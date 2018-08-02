//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKNodeFieldTypeOptionSet.m
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

#import "MKNodeFieldTypeOptionSet.h"
#import "MKInternal.h"
#import "MKNode.h"

//----------------------------------------------------------------------------//
@implementation MKNodeFieldTypeOptionSet

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)optionSetWithUnderlyingType:(id<MKNodeFieldNumericType>)underlyingType name:(NSString*)name traits:(MKNodeFieldOptionSetTraits)traits options:(MKNodeFieldOptionSetOptions*)options
{ return [[[self alloc] initWithUnderlyingType:underlyingType name:name traits:traits options:options] autorelease]; }

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)optionSetWithUnderlyingType:(id<MKNodeFieldNumericType>)underlyingType name:(NSString*)name options:(MKNodeFieldOptionSetOptions*)options
{ return [[[self alloc] initWithUnderlyingType:underlyingType name:name options:options] autorelease]; }

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithUnderlyingType:(id<MKNodeFieldNumericType>)underlyingType name:(NSString*)name traits:(MKNodeFieldOptionSetTraits)traits options:(MKNodeFieldOptionSetOptions*)options
{
    NSParameterAssert([underlyingType conformsToProtocol:@protocol(MKNodeFieldNumericType)]);
    
    self = [super init];
    if (self == nil) return nil;
    
    _underlyingType = [underlyingType retain];
    _options = [options copy];
    _optionSetTraits = traits;
    _name = [name copy];
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithUnderlyingType:(id<MKNodeFieldNumericType>)underlyingType name:(NSString*)name options:(MKNodeFieldOptionSetOptions*)options
{ return [self initWithUnderlyingType:underlyingType name:name traits:0 options:options]; }

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)init
{ @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"-init unavailable." userInfo:nil]; }

//|++++++++++++++++++++++++++++++++++++|//
- (void)dealloc
{
    [_formatter release];
    [_name release];
    [_options release];
    [_underlyingType release];
    
    [super dealloc];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  MKNodeFieldOptionSetType
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@synthesize options = _options;
@synthesize optionSetTraits = _optionSetTraits;

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
        return [NSString stringWithFormat:@"Option Set (%@)", _underlyingType.name];
}

//|++++++++++++++++++++++++++++++++++++|//
- (NSFormatter*)formatter
{
    if (_formatter == nil) {
        MKOptionSetFormatter *optionSetFormatter = [MKOptionSetFormatter new];
        optionSetFormatter.options = self.options;
        optionSetFormatter.partialMatching = (self.optionSetTraits & MKNodeFieldOptionSetTraitPartialMatchingAllowed) ? YES : NO;
        
        _formatter = optionSetFormatter;
    }
    
    return _formatter;
}

@end
