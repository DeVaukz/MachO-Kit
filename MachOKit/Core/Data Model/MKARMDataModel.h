//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       MKARMDataModel.h
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

#import <MachOKit/MKAbstractDataModel.h>

NS_ASSUME_NONNULL_BEGIN

//----------------------------------------------------------------------------//
//! Implementation of \ref MKDataModel for the 32-bit ARM architecture.
//!
@interface MKARMDataModel : MKDataModel {
@package
    MKDataEndianness _endianness;
}

//! The ARM architecture allows running software in either endianness.
- (instancetype)initWithDataSource:(MKDataModel*)dataSource endianness:(MKDataEndianness)endianness;

@end



//----------------------------------------------------------------------------//
//! Implementation of \ref MKDataModel for the AARCH64 (64-bit ARM)
//! architecture.
//!
@interface MKAARCH64DataModel : MKDataModel {
@package
    MKDataEndianness _endianness;
}

//! The AARCH64 architecture allows running software in either endianness.
- (instancetype)initWithDataSource:(MKDataModel*)dataSource endianness:(MKDataEndianness)endianness;

@end

NS_ASSUME_NONNULL_END
