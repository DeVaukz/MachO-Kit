//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       MKNodeFieldCPUType.h
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
#import <MachOKit/MKDataModel.h>
#import <MachOKit/MKNodeFieldTypeDoubleWord.h>
#import <MachOKit/MKNodeFieldEnumerationType.h>

#include <mach/machine.h>

NS_ASSUME_NONNULL_BEGIN

//----------------------------------------------------------------------------//
//! @name       CPU Types
//! @relates    MKNodeFieldCPUType
//!
typedef cpu_type_t MKCPUType NS_TYPED_EXTENSIBLE_ENUM;

static const MKCPUType MKCPUTypeAny               = CPU_TYPE_ANY;
static const MKCPUType MKCPUTypeVax               = CPU_TYPE_VAX;
/* skip 2,3,4,5 */
static const MKCPUType MKCPUTypeMC680x0           = CPU_TYPE_MC680x0;
static const MKCPUType MKCPUTypeI386              = CPU_TYPE_I386;
static const MKCPUType MKCPUTypeX86               = CPU_TYPE_X86;
static const MKCPUType MKCPUTypeX8664             = CPU_TYPE_X86_64;
/* skip 8,9 */
static const MKCPUType MKCPUTypeMC98000           = CPU_TYPE_MC98000;
static const MKCPUType MKCPUTypeHPPA              = CPU_TYPE_HPPA;
static const MKCPUType MKCPUTypeARM               = CPU_TYPE_ARM;
static const MKCPUType MKCPUTypeARM64             = CPU_TYPE_ARM64;
static const MKCPUType MKCPUTypeARM6432           = CPU_TYPE_ARM64_32;
static const MKCPUType MKCPUTypeMC88000           = CPU_TYPE_MC88000;
static const MKCPUType MKCPUTypeSPARC             = CPU_TYPE_SPARC;
static const MKCPUType MKCPUTypeI860              = CPU_TYPE_I860;
/* skip 16,17 */
static const MKCPUType MKCPUTypePowerPC           = CPU_TYPE_POWERPC;
static const MKCPUType MKCPUTypePowerPC64         = CPU_TYPE_POWERPC64;
/* skip 19,20,21,22 */



//----------------------------------------------------------------------------//
@interface MKNodeFieldCPUType : MKNodeFieldTypeDoubleWord <MKNodeFieldEnumerationType>

+ (instancetype)sharedInstance;

@end

NS_ASSUME_NONNULL_END
