//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKNodeFieldRecipe.m
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

#import "MKNodeFieldRecipe.h"
#import "MKNode.h"

//----------------------------------------------------------------------------//
@implementation _MKNodeFieldOperationReadKey

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithKey:(NSString*)key
{
    self = [super init];
    if (self == nil) return nil;
    
    _key = [key copy];
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (void)dealloc
{
    [_key release];
    [super dealloc];
}

//|++++++++++++++++++++++++++++++++++++|//
- (id)valueForNode:(MKNode*)input
{
    if (_key)
        return [input valueForKeyPath:_key];
    else
        return nil;
}

@end



//----------------------------------------------------------------------------//
@implementation _MKNodeFieldOperationConstant

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithValue:(id)value
{
    self = [super init];
    if (self == nil) return nil;
    
    _value = [value retain];
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (void)dealloc
{
    [_value release];
    [super dealloc];
}

//|++++++++++++++++++++++++++++++++++++|//
- (id)valueForNode:(__unused MKNode*)input
{ return _value; }

@end
