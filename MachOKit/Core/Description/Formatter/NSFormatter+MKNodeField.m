//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             NSFormatter+MKNodeField.m
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

#import "NSFormatter+MKNodeField.h"

//----------------------------------------------------------------------------//
@implementation NSFormatter (MKNodeField)

//|++++++++++++++++++++++++++++++++++++|//
+ (NSFormatter*)mk_objectFormatter
{
    static MKObjectFormatter *s_ObjectFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_ObjectFormatter = [MKObjectFormatter new];
    });
    
    return s_ObjectFormatter;
}

//|++++++++++++++++++++++++++++++++++++|//
+ (NSFormatter*)mk_stringFormatter
{
    static MKStringFormatter *s_StringFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_StringFormatter = [MKStringFormatter new];
    });
    
    return s_StringFormatter;
}

//|++++++++++++++++++++++++++++++++++++|//
+ (NSFormatter*)mk_booleanFormatter
{
    static MKBooleanFormatter *s_BooleanFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_BooleanFormatter = [MKBooleanFormatter new];
    });
    
    return s_BooleanFormatter;
}

//|++++++++++++++++++++++++++++++++++++|//
+ (NSFormatter*)mk_decimalNumberFormatter
{
    static NSNumberFormatter *s_DecimalNumberFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_DecimalNumberFormatter = [NSNumberFormatter new];
        s_DecimalNumberFormatter.numberStyle = NSNumberFormatterNoStyle;
    });
    
    return s_DecimalNumberFormatter;
}

//|++++++++++++++++++++++++++++++++++++|//
+ (NSFormatter*)mk_hexFormatter
{
    static MKHexNumberFormatter *s_HexFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_HexFormatter = [[MKHexNumberFormatter hexNumberFormatterWithDigits:SIZE_T_MAX] retain];
    });
    
    return s_HexFormatter;
}

//|++++++++++++++++++++++++++++++++++++|//
+ (NSFormatter*)mk_hex8Formatter
{
    static MKHexNumberFormatter *s_Hex8Formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_Hex8Formatter = [[MKHexNumberFormatter hexNumberFormatterWithDigits:2] retain];
    });
    
    return s_Hex8Formatter;
}

//|++++++++++++++++++++++++++++++++++++|//
+ (NSFormatter*)mk_hex16Formatter
{
    static MKHexNumberFormatter *s_Hex16Formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_Hex16Formatter = [[MKHexNumberFormatter hexNumberFormatterWithDigits:4] retain];
    });
    
    return s_Hex16Formatter;
}

//|++++++++++++++++++++++++++++++++++++|//
+ (NSFormatter*)mk_hex32Formatter
{
    static MKHexNumberFormatter *s_Hex32Formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_Hex32Formatter = [[MKHexNumberFormatter hexNumberFormatterWithDigits:8] retain];
    });
    
    return s_Hex32Formatter;
}

//|++++++++++++++++++++++++++++++++++++|//
+ (NSFormatter*)mk_hex64Formatter
{
    static MKHexNumberFormatter *s_Hex64Formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_Hex64Formatter = [[MKHexNumberFormatter hexNumberFormatterWithDigits:16] retain];
    });
    
    return s_Hex64Formatter;
}

//|++++++++++++++++++++++++++++++++++++|//
+ (NSFormatter*)mk_uppercaseHexFormatter
{
    static MKHexNumberFormatter *s_UppercaseHexFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_UppercaseHexFormatter = [[MKHexNumberFormatter hexNumberFormatterWithDigits:SIZE_T_MAX uppercase:YES] retain];
    });
    
    return s_UppercaseHexFormatter;
}

//|++++++++++++++++++++++++++++++++++++|//
+ (NSFormatter*)mk_uppercaseHex8Formatter
{
    static MKHexNumberFormatter *s_UppercaseHex8Formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_UppercaseHex8Formatter = [[MKHexNumberFormatter hexNumberFormatterWithDigits:2 uppercase:YES] retain];
    });
    
    return s_UppercaseHex8Formatter;
}

//|++++++++++++++++++++++++++++++++++++|//
+ (NSFormatter*)mk_uppercaseHex16Formatter
{
    static MKHexNumberFormatter *s_UppercaseHex16Formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_UppercaseHex16Formatter = [[MKHexNumberFormatter hexNumberFormatterWithDigits:4 uppercase:YES] retain];
    });
    
    return s_UppercaseHex16Formatter;
}

//|++++++++++++++++++++++++++++++++++++|//
+ (NSFormatter*)mk_uppercaseHex32Formatter
{
    static MKHexNumberFormatter *s_UppercaseHex32Formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_UppercaseHex32Formatter = [[MKHexNumberFormatter hexNumberFormatterWithDigits:8 uppercase:YES] retain];
    });
    
    return s_UppercaseHex32Formatter;
}

//|++++++++++++++++++++++++++++++++++++|//
+ (NSFormatter*)mk_uppercaseHex64Formatter
{
    static MKHexNumberFormatter *s_UppercaseHex64Formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_UppercaseHex64Formatter = [[MKHexNumberFormatter hexNumberFormatterWithDigits:16 uppercase:YES] retain];
    });
    
    return s_UppercaseHex64Formatter;
}

//|++++++++++++++++++++++++++++++++++++|//
+ (NSFormatter*)mk_hexCompactFormatter
{
    static MKHexNumberFormatter *s_HexCompactFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_HexCompactFormatter = [[MKHexNumberFormatter hexNumberFormatterWithDigits:0] retain];
    });
    
    return s_HexCompactFormatter;
}

//|++++++++++++++++++++++++++++++++++++|//
+ (NSFormatter*)mk_uppercaseHexCompactFormatter
{
    static MKHexNumberFormatter *s_UppercaseHexCompactFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_UppercaseHexCompactFormatter = [[MKHexNumberFormatter hexNumberFormatterWithDigits:0 uppercase:YES] retain];
    });
    
    return s_UppercaseHexCompactFormatter;
}

//|++++++++++++++++++++++++++++++++++++|//
+ (NSFormatter*)mk_AddressFormatter
{
    return [self mk_hexFormatter];
}

//|++++++++++++++++++++++++++++++++++++|//
+ (NSFormatter*)mk_SizeFormatter
{
    return [self mk_decimalNumberFormatter];
}

//|++++++++++++++++++++++++++++++++++++|//
+ (NSFormatter*)mk_OffsetFormatter
{
    return [self mk_decimalNumberFormatter];
}

@end
