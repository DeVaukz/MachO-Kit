//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       MKDSCMapping.h
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

#import <MachOKit/MKBackedNode.h>

@class MKSharedCache;
@class MKDSCMappingInfo;

NS_ASSUME_NONNULL_BEGIN

//----------------------------------------------------------------------------//
@interface MKDSCMapping : MKBackedNode {
@package
    mk_vm_address_t _contextAddress;
    //
    mk_vm_address_t _vmAddress;
    mk_vm_size_t _vmSize;
    mk_vm_offset_t _fileOffset;
    vm_prot_t _maximumProtection;
    vm_prot_t _initialProtection;
}

- (nullable instancetype)initWithSharedCache:(MKSharedCache*)sharedCache vmAddress:(mk_vm_address_t)vmAddress vmSize:(mk_vm_size_t)vmSize fileOffset:(mk_vm_offset_t)fileOffset initialProtection:(vm_prot_t)initialProtection maximumProtection:(vm_prot_t)maximumProtection error:(NSError**)error NS_DESIGNATED_INITIALIZER;

- (nullable instancetype)initWithDescriptor:(MKDSCMappingInfo*)descriptor error:(NSError**)error;

@property (nonatomic, readonly) mk_vm_address_t vmAddress;
@property (nonatomic, readonly) mk_vm_size_t vmSize;
@property (nonatomic, readonly) mk_vm_offset_t fileOffset;

@property (nonatomic, readonly) vm_prot_t maximumProtection;
@property (nonatomic, readonly) vm_prot_t initialProtection;

@end

NS_ASSUME_NONNULL_END
