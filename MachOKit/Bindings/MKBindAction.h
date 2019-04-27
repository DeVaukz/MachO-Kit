//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       MKBindAction.h
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
#import <MachOKit/MKBindingsFieldType.h>
#import <MachOKit/MKBindContext.h>

@class MKSegment;
@class MKSection;
@class MKBindCommand;

NS_ASSUME_NONNULL_BEGIN

//----------------------------------------------------------------------------//
@interface MKBindAction : MKAddressedNode {
@package
	mk_vm_offset_t _nodeOffset;
    MKSegment *_segment;
    MKOptional<MKSection*> *_section;
    mk_vm_offset_t _offset;
    MKBindType _type;
}

//! Returns the subclass of \ref MKBindCommand that is most suitable to
//! represent the bind action for the provided \a bindContext
+ (Class)classForContext:(struct MKBindContext*)bindContext;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Subclassing MKBindAction
//! @name       Subclassing MKBindAction
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//! This method is called on all \ref MKBindAction subclasses when
//! determining the appropriate class to instantiate to represent the bind
//! action for the provided \a bindContext.
//!
//! Subclasses should return a non-zero integer.  The subclass that returns the
//! largest value will be instantiated.  \ref MKBindAction subclasses in
//! Mach-O Kit return a value no larger than \c 100.  You can substitute your
//! own subclass by returning a larger value.
+ (uint32_t)canInstantiateWithContext:(struct MKBindContext*)bindContext;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Creating a Bind Action
//! @name       Creating a Bind Action
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

+ (nullable instancetype)actionWithContext:(struct MKBindContext*)bindContext error:(NSError**)error;

- (nullable instancetype)initWithParent:(null_unspecified MKNode*)parent error:(NSError**)error NS_UNAVAILABLE;

- (nullable instancetype)initWithContext:(struct MKBindContext*)bindContext error:(NSError**)error NS_DESIGNATED_INITIALIZER;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Binding Information
//! @name       Binding Information
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//! The bind action type.
@property (nonatomic, readonly) MKBindType type;

//! The segment where bind location resides.
@property (nonatomic, readonly) MKSegment *segment;

//! The offset from the start of the segment to the bind location.
@property (nonatomic, readonly) mk_vm_offset_t offset;

//! The VM address of the bind location.
@property (nonatomic, readonly) mk_vm_address_t address;

//! The section where the bind location resides.
@property (nonatomic, readonly) MKOptional<MKSection*> *section;

@end

NS_ASSUME_NONNULL_END
