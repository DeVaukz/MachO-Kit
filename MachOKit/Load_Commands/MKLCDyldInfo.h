//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       MKLCDyldInfo.h
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

#import <MachOKit/MKLoadCommand.h>

NS_ASSUME_NONNULL_BEGIN

//----------------------------------------------------------------------------//
//! Parser for \c LC_DYLD_INFO.
//!
//! The dyld_info_command contains the file offsets and sizes of
//! the new compressed form of the information dyld needs to
//! load the image.  This information is used by dyld on Mac OS X
//! 10.6 and later.  All information pointed to by this command
//! is encoded using byte streams, so no endian swapping is needed
//! to interpret it.
//
@interface MKLCDyldInfo : MKLoadCommand {
@package
    uint32_t _rebase_off;
    uint32_t _rebase_size;
    uint32_t _bind_off;
    uint32_t _bind_size;
    uint32_t _weak_bind_off;
    uint32_t _weak_bind_size;
    uint32_t _lazy_bind_off;
    uint32_t _lazy_bind_size;
    uint32_t _export_off;
    uint32_t _export_size;
}

@property (nonatomic, readonly) uint32_t rebase_off;
@property (nonatomic, readonly) uint32_t rebase_size;

@property (nonatomic, readonly) uint32_t bind_off;
@property (nonatomic, readonly) uint32_t bind_size;

@property (nonatomic, readonly) uint32_t weak_bind_off;
@property (nonatomic, readonly) uint32_t weak_bind_size;

@property (nonatomic, readonly) uint32_t lazy_bind_off;
@property (nonatomic, readonly) uint32_t lazy_bind_size;

@property (nonatomic, readonly) uint32_t export_off;
@property (nonatomic, readonly) uint32_t export_size;

@end

NS_ASSUME_NONNULL_END
