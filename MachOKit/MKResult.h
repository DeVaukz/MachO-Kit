//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       MKResult.h
//!
//! @author     D.V.
//! @copyright  Copyright (c) 2014-2015 D.V. All rights reserved.
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

#import <MachOKit/MKBase.h>

NS_ASSUME_NONNULL_BEGIN

//----------------------------------------------------------------------------//
//! A type that can represent either none, a value, or an error.
//!
@interface MKResult<ObjectType> : NSObject {
@package
    id _value;
}

//! Creates and returns a result with no value.
//!
//! A result with no value and no error indicates an operation was sucessful,
//! but has no data to return.  For example, a search completed without any
//! errors but did not find a match.
+ (instancetype)result;

//! Creates and returns a result with the provided \a value.
+ (instancetype)resultWithValue:(ObjectType)value;

//! Creates and returns a result with the provided \a error.
+ (instancetype)resultWithError:(NSError*)error;

//! Creates and returns a new optional with the result of invoking \a builder.
//!
//! @important
//! This method expects \a builder to return an object at a +1 retain count.
+ (instancetype)newResultWith:(NS_NOESCAPE NS_RETURNS_RETAINED ObjectType __nullable (^)(NSError **error))builder NS_RETURNS_RETAINED;

//! Initializes the receiver with no value.
- (instancetype)init;

//! Initializes the receiver with the provided \a value.
- (instancetype)initWithValue:(ObjectType)value;

//! Initializes the receiver with the provided \a error.
- (instancetype)initWithError:(NSError*)error;

//! \c YES if the result is empty - does not contain a value and does not
//! contain an error.
@property (readonly) BOOL none;

//! The result value.
@property (readonly, nullable) ObjectType value;

//! If \c value is \c nil, an error describing why no value could be provided.
@property (readonly, nullable) NSError *error;

@end



//----------------------------------------------------------------------------//
@interface MKResult<ObjectType> (Deprecated)

//! Creates and returns a result with no value.
+ (instancetype)optional __attribute__((deprecated("Use +result.")));

//! Creates and returns a result with the provided \a value.
+ (instancetype)optionalWithValue:(ObjectType)value __attribute__((deprecated("Use +resultWithValue:.")));

//! Creates and returns a result with the provided \a error.
+ (instancetype)optionalWithError:(NSError*)error __attribute__((deprecated("Use +resultWithError:.")));

@end

@compatibility_alias MKOptional MKResult;

NS_ASSUME_NONNULL_END
