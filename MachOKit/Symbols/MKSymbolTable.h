//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       MKSymbolTable.h
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

#import <MachOKit/MKLinkEditNode.h>

@class MKSymbol;

NS_ASSUME_NONNULL_BEGIN

//----------------------------------------------------------------------------//
//! The \c MKSymbolTable class parses the link-edit symbol table, building
//! a list of \ref MKSymbol instances from the extracted symbol information.
//! The symbol table is identified by an offset in the \c LC_SYMTAB load
//! command.
//
@interface MKSymbolTable : MKLinkEditNode {
@package
    NSArray<MKSymbol*> *_symbols;
    NSRange _localSymbols;
    NSRange _externalSymbols;
    NSRange _undefinedSymbols;
}

//! Initializes the receiver with the provided Mach-O.
- (nullable instancetype)initWithImage:(MKMachOImage*)image error:(NSError**)error;

//! An array of \ref MKSymbol instances, each corresponding to an entry in the
//! symbol table.  The order of this array matches the ordering of the
//! symbol structures in the Mach-O.
@property (nonatomic, readonly) NSArray<__kindof MKSymbol*> *symbols;

//! The range of indexes in the \ref symbols array which correspond to
//! local symbols.  These symbols are typically included for debugging.
@property (nonatomic, readonly) NSRange localSymbols;
//! The range of indexes in the \ref symbols array which correspond to
//! external symbols.  These symbols are expected to be found in a specific
//! external library that will dynamically linked at runtime.
@property (nonatomic, readonly) NSRange externalSymbols;
//! The range of indexes in the \ref symbols array which correspond to
//! undefined symbols.
@property (nonatomic, readonly) NSRange undefinedSymbols;

@end

NS_ASSUME_NONNULL_END
