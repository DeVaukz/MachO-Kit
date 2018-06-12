//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKCFString.m
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

#import "MKCFString.h"
#import "MKInternal.h"
#import "MKPointer+Node.h"
#import "MKObjCClass.h"

struct cf_string_64 {
    uint64_t isa;
    uint64_t flags;
    uint64_t string;
    uint64_t length;
};

struct cf_string_32 {
    uint32_t isa;
    uint32_t flags;
    uint32_t string;
    uint32_t length;
};

//----------------------------------------------------------------------------//
@implementation MKCFString

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithOffset:(mk_vm_offset_t)offset fromParent:(MKBackedNode*)parent error:(NSError**)error
{
    self = [super initWithOffset:offset fromParent:parent error:error];
    if (self == nil) return nil;
    
    id<MKDataModel> dataModel = self.dataModel;
    size_t pointerSize = dataModel.pointerSize;
    
    if (dataModel.pointerSize == 8)
    {
        NSError *memoryMapError = nil;
        
        struct cf_string_64 var;
        if ([self.memoryMap copyBytesAtOffset:offset fromAddress:parent.nodeContextAddress into:&var length:sizeof(var) requireFull:YES error:&memoryMapError] < sizeof(var)) {
            MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_EINTERNAL_ERROR underlyingError:memoryMapError description:@"Could not read __builtin_CFString."];
            [self release]; return nil;
        }
        
        _isa = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), isa) fromParent:self targetClass:MKObjCClass.class error:error];
        _string = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), string) fromParent:self targetClass:nil error:error];
        _flags = (uint32_t)MKSwapLValue64(var.flags, dataModel);
        _length = MKSwapLValue64(var.length, dataModel);
    }
    else if (dataModel.pointerSize == 4)
    {
        NSError *memoryMapError = nil;
        
        struct cf_string_32 var;
        if ([self.memoryMap copyBytesAtOffset:offset fromAddress:parent.nodeContextAddress into:&var length:sizeof(var) requireFull:YES error:&memoryMapError] < sizeof(var)) {
            MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_EINTERNAL_ERROR underlyingError:memoryMapError description:@"Could not read __builtin_CFString."];
            [self release]; return nil;
        }
        
        _isa = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), isa) fromParent:self targetClass:MKObjCClass.class error:error];
        _string = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), string) fromParent:self targetClass:nil error:error];
        _flags = MKSwapLValue32(var.flags, dataModel);
        _length = MKSwapLValue32(var.length, dataModel);
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
    [_string release];
    [_isa release];
    
    [super dealloc];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  String Values
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@synthesize isa = _isa;
@synthesize flags = _flags;
@synthesize string = _string;
@synthesize length = _length;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_size_t)nodeSize
{ return (self.dataModel.pointerSize == 8) ? sizeof(struct cf_string_64) : sizeof(struct cf_string_32); }

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    struct cf_string_64 cf64;
    struct cf_string_32 cf32;
    
    size_t pointerSize = self.dataModel.pointerSize;
    
#define FIELD_TYPE(type64, type32) (pointerSize == 8 ? type64.sharedInstance : type32.sharedInstance)
#define FIELD_OFFSET(field) (pointerSize == 8 ? offsetof(typeof(cf64), field) : offsetof(typeof(cf32), field))
#define FIELD_SIZE(field) (pointerSize == 8 ? sizeof(cf64.field) : sizeof(cf32.field))
    
    MKNodeFieldBuilder *isa = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(isa)
        type:[MKNodeFieldTypePointer pointerWithType:FIELD_TYPE(MKNodeFieldTypeUnsignedQuadWord, MKNodeFieldTypeUnsignedDoubleWord)]
        offset:FIELD_OFFSET(isa)
        size:FIELD_SIZE(isa)
    ];
    isa.description = @"ISA";
    isa.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *flags = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(flags)
        type:FIELD_TYPE(MKNodeFieldTypeUnsignedQuadWord, MKNodeFieldTypeUnsignedDoubleWord)
        offset:FIELD_OFFSET(flags)
        size:FIELD_SIZE(flags)
    ];
    flags.description = @"Flags";
    flags.options = MKNodeFieldOptionDisplayAsDetail;
    flags.formatter = [NSFormatter mk_hexCompactFormatter];
    
    MKNodeFieldBuilder *string = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(string)
        type:[MKNodeFieldTypePointer pointerWithType:FIELD_TYPE(MKNodeFieldTypeUnsignedQuadWord, MKNodeFieldTypeUnsignedDoubleWord)]
        offset:FIELD_OFFSET(string)
        size:FIELD_SIZE(string)
    ];
    string.description = @"String";
    string.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *length = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(length)
        type:FIELD_TYPE(MKNodeFieldTypeUnsignedQuadWord, MKNodeFieldTypeUnsignedDoubleWord)
        offset:FIELD_OFFSET(length)
        size:FIELD_SIZE(length)
    ];
    length.description = @"Length";
    length.options = MKNodeFieldOptionDisplayAsDetail;
    
#undef FIELD_SIZE
#undef FIELD_OFFSET
#undef FIELD_TYPE
    
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        isa.build,
        flags.build,
        string.build,
        length.build
    ]];
}

@end
