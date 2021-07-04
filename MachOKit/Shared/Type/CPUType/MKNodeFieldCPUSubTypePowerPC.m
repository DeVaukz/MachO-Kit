//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKNodeFieldCPUSubTypePowerPC.m
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

#import "MKNodeFieldCPUSubTypePowerPC.h"
#import "MKInternal.h"
#import "MKNodeDescription.h"

extern void OBJC_CLASS_$_MKNodeFieldCPUSubTypePowerPC;

//----------------------------------------------------------------------------//
@implementation MKNodeFieldCPUSubTypePowerPC

static NSFormatter *s_BitfieldFormatter = nil;

MKMakeSingletonInitializer(MKNodeFieldCPUSubTypePowerPC)

//|++++++++++++++++++++++++++++++++++++|//
+ (void)initialize
{
    if (self != &OBJC_CLASS_$_MKNodeFieldCPUSubTypePowerPC)
        return;
    
    MKBitfieldFormatterMask *subtypeMask = [MKBitfieldFormatterMask new];
    subtypeMask.mask = _$(~(uint32_t)CPU_SUBTYPE_MASK);
    subtypeMask.formatter = MKNodeFieldCPUSubTypePowerPCSubType.sharedInstance.formatter;
    
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
        return MKNodeFieldCPUSubTypePowerPCSubType.sharedInstance;
}

//|++++++++++++++++++++++++++++++++++++|//
- (NSFormatter*)formatter
{ return s_BitfieldFormatter; }

@end



//----------------------------------------------------------------------------//
@implementation MKNodeFieldCPUSubTypePowerPCSubType

static NSDictionary *s_Types = nil;
static MKEnumerationFormatter *s_Formatter = nil;

MKMakeSingletonInitializer(MKNodeFieldCPUSubTypePowerPCSubType)

//|++++++++++++++++++++++++++++++++++++|//
+ (void)initialize
{
    if (s_Types != nil && s_Formatter != nil)
        return;
    
    s_Types = [@{
        _$(CPU_SUBTYPE_POWERPC_ALL): @"CPU_SUBTYPE_POWERPC_ALL",
        _$(CPU_SUBTYPE_POWERPC_601): @"CPU_SUBTYPE_POWERPC_601",
        _$(CPU_SUBTYPE_POWERPC_602): @"CPU_SUBTYPE_POWERPC_602",
        _$(CPU_SUBTYPE_POWERPC_603): @"CPU_SUBTYPE_POWERPC_603",
        _$(CPU_SUBTYPE_POWERPC_603e): @"CPU_SUBTYPE_POWERPC_603e",
        _$(CPU_SUBTYPE_POWERPC_603ev): @"CPU_SUBTYPE_POWERPC_603ev",
        _$(CPU_SUBTYPE_POWERPC_604): @"CPU_SUBTYPE_POWERPC_604",
        _$(CPU_SUBTYPE_POWERPC_604e): @"CPU_SUBTYPE_POWERPC_604e",
        _$(CPU_SUBTYPE_POWERPC_620): @"CPU_SUBTYPE_POWERPC_620",
        _$(CPU_SUBTYPE_POWERPC_750): @"CPU_SUBTYPE_POWERPC_750",
        _$(CPU_SUBTYPE_POWERPC_7400): @"CPU_SUBTYPE_POWERPC_7400",
        _$(CPU_SUBTYPE_POWERPC_7450): @"CPU_SUBTYPE_POWERPC_7450",
        // PowerPC 970 is the "G5" - unclear if this subtype could appear
        // alongside the CPU_TYPE_POWERPC in a valid Mach-O.  TODO.
        _$(CPU_SUBTYPE_POWERPC_970): @"CPU_SUBTYPE_POWERPC_970"
    } retain];
    
    MKEnumerationFormatter *formatter = [MKEnumerationFormatter new];
    formatter.name = @"CPU_SUBTYPE_POWERPC";
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
{ return @"PowerPC CPU Subtype"; }

//|++++++++++++++++++++++++++++++++++++|//
- (NSFormatter*)formatter
{ return s_Formatter; }

@end
