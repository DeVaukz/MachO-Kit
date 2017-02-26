//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKLinkEditDataLoadCommand.m
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

#import "MKLinkEditDataLoadCommand.h"
#import "MKInternal.h"
#import "MKMachO.h"

//----------------------------------------------------------------------------//
@implementation MKLinkEditDataLoadCommand

@synthesize dataoff = _dataoff;
@synthesize datasize = _datasize;

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithOffset:(mk_vm_offset_t)offset fromParent:(MKBackedNode*)parent error:(NSError**)error
{
    self = [super initWithOffset:offset fromParent:parent error:error];
    if (self == nil) return nil;
    
    struct linkedit_data_command lc;
    if ([self.memoryMap copyBytesAtOffset:offset fromAddress:parent.nodeContextAddress into:&lc length:sizeof(lc) requireFull:YES error:error] < sizeof(lc))
    { [self release]; return nil; }
    
    _dataoff = MKSwapLValue32(lc.dataoff, self.macho.dataModel);
    _datasize = MKSwapLValue32(lc.datasize, self.macho.dataModel);
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(dataoff) description:@"Data Offset" offset:offsetof(struct linkedit_data_command, dataoff) size:sizeof(uint32_t)],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(datasize) description:@"Data Size" offset:offsetof(struct linkedit_data_command, datasize) size:sizeof(uint32_t)]
    ]];
}

@end
