//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       MKFatBinary.h
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
@class MKFatArch;

NS_ASSUME_NONNULL_BEGIN

//----------------------------------------------------------------------------//
//! An instance of \c MKFatBinary parses the header of a 'FAT' binary, and
//! provides interfaces to query the slices containined within.
//
@interface MKFatBinary : MKBackedNode {
@package
    MKMemoryMap *_memoryMap;
    NSArray<MKFatArch*> *_architectures;
    /// fat_header ///
    uint32_t _magic;
    uint32_t _nfat_arch;
}

//! Initializes the receiver with the provided \a memoryMap.  The FAT header
//! is expected to reside at address \c 0 in the provided memory map.
- (nullable instancetype)initWithMemoryMap:(MKMemoryMap*)memoryMap error:(NSError**)error NS_DESIGNATED_INITIALIZER;

//! An array of \ref MKFatArch instances, each represeting an architecture
//! present in the fat binary.
@property (nonatomic, readonly) NSArray<MKFatArch*> *architectures;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  fat_header Values
//! @name       fat_header Values
//!
//! @brief      These values are extracted directly from the fat_header
//!             structure without any modification or cleanup.
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//! FAT_MAGIC
@property (nonatomic, readonly) uint32_t magic;
//! The number of architectures in the fat binary.
@property (nonatomic, readonly) uint32_t nfat_arch;

@end

NS_ASSUME_NONNULL_END
