//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       MKNodeFieldExportKindType.h
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

// <https://opensource.apple.com/source/dyld/dyld-519.2.1/src/ImageLoaderMachOCompressed.cpp.auto.html>
#ifndef EXPORT_SYMBOL_FLAGS_KIND_ABSOLUTE
    #define EXPORT_SYMBOL_FLAGS_KIND_ABSOLUTE            0x02
#endif

NS_ASSUME_NONNULL_BEGIN

//----------------------------------------------------------------------------//
//! @name       Export Kind
//! @relates    MKNodeFieldExportKindType
//!
//
typedef uint8_t MKExportKind NS_TYPED_EXTENSIBLE_ENUM;

static const MKExportKind MKExportKindRegular           = EXPORT_SYMBOL_FLAGS_KIND_REGULAR;
static const MKExportKind MKExportKindThreadLocal       = EXPORT_SYMBOL_FLAGS_KIND_THREAD_LOCAL;
static const MKExportKind MKExportKindAbsolute          = EXPORT_SYMBOL_FLAGS_KIND_ABSOLUTE;



//----------------------------------------------------------------------------//
@interface MKNodeFieldExportKindType : MKNodeFieldTypeUnsignedByte <MKNodeFieldEnumerationType>

+ (instancetype)sharedInstance;

@end

NS_ASSUME_NONNULL_END
