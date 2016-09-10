//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       architecture.h
//!
//! @author     D.V.
//! @copyright  Copyright (c) 2014-2015 D.V. All rights reserved.
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

//----------------------------------------------------------------------------//
//! @defgroup ARCHITECTURE Architecture
//! @ingroup CORE
//!
//! An architecture specifies basic information about a CPU.
//----------------------------------------------------------------------------//

#ifndef _architecture_h
#define _architecture_h

//! @addtogroup ARCHITECTURE
//! @{
//!

//----------------------------------------------------------------------------//
#pragma mark -  Types
//! @name       Types
//----------------------------------------------------------------------------//

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
//! @internal
//
typedef struct mk_architecture_s {
    cpu_type_t cputype;
    cpu_subtype_t cpusubtype;
} mk_architecture_t;

//! Unknown architecture
static const mk_architecture_t mk_architecture_unknown = { 0, 0 };

//! Architecture for i386 CPUs.
static const mk_architecture_t mk_architecture_i386 = { CPU_TYPE_I386, CPU_SUBTYPE_I386_ALL };

//! Architecture for all x86_64 CPUs.
static const mk_architecture_t mk_architecture_x86_64 = { CPU_TYPE_X86_64, CPU_SUBTYPE_X86_64_ALL };

//! Architecture for all x86_64 Haswell CPUs.
static const mk_architecture_t mk_architecture_x86_64h = { CPU_TYPE_X86_64, CPU_SUBTYPE_X86_64_H };

//! Architecture for generic ARM CPUs.
static const mk_architecture_t mk_architecture_arm = { CPU_TYPE_ARM, CPU_SUBTYPE_ARM_ALL };

//! Architecture for ARMv7 CPUs.
static const mk_architecture_t mk_architecture_armv7 = { CPU_TYPE_ARM, CPU_SUBTYPE_ARM_V7 };

//! Architecture for ARMv7f CPUs.
static const mk_architecture_t mk_architecture_armv7f = { CPU_TYPE_ARM, CPU_SUBTYPE_ARM_V7F };

//! Architecture for ARMv7s CPUs.
static const mk_architecture_t mk_architecture_armv7s = { CPU_TYPE_ARM, CPU_SUBTYPE_ARM_V7S };

//! Architecture for ARMv7k CPUs.
static const mk_architecture_t mk_architecture_armv7k = { CPU_TYPE_ARM, CPU_SUBTYPE_ARM_V7K };

//! Architecture for 64-bit ARM CPUs.
static const mk_architecture_t mk_architecture_arm64 = { CPU_TYPE_ARM64, CPU_SUBTYPE_ARM64_ALL };


//----------------------------------------------------------------------------//
#pragma mark -  Creating An Architecture
//! @name       Creating An Architecture
//----------------------------------------------------------------------------//

//!  Create a new architecture structure with the given CPU type and subtype.
_mk_inine mk_architecture_t
mk_architecture_create(cpu_type_t type, cpu_subtype_t subtype)
{
    mk_architecture_t arch;
    arch.cputype = type;
    arch.cpusubtype = subtype;
    return arch;
}


//----------------------------------------------------------------------------//
#pragma mark -  Retrieving Information About An Architecture
//! @name       Retrieving Information About An Architecture
//----------------------------------------------------------------------------//

//! Returns the CPU type of the provided \a architecture.
_mk_inine cpu_type_t
mk_architecture_get_cpu_type(mk_architecture_t architecture)
{ return architecture.cputype; }

//! Returns the CPU subtype of the provided \a architecture.
_mk_inine cpu_subtype_t
mk_architecture_get_cpu_subtype(mk_architecture_t architecture)
{ return architecture.cpusubtype; }

//! Returns true if the provided \a architecture uses a 64-bit ABI.
_mk_inine bool
mk_architecture_uses_64bit_abi(mk_architecture_t architecture)
{ return !!(architecture.cputype & CPU_ARCH_ABI64); }


//----------------------------------------------------------------------------//
#pragma mark -  Comparing Architectures
//! @name       Comparing Architectures
//----------------------------------------------------------------------------//

//! Returns true if the provided architecturs are equal.
_mk_inine bool
mk_architecture_equal_to_architecture(mk_architecture_t architecture, mk_architecture_t other)
{ return (architecture.cputype == other.cputype && architecture.cpusubtype == other.cpusubtype); }


//! @} ARCHITECTURE !//

#endif /* _architecture_h */
