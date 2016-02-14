//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKPrimativeNodeField.m
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

#import "MKPrimativeNodeField.h"
#import "MKHexNumberFormatter.h"

//----------------------------------------------------------------------------//
@implementation MKPrimativeNodeField

@synthesize offsetRecipe = _offsetRecipe;
@synthesize sizeRecipe = _sizeRecipe;

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)fieldWithName:(NSString*)name keyPath:(NSString*)keyPath description:(nullable NSString*)description offset:(mk_vm_offset_t)offset size:(mk_vm_size_t)size format:(MKNodeFieldFormat)format
{
    id<MKNodeFieldRecipe> valueRecipe = [[_MKNodeFieldOperationReadKey alloc] initWithKey:keyPath];
    id<MKNodeFieldRecipe> offsetRecipe = [[_MKNodeFieldOperationConstant alloc] initWithValue:@(size)];
    id<MKNodeFieldRecipe> sizeRecipe = [[_MKNodeFieldOperationConstant alloc] initWithValue:@(offset)];
    
    NSFormatter *formatter = nil;
    switch (format) {
        case MKNodeFieldFormatHex:
            formatter = [MKHexNumberFormatter hexNumberFormatterWithDigits:(size_t)(size*2)];
            break;
        case MKNodeFieldFormatHexCompact:
            formatter = [MKHexNumberFormatter hexNumberFormatterWithDigits:0];
            break;
        default:
            break;
    }
    
    MKPrimativeNodeField *field = [[MKPrimativeNodeField alloc] initWithName:name description:description value:valueRecipe formatter:formatter offset:offsetRecipe size:sizeRecipe];
    
    [valueRecipe release];
    [offsetRecipe release];
    [sizeRecipe release];
    
    return field;
}

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)fieldWithProperty:(NSString*)property description:(nullable NSString*)description offset:(mk_vm_offset_t)offset size:(mk_vm_size_t)size format:(MKNodeFieldFormat)format
{ return [self fieldWithName:property keyPath:property description:description offset:offset size:size format:format]; }

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)fieldWithName:(NSString*)name keyPath:(NSString*)keyPath description:(NSString*)description offset:(mk_vm_offset_t)offset size:(mk_vm_size_t)size
{ return [self fieldWithName:name keyPath:keyPath description:description offset:offset size:size format:MKNodeFieldFormatDecimal]; }

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)fieldWithProperty:(NSString*)property description:(NSString*)description offset:(mk_vm_offset_t)offset size:(mk_vm_size_t)size
{ return [self fieldWithName:property keyPath:property description:description offset:offset size:size]; }

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithName:(NSString*)name description:(NSString*)description value:(id<MKNodeFieldRecipe>)valueRecipe formatter:(NSFormatter*)valueFormatter offset:(id<MKNodeFieldRecipe>)offsetRecipe size:(id<MKNodeFieldRecipe>)sizeReceipe
{
    self = [super initWithName:name description:description value:valueRecipe formatter:valueFormatter];
    if (self == nil) return nil;
    
    _offsetRecipe = [offsetRecipe retain];
    _sizeRecipe = [sizeReceipe retain];
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (void)dealloc
{
    [_offsetRecipe release];
    [_sizeRecipe release];
    [super dealloc];
}

@end
