//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKNodeFieldTypeBitfield.m
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

#import "MKNodeFieldTypeBitfield.h"
#import "MKInternal.h"
#import "MKNode.h"

//----------------------------------------------------------------------------//
@implementation MKNodeFieldTypeBitfieldMask

@synthesize type = _type;
@synthesize mask = _mask;
@synthesize shift = _shift;

//|++++++++++++++++++++++++++++++++++++|//
- (id)copyWithZone:(NSZone*)zone
{
    MKNodeFieldTypeBitfieldMask *copy = [[MKNodeFieldTypeBitfieldMask allocWithZone:zone] init];
    copy.type = self.type;
    copy.mask = self.mask;
    copy.shift = self.shift;
    
    return copy;
}

//|++++++++++++++++++++++++++++++++++++|//
- (void)dealloc
{
    [_mask release];
    [_type release];
    
    [super dealloc];
}

@end



//----------------------------------------------------------------------------//
@implementation MKNodeFieldTypeBitfield

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)bitfieldWithType:(id<MKNodeFieldNumericType>)underlyingType bits:(NSArray*)bits name:(NSString*)name
{ return [[[self alloc] initWithType:underlyingType bits:bits name:name] autorelease]; }

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)bitfieldWithType:(id<MKNodeFieldNumericType>)underlyingType mask:(NSNumber*)mask name:(NSString*)name
{
    MKNodeFieldTypeBitfieldMask *m = [MKNodeFieldTypeBitfieldMask new];
    m.type = underlyingType;
    m.mask = mask;
    
    NSArray *bits = [[NSArray alloc] initWithObjects:m, nil];
    
    MKNodeFieldTypeBitfield *bitfield = [self bitfieldWithType:underlyingType bits:bits name:name];
    
    [bits release];
    [m release];
    
    return bitfield;
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithType:(id<MKNodeFieldNumericType>)underlyingType bits:(NSArray<MKNodeFieldTypeBitfieldMask*> *)bits name:(nullable NSString*)name
{
    NSParameterAssert([underlyingType conformsToProtocol:@protocol(MKNodeFieldNumericType)]);
    // Don't really care if 'bits' is nil.
    
    self = [super init];
    if (self == nil) return nil;
    
    _underlyingType = [underlyingType retain];
    _bits = [bits copy]; // TODO - This should be a deep copy
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
    [_bits release];
    [_underlyingType release];
    
    [super dealloc];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  MKNodeFieldBitfieldType
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeFieldBitfieldMasks*)bits
{
    NSMutableArray *masks = [NSMutableArray array];
    
    for (MKNodeFieldTypeBitfieldMask *bits in _bits) {
        NSNumber *mask = bits.mask;
        if (mask)
            [masks addObject:mask];
    }
    
    return masks;
}

//|++++++++++++++++++++++++++++++++++++|//
- (id<MKNodeFieldNumericType>)typeForMask:(NSNumber*)mask
{
    for (MKNodeFieldTypeBitfieldMask *bits in _bits) {
        if ([bits.mask isEqual:mask])
            return bits.type;
    }
    
    return nil; // TODO - Should this throw instead?
}

//|++++++++++++++++++++++++++++++++++++|//
- (int)shiftForMask:(NSNumber*)mask
{
    for (MKNodeFieldTypeBitfieldMask *bits in _bits) {
        if ([bits.mask isEqual:mask])
            return bits.shift;
    }
    
    return 0; // TODO - Should this throw instead?
}

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
        return [NSString stringWithFormat:@"Bitfield (%@)", _underlyingType.name];
}

//|++++++++++++++++++++++++++++++++++++|//
- (NSFormatter*)formatter
{
    if (_formatter == nil) {
        MKBitfieldFormatter *bitfieldFormatter = [MKBitfieldFormatter new];
        
        NSMutableArray<MKBitfieldFormatterMask*> *formatterMasks = [[NSMutableArray alloc] initWithCapacity:_bits.count];
        
        for (MKNodeFieldTypeBitfieldMask *bits in _bits) {
            MKBitfieldFormatterMask *formatterMask = [MKBitfieldFormatterMask new];
            formatterMask.mask = bits.mask;
            formatterMask.formatter = bits.type.formatter;
            formatterMask.shift = bits.shift;
            
            [formatterMasks addObject:formatterMask];
            [formatterMask release];
        }
        
        bitfieldFormatter.bits = formatterMasks;
        [formatterMasks release];
        
        _formatter = bitfieldFormatter;
    }
    
    return _formatter;
}

@end
