//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       MKNodeFieldCPUSubTypeX86.h
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
//! @name       X86 CPU SubTypes
//! @relates    MKNodeFieldCPUSubTypeX86SubType
//!
NS_SWIFT_NAME(MKCPUSubType.X86_All)
static const MKCPUSubType MKX86CPUSubTypeAll         = CPU_SUBTYPE_X86_ALL;
NS_SWIFT_NAME(MKCPUSubType.X8664_All)
static const MKCPUSubType MKX8664CPUSubTypeAll       = CPU_SUBTYPE_X86_64_ALL;
NS_SWIFT_NAME(MKCPUSubType.X8664_Haswell)
static const MKCPUSubType MKX8664CPUSubTypeHaswell   = CPU_SUBTYPE_X86_64_H;


//----------------------------------------------------------------------------//
//! @name       CPU Subtype Features for X86 64-bit
//! @relates    MKNodeFieldCPUSubTypeX86Features
//!
typedef NS_OPTIONS(uint32_t, MKCPUSubTypeX86Features) {
    MKCPUSubTypeX86FeatureLib64                     = CPU_SUBTYPE_LIB64
};



//----------------------------------------------------------------------------//
@interface MKNodeFieldCPUSubTypeX86 : MKNodeFieldCPUSubType

+ (instancetype)sharedInstance;

@end



//----------------------------------------------------------------------------//
@interface MKNodeFieldCPUSubTypeX86SubType : MKNodeFieldCPUSubTypeAnySubType

+ (instancetype)sharedInstance;

@end



//----------------------------------------------------------------------------//
@interface MKNodeFieldCPUSubTypeX86Features : MKNodeFieldCPUSubTypeFeatures <MKNodeFieldOptionSetType>

+ (instancetype)sharedInstance;

@end

NS_ASSUME_NONNULL_END
