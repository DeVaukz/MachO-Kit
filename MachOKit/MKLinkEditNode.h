//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       MKLinkEditNode.h
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

#import <MachOKit/MKBackedNode.h>

@class MKMemoryMap;
@class MKMachOImage;

NS_ASSUME_NONNULL_BEGIN

//----------------------------------------------------------------------------//
//! \c MKLinkEditNode is a specialization of \ref MKBackedNode for blobs
//! of data in the \c __LINKEDIT segment.  It contains logic for determining
//! the proper file offset and VM address for a range of memory, given
//! its offset to the data from the start of the Mach-O.
//
@interface MKLinkEditNode : MKBackedNode {
@package
    __unsafe_unretained MKMemoryMap *_memoryMap;
    mk_vm_address_t _nodeContextAddress;
    mk_vm_address_t _nodeVMAddress;
    mk_vm_size_t _nodeSize;
}

- (nullable instancetype)initWithSize:(mk_vm_size_t)size offset:(mk_vm_offset_t)offset inImage:(MKMachOImage*)image error:(NSError**)error;

@end

NS_ASSUME_NONNULL_END
