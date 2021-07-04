//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       MKNodeFieldCPUSubTypePowerPC64.h
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

#import <MachOKit/MKNodeFieldCPUSubType.h>
#import <MachOKit/MKNodeFieldCPUSubTypeFeatures.h>
#import <MachOKit/MKNodeFieldCPUSubTypeAny.h>

NS_ASSUME_NONNULL_BEGIN

//----------------------------------------------------------------------------//
//! @name       CPU Subtype Features for PowerPC 64-bit
//! @relates    MKNodeFieldCPUSubTypePowerPC64Features
//!
typedef NS_OPTIONS(uint32_t, MKCPUSubTypePowerPC64Features) {
    MKCPUSubTypePowerPC64FeatureLib64                = CPU_SUBTYPE_LIB64
};



//----------------------------------------------------------------------------//
@interface MKNodeFieldCPUSubTypePowerPC64 : MKNodeFieldCPUSubType

+ (instancetype)sharedInstance;

@end



//----------------------------------------------------------------------------//
@interface MKNodeFieldCPUSubTypePowerPC64SubType : MKNodeFieldCPUSubTypeAnySubType

+ (instancetype)sharedInstance;

@end



//----------------------------------------------------------------------------//
@interface MKNodeFieldCPUSubTypePowerPC64Features : MKNodeFieldCPUSubTypeFeatures <MKNodeFieldOptionSetType>

+ (instancetype)sharedInstance;

@end

NS_ASSUME_NONNULL_END
