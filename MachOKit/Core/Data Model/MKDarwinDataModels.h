//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       MKDarwinDataModels.h
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
//! Concrete implementation of the \ref MKDataModel for the
//! data model used in 64-bit AARCH64 Mach-O images running on darwin OSs.
//!
@interface MKDarwinARM64DataModel : MKDataModel

//! Returns the shared \c MKDarwinARM64DataModel.
+ (MKDarwinARM64DataModel*)sharedDataModel;

- (instancetype)init;

@end



//----------------------------------------------------------------------------//
//! Concrete implementation of the \ref MKDataModel for the
//! data model used in 32-bit AARCH64 Mach-O images running on darwin OSs.
//!
@interface MKDarwinARMDataModel : MKDataModel

//! Returns the shared \c MKDarwinARMDataModel.
+ (MKDarwinARMDataModel*)sharedDataModel;

- (instancetype)init;

@end



//----------------------------------------------------------------------------//
//! Concrete implementation of the \ref MKDataModel for the
//! data model used in 64-bit Intel Mach-O images running on darwin OSs.
//!
@interface MKDarwinIntel64DataModel : MKDataModel

//! Returns the shared \c MKDarwinIntel64DataModel.
+ (MKDarwinIntel64DataModel*)sharedDataModel;

- (instancetype)init;

@end



//----------------------------------------------------------------------------//
//! Concrete implementation of the \ref MKDataModel for the
//! data model used in 32-bit Intel Mach-O images running on darwin OSs.
//!
@interface MKDarwinIntel32DataModel : MKDataModel

//! Returns the shared \c MKDarwinIntel32DataModel.
+ (MKDarwinIntel32DataModel*)sharedDataModel;

- (instancetype)init;

@end



//----------------------------------------------------------------------------//
//! Concrete implementation of the \ref MKDataModel for the data model
//! used in 32-bit PowerPC Mach-O images running on darwin OSs, as well as the
//! FAT header in universal binaries.
//!
@interface MKDarwinPPC32DataModel : MKDataModel

//! Returns the shared \c MKDarwinPPC32DataModel.
+ (MKDarwinPPC32DataModel*)sharedDataModel;

- (instancetype)init;

@end

NS_ASSUME_NONNULL_END
