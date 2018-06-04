//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKNodeFieldSectionFlagsType.m
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

#import "MKNodeFieldSectionFlagsType.h"
#import "MKInternal.h"
#import "MKNodeDescription.h"
#import "MKNodeFieldSectionType.h"
#import "MKNodeFieldSectionUserAttributesType.h"
#import "MKNodeFieldSectionSystemAttributesType.h"

//----------------------------------------------------------------------------//
@implementation MKNodeFieldSectionFlagsType

static MKNodeFieldBitfieldMasks *s_Bits = nil;
static MKBitfieldFormatter *s_Formatter = nil;

MKMakeSingletonInitializer(MKNodeFieldSectionFlagsType)

//|++++++++++++++++++++++++++++++++++++|//
+ (void)initialize
{
    if (s_Bits != nil)
        return;
    
    s_Bits = [[NSArray alloc] initWithObjects:
        _$((uint32_t)SECTION_TYPE),
        _$((uint32_t)SECTION_ATTRIBUTES_USR),
        _$((uint32_t)SECTION_ATTRIBUTES_SYS),
    nil];
    
    MKBitfieldFormatterMask *type = [MKBitfieldFormatterMask new];
    type.mask = _$((uint32_t)SECTION_TYPE);
    type.formatter = MKNodeFieldSectionType.sharedInstance.formatter;
    
    MKBitfieldFormatterMask *userAttributes = [MKBitfieldFormatterMask new];
    userAttributes.mask = _$((uint32_t)SECTION_ATTRIBUTES_USR);
    userAttributes.formatter = MKNodeFieldSectionUserAttributesType.sharedInstance.formatter;
    userAttributes.ignoreZero = YES;
    
    MKBitfieldFormatterMask *systemAttributes = [MKBitfieldFormatterMask new];
    systemAttributes.mask = _$((uint32_t)SECTION_ATTRIBUTES_SYS);
    systemAttributes.formatter = MKNodeFieldSectionSystemAttributesType.sharedInstance.formatter;
    systemAttributes.ignoreZero = YES;
    
    NSArray *bits = [[NSArray alloc] initWithObjects:type, userAttributes, systemAttributes, nil];
    
    MKBitfieldFormatter *formatter = [MKBitfieldFormatter new];
    formatter.bits = bits;
    s_Formatter = formatter;
    
    [bits release];
    [systemAttributes release];
    [userAttributes release];
    [type release];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  MKNodeFieldBitfieldType
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeFieldBitfieldMasks*)bits
{ return s_Bits; }

//|++++++++++++++++++++++++++++++++++++|//
- (id<MKNodeFieldNumericType>)typeForMask:(NSNumber*)mask
{
    if ([mask isEqual:_$((uint32_t)SECTION_TYPE)])
        return MKNodeFieldSectionType.sharedInstance;
    else if ([mask isEqual:_$((uint32_t)SECTION_ATTRIBUTES_USR)])
        return MKNodeFieldSectionUserAttributesType.sharedInstance;
    else if ([mask isEqual:_$((uint32_t)SECTION_ATTRIBUTES_SYS)])
        return MKNodeFieldSectionSystemAttributesType.sharedInstance;
    else
        return nil;
}

//|++++++++++++++++++++++++++++++++++++|//
- (int)shiftForMask:(__unused NSNumber*)mask
{ return 0; }

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  MKNodeFieldType
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (NSString*)name
{ return @"Section Flags"; }

//|++++++++++++++++++++++++++++++++++++|//
- (NSFormatter*)formatter
{ return s_Formatter; }

@end
