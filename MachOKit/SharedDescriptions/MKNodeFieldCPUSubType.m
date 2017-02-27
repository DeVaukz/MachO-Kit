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
#import "MKNode.h"

#include <mach-o/fat.h>

//----------------------------------------------------------------------------//
@implementation MKNodeFieldCPUSubType

static NSDictionary *s_CPUSubTypes = nil;

MKMakeSingletonInitializer(MKNodeFieldCPUSubType)

//|++++++++++++++++++++++++++++++++++++|//
+ (void)initialize
{
    if (s_CPUSubTypes != nil)
        return;
    
    s_CPUSubTypes = [@{
        @((cpu_subtype_t)CPU_SUBTYPE_MULTIPLE): @"CPU_SUBTYPE_MULTIPLE",
        @((cpu_subtype_t)CPU_SUBTYPE_LITTLE_ENDIAN): @"CPU_SUBTYPE_LITTLE_ENDIAN",
        @((cpu_subtype_t)CPU_SUBTYPE_BIG_ENDIAN): @"CPU_SUBTYPE_BIG_ENDIAN"
    } retain];
}

//|++++++++++++++++++++++++++++++++++++|//
+ (MKNodeFieldCPUSubType*)cpuSubTypeForCPUType:(cpu_type_t)cpuType
{
    switch (cpuType) {
        case CPU_TYPE_X86:
            return MKNodeFieldIntelCPUSubType.sharedInstance;
        case CPU_TYPE_X86_64:
            return MKNodeFieldIntel64CPUSubType.sharedInstance;
        case CPU_TYPE_ARM:
            return MKNodeFieldARMCPUSubType.sharedInstance;
        case CPU_TYPE_ARM64:
            return MKNodeFieldARM64CPUSubType.sharedInstance;
        default:
            return [MKNodeFieldCPUSubType sharedInstance];
    }
    
    
}

//|++++++++++++++++++++++++++++++++++++|//
- (NSString*)name
{ return @"cpu_subtype_t"; }

//|++++++++++++++++++++++++++++++++++++|//
- (NSDictionary*)elements
{ return s_CPUSubTypes; }

//|++++++++++++++++++++++++++++++++++++|//
- (NSFormatter*)formatter
{
    return [MKEnumerationFormatter enumerationFormatterWithName:@"CPU_SUBTYPE" fallbackFormatter:NSFormatter.mk_decimalNumberFormatter elements:self.elements];
}

@end


#define __CPU_SUBTYPE_IMPL(NAME, ...) \
@implementation NAME \
static NSDictionary *s_ ## NAME ## Dict = nil; \
MKMakeSingletonInitializer(NAME) \
+ (void)initialize \
{ \
    if (s_ ## NAME ## Dict != nil) return; \
    \
    s_ ## NAME ## Dict = [__VA_ARGS__ retain]; \
} \
- (NSDictionary*)elements \
{ return s_ ## NAME ## Dict; } \
@end


__CPU_SUBTYPE_IMPL(MKNodeFieldIntelCPUSubType, @{
    @((cpu_subtype_t)CPU_SUBTYPE_I386_ALL): @"CPU_SUBTYPE_I386_ALL",
    @((cpu_subtype_t)CPU_SUBTYPE_486): @"CPU_SUBTYPE_486",
    @((cpu_subtype_t)CPU_SUBTYPE_486SX): @"CPU_SUBTYPE_486SX",
    @((cpu_subtype_t)CPU_SUBTYPE_586): @"CPU_SUBTYPE_586",
    @((cpu_subtype_t)CPU_SUBTYPE_PENTPRO): @"CPU_SUBTYPE_PENTPRO",
    @((cpu_subtype_t)CPU_SUBTYPE_PENTII_M3): @"CPU_SUBTYPE_PENTII_M3",
    @((cpu_subtype_t)CPU_SUBTYPE_PENTII_M5): @"CPU_SUBTYPE_PENTII_M5",
    @((cpu_subtype_t)CPU_SUBTYPE_CELERON): @"CPU_SUBTYPE_CELERON",
    @((cpu_subtype_t)CPU_SUBTYPE_CELERON_MOBILE): @"CPU_SUBTYPE_CELERON_MOBILE",
    @((cpu_subtype_t)CPU_SUBTYPE_PENTIUM_3): @"CPU_SUBTYPE_PENTIUM_3",
    @((cpu_subtype_t)CPU_SUBTYPE_PENTIUM_3_M): @"CPU_SUBTYPE_PENTIUM_3_M",
    @((cpu_subtype_t)CPU_SUBTYPE_PENTIUM_3_XEON): @"CPU_SUBTYPE_PENTIUM_3_XEON",
    @((cpu_subtype_t)CPU_SUBTYPE_PENTIUM_M): @"CPU_SUBTYPE_PENTIUM_M",
    @((cpu_subtype_t)CPU_SUBTYPE_PENTIUM_4): @"CPU_SUBTYPE_PENTIUM_4",
    @((cpu_subtype_t)CPU_SUBTYPE_PENTIUM_4_M): @"CPU_SUBTYPE_PENTIUM_4_M",
    @((cpu_subtype_t)CPU_SUBTYPE_ITANIUM): @"CPU_SUBTYPE_ITANIUM",
    @((cpu_subtype_t)CPU_SUBTYPE_ITANIUM_2): @"CPU_SUBTYPE_ITANIUM_2",
    @((cpu_subtype_t)CPU_SUBTYPE_XEON): @"CPU_SUBTYPE_XEON",
    @((cpu_subtype_t)CPU_SUBTYPE_XEON_MP): @"CPU_SUBTYPE_XEON_MP",
})
__CPU_SUBTYPE_IMPL(MKNodeFieldIntel64CPUSubType, @{
    @((cpu_subtype_t)CPU_SUBTYPE_X86_64_ALL): @"CPU_SUBTYPE_X86_64_ALL",
    @((cpu_subtype_t)CPU_SUBTYPE_X86_64_H): @"CPU_SUBTYPE_X86_64_H",
    @((cpu_subtype_t)(CPU_SUBTYPE_LIB64 | CPU_SUBTYPE_X86_64_ALL)): @"CPU_SUBTYPE_X86_64_ALL",
    @((cpu_subtype_t)(CPU_SUBTYPE_LIB64 | CPU_SUBTYPE_X86_64_H)): @"CPU_SUBTYPE_X86_64_H"
})
__CPU_SUBTYPE_IMPL(MKNodeFieldARMCPUSubType, @{
    @((cpu_subtype_t)CPU_SUBTYPE_ARM_ALL): @"CPU_SUBTYPE_ARM_ALL",
    @((cpu_subtype_t)CPU_SUBTYPE_ARM_V4T): @"CPU_SUBTYPE_ARM_V4T",
    @((cpu_subtype_t)CPU_SUBTYPE_ARM_V6): @"CPU_SUBTYPE_ARM_V6",
    @((cpu_subtype_t)CPU_SUBTYPE_ARM_V5TEJ): @"CPU_SUBTYPE_ARM_V5TEJ",
    @((cpu_subtype_t)CPU_SUBTYPE_ARM_XSCALE): @"CPU_SUBTYPE_ARM_XSCALE",
    @((cpu_subtype_t)CPU_SUBTYPE_ARM_V7): @"CPU_SUBTYPE_ARM_V7",
    @((cpu_subtype_t)CPU_SUBTYPE_ARM_V7F): @"CPU_SUBTYPE_ARM_V7F",
    @((cpu_subtype_t)CPU_SUBTYPE_ARM_V7S): @"CPU_SUBTYPE_ARM_V7S",
    @((cpu_subtype_t)CPU_SUBTYPE_ARM_V7K): @"CPU_SUBTYPE_ARM_V7K",
    @((cpu_subtype_t)CPU_SUBTYPE_ARM_V6M): @"CPU_SUBTYPE_ARM_V6M",
    @((cpu_subtype_t)CPU_SUBTYPE_ARM_V7M): @"CPU_SUBTYPE_ARM_V7M",
    @((cpu_subtype_t)CPU_SUBTYPE_ARM_V7EM): @"CPU_SUBTYPE_ARM_V7EM",
    @((cpu_subtype_t)CPU_SUBTYPE_ARM_V8): @"CPU_SUBTYPE_ARM_V8"
})
__CPU_SUBTYPE_IMPL(MKNodeFieldARM64CPUSubType, @{
    @((cpu_subtype_t)CPU_SUBTYPE_ARM64_ALL): @"CPU_SUBTYPE_ARM64_ALL",
    @((cpu_subtype_t)CPU_SUBTYPE_ARM64_V8): @"CPU_SUBTYPE_ARM64_V8",
    @((cpu_subtype_t)(CPU_SUBTYPE_LIB64 | CPU_SUBTYPE_ARM64_ALL)): @"CPU_SUBTYPE_ARM64_ALL",
    @((cpu_subtype_t)(CPU_SUBTYPE_LIB64 | CPU_SUBTYPE_ARM64_V8)): @"CPU_SUBTYPE_ARM64_V8"
})

