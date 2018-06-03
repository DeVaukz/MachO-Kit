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
#import "NSError+MK.h"
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
    
    NSError *localError = nil;
    
    id<MKDataModel> dataModel = self.dataModel;
    NSAssert(dataModel != nil, @"Parent node must have a data model.");
    
    if (dataModel.pointerSize == 8)
    {
        struct objc_cat_64 var;
        if ([self.memoryMap copyBytesAtOffset:offset fromAddress:parent.nodeContextAddress into:&var length:sizeof(var) requireFull:YES error:error] < sizeof(var))
        { [self release]; return nil; }
        
        _name = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), name) fromParent:self targetClass:MKCString.class error:error];
        _cls = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), cls) fromParent:self error:error];
        _instanceMethods = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), instanceMethods) fromParent:self targetClass:MKObjCClassMethodList.class error:error];
        _classMethods = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), classMethods) fromParent:self targetClass:MKObjCClassMethodList.class error:error];
        _protocols = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), protocols) fromParent:self targetClass:MKObjCProtocolList.class error:error];
        _instanceProperties = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), instanceProperties) fromParent:self targetClass:MKObjCClassPropertyList.class error:error];
        
        // TODO -
        //_classProperties = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), instanceProperties) fromParent:self targetClass:MKObjCClassPropertyList.class error:error];
    }
    else if (dataModel.pointerSize == 4)
    {
        struct objc_cat_32 var;
        if ([self.memoryMap copyBytesAtOffset:offset fromAddress:parent.nodeContextAddress into:&var length:sizeof(var) requireFull:YES error:error] < sizeof(var))
        { [self release]; return nil; }
        
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
    [_instanceProperties release];
    [_protocols release];
    [_classMethods release];
    [_instanceMethods release];
    [_cls release];
    [_name release];
    
    [super dealloc];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Values
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
    NSArray *fields;
    
    if (self.dataModel.pointerSize == 8) {
        struct objc_cat_64 var;
        fields = @[
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(name) description:@"Name" offset:offsetof(typeof(var), name) size:sizeof(var.name)],
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(cls) description:@"Class" offset:offsetof(typeof(var), cls) size:sizeof(var.cls)],
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(instanceMethods) description:@"Instance Methods" offset:offsetof(typeof(var), instanceMethods) size:sizeof(var.instanceMethods)],
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(classMethods) description:@"Class Methods" offset:offsetof(typeof(var), classMethods) size:sizeof(var.classMethods)],
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(protocols) description:@"Protocols" offset:offsetof(typeof(var), protocols) size:sizeof(var.protocols)],
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(instanceProperties) description:@"Instance Properties" offset:offsetof(typeof(var), instanceProperties) size:sizeof(var.instanceProperties)],
            //[MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(classProperties) description:@"Class Properties" offset:offsetof(typeof(var), classProperties) size:sizeof(var.classProperties)],
        ];
    } else {
        struct objc_cat_32 var;
        fields = @[
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(name) description:@"Name" offset:offsetof(typeof(var), name) size:sizeof(var.name)],
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(cls) description:@"Class" offset:offsetof(typeof(var), cls) size:sizeof(var.cls)],
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(instanceMethods) description:@"Instance Methods" offset:offsetof(typeof(var), instanceMethods) size:sizeof(var.instanceMethods)],
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(classMethods) description:@"Class Methods" offset:offsetof(typeof(var), classMethods) size:sizeof(var.classMethods)],
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(protocols) description:@"Protocols" offset:offsetof(typeof(var), protocols) size:sizeof(var.protocols)],
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(instanceProperties) description:@"Instance Properties" offset:offsetof(typeof(var), instanceProperties) size:sizeof(var.instanceProperties)],
            //[MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(classProperties) description:@"Class Properties" offset:offsetof(typeof(var), classProperties) size:sizeof(var.classProperties)],
        ];
    }
    
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:fields];
}

@end
