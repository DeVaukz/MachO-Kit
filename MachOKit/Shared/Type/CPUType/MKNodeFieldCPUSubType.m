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

//----------------------------------------------------------------------------//
@implementation MKNodeFieldCPUSubType

static MKNodeFieldBitfieldMasks *s_Bits = nil;

//|++++++++++++++++++++++++++++++++++++|//
+ (void)initialize
{
    if (s_Bits != nil)
        return;
    
    s_Bits = [[NSArray alloc] initWithObjects:
        _$((uint32_t)CPU_SUBTYPE_MASK),
        _$(~(uint32_t)CPU_SUBTYPE_MASK),
    nil];
}

//|++++++++++++++++++++++++++++++++++++|//
+ (MKNodeFieldCPUSubType*)cpuSubTypeForCPUType:(cpu_type_t)cpuType
{
    switch (cpuType) {
        case CPU_TYPE_X86:
        {
            static MKNodeFieldCPUSubType *s_I386Type = nil;
            if (s_I386Type == nil)
                s_I386Type = [[MKNodeFieldCPUSubType alloc] initWithCPUSubType:MKNodeFieldCPUSubTypeI386.sharedInstance];
            return s_I386Type;
        }
        case CPU_TYPE_X86_64:
        {
            static MKNodeFieldCPUSubType *s_X86_64Type = nil;
            if (s_X86_64Type == nil)
                s_X86_64Type = [[MKNodeFieldCPUSubType alloc] initWithCPUSubType:MKNodeFieldCPUSubTypeX86.sharedInstance];
            return s_X86_64Type;
        }
        case CPU_TYPE_ARM:
        {
            static MKNodeFieldCPUSubType *s_ARMType = nil;
            if (s_ARMType == nil)
                s_ARMType = [[MKNodeFieldCPUSubType alloc] initWithCPUSubType:MKNodeFieldCPUSubTypeARM.sharedInstance];
            return s_ARMType;
        }
        case CPU_TYPE_ARM64:
        {
            static MKNodeFieldCPUSubType *s_ARM64Type = nil;
            if (s_ARM64Type == nil)
                s_ARM64Type = [[MKNodeFieldCPUSubType alloc] initWithCPUSubType:MKNodeFieldCPUSubTypeARM64.sharedInstance];
            return s_ARM64Type;
        }
        case CPU_TYPE_ARM64_32:
        {
            static MKNodeFieldCPUSubType *s_ARM6432Type = nil;
            if (s_ARM6432Type == nil)
                s_ARM6432Type = [[MKNodeFieldCPUSubType alloc] initWithCPUSubType:MKNodeFieldCPUSubTypeARM6432.sharedInstance];
            return s_ARM6432Type;
        }
        case CPU_TYPE_POWERPC:
        {
            static MKNodeFieldCPUSubType *s_PowerPCType = nil;
            if (s_PowerPCType == nil)
                s_PowerPCType = [[MKNodeFieldCPUSubType alloc] initWithCPUSubType:MKNodeFieldCPUSubTypePowerPC.sharedInstance];
            return s_PowerPCType;
        }
        default:
        {
            static MKNodeFieldCPUSubType *s_DefaultType = nil;
            if (s_DefaultType == nil)
                s_DefaultType = [[MKNodeFieldCPUSubType alloc] init];
            return s_DefaultType;
        }
    }
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithCPUSubType:(MKNodeFieldCPUSubTypeAny*)subtype
{
    self = [super init];
    if (self == nil) return nil;
    
    _implType = [subtype ?: MKNodeFieldCPUSubTypeAny.sharedInstance retain];
    
    MKBitfieldFormatterMask *subtypeMask = [MKBitfieldFormatterMask new];
    subtypeMask.mask = _$(~(uint32_t)CPU_SUBTYPE_MASK);
    subtypeMask.formatter = _implType.formatter;
    
    MKBitfieldFormatterMask *capabilitiesMask = [MKBitfieldFormatterMask new];
    capabilitiesMask.mask = _$((uint32_t)CPU_SUBTYPE_MASK);
    capabilitiesMask.formatter = MKNodeFieldCPUSubTypeCapability.sharedInstance.formatter;
    capabilitiesMask.ignoreZero = YES;
    
    NSArray *bits = [[NSArray alloc] initWithObjects:capabilitiesMask, subtypeMask, nil];
    
    MKBitfieldFormatter *formatter = [MKBitfieldFormatter new];
    formatter.bits = bits;
    _formatter = formatter;
    
    [bits release];
    [capabilitiesMask release];
    [subtypeMask release];
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)init
{ return [self initWithCPUSubType:nil]; }

//|++++++++++++++++++++++++++++++++++++|//
- (void)dealloc
{
    [_formatter release];
    [_implType release];
    
    [super dealloc];
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
        return MKNodeFieldCPUSubTypeCapability.sharedInstance;
    else
        return _implType;
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
{ return _formatter; }

@end
