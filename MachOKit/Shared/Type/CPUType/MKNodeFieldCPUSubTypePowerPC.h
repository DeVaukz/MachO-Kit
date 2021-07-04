//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       MKNodeFieldCPUSubTypePowerPC.h
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
//! @name       PowerPC CPU SubTypes
//! @relates    MKNodeFieldCPUSubTypePowerPC
//!
NS_SWIFT_NAME(MKCPUSubType.PowerPC_All)
static const MKCPUSubType MKPowerPCCPUSubTypeAll     = CPU_SUBTYPE_POWERPC_ALL;
NS_SWIFT_NAME(MKCPUSubType.PowerPC_601)
static const MKCPUSubType MKPowerPCCPUSubType601     = CPU_SUBTYPE_POWERPC_601;
NS_SWIFT_NAME(MKCPUSubType.PowerPC_602)
static const MKCPUSubType MKPowerPCCPUSubType602     = CPU_SUBTYPE_POWERPC_602;
NS_SWIFT_NAME(MKCPUSubType.PowerPC_603)
static const MKCPUSubType MKPowerPCCPUSubType603     = CPU_SUBTYPE_POWERPC_603;
NS_SWIFT_NAME(MKCPUSubType.PowerPC_603e)
static const MKCPUSubType MKPowerPCCPUSubType603e    = CPU_SUBTYPE_POWERPC_603e;
NS_SWIFT_NAME(MKCPUSubType.PowerPC_603ev)
static const MKCPUSubType MKPowerPCCPUSubType603ev   = CPU_SUBTYPE_POWERPC_603ev;
NS_SWIFT_NAME(MKCPUSubType.PowerPC_604)
static const MKCPUSubType MKPowerPCCPUSubType604     = CPU_SUBTYPE_POWERPC_604;
NS_SWIFT_NAME(MKCPUSubType.PowerPC_604e)
static const MKCPUSubType MKPowerPCCPUSubType604e    = CPU_SUBTYPE_POWERPC_604e;
NS_SWIFT_NAME(MKCPUSubType.PowerPC_620)
static const MKCPUSubType MKPowerPCCPUSubType620     = CPU_SUBTYPE_POWERPC_620;
NS_SWIFT_NAME(MKCPUSubType.PowerPC_750)
static const MKCPUSubType MKPowerPCCPUSubType750     = CPU_SUBTYPE_POWERPC_750;
NS_SWIFT_NAME(MKCPUSubType.PowerPC_7400)
static const MKCPUSubType MKPowerPCCPUSubType7400    = CPU_SUBTYPE_POWERPC_7400;
NS_SWIFT_NAME(MKCPUSubType.PowerPC_7450)
static const MKCPUSubType MKPowerPCCPUSubType7450    = CPU_SUBTYPE_POWERPC_7450;
NS_SWIFT_NAME(MKCPUSubType.PowerPC_970)
static const MKCPUSubType MKPowerPCCPUSubType970     = CPU_SUBTYPE_POWERPC_970;



//----------------------------------------------------------------------------//
@interface MKNodeFieldCPUSubTypePowerPC : MKNodeFieldCPUSubType

+ (instancetype)sharedInstance;

@end



//----------------------------------------------------------------------------//
@interface MKNodeFieldCPUSubTypePowerPCSubType : MKNodeFieldCPUSubTypeAnySubType

+ (instancetype)sharedInstance;

@end

NS_ASSUME_NONNULL_END
