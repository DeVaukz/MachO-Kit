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

//----------------------------------------------------------------------------//
@implementation MKNodeFieldCPUSubTypePowerPC

static NSDictionary *s_Types = nil;
static MKEnumerationFormatter *s_Formatter = nil;

MKMakeSingletonInitializer(MKNodeFieldCPUSubTypePowerPC)

//|++++++++++++++++++++++++++++++++++++|//
+ (void)initialize
{
    if (s_Types != nil && s_Formatter != nil)
        return;
    
    s_Types = [@{
        @((cpu_subtype_t)CPU_SUBTYPE_POWERPC_ALL): @"CPU_SUBTYPE_POWERPC_ALL",
        @((cpu_subtype_t)CPU_SUBTYPE_POWERPC_601): @"CPU_SUBTYPE_POWERPC_601",
        @((cpu_subtype_t)CPU_SUBTYPE_POWERPC_602): @"CPU_SUBTYPE_POWERPC_602",
        @((cpu_subtype_t)CPU_SUBTYPE_POWERPC_603): @"CPU_SUBTYPE_POWERPC_603",
        @((cpu_subtype_t)CPU_SUBTYPE_POWERPC_603e): @"CPU_SUBTYPE_POWERPC_603e",
        @((cpu_subtype_t)CPU_SUBTYPE_POWERPC_603ev): @"CPU_SUBTYPE_POWERPC_603ev",
        @((cpu_subtype_t)CPU_SUBTYPE_POWERPC_604): @"CPU_SUBTYPE_POWERPC_604",
        @((cpu_subtype_t)CPU_SUBTYPE_POWERPC_604e): @"CPU_SUBTYPE_POWERPC_604e",
        @((cpu_subtype_t)CPU_SUBTYPE_POWERPC_620): @"CPU_SUBTYPE_POWERPC_620",
        @((cpu_subtype_t)CPU_SUBTYPE_POWERPC_750): @"CPU_SUBTYPE_POWERPC_750",
        @((cpu_subtype_t)CPU_SUBTYPE_POWERPC_7400): @"CPU_SUBTYPE_POWERPC_7400",
        @((cpu_subtype_t)CPU_SUBTYPE_POWERPC_7450): @"CPU_SUBTYPE_POWERPC_7450",
        @((cpu_subtype_t)CPU_SUBTYPE_POWERPC_970): @"CPU_SUBTYPE_POWERPC_970"
    } retain];
    
    MKEnumerationFormatter *formatter = [MKEnumerationFormatter new];
    formatter.name = @"CPU_SUBTYPE_POWERPC";
    formatter.elements = s_Types;
    s_Formatter = formatter;
}

//|++++++++++++++++++++++++++++++++++++|//
- (NSString*)name
{ return @"CPU_SUBTYPE_POWERPC"; }

//|++++++++++++++++++++++++++++++++++++|//
- (NSDictionary*)elements
{ return s_Types; }

//|++++++++++++++++++++++++++++++++++++|//
- (NSFormatter*)formatter
{ return s_Formatter; }

@end
