//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       MKNodeFieldCPUSubTypeI386.h
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
//! @name       I386 CPU SubTypes
//! @relates    MKNodeFieldCPUSubTypeI386SubType
//!
NS_SWIFT_NAME(MKCPUSubType.I386_All)
static const MKCPUSubType MKI386CPUSubTypeAll           = CPU_SUBTYPE_I386_ALL;
NS_SWIFT_NAME(MKCPUSubType.I386_486)
static const MKCPUSubType MKI386CPUSubType486           = CPU_SUBTYPE_486;
NS_SWIFT_NAME(MKCPUSubType.I386_486SX)
static const MKCPUSubType MKI386CPUSubType486SX         = CPU_SUBTYPE_486SX;
NS_SWIFT_NAME(MKCPUSubType.I386_586)
static const MKCPUSubType MKI386CPUSubType586           = CPU_SUBTYPE_586;
NS_SWIFT_NAME(MKCPUSubType.I386_PentiumPro)
static const MKCPUSubType MKI386CPUSubTypePentiumPro    = CPU_SUBTYPE_PENTPRO;
NS_SWIFT_NAME(MKCPUSubType.I386_PentiumM3)
static const MKCPUSubType MKI386CPUSubTypePentiumM3     = CPU_SUBTYPE_PENTII_M3;
NS_SWIFT_NAME(MKCPUSubType.I386_PentiumM5)
static const MKCPUSubType MKI386CPUSubTypePentiumM5     = CPU_SUBTYPE_PENTII_M5;
NS_SWIFT_NAME(MKCPUSubType.I386_Celeron)
static const MKCPUSubType MKI386CPUSubTypeCeleron       = CPU_SUBTYPE_CELERON;
NS_SWIFT_NAME(MKCPUSubType.I386_CeleronMobile)
static const MKCPUSubType MKI386CPUSubTypeCeleronMobile = CPU_SUBTYPE_CELERON_MOBILE;
NS_SWIFT_NAME(MKCPUSubType.I386_Pentium3)
static const MKCPUSubType MKI386CPUSubTypePentium3      = CPU_SUBTYPE_PENTIUM_3;
NS_SWIFT_NAME(MKCPUSubType.I386_Pentium3M)
static const MKCPUSubType MKI386CPUSubTypePentium3M     = CPU_SUBTYPE_PENTIUM_3_M;
NS_SWIFT_NAME(MKCPUSubType.I386_Pentium3Xeon)
static const MKCPUSubType MKI386CPUSubTypePentium3Xeon  = CPU_SUBTYPE_PENTIUM_3_XEON;
NS_SWIFT_NAME(MKCPUSubType.I386_PentiumM)
static const MKCPUSubType MKI386CPUSubTypePentiumM      = CPU_SUBTYPE_PENTIUM_M;
NS_SWIFT_NAME(MKCPUSubType.I386_Pentium4)
static const MKCPUSubType MKI386CPUSubTypePentium4      = CPU_SUBTYPE_PENTIUM_4;
NS_SWIFT_NAME(MKCPUSubType.I386_Pentium4M)
static const MKCPUSubType MKI386CPUSubTypePentium4M     = CPU_SUBTYPE_PENTIUM_4_M;
NS_SWIFT_NAME(MKCPUSubType.I386_Itanium)
static const MKCPUSubType MKI386CPUSubTypeItanium       = CPU_SUBTYPE_ITANIUM;
NS_SWIFT_NAME(MKCPUSubType.I386_Itanium2)
static const MKCPUSubType MKI386CPUSubTypeItanium2      = CPU_SUBTYPE_ITANIUM_2;
NS_SWIFT_NAME(MKCPUSubType.I386_Xeon)
static const MKCPUSubType MKI386CPUSubTypeXeon          = CPU_SUBTYPE_XEON;
NS_SWIFT_NAME(MKCPUSubType.I386_XeonMP)
static const MKCPUSubType MKI386CPUSubTypeXeonMP        = CPU_SUBTYPE_XEON_MP;



//----------------------------------------------------------------------------//
@interface MKNodeFieldCPUSubTypeI386 : MKNodeFieldCPUSubType

+ (instancetype)sharedInstance;

@end



//----------------------------------------------------------------------------//
@interface MKNodeFieldCPUSubTypeI386SubType : MKNodeFieldCPUSubTypeAnySubType

+ (instancetype)sharedInstance;

@end

NS_ASSUME_NONNULL_END
