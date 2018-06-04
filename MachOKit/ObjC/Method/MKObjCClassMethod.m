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
#import "MKInternal.h"
#import "MKPointer+Node.h"

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
    
    id<MKDataModel> dataModel = self.dataModel;
    size_t pointerSize = dataModel.pointerSize;
    
    if (pointerSize == 8)
    {
        NSError *memoryMapError = nil;
        
        struct objc_method_64 var;
        if ([self.memoryMap copyBytesAtOffset:offset fromAddress:parent.nodeContextAddress into:&var length:sizeof(var) requireFull:YES error:&memoryMapError] < sizeof(var)) {
            MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_EINTERNAL_ERROR underlyingError:memoryMapError description:@"Could not read objc_method."];
            [self release]; return nil;
        }
        
        _name = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), name) fromParent:self targetClass:MKCString.class error:error];
        _types = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), types) fromParent:self targetClass:MKCString.class error:error];
        _implementation = MKSwapLValue64(var.imp, dataModel);
    }
    else if (pointerSize == 4)
    {
        NSError *memoryMapError = nil;
        
        struct objc_method_32 var;
        if ([self.memoryMap copyBytesAtOffset:offset fromAddress:parent.nodeContextAddress into:&var length:sizeof(var) requireFull:YES error:&memoryMapError] < sizeof(var)) {
            MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_EINTERNAL_ERROR underlyingError:memoryMapError description:@"Could not read objc_method."];
            [self release]; return nil;
        }
        
        _name = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), name) fromParent:self targetClass:MKCString.class error:error];
        _types = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), types) fromParent:self targetClass:MKCString.class error:error];
        _implementation = MKSwapLValue32(var.imp, dataModel);
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
    [_types release];
    [_name release];
    
    [super dealloc];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Method Values
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
    struct objc_method_64 method64;
    struct objc_method_32 method32;
    
    size_t pointerSize = self.dataModel.pointerSize;
    
#define FIELD_TYPE(type64, type32) (pointerSize == 8 ? type64.sharedInstance : type32.sharedInstance)
#define FIELD_OFFSET(field) (pointerSize == 8 ? offsetof(typeof(method64), field) : offsetof(typeof(method32), field))
#define FIELD_SIZE(field) (pointerSize == 8 ? sizeof(method64.field) : sizeof(method32.field))
    
    MKNodeFieldBuilder *name = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(name)
        type:[MKNodeFieldTypePointer pointerWithType:FIELD_TYPE(MKNodeFieldTypeUnsignedQuadWord, MKNodeFieldTypeUnsignedDoubleWord)]
        offset:FIELD_OFFSET(name)
        size:FIELD_SIZE(name)
    ];
    name.description = @"Name";
    name.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *types = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(types)
        type:[MKNodeFieldTypePointer pointerWithType:FIELD_TYPE(MKNodeFieldTypeUnsignedQuadWord, MKNodeFieldTypeUnsignedDoubleWord)]
        offset:FIELD_OFFSET(types)
        size:FIELD_SIZE(types)
    ];
    types.description = @"Types";
    types.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *implementation = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(implementation)
        type:MKNodeFieldTypeAddress.sharedInstance
        offset:FIELD_OFFSET(imp)
        size:FIELD_SIZE(imp)
    ];
    implementation.description = @"Implementation";
    implementation.options = MKNodeFieldOptionDisplayAsDetail;
    
#undef FIELD_SIZE
#undef FIELD_OFFSET
#undef FIELD_TYPE
    
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        name.build,
        types.build,
        implementation.build
    ]];
}

@end
