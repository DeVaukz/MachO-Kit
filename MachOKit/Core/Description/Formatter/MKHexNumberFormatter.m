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

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)hexNumberFormatterWithDigits:(size_t)digits uppercase:(BOOL)uppercase
{
    MKHexNumberFormatter *retValue = [[[self alloc] init] autorelease];
    retValue.digits = digits;
    retValue.uppercase = uppercase;
    
    return retValue;
}

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)hexNumberFormatterWithDigits:(size_t)digits
{
    return [self hexNumberFormatterWithDigits:digits uppercase:NO];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  NSCoding
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithCoder:(NSCoder*)aDecoder
{
    self = [super init];
    if (self == nil) return nil;
    
    _digits = (size_t)[aDecoder decodeIntegerForKey:@"digits"];
    _uppercase = [aDecoder decodeBoolForKey:@"uppercase"];
    _omitPrefix = [aDecoder decodeBoolForKey:@"omitPrefix"];
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (void)encodeWithCoder:(NSCoder*)aCoder
{
    [aCoder encodeInteger:(NSInteger)self.digits forKey:@"digits"];
    [aCoder encodeBool:self.uppercase forKey:@"uppercase"];
    [aCoder encodeBool:self.omitPrefix forKey:@"omitPrefix"];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  NSCopying
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (id)copyWithZone:(NSZone*)zone
{
    MKHexNumberFormatter *copy = [[MKHexNumberFormatter allocWithZone:zone] init];
    copy.digits = self.digits;
    copy.uppercase = self.uppercase;
    copy.omitPrefix = self.omitPrefix;
    
    return copy;
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Configuring Formatter Behavior
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@synthesize digits = _digits;
@synthesize uppercase = _uppercase;
@synthesize omitPrefix = _omitPrefix;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  NSFormatter
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (NSString*)stringForObjectValue:(NSNumber*)anObject
{
    if (anObject == nil)
        return nil;
    if ([anObject isKindOfClass:NSNumber.class] == NO)
        return @"<Not a number>";

#define MAKE_FORMAT_STRING(MODIFIERS, LOWERCASE, UPPERCASE) ({ \
    BOOL uppercase = self.uppercase; \
    BOOL prefix = !self.omitPrefix; \
    NSString * format; \
    \
    if (uppercase && prefix) format = @("0x" MODIFIERS UPPERCASE); \
    else if (uppercase && !prefix) format = @(MODIFIERS UPPERCASE); \
    else if (!uppercase && prefix) format = @("0x" MODIFIERS LOWERCASE); \
    else /*if (!uppercase && !prefix)*/ format = @(MODIFIERS LOWERCASE); \
    \
    format; \
})
    
    if (_digits == SIZE_T_MAX) {
        const char *objcType = [anObject objCType];
        
        switch (*objcType) {
            case 'c':
            case 'C':
                return [NSString stringWithFormat:MAKE_FORMAT_STRING("%0*hh", "x", "X"), 2, [anObject unsignedCharValue]];
            case 's':
            case 'S':
                return [NSString stringWithFormat:MAKE_FORMAT_STRING("%0*h", "x", "X"), 4, [anObject unsignedShortValue]];
            case 'i':
            case 'I':
                return [NSString stringWithFormat:MAKE_FORMAT_STRING("%0*", "x", "X"), 8, [anObject unsignedIntValue]];
            default:
                return [NSString stringWithFormat:MAKE_FORMAT_STRING("%0*ll", "x", "X"), 16, [anObject unsignedLongLongValue]];
        }
    } else if (_digits == 0)
        return [NSString stringWithFormat:MAKE_FORMAT_STRING("%ll", "x", "X"), [anObject unsignedLongLongValue]];
    else
        return [NSString stringWithFormat:MAKE_FORMAT_STRING("%0*ll", "x", "X"), (int)_digits, [anObject unsignedLongLongValue]];

#undef MAKE_FORMAT_STRING
}

@end
