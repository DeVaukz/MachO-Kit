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
#import <Foundation/Foundation.h>

#import <MachOKit/MKAddressedNode.h>
#import <MachOKit/MKRebaseFieldType.h>
#import <MachOKit/MKRebaseContext.h>

@class MKSegment;
@class MKSection;
@class MKRebaseCommand;

NS_ASSUME_NONNULL_BEGIN

//----------------------------------------------------------------------------//
@interface MKFixup : MKAddressedNode {
@package
	mk_vm_offset_t _nodeOffset;
    MKSegment *_segment;
    MKResult<MKSection*> *_section;
    mk_vm_offset_t _offset;
    MKRebaseType _type;
}

- (nullable instancetype)initWithParent:(null_unspecified MKNode*)parent error:(NSError**)error NS_UNAVAILABLE;

- (nullable instancetype)initWithContext:(struct MKRebaseContext*)rebaseContext error:(NSError**)error NS_DESIGNATED_INITIALIZER;

//! The segment where the fixup location resides.
@property (nonatomic, readonly) MKSegment *segment;

//! The offset from the start of the segment to the fixup location.
@property (nonatomic, readonly) mk_vm_offset_t offset;

//! The VM address of the fixup location.
@property (nonatomic, readonly) mk_vm_address_t address;

//! The section where the fixup location resides.
@property (nonatomic, readonly) MKResult<MKSection*> *section;

//!	The fixup type.
@property (nonatomic, readonly) MKRebaseType type;

@end

NS_ASSUME_NONNULL_END
