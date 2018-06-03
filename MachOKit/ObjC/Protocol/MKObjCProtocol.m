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
#import "NSError+MK.h"
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
    
    NSError *localError = nil;
    
    id<MKDataModel> dataModel = self.dataModel;
    NSAssert(dataModel != nil, @"Parent node must have a data model.");
    
#define HAS_EXTENDED_METHOD_TYPES (var.size >= offsetof(typeof(var), extendedMethodTypes))
#define HAS_DEMANGLED_NAME (var.size >= offsetof(typeof(var), demangledName))
#define HAS_CLASS_PROPERTIES (var.size >= offsetof(typeof(var), classProperties))
    
    if (dataModel.pointerSize == 8)
    {
        struct objc_protocol_64 var;
        if ([self.memoryMap copyBytesAtOffset:offset fromAddress:parent.nodeContextAddress into:&var length:sizeof(var) requireFull:NO error:error] < offsetof(typeof(var), extendedMethodTypes))
        { [self release]; return nil; }
        
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
            
            MKDeferredContextProvider ctx = ^{
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
            };
            
            _extendedMethodTypes = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), extendedMethodTypes) fromParent:self context:@{
                MKInitializationContextTargetClass: MKObjCProtocolMethodTypesList.class,
                MKInitializationContextDeferredProvider: ctx
            } error:error];
        }
        
        if (HAS_DEMANGLED_NAME) {
            _demangledName = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), demangledName) fromParent:self targetClass:MKCString.class error:error];
        }
        
        if (HAS_CLASS_PROPERTIES) {
            _classProperties = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), classProperties) fromParent:self targetClass:MKObjCClassPropertyList.class error:error];
        }
    }
    else if (dataModel.pointerSize == 4)
    {
        struct objc_protocol_32 var;
        if ([self.memoryMap copyBytesAtOffset:offset fromAddress:parent.nodeContextAddress into:&var length:sizeof(var) requireFull:NO error:error] < offsetof(typeof(var), extendedMethodTypes))
        { [self release]; return nil; }
        
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
            
            MKDeferredContextProvider ctx = ^{
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
            };
            
            _extendedMethodTypes = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), extendedMethodTypes) fromParent:self context:@{
                MKInitializationContextTargetClass: MKObjCProtocolMethodTypesList.class,
                MKInitializationContextDeferredProvider: ctx
            } error:error];
        }
        
        if (HAS_DEMANGLED_NAME) {
            _demangledName = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), demangledName) fromParent:self targetClass:MKCString.class error:error];
        }
        
        if (HAS_CLASS_PROPERTIES) {
            _classProperties = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), classProperties) fromParent:self targetClass:MKObjCClassPropertyList.class error:error];
        }
    }
    else
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Unsupported pointer size." userInfo:nil];
    
    if (localError) {
        MK_ERROR_OUT = localError;
        [self release]; return nil;
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
#pragma mark -  Values
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
    NSArray *fields;
    
    if (self.dataModel.pointerSize == 8) {
        struct objc_protocol_64 var;
        fields = @[
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(isa) description:@"ISA" offset:offsetof(typeof(var), isa) size:sizeof(var.isa)],
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(mangledName) description:@"Mangled Name" offset:offsetof(typeof(var), mangledName) size:sizeof(var.mangledName)],
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(protocols) description:@"Protocols" offset:offsetof(typeof(var), protocols) size:sizeof(var.protocols)],
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(instanceMethods) description:@"Instance Methods" offset:offsetof(typeof(var), instanceMethods) size:sizeof(var.instanceMethods)],
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(classMethods) description:@"Class Methods" offset:offsetof(typeof(var), classMethods) size:sizeof(var.classMethods)],
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(optionalInstanceMethods) description:@"Optional Instance Methods" offset:offsetof(typeof(var), optionalInstanceMethods) size:sizeof(var.optionalInstanceMethods)],
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(optionalClassMethods) description:@"Optional Class Methods" offset:offsetof(typeof(var), optionalClassMethods) size:sizeof(var.optionalClassMethods)],
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(instanceProperties) description:@"Instance Properties" offset:offsetof(typeof(var), instanceProperties) size:sizeof(var.instanceProperties)],
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(size) description:@"Size" offset:offsetof(typeof(var), size) size:sizeof(var.size)],
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(flags) description:@"Flags" offset:offsetof(typeof(var), flags) size:sizeof(var.flags)],
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(extendedMethodTypes) description:@"Extended Types" offset:offsetof(typeof(var), extendedMethodTypes) size:sizeof(var.extendedMethodTypes)],
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(demangledName) description:@"Demangled Name" offset:offsetof(typeof(var), demangledName) size:sizeof(var.demangledName)],
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(classProperties) description:@"Class Properties" offset:offsetof(typeof(var), classProperties) size:sizeof(var.classProperties)],
        ];
    } else {
        struct objc_protocol_32 var;
        fields = @[
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(isa) description:@"ISA" offset:offsetof(typeof(var), isa) size:sizeof(var.isa)],
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(mangledName) description:@"Mangled Name" offset:offsetof(typeof(var), mangledName) size:sizeof(var.mangledName)],
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(protocols) description:@"Protocols" offset:offsetof(typeof(var), protocols) size:sizeof(var.protocols)],
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(instanceMethods) description:@"Instance Methods" offset:offsetof(typeof(var), instanceMethods) size:sizeof(var.instanceMethods)],
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(classMethods) description:@"Class Methods" offset:offsetof(typeof(var), classMethods) size:sizeof(var.classMethods)],
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(optionalInstanceMethods) description:@"Optional Instance Methods" offset:offsetof(typeof(var), optionalInstanceMethods) size:sizeof(var.optionalInstanceMethods)],
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(optionalClassMethods) description:@"Optional Class Methods" offset:offsetof(typeof(var), optionalClassMethods) size:sizeof(var.optionalClassMethods)],
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(instanceProperties) description:@"Instance Properties" offset:offsetof(typeof(var), instanceProperties) size:sizeof(var.instanceProperties)],
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(size) description:@"Size" offset:offsetof(typeof(var), size) size:sizeof(var.size)],
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(flags) description:@"Flags" offset:offsetof(typeof(var), flags) size:sizeof(var.flags)],
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(extendedMethodTypes) description:@"Extended Types" offset:offsetof(typeof(var), extendedMethodTypes) size:sizeof(var.extendedMethodTypes)],
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(demangledName) description:@"Demangled Name" offset:offsetof(typeof(var), demangledName) size:sizeof(var.demangledName)],
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(classProperties) description:@"Class Properties" offset:offsetof(typeof(var), classProperties) size:sizeof(var.classProperties)],
        ];
    }
    
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:fields];
}

@end
