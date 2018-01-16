//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKNodeFieldTypeEnumeration.m
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

#import "MKNodeFieldTypeEnumeration.h"
#import "MKInternal.h"
#import "MKNode.h"

//----------------------------------------------------------------------------//
@implementation MKNodeFieldTypeEnumeration

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)enumerationWithUnderlyingType:(id<MKNodeFieldNumericType>)underlyingType name:(NSString*)name elements:(MKNodeFieldEnumerationElements*)elements
{ return [[[self alloc] initWithUnderlyingType:underlyingType name:name elements:elements] autorelease]; }

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithUnderlyingType:(id<MKNodeFieldNumericType>)underlyingType name:(NSString*)name elements:(MKNodeFieldEnumerationElements*)elements
{
    NSParameterAssert([underlyingType conformsToProtocol:@protocol(MKNodeFieldNumericType)]);
    
    self = [super init];
    if (self == nil) return nil;
    
    _underlyingType = [underlyingType retain];
    _elements = [elements copy];
    _name = [name copy];
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)init
{ @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"-init unavailable." userInfo:nil]; }

//|++++++++++++++++++++++++++++++++++++|//
- (void)dealloc
{
    [_formatter release];
    [_name release];
    [_elements release];
    [_underlyingType release];
    
    [super dealloc];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  MKNodeFieldEnumerationType
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@synthesize elements = _elements;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  MKNodeFieldNumericType
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeFieldNumericTypeTraits)traitsForNode:(MKNode*)input
{ return [_underlyingType traitsForNode:input]; }

//|++++++++++++++++++++++++++++++++++++|//
- (size_t)sizeForNode:(MKNode*)input
{ return [_underlyingType sizeForNode:input]; }

//|++++++++++++++++++++++++++++++++++++|//
- (size_t)alignmentForNode:(MKNode*)input
{ return [_underlyingType alignmentForNode:input]; }

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  MKNodeFieldType
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (NSString*)name
{
    if (_name)
        return _name;
    else
        return [NSString stringWithFormat:@"Enumeration (%@)", _underlyingType.name];
}

//|++++++++++++++++++++++++++++++++++++|//
- (NSFormatter*)formatter
{
    if (_formatter == nil) {
        NSFormatter *fallbackFormatter = _name ? _underlyingType.formatter : nil;
        
        MKEnumerationFormatter *enumerationFormatter = [MKEnumerationFormatter new];
        enumerationFormatter.elements = _elements;
        enumerationFormatter.name = _name;
        enumerationFormatter.fallbackFormatter = fallbackFormatter;
        
        NSArray *formatters = [[NSArray alloc] initWithObjects:enumerationFormatter, fallbackFormatter, nil];
        
        MKFormatterChain *formatterChain = [MKFormatterChain new];
        formatterChain.formatters = formatters;
        
        _formatter = formatterChain;
        
        [formatters release];
        [enumerationFormatter release];
    }
    
    return _formatter;
}

@end
