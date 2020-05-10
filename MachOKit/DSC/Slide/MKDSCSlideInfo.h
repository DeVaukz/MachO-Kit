//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       MKDSCSlideInfo.h
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

@class MKSharedCache;
@class MKDSCSlideInfoHeader;
@class MKDSCSlideInfoBitmap;
@class MKDSCSlideInfoPage;
@class MKDSCSlidPointer;

NS_ASSUME_NONNULL_BEGIN

//----------------------------------------------------------------------------//
//! The slide info contains minimal rebasing information that is used to
//! update pointers in the read/write mapping when the shared cache is
//! loaded at a different base address.  The slide info is split into two
//! parts: the TOC, and entires.
//!
@interface MKDSCSlideInfo : MKBackedNode {
@package
    MKMemoryMap *_memoryMap;
    mk_vm_address_t _contextAddress;
    mk_vm_address_t _vmAddress;
    mk_vm_size_t _size;
    // Header //
    MKDSCSlideInfoHeader *_header;
    NSArray<MKDSCSlideInfoBitmap*> *_entries;
    NSArray<MKDSCSlideInfoPage*> *_toc;
    NSArray<MKDSCSlidPointer*> *_slidPointers;
}

- (nullable instancetype)initWithSharedCache:(MKSharedCache*)sharedCache error:(NSError**)error NS_DESIGNATED_INITIALIZER;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Header and Entires
//! @name       Header and Entries
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//!
@property (nonatomic, readonly) MKDSCSlideInfoHeader *header;

//!
@property (nonatomic, readonly) NSArray<MKDSCSlideInfoBitmap*> *entries;

//!
@property (nonatomic, readonly) NSArray<MKDSCSlideInfoPage*> *toc;

//!
@property (nonatomic, readonly) NSArray<MKDSCSlidPointer*> *slidPointers;

@end

NS_ASSUME_NONNULL_END
