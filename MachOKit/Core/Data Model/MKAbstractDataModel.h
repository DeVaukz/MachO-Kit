//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       MKAbstractDataModel.h
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

NS_ASSUME_NONNULL_BEGIN

//----------------------------------------------------------------------------//
//! @name       Endianness
//! @relates    MKDataModel
//!
typedef NS_ENUM(int, MKDataEndianness) {
    MKDataEndiannessUnknown     = 0,
    MKDataEndiannessBig,
    MKDataEndiannessLittle
};


//----------------------------------------------------------------------------//
//! Instances of the\c MKDataModel class encapsulate details of a single
//! instruction set architecture and ABI, which are needed to properly parse
//! a Mach-O image.
//!
//! @note
//! The \c MKDataModel class is semi-abstract and should not be instantiated
//! directly.
//!
@interface MKDataModel : NSObject {
@package
    MKDataModel *_dataSource;
}

- (instancetype)initWithDataSource:(MKDataModel*)dataSource NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Byte Order
//! @name       Byte Order
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//! The endianess of the data.
@property (readonly) MKDataEndianness endianness;

//! A structure of functions used to convert between the endianess of this
//! data model and the endianess of the host process.
@property (readonly) const mk_byteorder_t *byteOrder;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Pointers
//! @name       Pointers
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//! The natural size of a pointer, in bytes.
@property (readonly) size_t pointerSize;
//! The natural alignment of a pointer, in bytes.
@property (readonly) size_t pointerAlignment;

//! A mask that specifies which of the pointer's bits hold the "canonical form"
//! address, as specified by the processor architecture and ABI.
//!
//! Certain processor architectures permit only a subset of the total possible
//! virtual address space to be used for address translation.  Therefore, only
//! a lower subset of the pointer's bits are used to store the target address,
//! with the remaining "high" bits being copies of the most significant bit
//! (akin to a sign extension).
//!
//! The OS ABI may further reduce the total possible virtual address space,
//! which confines the target address to an even smaller subset of the pointer's
//! bits.
@property (readonly) uint64_t pointerMask;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Fundamental (C) Types
//! @name       Fundamental (C) Types
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//! The natural size of a \c short, in bytes.
@property (readonly) size_t shortSize;
//! The natural alignment of a \c short, in bytes.
@property (readonly) size_t shortAlignment;

//! The natural size of an \c int, in bytes.
@property (readonly) size_t intSize;
//! The natural alignment of an \c int, in bytes.
@property (readonly) size_t intAlignment;

//! The natural size of a \c long, in bytes.
@property (readonly) size_t longSize;
//! The natural alignment of a \c long, in bytes.
@property (readonly) size_t longAlignment;

//! The natural size of a \c long \c long, in bytes.
@property (readonly) size_t longlongSize;
//! The natural alignment of a \c long \c long, in bytes.
@property (readonly) size_t longlongAlignment;

@end

NS_ASSUME_NONNULL_END
