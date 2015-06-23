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
@import Foundation;

#import <MachOKit/MKOffsetNode.h>

@class MKCString;
@class MKMachOImage;

NS_ASSUME_NONNULL_BEGIN

//----------------------------------------------------------------------------//
//! The \c MKSymbol class is the base parser for entries in the \c __LINKEDIT
//! symbol table.  All symbols share a common structure, and are hence the
//! same size.  The value of the \c type field determines the type of the
//! symbol, and the meaning of the remaining fields.
//
@interface MKSymbol : MKOffsetNode {
@package
    MKCString *_name;
    uint32_t _strx;
    uint8_t _type;
    uint8_t _sect;
    uint16_t _desc;
    uint64_t _value;
}

//! Searches the subclasses of \ref MKSymbol for a class that can parse
//! the symbol at \a offset from the \a parent symbol table.
//!
//! The \c -canInstantiateWithNList:parent: is used to rank each subclass'
//! ability to parse the symbol.
+ (nullable Class)classForSymbolWithOffset:(mk_vm_offset_t)offset fromParent:(MKBackedNode*)parent error:(NSError**)error;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Subclassing MKSymbol
//! @name       Subclassing MKSymbol
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//! This method is called on each subclass of \ref MKSymbol to locate an
//! appropriate parser for a symbol.
//!
//! Return a non-zero value if the receiving class can parse the symbol
//! described by \a nlist.  The subclass of \c MKSymbol returning the largest
//! value is instantiated to parse the symbol.
//!
//! @param  nlist
//!         The values in this structure have already been byte swapped and
//!         the \c n_value field has been converted to a \uint64_t if
//!         necessary.
//! @param  parent
//!         The \ref MKSymbolTable in which \c nlist resides.
//! @return
//! A score ranking the receiving class' ability to parse the symbol described
//! by \c nlist.
+ (uint32_t)canInstantiateWithNList:(struct nlist_64)nlist parent:(MKBackedNode*)parent;


//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Creating a Symbol
//! @name       Creating a Symbol
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//! Instantiates and returns the appropriate parser for the symbol at
//! \a offset from the \a parent symbol table.
+ (nullable instancetype)symbolWithOffset:(mk_vm_offset_t)offset fromParent:(MKBackedNode*)parent error:(NSError**)error;


//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Acessing Symbol Metadata
//! @name       Acessing Symbol Metadata
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//! The entry in the string table referenced by this symbol.  May be \c nil.
@property (nonatomic, readonly, nullable) MKCString *name;


//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  nlist Values
//! @name       nlist Values
//!
//! @brief      These values are extracted directly from the nlist structure
//!             without modification or cleanup.
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//! An offset into the \c __LINKEDIT string table, or zero if the symbol has
//! a null, "", name.  The string at this offset, if any, is assigned to the
//! \ref name property of this symbol.
@property (nonatomic, readonly) uint32_t strx;
//! Type information for the symbol.  This is actually a bitfield the format
//! of which is discussed in <mach-o/nlist.h>.
@property (nonatomic, readonly) uint8_t type;
@property (nonatomic, readonly) uint8_t sect;
@property (nonatomic, readonly) uint16_t desc;
@property (nonatomic, readonly) uint64_t value;

@end

NS_ASSUME_NONNULL_END
