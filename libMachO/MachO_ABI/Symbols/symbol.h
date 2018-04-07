//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       symbol.h
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

//----------------------------------------------------------------------------//
//! @defgroup SYMBOLS Symbols
//! @ingroup MACH
//!
//! Parsers for Symbols.
//----------------------------------------------------------------------------//

#ifndef _symbol_h
#define _symbol_h

//! @addtogroup SYMBOLS
//! @{
//!

//----------------------------------------------------------------------------//
#pragma mark -  Types
//! @name       Types
//----------------------------------------------------------------------------//

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
typedef union {
    void *any;
    struct nlist *nlist;
    struct nlist_64 *nlist_64;
} mk_macho_nlist_ptr _mk_transparent_union;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
//! @internal
//
typedef struct mk_symbol_s {
    __MK_RUNTIME_BASE
    mk_symbol_table_ref symbol_table;
    mk_macho_nlist_ptr nlist;
} mk_symbol_t;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
//! The Symbol polymorphic type.
//
typedef union {
    mk_type_ref type;
    struct mk_symbol_s *symbol;
} mk_symbol_ref _mk_transparent_union;

//! The identifier for the Symbol type.
_mk_export intptr_t mk_symbol_type;


//----------------------------------------------------------------------------//
#pragma mark -  Working With Symbols
//! @name       Working With Symbols
//----------------------------------------------------------------------------//

//! Initializes the provided symbol with the provided Mach nlist structure
//! in \a image.
_mk_export mk_error_t
mk_symbol_init(mk_symbol_table_ref symbol_table, mk_macho_nlist_ptr nlist, mk_symbol_t* symbol);

//! Returns the Mach-O image that the specified symbol resides within.
_mk_export mk_macho_ref
mk_symbol_get_macho(mk_symbol_ref symbol);

//! Returns the symbol table that the specified symbol resides within.
_mk_export mk_symbol_table_ref
mk_symbol_get_symbol_table(mk_symbol_ref symbol);

//! Returns range of memory (in the target address space) that the specified
//! symbol occupies.
_mk_export mk_vm_range_t
mk_symbol_get_target_range(mk_symbol_ref symbol);


//----------------------------------------------------------------------------//
#pragma mark -  Symbol Values
//! @name       Symbol Values
//!
//! These functions return values directly from the underlying Mach
//! nlist(_64) structure.
//----------------------------------------------------------------------------//

_mk_export uint32_t
mk_symbol_get_strx(mk_symbol_ref symbol);
_mk_export uint8_t
mk_symbol_get_type(mk_symbol_ref symbol);
_mk_export uint8_t
mk_symbol_get_sect(mk_symbol_ref symbol);
_mk_export int16_t
mk_symbol_get_desc(mk_symbol_ref symbol);
_mk_export uint64_t
mk_symbol_get_value(mk_symbol_ref symbol);


//! @} SYMBOLS !//

#endif /* _symbol_h */
