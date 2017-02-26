//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKEnumerationFormatter.m
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

#import "MKEnumerationFormatter.h"

//----------------------------------------------------------------------------//
@implementation MKEnumerationFormatter

@synthesize name = _name;
@synthesize elements = _elements;
@synthesize fallbackFormatter = _fallbackFormatter;

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)enumerationFormatterWithName:(NSString*)name fallbackFormatter:(NSFormatter*)formatter elements:(NSDictionary*)elements
{
    MKEnumerationFormatter *retValue = [self new];
    retValue.elements = elements;
    retValue.name = name;
    retValue.fallbackFormatter = formatter;
    return [retValue autorelease];
}

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)enumerationFormatterWithName:(NSString*)name elements:(NSDictionary*)elements
{
    MKEnumerationFormatter *retValue = [self new];
    retValue.elements = elements;
    retValue.name = name;
    return [retValue autorelease];
}

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)enumerationFormatterWithElements:(NSDictionary*)elements
{
    MKEnumerationFormatter *retValue = [self new];
    retValue.elements = elements;
    return [retValue autorelease];
}

//|++++++++++++++++++++++++++++++++++++|//
- (void)dealloc
{
    [_fallbackFormatter release];
    [_elements release];
    [_name release];
    
    [super dealloc];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  NSFormatter
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (NSString*)stringForObjectValue:(id)anObject
{
    NSString *matchingElement = [self.elements objectForKey:anObject];
    if (matchingElement)
        return matchingElement;
    
    NSString *name = self.name;
    NSString *fallbackValue = [self.fallbackFormatter stringForObjectValue:anObject];
    
    if (name && fallbackValue)
        return [NSString stringWithFormat:@"%@(%@)", name, fallbackValue];
    
    // Do not return the fallback value here.  Anonymous enumerations (where
    // a name was not given) may want to use a hex representation if anObject
    // is not one of the elemens.  For various reasons, the hex formatter may
    // not be our fallbackFormatter; instead we are chained with the
    // hex formatter following.  Returning nil here allows the next formatter
    // in the chain to handle the value.
    
    return nil;
}

@end
