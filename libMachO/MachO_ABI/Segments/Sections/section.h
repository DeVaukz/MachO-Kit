//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       segment.h
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
//! @defgroup SECTIONS Sections
//! @ingroup SEGMENTS
//!
//! Parsers for Sections.
//----------------------------------------------------------------------------//

#ifndef _section_h
#define _section_h

//! @addtogroup SECTIONS
//! @{
//!

//----------------------------------------------------------------------------//
#pragma mark -  Types
//! @name       Types
//----------------------------------------------------------------------------//

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
//! @internal
//
typedef struct mk_section_s {
    __MK_RUNTIME_BASE
    // The segment containing this section.
    mk_segment_ref section_segment;
    // The mach section structure.
    union {
        mk_load_command_section_t section;
        mk_load_command_section_64_t section_64;
    };
    // Memory object for accessing this section.
    mk_memory_object_t memory_object;
} mk_section_t;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
//! The Section polymorphic type.
//
typedef union {
    mk_type_ref type;
    struct mk_section_s *section;
} mk_section_ref __attribute__((__transparent_union__));


//----------------------------------------------------------------------------//
#pragma mark -  Working With Sections
//! @name       Working With Sections
//----------------------------------------------------------------------------//

//! Initializes the provided \a section with the provided Mach \c section.
_mk_export mk_error_t
mk_section_init_with_section(mk_segment_ref segment, struct section* s, mk_section_t* section);

//! Initializes the provided \a section with the provided Mach \c section_64.
_mk_export mk_error_t
mk_section_init_with_section_64(mk_segment_ref segment, struct section_64* s, mk_section_t* section);

//! Releases any resources held by \a section
_mk_export void
mk_section_free(mk_section_ref section);

//! Returns the image that \a section resides within.
_mk_export mk_macho_ref
mk_section_get_macho(mk_section_ref section);

//! Returns the segment that \a section resides within.
_mk_export mk_segment_ref
mk_section_get_segment(mk_section_ref section);

//! Returns a memory object that can be used to safely access the \a section
//! contents.
_mk_export mk_memory_object_ref
mk_section_get_mobj(mk_section_ref section);


//----------------------------------------------------------------------------//
#pragma mark -  Section Values
//! @name       Section Values
//----------------------------------------------------------------------------//

_mk_export size_t
mk_section_copy_section_name(mk_section_ref section, char output[16]);
_mk_export size_t
mk_section_copy_segment_name(mk_section_ref section, char output[16]);
_mk_export mk_vm_address_t
mk_section_get_vm_address(mk_section_ref section);
_mk_export mk_vm_size_t
mk_section_get_vm_size(mk_section_ref section);
_mk_export mk_vm_address_t
mk_section_get_vm_offset(mk_section_ref section);
_mk_export uint32_t
mk_section_get_alignment(mk_section_ref section);
_mk_export uint32_t
mk_section_get_relocations_offset(mk_section_ref section);
_mk_export uint32_t
mk_section_get_number_relocations(mk_section_ref section);
_mk_export uint8_t
mk_section_get_type(mk_section_ref section);
_mk_export uint32_t
mk_section_get_attributes(mk_section_ref section);
_mk_export uint32_t
mk_section_get_reserved1(mk_section_ref section);
_mk_export uint32_t
mk_section_get_reserved2(mk_section_ref section);


//! @} SECTIONS !//

#endif /* _section_h */
