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
typedef union {
    void *any;
    struct section *section;
    struct section_64 *section_64;
} mk_mach_section __attribute__((__transparent_union__));

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
typedef union {
    void *any;
    mk_load_command_section_t *section;
    mk_load_command_section_64_t *section_64;
} mk_load_command_section __attribute__((__transparent_union__));

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
//! @internal
//
typedef struct mk_section_s {
    __MK_RUNTIME_BASE
    // The segment containing this section.
    mk_segment_ref segment;
    // The section structure.
    union {
        mk_load_command_section_64_t section_64;
        mk_load_command_section_t section;
    };
} mk_section_t;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
//! The Section polymorphic type.
//
typedef union {
    struct mk_section_s *section;
} mk_section_ref __attribute__((__transparent_union__));

//! The identifier for the Section type.
_mk_export intptr_t mk_section_type;


//----------------------------------------------------------------------------//
#pragma mark -  Working With Sections
//! @name       Working With Sections
//----------------------------------------------------------------------------//

//! Initializes the provided \a section with the provided
//! \ref mk_load_command_section_64_t or \ref mk_load_command_section_t.
//!
//! @param  segment
//!         The segment in which \a lc_section resides.
//! @param  lc_section
//!         A \ref mk_load_command_section.
//! @param  section
//!         A pointer to the \ref to be initialized.
_mk_export mk_error_t
mk_section_init(mk_segment_ref segment, mk_load_command_section lc_section, mk_section_t* section);

//! Initializes the provided \a section with the provided \a mach_section.
//!
//! @param  segment
//!         The segment in which \a mach_section resides.
//! @param  mach_section
//!         A pointer to a Mach \c section or \c section_64 structure.
//! @param  section
//!         A pointer to the \ref to be initialized.
_mk_export mk_error_t
mk_section_init_wih_mach_section(mk_segment_ref segment, mk_mach_section mach_section, mk_section_t* section);

//! Returns the image that \a section resides within.
_mk_export mk_macho_ref
mk_section_get_macho(mk_section_ref section);

//! Returns the segment that \a section resides within.
_mk_export mk_segment_ref
mk_section_get_segment(mk_section_ref section);

//! Returns the range of memory in the originating context occupied by
//! \a section.
//!
//! @param  mobj
//!         An initialized memory object.
_mk_export mk_vm_range_t
mk_section_get_range(mk_section_ref section);

//! Initializes a memory object that can be used to safely access the
//! \a section contents.
_mk_export mk_error_t
mk_section_init_mobj(mk_section_ref section, mk_memory_object_t *mobj);


//----------------------------------------------------------------------------//
#pragma mark -  Section Values
//! @name       Section Values
//!
//! These functions return values directly from the underlying Mach
//! section(_64) structure.
//----------------------------------------------------------------------------//

_mk_export size_t
mk_section_copy_name(mk_section_ref section, char output[16]);
_mk_export size_t
mk_section_copy_segment_name(mk_section_ref section, char output[16]);
_mk_export mk_vm_address_t
mk_section_get_addr(mk_section_ref section);
_mk_export mk_vm_size_t
mk_section_get_size(mk_section_ref section);
_mk_export mk_vm_address_t
mk_section_get_offset(mk_section_ref section);
_mk_export uint32_t
mk_section_get_align(mk_section_ref section);
_mk_export uint32_t
mk_section_get_reloff(mk_section_ref section);
_mk_export uint32_t
mk_section_get_nreloc(mk_section_ref section);
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
