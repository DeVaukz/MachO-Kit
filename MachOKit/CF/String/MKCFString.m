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
#import "MKCString.h"
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
    
    NSError *localError = nil;
    
    id<MKDataModel> dataModel = self.dataModel;
    NSAssert(dataModel != nil, @"Parent node must have a data model.");
    
    if (dataModel.pointerSize == 8)
    {
        struct cf_string_64 var;
        if ([self.memoryMap copyBytesAtOffset:offset fromAddress:parent.nodeContextAddress into:&var length:sizeof(var) requireFull:YES error:error] < sizeof(var))
        { [self release]; return nil; }
        
        _isa = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), isa) fromParent:self targetClass:MKObjCClass.class error:error];
        _string = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), string) fromParent:self targetClass:MKCString.class error:error];
        _flags = (uint32_t)MKSwapLValue64(var.flags, dataModel);
        _length = MKSwapLValue64(var.length, dataModel);
    }
    else if (dataModel.pointerSize == 4)
    {
        struct cf_string_32 var;
        if ([self.memoryMap copyBytesAtOffset:offset fromAddress:parent.nodeContextAddress into:&var length:sizeof(var) requireFull:YES error:error] < sizeof(var))
        { [self release]; return nil; }
        
        _isa = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), isa) fromParent:self targetClass:MKObjCClass.class error:error];
        _string = [[MKPointer alloc] initWithOffset:offsetof(typeof(var), string) fromParent:self targetClass:MKCString.class error:error];
        _flags = MKSwapLValue32(var.flags, dataModel);
        _length = MKSwapLValue32(var.length, dataModel);
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
    [_string release];
    [_isa release];
    
    [super dealloc];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Values
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
    NSArray *fields;
    
    if (self.dataModel.pointerSize == 8) {
        struct cf_string_64 var;
        fields = @[
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(isa) description:@"ISA" offset:offsetof(typeof(var), isa) size:sizeof(var.isa)],
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(flags) description:@"Flags" offset:offsetof(typeof(var), flags) size:sizeof(var.flags)],
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(string) description:@"String" offset:offsetof(typeof(var), string) size:sizeof(var.string)],
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(length) description:@"Length" offset:offsetof(typeof(var), length) size:sizeof(var.length)]
        ];
    } else {
        struct cf_string_32 var;
        fields = @[
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(isa) description:@"ISA" offset:offsetof(typeof(var), isa) size:sizeof(var.isa)],
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(flags) description:@"Flags" offset:offsetof(typeof(var), flags) size:sizeof(var.flags)],
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(string) description:@"String" offset:offsetof(typeof(var), string) size:sizeof(var.string)],
            [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(length) description:@"Length" offset:offsetof(typeof(var), length) size:sizeof(var.length)]
        ];
    }
    
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:fields];
}

@end
