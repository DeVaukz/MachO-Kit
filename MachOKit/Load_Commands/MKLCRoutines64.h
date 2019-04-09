//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       MKLCRoutines64.h
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
@import Foundation;

#import <MachOKit/MKLoadCommand.h>

NS_ASSUME_NONNULL_BEGIN

//----------------------------------------------------------------------------//
//! Parser for \c LC_ROUTINES_64.
//!
//! The routines command contains the address of the dynamic shared library
//! initialization routine and an index into the module table for the module
//! that defines the routine.  Before any modules are used from the library the
//! dynamic linker fully binds the module that defines the initialization
//! routine and then calls it.  This gets called before any module
//! initialization routines (used for C++ static constructors) in the library.
//
@interface MKLCRoutines64 : MKLoadCommand {
@package
    uint64_t _init_address;
    uint64_t _init_module;
    uint64_t _reserved1;
    uint64_t _reserved2;
    uint64_t _reserved3;
    uint64_t _reserved4;
    uint64_t _reserved5;
    uint64_t _reserved6;
}

//! Address of initialization routine.
@property (nonatomic, readonly) uint64_t init_address;
//! Index into the module table that the init routine is defined in.
@property (nonatomic, readonly) uint64_t init_module;

@property (nonatomic, readonly) uint64_t reserved1;
@property (nonatomic, readonly) uint64_t reserved2;
@property (nonatomic, readonly) uint64_t reserved3;
@property (nonatomic, readonly) uint64_t reserved4;
@property (nonatomic, readonly) uint64_t reserved5;
@property (nonatomic, readonly) uint64_t reserved6;


@end

NS_ASSUME_NONNULL_END
