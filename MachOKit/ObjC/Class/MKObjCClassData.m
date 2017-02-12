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
#import "NSError+MK.h"
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
    
    NSError *localError = nil;
    
    id<MKDataModel> dataModel = self.dataModel;
    NSAssert(dataModel != nil, @"Parent node must have a data model.");
    
    if (dataModel.pointerSize == 8)
    {
        struct objc_class_data_64 var;
        if ([self.memoryMap copyBytesAtOffset:offset fromAddress:parent.nodeContextAddress into:&var length:sizeof(var) requireFull:YES error:error] < sizeof(var))
        { [self release]; return nil; }
        
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
    else if (dataModel.pointerSize == 4)
    {
        struct objc_class_data_32 var;
        if ([self.memoryMap copyBytesAtOffset:offset fromAddress:parent.nodeContextAddress into:&var length:sizeof(var) requireFull:YES error:error] < sizeof(var))
        { [self release]; return nil; }
        
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
#pragma mark -  Values
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
    NSArray *fields;
    
    if (self.dataModel.pointerSize == 8) {
        struct objc_class_data_64 var;
        fields = @[
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(flags) description:@"Flags" offset:offsetof(typeof(var), flags) size:sizeof(var.flags)],
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(instanceStart) description:@"Instance Start" offset:offsetof(typeof(var), instanceStart) size:sizeof(var.instanceStart)],
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(instanceSize) description:@"Instance Size" offset:offsetof(typeof(var), instanceSize) size:sizeof(var.instanceSize)],
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(reserved) description:@"Reserved" offset:offsetof(typeof(var), reserved) size:sizeof(var.reserved)],
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(name) description:@"Name" offset:offsetof(typeof(var), name) size:sizeof(var.name)],
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(methods) description:@"Methods" offset:offsetof(typeof(var), baseMethodList) size:sizeof(var.baseMethodList)],
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(protocols) description:@"Protocols" offset:offsetof(typeof(var), baseProtocols) size:sizeof(var.baseProtocols)],
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(properties) description:@"Properties" offset:offsetof(typeof(var), baseProperties) size:sizeof(var.baseProperties)],
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(ivars) description:@"Instance Variables" offset:offsetof(typeof(var), ivars) size:sizeof(var.ivars)],
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(ivarLayout) description:@"ivar Layout" offset:offsetof(typeof(var), ivarLayout) size:sizeof(var.ivarLayout)],
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(weakIVarLayout) description:@"Weak ivar Layout" offset:offsetof(typeof(var), weakIVarLayout) size:sizeof(var.weakIVarLayout)],
        ];
    } else {
        struct objc_class_data_32 var;
        fields = @[
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(flags) description:@"Flags" offset:offsetof(typeof(var), flags) size:sizeof(var.flags)],
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(instanceStart) description:@"Instance Start" offset:offsetof(typeof(var), instanceStart) size:sizeof(var.instanceStart)],
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(instanceSize) description:@"Instance Size" offset:offsetof(typeof(var), instanceSize) size:sizeof(var.instanceSize)],
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(name) description:@"Name" offset:offsetof(typeof(var), name) size:sizeof(var.name)],
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(methods) description:@"Methods" offset:offsetof(typeof(var), baseMethodList) size:sizeof(var.baseMethodList)],
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(protocols) description:@"Protocols" offset:offsetof(typeof(var), baseProtocols) size:sizeof(var.baseProtocols)],
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(properties) description:@"Properties" offset:offsetof(typeof(var), baseProperties) size:sizeof(var.baseProperties)],
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(ivars) description:@"Instance Variables" offset:offsetof(typeof(var), ivars) size:sizeof(var.ivars)],
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(ivarLayout) description:@"ivar Layout" offset:offsetof(typeof(var), ivarLayout) size:sizeof(var.ivarLayout)],
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(weakIVarLayout) description:@"Weak ivar Layout" offset:offsetof(typeof(var), weakIVarLayout) size:sizeof(var.weakIVarLayout)],
        ];
    }
    
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:fields];
}

@end
