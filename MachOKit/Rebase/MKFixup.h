//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       MKFixup.h
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

#import <MachOKit/MKOffsetNode.h>

@class MKSegment;
@class MKSection;
@class MKRebaseCommand;

NS_ASSUME_NONNULL_BEGIN

//----------------------------------------------------------------------------//
//! @name       Rebase Types
//! @relates    MKFixup
//!
//
typedef NS_ENUM(uint8_t, MKRebaseType) {
    MKRebaseTypePointer                     = REBASE_TYPE_POINTER,
    MKRebaseTypeTextAbsolute32              = REBASE_TYPE_TEXT_ABSOLUTE32,
    MKRebaseTypeTextPcrel32                 = REBASE_TYPE_TEXT_PCREL32
};



//----------------------------------------------------------------------------//
@interface MKFixup : MKOffsetNode {
@package
    MKSegment *_segment;
    MKSection *_section;
    mk_vm_offset_t _offset;
    mk_vm_size_t _nodeSize;
    MKRebaseType _type;
}

- (nullable instancetype)initWithParent:(null_unspecified MKNode*)parent error:(NSError**)error NS_UNAVAILABLE;
- (nullable instancetype)initWithOffset:(mk_vm_offset_t)offset fromParent:(MKBackedNode*)parent error:(NSError**)error NS_UNAVAILABLE;

- (nullable instancetype)initWithType:(uint8_t)type offset:(mk_vm_offset_t)offset segment:(unsigned)segmentIndex atCommand:(MKRebaseCommand*)command error:(NSError**)error NS_DESIGNATED_INITIALIZER;

//! The segment in which the location to be rebased resides.
@property (nonatomic, readonly) MKSegment *segment;

//! Offset from the start of the segment to the fixup location.
@property (nonatomic, readonly) mk_vm_offset_t offset;

//! VM address of the fixup location.
@property (nonatomic, readonly) mk_vm_address_t address;

//! The section in which the location to be rebased resides, or \c nil if it
//! does not reside in a known section.
@property (nonatomic, readonly, nullable) MKSection *section;

@property (nonatomic, readonly) MKRebaseType type;

@end

NS_ASSUME_NONNULL_END
