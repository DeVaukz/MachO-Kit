//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKDSCMappingInfo.m
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

#import "MKDSCMappingInfo.h"
#import "NSError+MK.h"

#include "dyld_cache_format.h"

//----------------------------------------------------------------------------//
@implementation MKDSCMappingInfo

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithOffset:(mk_vm_offset_t)offset fromParent:(MKBackedNode*)parent error:(NSError**)error
{
    NSParameterAssert(parent.dataModel);
    
    self = [super initWithOffset:offset fromParent:parent error:error];
    if (self == nil) return nil;
    
    struct dyld_cache_mapping_info scmi;
    if ([self.memoryMap copyBytesAtOffset:offset fromAddress:parent.nodeContextAddress into:&scmi length:sizeof(scmi) requireFull:YES error:error] < sizeof(scmi))
    { [self release]; return nil; }
    
    _address = MKSwapLValue64(scmi.address, self.dataModel);
    _size = MKSwapLValue64(scmi.size, self.dataModel);
    _fileOffset = MKSwapLValue64(scmi.fileOffset, self.dataModel);
    _maxProt = (vm_prot_t)MKSwapLValue32(scmi.maxProt, self.dataModel);
    _initProt = (vm_prot_t)MKSwapLValue32(scmi.initProt, self.dataModel);
    
    return self;
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Shared Cache Struct Values
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@synthesize address = _address;
@synthesize size = _size;
@synthesize fileOffset = _fileOffset;
@synthesize maxProt = _maxProt;
@synthesize initProt = _initProt;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_size_t)nodeSize
{ return sizeof(struct dyld_cache_mapping_info); }

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(address) description:@"Mapping Address" offset:offsetof(struct dyld_cache_mapping_info, address) size:sizeof(uint64_t) format:MKNodeFieldFormatAddress],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(size) description:@"Mapping Size" offset:offsetof(struct dyld_cache_mapping_info, size) size:sizeof(uint64_t) format:MKNodeFieldFormatSize],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(fileOffset) description:@"File Offset" offset:offsetof(struct dyld_cache_mapping_info, fileOffset) size:sizeof(uint64_t) format:MKNodeFieldFormatOffset],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(maxProt) description:@"Maximum Protection" offset:offsetof(struct dyld_cache_mapping_info, maxProt) size:sizeof(uint32_t) format:MKNodeFieldFormatHexCompact],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(initProt) description:@"Initial Protection" offset:offsetof(struct dyld_cache_mapping_info, initProt) size:sizeof(uint32_t) format:MKNodeFieldFormatHexCompact]
    ]];
}

@end
