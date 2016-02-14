//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKFormattedNodeField.m
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

#import "MKFormattedNodeField.h"
#import "MKHexNumberFormatter.h"

//----------------------------------------------------------------------------//
@implementation MKFormattedNodeField

@synthesize valueFormatter = _valueFormatter;

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)fieldWithName:(NSString*)name keyPath:(NSString*)keyPath description:(nullable NSString*)description format:(MKNodeFieldFormat)format
{
    id<MKNodeFieldRecipe> valueRecipe = [[_MKNodeFieldOperationReadKey alloc] initWithKey:keyPath];
    
    NSFormatter *formatter = nil;
    switch (format) {
        case MKNodeFieldFormatHex:
            formatter = [MKHexNumberFormatter hexNumberFormatterWithDigits:SIZE_T_MAX];
            break;
        case MKNodeFieldFormatHexCompact:
            formatter = [MKHexNumberFormatter hexNumberFormatterWithDigits:0];
            break;
        default:
            break;
    }
    
    MKFormattedNodeField *field = [[MKFormattedNodeField alloc] initWithName:name description:description value:valueRecipe formatter:formatter];
    
    [valueRecipe release];
    
    return field;
}

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)fieldWithProperty:(NSString*)property description:(nullable NSString*)description format:(MKNodeFieldFormat)format
{ return [self fieldWithName:property keyPath:property description:description format:format]; }

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithName:(NSString*)name description:(nullable NSString*)description value:(id<MKNodeFieldRecipe>)valueRecipe formatter:(nullable NSFormatter*)valueFormatter
{
    self = [super initWithName:name description:description value:valueRecipe];
    if (self == nil) return nil;
    
    _valueFormatter = [valueFormatter retain];
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (void)dealloc
{
    [_valueFormatter release];
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
