//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       MKNodeFieldSectionType.h
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
#import <Foundation/Foundation.h>

#include <mach-o/loader.h>

#import <MachOKit/MKNodeFieldTypeByte.h>
#import <MachOKit/MKNodeFieldEnumerationType.h>

NS_ASSUME_NONNULL_BEGIN

//----------------------------------------------------------------------------//
//! @name       Section Types
//! @relates    MKNodeFieldSectionType
//!
//
typedef uint8_t MKSectionType NS_TYPED_EXTENSIBLE_ENUM;

//! Regular section
static const MKSectionType MKSectionTypeRegular                        = S_REGULAR;
//! Zzero fill on demand section
static const MKSectionType MKSectionTypeZeroFill                       = S_ZEROFILL;
//! Section with only literal C strings
static const MKSectionType MKSectionTypeCStringLiterals                = S_CSTRING_LITERALS;
//! Section with only 4 byte literals
static const MKSectionType MKSectionType4ByteLiterals                  = S_4BYTE_LITERALS;
//! Section with only 8 byte literals
static const MKSectionType MKSectionType8ByteLiterals                  = S_8BYTE_LITERALS;
//! Section with only pointers to literals
static const MKSectionType MKSectionTypeLiteralPointers                = S_LITERAL_POINTERS;
//! Section with only non-lazy symbol pointers
static const MKSectionType MKSectionTypeNonLazySymbolPointers          = S_NON_LAZY_SYMBOL_POINTERS;
//! Section with only lazy symbol pointers
static const MKSectionType MKSectionTypeLazySymbolPointers             = S_LAZY_SYMBOL_POINTERS;
//! Section with only symbol stubs, byte size of stub in the reserved2 field
static const MKSectionType MKSectionTypeSymbolStubs                    = S_SYMBOL_STUBS;
//! Section with only function pointers for initialization
static const MKSectionType MKSectionTypeModInitFunctionPointers        = S_MOD_INIT_FUNC_POINTERS;
//! Section with only function pointers for termination
static const MKSectionType MKSectionTypeModTermFunctionPointers        = S_MOD_TERM_FUNC_POINTERS;
//! Section contains symbols that are to be coalesced
static const MKSectionType MKSectionTypeCoalesced                      = S_COALESCED;
//! Zero fill on demand section (that can be larger than 4 gigabytes)
static const MKSectionType MKSectionTypeGBZeroFill                     = S_GB_ZEROFILL;
//! Section with only pairs of function pointers for interposing
static const MKSectionType MKSectionTypeInterposing                    = S_INTERPOSING;
//! section with only 16 byte literals
static const MKSectionType MKSectionType16ByteLiterals                 = S_16BYTE_LITERALS;
//! Section contains DTrace Object Format
static const MKSectionType MKSectionTypeDTraceDOF                      = S_DTRACE_DOF;
//! Section with only lazy symbol pointers to lazy loaded dylibs
static const MKSectionType MKSectionTypeLazyDylibSymbolPointers        = S_LAZY_DYLIB_SYMBOL_POINTERS;
//! Template of initial values for TLVs
static const MKSectionType MKSectionTypeThreadLocalRegular             = S_THREAD_LOCAL_REGULAR;
//! Template of initial values for TLVs
static const MKSectionType MKSectionTypeThreadLocalZeroFill            = S_THREAD_LOCAL_ZEROFILL;
//! TLV descriptors
static const MKSectionType MKSectionTypeThreadLocalVariables           = S_THREAD_LOCAL_VARIABLES;
//! pointers to TLV descriptors
static const MKSectionType MKSectionTypeThreadLocalVariablePointers    = S_THREAD_LOCAL_VARIABLE_POINTERS;
//! Functions to call to initialize TLV values
static const MKSectionType MKSectionTypeLocalInitFunctionPointers      = S_THREAD_LOCAL_INIT_FUNCTION_POINTERS;



//----------------------------------------------------------------------------//
@interface MKNodeFieldSectionType : MKNodeFieldTypeUnsignedByte <MKNodeFieldEnumerationType>

+ (instancetype)sharedInstance;

@end

NS_ASSUME_NONNULL_END
