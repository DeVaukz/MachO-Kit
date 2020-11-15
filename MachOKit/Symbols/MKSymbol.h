//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       MKSymbol.h
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

#import <MachOKit/MKOffsetNode.h>

@class MKCString;
@class MKSection;
@class MKSymbolTable;

NS_ASSUME_NONNULL_BEGIN

//----------------------------------------------------------------------------//
//! The \c MKSymbol class is the base parser for entries in the \c __LINKEDIT
//! symbol table.  All symbols share a common structure, and are therefore the
//! same size.  The value of the \c type field determines the type of the
//! symbol, and the meaning of the remaining fields.
//
@interface MKSymbol : MKOffsetNode {
@package
    MKResult<MKCString*> *_name;
    MKResult<MKSection*> *_section;
    uint32_t _strx;
    uint8_t _type;
    uint8_t _sect;
    uint16_t _desc;
    uint64_t _value;
}

//! Returns the subclass of \ref MKSymbol that is most suitable for parsing
//! the provided symbol table entry.
+ (nullable Class)classForEntry:(struct nlist_64)nlist;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Subclassing MKSymbol
//! @name       Subclassing MKSymbol
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//! This method is called on all \ref MKSymbol subclasses when
//! determining the appropriate class to instantiate to parse the symbol table
//! entry with the provided \a nlist.
//!
//! Subclasses should return a non-zero integer if they support parsing the
//! command.  The subclass that returns the largest value will be instantiated.
//! \ref MKSymbol subclasses in Mach-O Kit return a value no larger than \c 100.
//! You can substitute your own subclass by returning a larger value.
//!
//! @param  nlist
//!         The values in this structure have already been byte swapped and
//!         the \c n_value field has been converted to a \uint64_t if
//!         necessary.
//!
+ (uint32_t)canInstantiateWithEntry:(struct nlist_64)nlist;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Creating a Symbol
//! @name       Creating a Symbol
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//! Creates an instantiates the appropriate subclass of \ref MKSymbol
//! for parsing the entry at the provided \a offset from the parent
//! \ref MKSymbolTable.
+ (nullable instancetype)symbolAtOffset:(mk_vm_offset_t)offset fromParent:(MKSymbolTable*)parent error:(NSError**)error;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  nlist Values
//! @name       nlist Values
//!
//! @brief      These values are extracted directly from the nlist structure
//!             without modification or cleanup.
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//! An offset into the \c __LINKEDIT string table, or zero if the symbol has
//! a null, "", name.
@property (nonatomic, readonly) uint32_t strx;
//! Type information for the symbol.  This is actually a bitfield, the format
//! of which is discussed in <mach-o/nlist.h>.
@property (nonatomic, readonly) uint8_t type;
@property (nonatomic, readonly) uint8_t sect;
@property (nonatomic, readonly) uint16_t desc;
@property (nonatomic, readonly) uint64_t value;

@end

NS_ASSUME_NONNULL_END
