//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       indirect_symbol_table.h
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

#ifndef _indirect_symbol_table_h
#define _indirect_symbol_table_h

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
typedef struct mk_indirect_symbol_table_s {
    __MK_RUNTIME_BASE
    //! Link edit segment
    mk_segment_ref link_edit;
    //! The range of the indirect symbol table in the link edit segment.
    mk_vm_range_t range;
} mk_indirect_symbol_table_t;


//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
//! The Indirect Symbol Table type.
//
typedef union {
    struct mk_indirect_symbol_table_s *symbol_table;
} mk_indirect_symbol_table_ref __attribute__((__transparent_union__));

//! The identifier for the Symbol Table type.
_mk_export intptr_t mk_indirect_symbol_table_type;


//----------------------------------------------------------------------------//
#pragma mark -  Working With The Indirect Symbol Table
//! @name       Working With The Indirect String Table
//----------------------------------------------------------------------------//

//! Initializes the provided \ref mk_indirect_symbol_table_t.
_mk_export mk_error_t
mk_indirect_symbol_table_init(mk_segment_ref link_edit, mk_load_command_ref dysymtab_cmd, mk_indirect_symbol_table_t *symbol_table);

//! Initializes the provided \ref mk_indirect_symbol_table_t.
_mk_export mk_error_t
mk_indirect_symbol_table_init_with_mach_dysymtab(mk_segment_ref link_edit, struct dysymtab_command *mach_dysymtab, mk_indirect_symbol_table_t *symbol_table);

//! Initializes the provided \ref mk_indirect_symbol_table_t.
_mk_export mk_error_t
mk_indirect_symbol_table_init_with_segment(mk_segment_ref link_edit, mk_indirect_symbol_table_t *symbol_table);

//! Returns the image that \a symbol_table resides within.
_mk_export mk_macho_ref
mk_indirect_symbol_table_get_macho(mk_indirect_symbol_table_ref symbol_table);

//! Returns the segment that was used to initialize \a symbol_table.
_mk_export mk_segment_ref
mk_indirect_symbol_table_get_seg_link_edit(mk_indirect_symbol_table_ref symbol_table);

//! Returns the host-relative range of memory occupied by \a symbol_table.
_mk_export mk_vm_range_t
mk_indirect_symbol_table_get_range(mk_indirect_symbol_table_ref symbol_table);

//! Returns the number of entries present in \a symbol_table.
_mk_export uint32_t
mk_indirect_symbol_table_get_count(mk_indirect_symbol_table_ref symbol_table);


//----------------------------------------------------------------------------//
#pragma mark -  Looking Up Symbols
//! @name       Looking Up Symbols
//----------------------------------------------------------------------------//

//!
_mk_export uint32_t
mk_indirect_symbol_table_get_value_at_index(mk_indirect_symbol_table_ref symbol_table, uint32_t index, mk_vm_address_t* host_address);

#if __BLOCKS__
//!
_mk_export void
mk_indirect_symbol_table_enumerate_values(mk_indirect_symbol_table_ref symbol_table, uint32_t index,
                                          void (^enumerator)(uint32_t value, uint32_t index, mk_vm_address_t host_address));
#endif


//! @} MACH !//

#endif /* _indirect_symbol_table_h */
