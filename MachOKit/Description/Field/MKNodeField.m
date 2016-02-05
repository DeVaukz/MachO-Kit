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
#import "MKNode.h"

//----------------------------------------------------------------------------//
@implementation MKNodeField

@synthesize name = _name;
@synthesize description = _description;
@synthesize valueRecipe = _valueRecipe;

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)nodeFieldWithName:(NSString*)name keyPath:(NSString*)keyPath description:(NSString*)description
{
    id<MKNodeFieldRecipe> valueRecipe = [[[_MKNodeFieldOperationReadKey alloc] initWithKey:keyPath] autorelease];
    return [[[MKNodeField alloc] initWithName:name description:description value:valueRecipe] autorelease];
}

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)nodeFieldWithProperty:(NSString*)property description:(NSString*)description
{ return [self nodeFieldWithName:property keyPath:property description:description]; }

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)nodeFieldWithProperty:(NSString*)property
{ return [self nodeFieldWithProperty:property description:nil]; }

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithName:(NSString*)name description:(NSString*)description value:(id<MKNodeFieldRecipe>)valueRecipe
{
    self = [super init];
    if (self == nil) return nil;
    
    _name = [name copy];
    _description = [description copy];
    
    _valueRecipe = [valueRecipe retain];
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)init
{ @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"-init unavailable." userInfo:nil]; }

//|++++++++++++++++++++++++++++++++++++|//
- (void)dealloc
{
    [_name release];
    [_description release];
    [_valueRecipe release];
    [super dealloc];
}

//|++++++++++++++++++++++++++++++++++++|//
- (NSString*)formattedDescriptionForNode:(MKNode*)node
{ return [[_valueRecipe valueForNode:node] description]; }

@end
