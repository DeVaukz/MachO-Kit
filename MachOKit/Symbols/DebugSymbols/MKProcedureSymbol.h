//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       MKProcedureSymbol.h
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

#include <MachOKit/macho.h>
#import <Foundation/Foundation.h>

#import <MachOKit/MKDebugSymbol.h>

NS_ASSUME_NONNULL_BEGIN

//----------------------------------------------------------------------------//
@interface MKProcedureSymbol : MKDebugSymbol

//! The address or length of the procedure (see note).
//!
//! @note
//! When ld64 synthesizes STABS, each procedure is represented by two
//! N_FUN entires nested between N_BNSYM and N_ENSYM entires.  The first
//! N_FUN entry in the pair contains the procedure start address.  The second
//! N_FUN entry contains the procedure *length*.  This is a deviation from the
//! documented usage:
//!
//!   "Recent versions of GCC will mark the end of a function with an N_FUN
//!    symbol with an empty string for the name. The value is the address of
//!    the end of the current function."
//!
//! https://www.sourceware.org/gdb/onlinedocs/stabs.html#Procedures
@property (nonatomic, readonly) uint64_t address;

@end

NS_ASSUME_NONNULL_END
