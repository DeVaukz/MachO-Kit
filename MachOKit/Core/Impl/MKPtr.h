//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       MKPtr.h
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

#import <MachOKit/MKBase.h>

#import <MachOKit/MKBackedNode.h>
#import <MachOKit/MKResult.h>

NS_ASSUME_NONNULL_BEGIN

//----------------------------------------------------------------------------//
//! @struct MKPtr
//
struct MKPtr {
    MKBackedNode *parent;
    uint64_t __reserved;
    mk_vm_address_t address;
    uintptr_t __opaque;
};

//!
//! @param context
//!        The context is a mechanism for passing information from the node
//!        containing the pointer to the node representing the pointee, for use
//!        during its initialization.  Use of this mechanism is discouraged
//!        but is ocassionally necessary, for example, because only the node
//!        containing the pointer knows the size of the pointee.
_mk_internal_extern bool
MKPtrInitialize(struct MKPtr *ptr, MKBackedNode *node, mk_vm_address_t addr, NSDictionary<NSString*, id> * __nullable ctx, NSError **error);

//!
_mk_internal_extern void
MKPtrDestory(struct MKPtr *ptr);

//!
_mk_internal_extern __nullable Class
MKPtrTargetClass(struct MKPtr *ptr);

//!
_mk_internal_extern MKResult<__kindof MKBackedNode*> *
MKPtrPointee(struct MKPtr *ptr);

NS_ASSUME_NONNULL_END
