//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       MKNodeFieldMachOFileType.h
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

#import <MachOKit/MKNodeFieldTypeDoubleWord.h>
#import <MachOKit/MKNodeFieldEnumerationType.h>

NS_ASSUME_NONNULL_BEGIN

//----------------------------------------------------------------------------//
//! @name       Mach-O File Types
//! @relates    MKNodeFieldMachOFileType
//!
//
typedef uint32_t MKMachOFileType NS_TYPED_EXTENSIBLE_ENUM;

static const MKMachOFileType MKMachOFileTypeObject              = MH_OBJECT;
static const MKMachOFileType MKMachOFileTypeExecutable          = MH_EXECUTE;
static const MKMachOFileType MKMachOFileTypeFixedVMLibrary      = MH_FVMLIB;
static const MKMachOFileType MKMachOFileTypeCore                = MH_CORE;
static const MKMachOFileType MKMachOFileTypePreloadedExecutable = MH_PRELOAD;
static const MKMachOFileType MKMachOFileTypeDynamicLibrary      = MH_DYLIB;
static const MKMachOFileType MKMachOFileTypeDynamicLinker       = MH_DYLINKER;
static const MKMachOFileType MKMachOFileTypeBundle              = MH_BUNDLE;
static const MKMachOFileType MKMachOFileTypeDynamicLibraryStub  = MH_DYLIB_STUB;
static const MKMachOFileType MKMachOFileTypeDSYM                = MH_DSYM;
static const MKMachOFileType MKMachOFileTypeKEXT                = MH_KEXT_BUNDLE;



//----------------------------------------------------------------------------//
@interface MKNodeFieldMachOFileType : MKNodeFieldTypeUnsignedDoubleWord <MKNodeFieldEnumerationType>

+ (instancetype)sharedInstance;

@end

NS_ASSUME_NONNULL_END
