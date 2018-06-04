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
#import "MKInternal.h"
#import "MKPointer+Node.h"
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
    
    id<MKDataModel> dataModel = self.dataModel;
    size_t pointerSize = dataModel.pointerSize;
    
    if (pointerSize == 8)
    {
        NSError *memoryMapError = nil;
        
        struct objc_class_64 cls;
        if ([self.memoryMap copyBytesAtOffset:0 fromAddress:self.nodeContextAddress into:&cls length:sizeof(cls) requireFull:YES error:&memoryMapError] < sizeof(cls)) {
            MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_EINTERNAL_ERROR underlyingError:memoryMapError description:@"Could not read objc_class."];
            [self release]; return nil;
        }
        
        _metaClass = [[MKPointer alloc] initWithOffset:offsetof(struct objc_class_64, meta_class) fromParent:self targetClass:MKObjCClass.class error:error];
        _superClass = [[MKPointer alloc] initWithOffset:offsetof(struct objc_class_64, super_class) fromParent:self targetClass:MKObjCClass.class error:error];
        _cache = [[MKPointer alloc] initWithOffset:offsetof(struct objc_class_64, cache) fromParent:self error:error];
        _classData = [[MKPointer alloc] initWithOffset:offsetof(struct objc_class_64, data) fromParent:self targetClass:MKObjCClassData.class error:error];
        _mask = MKSwapLValue32(cls.mask, dataModel);
        _occupied = MKSwapLValue32(cls.occupied, dataModel);
    }
    else if (pointerSize == 4)
    {
        NSError *memoryMapError = nil;
        
        struct objc_class_32 cls;
        if ([self.memoryMap copyBytesAtOffset:0 fromAddress:self.nodeContextAddress into:&cls length:sizeof(cls) requireFull:YES error:&memoryMapError] < sizeof(cls)) {
            MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_EINTERNAL_ERROR underlyingError:memoryMapError description:@"Could not read objc_class."];
            [self release]; return nil;
        }
        
        _metaClass = [[MKPointer alloc] initWithOffset:offsetof(struct objc_class_32, meta_class) fromParent:self targetClass:MKObjCClass.class error:error];
        _superClass = [[MKPointer alloc] initWithOffset:offsetof(struct objc_class_32, super_class) fromParent:self targetClass:MKObjCClass.class error:error];
        _cache = [[MKPointer alloc] initWithOffset:offsetof(struct objc_class_32, cache) fromParent:self error:error];
        _classData = [[MKPointer alloc] initWithOffset:offsetof(struct objc_class_32, data) fromParent:self targetClass:MKObjCClassData.class error:error];
        _mask = MKSwapLValue16(cls.mask, dataModel);
        _occupied = MKSwapLValue16(cls.occupied, dataModel);
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
    [_classData release];
    [_cache release];
    [_superClass release];
    [_metaClass release];
    
    [super dealloc];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Class Values
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
{ return self.dataModel.pointerSize == 8 ? sizeof(struct objc_class_64) : sizeof(struct objc_class_32); }

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    struct objc_class_64 cls64;
    struct objc_class_32 cls32;
    
    size_t pointerSize = self.dataModel.pointerSize;
    
#define FIELD_TYPE(type64, type32) (pointerSize == 8 ? type64.sharedInstance : type32.sharedInstance)
#define FIELD_OFFSET(field) (pointerSize == 8 ? offsetof(typeof(cls64), field) : offsetof(typeof(cls32), field))
#define FIELD_SIZE(field) (pointerSize == 8 ? sizeof(cls64.field) : sizeof(cls32.field))
    
    MKNodeFieldBuilder *metaClass = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(metaClass)
        type:[MKNodeFieldTypePointer pointerWithType:FIELD_TYPE(MKNodeFieldTypeUnsignedQuadWord, MKNodeFieldTypeUnsignedDoubleWord)]
        offset:FIELD_OFFSET(meta_class)
        size:FIELD_SIZE(meta_class)
    ];
    metaClass.description = @"ISA";
    metaClass.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *superClass = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(superClass)
        type:[MKNodeFieldTypePointer pointerWithType:FIELD_TYPE(MKNodeFieldTypeUnsignedQuadWord, MKNodeFieldTypeUnsignedDoubleWord)]
        offset:FIELD_OFFSET(super_class)
        size:FIELD_SIZE(super_class)
    ];
    superClass.description = @"Super Class";
    superClass.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *cache = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(cache)
        type:[MKNodeFieldTypePointer pointerWithType:FIELD_TYPE(MKNodeFieldTypeUnsignedQuadWord, MKNodeFieldTypeUnsignedDoubleWord)]
        offset:FIELD_OFFSET(cache)
        size:FIELD_SIZE(cache)
    ];
    cache.description = @"Cache";
    cache.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *mask = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(mask)
        type:FIELD_TYPE(MKNodeFieldTypeUnsignedDoubleWord, MKNodeFieldTypeUnsignedWord)
        offset:FIELD_OFFSET(mask)
        size:FIELD_SIZE(mask)
    ];
    mask.description = @"Cache Mask";
    mask.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *occupied = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(occupied)
        type:FIELD_TYPE(MKNodeFieldTypeUnsignedDoubleWord, MKNodeFieldTypeUnsignedWord)
        offset:FIELD_OFFSET(occupied)
        size:FIELD_SIZE(occupied)
    ];
    occupied.description = @"Cache Occupied";
    occupied.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *classData = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(classData)
        type:[MKNodeFieldTypePointer pointerWithType:FIELD_TYPE(MKNodeFieldTypeUnsignedQuadWord, MKNodeFieldTypeUnsignedDoubleWord)]
        offset:FIELD_OFFSET(data)
        size:FIELD_SIZE(data)
    ];
    classData.description = @"Class Data";
    classData.options = MKNodeFieldOptionDisplayAsChild;
    
#undef FIELD_SIZE
#undef FIELD_OFFSET
#undef FIELD_TYPE
    
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        metaClass.build,
        superClass.build,
        cache.build,
        mask.build,
        occupied.build,
        classData.build
    ]];
}

@end
