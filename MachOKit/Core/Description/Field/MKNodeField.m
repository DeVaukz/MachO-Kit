//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKNodeField.m
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

#import "MKNodeField.h"
#import "MKInternal.h"
#import "MKOptional.h"
#import "MKNode.h"

//----------------------------------------------------------------------------//
@implementation MKNodeField

@synthesize name = _name;
@synthesize description = _description;
@synthesize type = _type;
@synthesize valueRecipe = _valueRecipe;
@synthesize dataRecipe = _dataRecipe;
@synthesize valueFormatter = _valueFormatter;
@synthesize options = _options;
@synthesize alternateFieldName = _alternateFieldName;

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithName:(NSString*)name description:(NSString*)description type:(id<MKNodeFieldType>)type value:(id<MKNodeFieldValueRecipe>)valueRecipe data:(id<MKNodeFieldDataRecipe>)dataRecipe formatter:(NSFormatter*)valueFormatter options:(MKNodeFieldOptions)options alternateFieldName:(nullable NSString*)alternateFieldName
{
    NSParameterAssert(name != nil);
    NSParameterAssert(valueRecipe != nil);
    
    self = [super init];
    if (self == nil) return nil;
    
    _name = [name copy];
    _description = [description copy];
    _type = [type retain];
    _valueRecipe = [valueRecipe retain];
    _dataRecipe = [dataRecipe retain];
    // The formatter really should be copied but it saves memory not to.
    _valueFormatter = [valueFormatter retain];
    _options = options;
    _alternateFieldName = [alternateFieldName copy];
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithName:(NSString*)name description:(NSString*)description type:(id<MKNodeFieldType>)type value:(id<MKNodeFieldValueRecipe>)valueRecipe data:(id<MKNodeFieldDataRecipe>)dataRecipe formatter:(NSFormatter*)valueFormatter options:(MKNodeFieldOptions)options
{
    return [self initWithName:name description:description type:type value:valueRecipe data:dataRecipe formatter:valueFormatter options:options alternateFieldName:nil];
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)init
{ @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"-init unavailable." userInfo:nil]; }

//|++++++++++++++++++++++++++++++++++++|//
- (void)dealloc
{
    [_name release];
    [_description release];
    [_type release];
    [_valueRecipe release];
    [_dataRecipe release];
    [_valueFormatter release];
    [_alternateFieldName release];
    
    [super dealloc];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Obtaining a Formatted Description
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (NSString*)formattedDescriptionForNode:(MKNode*)node
{
    id value = [self.valueRecipe valueForField:self ofNode:node].value;
    NSFormatter *formatter = self.valueFormatter;
    
    if (formatter)
        return [formatter stringForObjectValue:value];
    else
        return [value description];
}

@end
