//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       MKOptional.h
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

#include <MachOKit/macho.h>
@import Foundation;

NS_ASSUME_NONNULL_BEGIN

//----------------------------------------------------------------------------//
//! A type that can represent either none, a value, or an error.
//!
@interface MKOptional<ObjectType> : NSObject {
@package
    id _value;
}

//! Creates and returns a new optional with no value.
+ (instancetype)optional;

//! Creates and returns a new optional with the provided \a value.
+ (instancetype)optionalWithValue:(ObjectType)value;

//! Creates and returns a new optional with the provided \a error.
+ (instancetype)optionalWithError:(NSError*)error;

//! Initializes the receiver with no value.
- (instancetype)init;

//! Initializes the receiver with the provided \a value.
- (instancetype)initWithValue:(ObjectType)value;

//! Initializes the receiver with the provided \a error.
- (instancetype)initWithError:(NSError*)error;

//! \c YES if the optional is empty - does not contain a value and does not
//! contain an error.
@property (readonly) BOOL none;

//!
@property (readonly, nullable) ObjectType value;

//! If \c value is \c nil, an error describing why no value could be provided.
@property (readonly, nullable) NSError *error;

@end

NS_ASSUME_NONNULL_END
