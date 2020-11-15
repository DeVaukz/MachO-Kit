//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       MKPointerNode.h
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
#import <MachOKit/MKPointer.h>

NS_ASSUME_NONNULL_BEGIN

//----------------------------------------------------------------------------//
//! An \c MKPointerNode is a an \ref MKNode subclass that parses a single
//! pointer.
//!
@interface MKPointerNode<Pointee> : MKOffsetNode {
@package
    mk_vm_address_t _address;
    uintptr_t _pointee;
}

- (nullable instancetype)initWithOffset:(mk_vm_offset_t)offset fromParent:(MKBackedNode*)parent mask:(mk_vm_address_t)mask context:(nullable NSDictionary<NSString*, id>*)context error:(NSError**)error NS_DESIGNATED_INITIALIZER;

- (nullable instancetype)initWithOffset:(mk_vm_offset_t)offset fromParent:(MKBackedNode*)parent context:(nullable NSDictionary<NSString*, id>*)context error:(NSError**)error;

- (nullable instancetype)initWithOffset:(mk_vm_offset_t)offset fromParent:(MKBackedNode*)parent mask:(mk_vm_address_t)mask targetClass:(nullable Class)targetClass error:(NSError**)error;

- (nullable instancetype)initWithOffset:(mk_vm_offset_t)offset fromParent:(MKBackedNode*)parent targetClass:(nullable Class)targetClass error:(NSError**)error;

//! The address referenced by the pointer.
@property (nonatomic, readonly) mk_vm_address_t address;

//! The class of the node that the pointer is expected to reference.
@property (nonatomic, readonly, nullable) Class targetClass;

//! The node referenced by the pointer.
@property (nonatomic, readonly) MKResult<Pointee> *pointee;

@end

NS_ASSUME_NONNULL_END
