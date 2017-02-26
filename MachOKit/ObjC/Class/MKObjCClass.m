//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKObjCClass.m
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

#import "MKObjCClass.h"
#import "NSError+MK.h"
#import "MKObjCClassData.h"

struct objc_class_64 {
    uint64_t meta_class;
    uint64_t super_class;
    uint64_t cache;
    uint32_t mask;
    uint32_t occupied;
    uint64_t data;
};

struct objc_class_32 {
    uint32_t meta_class;
    uint32_t super_class;
    uint32_t cache;
    uint16_t mask;
    uint16_t occupied;
    uint32_t data;
};

//----------------------------------------------------------------------------//
@implementation MKObjCClass

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
        struct objc_class_64 cls;
        if ([self.memoryMap copyBytesAtOffset:offset fromAddress:parent.nodeContextAddress into:&cls length:sizeof(cls) requireFull:YES error:error] < sizeof(cls))
        { [self release]; return nil; }
        
        _metaClass = [[MKPointer alloc] initWithOffset:offsetof(struct objc_class_64, meta_class) fromParent:self targetClass:MKObjCClass.class error:error];
        _superClass = [[MKPointer alloc] initWithOffset:offsetof(struct objc_class_64, super_class) fromParent:self targetClass:MKObjCClass.class error:error];
        _cache = [[MKPointer alloc] initWithOffset:offsetof(struct objc_class_64, cache) fromParent:self error:error];
        _classData = [[MKPointer alloc] initWithOffset:offsetof(struct objc_class_64, data) fromParent:self targetClass:MKObjCClassData.class error:error];
        _mask = MKSwapLValue32(cls.mask, dataModel);
        _occupied = MKSwapLValue32(cls.occupied, dataModel);
    }
    else if (dataModel.pointerSize == 4)
    {
        struct objc_class_32 cls;
        if ([self.memoryMap copyBytesAtOffset:offset fromAddress:parent.nodeContextAddress into:&cls length:sizeof(cls) requireFull:YES error:error] < sizeof(cls))
        { [self release]; return nil; }
        
        _metaClass = [[MKPointer alloc] initWithOffset:offsetof(struct objc_class_32, meta_class) fromParent:self targetClass:MKObjCClass.class error:error];
        _superClass = [[MKPointer alloc] initWithOffset:offsetof(struct objc_class_32, super_class) fromParent:self targetClass:MKObjCClass.class error:error];
        _cache = [[MKPointer alloc] initWithOffset:offsetof(struct objc_class_32, cache) fromParent:self error:error];
        _classData = [[MKPointer alloc] initWithOffset:offsetof(struct objc_class_32, data) fromParent:self targetClass:MKObjCClassData.class error:error];
        _mask = MKSwapLValue16(cls.mask, dataModel);
        _occupied = MKSwapLValue16(cls.occupied, dataModel);
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
    [_classData release];
    [_cache release];
    [_superClass release];
    [_metaClass release];
    
    [super dealloc];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Values
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@synthesize metaClass = _metaClass;
@synthesize superClass = _superClass;
@synthesize cache = _cache;
@synthesize mask = _mask;
@synthesize occupied = _occupied;
@synthesize classData = _classData;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_size_t)nodeSize
{ return (self.dataModel.pointerSize == 8) ? sizeof(struct objc_class_64) : sizeof(struct objc_class_32); }

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    struct objc_class_64 cls64;
    struct objc_class_32 cls32;
    NSArray *fields;
    
    if (self.dataModel.pointerSize == 8)
        fields = @[
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(metaClass) description:@"ISA" offset:offsetof(struct objc_class_64, meta_class) size:sizeof(cls64.meta_class)],
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(superClass) description:@"Super Class" offset:offsetof(struct objc_class_64, super_class) size:sizeof(cls64.super_class)],
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(cache) description:@"Cache" offset:offsetof(struct objc_class_64, cache) size:sizeof(cls64.cache)],
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(mask) description:@"Cache Mask" offset:offsetof(struct objc_class_64, mask) size:sizeof(cls64.mask)],
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(occupied) description:@"Cache Occupied" offset:offsetof(struct objc_class_64, occupied) size:sizeof(cls64.occupied)],
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(classData) description:@"Data" offset:offsetof(struct objc_class_64, data) size:sizeof(cls64.data)]
        ];
    else
        fields = @[
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(metaClass) description:@"ISA" offset:offsetof(struct objc_class_32, meta_class) size:sizeof(cls32.meta_class)],
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(superClass) description:@"Super Class" offset:offsetof(struct objc_class_32, super_class) size:sizeof(cls32.super_class)],
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(cache) description:@"Cache" offset:offsetof(struct objc_class_32, cache) size:sizeof(cls32.cache)],
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(mask) description:@"Cache Mask" offset:offsetof(struct objc_class_32, mask) size:sizeof(cls32.mask)],
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(occupied) description:@"Cache Occupied" offset:offsetof(struct objc_class_32, occupied) size:sizeof(cls32.occupied)],
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(classData) description:@"Data" offset:offsetof(struct objc_class_32, data) size:sizeof(cls32.data)]
        ];
        
    
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:fields];
}

@end
