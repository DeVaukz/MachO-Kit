//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       MKNodeFieldSegmentFlagsType.h
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

#include <mach-o/loader.h>

#import <MachOKit/MKNodeFieldTypeDoubleWord.h>
#import <MachOKit/MKNodeFieldOptionSetType.h>

NS_ASSUME_NONNULL_BEGIN

//----------------------------------------------------------------------------//
//! @name       Segment Flags
//! @relates    MKNodeFieldSegmentFlagsType
//!
//
typedef NS_OPTIONS(uint32_t, MKSegmentFlags) {
    //! The file contents for this segment is for the high part of the VM
    //! space, the low part is zero filled (for stacks in core files).
    MKSegmentHighVM                             = SG_HIGHVM,
    //! This segment is the VM that is allocated by a fixed VM library, for
    //! overlap checking in the link editor.
    MKSegmentFixedVM                            = SG_FVMLIB,
    //! This segment has nothing that was relocated in it and nothing
    //! relocated to it, that is it maybe safely replaced without relocation.
    MKSegmentNoRelocations                      = SG_NORELOC,
    //! This segment is protected.  If the segment starts at file offset 0,
    //! the first page of the segment is not protected.  All other pages of
    //! the segment are protected.
    MKSegmentProtectedV1                        = SG_PROTECTED_VERSION_1
};



//----------------------------------------------------------------------------//
@interface MKNodeFieldSegmentFlagsType : MKNodeFieldTypeUnsignedDoubleWord <MKNodeFieldOptionSetType>

+ (instancetype)sharedInstance;

@end

NS_ASSUME_NONNULL_END
