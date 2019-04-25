//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       MKBindActionBind.h
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

#import <MachOKit/MKBindAction.h>

@class MKDependentLibrary;

NS_ASSUME_NONNULL_BEGIN

//----------------------------------------------------------------------------//
//! @name       Special Ordinals
//! @relates    MKBindAction
//!
//
typedef NS_ENUM(int64_t, MKLibraryOrdinal) {
    MKLibraryOrdinalSelf                = BIND_SPECIAL_DYLIB_SELF,
    MKLibraryOrdinalMainExecutable      = BIND_SPECIAL_DYLIB_MAIN_EXECUTABLE,
    MKLibraryOrdinalFlatLookup          = BIND_SPECIAL_DYLIB_FLAT_LOOKUP
};



//----------------------------------------------------------------------------//
@interface MKBindActionBind : MKBindAction {
@package
    MKLibraryOrdinal _sourceLibraryOrdinal;
    MKDependentLibrary *_sourceLibrary;
    NSString *_symbolName;
    int64_t _addend;
    MKBindSymbolFlags _symbolOptions;
}

//!
@property (nonatomic, readonly) MKLibraryOrdinal sourceLibraryOrdinal;

//!
@property (nonatomic, readonly, nullable) MKDependentLibrary *sourceLibrary;

//!
@property (nonatomic, readonly) NSString *symbolName;

//!
@property (nonatomic, readonly) MKBindSymbolFlags symbolFlags;

//!
@property (nonatomic, readonly) int64_t addend;

@end



//----------------------------------------------------------------------------//
@interface MKBindActionWeakBind : MKBindActionBind
@end



//----------------------------------------------------------------------------//
@interface MKBindActionLazyBind : MKBindActionBind
@end

NS_ASSUME_NONNULL_END
