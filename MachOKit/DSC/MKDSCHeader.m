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

struct dyld_cache_header
{
    char		magic[16];				// e.g. "dyld_v0    i386"
    uint32_t	mappingOffset;			// file offset to first dyld_cache_mapping_info
    uint32_t	mappingCount;			// number of dyld_cache_mapping_info entries
    uint32_t	imagesOffset;			// file offset to first dyld_cache_image_info
    uint32_t	imagesCount;			// number of dyld_cache_image_info entries
    uint64_t	dyldBaseAddress;		// base address of dyld when cache was built
    uint64_t	codeSignatureOffset;	// file offset of code signature blob
    uint64_t	codeSignatureSize;		// size of code signature blob (zero means to end of file)
    uint64_t	slideInfoOffset;		// file offset of kernel slid info
    uint64_t	slideInfoSize;			// size of kernel slid info
    uint64_t	localSymbolsOffset;		// file offset of where local symbols are stored
    uint64_t	localSymbolsSize;		// size of local symbols information
    uint8_t		uuid[16];				// unique value for each shared cache file
};

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
    _slideInfoOffset = MKSwapLValue64(sch.slideInfoOffset, self.dataModel);
    _slideInfoSize = MKSwapLValue64(sch.slideInfoSize, self.dataModel);
    _localSymbolsOffset = MKSwapLValue64(sch.localSymbolsOffset, self.dataModel);
    _localSymbolsSize = MKSwapLValue64(sch.localSymbolsSize, self.dataModel);
    
    _uuid = [[NSUUID alloc] initWithUUIDBytes:sch.uuid];
    if (_uuid == nil)
        MK_PUSH_WARNING(uuid, MK_EINVALID_DATA, @"Could not create an NSUUID with data.");
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (void)dealloc
{
    [_magic release];
    [_uuid release];
    [super dealloc];
}

//----------------------------------------------------------------------------//
#pragma mark -  Shared Cache Header Values
//----------------------------------------------------------------------------//

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

//----------------------------------------------------------------------------//
#pragma mark -  MKNode
//----------------------------------------------------------------------------//

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_size_t)nodeSize
{ return sizeof(struct dyld_cache_header); }

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    __unused struct dyld_cache_header h;
    
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(magic) description:@"Magic String" offset:offsetof(struct dyld_cache_header, magic) size:sizeof(h.magic)],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(mappingOffset) description:@"Mapping Offset" offset:offsetof(struct dyld_cache_header, mappingOffset) size:sizeof(h.mappingOffset)],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(mappingCount) description:@"Number of Mappings" offset:offsetof(struct dyld_cache_header, mappingCount) size:sizeof(h.mappingCount)],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(imagesOffset) description:@"Images Offset" offset:offsetof(struct dyld_cache_header, imagesOffset) size:sizeof(h.imagesOffset)],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(imagesCount) description:@"Number of Images" offset:offsetof(struct dyld_cache_header, imagesCount) size:sizeof(h.imagesCount)],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(dyldBaseAddress) description:@"Dyld Base Address" offset:offsetof(struct dyld_cache_header, dyldBaseAddress) size:sizeof(h.dyldBaseAddress)],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(codeSignatureOffset) description:@"Code Signature Offset" offset:offsetof(struct dyld_cache_header, codeSignatureOffset) size:sizeof(h.codeSignatureOffset)],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(codeSignatureSize) description:@"Code Signature Size" offset:offsetof(struct dyld_cache_header, codeSignatureSize) size:sizeof(h.codeSignatureSize)],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(slideInfoOffset) description:@"Slide Info Offset" offset:offsetof(struct dyld_cache_header, slideInfoOffset) size:sizeof(h.slideInfoOffset)],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(slideInfoSize) description:@"Slide Info Size" offset:offsetof(struct dyld_cache_header, slideInfoSize) size:sizeof(h.slideInfoSize)],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(localSymbolsOffset) description:@"Local Symbols Offset" offset:offsetof(struct dyld_cache_header, localSymbolsOffset) size:sizeof(h.localSymbolsOffset)],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(localSymbolsSize) description:@"Local Symbols Size" offset:offsetof(struct dyld_cache_header, localSymbolsSize) size:sizeof(h.localSymbolsSize)],
        [MKPrimativeNodeField fieldWithName:MK_PROPERTY(uuid) keyPath:@"uuid.UUIDString" description:@"UUID" offset:offsetof(struct dyld_cache_header, uuid) size:sizeof(h.uuid)],
    ]];
}

@end
