//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       MKBackedNode.h
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

NS_ASSUME_NONNULL_BEGIN

//----------------------------------------------------------------------------//
//! \c MKBackedNode is a subclass of \ref MKNode which represents the parsed
//! contents in some fixed range of memory.
//!
@interface MKBackedNode : MKAddressedNode

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Memory Layout
//! @name       Memory Layout
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//! The size of the node.  Includes the size of all child nodes.
//! Subclasses must implement the getter for this property.
//!
//! @note
//! A value of \c 0 indicates the node size is unknown.  This value should only
//! be returned by top-level nodes such as \ref MKMachO.
@property (nonatomic, readonly) mk_vm_size_t nodeSize;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Accessing the Underlying Data
//! @name       Accessing the Underlying Data
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//! An \c NSData instance containing the contents of memory represented by
//! the node.
@property (nonatomic, readonly, nullable) NSData *data;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Looking Up Ancestor Nodes By Address
//! @name       Looking Up Ancestor Nodes By Address
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//!	Returns the nearest ancestor node occupying \a address, if it's class
//! matches the \a targetClass.
//!
//!	@param 	includeReceiver
//!			If \c YES, the search starts at the receiver.  Otherwise, the
//!			search starts at the receiver's parent.
//!
- (MKResult<__kindof MKBackedNode*> *)ancestorNodeOccupyingAddress:(mk_vm_address_t)address type:(MKNodeAddressType)addressType targetClass:(nullable Class)targetClass includeReceiver:(BOOL)includeReceiver;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Looking Up Child Nodes By Address
//! @name       Looking Up Child Nodes By Address
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//! Returns the child node occupying \a address.  Subclasses should override
//! this method.
- (MKResult<__kindof MKBackedNode*> *)childNodeOccupyingVMAddress:(mk_vm_address_t)address targetClass:(nullable Class)targetClass;

//! Returns the child node at \a address, if it's class matches the
//! \a targetClass.
- (MKResult<__kindof MKBackedNode*> *)childNodeAtVMAddress:(mk_vm_address_t)address targetClass:(nullable Class)targetClass;

//! Returns the child node at \a address.
- (MKResult<__kindof MKBackedNode*> *)childNodeAtVMAddress:(mk_vm_address_t)address;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Node Array Searching & Sorting
//! @name       Node Array Searching & Sorting
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//! Returns a sorted version of \a array, with nil optionals removed
+ (NSArray<__kindof MKBackedNode *> *)sortNodeArray:(NSArray<MKResult<__kindof MKBackedNode *> *> *)array;

//! Performs a fast binary search for the child node occupying \a address inside \a array
//!
//! @pre
//! \a array must be sorted in ascending order of \c nodeContextAddress. This may be done
//! using a method in \ref Node Array Sorting if required
+ (MKResult<__kindof MKBackedNode *> *)childNodeOccupyingVMAddress:(mk_vm_address_t)address targetClass:(Class)targetClass inSortedArray:(NSArray<__kindof MKBackedNode *> *)array;

@end

NS_ASSUME_NONNULL_END
