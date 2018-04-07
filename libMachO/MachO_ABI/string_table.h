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
    //! The range of the string table in the target.
    mk_vm_range_t target_range;
} mk_string_table_t;


//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
//! The String Table type.
//
typedef union {
    mk_type_ref type;
    struct mk_string_table_s *string_table;
} mk_string_table_ref _mk_transparent_union;

//! The identifier for the String Table type.
_mk_export intptr_t mk_string_table_type;


//----------------------------------------------------------------------------//
#pragma mark -  Working With The String Table
//! @name       Working With The String Table
//----------------------------------------------------------------------------//

//! Initializes a String Table object.
//!
//! @param  link_edit_segment
//!         The LINKEDIT segment.  Must remain valid for the lifetime of the
//!         string table object.
//! @param  load_command
//!         The LC_SYMTAB load command that defines the string table.
//! @param  string_table
//!         A valid \ref mk_string_table_t structure.
_mk_export mk_error_t
mk_string_table_init(mk_segment_ref segment, mk_load_command_ref load_command, mk_string_table_t *string_table);

//! Initializes a String Table object with the specified Mach-O LC_SYMTAB
//! load command.
_mk_export mk_error_t
mk_string_table_init_with_mach_load_command(mk_segment_ref segment, struct symtab_command *lc, mk_string_table_t *string_table);

//! Initializes a String Table object.
_mk_export mk_error_t
mk_string_table_init_with_segment(mk_segment_ref segment, mk_string_table_t *string_table);

//! Cleans up any resources held by \a string_table.  It is no longer safe to
//! use \a string_table after calling this function.
_mk_export void
mk_string_table_free(mk_string_table_ref string_table);

//! Returns the Mach-O image that the specified string table resides within.
_mk_export mk_macho_ref
mk_string_table_get_macho(mk_string_table_ref string_table);

//! Returns the LINKEDIT segment that the specified string table resides
//! within.
_mk_export mk_segment_ref
mk_string_table_get_segment(mk_string_table_ref string_table);

//! Returns range of memory (in the target address space) that the specified
//! string table occupies.
_mk_export mk_vm_range_t
mk_string_table_get_target_range(mk_string_table_ref string_table);


//----------------------------------------------------------------------------//
#pragma mark -  Looking Up Strings
//! @name       Looking Up Strings
//----------------------------------------------------------------------------//

//! Returns a pointer to the start of the string at \a offset in the specified
//! string table.  The returned pointer should only be considered valid for the
//! lifetime of \a string_table.
_mk_export const char*
mk_string_table_get_string_at_offset(mk_string_table_ref string_table, uint32_t offset, mk_vm_address_t* target_address);

//! Copies the string at \a offset in the specified string table into \a buffer,
//! returning the number of bytes copied, not counting the terminating
//! null character.  If \a buffer is \c NULL, returns the length of the string,
//! not including terminating \c NULL byte.
//!
//! @note
//! The string copied to \a buffer is *not* \c NULL terminated.
_mk_export size_t
mk_string_table_copy_string_at_offset(mk_string_table_ref string_table, uint32_t offset, char buffer[], size_t max_len);

//! Iterate over strings in the specified string table.
_mk_export const char*
mk_string_table_next_string(mk_string_table_ref string_table, const char* previous, uint32_t *offset, mk_vm_address_t* target_address);

#if __BLOCKS__
//! Iterate over the strings in the specified string table using a block.
_mk_export void
mk_string_table_enumerate_strings(mk_string_table_ref string_table, uint32_t offset,
                                  void (^enumerator)(const char* string, uint32_t offset, mk_vm_address_t target_address));
#endif


//! @} MACH !//

#endif /* _string_table_h */
