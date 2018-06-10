//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKLCEncryptionInfo.m
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

#import "MKLCEncryptionInfo.h"
#import "MKInternal.h"
#import "MKMachO.h"

//----------------------------------------------------------------------------//
@implementation MKLCEncryptionInfo

@synthesize cryptoff = _cryptoff;
@synthesize cryptsize = _cryptsize;
@synthesize cryptid = _cryptid;

//|++++++++++++++++++++++++++++++++++++|//
+ (uint32_t)ID
{ return LC_ENCRYPTION_INFO; }

//|++++++++++++++++++++++++++++++++++++|//
+ (uint32_t)canInstantiateWithLoadCommandID:(uint32_t)commandID
{
    if (self != MKLCEncryptionInfo.class)
        return 0;
    
    return commandID == [self ID] ? 10 : 0;
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithOffset:(mk_vm_offset_t)offset fromParent:(MKBackedNode*)parent error:(NSError**)error
{
    self = [super initWithOffset:offset fromParent:parent error:error];
    if (self == nil) return nil;
    
    struct encryption_info_command lc;
    if ([self.memoryMap copyBytesAtOffset:offset fromAddress:parent.nodeContextAddress into:&lc length:sizeof(lc) requireFull:YES error:error] < sizeof(lc))
    { [self release]; return nil; }
    
    _cryptoff = MKSwapLValue32(lc.cryptoff, self.macho.dataModel);
    _cryptsize = MKSwapLValue32(lc.cryptsize, self.macho.dataModel);
    _cryptid = MKSwapLValue32(lc.cryptid, self.macho.dataModel);
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    __unused struct encryption_info_command lc;
    
    MKNodeFieldBuilder *cryptoff = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(cryptoff)
        type:MKNodeFieldTypeUnsignedDoubleWord.sharedInstance
        offset:offsetof(typeof(lc), cryptoff)
        size:sizeof(lc.cryptoff)
    ];
    cryptoff.description = @"Encrypted Range Offset";
    cryptoff.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *cryptsize = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(cryptsize)
        type:MKNodeFieldTypeUnsignedDoubleWord.sharedInstance
        offset:offsetof(typeof(lc), cryptsize)
        size:sizeof(lc.cryptsize)
    ];
    cryptsize.description = @"Encrypted Range Size";
    cryptsize.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *cryptid = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(cryptid)
        type:MKNodeFieldTypeUnsignedDoubleWord.sharedInstance
        offset:offsetof(typeof(lc), cryptid)
        size:sizeof(lc.cryptid)
    ];
    cryptid.description = @"Encryption System";
    cryptid.options = MKNodeFieldOptionDisplayAsDetail;
    
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        cryptoff.build,
        cryptsize.build,
        cryptid.build
    ]];
}

@end
