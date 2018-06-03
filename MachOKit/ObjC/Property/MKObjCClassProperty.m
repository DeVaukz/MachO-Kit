//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKObjCProperty.m
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

#import "MKObjCClassProperty.h"
#import "NSError+MK.h"
#import "MKPointer+Node.h"

struct objc_property_64 {
    uint64_t name;
    uint64_t attributes;
};

struct objc_property_32 {
    uint32_t name;
    uint32_t attributes;
};

//----------------------------------------------------------------------------//
@implementation MKObjCClassProperty

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
        struct objc_property_64 var;
        if ([self.memoryMap copyBytesAtOffset:offset fromAddress:parent.nodeContextAddress into:&var length:sizeof(var) requireFull:YES error:error] < sizeof(var))
        { [self release]; return nil; }
        
        _name = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), name) fromParent:self error:error];
        _attributes = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), attributes) fromParent:self error:error];
    }
    else if (dataModel.pointerSize == 4)
    {
        struct objc_property_32 var;
        if ([self.memoryMap copyBytesAtOffset:offset fromAddress:parent.nodeContextAddress into:&var length:sizeof(var) requireFull:YES error:error] < sizeof(var))
        { [self release]; return nil; }
        
        _name = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), name) fromParent:self error:error];
        _attributes = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), attributes) fromParent:self error:error];
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
    [_attributes release];
    [_name release];
    
    [super dealloc];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Values
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@synthesize name = _name;
@synthesize attributes = _attributes;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_size_t)nodeSize
{ return (self.dataModel.pointerSize == 8) ? sizeof(struct objc_property_64) : sizeof(struct objc_property_32); }

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    struct objc_property_64 var64;
    struct objc_property_32 var32;
    NSArray *fields;
    
    if (self.dataModel.pointerSize == 8)
        fields = @[
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(name) description:@"Name" offset:offsetof(typeof(var64), name) size:sizeof(var64.name)],
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(attributes) description:@"Attributes" offset:offsetof(typeof(var64), attributes) size:sizeof(var64.attributes)]
        ];
    else
        fields = @[
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(name) description:@"Name" offset:offsetof(typeof(var32), name) size:sizeof(var32.name)],
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(attributes) description:@"Attributes" offset:offsetof(typeof(var32), attributes) size:sizeof(var32.attributes)]
        ];
    
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:fields];
}

@end
