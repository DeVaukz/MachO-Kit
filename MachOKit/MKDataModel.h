//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       MKDataModel.h
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

#define MKSwapLValue16(LVALUE, DATA_MODEL) \
    (LVALUE = DATA_MODEL.byteOrder->swap16( LVALUE ))
#define MKSwapLValue32(LVALUE, DATA_MODEL) \
    (LVALUE = DATA_MODEL.byteOrder->swap32( LVALUE ))
#define MKSwapLValue64(LVALUE, DATA_MODEL) \
    (LVALUE = DATA_MODEL.byteOrder->swap64( LVALUE ))



//----------------------------------------------------------------------------//
//! Instances of a class which conforms to the \c MKDataModel protocol
//! encapsulate details of a single instruction set architecture, which are
//! needed to properly parse a Mach-O image.
//!
@protocol MKDataModel <NSObject>

//! A structure of functions used to convert between the endianess of this
//! data model and the emdianess of the host process.
@property (nonatomic, readonly) const mk_byteorder_t *byteOrder;

//! The natural size of a pointer.
@property (nonatomic, readonly) size_t pointerSize;
//! The natural alignment of a pointer.
@property (nonatomic, readonly) size_t pointerAlignment;

@end



//----------------------------------------------------------------------------//
//! Concrete implementation of the \ref MKDataModel protocol for the ILP32
//! data model used in Intel/32-bit Mach-O images.
//!
@interface MKILP32DataModel : NSObject <MKDataModel>

//! Returns the shared \c MKILP32DataModel.
+ (instancetype)sharedDataModel;

@end



//----------------------------------------------------------------------------//
//! Concrete implementation of the \ref MKDataModel protocol for the LP64
//! data model used in Intel/64-bit Mach-O images.
//!
@interface MKLP64DataModel : NSObject <MKDataModel>

//! Returns the shared \c MKILP32DataModel.
+ (instancetype)sharedDataModel;

@end


//----------------------------------------------------------------------------//
//! Concrete implementation of the \ref MKDataModel protocol for the PPC32
//! data model used in PowerPC/32-bit Mach-O images, as well as the
//! FAT header in universal binaries.
//!
@interface MKPPC32DataModel : NSObject <MKDataModel>

//! Returns the shared \c MKILP32DataModel.
+ (instancetype)sharedDataModel;

@end
