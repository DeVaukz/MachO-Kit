//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       MKHexNumberFormatter.h
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

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

//----------------------------------------------------------------------------//
//! An instance of \c MKHexNumberFormatter formats the textual representation
//! of NSNumber objects in hexadecimal notation.
//
@interface MKHexNumberFormatter : NSFormatter {
@package
    size_t _digits;
    BOOL _uppercase;
    BOOL _omitPrefix;
}

//! Returns a formatter that formats an input NSNumber in hexadecimal
//! representation, padding the resulting string with up to \a digits
//! preceeding zeros.
//!
//! @param  digits
//!         Pass zero for no padding.  Pass SIZE_T_MAX for padding up to the
//!         natural length of the underlying type of the NSNumber.
+ (instancetype)hexNumberFormatterWithDigits:(size_t)digits uppercase:(BOOL)uppercase;

+ (instancetype)hexNumberFormatterWithDigits:(size_t)digits;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Configuring Formatter Behavior
//! @name       Configuring Formatter Behavior
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//! The minimum number of digits to include in the formatted string.
@property (nonatomic, readwrite) size_t digits;

//!
@property (nonatomic, readwrite) BOOL uppercase;

//! If \c YES, the standard hexadecimal prefix (0x) will not be included in the
//! formatted string.
@property (nonatomic, readwrite) BOOL omitPrefix;

@end

NS_ASSUME_NONNULL_END
