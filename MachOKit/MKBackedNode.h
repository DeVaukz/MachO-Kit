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
@import Foundation;

#import <MachOKit/MKNode.h>

NS_ASSUME_NONNULL_BEGIN

//----------------------------------------------------------------------------//
//! @name       Node Address Types
//! @relates    MKBackedNode
//!
typedef NS_ENUM(NSUInteger, MKNodeAddressType) {
    //! The address of the node with respect to its \ref memoryMap.
    //!
    //! @details
    //! For a memory map reading process memory, the context address matches
    //! the node's VM address plus any slide.
    //!
    //! For a memory map reading a file on disk, the context address *usually* 
    //! matches the offset of the node in the file.
    MKNodeContextAddress                = 0,
    //! The address of the node when the image is mapped into virtual memory.
    //!
    //! @details
    //! This value does not include any slide that is applied to the image.
    MKNodeVMAddress
};



//----------------------------------------------------------------------------//
//! \c MKBackedNode is a subclass of \ref MKNode which represents the parsed
//! contents in some fixed range of memory.
//!
@interface MKBackedNode : MKNode

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

//! Shortcut for calling the \ref -nodeAddress: method with the
//! \ref MKNodeContextAddress address type.
@property (nonatomic, readonly) mk_vm_address_t nodeContextAddress;

//! Shortcut for calling the \ref -nodeAddress: method with the
//! \ref MKNodeVMAddress address type.
@property (nonatomic, readonly) mk_vm_address_t nodeVMAddress;

//! Subclasses must implement this method.
- (mk_vm_address_t)nodeAddress:(MKNodeAddressType)type;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Accessing the Underlying Data
//! @name       Accessing the Underlying Data
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//! An \c NSData instance containing the contents of memory represented by
//! the node.
@property (nonatomic, readonly, nullable) NSData *data;

@end

NS_ASSUME_NONNULL_END
