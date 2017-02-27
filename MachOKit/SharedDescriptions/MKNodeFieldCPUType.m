//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKNodeFieldCPUType.m
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

#import "MKNodeFieldCPUType.h"
#import "MKInternal.h"
#import "MKNode.h"

#include <mach-o/fat.h>

//----------------------------------------------------------------------------//
@implementation MKNodeFieldCPUType

static NSDictionary *s_CPUTypes = nil;

MKMakeSingletonInitializer(MKNodeFieldCPUType)

//|++++++++++++++++++++++++++++++++++++|//
+ (void)initialize
{
    if (s_CPUTypes != nil)
        return;
    
    s_CPUTypes = [@{
        @(CPU_TYPE_ANY): @"CPU_TYPE_ANY",
        @(CPU_TYPE_VAX): @"CPU_TYPE_VAX",
        /* skip				((cpu_type_t) 2)	*/
        /* skip				((cpu_type_t) 3)	*/
        /* skip				((cpu_type_t) 4)	*/
        /* skip				((cpu_type_t) 5)	*/
        @(CPU_TYPE_MC680x0): @"CPU_TYPE_MC680x0",
        @(CPU_TYPE_X86): @"CPU_TYPE_X86",
        @(CPU_TYPE_X86_64): @"CPU_TYPE_X86_64",
        /* skip CPU_TYPE_MIPS		((cpu_type_t) 8)	*/
        /* skip 			((cpu_type_t) 9)	*/
        @(CPU_TYPE_MC98000): @"CPU_TYPE_MC98000",
        @(CPU_TYPE_HPPA): @"CPU_TYPE_HPPA",
        @(CPU_TYPE_ARM): @"CPU_TYPE_ARM",
        @(CPU_TYPE_ARM64): @"CPU_TYPE_ARM64",
        @(CPU_TYPE_MC88000): @"CPU_TYPE_MC88000",
        @(CPU_TYPE_SPARC): @"CPU_TYPE_SPARC",
        @(CPU_TYPE_I860): @"CPU_TYPE_I860",
        /* skip	CPU_TYPE_ALPHA		((cpu_type_t) 16)	*/
        /* skip				((cpu_type_t) 17)	*/
        @(CPU_TYPE_POWERPC): @"CPU_TYPE_POWERPC",
        @(CPU_TYPE_POWERPC64): @"CPU_TYPE_POWERPC64"
    } retain];
}

//|++++++++++++++++++++++++++++++++++++|//
- (NSString*)name
{ return @"cpu_type_t"; }

//|++++++++++++++++++++++++++++++++++++|//
- (NSDictionary*)elements
{ return s_CPUTypes; }

//|++++++++++++++++++++++++++++++++++++|//
- (NSFormatter*)formatter
{
    return [MKEnumerationFormatter enumerationFormatterWithName:@"CPU_TYPE" elements:self.elements];
}

@end
