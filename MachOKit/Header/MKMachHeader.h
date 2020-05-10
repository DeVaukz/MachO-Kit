//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       MKMachHeader.h
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
//! The \c MKMachHeader parses the structure at the start of a Mach-O.
//
@interface MKMachHeader : MKOffsetNode {
@package
    uint32_t _magic;
    cpu_type_t _cputype;
    cpu_subtype_t _cpusubtype;
    uint32_t _filetype;
    uint32_t _ncmds;
    uint32_t _sizeofcmds;
    uint32_t _flags;
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Mach-O Header Values
//! @name       Mach-O Header Values
//!
//! @brief      These values are lifted directly from the Mach-O header
//!             without modification or cleanup.
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@property (nonatomic, readonly) uint32_t magic;
@property (nonatomic, readonly) cpu_type_t cputype;
@property (nonatomic, readonly) cpu_subtype_t cpusubtype;
@property (nonatomic, readonly) uint32_t filetype;
@property (nonatomic, readonly) uint32_t ncmds;
@property (nonatomic, readonly) uint32_t sizeofcmds;
@property (nonatomic, readonly) uint32_t flags;

@end

NS_ASSUME_NONNULL_END
