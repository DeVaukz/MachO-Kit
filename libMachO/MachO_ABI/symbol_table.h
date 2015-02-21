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
    //! The range of the symbol table in the link edit segment.
    mk_vm_range_t range;
    //! The total number of symbols.
    uint32_t symbol_count;
    //! Dynamic Symbol Table information.
    mk_load_command_t dysymtab_cmd;
} mk_symbol_table_t;


//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
//! The Symbol Table type.
//
typedef union {
    struct mk_symbol_table_s *symbol_table;
} mk_symbol_table_ref __attribute__((__transparent_union__));

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

//! Initializes the provided \ref mk_symbol_table_t.
_mk_export mk_error_t
mk_symbol_table_init(mk_segment_ref link_edit, mk_load_command_ref symtab_cmd, mk_load_command_ref dysymtab_cmd, mk_symbol_table_t *symbol_table);

//! Initializes the provided \ref mk_string_table_t.
_mk_export mk_error_t
mk_symbol_table_init_with_mach_symtab(mk_segment_ref link_edit, struct symtab_command *mach_symtab, struct dysymtab_command *mach_dysymtab, mk_symbol_table_t *symbol_table);

//! Initializes the provided \ref mk_string_table_t.
_mk_export mk_error_t
mk_symbol_table_init_with_segment(mk_segment_ref link_edit, mk_symbol_table_t *symbol_table);

//! Returns the image that \a symbol_table resides within.
_mk_export mk_macho_ref
mk_symbol_table_get_macho(mk_symbol_table_ref symbol_table);

//! Returns the segment that was used to initialize \a symbol_table.
_mk_export mk_segment_ref
mk_symbol_table_get_seg_link_edit(mk_symbol_table_ref symbol_table);

//! Returns the host-relative range of memory occupied by \a symbol_table.
_mk_export mk_vm_range_t
mk_symbol_table_get_range(mk_symbol_table_ref symbol_table);

//! Returns the number of entries present in \a symbol_table.
_mk_export uint32_t
mk_symbol_table_get_count(mk_symbol_table_ref symbol_table);

//!
_mk_export mk_load_command_ref
mk_symbol_table_get_dysymtab_load_command(mk_symbol_table_ref symbol_table);


//----------------------------------------------------------------------------//
#pragma mark -  Looking Up Symbols
//! @name       Looking Up Symbols
//----------------------------------------------------------------------------//

//! Returns a pointer to the symbol at \a index in \a symbol_table.  The
//! returned pointer should be considered valid for the lifetime of
//! \a symbol_table.
_mk_export mk_mach_nlist
mk_symbol_table_get_symbol_at_index(mk_symbol_table_ref symbol_table, uint32_t index, mk_vm_address_t* host_address);

//! 
_mk_export mk_mach_nlist
mk_symbol_table_next_mach_symbol(mk_symbol_table_ref symbol_table, const mk_mach_nlist previous, uint32_t* index, mk_vm_address_t* host_address);

#if __BLOCKS__
//! Iterate over the mach symbols using a block.
_mk_export void
mk_symbol_table_enumerate_mach_symbols(mk_symbol_table_ref symbol_table, uint32_t index,
                                       void (^enumerator)(const mk_mach_nlist symbol, uint32_t index, mk_vm_address_t host_address));
#endif


//! @} MACH !//

#endif /* _symbol_table_h */
