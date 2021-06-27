//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKResult.m
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

#import "MKResult.h"

extern void OBJC_CLASS_$_MKResult;

//----------------------------------------------------------------------------//
@implementation MKResult

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)result
{
    static MKResult *kResultNone = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kResultNone = [self new];
    });
    
    return kResultNone;
}

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)resultWithValue:(id)value
{ return [[[self alloc] initWithValue:value] autorelease]; }

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)resultWithError:(NSError*)error
{ return [[[self alloc] initWithError:error] autorelease]; }

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)newResultWith:(NS_NOESCAPE id (^)(NSError **error))builder
{
    NSError *error = nil;
    id object = builder(&error);
    
    MKResult *result;
    
    if (self == &OBJC_CLASS_$_MKResult) {
        // Optimization - Bypass the -initWith: call.
        result = [MKResult new];
        if (object)
            result->_value = object;
        else if (error /* Only fail if we have an error */)
            result->_value = [error retain];
        
    } else {
        if (object)
            result = [[self alloc] initWithValue:object];
        else if (error /* Only fail if we have an error */)
            result = [[self alloc] initWithError:error];
        else
            result = [self new];
        
        [object release];
    }
    
    return result;
}

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
    if (self.none && [object isKindOfClass:MKResult.class] && [object none])
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



//----------------------------------------------------------------------------//
@implementation MKResult (Deprecated)

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)optional
{ return [self result]; }

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)optionalWithValue:(id)value
{ return [self resultWithValue:value]; }

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)optionalWithError:(NSError*)error
{ return [self resultWithError:error]; }

@end
