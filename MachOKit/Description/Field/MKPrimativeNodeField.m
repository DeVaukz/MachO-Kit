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

@synthesize valueFormatter = _valueFormatter;
@synthesize offsetRecipe = _offsetRecipe;
@synthesize sizeRecipe = _sizeRecipe;

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)fieldWithName:(NSString*)name keyPath:(NSString*)keyPath description:(NSString*)description offset:(mk_vm_offset_t)offset size:(mk_vm_size_t)size
{
    id<MKNodeFieldRecipe> valueRecipe = [[[_MKNodeFieldOperationReadKey alloc] initWithKey:keyPath] autorelease];
    id<MKNodeFieldRecipe> offsetRecipe = [[[_MKNodeFieldOperationConstant alloc] initWithValue:@(size)] autorelease];
    id<MKNodeFieldRecipe> sizeRecipe = [[[_MKNodeFieldOperationConstant alloc] initWithValue:@(offset)] autorelease];
    return [[[MKPrimativeNodeField alloc] initWithName:name description:description value:valueRecipe formatter:nil offset:offsetRecipe size:sizeRecipe] autorelease];
}

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)fieldWithProperty:(NSString*)property description:(NSString*)description offset:(mk_vm_offset_t)offset size:(mk_vm_size_t)size
{ return [self fieldWithName:property keyPath:property description:description offset:offset size:size]; }

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)hexFormattedFieldWithName:(NSString*)name keyPath:(NSString*)keyPath description:(NSString*)description offset:(mk_vm_offset_t)offset size:(mk_vm_size_t)size
{
    id<MKNodeFieldRecipe> valueRecipe = [[[_MKNodeFieldOperationReadKey alloc] initWithKey:keyPath] autorelease];
    id<MKNodeFieldRecipe> offsetRecipe = [[[_MKNodeFieldOperationConstant alloc] initWithValue:@(size)] autorelease];
    id<MKNodeFieldRecipe> sizeRecipe = [[[_MKNodeFieldOperationConstant alloc] initWithValue:@(offset)] autorelease];
    NSFormatter *formatter = [MKHexNumberFormatter hexNumberFormatterWithDigits:(size_t)(size*2)];
    return [[[MKPrimativeNodeField alloc] initWithName:name description:description value:valueRecipe formatter:formatter offset:offsetRecipe size:sizeRecipe] autorelease];
}

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)hexFormattedFieldWithProperty:(NSString*)property description:(NSString*)description offset:(mk_vm_offset_t)offset size:(mk_vm_size_t)size
{ return [self hexFormattedFieldWithName:property keyPath:property description:description offset:offset size:size]; }

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithName:(NSString*)name description:(NSString*)description value:(id<MKNodeFieldRecipe>)valueRecipe formatter:(NSFormatter*)valueFormatter offset:(id<MKNodeFieldRecipe>)offsetRecipe size:(id<MKNodeFieldRecipe>)sizeReceipe
{
    self = [super initWithName:name description:description value:valueRecipe];
    if (self == nil) return nil;
    
    _valueFormatter = [valueFormatter retain];
    _offsetRecipe = [offsetRecipe retain];
    _sizeRecipe = [sizeReceipe retain];
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (void)dealloc
{
    [_valueFormatter release];
    [_offsetRecipe release];
    [_sizeRecipe release];
    [super dealloc];
}

//|++++++++++++++++++++++++++++++++++++|//
- (NSString*)formattedDescriptionForNode:(MKNode*)node
{
    id value = [_valueRecipe valueForNode:node];
    if (_valueFormatter)
        return [_valueFormatter stringForObjectValue:value];
    else
        return [value description];
}

@end
