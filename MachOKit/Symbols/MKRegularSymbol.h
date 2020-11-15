//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       MKRegularSymbol.h
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

#import <MachOKit/MKSymbol.h>
#import <MachOKit/MKNodeFieldSymbolType.h>

NS_ASSUME_NONNULL_BEGIN

//----------------------------------------------------------------------------//
//! The \c MKRegularSymbol class is the common parent class of all symbols
//! that are *not* debugging symbols (stabs).
//
@interface MKRegularSymbol : MKSymbol

//! The entry in the string table referenced by this symbol.
@property (nonatomic, readonly) MKResult<MKCString*> *name;

//! The section referenced by this symbol.
@property (nonatomic, readonly) MKResult<MKSection*> *section;

//! The symbol type.
@property (nonatomic, readonly) MKSymbolType symbolType;

//! \c True if this is a private external symbol.
@property (nonatomic, readonly, getter=isPrivateExternal) BOOL privateExternal;

//! \c True if this is an external symbol.
@property (nonatomic, readonly, getter=isExternal) BOOL external;

@end

NS_ASSUME_NONNULL_END
