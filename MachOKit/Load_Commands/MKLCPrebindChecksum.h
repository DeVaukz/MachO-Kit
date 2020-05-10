//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       MKLCPrebindChecksum.h
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
//! Parser for \c LC_PREBIND_CKSUM.
//!
//! The prebind_cksum_command contains the value of the original check sum for
//! prebound files or zero.  When a prebound file is first created or modified
//! for other than updating its prebinding information the value of the check
//! sum is set to zero.  When the file has it prebinding re-done and if the
//! value of the check sum is zero the original check sum is calculated and
//! stored in cksum field of this load command in the output file.  If when
//! the prebinding is re-done and the cksum field is non-zero it is left
//! unchanged from the input file.
//
@interface MKLCPrebindChecksum : MKLoadCommand {
@package
    uint32_t _cksum;
}

//! The checksum or zero.
@property (nonatomic, readonly) uint32_t cksum;

@end

NS_ASSUME_NONNULL_END
