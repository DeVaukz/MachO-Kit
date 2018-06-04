//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKObjCClassData.m
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

#import "MKObjCClassData.h"
#import "MKInternal.h"
#import "MKPointer+Node.h"
#import "MKCString.h"
#import "MKObjCProtocolList.h"
#import "MKObjCClassMethodList.h"
#import "MKObjCClassPropertyList.h"
#import "MKObjCClassIVarList.h"

struct objc_class_data_64 {
    uint32_t flags;
    uint32_t instanceStart;
    uint32_t instanceSize;
    uint32_t reserved;
    uint64_t ivarLayout;
    uint64_t name;
    uint64_t baseMethodList;
    uint64_t baseProtocols;
    uint64_t ivars;
    uint64_t weakIVarLayout;
    uint64_t baseProperties;
};

struct objc_class_data_32 {
    uint32_t flags;
    uint32_t instanceStart;
    uint32_t instanceSize;
    uint32_t ivarLayout;
    uint32_t name;
    uint32_t baseMethodList;
    uint32_t baseProtocols;
    uint32_t ivars;
    uint32_t weakIVarLayout;
    uint32_t baseProperties;
};

//----------------------------------------------------------------------------//
@implementation MKObjCClassData

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithOffset:(mk_vm_offset_t)offset fromParent:(MKBackedNode*)parent error:(NSError**)error
{
    self = [super initWithOffset:offset fromParent:parent error:error];
    if (self == nil) return nil;
    
    id<MKDataModel> dataModel = self.dataModel;
    size_t pointerSize = dataModel.pointerSize;
    
    if (pointerSize == 8)
    {
        NSError *memoryMapError = nil;
        
        struct objc_class_data_64 var;
        if ([self.memoryMap copyBytesAtOffset:0 fromAddress:self.nodeContextAddress into:&var length:sizeof(var) requireFull:YES error:&memoryMapError] < sizeof(var)) {
            MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_EINTERNAL_ERROR underlyingError:memoryMapError description:@"Could not read objc class data."];
            [self release]; return nil;
        }
        
        _name = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), name) fromParent:self targetClass:MKCString.class error:error];
        _methods = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), baseMethodList) fromParent:self targetClass:MKObjCClassMethodList.class error:error];
        _protocols = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), baseProtocols) fromParent:self targetClass:MKObjCProtocolList.class error:error];
        _properties = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), baseProperties) fromParent:self targetClass:MKObjCClassPropertyList.class error:error];
        _ivars = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), ivars) fromParent:self targetClass:MKObjCClassIVarList.class error:error];
        _ivarLayout = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), ivarLayout) fromParent:self targetClass:MKCString.class error:error];
        _weakIVarLayout = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), weakIVarLayout) fromParent:self targetClass:MKCString.class error:error];
        _flags = MKSwapLValue32(var.flags, dataModel);
        _instanceStart = MKSwapLValue32(var.instanceStart, dataModel);
        _instanceSize = MKSwapLValue32(var.instanceSize, dataModel);
        _reserved = MKSwapLValue32(var.reserved, dataModel);
    }
    else if (pointerSize == 4)
    {
        NSError *memoryMapError = nil;
        
        struct objc_class_data_32 var;
        if ([self.memoryMap copyBytesAtOffset:0 fromAddress:self.nodeContextAddress into:&var length:sizeof(var) requireFull:YES error:&memoryMapError] < sizeof(var)) {
            MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_EINTERNAL_ERROR underlyingError:memoryMapError description:@"Could not read objc class data."];
            [self release]; return nil;
        }
        
        _name = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), name) fromParent:self targetClass:MKCString.class error:error];
        _methods = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), baseMethodList) fromParent:self targetClass:MKObjCClassMethodList.class error:error];
        _protocols = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), baseProtocols) fromParent:self targetClass:MKObjCProtocolList.class error:error];
        _properties = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), baseProperties) fromParent:self targetClass:MKObjCClassPropertyList.class error:error];
        _ivars = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), ivars) fromParent:self targetClass:MKObjCClassIVarList.class error:error];
        _ivarLayout = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), ivarLayout) fromParent:self targetClass:MKCString.class error:error];
        _weakIVarLayout = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), weakIVarLayout) fromParent:self targetClass:MKCString.class error:error];
        _flags = MKSwapLValue32(var.flags, dataModel);
        _instanceStart = MKSwapLValue32(var.instanceStart, dataModel);
        _instanceSize = MKSwapLValue32(var.instanceSize, dataModel);
    }
    else
    {
        NSString *reason = [NSString stringWithFormat:@"Unsupported pointer size [%zu].", pointerSize];
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:nil];
    }
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (void)dealloc
{
    [_weakIVarLayout release];
    [_ivarLayout release];
    [_ivars release];
    [_properties release];
    [_protocols release];
    [_methods release];
    [_name release];
    
    [super dealloc];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Class Data Values
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@synthesize flags = _flags;
@synthesize instanceStart = _instanceStart;
@synthesize instanceSize = _instanceSize;
@synthesize reserved = _reserved;
@synthesize name = _name;
@synthesize methods = _methods;
@synthesize protocols = _protocols;
@synthesize properties = _properties;
@synthesize ivars = _ivars;
@synthesize ivarLayout = _ivarLayout;
@synthesize weakIVarLayout = _weakIVarLayout;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_size_t)nodeSize
{ return (self.dataModel.pointerSize == 8) ? sizeof(struct objc_class_data_64) : sizeof(struct objc_class_data_32); }

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    struct objc_class_data_64 data64;
    struct objc_class_data_32 data32;
    
    size_t pointerSize = self.dataModel.pointerSize;
   
#define FIELD_TYPE(type64, type32) (pointerSize == 8 ? type64.sharedInstance : type32.sharedInstance)
#define FIELD_OFFSET(field) (pointerSize == 8 ? offsetof(typeof(data64), field) : offsetof(typeof(data32), field))
#define FIELD_SIZE(field) (pointerSize == 8 ? sizeof(data64.field) : sizeof(data32.field))

    MKNodeFieldBuilder *flags = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(flags)
        type:MKNodeFieldObjCClassFlagsType.sharedInstance
        offset:FIELD_OFFSET(flags)
        size:FIELD_SIZE(flags)
    ];
    flags.description = @"Flags";
    flags.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *instanceStart = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(instanceStart)
        type:MKNodeFieldTypeUnsignedDoubleWord.sharedInstance
        offset:FIELD_OFFSET(instanceStart)
        size:FIELD_SIZE(instanceStart)
    ];
    instanceStart.description = @"Instance Start";
    instanceStart.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *instanceSize = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(instanceSize)
        type:MKNodeFieldTypeUnsignedDoubleWord.sharedInstance
        offset:FIELD_OFFSET(instanceSize)
        size:FIELD_SIZE(instanceSize)
    ];
    instanceSize.description = @"Instance Size";
    instanceSize.options = MKNodeFieldOptionDisplayAsDetail;
    
    /* MKNodeFieldBuilder *reserved = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(reserved)
        type:MKNodeFieldTypeUnsignedDoubleWord.sharedInstance
        offset:FIELD_OFFSET(reserved)
        size:FIELD_SIZE(reserved)
    ];
    reserved.description = @"Reserved";
    reserved.options = MKNodeFieldOptionDisplayAsDetail; */
    
    MKNodeFieldBuilder *name = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(name)
        type:[MKNodeFieldTypePointer pointerWithType:FIELD_TYPE(MKNodeFieldTypeUnsignedQuadWord, MKNodeFieldTypeUnsignedDoubleWord)]
        offset:FIELD_OFFSET(name)
        size:FIELD_SIZE(name)
    ];
    name.description = @"Name";
    name.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *methods = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(methods)
        type:[MKNodeFieldTypePointer pointerWithType:FIELD_TYPE(MKNodeFieldTypeUnsignedQuadWord, MKNodeFieldTypeUnsignedDoubleWord)]
        offset:FIELD_OFFSET(baseMethodList)
        size:FIELD_SIZE(baseMethodList)
    ];
    methods.description = @"Methods";
    methods.options = MKNodeFieldOptionDisplayAsChild;
    
    MKNodeFieldBuilder *protocols = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(protocols)
        type:[MKNodeFieldTypePointer pointerWithType:FIELD_TYPE(MKNodeFieldTypeUnsignedQuadWord, MKNodeFieldTypeUnsignedDoubleWord)]
        offset:FIELD_OFFSET(baseProtocols)
        size:FIELD_SIZE(baseProtocols)
    ];
    protocols.description = @"Protocols";
    protocols.options = MKNodeFieldOptionDisplayAsChild;
    
    MKNodeFieldBuilder *properties = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(properties)
        type:[MKNodeFieldTypePointer pointerWithType:FIELD_TYPE(MKNodeFieldTypeUnsignedQuadWord, MKNodeFieldTypeUnsignedDoubleWord)]
        offset:FIELD_OFFSET(baseProperties)
        size:FIELD_SIZE(baseProperties)
    ];
    properties.description = @"Properties";
    properties.options = MKNodeFieldOptionDisplayAsChild;
    
    MKNodeFieldBuilder *ivars = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(ivars)
        type:[MKNodeFieldTypePointer pointerWithType:FIELD_TYPE(MKNodeFieldTypeUnsignedQuadWord, MKNodeFieldTypeUnsignedDoubleWord)]
        offset:FIELD_OFFSET(ivars)
        size:FIELD_SIZE(ivars)
    ];
    ivars.description = @"Instance Variables";
    ivars.options = MKNodeFieldOptionDisplayAsChild;
    
    MKNodeFieldBuilder *ivarLayout = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(ivarLayout)
        type:[MKNodeFieldTypePointer pointerWithType:FIELD_TYPE(MKNodeFieldTypeUnsignedQuadWord, MKNodeFieldTypeUnsignedDoubleWord)]
        offset:FIELD_OFFSET(ivarLayout)
        size:FIELD_SIZE(ivarLayout)
    ];
    ivarLayout.description = @"Instance Variable Layout";
    ivarLayout.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *weakIVarLayout = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(weakIVarLayout)
        type:[MKNodeFieldTypePointer pointerWithType:FIELD_TYPE(MKNodeFieldTypeUnsignedQuadWord, MKNodeFieldTypeUnsignedDoubleWord)]
        offset:FIELD_OFFSET(weakIVarLayout)
        size:FIELD_SIZE(weakIVarLayout)
    ];
    weakIVarLayout.description = @"Weak Instance Variable Layout";
    weakIVarLayout.options = MKNodeFieldOptionDisplayAsDetail;

#undef FIELD_SIZE
#undef FIELD_OFFSET
#undef FIELD_TYPE
    
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        flags.build,
        instanceStart.build,
        instanceSize.build,
        name.build,
        methods.build,
        protocols.build,
        properties.build,
        ivars.build,
        ivarLayout.build,
        weakIVarLayout.build
    ]];
}

@end
