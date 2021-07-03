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
    
    cpu_type_t cputype = mk_architecture_get_cpu_type(architecture);
    cpu_subtype_t cpusubtype = mk_architecture_get_cpu_subtype(architecture);
    
    switch (cputype)
    {
        case CPU_TYPE_ANY:
        {
            switch (cpusubtype) {
                case CPU_SUBTYPE_LITTLE_ENDIAN:
                    description = "little";
                    break;
                case CPU_SUBTYPE_BIG_ENDIAN:
                    description = "big";
                    break;
                case CPU_SUBTYPE_MULTIPLE:
                default:
                    description = "any";
                    break;
            }
            break;
        }
        case CPU_TYPE_VAX:
            description = "vax";
            break;
        case CPU_TYPE_MC680x0:
        {
            switch (cpusubtype) {
                case CPU_SUBTYPE_MC68040:
                    description = "m68040";
                    break;
                case CPU_SUBTYPE_MC68030_ONLY:
                    description = "m68030";
                    break;
                default:
                    description = "m68k";
                    break;
            }
            break;
        }
        //case CPU_TYPE_X86:
        case CPU_TYPE_I386:
        {
            switch (cpusubtype) {
                case CPU_SUBTYPE_486:
                    description = "i486";
                    break;
                case CPU_SUBTYPE_486SX:
                    description = "i486SX";
                    break;
                case CPU_SUBTYPE_PENT:
                    description = "pentium";
                    break;
                case CPU_SUBTYPE_PENTPRO:
                    description = "pentpro";
                    break;
                case CPU_SUBTYPE_PENTII_M3:
                    description = "pentIIm3";
                    break;
                case CPU_SUBTYPE_PENTII_M5:
                    description = "pentIIm5";
                    break;
                default:
                    description = "i386";
                    break;
            }
            break;
        }
        case CPU_TYPE_X86_64:
        {
            switch (cpusubtype) {
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
            description = "hppa";
            break;
        case CPU_TYPE_ARM:
        {
            switch (cpusubtype) {
                case CPU_SUBTYPE_ARM_V4T:
                    description = "armv4t";
                    break;
                case CPU_SUBTYPE_ARM_V6:
                    description = "armv6";
                    break;
                case CPU_SUBTYPE_ARM_V5TEJ:
                    description = "armv5";
                    break;
                case CPU_SUBTYPE_ARM_XSCALE:
                    description = "xscale";
                    break;
                case CPU_SUBTYPE_ARM_V7:
                    description = "armv7";
                    break;
                case CPU_SUBTYPE_ARM_V7F:
                    description = "armv7f";
                    break;
                case CPU_SUBTYPE_ARM_V7S:
                    description = "armv7s";
                    break;
                case CPU_SUBTYPE_ARM_V7K:
                    description = "armv7k";
                    break;
                case CPU_SUBTYPE_ARM_V6M:
                    description = "armv6m";
                    break;
                case CPU_SUBTYPE_ARM_V7M:
                    description = "armv7m";
                    break;
                case CPU_SUBTYPE_ARM_V7EM:
                    description = "armv7em";
                    break;
                default:
                    description = "arm";
                    break;
            }
            break;
        }
        case CPU_TYPE_ARM64:
        {
            switch (cpusubtype) {
                case CPU_SUBTYPE_ARM64_V8:
                    description = "arm64v8";
                    break;
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
            description = "arm64_32";
            break;
        case CPU_TYPE_MC88000:
            description = "m88k";
            break;
        case CPU_TYPE_SPARC:
            description = "sparc";
            break;
        case CPU_TYPE_I860:
            description = "i860";
            break;
        case CPU_TYPE_POWERPC:
        {
            switch (cpusubtype) {
                case CPU_SUBTYPE_POWERPC_601:
                    description = "ppc601";
                    break;
                case CPU_SUBTYPE_POWERPC_602:
                    description = "ppc602";
                    break;
                case CPU_SUBTYPE_POWERPC_603:
                    description = "ppc603";
                    break;
                case CPU_SUBTYPE_POWERPC_603e:
                    description = "ppc603e";
                    break;
                case CPU_SUBTYPE_POWERPC_603ev:
                    description = "ppc603ev";
                    break;
                case CPU_SUBTYPE_POWERPC_604:
                    description = "ppc604";
                    break;
                case CPU_SUBTYPE_POWERPC_604e:
                    description = "ppc604e";
                    break;
                case CPU_SUBTYPE_POWERPC_620:
                    description = "ppc620";
                    break;
                case CPU_SUBTYPE_POWERPC_750:
                    description = "ppc750";
                    break;
                case CPU_SUBTYPE_POWERPC_7400:
                    description = "ppc7400";
                    break;
                case CPU_SUBTYPE_POWERPC_7450:
                    description = "ppc7450";
                    break;
                case CPU_SUBTYPE_POWERPC_970:
                    description = "ppc970";
                    break;
                default:
                    description = "ppc";
                    break;
            }
            break;
        }
        case CPU_TYPE_POWERPC64:
        {
            switch (cpusubtype) {
                case CPU_SUBTYPE_POWERPC_970:
                    description = "ppc970-64";
                    break;
                default:
                    description = "ppc64";
                    break;
            }
            break;
        }
        default:
            description = "unknown";
            break;
    }
    
    return (size_t)snprintf(output, output_len, "%s", description);
}
