//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       load_command_segment.h
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

#ifndef _load_command_segment_h
#define _load_command_segment_h

//! @addtogroup LOAD_COMMANDS
//! @{
//!

//----------------------------------------------------------------------------//
#pragma mark -  Segment
//! @name       Segment
//----------------------------------------------------------------------------//

_mk_export uint32_t
mk_load_command_segment_id(void);

_mk_export mk_error_t
mk_load_command_segment_copy_native(mk_load_command_ref load_command, struct segment_command *result);

_mk_export size_t
mk_load_command_segment_copy_name(mk_load_command_ref load_command, char output[16]);
_mk_export uint32_t
mk_load_command_segment_get_vmaddr(mk_load_command_ref load_command);
_mk_export uint32_t
mk_load_command_segment_get_vmsize(mk_load_command_ref load_command);
_mk_export uint32_t
mk_load_command_segment_get_fileoff(mk_load_command_ref load_command);
_mk_export uint32_t
mk_load_command_segment_get_filesize(mk_load_command_ref load_command);
_mk_export vm_prot_t
mk_load_command_segment_get_maxprot(mk_load_command_ref load_command);
_mk_export vm_prot_t
mk_load_command_segment_get_initprot(mk_load_command_ref load_command);
_mk_export uint32_t
mk_load_command_segment_get_nsects(mk_load_command_ref load_command);
_mk_export uint32_t
mk_load_command_segment_get_flags(mk_load_command_ref load_command);

_mk_export struct section*
mk_load_command_segment_next_section(mk_load_command_ref load_command, struct section *previous, mk_vm_address_t *target_address);

#if __BLOCKS__
//! Iterate over the available sections using a block.
_mk_export void
mk_load_command_segment_enumerate_sections(mk_load_command_ref load_command,
                                           void (^enumerator)(struct section *command, uint32_t index, mk_vm_address_t target_address));
#endif


//----------------------------------------------------------------------------//
#pragma mark -  Section
//! @name       Section
//----------------------------------------------------------------------------//

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
//! @internal
//
typedef struct mk_load_command_section_s {
    // The segment load command that the section command resides within.
    mk_load_command_ref segment;
    // Pointer to the Mach-O section structure.
    struct section *mach_section;
} mk_load_command_section_t;


//! Initializes a new Section.
_mk_export mk_error_t
mk_load_command_segment_section_init(mk_load_command_ref segment, struct section *sec, mk_load_command_section_t *section);

_mk_export mk_error_t
mk_load_command_segment_section_copy_native(mk_load_command_section_t *section, struct section *result);

_mk_export size_t
mk_load_command_segment_section_copy_name(mk_load_command_section_t *section, char output[16]);
_mk_export size_t
mk_load_command_segment_section_copy_segment_name(mk_load_command_section_t *section, char output[16]);
_mk_export uint32_t
mk_load_command_segment_section_get_addr(mk_load_command_section_t *section);
_mk_export uint32_t
mk_load_command_segment_section_get_size(mk_load_command_section_t *section);
_mk_export uint32_t
mk_load_command_segment_section_get_offset(mk_load_command_section_t *section);
_mk_export uint32_t
mk_load_command_segment_section_get_align(mk_load_command_section_t *section);
_mk_export uint32_t
mk_load_command_segment_section_get_reloff(mk_load_command_section_t *section);
_mk_export uint32_t
mk_load_command_segment_section_get_nreloc(mk_load_command_section_t *section);
_mk_export uint8_t
mk_load_command_segment_section_get_type(mk_load_command_section_t *section);
_mk_export uint32_t
mk_load_command_segment_section_get_attributes(mk_load_command_section_t *section);
_mk_export uint32_t
mk_load_command_segment_section_get_reserved1(mk_load_command_section_t *section);
_mk_export uint32_t
mk_load_command_segment_section_get_reserved2(mk_load_command_section_t *section);


//! @} LOAD_COMMANDS !//

#endif /* _load_command_segment_h */
