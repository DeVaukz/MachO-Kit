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
#import "MKInternal.h"
#import "MKMachO.h"

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
+ (uint32_t)canInstantiateWithLoadCommandID:(uint32_t)commandID
{
    if (self != MKLCDyldInfo.class)
        return 0;
    
    return commandID == [self ID] ? 10 : 0;
}

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
    __unused struct dyld_info_command lc;
    
    MKNodeFieldBuilder *rebase_off = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(rebase_off)
        type:MKNodeFieldTypeUnsignedDoubleWord.sharedInstance
        offset:offsetof(typeof(lc), rebase_off)
        size:sizeof(lc.rebase_off)
    ];
    rebase_off.description = @"Rebase Info Offset";
    rebase_off.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *rebase_size = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(rebase_size)
        type:MKNodeFieldTypeUnsignedDoubleWord.sharedInstance
        offset:offsetof(typeof(lc), rebase_size)
        size:sizeof(lc.rebase_size)
    ];
    rebase_size.description = @"Rebase Info Size";
    rebase_size.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *bind_off = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(bind_off)
        type:MKNodeFieldTypeUnsignedDoubleWord.sharedInstance
        offset:offsetof(typeof(lc), bind_off)
        size:sizeof(lc.bind_off)
    ];
    bind_off.description = @"Binding Info Offset";
    bind_off.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *bind_size = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(bind_size)
        type:MKNodeFieldTypeUnsignedDoubleWord.sharedInstance
        offset:offsetof(typeof(lc), bind_size)
        size:sizeof(lc.bind_size)
    ];
    bind_size.description = @"Binding Info Size";
    bind_size.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *weak_bind_off = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(weak_bind_off)
        type:MKNodeFieldTypeUnsignedDoubleWord.sharedInstance
        offset:offsetof(typeof(lc), weak_bind_off)
        size:sizeof(lc.weak_bind_off)
    ];
    weak_bind_off.description = @"Weak Binding Info Offset";
    weak_bind_off.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *weak_bind_size = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(weak_bind_size)
        type:MKNodeFieldTypeUnsignedDoubleWord.sharedInstance
        offset:offsetof(typeof(lc), weak_bind_size)
        size:sizeof(lc.weak_bind_size)
    ];
    weak_bind_size.description = @"Weak Binding Info Size";
    weak_bind_size.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *lazy_bind_off = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(lazy_bind_off)
        type:MKNodeFieldTypeUnsignedDoubleWord.sharedInstance
        offset:offsetof(typeof(lc), lazy_bind_off)
        size:sizeof(lc.lazy_bind_off)
    ];
    lazy_bind_off.description = @"Lazy Binding Info Offset";
    lazy_bind_off.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *lazy_bind_size = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(lazy_bind_size)
        type:MKNodeFieldTypeUnsignedDoubleWord.sharedInstance
        offset:offsetof(typeof(lc), lazy_bind_size)
        size:sizeof(lc.lazy_bind_size)
    ];
    lazy_bind_size.description = @"Lazy Binding Info Size";
    lazy_bind_size.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *export_off = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(export_off)
        type:MKNodeFieldTypeUnsignedDoubleWord.sharedInstance
        offset:offsetof(typeof(lc), export_off)
        size:sizeof(lc.export_off)
    ];
    export_off.description = @"Export Info Offset";
    export_off.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *export_size = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(export_size)
        type:MKNodeFieldTypeUnsignedDoubleWord.sharedInstance
        offset:offsetof(typeof(lc), export_size)
        size:sizeof(lc.export_size)
    ];
    export_size.description = @"Export Info Size";
    export_size.options = MKNodeFieldOptionDisplayAsDetail;
    
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        rebase_off.build,
        rebase_size.build,
        bind_off.build,
        bind_size.build,
        weak_bind_off.build,
        weak_bind_size.build,
        lazy_bind_off.build,
        lazy_bind_size.build,
        export_off.build,
        export_size.build,
    ]];
}

@end
