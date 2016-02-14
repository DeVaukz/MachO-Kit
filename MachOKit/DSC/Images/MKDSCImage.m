//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKDSCImage.m
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

#import "MKDSCImage.h"
#import "NSError+MK.h"
#import "MKMachO.h"

#include "dyld_cache_format.h"

//----------------------------------------------------------------------------//
@implementation MKDSCImage

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithOffset:(mk_vm_offset_t)offset fromParent:(MKBackedNode*)parent error:(NSError**)error
{
    NSParameterAssert(parent.dataModel);
    
    self = [super initWithOffset:offset fromParent:parent error:error];
    if (self == nil) return nil;
    
    struct dyld_cache_image_info scii;
    if ([self.memoryMap copyBytesAtOffset:offset fromAddress:parent.nodeContextAddress into:&scii length:sizeof(scii) requireFull:YES error:error] < sizeof(scii))
    { [self release]; return nil; }
    
    _address = MKSwapLValue64(scii.address, self.dataModel);
    _modTime = MKSwapLValue64(scii.modTime, self.dataModel);
    _inode = MKSwapLValue64(scii.inode, self.dataModel);
    _pathFileOffset = MKSwapLValue32(scii.pathFileOffset, self.dataModel);
    
    return self;
}

//----------------------------------------------------------------------------//
#pragma mark -  Shared Cache Struct Values
//----------------------------------------------------------------------------//

@synthesize address = _address;
@synthesize modTime = _modTime;
@synthesize inode = _inode;
@synthesize pathFileOffset = _pathFileOffset;

//----------------------------------------------------------------------------//
#pragma mark -  MKNode
//----------------------------------------------------------------------------//

//|++++++++++++++++++++++++++++++++++++|//
- (mach_vm_size_t)nodeSize
{ return sizeof(struct dyld_cache_image_info); }

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(address) description:@"Image Start Address" offset:offsetof(struct dyld_cache_image_info, address) size:sizeof(uint64_t) format:MKNodeFieldFormatAddress],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(modTime) description:@"Modification Time" offset:offsetof(struct dyld_cache_image_info, modTime) size:sizeof(uint64_t)],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(inode) description:@"iNode" offset:offsetof(struct dyld_cache_image_info, inode) size:sizeof(uint64_t)],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(pathFileOffset) description:@"Image Path Offset" offset:offsetof(struct dyld_cache_image_info, pathFileOffset) size:sizeof(uint32_t) format:MKNodeFieldFormatOffset]
    ]];
}

@end
