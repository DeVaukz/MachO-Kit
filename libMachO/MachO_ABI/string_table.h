//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       string_table.h
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

#ifndef _string_table_h
#define _string_table_h

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
typedef struct mk_string_table_s {
    __MK_RUNTIME_BASE
    //! Link edit segment
    mk_segment_ref link_edit;
    //! The range of the string table in the link edit segment.
    mk_vm_range_t range;
} mk_string_table_t;


//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
//! The String Table type.
//
typedef union {
    struct mk_string_table_s *string_table;
} mk_string_table_ref __attribute__((__transparent_union__));

//! The identifier for the String Table type.
_mk_export intptr_t mk_string_table_type;


//----------------------------------------------------------------------------//
#pragma mark -  Working With The String Table
//! @name       Working With The String Table
//----------------------------------------------------------------------------//

//! Initializes the provided \ref mk_string_table_t.
_mk_export mk_error_t
mk_string_table_init(mk_segment_ref link_edit, mk_load_command_ref symtab_cmd, mk_string_table_t *string_table);

//! Initializes the provided \ref mk_string_table_t.
_mk_export mk_error_t
mk_string_table_init_with_mach_symtab(mk_segment_ref link_edit, struct symtab_command *mach_symtab, mk_string_table_t *string_table);

//! Initializes the provided \ref mk_string_table_t.
_mk_export mk_error_t
mk_string_table_init_with_segment(mk_segment_ref link_edit, mk_string_table_t *string_table);

//! Releases any resources held by \a string_table
_mk_export void
mk_string_table_free(mk_string_table_ref string_table);

//! Returns the image that \a string_table resides within.
_mk_export mk_macho_ref
mk_string_table_get_macho(mk_string_table_ref string_table);

//! Returns the segment that was used to initialize \a string_table.
_mk_export mk_segment_ref
mk_string_table_get_seg_link_edit(mk_string_table_ref string_table);

//! Returns the host-relative range of memory occupied by \a string_table.
_mk_export mk_vm_range_t
mk_string_table_get_range(mk_string_table_ref string_table);


//----------------------------------------------------------------------------//
#pragma mark -  Looking Up Strings
//! @name       Looking Up Strings
//----------------------------------------------------------------------------//

//! Returns a pointer to the start of the string at \a offset.  The returned
//! pointer should be considered valid for the lifetime of \a string_table.
_mk_export const char*
mk_string_table_get_string_at_offset(mk_string_table_ref string_table, uint32_t offset, mk_vm_address_t* host_address);

//! Copies the string at \a offset from \a string_table into \a buffer,
//! returning the number of bytes copied.  If \a buffer is \c NULL, returns
//! the length of the string at \a offset from \a string_table (not including
//! terminating \c NULL byte).
//!
//! @note
//! The string copied to \a buffer is *not* \c NULL terminated.
_mk_export size_t
mk_string_table_copy_string_at_offset(mk_string_table_ref string_table, uint32_t offset, char buffer[], size_t max_len);

//! 
_mk_export const char*
mk_string_table_next_string(mk_string_table_ref string_table, const char* previous, uint32_t *offset, mk_vm_address_t* host_address);

#if __BLOCKS__
//! Iterate over the strings using a block.
_mk_export void
mk_string_table_enumerate_strings(mk_string_table_ref string_table, uint32_t offset,
                                  void (^enumerator)(const char* string, uint32_t offset, mk_vm_address_t context_address));
#endif


//! @} MACH !//

#endif /* _string_table_h */
