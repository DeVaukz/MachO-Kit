//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             NMUtil.h
//|
//|             D.V.
//|             Copyright (c) 2014-2015 D.V. All rights reserved.
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

@import Foundation;

//----------------------------------------------------------------------------//
@interface NMUtil : NSObject

//! Parses \a input into an array of dictionaries, each representing a single
//! symbol table entry.  Each dictionary contains the following keys:
//!
//!     type: Symbol type
//!     address [Optional]: Address of the symbol
//!     stabInfo [Optional]: Information specific to STABs
//!         type: The value of the n_type field
//!         sect: The value of the n_sect field
//!         desc: The value of the n_desc field
//!     indirect [Optional]: The indirect symbol name
//!     name: The symbol name
//!
//! @note
//! The input string must be the output of llvm-nm with the '-format bsd'
//! option.
//!
+ (NSArray*)parseBSDSymbols:(NSString*)input;

//! Parses \a input into an array of dictionaries, each representing a single
//! symbol table entry.  Each dictionary contains the following keys:
//!
//!     type: Symbol type
//!     section [Optional]: Section where the symbol resides
//!     address [Optional]: Address of the symbol
//!     referencedDynamically [Optional]: The symbol is referenced dynamically
//!     weak [Optional]: The symbol is weak
//!     external [Optional]: The symbol is external
//!     privateExternal [Optional]: The symbol is private-external
//!     thumb [Optional]: The symbol is a thumb function
//!     name: The symbol name
//!     sourceLibrary [Optional]: The library where the symbol is defined
//!
//! @note
//! The input string must be the output of llvm-nm with the '-format darwin'
//! option.
//!
+ (NSArray*)parseDarwinSymbols:(NSString*)input;

@end
