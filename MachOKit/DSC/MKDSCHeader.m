//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKDSCHeader.m
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

#import "MKDSCHeader.h"
#import "NSError+MK.h"
#import "MKMachO.h"

#include "dyld_cache_format.h"

//----------------------------------------------------------------------------//
@implementation MKDSCHeader

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithOffset:(mk_vm_offset_t)offset fromParent:(MKBackedNode*)parent error:(NSError**)error
{
    NSParameterAssert(parent.dataModel);
    
    self = [super initWithOffset:offset fromParent:parent error:error];
    if (self == nil) return nil;
    
    struct dyld_cache_header sch;
    if ([self.memoryMap copyBytesAtOffset:offset fromAddress:parent.nodeContextAddress into:&sch length:sizeof(sch) requireFull:YES error:error] < sizeof(sch))
    { [self release]; return nil; }
    
    _magic = [[NSString alloc] initWithBytes:sch.magic length:strnlen(sch.magic, sizeof(sch.magic)) encoding:NSUTF8StringEncoding];
    if (_magic == nil)
        MK_PUSH_WARNING(magic, MK_EINVALID_DATA, @"Could not form a string with data.");
    
    _mappingOffset = MKSwapLValue32(sch.mappingOffset, self.dataModel);
    _mappingCount = MKSwapLValue32(sch.mappingCount, self.dataModel);
    _imagesOffset = MKSwapLValue32(sch.imagesOffset, self.dataModel);
    _imagesCount = MKSwapLValue32(sch.imagesCount, self.dataModel);
    _dyldBaseAddress = MKSwapLValue64(sch.dyldBaseAddress, self.dataModel);
    _codeSignatureOffset = MKSwapLValue64(sch.codeSignatureOffset, self.dataModel);
    _codeSignatureSize = MKSwapLValue64(sch.codeSignatureSize, self.dataModel);
    
    // The slideInfo* fields are only present if the header size is >= 0x48.
    // Dyld actually checks for this so presumably caches without it exist.
#define HAS_SLIDE_INFO (_mappingOffset >= offsetof(struct dyld_cache_header, slideInfoSize) + sizeof(sch.slideInfoSize))
    if (HAS_SLIDE_INFO) {
        _slideInfoOffset = MKSwapLValue64(sch.slideInfoOffset, self.dataModel);
        _slideInfoSize = MKSwapLValue64(sch.slideInfoSize, self.dataModel);
    }
    
    // The localSymbols* fields are only present if the header size is >= 0x58.
#define HAS_LOCAL_SYMBOLS (_mappingOffset >= offsetof(struct dyld_cache_header, localSymbolsSize) + sizeof(sch.localSymbolsSize))
    if (HAS_LOCAL_SYMBOLS) {
        _localSymbolsOffset = MKSwapLValue64(sch.localSymbolsOffset, self.dataModel);
        _localSymbolsSize = MKSwapLValue64(sch.localSymbolsSize, self.dataModel);
    }
    
    // The uuid field is only present if the header size is >= 0x68.  Dyld
    // actually checks for this so presumably caches without it exist.
#define HAS_UUID (_mappingOffset >= offsetof(struct dyld_cache_header, uuid) + sizeof(sch.uuid))
    if (HAS_UUID) {
        _uuid = [[NSUUID alloc] initWithUUIDBytes:sch.uuid];
        if (_uuid == nil)
            MK_PUSH_WARNING(uuid, MK_EINVALID_DATA, @"Could not create an NSUUID with data.");
    }
    
    // The cacheType field is only present if the header size is >= 0x70.  This
    // field first appeared in the OS X 10.11 dyld sources.
#define HAS_CACHE_TYPE (_mappingOffset >= offsetof(struct dyld_cache_header, cacheType) + sizeof(sch.cacheType))
    if (HAS_CACHE_TYPE)
        _cacheType = MKSwapLValue64(sch.cacheType, self.dataModel);
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (void)dealloc
{
    [_magic release];
    [_uuid release];
	
    [super dealloc];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Shared Cache Header Values
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@synthesize magic = _magic;
@synthesize mappingOffset = _mappingOffset;
@synthesize mappingCount = _mappingCount;
@synthesize imagesOffset = _imagesOffset;
@synthesize imagesCount = _imagesCount;
@synthesize dyldBaseAddress = _dyldBaseAddress;
@synthesize codeSignatureOffset = _codeSignatureOffset;
@synthesize codeSignatureSize = _codeSignatureSize;
@synthesize slideInfoOffset = _slideInfoOffset;
@synthesize slideInfoSize = _slideInfoSize;
@synthesize localSymbolsOffset = _localSymbolsOffset;
@synthesize localSymbolsSize = _localSymbolsSize;
@synthesize uuid = _uuid;
@synthesize cacheType = _cacheType;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_size_t)nodeSize
{ return MIN(sizeof(struct dyld_cache_header), _mappingOffset); }

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    __unused struct dyld_cache_header sch;
    
    NSArray *fields = @[
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(magic) description:@"Magic String" offset:offsetof(struct dyld_cache_header, magic) size:sizeof(sch.magic)],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(mappingOffset) description:@"Mapping Offset" offset:offsetof(struct dyld_cache_header, mappingOffset) size:sizeof(sch.mappingOffset) format:MKNodeFieldFormatOffset],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(mappingCount) description:@"Number of Mappings" offset:offsetof(struct dyld_cache_header, mappingCount) size:sizeof(sch.mappingCount)],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(imagesOffset) description:@"Images Offset" offset:offsetof(struct dyld_cache_header, imagesOffset) size:sizeof(sch.imagesOffset)],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(imagesCount) description:@"Number of Images" offset:offsetof(struct dyld_cache_header, imagesCount) size:sizeof(sch.imagesCount)],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(dyldBaseAddress) description:@"Dyld Base Address" offset:offsetof(struct dyld_cache_header, dyldBaseAddress) size:sizeof(sch.dyldBaseAddress) format:MKNodeFieldFormatAddress],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(codeSignatureOffset) description:@"Code Signature Offset" offset:offsetof(struct dyld_cache_header, codeSignatureOffset) size:sizeof(sch.codeSignatureOffset) format:MKNodeFieldFormatOffset],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(codeSignatureSize) description:@"Code Signature Size" offset:offsetof(struct dyld_cache_header, codeSignatureSize) size:sizeof(sch.codeSignatureSize) format:MKNodeFieldFormatSize]
    ];
    
    if (HAS_SLIDE_INFO) {
        fields = [fields arrayByAddingObjectsFromArray:@[
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(slideInfoOffset) description:@"Slide Info Offset" offset:offsetof(struct dyld_cache_header, slideInfoOffset) size:sizeof(sch.slideInfoOffset) format:MKNodeFieldFormatOffset],
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(slideInfoSize) description:@"Slide Info Size" offset:offsetof(struct dyld_cache_header, slideInfoSize) size:sizeof(sch.slideInfoSize) format:MKNodeFieldFormatSize]
        ]];
    }
    
    if (HAS_LOCAL_SYMBOLS) {
        fields = [fields arrayByAddingObjectsFromArray:@[
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(localSymbolsOffset) description:@"Local Symbols Offset" offset:offsetof(struct dyld_cache_header, localSymbolsOffset) size:sizeof(sch.localSymbolsOffset) format:MKNodeFieldFormatOffset],
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(localSymbolsSize) description:@"Local Symbols Size" offset:offsetof(struct dyld_cache_header, localSymbolsSize) size:sizeof(sch.localSymbolsSize) format:MKNodeFieldFormatSize]
        ]];
    }
    
    if (HAS_UUID) {
        fields = [fields arrayByAddingObject:[MKPrimativeNodeField fieldWithName:MK_PROPERTY(uuid) keyPath:@"uuid.UUIDString" description:@"UUID" offset:offsetof(struct dyld_cache_header, uuid) size:sizeof(sch.uuid)]];
    }
    
    if (HAS_CACHE_TYPE) {
        fields = [fields arrayByAddingObject:[MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(cacheType) description:@"Cache Type" offset:offsetof(struct dyld_cache_header, cacheType) size:sizeof(sch.cacheType)]];
    }
    
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:fields];
}

@end
