//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       MKFormattedNodeField.h
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

#import <MachOKit/MKNodeField.h>

NS_ASSUME_NONNULL_BEGIN

//----------------------------------------------------------------------------//
//! @name       Node Field Format
//! @relates    MKFormattedNodeField
//!
typedef NS_ENUM(NSUInteger, MKNodeFieldFormat) {
    //! Format the value of this field as a decimal number.
    MKNodeFieldFormatDecimal        = 0,
    //! Format the value of this field as a hexadecimal number.
    MKNodeFieldFormatHex,
    //! Format the value of this field as a hexadecimal number, without any
    //! leading zeros.
    MKNodeFieldFormatHexCompact,
    //! Alias for formatting addresses.
    MKNodeFieldFormatAddress        = MKNodeFieldFormatHex,
    //! Alias for formatting sizes
    MKNodeFieldFormatSize           = MKNodeFieldFormatDecimal,
    //! Alias for formatting offsets
    MKNodeFieldFormatOffset         = MKNodeFieldFormatHexCompact
};



//----------------------------------------------------------------------------//
@interface MKFormattedNodeField : MKNodeField {
@package
    NSFormatter *_valueFormatter;
}

+ (instancetype)fieldWithName:(NSString*)name keyPath:(NSString*)keyPath description:(nullable NSString*)description format:(MKNodeFieldFormat)format;
+ (instancetype)fieldWithProperty:(NSString*)property description:(nullable NSString*)description format:(MKNodeFieldFormat)format;

- (instancetype)initWithName:(NSString*)name description:(nullable NSString*)description value:(id<MKNodeFieldRecipe>)valueRecipe formatter:(nullable NSFormatter*)valueFormatter;

//! The formatter used to format the value of this field.
@property (nonatomic, readonly, nullable) NSFormatter *valueFormatter;

@end

NS_ASSUME_NONNULL_END
