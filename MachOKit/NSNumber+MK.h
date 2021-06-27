//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       NSNumber+MK.h
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
//! Mach-O Kit extensions to \c NSNumber.
//!
@interface NSNumber (MK)

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Creating an NSNumber Object
//! @name       Creating an NSNumber Object
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//! Creates and returns an NSNumber object containing a given value, treating
//! it as a \c int8_t.
+ (NSNumber*)mk_numberWithByte:(int8_t)value;

//! Creates and returns an NSNumber object containing a given value, treating
//! it as a \c uint8_t.
+ (NSNumber*)mk_numberWithUnsignedByte:(uint8_t)value;

//! Creates and returns an NSNumber object containing a given value, treating
//! it as a \c int16_t.
+ (NSNumber*)mk_numberWithWord:(int16_t)value;

//! Creates and returns an NSNumber object containing a given value, treating
//! it as a \c uint16_t.
+ (NSNumber*)mk_numberWithUnsignedWord:(uint16_t)value;

//! Creates and returns an NSNumber object containing a given value, treating
//! it as a \c int32_t.
+ (NSNumber*)mk_numberWithDoubleWord:(int32_t)value;

//! Creates and returns an NSNumber object containing a given value, treating
//! it as a \c uint32_t.
+ (NSNumber*)mk_numberWithUnsignedDoubleWord:(uint32_t)value;

//! Creates and returns an NSNumber object containing a given value, treating
//! it as a \c int64_t.
+ (NSNumber*)mk_numberWithQuadWord:(int64_t)value;

//! Creates and returns an NSNumber object containing a given value, treating
//! it as a \c uint64_t.
+ (NSNumber*)mk_numberWithUnsignedQuadWord:(uint64_t)value;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Accessing Numeric Values
//! @name       Accessing Numeric Values
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

- (uint64_t)mk_UnsignedValue:(size_t* _Nullable)bitsOut;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Bitwise Operations
//! @name       Bitwise Operations
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//! Performs a bitwise AND of the receiver and \a mask and returns a new
//! \c NSNumber containing the result.  The returned \c NSNumber has the
//! same underlying type as the receiver.
- (NSNumber*)mk_maskUsing:(NSNumber*)mask;

//! Performs a bitwise shift of the receiver and returns a new \c NSNumber
//! containing the result.  A negative \a shift specifies a right shift.
//! A positive \a shift specifies a left shift.  The returned \c NSNumber has
//! the same underlying type as the receiver.
- (NSNumber*)mk_shift:(int)shift;

@end

NS_ASSUME_NONNULL_END
