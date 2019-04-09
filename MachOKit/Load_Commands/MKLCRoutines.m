//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKLCRoutines.m
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

#import "MKLCRoutines.h"
#import "MKInternal.h"
#import "MKMachO.h"

//----------------------------------------------------------------------------//
@implementation MKLCRoutines

@synthesize init_address = _init_address;
@synthesize init_module = _init_module;
@synthesize reserved1 = _reserved1;
@synthesize reserved2 = _reserved2;
@synthesize reserved3 = _reserved3;
@synthesize reserved4 = _reserved4;
@synthesize reserved5 = _reserved5;
@synthesize reserved6 = _reserved6;

//|++++++++++++++++++++++++++++++++++++|//
+ (uint32_t)ID
{ return LC_ROUTINES; }

//|++++++++++++++++++++++++++++++++++++|//
+ (uint32_t)canInstantiateWithLoadCommandID:(uint32_t)commandID
{
    if (self != MKLCRoutines.class)
        return 0;
    
    return commandID == [self ID] ? 10 : 0;
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithOffset:(mk_vm_offset_t)offset fromParent:(MKBackedNode*)parent error:(NSError**)error
{
    self = [super initWithOffset:offset fromParent:parent error:error];
    if (self == nil) return nil;
    
    struct routines_command lc;
    if ([self.memoryMap copyBytesAtOffset:offset fromAddress:parent.nodeContextAddress into:&lc length:sizeof(lc) requireFull:YES error:error] < sizeof(lc))
    { [self release]; return nil; }
    
    _init_address = MKSwapLValue32(lc.init_address, self.macho.dataModel);
    _init_module = MKSwapLValue32(lc.init_module, self.macho.dataModel);
    _reserved1 = MKSwapLValue32(lc.reserved1, self.macho.dataModel);
    _reserved2 = MKSwapLValue32(lc.reserved2, self.macho.dataModel);
    _reserved3 = MKSwapLValue32(lc.reserved3, self.macho.dataModel);
    _reserved4 = MKSwapLValue32(lc.reserved4, self.macho.dataModel);
    _reserved5 = MKSwapLValue32(lc.reserved5, self.macho.dataModel);
    _reserved6 = MKSwapLValue32(lc.reserved6, self.macho.dataModel);
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    __unused struct routines_command lc;
    
    MKNodeFieldBuilder *init_address = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(init_address)
        type:MKNodeFieldTypeUnsignedDoubleWord.sharedInstance
        offset:offsetof(typeof(lc), init_address)
        size:sizeof(lc.init_address)
    ];
    init_address.description = @"Initialization Routine";
    init_address.formatter = [MKHexNumberFormatter hexNumberFormatterWithDigits:(size_t)(sizeof(lc.init_address)*2)];
    init_address.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *init_module = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(init_module)
        type:MKNodeFieldTypeUnsignedDoubleWord.sharedInstance
        offset:offsetof(typeof(lc), init_module)
        size:sizeof(lc.init_module)
    ];
    init_module.description = @"Initialization Module Index";
    init_module.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *reserved1 = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(reserved1)
        type:MKNodeFieldTypeUnsignedDoubleWord.sharedInstance
        offset:offsetof(typeof(lc), reserved1)
        size:sizeof(lc.reserved1)
    ];
    reserved1.description = @"Reserved1";
    reserved1.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *reserved2 = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(reserved2)
        type:MKNodeFieldTypeUnsignedDoubleWord.sharedInstance
        offset:offsetof(typeof(lc), reserved2)
        size:sizeof(lc.reserved2)
    ];
    reserved2.description = @"Reserved2";
    reserved2.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *reserved3 = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(reserved3)
        type:MKNodeFieldTypeUnsignedDoubleWord.sharedInstance
        offset:offsetof(typeof(lc), reserved3)
        size:sizeof(lc.reserved3)
    ];
    reserved3.description = @"Reserved3";
    reserved3.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *reserved4 = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(reserved4)
        type:MKNodeFieldTypeUnsignedDoubleWord.sharedInstance
        offset:offsetof(typeof(lc), reserved4)
        size:sizeof(lc.reserved4)
    ];
    reserved4.description = @"Reserved4";
    reserved4.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *reserved5 = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(reserved5)
        type:MKNodeFieldTypeUnsignedDoubleWord.sharedInstance
        offset:offsetof(typeof(lc), reserved5)
        size:sizeof(lc.reserved5)
    ];
    reserved5.description = @"Reserved5";
    reserved5.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *reserved6 = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(reserved6)
        type:MKNodeFieldTypeUnsignedDoubleWord.sharedInstance
        offset:offsetof(typeof(lc), reserved6)
        size:sizeof(lc.reserved6)
    ];
    reserved6.description = @"Reserved6";
    reserved6.options = MKNodeFieldOptionDisplayAsDetail;
    
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        init_address.build,
        init_module.build,
        reserved1.build,
        reserved2.build,
        reserved3.build,
        reserved4.build,
        reserved5.build,
        reserved6.build
    ]];
}

@end
