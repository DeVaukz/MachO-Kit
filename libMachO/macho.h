//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       macho.h
//!
//! @author     D.V.
//! @copyright  Copyright (c) 2014-2015 D.V. All rights reserved.
//!
//! @brief
//! The root include for libMachO.
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
//! @mainpage libMachO
//!
//! @section sec_intro Introduction
//! libMachO is a lightweight, C library for parsing Mach-O binaries. To keep
//! the library lightweight libMachO overlays itself atop the MachO binary and
//! provides a structured set of APIs to parse the data. libMachO does not
//! build up its own independent representation of the Mach-O opting to
//! continuously walk the Mach-O structures to access requested data.  This
//! means that libMachO generally expects well-formed MachO binaries.
//!
//! Differences between the target architecture of the Mach-O binary and your
//! process are handled by libMachO.  Access to data of the Mach-O binary is
//! abstracted by a memory map and one or more memory objects vended by the
//! map.  libMachO includes memory maps for accessing MachO binaries loaded
//! into the current process, or another process for which your process has
//! rights to the task port.  Memory access through a memory map is checked to
//! ensure invalid memory cannot be accidentally accessed, in the case of a
//! malformed Mach-O binary.
//!
//! libMachO does not perform any dynamic memory allocation.  Clients are
//! responsible for allocating buffers which are then initialized by the
//! various parsers in libMachO.  Consequently, the lifetimes of these buffers
//! must be managed by clients.
//----------------------------------------------------------------------------//

#ifndef _macho_h
#define _macho_h

#ifdef __APPLE__
    #include <TargetConditionals.h>
#endif

#define MK_API_VERSION 1

#include "core.h"
#include "macho_abi.h"

#endif /* _macho_h */
