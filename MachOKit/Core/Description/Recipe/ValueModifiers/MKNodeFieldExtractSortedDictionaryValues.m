//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKNodeFieldExtractSortedDictionaryValues.m
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

#import "MKNodeFieldExtractSortedDictionaryValues.h"
#import "MKInternal.h"
#import "MKOptional.h"
#import "MKNode.h"

//----------------------------------------------------------------------------//
@implementation MKNodeFieldExtractSortedDictionaryValues

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithValueRecipe:(id<MKNodeFieldValueRecipe>)recipe keyComparisonSelector:(SEL)comparisonSelector
{
    self = [super init];
    if (self == nil) return nil;
    
    _recipe = [recipe retain];
    _comparisonSelector = comparisonSelector;
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)init
{ @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"-init unavailable." userInfo:nil]; }

//|++++++++++++++++++++++++++++++++++++|//
- (void)dealloc
{
    [_recipe release];
    
    [super dealloc];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  MKNodeFieldValueRecipe
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (MKOptional*)valueForField:(MKNodeField*)field ofNode:(MKNode*)input
{
    MKOptional<NSDictionary*> *value = [_recipe valueForField:field ofNode:input];
    if (value.value == nil)
        return value;
    
    NSDictionary *dict = value.value;
    if ([dict isKindOfClass:NSDictionary.class] == NO)
        return value;
    
    NSArray *allKeys = [dict.allKeys sortedArrayUsingSelector:_comparisonSelector];
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:dict.count];
    
    for (id key in allKeys) {
        [result addObject:[dict objectForKey:key]];
    }
    
    value = [MKOptional optionalWithValue:result];
    [result release];
    
    return value;
}

@end
