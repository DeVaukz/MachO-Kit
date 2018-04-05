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
//! Parsers for Mach-O sections.
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
} mk_macho_section_command_ptr _mk_transparent_union;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
typedef union {
    void *any;
    mk_load_command_section_t *section;
    mk_load_command_section_64_t *section_64;
} mk_load_command_section _mk_transparent_union;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
//! @internal
//
typedef struct mk_section_s {
    __MK_RUNTIME_BASE
    // The segment that the section resides within.
    mk_segment_ref segment;
    // The section command that defines the section.
    union {
        mk_load_command_section_t command;
        mk_load_command_section_64_t command_64;
    };
} mk_section_t;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
//! The Section polymorphic type.
//
typedef union {
    mk_type_ref type;
    struct mk_section_s *section;
} mk_section_ref _mk_transparent_union;

//! The identifier for the Section type.
_mk_export intptr_t mk_section_type;


//----------------------------------------------------------------------------//
#pragma mark -  Working With Sections
//! @name       Working With Sections
//----------------------------------------------------------------------------//

//! Initializes a Section object.
//!
//! @param  segment
//!         The segment that the section resides within.  Must remain valid for
//!         the lifetime of the section object.
//! @param  lc_section
//!         The section command that defines the section.
//! @param  section
//!         A valid \ref mk_section_t structure.
_mk_export mk_error_t
mk_section_init(mk_segment_ref segment, mk_load_command_section section_command, mk_section_t* section);

//! Initializes a Section object with the specified segment and Mach-O
//! section command.
_mk_export mk_error_t
mk_section_init_wih_mach_section_command(mk_segment_ref segment, mk_macho_section_command_ptr lc_section, mk_section_t* section);

//! Returns the Mach-O image that the specified section resides within.
_mk_export mk_macho_ref
mk_section_get_macho(mk_section_ref section);

//! Returns the segment that the specified section resides within.
_mk_export mk_segment_ref
mk_section_get_segment(mk_section_ref section);

//! Returns range of memory (in the target address space) that the specified
//! section occupies.
_mk_export mk_vm_range_t
mk_section_get_target_range(mk_section_ref section);

//! Initializes a memory object that can be used to safely access the
//! contents of the specified section.
//!
//! @note
//! Some sections (such as the __TEXT,__text in stub frameworks) have a size
//! of zero.  When this function is called with such a section, it will return
//! \ref MK_ENOT_FOUND.  Your error handling may want to handle this error
//! case separately since it is not actually an error.
_mk_export mk_error_t
mk_section_init_mapping(mk_section_ref section, mk_memory_object_t *mobj);


//----------------------------------------------------------------------------//
#pragma mark -  Section Values
//! @name       Section Values
//!
//! These functions return values directly from the underlying Mach-O
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
