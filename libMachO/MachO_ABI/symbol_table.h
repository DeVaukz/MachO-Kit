//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       symbol_table.h
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

#ifndef _symbol_table_h
#define _symbol_table_h

//! @addtogroup MACH
//! @{
//!

//----------------------------------------------------------------------------//
#pragma mark -  Types
//! @name       Types
//----------------------------------------------------------------------------//

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
//! @internal
//
typedef struct mk_symbol_table_s {
    __MK_RUNTIME_BASE
    //! Link edit segment
    mk_segment_ref link_edit;
    //! The range of the symbol table in the target.
    mk_vm_range_t target_range;
    //! Symbol table information.
    mk_load_command_t symtab_command;
    //! Dynamic Symbol Table information.
    mk_load_command_t dysymtab_command;
} mk_symbol_table_t;


//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
//! The Symbol Table type.
//
typedef union {
    mk_type_ref type;
    struct mk_symbol_table_s *symbol_table;
} mk_symbol_table_ref _mk_transparent_union;

//! The identifier for the Symbol Table type.
_mk_export intptr_t mk_symbol_table_type;


//----------------------------------------------------------------------------//
#pragma mark -  Includes
//----------------------------------------------------------------------------//

#include "symbol.h"


//----------------------------------------------------------------------------//
#pragma mark -  Working With The Symbol Table
//! @name       Working With The String Table
//----------------------------------------------------------------------------//

//! Initializes a Symbol Table object.
//!
//! @param  segment
//!         The LINKEDIT segment.  Must remain valid for the lifetime of the
//!         string table object.
//! @param  symtab_load_command
//!         The LC_SYMTAB load command that defines the symbol table.
//! @param  dysymtab_load_command
//!         The LC_DYSYMTAB load command that defines the symbol table.
//! @param  symbol_table
//!         A valid \ref mk_symbol_table_t structure.
_mk_export mk_error_t
mk_symbol_table_init(mk_segment_ref segment, mk_load_command_ref symtab_load_command, mk_load_command_ref dysymtab_load_command, mk_symbol_table_t *symbol_table);

//! Initializes a Symbol Table object with the specified Mach-O LC_SYMTAB
//! and LC_DYSYMTAB load commands.
_mk_export mk_error_t
mk_symbol_table_init_with_mach_load_commands(mk_segment_ref segment, struct symtab_command *symtab_lc, struct dysymtab_command *dysymtab_lc, mk_symbol_table_t *symbol_table);

//! Initializes a Symbol Table object.
_mk_export mk_error_t
mk_symbol_table_init_with_segment(mk_segment_ref segment, mk_symbol_table_t *symbol_table);

//! Cleans up any resources held by \a symbol_table.  It is no longer safe to
//! use \a symbol_table after calling this function.
_mk_export void
mk_symbol_table_free(mk_symbol_table_ref symbol_table);

//! Returns the Mach-O image that the specified symbol table resides within.
_mk_export mk_macho_ref
mk_symbol_table_get_macho(mk_symbol_table_ref symbol_table);

//! Returns the LINKEDIT segment that the specified symbol table resides
//! within.
_mk_export mk_segment_ref
mk_symbol_table_get_segment(mk_symbol_table_ref symbol_table);

//! Returns range of memory (in the target address space) that the specified
//! symbol table occupies.
_mk_export mk_vm_range_t
mk_symbol_table_get_target_range(mk_symbol_table_ref symbol_table);

//! Returns the LC_SYMTAB load command that defines the specified symbol
//! table.
_mk_export mk_load_command_ref
mk_symbol_table_get_symtab_load_command(mk_symbol_table_ref symbol_table);

//! Returns the LC_DYSYMTAB load command that defines the specified symbol
//! table.
_mk_export mk_load_command_ref
mk_symbol_table_get_dysymtab_load_command(mk_symbol_table_ref symbol_table);


//----------------------------------------------------------------------------//
#pragma mark -  Looking Up Symbols
//! @name       Looking Up Symbols
//----------------------------------------------------------------------------//

//! Returns the number of entries present in the specified symbol table.
_mk_export uint32_t
mk_symbol_table_get_symbol_count(mk_symbol_table_ref symbol_table);

//! Returns a pointer to the symbol at \a index in the specified Symbol Table.
//! The returned pointer should only be considered valid for the lifetime of
//! \a symbol_table.
_mk_export mk_macho_nlist_ptr
mk_symbol_table_get_mach_symbol_at_index(mk_symbol_table_ref symbol_table, uint32_t index, mk_vm_address_t* target_address);

//! Iterate over symbols in the specified symbol table.
_mk_export mk_macho_nlist_ptr
mk_symbol_table_next_mach_symbol(mk_symbol_table_ref symbol_table, const mk_macho_nlist_ptr previous, uint32_t* index, mk_vm_address_t* target_address);

#if __BLOCKS__
//! Iterate over the symbols in the specified symbol table using a block.
_mk_export void
mk_symbol_table_enumerate_mach_symbols(mk_symbol_table_ref symbol_table, uint32_t index,
                                       void (^enumerator)(const mk_macho_nlist_ptr symbol, uint32_t index, mk_vm_address_t target_address));
#endif


//! @} MACH !//

#endif /* _symbol_table_h */
