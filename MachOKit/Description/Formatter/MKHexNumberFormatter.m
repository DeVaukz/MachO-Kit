//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKHexNumberFormatter.m
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

#import "MKHexNumberFormatter.h"

//----------------------------------------------------------------------------//
@implementation MKHexNumberFormatter

@synthesize digits = _digits;

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)hexNumberFormatterWithDigits:(size_t)digits
{
    MKHexNumberFormatter *retValue = [[[self alloc] init] autorelease];
    retValue.digits = digits;
    return retValue;
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  NSFormatter
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (NSString*)stringForObjectValue:(NSNumber*)anObject
{
    if ([anObject isKindOfClass:NSNumber.class] == NO)
        return @"<Not a number>";
    
    if (_digits == SIZE_T_MAX) {
        const char *objcType = [anObject objCType];
        
        switch (*objcType) {
            case 'c':
            case 'C':
                return [NSString stringWithFormat:@"0x%0*hhx", 2, [anObject unsignedCharValue]];
            case 's':
            case 'S':
                return [NSString stringWithFormat:@"0x%0*hx", 2, [anObject unsignedShortValue]];
            case 'i':
            case 'I':
                return [NSString stringWithFormat:@"0x%0*x", 2, [anObject unsignedIntValue]];
            default:
                return [NSString stringWithFormat:@"0x%0*llx", 2, [anObject unsignedLongLongValue]];
        }
    } else if (_digits == 0)
        return [NSString stringWithFormat:@"0x%llx", [anObject unsignedLongLongValue]];
    else
        return [NSString stringWithFormat:@"0x%0*llx", (int)_digits, [anObject unsignedLongLongValue]];
}

@end
