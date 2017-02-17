//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKNodeFieldOperationReturnConstant.m
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

#import "MKNodeFieldOperationReturnConstant.h"
#import "MKNode.h"

//----------------------------------------------------------------------------//
@implementation MKNodeFieldOperationReturnConstant

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithConstant:(id)constant ofType:(NSString*)type
{
    self = [super init];
    if (self == nil) return nil;
    
    _constant = [constant retain];
    _type = [type copy];
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithConstant:(id)constant
{ return [self initWithConstant:constant ofType:nil]; }

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)init
{ return [self initWithConstant:nil]; }

//|++++++++++++++++++++++++++++++++++++|//
- (void)dealloc
{
    [_constant release];
    [_type release];
    
    [super dealloc];
}

//|++++++++++++++++++++++++++++++++++++|//
- (NSString*)typeOfField:(__unused MKNodeField*)field ofNode:(__unused MKNode*)input
{ return _type; }

//|++++++++++++++++++++++++++++++++++++|//
- (id)valueForField:(__unused MKNodeField*)field ofNode:(__unused MKNode*)input
{ return _constant; }

@end
