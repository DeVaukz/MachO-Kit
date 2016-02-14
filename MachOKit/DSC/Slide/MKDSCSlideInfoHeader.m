//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKDSCSlideInfoHeader.m
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

#import "MKDSCSlideInfoHeader.h"
#import "NSError+MK.h"

#include "dyld_cache_format.h"

//----------------------------------------------------------------------------//
@implementation MKDSCSlideInfoHeader

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithOffset:(mk_vm_offset_t)offset fromParent:(MKBackedNode*)parent error:(NSError**)error
{
    NSParameterAssert(parent.dataModel);
    
    self = [super initWithOffset:offset fromParent:parent error:error];
    if (self == nil) return nil;

    struct dyld_cache_slide_info scli;
    if ([self.memoryMap copyBytesAtOffset:offset fromAddress:parent.nodeContextAddress into:&scli length:sizeof(scli) requireFull:YES error:error] < sizeof(scli))
    { [self release]; return nil; }
    
    _version = MKSwapLValue32(scli.version, self.dataModel);
    _tocOffset = MKSwapLValue32(scli.toc_offset, self.dataModel);
    _tocCount = MKSwapLValue32(scli.toc_count, self.dataModel);
    _entriesOffset = MKSwapLValue32(scli.entries_offset, self.dataModel);
    _entriesCount = MKSwapLValue32(scli.entries_count, self.dataModel);
    _entriesSize = MKSwapLValue32(scli.entries_size, self.dataModel);
    
    // Current version is 1.
    if (_version != 1) {
        MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_EINVAL description:@"Unknown Shared Cache slide info version: %" PRIu32 ".", _version];
        [self release]; return nil;
    }
    
    return self;
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Shared Cache Struct Values
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@synthesize version = _version;
@synthesize tocOffset = _tocOffset;
@synthesize tocCount = _tocCount;
@synthesize entriesOffset = _entriesOffset;
@synthesize entriesCount = _entriesCount;
@synthesize entriesSize = _entriesSize;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_size_t)nodeSize
{ return sizeof(struct dyld_cache_image_info); }

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(version) description:@"Version" offset:offsetof(struct dyld_cache_slide_info, version) size:sizeof(uint32_t)],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(tocOffset) description:@"TOC Offset" offset:offsetof(struct dyld_cache_slide_info, toc_offset) size:sizeof(uint32_t) format:MKNodeFieldFormatOffset],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(tocCount) description:@"TOC Count" offset:offsetof(struct dyld_cache_slide_info, toc_count) size:sizeof(uint32_t)],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(entriesOffset) description:@"Entries Offset" offset:offsetof(struct dyld_cache_slide_info, entries_offset) size:sizeof(uint32_t) format:MKNodeFieldFormatOffset],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(entriesCount) description:@"Entries Count" offset:offsetof(struct dyld_cache_slide_info, entries_count) size:sizeof(uint32_t)],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(entriesSize) description:@"Entries Size" offset:offsetof(struct dyld_cache_slide_info, entries_size) size:sizeof(uint32_t) format:MKNodeFieldFormatSize]
    ]];
}

@end
