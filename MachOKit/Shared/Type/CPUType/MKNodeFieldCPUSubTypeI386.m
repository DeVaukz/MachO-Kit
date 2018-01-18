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

//----------------------------------------------------------------------------//
@implementation MKNodeFieldCPUSubTypeI386

static NSDictionary *s_Types = nil;
static MKEnumerationFormatter *s_Formatter = nil;

MKMakeSingletonInitializer(MKNodeFieldCPUSubTypeI386)

//|++++++++++++++++++++++++++++++++++++|//
+ (void)initialize
{
    if (s_Types != nil && s_Formatter != nil)
        return;
    
    s_Types = [@{
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
         @((cpu_subtype_t)CPU_SUBTYPE_XEON_MP): @"CPU_SUBTYPE_XEON_MP"
    } retain];
    
    MKEnumerationFormatter *formatter = [MKEnumerationFormatter new];
    formatter.name = @"CPU_SUBTYPE_INTEL";
    formatter.elements = s_Types;
    s_Formatter = formatter;
}

//|++++++++++++++++++++++++++++++++++++|//
- (NSString*)name
{ return @"CPU_SUBTYPE_INTEL"; }

//|++++++++++++++++++++++++++++++++++++|//
- (NSDictionary*)elements
{ return s_Types; }

//|++++++++++++++++++++++++++++++++++++|//
- (NSFormatter*)formatter
{ return s_Formatter; }

@end
