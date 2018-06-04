//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKObjCClassIVar.m
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

#import "MKObjCClassIVar.h"
#import "MKInternal.h"
#import "MKPointer+Node.h"

struct objc_ivar_64 {
    uint64_t offset;
    uint64_t name;
    uint64_t type;
    uint32_t alignment;
    uint32_t size;
};

struct objc_ivar_32 {
    uint32_t offset;
    uint32_t name;
    uint32_t type;
    uint32_t alignment;
    uint32_t size;
};

//----------------------------------------------------------------------------//
@implementation MKObjCClassIVar

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
        
        struct objc_ivar_64 var;
        if ([self.memoryMap copyBytesAtOffset:offset fromAddress:parent.nodeContextAddress into:&var length:sizeof(var) requireFull:YES error:&memoryMapError] < sizeof(var)) {
            MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_EINTERNAL_ERROR underlyingError:memoryMapError description:@"Could not read objc_ivar."];
            [self release]; return nil;
        }
        
        _name = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), name) fromParent:self targetClass:MKCString.class error:error];
        _type = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), type) fromParent:self targetClass:MKCString.class error:error];
        _offset = MKSwapLValue64(var.offset, dataModel);
        _alignment = MKSwapLValue32(var.alignment, dataModel);
        _size = MKSwapLValue32(var.size, dataModel);
    }
    else if (pointerSize == 4)
    {
        NSError *memoryMapError = nil;
        
        struct objc_ivar_32 var;
        if ([self.memoryMap copyBytesAtOffset:offset fromAddress:parent.nodeContextAddress into:&var length:sizeof(var) requireFull:YES error:&memoryMapError] < sizeof(var)) {
            MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_EINTERNAL_ERROR underlyingError:memoryMapError description:@"Could not read objc_ivar."];
            [self release]; return nil;
        }
        
        _name = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), name) fromParent:self targetClass:MKCString.class error:error];
        _type = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), type) fromParent:self targetClass:MKCString.class error:error];
        _offset = MKSwapLValue32(var.offset, dataModel);
        _alignment = MKSwapLValue32(var.alignment, dataModel);
        _size = MKSwapLValue32(var.size, dataModel);
    }
    else
    {
        NSString *reason = [NSString stringWithFormat:@"Unsupported pointer size [%zu].", pointerSize];
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:nil];
    }
    
    // Convert the alignment to bytes.
    if (_alignment == ~(uint32_t)0)
        _alignment = (uint32_t)self.dataModel.pointerSize;
    else
        _alignment = (uint32_t)(1U << _alignment);
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (void)dealloc
{
    [_type release];
    [_name release];
    
    [super dealloc];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  IVar Values
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@synthesize offset = _offset;
@synthesize name = _name;
@synthesize type = _type;
@synthesize alignment = _alignment;
@synthesize size = _size;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_size_t)nodeSize
{ return (self.dataModel.pointerSize == 8) ? sizeof(struct objc_ivar_64) : sizeof(struct objc_ivar_32); }

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    struct objc_ivar_64 ivar64;
    struct objc_ivar_32 ivar32;
    
    size_t pointerSize = self.dataModel.pointerSize;
    
#define FIELD_TYPE(type64, type32) (pointerSize == 8 ? type64.sharedInstance : type32.sharedInstance)
#define FIELD_OFFSET(field) (pointerSize == 8 ? offsetof(typeof(ivar64), field) : offsetof(typeof(ivar32), field))
#define FIELD_SIZE(field) (pointerSize == 8 ? sizeof(ivar64.field) : sizeof(ivar32.field))
    
    MKNodeFieldBuilder *offset = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(offset)
        type:[MKNodeFieldTypePointer pointerWithType:MKNodeFieldTypeUnsignedQuadWord.sharedInstance]
        offset:FIELD_OFFSET(offset)
        size:FIELD_SIZE(offset)
    ];
    offset.description = @"Offset";
    offset.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *name = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(name)
        type:[MKNodeFieldTypePointer pointerWithType:FIELD_TYPE(MKNodeFieldTypeUnsignedQuadWord, MKNodeFieldTypeUnsignedDoubleWord)]
        offset:FIELD_OFFSET(name)
        size:FIELD_SIZE(name)
    ];
    name.description = @"Name";
    name.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *type = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(type)
        type:[MKNodeFieldTypePointer pointerWithType:FIELD_TYPE(MKNodeFieldTypeUnsignedQuadWord, MKNodeFieldTypeUnsignedDoubleWord)]
        offset:FIELD_OFFSET(type)
        size:FIELD_SIZE(type)
    ];
    type.description = @"Type";
    type.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *alignment = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(alignment)
        type:[MKNodeFieldTypePointer pointerWithType:MKNodeFieldTypeUnsignedDoubleWord.sharedInstance]
        offset:FIELD_OFFSET(alignment)
        size:FIELD_SIZE(alignment)
    ];
    alignment.description = @"Alignment";
    alignment.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *size = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(size)
        type:[MKNodeFieldTypePointer pointerWithType:MKNodeFieldTypeUnsignedDoubleWord.sharedInstance]
        offset:FIELD_OFFSET(size)
        size:FIELD_SIZE(size)
    ];
    size.description = @"AlignSizement";
    size.options = MKNodeFieldOptionDisplayAsDetail;
    
#undef FIELD_SIZE
#undef FIELD_OFFSET
#undef FIELD_TYPE
    
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        offset.build,
        name.build,
        type.build,
        alignment.build,
        size.build
    ]];
}

@end
