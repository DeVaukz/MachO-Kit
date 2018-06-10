//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKLCMain.m
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

#import "MKLCMain.h"
#import "MKInternal.h"
#import "MKMachO.h"

//----------------------------------------------------------------------------//
@implementation MKLCMain

@synthesize entryoff = _entryoff;
@synthesize stacksize = _stacksize;

//|++++++++++++++++++++++++++++++++++++|//
+ (uint32_t)ID
{ return LC_MAIN; }

//|++++++++++++++++++++++++++++++++++++|//
+ (uint32_t)canInstantiateWithLoadCommandID:(uint32_t)commandID
{
    if (self != MKLCMain.class)
        return 0;
    
    return commandID == [self ID] ? 10 : 0;
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithOffset:(mk_vm_offset_t)offset fromParent:(MKBackedNode*)parent error:(NSError**)error
{
    self = [super initWithOffset:offset fromParent:parent error:error];
    if (self == nil) return nil;
    
    struct entry_point_command lc;
    if ([self.memoryMap copyBytesAtOffset:offset fromAddress:parent.nodeContextAddress into:&lc length:sizeof(lc) requireFull:YES error:error] < sizeof(lc))
    { [self release]; return nil; }
    
    _entryoff = MKSwapLValue64(lc.entryoff, self.macho.dataModel);
    _stacksize = MKSwapLValue64(lc.stacksize, self.macho.dataModel);
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    __unused struct entry_point_command lc;
    
    MKNodeFieldBuilder *entryoff = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(entryoff)
        type:MKNodeFieldTypeUnsignedQuadWord.sharedInstance
        offset:offsetof(typeof(lc), entryoff)
        size:sizeof(lc.entryoff)
    ];
    entryoff.description = @"Entry Point Offset";
    entryoff.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *stacksize = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(stacksize)
        type:MKNodeFieldTypeUnsignedQuadWord.sharedInstance
        offset:offsetof(typeof(lc), stacksize)
        size:sizeof(lc.stacksize)
    ];
    stacksize.description = @"Stack Size";
    stacksize.options = MKNodeFieldOptionDisplayAsDetail;
    
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        entryoff.build,
        stacksize.build
    ]];
}

@end
