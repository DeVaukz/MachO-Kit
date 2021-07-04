//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKNodeFieldCPUSubType.m
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

#import "MKNodeFieldCPUSubType.h"
#import "MKInternal.h"
#import "MKNodeDescription.h"

#import "MKNodeFieldCPUSubTypeI386.h"
#import "MKNodeFieldCPUSubTypeX86.h"
#import "MKNodeFieldCPUSubTypeARM.h"
#import "MKNodeFieldCPUSubTypeARM64.h"
#import "MKNodeFieldCPUSubTypeARM6432.h"
#import "MKNodeFieldCPUSubTypePowerPC.h"
#import "MKNodeFieldCPUSubTypePowerPC64.h"

extern void OBJC_CLASS_$_MKNodeFieldCPUSubType;

//----------------------------------------------------------------------------//
@implementation MKNodeFieldCPUSubType

static MKNodeFieldBitfieldMasks *s_Bits = nil;
static NSFormatter *s_Formatter = nil;

//|++++++++++++++++++++++++++++++++++++|//
+ (void)initialize
{
    if (self != &OBJC_CLASS_$_MKNodeFieldCPUSubType)
        return;
    
    s_Bits = [[NSArray alloc] initWithObjects:
        _$((uint32_t)CPU_SUBTYPE_MASK),
        _$(~(uint32_t)CPU_SUBTYPE_MASK),
    nil];
    
    MKBitfieldFormatterMask *subtypeMask = [MKBitfieldFormatterMask new];
    subtypeMask.mask = _$(~(uint32_t)CPU_SUBTYPE_MASK);
    subtypeMask.formatter = MKNodeFieldCPUSubTypeAnySubType.sharedInstance.formatter;
    
    MKBitfieldFormatterMask *capabilitiesMask = [MKBitfieldFormatterMask new];
    capabilitiesMask.mask = _$((uint32_t)CPU_SUBTYPE_MASK);
    capabilitiesMask.formatter = MKNodeFieldCPUSubTypeFeatures.sharedInstance.formatter;
    capabilitiesMask.ignoreZero = YES;
    
    NSArray *bits = [[NSArray alloc] initWithObjects:capabilitiesMask, subtypeMask, nil];
    
    MKBitfieldFormatter *formatter = [MKBitfieldFormatter new];
    formatter.bits = bits;
    s_Formatter = formatter;
    
    [bits release];
    [capabilitiesMask release];
    [subtypeMask release];
}

//|++++++++++++++++++++++++++++++++++++|//
+ (MKNodeFieldCPUSubType*)cpuSubTypeForCPUType:(cpu_type_t)cpuType
{
    switch (cpuType) {
        case CPU_TYPE_I386:
            return MKNodeFieldCPUSubTypeI386.sharedInstance;
        case CPU_TYPE_X86_64:
            return MKNodeFieldCPUSubTypeX86.sharedInstance;
        case CPU_TYPE_ARM:
            return MKNodeFieldCPUSubTypeARM.sharedInstance;
        case CPU_TYPE_ARM64:
            return MKNodeFieldCPUSubTypeARM64.sharedInstance;
        case CPU_TYPE_ARM64_32:
            return MKNodeFieldCPUSubTypeARM6432.sharedInstance;
        case CPU_TYPE_POWERPC:
            return MKNodeFieldCPUSubTypePowerPC.sharedInstance;
        case CPU_TYPE_POWERPC64:
            return MKNodeFieldCPUSubTypePowerPC64.sharedInstance;
        default:
        {
            static MKNodeFieldCPUSubType *s_DefaultType = nil;
            if (s_DefaultType == nil)
                s_DefaultType = [[MKNodeFieldCPUSubType alloc] init];
            return s_DefaultType;
        }
    }
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
    if ([mask isEqual:_$((uint32_t)CPU_SUBTYPE_MASK)])
        return MKNodeFieldCPUSubTypeFeatures.sharedInstance;
    else
        return MKNodeFieldCPUSubTypeAnySubType.sharedInstance;
}

//|++++++++++++++++++++++++++++++++++++|//
- (int)shiftForMask:(__unused NSNumber*)mask
{ return 0; }

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  MKNodeFieldType
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (NSString*)name
{ return @"CPU Subtype"; }

//|++++++++++++++++++++++++++++++++++++|//
- (NSFormatter*)formatter
{ return s_Formatter; }

@end
