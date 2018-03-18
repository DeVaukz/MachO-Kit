//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       internal.h
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

#ifndef _internal_h
#define _internal_h

#include <sys/param.h>
#include <inttypes.h>

#if __MACHOKIT__
#include <objc/runtime.h>
#include <objc/message.h>
#endif

#include "base.h"

//----------------------------------------------------------------------------//
#pragma mark -  Visibility
/// @name       Visibility
//----------------------------------------------------------------------------//

//! Hide the following definition from other modules.
#if defined(DOXYGEN)
#   define _mk_weak_import
#elif __GNUC__ && defined(__cplusplus)
#   define _mk_weak_import extern "C" __attribute__((weak_import))
#elif __GNUC__
#   define _mk_weak_import extern __attribute__((weak_import))
#else
#   define _mk_weak_import
#endif


#endif /* _internal_h */
