//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       MKNodeFieldCPUSubType.h
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

#include <mach/machine.h>

#import <MachOKit/MKNodeFieldTypeDoubleWord.h>
#import <MachOKit/MKNodeFieldBitfieldType.h>

#import <MachOKit/MKNodeFieldCPUSubTypeCapability.h>
#import <MachOKit/MKNodeFieldCPUSubTypeAny.h>
#import <MachOKit/MKNodeFieldCPUSubTypeI386.h>
#import <MachOKit/MKNodeFieldCPUSubTypeX86.h>
#import <MachOKit/MKNodeFieldCPUSubTypeARM.h>
#import <MachOKit/MKNodeFieldCPUSubTypeARM64.h>
#import <MachOKit/MKNodeFieldCPUSubTypeARM6432.h>
#import <MachOKit/MKNodeFieldCPUSubTypePowerPC.h>

NS_ASSUME_NONNULL_BEGIN

//----------------------------------------------------------------------------//
@interface MKNodeFieldCPUSubType : MKNodeFieldTypeDoubleWord <MKNodeFieldBitfieldType> {
@package
    MKNodeFieldCPUSubTypeAny *_implType;
    NSFormatter *_formatter;
}

+ (__kindof MKNodeFieldCPUSubType*)cpuSubTypeForCPUType:(cpu_type_t)cpuType;

- (instancetype)initWithCPUSubType:(nullable MKNodeFieldCPUSubTypeAny*)subtype NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
