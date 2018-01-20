//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKOptional.m
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

#import "MKOptional.h"

//----------------------------------------------------------------------------//
@implementation MKOptional

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)optional
{
    static MKOptional *kOptionalNone = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kOptionalNone = [self new];
    });
    
    return kOptionalNone;
}

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)optionalWithValue:(id)value
{ return [[[self alloc] initWithValue:value] autorelease]; }

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)optionalWithError:(NSError*)error
{ return [[[self alloc] initWithError:error] autorelease]; }

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)init
{
    self = [super init];
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithValue:(id)value
{
    self = [super init];
    
    self->_value = [value retain];
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithError:(NSError*)error
{
    self = [super init];
    
    self->_value = [error retain];
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (void)dealloc
{
    [_value release];
    
    [super dealloc];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Values
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (BOOL)none
{
    return (_value == nil);
}

//|++++++++++++++++++++++++++++++++++++|//
- (id)value
{
    if ([_value isKindOfClass:NSError.class] == NO)
        return _value;
    else
        return nil;
}

//|++++++++++++++++++++++++++++++++++++|//
- (NSError*)error
{
    if ([_value isKindOfClass:NSError.class])
        return _value;
    else
        return nil;
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  NSObject
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (BOOL)isEqual:(id)object
{
    if (self.none && [object isKindOfClass:MKOptional.class] && [object none])
        return YES;
    else
        return [_value isEqual:object];
}

//|++++++++++++++++++++++++++++++++++++|//
- (NSString*)description
{
    return [self.value description];
}

@end
