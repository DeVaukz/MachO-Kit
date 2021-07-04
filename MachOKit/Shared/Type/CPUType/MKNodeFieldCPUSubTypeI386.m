//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKNodeFieldCPUSubTypeI386.m
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

#import "MKNodeFieldCPUSubTypeI386.h"
#import "MKInternal.h"
#import "MKNodeDescription.h"

extern void OBJC_CLASS_$_MKNodeFieldCPUSubTypeI386;

//----------------------------------------------------------------------------//
@implementation MKNodeFieldCPUSubTypeI386

static NSFormatter *s_BitfieldFormatter = nil;

MKMakeSingletonInitializer(MKNodeFieldCPUSubTypeI386)

//|++++++++++++++++++++++++++++++++++++|//
+ (void)initialize
{
    if (self != &OBJC_CLASS_$_MKNodeFieldCPUSubTypeI386)
        return;
    
    MKBitfieldFormatterMask *subtypeMask = [MKBitfieldFormatterMask new];
    subtypeMask.mask = _$(~(uint32_t)CPU_SUBTYPE_MASK);
    subtypeMask.formatter = MKNodeFieldCPUSubTypeI386SubType.sharedInstance.formatter;
    
    MKBitfieldFormatterMask *capabilitiesMask = [MKBitfieldFormatterMask new];
    capabilitiesMask.mask = _$((uint32_t)CPU_SUBTYPE_MASK);
    capabilitiesMask.formatter = MKNodeFieldCPUSubTypeFeatures.sharedInstance.formatter;
    capabilitiesMask.ignoreZero = YES;
    
    NSArray *bits = [[NSArray alloc] initWithObjects:capabilitiesMask, subtypeMask, nil];
    
    MKBitfieldFormatter *formatter = [MKBitfieldFormatter new];
    formatter.bits = bits;
    s_BitfieldFormatter = formatter;
    
    [bits release];
    [capabilitiesMask release];
    [subtypeMask release];
}

//|++++++++++++++++++++++++++++++++++++|//
- (id<MKNodeFieldNumericType>)typeForMask:(NSNumber*)mask
{
    if ([mask isEqual:_$((uint32_t)CPU_SUBTYPE_MASK)])
        return MKNodeFieldCPUSubTypeFeatures.sharedInstance;
    else
        return MKNodeFieldCPUSubTypeI386SubType.sharedInstance;
}

//|++++++++++++++++++++++++++++++++++++|//
- (NSFormatter*)formatter
{ return s_BitfieldFormatter; }

@end



//----------------------------------------------------------------------------//
@implementation MKNodeFieldCPUSubTypeI386SubType

static NSDictionary *s_Types = nil;
static MKEnumerationFormatter *s_Formatter = nil;

MKMakeSingletonInitializer(MKNodeFieldCPUSubTypeI386SubType)

//|++++++++++++++++++++++++++++++++++++|//
+ (void)initialize
{
    if (s_Types != nil && s_Formatter != nil)
        return;
    
    s_Types = [@{
         _$(CPU_SUBTYPE_I386_ALL): @"CPU_SUBTYPE_I386_ALL",
         _$(CPU_SUBTYPE_486): @"CPU_SUBTYPE_486",
         _$(CPU_SUBTYPE_486SX): @"CPU_SUBTYPE_486SX",
         _$(CPU_SUBTYPE_586): @"CPU_SUBTYPE_586",
         _$(CPU_SUBTYPE_PENTPRO): @"CPU_SUBTYPE_PENTPRO",
         _$(CPU_SUBTYPE_PENTII_M3): @"CPU_SUBTYPE_PENTII_M3",
         _$(CPU_SUBTYPE_PENTII_M5): @"CPU_SUBTYPE_PENTII_M5",
         _$(CPU_SUBTYPE_CELERON): @"CPU_SUBTYPE_CELERON",
         _$(CPU_SUBTYPE_CELERON_MOBILE): @"CPU_SUBTYPE_CELERON_MOBILE",
         _$(CPU_SUBTYPE_PENTIUM_3): @"CPU_SUBTYPE_PENTIUM_3",
         _$(CPU_SUBTYPE_PENTIUM_3_M): @"CPU_SUBTYPE_PENTIUM_3_M",
         _$(CPU_SUBTYPE_PENTIUM_3_XEON): @"CPU_SUBTYPE_PENTIUM_3_XEON",
         _$(CPU_SUBTYPE_PENTIUM_M): @"CPU_SUBTYPE_PENTIUM_M",
         _$(CPU_SUBTYPE_PENTIUM_4): @"CPU_SUBTYPE_PENTIUM_4",
         _$(CPU_SUBTYPE_PENTIUM_4_M): @"CPU_SUBTYPE_PENTIUM_4_M",
         _$(CPU_SUBTYPE_ITANIUM): @"CPU_SUBTYPE_ITANIUM",
         _$(CPU_SUBTYPE_ITANIUM_2): @"CPU_SUBTYPE_ITANIUM_2",
         _$(CPU_SUBTYPE_XEON): @"CPU_SUBTYPE_XEON",
         _$(CPU_SUBTYPE_XEON_MP): @"CPU_SUBTYPE_XEON_MP"
    } retain];
    
    MKEnumerationFormatter *formatter = [MKEnumerationFormatter new];
    formatter.name = @"CPU_SUBTYPE_INTEL";
    formatter.elements = s_Types;
    formatter.fallbackFormatter = NSFormatter.mk_decimalNumberFormatter;
    s_Formatter = formatter;
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  MKNodeFieldEnumerationType
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeFieldEnumerationElements*)elements
{ return s_Types; }

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  MKNodeFieldType
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (NSString*)name
{ return @"i386 CPU Subtype"; }

//|++++++++++++++++++++++++++++++++++++|//
- (NSFormatter*)formatter
{ return s_Formatter; }

@end
