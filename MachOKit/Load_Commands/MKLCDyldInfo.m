//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKLCDyldInfo.m
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

#import "MKLCDyldInfo.h"
#import "MKMachO.h"
#import "NSError+MK.h"

//----------------------------------------------------------------------------//
@implementation MKLCDyldInfo

@synthesize rebase_off = _rebase_off;
@synthesize rebase_size = _rebase_size;
@synthesize bind_off = _bind_off;
@synthesize bind_size = _bind_size;
@synthesize weak_bind_off = _weak_bind_off;
@synthesize weak_bind_size = _weak_bind_size;
@synthesize lazy_bind_off = _lazy_bind_off;
@synthesize lazy_bind_size = _lazy_bind_size;
@synthesize export_off = _export_off;
@synthesize export_size = _export_size;

//|++++++++++++++++++++++++++++++++++++|//
+ (uint32_t)ID
{ return LC_DYLD_INFO; }

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithOffset:(mk_vm_offset_t)offset fromParent:(MKBackedNode*)parent error:(NSError**)error
{
    self = [super initWithOffset:offset fromParent:parent error:error];
    if (self == nil) return nil;
    
    struct dyld_info_command lc;
    if ([self.memoryMap copyBytesAtOffset:offset fromAddress:parent.nodeContextAddress into:&lc length:sizeof(lc) requireFull:YES error:error] < sizeof(lc))
    { [self release]; return nil; }
    
    _rebase_off = MKSwapLValue32(lc.rebase_off, self.macho.dataModel);
    _rebase_size = MKSwapLValue32(lc.rebase_size, self.macho.dataModel);
    
    _bind_off = MKSwapLValue32(lc.bind_off, self.macho.dataModel);
    _bind_size = MKSwapLValue32(lc.bind_size, self.macho.dataModel);
    
    _weak_bind_off = MKSwapLValue32(lc.weak_bind_off, self.macho.dataModel);
    _weak_bind_size = MKSwapLValue32(lc.weak_bind_size, self.macho.dataModel);
    
    _lazy_bind_off = MKSwapLValue32(lc.lazy_bind_off, self.macho.dataModel);
    _lazy_bind_size = MKSwapLValue32(lc.lazy_bind_size, self.macho.dataModel);
    
    _export_off = MKSwapLValue32(lc.export_off, self.macho.dataModel);
    _export_size = MKSwapLValue32(lc.export_size, self.macho.dataModel);
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(rebase_off) description:@"Rebase Info Offset" offset:offsetof(struct dyld_info_command, rebase_off) size:sizeof(uint32_t)],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(rebase_size) description:@"Rebase Info Size" offset:offsetof(struct dyld_info_command, rebase_size) size:sizeof(uint32_t)],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(bind_off) description:@"Binding Info Size" offset:offsetof(struct dyld_info_command, bind_off) size:sizeof(uint32_t)],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(bind_size) description:@"Binding Info Size" offset:offsetof(struct dyld_info_command, bind_size) size:sizeof(uint32_t)],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(weak_bind_off) description:@"Weak Binding Info Size" offset:offsetof(struct dyld_info_command, weak_bind_off) size:sizeof(uint32_t)],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(weak_bind_size) description:@"Weak Binding Info Size" offset:offsetof(struct dyld_info_command, weak_bind_size) size:sizeof(uint32_t)],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(lazy_bind_off) description:@"Lazy Binding Info Size" offset:offsetof(struct dyld_info_command, lazy_bind_off) size:sizeof(uint32_t)],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(lazy_bind_size) description:@"Lazy Binding Info Size" offset:offsetof(struct dyld_info_command, lazy_bind_size) size:sizeof(uint32_t)],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(export_off) description:@"Export Info Size" offset:offsetof(struct dyld_info_command, export_off) size:sizeof(uint32_t)],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(export_size) description:@"Export Info Size" offset:offsetof(struct dyld_info_command, export_size) size:sizeof(uint32_t)],
    ]];
}

@end
