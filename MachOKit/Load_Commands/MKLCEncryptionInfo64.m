//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKLCEncryptionInfo64.m
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

#import "MKLCEncryptionInfo64.h"
#import "MKInternal.h"
#import "MKMachO.h"

//----------------------------------------------------------------------------//
@implementation MKLCEncryptionInfo64

@synthesize pad = _pad;

//|++++++++++++++++++++++++++++++++++++|//
+ (uint32_t)ID
{ return LC_ENCRYPTION_INFO_64; }

//|++++++++++++++++++++++++++++++++++++|//
+ (uint32_t)canInstantiateWithLoadCommandID:(uint32_t)commandID
{
    if (self != MKLCEncryptionInfo64.class)
        return 0;
    
    return commandID == [self ID] ? 10 : 0;
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithOffset:(mk_vm_offset_t)offset fromParent:(MKBackedNode*)parent error:(NSError**)error
{
    self = [super initWithOffset:offset fromParent:parent error:error];
    if (self == nil) return nil;
    
    struct encryption_info_command_64 lc;
    if ([self.memoryMap copyBytesAtOffset:offset fromAddress:parent.nodeContextAddress into:&lc length:sizeof(lc) requireFull:YES error:error] < sizeof(lc))
    { [self release]; return nil; }
    
    _pad = MKSwapLValue32(lc.pad, self.macho.dataModel);
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    __unused struct encryption_info_command_64 lc;
    
    MKNodeFieldBuilder *pad = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(pad)
        type:MKNodeFieldTypeUnsignedDoubleWord.sharedInstance
        offset:offsetof(typeof(lc), pad)
        size:sizeof(lc.pad)
    ];
    pad.description = @"Padding";
    pad.options = MKNodeFieldOptionDisplayAsDetail;
    
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        pad.build
    ]];
}

@end
