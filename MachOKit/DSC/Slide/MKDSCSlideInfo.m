//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKDSCSlideInfo.m
//|
//|             D.V.
//|             Copyright (c) 2014-2015 D.V. All rights reserved.
//|
//| Permission is hereby granted, free of charge, to any person obtaining a
//| copy of this software and associated documentation files (the "Software"),
//| to deal in the Software without restriction, including without limitation
//| the rights to use, copy, modify, merge, publish, distribute, sublicense,
//| and/or sell copies of the Software, and to permit persons to whom the
//| Software is furnished to do so, subject to the following conditions:
//|
//| The above copyright notice and this permission notice shall be included
//| in all copies or substantial portions of the Software.
//|
//| THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//| OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//| MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//| IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
//| CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
//| TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
//| SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//----------------------------------------------------------------------------//

#import "MKDSCSlideInfo.h"
#import "MKSharedCache.h"
#import "MKDSCHeader.h"
#import "MKDSCMapping.h"
#import "MKDSCSlideInfoHeader.h"
#import "MKDSCSlideInfoBitmap.h"
#import "MKDSCSlideInfoPage.h"
#import "MKDSCSlidPointer.h"
#import "MKNode+SharedCache.h"
#import "NSError+MK.h"

//----------------------------------------------------------------------------//
@implementation MKDSCSlideInfo

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithSharedCache:(MKSharedCache*)sharedCache error:(NSError**)error
{
    NSParameterAssert(sharedCache);
    NSError *localError;
    mk_error_t err;
    
    // The slide info resides in the readonly mapping.  This should always be
    // the final mapping.
    MKDSCMapping *readOnlyMapping = nil;
    for (MKDSCMapping *mapping in sharedCache.mappings) {
        if (mapping.initialProtection == VM_PROT_READ)
            readOnlyMapping = mapping;
        // Don't break
    }
    
    if (readOnlyMapping == nil) {
        MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_ENOT_FOUND description:@"%@ does not have a read-only mapping.", sharedCache];
        [self release]; return nil;
    }
    
    self = [super initWithParent:sharedCache error:error];
    if (self == nil) return nil;
    
    // Despite the shared cache being our real parent node, all of our data
    // should be within the readonly mapping.
    _memoryMap = [readOnlyMapping.memoryMap retain];
    NSParameterAssert(_memoryMap);
    
    // nodeAddress := readOnlyMappingAddress + (slideInfoOffset - readOnlyMappingFileOffset)
    mk_vm_offset_t slideInfoOffset = sharedCache.header.slideInfoOffset;
    mk_vm_size_t slideInfoSize = sharedCache.header.slideInfoSize;
    mk_vm_offset_t readOnlyMappingFileOffset = readOnlyMapping.fileOffset;
    mk_vm_address_t readOnlyMappingAddress = readOnlyMapping.nodeContextAddress;
    mk_vm_slide_t slide = sharedCache.slide;
    
    if ((err = mk_vm_address_subtract(slideInfoOffset, readOnlyMappingFileOffset, &_contextAddress))) {
        MK_ERROR_OUT = MK_MAKE_VM_ADDRESS_DEFFERENCE_ARITHMETIC_ERROR(err, slideInfoOffset, readOnlyMappingFileOffset);
        [self release]; return nil;
    }
    
    if ((err = mk_vm_address_add(_contextAddress, readOnlyMappingAddress, &_contextAddress))) {
        MK_ERROR_OUT = MK_MAKE_VM_ADDRESS_ADD_ARITHMETIC_ERROR(err, _contextAddress, readOnlyMappingAddress);
        [self release]; return nil;
    }
    
    // Now subtract any slide to derive the vmAddress
    if ((err = mk_vm_address_remove_slide(_contextAddress, slide, &_vmAddress))) {
        MK_ERROR_OUT = MK_MAKE_VM_ADDRESS_REMOVE_SLIDE_ARITHMETIC_ERROR(err, slide, _contextAddress);
        [self release]; return nil;
    }
    
    // Check that all the data is available
    if ([_memoryMap hasMappingAtOffset:0 fromAddress:_contextAddress length:slideInfoSize error:&localError] == NO) {
        MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_ENOT_FOUND underlyingError:localError description:@"Complete slide info data does not exist at context-relative address %" MK_VM_PRIxADDR ".", _contextAddress];
        [self release]; return nil;
    }
    
    _size = slideInfoSize;
    
    // Load the header
    _header = [[MKDSCSlideInfoHeader alloc] initWithParent:self error:&localError];
    if (_header == nil) {
        MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:localError.code underlyingError:localError description:@"Failed to load slide info header."];
        [self release]; return nil;
    }
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithParent:(MKNode*)parent error:(NSError**)error
{ return [self initWithSharedCache:parent.sharedCache error:error]; }

//|++++++++++++++++++++++++++++++++++++|//
- (void)dealloc
{
    [_toc release];
    [_entries release];
    [_header dealloc];
    [_memoryMap release];
    
    [super dealloc];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Header and Entires
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@synthesize header = _header;

//|++++++++++++++++++++++++++++++++++++|//
- (NSArray*)entries
{
    if (_entries == nil)
    @autoreleasepool {
        uint32_t entriesCount = _header.entriesCount;
        
        NSMutableArray<MKDSCSlideInfoBitmap*> *entries = [[NSMutableArray alloc] initWithCapacity:entriesCount];
        mach_vm_offset_t offset = _header.entriesOffset;
        mach_vm_offset_t oldOffset;
        
        while (entriesCount--)
        @autoreleasepool {
                
            NSError *e = nil;
                
            MKDSCSlideInfoBitmap *entry = [[MKDSCSlideInfoBitmap alloc] initWithOffset:offset fromParent:self error:&e];
            if (entry == nil) {
                // If we fail to instantiate an instance of MKDSCSlideInfoEntry
                // it means we've walked off the end of memory that can be
                // mapped by our MKMemoryMap.
                MK_PUSH_UNDERLYING_WARNING(entries, e, @"Failed to load bitmap at index %" PRIu32 ".", _header.entriesCount - entriesCount);
                break;
            }
                
            oldOffset = offset;
            offset += entry.nodeSize;
                
            [entries addObject:entry];
            [entry release];
            
            if (oldOffset > offset) {
                MK_PUSH_WARNING(entries, MK_EOVERFLOW, @"Encountered an overflow while advancing the parser to the entry following index %" PRIu32 ".", _header.entriesCount - entriesCount);
                break;
            }
        }
        
        _entries = [entries copy];
        [entries release];
    }
    
    return _entries;
}

//|++++++++++++++++++++++++++++++++++++|//
- (NSArray*)toc
{
    if (_toc == nil)
    @autoreleasepool {
        uint32_t tocCount = _header.tocCount;
        
        NSMutableArray<MKDSCSlideInfoPage*> *toc = [[NSMutableArray alloc] initWithCapacity:tocCount];
        mach_vm_offset_t offset = _header.tocOffset;
        mach_vm_offset_t oldOffset;
        
        while (tocCount--)
        @autoreleasepool {
            
            NSError *tocError = nil;
            
            MKDSCSlideInfoPage *page = [[MKDSCSlideInfoPage alloc] initWithOffset:offset fromParent:self error:&tocError];
            if (page == nil) {
                // If we fail to instantiate an instance of
                // MKDSCSlideInfoTOCPage it means we've walked off the end of
                // memory that can be mapped by our MKMemoryMap.
                MK_PUSH_UNDERLYING_WARNING(toc, tocError, @"Failed to load page at index %" PRIu32 ".", _header.tocCount - tocCount);
                break;
            }
            
            oldOffset = offset;
            offset += page.nodeSize;
            
            [toc addObject:page];
            [page release];
            
            if (oldOffset > offset) {
                MK_PUSH_WARNING(toc, MK_EOVERFLOW, @"Encountered an overflow while advancing the parser to the page following index %" PRIu32 ".", _header.tocCount - tocCount);
                break;
            }
        }
        
        _toc = [toc copy];
        [toc release];
    }
    
    return _toc;
}

//|++++++++++++++++++++++++++++++++++++|//
- (NSArray*)slidPointers
{
    if (_slidPointers == nil)
    @autoreleasepool {
        NSArray *toc = self.toc;
        if (toc == nil) {
            MK_PUSH_WARNING(slidPointers, MK_ENOT_FOUND, @"Can not locate slid pointers without TOC.");
            return nil;
        }
        
        // Preflight this.
        NSArray *entries = self.entries;
        if (entries == nil) {
            MK_PUSH_WARNING(slidPointers, MK_ENOT_FOUND, @"Can not locate slid pointers without entires list.");
            return nil;
        }
        
        uint64_t pageCount = toc.count;
        NSMutableArray<MKDSCSlidPointer*> *slidPointers = [[NSMutableArray alloc] initWithCapacity:(pageCount * 128)];
        
        for (uint64_t i = 0; i < pageCount; i++)
        @autoreleasepool {
            MKDSCSlideInfoPage *page = toc[i];
            MKDSCSlideInfoBitmap *entry = page.bitmap;
            
            if (entry == nil) {
                MK_PUSH_WARNING(slidPointers, MK_ENOT_FOUND, @"Skipping pointers in page %@.  No corresponding bitmap.", page);
                return nil;
            }
            
            // entryBytes can not be NULL, entry would not have loaded.
            const uint8_t *entryBytes = entry.data.bytes;
            uint32_t entrySize = (uint32_t)entry.nodeSize;
            
            for (unsigned int j = 0; j < entrySize; j++) {
                uint8_t b = entryBytes[j];
                if (b == 0x0) continue;
                
                for (unsigned int k = 0; k < 8; k++) {
                    if ((b & (1<<k)) == 0) continue;
                    
                    NSError *e;
                    uint32_t offset = (j * 8) + k;
                    
                    MKDSCSlidPointer *slidPointer = [[MKDSCSlidPointer alloc] initWithOffset:offset inEntryForPage:page error:&e];
                    if (slidPointer == nil) {
                        MK_PUSH_UNDERLYING_WARNING(slidPointers, e, @"Could not load pointer for offset %" PRIu32 " in bitmap for page %@.", offset, page);
                    }
                    
                    [slidPointers addObject:slidPointer];
                    [slidPointer release];
                }
            }
        }
        
        _slidPointers = [slidPointers copy];
        [slidPointers release];
    }
    
    return _slidPointers;
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@synthesize memoryMap = _memoryMap;
@synthesize nodeSize = _size;

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_address_t)nodeAddress:(MKNodeAddressType)type
{
    switch (type) {
        case MKNodeContextAddress:
            return _contextAddress;
        case MKNodeVMAddress:
            return _vmAddress;
        default:
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Unsupported node address type." userInfo:nil];
    }
}

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        [MKNodeField nodeFieldWithProperty:MK_PROPERTY(header) description:@"Header"],
        [MKNodeField nodeFieldWithProperty:MK_PROPERTY(entries) description:@"Entries"],
        [MKNodeField nodeFieldWithProperty:MK_PROPERTY(toc) description:@"TOC"],
        [MKNodeField nodeFieldWithProperty:MK_PROPERTY(slidPointers) description:@"Slid Pointers"]
    ]];
}

@end
