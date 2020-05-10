//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       MKFatArch.h
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

#import <MachOKit/MKOffsetNode.h>

NS_ASSUME_NONNULL_BEGIN

//----------------------------------------------------------------------------//
//! An instance of \c MKFatArch parses the structure identifying a
//! slice in a fat binary.
//
@interface MKFatArch : MKOffsetNode {
@package
    cpu_type_t _cputype;
    cpu_subtype_t _cpusubtype;
    uint32_t _offset;
    uint32_t _size;
    uint32_t _align;
}

//! The architecture of the slice.
@property (nonatomic, readonly) mk_architecture_t architecture;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  fat_arch Values
//! @name       fat_arch Values
//!
//! @brief      These values are extracted directly from the fat_arch
//!             structure without modification or cleanup.
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//! CPU specifier.
@property (nonatomic, readonly) cpu_type_t cputype;
//! Machine specifier.
@property (nonatomic, readonly) cpu_subtype_t cpusubtype;
//! Offset to the Mach-O identified by the slice.
@property (nonatomic, readonly) uint32_t offset;
//! The size of the slice.
@property (nonatomic, readonly) uint32_t size;
//! The alignment of the slice.
@property (nonatomic, readonly) uint32_t align;

@end

NS_ASSUME_NONNULL_END
