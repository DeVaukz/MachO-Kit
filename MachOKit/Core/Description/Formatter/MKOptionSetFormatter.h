//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       MKOptionSetFormatter.h
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

typedef NSDictionary<NSNumber*, NSString*> MKOptionSetFormatterOptions;

//----------------------------------------------------------------------------//
//! @name       Option Set Formatter Behavior For Zero Values
//! @relates    MKOptionSetFormatterZeroBehavior
//!
typedef NS_ENUM(NSUInteger, MKOptionSetFormatterZeroBehavior) {
    //! Return the string "0".  The default behavior.
    MKOptionSetFormatterZeroBehaviorZeroString      = 0,
    //! Return an empty string.
    MKOptionSetFormatterZeroBehaviorEmptyString,
    //! Return \c nil.
    MKOptionSetFormatterZeroBehaviorNil
};



//----------------------------------------------------------------------------//
@interface MKOptionSetFormatter : NSFormatter {
@package
    MKOptionSetFormatterOptions *_options;
    MKOptionSetFormatterZeroBehavior _zeroBehavior;
    BOOL _partialMatching;
}

+ (instancetype)optionSetFormatterWithOptions:(nullable MKOptionSetFormatterOptions*)options;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Configuring Formatter Behavior
//! @name       Configuring Formatter Behavior
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//!
@property (nonatomic, copy, nullable) MKOptionSetFormatterOptions *options;

//! The behavior when the formatter encounters a zero value.  Only applicable
//! if the options dictionary does not define a value for zero.
@property (nonatomic, readwrite) MKOptionSetFormatterZeroBehavior zeroBehavior;

//! If \c YES, an option is considered to be present if
//! (value & optionMask) != 0
//! If \c NO (default), an option is considered to be present if
//! (value & optionMask) == optionMask
@property (nonatomic, readwrite) BOOL partialMatching;

@end

NS_ASSUME_NONNULL_END
