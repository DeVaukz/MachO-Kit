//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             architecture.c
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

#include "core_internal.h"
#include "architecture.h"

//----------------------------------------------------------------------------//
#pragma mark -  Retrieving Information About An Architecture
//----------------------------------------------------------------------------//

//|++++++++++++++++++++++++++++++++++++|//
mk_data_model_ref
mk_architecture_get_data_model(mk_architecture_t architecture)
{
    // TODO - Support PowerPC here.  Need big-endian data models.
    if (mk_architecture_uses_64bit_abi(architecture)) {
        return mk_data_model_lp64();
    } else {
        return mk_data_model_ilp32();
    }
}

//----------------------------------------------------------------------------//
#pragma mark -  Description
//----------------------------------------------------------------------------//

//|++++++++++++++++++++++++++++++++++++|//
size_t
mk_architecture_copy_description(mk_architecture_t architecture, char *output, size_t output_len)
{
    const char *description = "";
    
    switch (architecture.cputype)
    {
        case CPU_TYPE_ANY:
            description = "ANY";
            break;
        case CPU_TYPE_VAX:
            description = "VAX";
            break;
        case CPU_TYPE_MC680x0:
            description = "MC680x0";
            break;
        //case CPU_TYPE_X86:
        case CPU_TYPE_I386:
            description = "i386";
            break;
        case CPU_TYPE_X86_64:
        {
            switch (architecture.cpusubtype) {
                case CPU_SUBTYPE_X86_64_H:
                    description = "x86_64h";
                    break;
                default:
                    description = "x86_64";
                    break;
            }
            break;
        }
        case CPU_TYPE_MC98000:
            description = "MC98000";
            break;
        case CPU_TYPE_HPPA:
            description = "HPPA";
            break;
        case CPU_TYPE_ARM:
        {
            switch (architecture.cpusubtype) {
                case CPU_SUBTYPE_ARM_V7K:
                    description = "armv7k";
                    break;
                case CPU_SUBTYPE_ARM_V7S:
                    description = "armv7s";
                    break;
                case CPU_SUBTYPE_ARM_V7F:
                    description = "armv7f";
                    break;
                case CPU_SUBTYPE_ARM_V7:
                    description = "armv7";
                    break;
                case CPU_SUBTYPE_ARM_V6:
                    description = "armv6";
                    break;
                default:
                    description = "ARM";
                    break;
            }
            break;
        }
        case CPU_TYPE_ARM64:
        {
            switch (architecture.cpusubtype) {
                case CPU_SUBTYPE_ARM64E:
                    description = "arm64e";
                    break;
                default:
                    description = "arm64";
                    break;
            }
            break;
        }
        case CPU_TYPE_ARM64_32:
        {
            description = "arm64_32";
            break;
        }
        case CPU_TYPE_MC88000:
            description = "MC88000";
            break;
        case CPU_TYPE_SPARC:
            description = "SPARC";
            break;
        case CPU_TYPE_I860:
            description = "I860";
            break;
        case CPU_TYPE_POWERPC:
            description = "PowerPC";
            break;
        case CPU_TYPE_POWERPC64:
            description = "PowerPC 64";
            break;
        default:
            description = "Unknown";
            break;
    }
    
    return (size_t)snprintf(output, output_len, "%s", description);
}
