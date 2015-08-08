//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKDSCLocalSymbols.m
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

#import "MKDSCLocalSymbols.h"
#import "NSError+MK.h"
#import "MKNode+SharedCache.h"
#import "MKSharedCache.h"
#import "MKDSCHeader.h"
#import "MKDSCSymbolsInfo.h"
#import "MKDSCStringTable.h"
#import "MKDSCSymbolsEntry.h"

//----------------------------------------------------------------------------//
@implementation MKDSCLocalSymbols

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithAddress:(mk_vm_address_t)contextAddress inSharedCache:(MKSharedCache*)sharedCache error:(NSError**)error
{
    NSParameterAssert(sharedCache.header);
    NSError *localError;
    
    self = [super initWithParent:sharedCache error:error];
    if (self == nil) return nil;
    
    _contextAddress = contextAddress;
    
    // Don't need to correct for the slide.
    _vmAddress = (sharedCache.isSourceFile == NO) ? _contextAddress : MK_VM_ADDRESS_INVALID;
    
    _size = [self.memoryMap mappingSizeAtOffset:0 fromAddress:contextAddress length:sharedCache.header.localSymbolsSize];
    // This is not an error...
    if (_size < sharedCache.header.localSymbolsSize) {
        MK_PUSH_WARNING(nodeSize, MK_EINVALID_DATA, @"Mappable memory at address %" MK_VM_PRIxADDR " for %@ is less than the expected size %" MK_VM_PRIxSIZE ".", contextAddress, NSStringFromClass(self.class), sharedCache.header.localSymbolsSize);
    }
    
    // ...but it will be if we can't map the symbols info header.
    _header = [[MKDSCSymbolsInfo alloc] initWithOffset:0 fromParent:self error:&localError];
    if (_header == nil) {
        MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:localError.code underlyingError:localError description:@"Failed to load symbols info."];
        [self release]; return nil;
    }
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithParent:(MKNode*)parent error:(NSError**)error
{
    MKSharedCache *sharedCache = parent.sharedCache;
    NSAssert(sharedCache != nil, @"");
    
    mk_error_t err;
    mk_vm_address_t address;
    
    if ((err = mk_vm_address_add(sharedCache.nodeContextAddress, sharedCache.header.localSymbolsOffset, &address))) {
        MK_ERROR_OUT = MK_MAKE_VM_ARITHMETIC_ERROR(err, sharedCache.nodeContextAddress, sharedCache.header.slideInfoOffset);
        [self release]; return nil;
    }
    
    return [self initWithAddress:address inSharedCache:sharedCache error:error];
}

//|++++++++++++++++++++++++++++++++++++|//
- (void)dealloc
{
    [_entries release];
    [_header release];
    
    [super dealloc];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@synthesize header = _header;

//|++++++++++++++++++++++++++++++++++++|//
- (MKDSCStringTable*)stringTable
{
    if (_stringTable == nil)
    @autoreleasepool {
        NSError *e = nil;
        
        _stringTable = [[MKDSCStringTable alloc] initWithParent:self error:&e];
        if (_stringTable == nil)
            MK_PUSH_UNDERLYING_WARNING(stringTable, e, @"Could not load string table.");
    }
    
    return _stringTable;
}

//|++++++++++++++++++++++++++++++++++++|//
- (NSArray<MKDSCSymbolsEntry*> *)entries
{
    if (_entries == nil)
    @autoreleasepool {
        NSUInteger count = self.header.entriesCount;
        mk_vm_offset_t offset = self.header.entriesOffset;
        mk_vm_size_t size = self.nodeSize;
        mk_error_t err;
        
        NSMutableArray<MKDSCSymbolsEntry*> *entries = [[NSMutableArray alloc] initWithCapacity:count];
        
        for (NSUInteger i = 0; i < count; i++)
        {
            NSError *localError = nil;
            
            // Need to stop in this case.  Further memory might be mappable
            // (i.e. the s.c. header had a small localSymbolsSize) but we risk
            // creating an MKDSCSymbolsEntry with bogus data.
            if (offset > size) {
                MK_PUSH_WARNING(entries, MK_ENOT_FOUND, @"Symbol entry at offset %" MK_VM_PRIiOFFSET " is beyond size %" MK_VM_PRIiSIZE " of %@.", offset, size, NSStringFromClass(self.class));
                break;
            }
            
            MKDSCSymbolsEntry *entry = [[MKDSCSymbolsEntry alloc] initWithOffset:offset fromParent:self error:&localError];
            
            if (entry == nil) {
                MK_PUSH_UNDERLYING_WARNING(MK_PROPERTY(entries), localError, @"Could not load entry at offset %" MK_VM_PRIiOFFSET ".", offset);
                if (localError.code & MK_EMEMORY_ERROR) break;
            }
            
            [entries addObject:entry];
            
            if ((err = mk_vm_address_apply_offset(offset, entry.nodeSize, &offset))) {
                MK_PUSH_UNDERLYING_WARNING(localError, MK_MAKE_VM_ARITHMETIC_ERROR(err, offset, entry.nodeSize), @"");
                break;
            }
        }
        
        _entries = [entries copy];
        [entries release];
    }
    
    return _entries;
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_size_t)nodeSize
{ return _size; }

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_address_t)nodeAddress:(MKNodeAddressType)type
{
    switch (type) {
        case MKNodeContextAddress:
            return _contextAddress;
        case MKNodeVMAddress:
            if (_vmAddress != MK_VM_ADDRESS_INVALID)
                return _vmAddress;
            else
                @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"VM address of local symbols is indeterminate for a  dyld_shared_cache source file." userInfo:nil];
        default:
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Unsupported node address type." userInfo:nil];
    }
}

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        [MKNodeField nodeFieldWithProperty:MK_PROPERTY(header) description:@"Header"],
        //[MKNodeField nodeFieldWithProperty:MK_PROPERTY(stringTable) description:@"String Table"],
        [MKNodeField nodeFieldWithProperty:MK_PROPERTY(entries) description:@"Entries"],
    ]];
}

@end
