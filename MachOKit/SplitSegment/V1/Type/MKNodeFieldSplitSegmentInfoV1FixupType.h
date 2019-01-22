//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       MKNodeFieldSplitSegmentInfoV1FixupType.h
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

#include <mach-o/loader.h>

#import <MachOKit/MKNodeFieldTypeByte.h>
#import <MachOKit/MKNodeFieldEnumerationType.h>

// <https://opensource.apple.com/source/ld64/ld64-409.12/src/abstraction/MachOFileAbstraction.hpp.auto.html>
#ifndef DYLD_CACHE_ADJ_V1_POINTER_32
    #define DYLD_CACHE_ADJ_V1_POINTER_32 0x01
#endif
#ifndef DYLD_CACHE_ADJ_V1_POINTER_64
    #define DYLD_CACHE_ADJ_V1_POINTER_64 0x02
#endif
#ifndef DYLD_CACHE_ADJ_V1_ADRP
    #define DYLD_CACHE_ADJ_V1_ADRP 0x03
#endif
#ifndef DYLD_CACHE_ADJ_V1_ARM_THUMB_MOVT
    #define DYLD_CACHE_ADJ_V1_ARM_THUMB_MOVT 0x10
#endif
#ifndef DYLD_CACHE_ADJ_V1_ARM_MOVT
    #define DYLD_CACHE_ADJ_V1_ARM_MOVT 0x20
#endif

NS_ASSUME_NONNULL_BEGIN

//----------------------------------------------------------------------------//
//! @name       Split Segment Info V1 Fixup Type
//! @relates    MKNodeFieldSplitSegmentInfoV1FixupType
//!
//
typedef uint8_t MKSplitSegmentInfoV1FixupType NS_TYPED_EXTENSIBLE_ENUM;

static const MKSplitSegmentInfoV1FixupType MKSplitSegmentInfoV1FixupTypePointer32       = DYLD_CACHE_ADJ_V1_POINTER_32;
static const MKSplitSegmentInfoV1FixupType MKSplitSegmentInfoV1FixupTypePointer64       = DYLD_CACHE_ADJ_V1_POINTER_64;
static const MKSplitSegmentInfoV1FixupType MKSplitSegmentInfoV1FixupTypeADRP            = DYLD_CACHE_ADJ_V1_ADRP;
static const MKSplitSegmentInfoV1FixupType MKSplitSegmentInfoV1FixupTypeARMThumbMOVT    = DYLD_CACHE_ADJ_V1_ARM_THUMB_MOVT;
static const MKSplitSegmentInfoV1FixupType MKSplitSegmentInfoV1FixupTypeARMMOVT         = DYLD_CACHE_ADJ_V1_ARM_MOVT;



//----------------------------------------------------------------------------//
@interface MKNodeFieldSplitSegmentInfoV1FixupType : MKNodeFieldTypeUnsignedByte <MKNodeFieldEnumerationType>

+ (instancetype)sharedInstance;

@end

NS_ASSUME_NONNULL_END
