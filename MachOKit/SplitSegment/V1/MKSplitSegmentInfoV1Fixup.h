//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       MKSplitSegmentInfoV1Fixup.h
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

#import <MachOKit/MKAddressedNode.h>
#import <MachOKit/MKSplitSegmentInfoV1FieldType.h>
#import <MachOKit/MKSplitSegmentInfoV1Context.h>

NS_ASSUME_NONNULL_BEGIN

//----------------------------------------------------------------------------//
@interface MKSplitSegmentInfoV1Fixup : MKAddressedNode {
@package
    mk_vm_address_t _address;
    MKSplitSegmentInfoV1FixupType _kind;
    uint8_t _extra;
}

- (nullable instancetype)initWithContext:(struct MKSplitSegmentInfoV1Context*)context error:(NSError**)error NS_DESIGNATED_INITIALIZER;

- (nullable instancetype)initWithParent:(null_unspecified MKNode*)parent error:(NSError**)error NS_UNAVAILABLE;

//! The VM address of the fixup location.
@property (nonatomic, readonly) mk_vm_address_t address;

//! The fixup type.
@property (nonatomic, readonly) MKSplitSegmentInfoV1FixupType kind;

//! Extra data.
@property (nonatomic, readonly) uint8_t extra;

@end

NS_ASSUME_NONNULL_END
