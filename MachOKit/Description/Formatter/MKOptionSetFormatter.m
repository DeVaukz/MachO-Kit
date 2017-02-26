//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKOptionSetFormatter.m
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

#import "MKOptionSetFormatter.h"

//----------------------------------------------------------------------------//
@implementation MKOptionSetFormatter

@synthesize options = _options;

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)optionSetFormatterWithOptions:(NSDictionary*)options
{
    MKOptionSetFormatter *retValue = [self new];
    retValue.options = options;
    return [retValue autorelease];
}

//|++++++++++++++++++++++++++++++++++++|//
- (void)dealloc
{
    [_options release];
    
    [super dealloc];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  NSFormatter
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (NSString*)stringForObjectValue:(NSNumber*)anObject
{
    if ([anObject isKindOfClass:NSNumber.class] == NO)
        return nil;
    
    uint64_t value = [anObject unsignedLongLongValue];
    
    // Special case the 0 value
    if (value == 0) {
        if (_options[@(0)])
            return _options[@(0)];
        else
            return 0;
    }
    
    size_t bits;
    switch (*[anObject objCType]) {
        case 'c':
        case 'C':
            bits = sizeof(uint8_t) * 8;
            break;
        case 's':
        case 'S':
            bits = sizeof(uint16_t) * 8;
            break;
        case 'i':
        case 'I':
            bits = sizeof(uint32_t) * 8;
            break;
        case 'q':
        case 'Q':
            bits = sizeof(uint64_t) * 8;
            break;
        default:
            return nil;
    }
    
    NSMutableString *retValue = [NSMutableString string];
    uint64_t maskedBits = 0;
    
    for (NSNumber *maskValue in _options) {
        uint64_t mask = maskValue.unsignedLongLongValue;
        
        if (mask == 0x0)
            continue;
        
        if ((value & mask) == mask) {
            maskedBits |= mask;
            if (retValue.length != 0) [retValue appendString:@" "];
            [retValue appendString:_options[maskValue]];
        }
    }
    
    value &= (~maskedBits);
    
    for (unsigned i=0; i<bits; i++) {
        if (value & (1<<i)) {
            if (retValue.length != 0) [retValue appendString:@" "];
            [retValue appendFormat:@"(1<<%u)", i];
        }
    }
    
    return retValue;
}

@end
