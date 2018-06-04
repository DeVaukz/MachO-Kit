//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKObjCProtocol.m
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

#import "MKObjCProtocol.h"
#import "MKInternal.h"
#import "MKPointer+Node.h"
#import "MKCString.h"
#import "MKObjCProtocolList.h"
#import "MKObjCClassMethodList.h"
#import "MKObjCClassPropertyList.h"
#import "MKObjCProtocolMethodTypesList.h"

struct objc_protocol_64 {
    uint64_t isa;
    uint64_t mangledName;
    uint64_t protocols;
    uint64_t instanceMethods;
    uint64_t classMethods;
    uint64_t optionalInstanceMethods;
    uint64_t optionalClassMethods;
    uint64_t instanceProperties;
    uint32_t size;
    uint32_t flags;
    uint64_t extendedMethodTypes;
    uint64_t demangledName;
    uint64_t classProperties;
};

struct objc_protocol_32 {
    uint32_t isa;
    uint32_t mangledName;
    uint32_t protocols;
    uint32_t instanceMethods;
    uint32_t classMethods;
    uint32_t optionalInstanceMethods;
    uint32_t optionalClassMethods;
    uint32_t instanceProperties;
    uint32_t size;
    uint32_t flags;
    uint32_t extendedMethodTypes;
    uint32_t demangledName;
    uint32_t classProperties;
};

//----------------------------------------------------------------------------//
@implementation MKObjCProtocol

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithOffset:(mk_vm_offset_t)offset fromParent:(MKBackedNode*)parent error:(NSError**)error
{
    self = [super initWithOffset:offset fromParent:parent error:error];
    if (self == nil) return nil;
    
    id<MKDataModel> dataModel = self.dataModel;
    size_t pointerSize = dataModel.pointerSize;
    
#define HAS_EXTENDED_METHOD_TYPES (var.size >= offsetof(typeof(var), extendedMethodTypes))
#define HAS_DEMANGLED_NAME (var.size >= offsetof(typeof(var), demangledName))
#define HAS_CLASS_PROPERTIES (var.size >= offsetof(typeof(var), classProperties))
    
    if (pointerSize == 8)
    {
        NSError *memoryMapError = nil;
        
        struct objc_protocol_64 var;
        if ([self.memoryMap copyBytesAtOffset:offset fromAddress:parent.nodeContextAddress into:&var length:sizeof(var) requireFull:NO error:error] < offsetof(typeof(var), extendedMethodTypes)) {
            MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_EINTERNAL_ERROR underlyingError:memoryMapError description:@"Could not read objc_protocol."];
            [self release]; return nil;
        }
        
        _isa = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), isa) fromParent:self error:error];
        _mangledName = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), mangledName) fromParent:self targetClass:MKCString.class error:error];
        _protocols = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), protocols) fromParent:self targetClass:MKObjCProtocolList.class error:error];
        _instanceMethods = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), instanceMethods) fromParent:self targetClass:MKObjCClassMethodList.class error:error];
        _classMethods = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), classMethods) fromParent:self targetClass:MKObjCClassMethodList.class error:error];
        _optionalInstanceMethods = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), optionalInstanceMethods) fromParent:self targetClass:MKObjCClassMethodList.class error:error];
        _optionalClassMethods = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), optionalClassMethods) fromParent:self targetClass:MKObjCClassMethodList.class error:error];
        _instanceProperties = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), instanceProperties) fromParent:self targetClass:MKObjCClassPropertyList.class error:error];
        _size = MKSwapLValue32(var.size, dataModel);
        _flags = MKSwapLValue32(var.flags, dataModel);
        
        if (HAS_EXTENDED_METHOD_TYPES) {
            void *weakSelf = (void*)self;
            
            MKDeferredContextProvider ctx = Block_copy(^{
                // Note that a nil value without an error is not an error, the
                // protocol may not have any of that kind of method.
                
                MKOptional<MKObjCClassMethodList*> *instanceMethods = ((MKObjCProtocol*)weakSelf)->_instanceMethods.pointee;
                if (instanceMethods.error)
                    return [MKOptional optionalWithError:[NSError mk_errorWithDomain:MKErrorDomain code:MK_ENOT_FOUND underlyingError:instanceMethods.error description:@"Could not retrieve the instance method count."]];
                
                MKOptional<MKObjCClassMethodList*> *classMethods = ((MKObjCProtocol*)weakSelf)->_classMethods.pointee;
                if (classMethods.error)
                    return [MKOptional optionalWithError:[NSError mk_errorWithDomain:MKErrorDomain code:MK_ENOT_FOUND underlyingError:classMethods.error description:@"Could not retrieve the class method count."]];
                
                MKOptional<MKObjCClassMethodList*> *optionalInstanceMethods = ((MKObjCProtocol*)weakSelf)->_optionalInstanceMethods.pointee;
                if (optionalInstanceMethods.error)
                    return [MKOptional optionalWithError:[NSError mk_errorWithDomain:MKErrorDomain code:MK_ENOT_FOUND underlyingError:optionalInstanceMethods.error description:@"Could not retrieve the optional instance method count."]];
                
                MKOptional<MKObjCClassMethodList*> *optionalClassMethods = ((MKObjCProtocol*)weakSelf)->_optionalClassMethods.pointee;
                if (optionalClassMethods.error)
                    return [MKOptional optionalWithError:[NSError mk_errorWithDomain:MKErrorDomain code:MK_ENOT_FOUND underlyingError:optionalClassMethods.error description:@"Could not retrieve the optional class method count."]];
                
                return [MKOptional optionalWithValue:@{
                    @"ExtendedTypeInfoCount": @(instanceMethods.value.count +
                                                classMethods.value.count +
                                                optionalInstanceMethods.value.count +
                                                optionalClassMethods.value.count)
                }];
            });
            
            _extendedMethodTypes = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), extendedMethodTypes) fromParent:self context:@{
                MKInitializationContextTargetClass: MKObjCProtocolMethodTypesList.class,
                MKInitializationContextDeferredProvider: ctx
            } error:error];
            
            Block_release(ctx);
        }
        
        if (HAS_DEMANGLED_NAME) {
            _demangledName = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), demangledName) fromParent:self targetClass:MKCString.class error:error];
        }
        
        if (HAS_CLASS_PROPERTIES) {
            _classProperties = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), classProperties) fromParent:self targetClass:MKObjCClassPropertyList.class error:error];
        }
    }
    else if (pointerSize == 4)
    {
        NSError *memoryMapError = nil;
        
        struct objc_protocol_32 var;
        if ([self.memoryMap copyBytesAtOffset:offset fromAddress:parent.nodeContextAddress into:&var length:sizeof(var) requireFull:NO error:error] < offsetof(typeof(var), extendedMethodTypes)) {
            MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_EINTERNAL_ERROR underlyingError:memoryMapError description:@"Could not read objc_protocol."];
            [self release]; return nil;
        }
        
        _isa = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), isa) fromParent:self error:error];
        _mangledName = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), mangledName) fromParent:self targetClass:MKCString.class error:error];
        _protocols = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), protocols) fromParent:self targetClass:MKObjCProtocolList.class error:error];
        _instanceMethods = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), instanceMethods) fromParent:self targetClass:MKObjCClassMethodList.class error:error];
        _classMethods = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), classMethods) fromParent:self targetClass:MKObjCClassMethodList.class error:error];
        _optionalInstanceMethods = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), optionalInstanceMethods) fromParent:self targetClass:MKObjCClassMethodList.class error:error];
        _optionalClassMethods = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), optionalClassMethods) fromParent:self targetClass:MKObjCClassMethodList.class error:error];
        _instanceProperties = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), instanceProperties) fromParent:self targetClass:MKObjCClassPropertyList.class error:error];
        _size = MKSwapLValue32(var.size, dataModel);
        _flags = MKSwapLValue32(var.flags, dataModel);
        
        if (HAS_EXTENDED_METHOD_TYPES) {
            void *weakSelf = (void*)self;
            
            MKDeferredContextProvider ctx = Block_copy(^{
                // Note that a nil value without an error is not an error, the
                // protocol may not have any of that kind of method.
                
                MKOptional<MKObjCClassMethodList*> *instanceMethods = ((MKObjCProtocol*)weakSelf)->_instanceMethods.pointee;
                if (instanceMethods.error)
                    return [MKOptional optionalWithError:[NSError mk_errorWithDomain:MKErrorDomain code:MK_ENOT_FOUND underlyingError:instanceMethods.error description:@"Could not retrieve the instance method count."]];
                
                MKOptional<MKObjCClassMethodList*> *classMethods = ((MKObjCProtocol*)weakSelf)->_classMethods.pointee;
                if (classMethods.error)
                    return [MKOptional optionalWithError:[NSError mk_errorWithDomain:MKErrorDomain code:MK_ENOT_FOUND underlyingError:classMethods.error description:@"Could not retrieve the class method count."]];
                
                MKOptional<MKObjCClassMethodList*> *optionalInstanceMethods = ((MKObjCProtocol*)weakSelf)->_optionalInstanceMethods.pointee;
                if (optionalInstanceMethods.error)
                    return [MKOptional optionalWithError:[NSError mk_errorWithDomain:MKErrorDomain code:MK_ENOT_FOUND underlyingError:optionalInstanceMethods.error description:@"Could not retrieve the optional instance method count."]];
                
                MKOptional<MKObjCClassMethodList*> *optionalClassMethods = ((MKObjCProtocol*)weakSelf)->_optionalClassMethods.pointee;
                if (optionalClassMethods.error)
                    return [MKOptional optionalWithError:[NSError mk_errorWithDomain:MKErrorDomain code:MK_ENOT_FOUND underlyingError:optionalClassMethods.error description:@"Could not retrieve the optional class method count."]];
                
                return [MKOptional optionalWithValue:@{
                    @"ExtendedTypeInfoCount": @(instanceMethods.value.count +
                                                classMethods.value.count +
                                                optionalInstanceMethods.value.count +
                                                optionalClassMethods.value.count)
                    }];
            });
            
            _extendedMethodTypes = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), extendedMethodTypes) fromParent:self context:@{
                MKInitializationContextTargetClass: MKObjCProtocolMethodTypesList.class,
                MKInitializationContextDeferredProvider: ctx
            } error:error];
            
            Block_release(ctx);
        }
        
        if (HAS_DEMANGLED_NAME) {
            _demangledName = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), demangledName) fromParent:self targetClass:MKCString.class error:error];
        }
        
        if (HAS_CLASS_PROPERTIES) {
            _classProperties = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), classProperties) fromParent:self targetClass:MKObjCClassPropertyList.class error:error];
        }
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
    [_demangledName release];
    [_extendedMethodTypes release];
    [_instanceProperties release];
    [_optionalClassMethods release];
    [_optionalInstanceMethods release];
    [_classMethods release];
    [_instanceMethods release];
    [_protocols release];
    [_mangledName release];
    [_isa release];
    
    [super dealloc];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Protocol Values
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@synthesize isa = _isa;
@synthesize mangledName = _mangledName;
@synthesize protocols = _protocols;
@synthesize instanceMethods = _instanceMethods;
@synthesize classMethods = _classMethods;
@synthesize optionalInstanceMethods = _optionalInstanceMethods;
@synthesize optionalClassMethods = _optionalClassMethods;
@synthesize instanceProperties = _instanceProperties;
@synthesize size = _size;
@synthesize flags = _flags;
@synthesize extendedMethodTypes = _extendedMethodTypes;
@synthesize demangledName = _demangledName;
@synthesize classProperties = _classProperties;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_size_t)nodeSize
{ return _size; }

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    struct objc_protocol_64 proto64;
    struct objc_protocol_32 proto32;
    
    size_t pointerSize = self.dataModel.pointerSize;
    
#define FIELD_TYPE(type64, type32) (pointerSize == 8 ? type64.sharedInstance : type32.sharedInstance)
#define FIELD_OFFSET(field) (pointerSize == 8 ? offsetof(typeof(proto64), field) : offsetof(typeof(proto32), field))
#define FIELD_SIZE(field) (pointerSize == 8 ? sizeof(proto64.field) : sizeof(proto32.field))
    
    MKNodeFieldBuilder *isa = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(isa)
        type:[MKNodeFieldTypePointer pointerWithType:FIELD_TYPE(MKNodeFieldTypeUnsignedQuadWord, MKNodeFieldTypeUnsignedDoubleWord)]
        offset:FIELD_OFFSET(isa)
        size:FIELD_SIZE(isa)
    ];
    isa.description = @"ISA";
    isa.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *mangledName = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(mangledName)
        type:[MKNodeFieldTypePointer pointerWithType:FIELD_TYPE(MKNodeFieldTypeUnsignedQuadWord, MKNodeFieldTypeUnsignedDoubleWord)]
        offset:FIELD_OFFSET(mangledName)
        size:FIELD_SIZE(mangledName)
    ];
    mangledName.description = @"Mangled Name";
    mangledName.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *protocols = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(protocols)
        type:[MKNodeFieldTypePointer pointerWithType:FIELD_TYPE(MKNodeFieldTypeUnsignedQuadWord, MKNodeFieldTypeUnsignedDoubleWord)]
        offset:FIELD_OFFSET(protocols)
        size:FIELD_SIZE(protocols)
    ];
    protocols.description = @"Protocols";
    protocols.options = MKNodeFieldOptionDisplayAsChild;
    
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
    
    MKNodeFieldBuilder *optionalInstanceMethods = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(optionalInstanceMethods)
        type:[MKNodeFieldTypePointer pointerWithType:FIELD_TYPE(MKNodeFieldTypeUnsignedQuadWord, MKNodeFieldTypeUnsignedDoubleWord)]
        offset:FIELD_OFFSET(optionalInstanceMethods)
        size:FIELD_SIZE(optionalInstanceMethods)
    ];
    optionalInstanceMethods.description = @"Optional Instance Methods";
    optionalInstanceMethods.options = MKNodeFieldOptionDisplayAsChild;
    
    MKNodeFieldBuilder *optionalClassMethods = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(optionalClassMethods)
        type:[MKNodeFieldTypePointer pointerWithType:FIELD_TYPE(MKNodeFieldTypeUnsignedQuadWord, MKNodeFieldTypeUnsignedDoubleWord)]
        offset:FIELD_OFFSET(optionalClassMethods)
        size:FIELD_SIZE(optionalClassMethods)
    ];
    optionalClassMethods.description = @"Optional Class Methods";
    optionalClassMethods.options = MKNodeFieldOptionDisplayAsChild;
    
    MKNodeFieldBuilder *instanceProperties = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(instanceProperties)
        type:[MKNodeFieldTypePointer pointerWithType:FIELD_TYPE(MKNodeFieldTypeUnsignedQuadWord, MKNodeFieldTypeUnsignedDoubleWord)]
        offset:FIELD_OFFSET(instanceProperties)
        size:FIELD_SIZE(instanceProperties)
    ];
    instanceProperties.description = @"Instance Properties";
    instanceProperties.options = MKNodeFieldOptionDisplayAsChild;
    
    MKNodeFieldBuilder *size = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(size)
        type:MKNodeFieldTypeUnsignedDoubleWord.sharedInstance
        offset:FIELD_OFFSET(size)
        size:FIELD_SIZE(size)
    ];
    size.description = @"Size";
    size.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *flags = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(flags)
        type:MKNodeFieldTypeUnsignedDoubleWord.sharedInstance /* TODO */
        offset:FIELD_OFFSET(flags)
        size:FIELD_SIZE(flags)
    ];
    flags.description = @"Flags";
    flags.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *extendedMethodTypes = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(extendedMethodTypes)
        type:[MKNodeFieldTypePointer pointerWithType:FIELD_TYPE(MKNodeFieldTypeUnsignedQuadWord, MKNodeFieldTypeUnsignedDoubleWord)]
        offset:FIELD_OFFSET(extendedMethodTypes)
        size:FIELD_SIZE(extendedMethodTypes)
    ];
    extendedMethodTypes.description = @"Extended Method Types";
    extendedMethodTypes.options = MKNodeFieldOptionDisplayAsChild;
    
    MKNodeFieldBuilder *demangledName = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(demangledName)
        type:[MKNodeFieldTypePointer pointerWithType:FIELD_TYPE(MKNodeFieldTypeUnsignedQuadWord, MKNodeFieldTypeUnsignedDoubleWord)]
        offset:FIELD_OFFSET(demangledName)
        size:FIELD_SIZE(demangledName)
    ];
    demangledName.description = @"Demangled Name";
    demangledName.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *classProperties = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(classProperties)
        type:[MKNodeFieldTypePointer pointerWithType:FIELD_TYPE(MKNodeFieldTypeUnsignedQuadWord, MKNodeFieldTypeUnsignedDoubleWord)]
        offset:FIELD_OFFSET(classProperties)
        size:FIELD_SIZE(classProperties)
    ];
    classProperties.description = @"Class Properties";
    classProperties.options = MKNodeFieldOptionDisplayAsChild;
    
#undef FIELD_SIZE
#undef FIELD_OFFSET
#undef FIELD_TYPE
    
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        isa.build,
        mangledName.build,
        protocols.build,
        instanceMethods.build,
        classMethods.build,
        optionalInstanceMethods.build,
        optionalClassMethods.build,
        instanceProperties.build,
        size.build,
        flags.build,
        extendedMethodTypes.build,
        demangledName.build,
        classProperties.build
    ]];
}

@end
