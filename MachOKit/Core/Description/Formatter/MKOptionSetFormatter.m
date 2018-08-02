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
#import "NSNumber+MK.h"

//----------------------------------------------------------------------------//
@implementation MKOptionSetFormatter

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
#pragma mark -  NSCoding
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithCoder:(NSCoder*)aDecoder
{
    self = [super init];
    if (self == nil) return nil;
    
    _options = [[aDecoder decodeObjectOfClass:NSDictionary.class forKey:@"options"] retain];
    _zeroBehavior = (NSUInteger)[aDecoder decodeIntegerForKey:@"zeroBehavior"];
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (void)encodeWithCoder:(NSCoder*)aCoder
{
    [aCoder encodeObject:self.options forKey:@"options"];
    [aCoder encodeInteger:self.zeroBehavior forKey:@"zeroBehavior"];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  NSCopying
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (id)copyWithZone:(NSZone*)zone
{
    MKOptionSetFormatter *copy = [[MKOptionSetFormatter allocWithZone:zone] init];
    copy.options = self.options;
    copy.zeroBehavior = self.zeroBehavior;
    
    return copy;
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Configuring Formatter Behavior
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@synthesize options = _options;
@synthesize zeroBehavior = _zeroBehavior;
@synthesize partialMatching = _partialMatching;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  NSFormatter
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (NSString*)stringForObjectValue:(NSNumber*)anObject
{
    if ([anObject isKindOfClass:NSNumber.class] == NO)
        return nil;
    
    size_t bits;
    uint64_t value = [anObject mk_UnsignedValue:&bits];
    
    MKOptionSetFormatterOptions *options = self.options;
    
    // Special case the 0 value
    if (value == 0) {
        if (options[@(0)])
            return options[@(0)];
        else {
            switch (self.zeroBehavior) {
                case MKOptionSetFormatterZeroBehaviorNil:
                    return nil;
                case MKOptionSetFormatterZeroBehaviorEmptyString:
                    return @"";
                case MKOptionSetFormatterZeroBehaviorZeroString:
                default:
                    return @"0";
            }
        }
    }
    
    NSMutableString *retValue = [NSMutableString string];
    uint64_t maskedBits = 0;
    
    for (NSNumber *maskValue in options) {
        uint64_t mask = [maskValue mk_UnsignedValue:NULL];
        
        if (mask == 0x0)
            continue;
        
        if ((value & mask) == mask || (self.partialMatching && (value & mask) != 0)) {
            maskedBits |= mask;
            if (retValue.length != 0) [retValue appendString:@" "];
            [retValue appendString:options[maskValue]];
        }
    }
    
    value &= (~maskedBits);
    
    for (unsigned i=0; i<bits; i++) {
        if (value & ((uint64_t)1 << i)) {
            if (retValue.length != 0) [retValue appendString:@" "];
            [retValue appendFormat:@"(1<<%u)", i];
        }
    }
    
    return retValue;
}

@end
