//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKComboFormatter.m
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

#import "MKComboFormatter.h"

//----------------------------------------------------------------------------//
@implementation MKComboFormatter

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)comboFormatterWithStyle:(MKComboFormatterStyle)style rawValueFormatter:(NSFormatter*)rawValueFormatter refinedValueFormatter:(NSFormatter*)refinedValueFormatter
{
    MKComboFormatter *retValue = [[[self alloc] init] autorelease];
    retValue.rawValueFormatter = rawValueFormatter;
    retValue.refinedValueFormatter = refinedValueFormatter;
    retValue.style = style;
    
    return retValue;
}

//|++++++++++++++++++++++++++++++++++++|//
- (void)dealloc
{
    [_refinedValueFormatter release];
    [_rawValueFormatter release];
    
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
    
    _rawValueFormatter = [[aDecoder decodeObjectOfClass:NSFormatter.class forKey:@"rawValueFormatter"] retain];
    _refinedValueFormatter = [[aDecoder decodeObjectOfClass:NSFormatter.class forKey:@"refinedValueFormatter"] retain];
    _style = (NSUInteger)[aDecoder decodeIntegerForKey:@"style"];
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (void)encodeWithCoder:(NSCoder*)aCoder
{
    [aCoder encodeObject:self.rawValueFormatter forKey:@"rawValueFormatter"];
    [aCoder encodeObject:self.refinedValueFormatter forKey:@"refinedValueFormatter"];
    [aCoder encodeInteger:self.style forKey:@"style"];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  NSCopying
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (id)copyWithZone:(NSZone*)zone
{
    MKComboFormatter *copy = [[MKComboFormatter allocWithZone:zone] init];
    copy.rawValueFormatter = self.rawValueFormatter;
    copy.refinedValueFormatter = self.refinedValueFormatter;
    copy.style = self.style;
    
    return copy;
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Configuring Formatter Behavior
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@synthesize rawValueFormatter = _rawValueFormatter;
@synthesize refinedValueFormatter = _refinedValueFormatter;
@synthesize style = _style;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  NSFormatter
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (NSString*)stringForObjectValue:(id)anObject
{
    switch (self.style) {
        case MKComboFormatterStyleRawAndRefinedValue1:
        {
            NSString *raw = [self.rawValueFormatter stringForObjectValue:anObject];
            NSString *refined = [self.refinedValueFormatter stringForObjectValue:anObject];
            
            if (raw && refined)
                return [NSString stringWithFormat:@"%@ %@", raw, refined];
            else
                return raw;
        }
        case MKComboFormatterStyleRawAndRefinedValue2:
        {
            NSString *raw = [self.rawValueFormatter stringForObjectValue:anObject];
            NSString *refined = [self.refinedValueFormatter stringForObjectValue:anObject];
            
            if (raw && refined)
                return [NSString stringWithFormat:@"%@ (%@)", raw, refined];
            else
                return raw;
        }
        case MKComboFormatterStyleRefinedValue:
        default:
            return [self.refinedValueFormatter stringForObjectValue:anObject];
    }
}

@end
