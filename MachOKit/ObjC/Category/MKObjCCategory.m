//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKObjCCategory.m
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

#import "MKObjCCategory.h"
#import "MKInternal.h"
#import "MKPointer+Node.h"
#import "MKObjCProtocolList.h"
#import "MKObjCClassMethodList.h"
#import "MKObjCClassPropertyList.h"

struct objc_cat_64 {
    uint64_t name;
    uint64_t cls;
    uint64_t instanceMethods;
    uint64_t classMethods;
    uint64_t protocols;
    uint64_t instanceProperties;
    //uint64_t classProperties;
};

struct objc_cat_32 {
    uint32_t name;
    uint32_t cls;
    uint32_t instanceMethods;
    uint32_t classMethods;
    uint32_t protocols;
    uint32_t instanceProperties;
    //uint32_t classProperties;
};

//----------------------------------------------------------------------------//
@implementation MKObjCCategory

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
        
        struct objc_cat_64 var;
        if ([self.memoryMap copyBytesAtOffset:offset fromAddress:parent.nodeContextAddress into:&var length:sizeof(var) requireFull:YES error:error] < sizeof(var)) {
            MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_EINTERNAL_ERROR underlyingError:memoryMapError description:@"Could not read objc_category."];
            [self release]; return nil;
        }
        
        _name = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), name) fromParent:self targetClass:MKCString.class error:error];
        _cls = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), cls) fromParent:self error:error];
        _instanceMethods = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), instanceMethods) fromParent:self targetClass:MKObjCClassMethodList.class error:error];
        _classMethods = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), classMethods) fromParent:self targetClass:MKObjCClassMethodList.class error:error];
        _protocols = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), protocols) fromParent:self targetClass:MKObjCProtocolList.class error:error];
        _instanceProperties = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), instanceProperties) fromParent:self targetClass:MKObjCClassPropertyList.class error:error];
        
        // TODO -
        //_classProperties = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), instanceProperties) fromParent:self targetClass:MKObjCClassPropertyList.class error:error];
    }
    else if (pointerSize == 4)
    {
        NSError *memoryMapError = nil;
        
        struct objc_cat_32 var;
        if ([self.memoryMap copyBytesAtOffset:offset fromAddress:parent.nodeContextAddress into:&var length:sizeof(var) requireFull:YES error:error] < sizeof(var)) {
            MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_EINTERNAL_ERROR underlyingError:memoryMapError description:@"Could not read objc_category."];
            [self release]; return nil;
        }
        
        _name = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), name) fromParent:self targetClass:MKCString.class error:error];
        _cls = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), cls) fromParent:self error:error];
        _instanceMethods = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), instanceMethods) fromParent:self targetClass:MKObjCClassMethodList.class error:error];
        _classMethods = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), classMethods) fromParent:self targetClass:MKObjCClassMethodList.class error:error];
        _protocols = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), protocols) fromParent:self targetClass:MKObjCProtocolList.class error:error];
        _instanceProperties = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), instanceProperties) fromParent:self targetClass:MKObjCClassPropertyList.class error:error];
        
        // TODO - 
        //_classProperties = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), instanceProperties) fromParent:self targetClass:MKObjCClassPropertyList.class error:error];
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
    [_classProperties release];
    [_instanceProperties release];
    [_protocols release];
    [_classMethods release];
    [_instanceMethods release];
    [_cls release];
    [_name release];
    
    [super dealloc];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Category Values
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@synthesize name = _name;
@synthesize cls = _cls;
@synthesize instanceMethods = _instanceMethods;
@synthesize classMethods = _classMethods;
@synthesize protocols = _protocols;
@synthesize instanceProperties = _instanceProperties;
@synthesize classProperties = _classProperties;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_size_t)nodeSize
{ return (self.dataModel.pointerSize == 8) ? sizeof(struct objc_cat_64) : sizeof(struct objc_cat_32); }

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    struct objc_cat_64 cat64;
    struct objc_cat_32 cat32;
    
    size_t pointerSize = self.dataModel.pointerSize;
    
#define FIELD_TYPE(type64, type32) (pointerSize == 8 ? type64.sharedInstance : type32.sharedInstance)
#define FIELD_OFFSET(field) (pointerSize == 8 ? offsetof(typeof(cat64), field) : offsetof(typeof(cat32), field))
#define FIELD_SIZE(field) (pointerSize == 8 ? sizeof(cat64.field) : sizeof(cat32.field))
    
    MKNodeFieldBuilder *name = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(name)
        type:[MKNodeFieldTypePointer pointerWithType:FIELD_TYPE(MKNodeFieldTypeUnsignedQuadWord, MKNodeFieldTypeUnsignedDoubleWord)]
        offset:FIELD_OFFSET(name)
        size:FIELD_SIZE(name)
    ];
    name.description = @"Name";
    name.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *cls = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(cls)
        type:[MKNodeFieldTypePointer pointerWithType:FIELD_TYPE(MKNodeFieldTypeUnsignedQuadWord, MKNodeFieldTypeUnsignedDoubleWord)]
        offset:FIELD_OFFSET(cls)
        size:FIELD_SIZE(cls)
    ];
    cls.description = @"Class";
    cls.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *instanceMethods = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(instanceMethods)
        type:[MKNodeFieldTypePointer pointerWithType:FIELD_TYPE(MKNodeFieldTypeUnsignedQuadWord, MKNodeFieldTypeUnsignedDoubleWord)]
        offset:FIELD_OFFSET(instanceMethods)
        size:FIELD_SIZE(instanceMethods)
    ];
    instanceMethods.description = @"Instance Methods";
    instanceMethods.options = MKNodeFieldOptionDisplayAsChild;
    
    MKNodeFieldBuilder *classMethods = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(classMethods)
        type:[MKNodeFieldTypePointer pointerWithType:FIELD_TYPE(MKNodeFieldTypeUnsignedQuadWord, MKNodeFieldTypeUnsignedDoubleWord)]
        offset:FIELD_OFFSET(classMethods)
        size:FIELD_SIZE(classMethods)
    ];
    classMethods.description = @"Class Methods";
    classMethods.options = MKNodeFieldOptionDisplayAsChild;
    
    MKNodeFieldBuilder *protocols = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(protocols)
        type:[MKNodeFieldTypePointer pointerWithType:FIELD_TYPE(MKNodeFieldTypeUnsignedQuadWord, MKNodeFieldTypeUnsignedDoubleWord)]
        offset:FIELD_OFFSET(protocols)
        size:FIELD_SIZE(protocols)
    ];
    protocols.description = @"Protocols";
    protocols.options = MKNodeFieldOptionDisplayAsChild;
    
    MKNodeFieldBuilder *instanceProperties = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(instanceProperties)
        type:[MKNodeFieldTypePointer pointerWithType:FIELD_TYPE(MKNodeFieldTypeUnsignedQuadWord, MKNodeFieldTypeUnsignedDoubleWord)]
        offset:FIELD_OFFSET(instanceProperties)
        size:FIELD_SIZE(instanceProperties)
    ];
    instanceProperties.description = @"Instance Properties";
    instanceProperties.options = MKNodeFieldOptionDisplayAsChild;
    /*
    MKNodeFieldBuilder *classProperties = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(classProperties)
        type:[MKNodeFieldTypePointer pointerWithType:FIELD_TYPE(MKNodeFieldTypeUnsignedQuadWord, MKNodeFieldTypeUnsignedDoubleWord)]
        offset:FIELD_OFFSET(classProperties)
        size:FIELD_SIZE(classProperties)
    ];
    classProperties.description = @"Class Properties";
    classProperties.options = MKNodeFieldOptionDisplayAsDetail;
    */
#undef FIELD_SIZE
#undef FIELD_OFFSET
#undef FIELD_TYPE
    
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        name.build,
        cls.build,
        instanceMethods.build,
        classMethods.build,
        protocols.build,
        instanceProperties.build
    ]];
}

@end
