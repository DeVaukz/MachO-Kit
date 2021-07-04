//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       MKNodeFieldCPUSubTypeARM.h
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
//! @name       ARM CPU SubTypes
//! @relates    MKNodeFieldCPUSubTypeARMSubType
//!
NS_SWIFT_NAME(MKCPUSubType.ARM_All)
static const MKCPUSubType MKARMCPUSubTypeAll     = CPU_SUBTYPE_ARM_ALL;
NS_SWIFT_NAME(MKCPUSubType.ARM_V4T)
static const MKCPUSubType MKARMCPUSubTypeV4T     = CPU_SUBTYPE_ARM_V4T;
NS_SWIFT_NAME(MKCPUSubType.ARM_V6)
static const MKCPUSubType MKARMCPUSubTypeV6      = CPU_SUBTYPE_ARM_V6;
NS_SWIFT_NAME(MKCPUSubType.ARM_V5TEJ)
static const MKCPUSubType MKARMCPUSubTypeV5TEJ   = CPU_SUBTYPE_ARM_V5TEJ;
NS_SWIFT_NAME(MKCPUSubType.ARM_XScale)
static const MKCPUSubType MKARMCPUSubTypeXScale  = CPU_SUBTYPE_ARM_XSCALE;
NS_SWIFT_NAME(MKCPUSubType.ARM_V7)
static const MKCPUSubType MKARMCPUSubTypeV7      = CPU_SUBTYPE_ARM_V7;
NS_SWIFT_NAME(MKCPUSubType.ARM_V7F)
static const MKCPUSubType MKARMCPUSubTypeV7F     = CPU_SUBTYPE_ARM_V7F;
NS_SWIFT_NAME(MKCPUSubType.ARM_V7S)
static const MKCPUSubType MKARMCPUSubTypeV7S     = CPU_SUBTYPE_ARM_V7S;
NS_SWIFT_NAME(MKCPUSubType.ARM_V7K)
static const MKCPUSubType MKARMCPUSubTypeV7K     = CPU_SUBTYPE_ARM_V7K;
NS_SWIFT_NAME(MKCPUSubType.ARM_V6M)
static const MKCPUSubType MKARMCPUSubTypeV6M     = CPU_SUBTYPE_ARM_V6M;
NS_SWIFT_NAME(MKCPUSubType.ARM_V7M)
static const MKCPUSubType MKARMCPUSubTypeV7M     = CPU_SUBTYPE_ARM_V7M;
NS_SWIFT_NAME(MKCPUSubType.ARM_V7EM)
static const MKCPUSubType MKARMCPUSubTypeV7EM    = CPU_SUBTYPE_ARM_V7EM;
NS_SWIFT_NAME(MKCPUSubType.ARM_V8)
static const MKCPUSubType MKARMCPUSubTypeV8      = CPU_SUBTYPE_ARM_V8;



//----------------------------------------------------------------------------//
@interface MKNodeFieldCPUSubTypeARM : MKNodeFieldCPUSubType

+ (instancetype)sharedInstance;

@end



//----------------------------------------------------------------------------//
@interface MKNodeFieldCPUSubTypeARMSubType : MKNodeFieldCPUSubTypeAnySubType

+ (instancetype)sharedInstance;

@end

NS_ASSUME_NONNULL_END
