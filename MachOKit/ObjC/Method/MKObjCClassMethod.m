//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKObjCClassMethod.m
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

#import "MKObjCClassMethod.h"
#import "NSError+MK.h"

struct objc_method_64 {
    uint64_t name;
    uint64_t types;
    uint64_t imp;
};

struct objc_method_32 {
    uint32_t name;
    uint32_t types;
    uint32_t imp;
};

//----------------------------------------------------------------------------//
@implementation MKObjCClassMethod

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
        struct objc_method_64 var;
        if ([self.memoryMap copyBytesAtOffset:offset fromAddress:parent.nodeContextAddress into:&var length:sizeof(var) requireFull:YES error:error] < sizeof(var))
        { [self release]; return nil; }
        
        _name = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), name) fromParent:self error:error];
        _types = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), types) fromParent:self error:error];
        _implementation = MKSwapLValue64(var.imp, dataModel);
    }
    else if (dataModel.pointerSize == 4)
    {
        struct objc_method_32 var;
        if ([self.memoryMap copyBytesAtOffset:offset fromAddress:parent.nodeContextAddress into:&var length:sizeof(var) requireFull:YES error:error] < sizeof(var))
        { [self release]; return nil; }
        
        _name = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), name) fromParent:self error:error];
        _types = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), types) fromParent:self error:error];
        _implementation = MKSwapLValue32(var.imp, dataModel);
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
    [_types release];
    [_name release];
    
    [super dealloc];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Values
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@synthesize name = _name;
@synthesize types = _types;
@synthesize implementation = _implementation;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_size_t)nodeSize
{ return (self.dataModel.pointerSize == 8) ? sizeof(struct objc_method_64) : sizeof(struct objc_method_32); }

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    struct objc_method_64 var64;
    struct objc_method_32 var32;
    NSArray *fields;
    
    if (self.dataModel.pointerSize == 8)
        fields = @[
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(name) description:@"Name" offset:offsetof(typeof(var64), name) size:sizeof(var64.name)],
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(types) description:@"Types" offset:offsetof(typeof(var64), types) size:sizeof(var64.types)],
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(implementation) description:@"Implementation" offset:offsetof(typeof(var64), imp) size:sizeof(var64.imp)]
        ];
    else
        fields = @[
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(name) description:@"Name" offset:offsetof(typeof(var32), name) size:sizeof(var32.name)],
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(types) description:@"Types" offset:offsetof(typeof(var32), types) size:sizeof(var32.types)],
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(implementation) description:@"Implementation" offset:offsetof(typeof(var32), imp) size:sizeof(var32.imp)]
        ];
    
    
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:fields];
}

@end
