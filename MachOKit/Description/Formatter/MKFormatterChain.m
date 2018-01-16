//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKFormatterChain.m
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

#import "MKFormatterChain.h"

//----------------------------------------------------------------------------//
@implementation MKFormatterChain

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)formatterChainWithFormatters:(NSArray<NSFormatter*> *)formatters
{
    MKFormatterChain *retValue = [[[self alloc] init] autorelease];
    retValue.formatters = formatters;
    
    return retValue;
}

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)formatterChainWithFormatter:(NSFormatter*)first, ...
{
    NSMutableArray *formatters = [[NSMutableArray alloc] initWithCapacity:3];
    [formatters addObject:first];
    
    va_list ap;
    va_start(ap, first);
    while ((first = va_arg(ap, NSFormatter*)) != nil) {
        [formatters addObject:first];
    }
    va_end(ap);
    
    MKFormatterChain *retValue = [self formatterChainWithFormatters:formatters];
    
    [formatters release];
    return retValue;
}

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)formatterChainWithLastFormatter:(NSFormatter*)last, ...
{
    NSMutableArray *formatters = [[NSMutableArray alloc] initWithCapacity:3];
    [formatters insertObject:last atIndex:0];
    
    va_list ap;
    va_start(ap, last);
    while ((last = va_arg(ap, NSFormatter*)) != nil) {
        [formatters insertObject:last atIndex:0];
    }
    va_end(ap);
    
    MKFormatterChain *retValue = [self formatterChainWithFormatters:formatters];
    
    [formatters release];
    return retValue;
}

//|++++++++++++++++++++++++++++++++++++|//
- (void)dealloc
{
    [_formatters release];
    
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
    
    _formatters = [[aDecoder decodeObjectOfClass:NSArray.class forKey:@"formatters"] retain];
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (void)encodeWithCoder:(NSCoder*)aCoder
{
    [aCoder encodeObject:self.formatters forKey:@"formatters"];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  NSCopying
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (id)copyWithZone:(NSZone*)zone
{
    MKFormatterChain *copy = [[MKFormatterChain allocWithZone:zone] init];
    copy.formatters = self.formatters;
    
    return copy;
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Configuring Formatter Behavior
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@synthesize formatters = _formatters;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  NSFormatter
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (NSString*)stringForObjectValue:(id)anObject
{
    for (NSFormatter *formatter in self.formatters) {
        NSString *string = [formatter stringForObjectValue:anObject];
        if (string)
            return string;
    }
    
    return nil;
}

@end
