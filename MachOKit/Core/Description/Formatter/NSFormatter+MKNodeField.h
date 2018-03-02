//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       NSFormatter+MKNodeField.h
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

#import <MachOKit/MKFormatterChain.h>
#import <MachOKit/MKComboFormatter.h>
#import <MachOKit/MKObjectFormatter.h>
#import <MachOKit/MKStringFormatter.h>
#import <MachOKit/MKBooleanFormatter.h>
#import <MachOKit/MKHexNumberFormatter.h>
#import <MachOKit/MKEnumerationFormatter.h>
#import <MachOKit/MKOptionSetFormatter.h>
#import <MachOKit/MKBitfieldFormatter.h>

NS_ASSUME_NONNULL_BEGIN

//----------------------------------------------------------------------------//
@interface NSFormatter (MKNodeField)

+ (NSFormatter*)mk_objectFormatter;
+ (NSFormatter*)mk_stringFormatter;

+ (NSFormatter*)mk_booleanFormatter;

+ (NSFormatter*)mk_decimalNumberFormatter;

+ (NSFormatter*)mk_hexFormatter;
+ (NSFormatter*)mk_hex8Formatter;
+ (NSFormatter*)mk_hex16Formatter;
+ (NSFormatter*)mk_hex32Formatter;
+ (NSFormatter*)mk_hex64Formatter;

+ (NSFormatter*)mk_uppercaseHexFormatter;
+ (NSFormatter*)mk_uppercaseHex8Formatter;
+ (NSFormatter*)mk_uppercaseHex16Formatter;
+ (NSFormatter*)mk_uppercaseHex32Formatter;
+ (NSFormatter*)mk_uppercaseHex64Formatter;

+ (NSFormatter*)mk_hexCompactFormatter;
+ (NSFormatter*)mk_uppercaseHexCompactFormatter;

+ (NSFormatter*)mk_AddressFormatter;
+ (NSFormatter*)mk_SizeFormatter;
+ (NSFormatter*)mk_OffsetFormatter;

@end

NS_ASSUME_NONNULL_END
