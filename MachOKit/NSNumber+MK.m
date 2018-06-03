//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             NSNumber+MK.m
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

#import "NSNumber+MK.h"
#import "MKInternal.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"

#define MKMakeUnsignedNSNumberSubclass(NAME, TYPE, ENCODING) \
    @interface __MKUnsigned ## NAME ## Number : NSNumber { unsigned TYPE _v; } \
    @end\
    @implementation __MKUnsigned ## NAME ## Number \
    - (id)initWithUnsigned ## NAME :(unsigned TYPE)value { if (self) _v = value; return self; } \
    - (id)copyWithZone:(__unused NSZone*)zone { return [self retain]; } \
    - (unsigned TYPE)unsigned ## NAME ## Value { return _v; } \
    - (const char*)objCType { return ENCODING; } \
    @end

MKMakeUnsignedNSNumberSubclass(Char, char, "C")
MKMakeUnsignedNSNumberSubclass(Short, short, "S")
MKMakeUnsignedNSNumberSubclass(Int, int, "I")
MKMakeUnsignedNSNumberSubclass(LongLong, long long, "Q")

#pragma clang diagnostic pop

//----------------------------------------------------------------------------//
@implementation NSNumber (MK)

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Creating an NSNumber Object
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
+ (NSNumber*)mk_numberWithByte:(int8_t)value
{ return [NSNumber numberWithChar:value]; }

//|++++++++++++++++++++++++++++++++++++|//
+ (NSNumber*)mk_numberWithUnsignedByte:(uint8_t)value
{ return [[[__MKUnsignedCharNumber alloc] initWithUnsignedChar:value] autorelease]; }

//|++++++++++++++++++++++++++++++++++++|//
+ (NSNumber*)mk_numberWithWord:(int16_t)value
{ return [NSNumber numberWithShort:value]; }

//|++++++++++++++++++++++++++++++++++++|//
+ (NSNumber*)mk_numberWithUnsignedWord:(uint16_t)value
{ return [[[__MKUnsignedShortNumber alloc] initWithUnsignedShort:value] autorelease]; }

//|++++++++++++++++++++++++++++++++++++|//
+ (NSNumber*)mk_numberWithDoubleWord:(int32_t)value
{ return [NSNumber numberWithInt:value]; }

//|++++++++++++++++++++++++++++++++++++|//
+ (NSNumber*)mk_numberWithUnsignedDoubleWord:(uint32_t)value
{ return [[[__MKUnsignedIntNumber alloc] initWithUnsignedInt:value] autorelease]; }

//|++++++++++++++++++++++++++++++++++++|//
+ (NSNumber*)mk_numberWithQuadWord:(int64_t)value
{ return [NSNumber numberWithLongLong:value]; }

//|++++++++++++++++++++++++++++++++++++|//
+ (NSNumber*)mk_numberWithUnsignedQuadWord:(uint64_t)value
{ return [[[__MKUnsignedLongLongNumber alloc] initWithUnsignedLongLong:value] autorelease]; }

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Accessing Numeric Values
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (uint64_t)mk_UnsignedValue:(size_t*)bitsOut
{
#define MK_BITS_OUT if (bitsOut) *bitsOut
    switch (*[self objCType]) {
        case 'c':
        case 'C':
            MK_BITS_OUT = sizeof(uint8_t) * 8;
            return (uint64_t)[self unsignedCharValue];
        case 's':
        case 'S':
            MK_BITS_OUT = sizeof(uint16_t) * 8;
            return (uint64_t)[self unsignedShortValue];
        case 'i':
        case 'I':
            MK_BITS_OUT = sizeof(uint32_t) * 8;
            return (uint64_t)[self unsignedIntValue];
        case 'q':
        case 'Q':
            MK_BITS_OUT = sizeof(uint64_t) * 8;
            return (uint64_t)[self unsignedLongLongValue];
        default:
        {
            NSString *reason = [NSString stringWithFormat:@"-mk_UnsignedIntegerValue: called on NSNumber with unsupported type [%s].", self.objCType];
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:nil];
        }
    }
#undef MK_BITS_OUT
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Bitwise Operations
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (NSNumber*)mk_maskUsing:(NSNumber*)mask
{
    uint64_t m = [mask mk_UnsignedValue:NULL];
    
    uint64_t value;
    switch (*[self objCType]) {
        case 'c':
        case 'C':
            value = (uint64_t)[self unsignedCharValue];
            value &= m;
            return [NSNumber mk_numberWithUnsignedByte:(uint8_t)value];
        case 's':
        case 'S':
            value = (uint64_t)[self unsignedShortValue];
            value &= m;
            return [NSNumber mk_numberWithUnsignedWord:(uint16_t)value];
        case 'i':
        case 'I':
            value = (uint64_t)[self unsignedIntValue];
            value &= m;
            return [NSNumber mk_numberWithUnsignedDoubleWord:(uint32_t)value];
        case 'q':
        case 'Q':
            value = (uint64_t)[self unsignedLongLongValue];
            value &= m;
            return [NSNumber mk_numberWithUnsignedQuadWord:(uint64_t)value];
        default:
        {
            NSString *reason = [NSString stringWithFormat:@"-mk_maskUsing: called on NSNumber with unsupported type [%s].", self.objCType];
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:nil];
        }
    }
}

//|++++++++++++++++++++++++++++++++++++|//
- (NSNumber*)mk_shift:(int)shift
{
    uint64_t value;
    switch (*[self objCType]) {
        case 'c':
        case 'C':
            value = (uint64_t)[self unsignedCharValue];
            value = shift > 0 ? value << shift : value >> -shift;
            return [NSNumber mk_numberWithUnsignedByte:(uint8_t)value];
        case 's':
        case 'S':
            value = (uint64_t)[self unsignedShortValue];
            value = shift > 0 ? value << shift : value >> -shift;
            return [NSNumber mk_numberWithUnsignedWord:(uint16_t)value];
        case 'i':
        case 'I':
            value = (uint64_t)[self unsignedIntValue];
            value = shift > 0 ? value << shift : value >> -shift;
            return [NSNumber mk_numberWithUnsignedDoubleWord:(uint32_t)value];
        case 'q':
        case 'Q':
            value = (uint64_t)[self unsignedLongLongValue];
            value = shift > 0 ? value << shift : value >> -shift;
            return [NSNumber mk_numberWithUnsignedQuadWord:(uint64_t)value];
        default:
        {
            NSString *reason = [NSString stringWithFormat:@"-mk_shift: called on NSNumber with unsupported type [%s].", self.objCType];
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:nil];
        }
    }
}

@end
