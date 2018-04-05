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
//! @defgroup SEGMENTS Segments
//! @ingroup MACH
//!
//! Parsers for Mach-O segments and sections.
//----------------------------------------------------------------------------//

#ifndef _segment_h
#define _segment_h

//! @addtogroup SEGMENTS
//! @{
//!

//----------------------------------------------------------------------------//
#pragma mark -  Types
//! @name       Types
//----------------------------------------------------------------------------//

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
typedef union {
    struct load_command *any;
    struct segment_command *segment;
    struct segment_command_64 *segment_64;
} mk_macho_segment_load_command_ptr _mk_transparent_union;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
//! @internal
//
typedef struct mk_segment_s {
    __MK_RUNTIME_BASE
    // The load command that defines the segment.
    mk_load_command_t command;
    // Memory object mapping the segment into the current process.
    mk_memory_object_t memory_object;
} mk_segment_t;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
//! The Segment polymorphic type.
//
typedef union {
    mk_type_ref type;
    struct mk_segment_s *segment;
} mk_segment_ref _mk_transparent_union;

//! The identifier for the Segment type.
_mk_export intptr_t mk_segment_type;


//----------------------------------------------------------------------------//
#pragma mark -  Includes
//----------------------------------------------------------------------------//

#include "section.h"


//----------------------------------------------------------------------------//
#pragma mark -  Working With Segments
//! @name       Working With Segments
//----------------------------------------------------------------------------//

//! Initializes a Segment object.
//!
//! @param  load_command
//!         The load command that defines the segment.
//! @param  segment
//!         A valid \ref mk_segment_t structure.
_mk_export mk_error_t
mk_segment_init(mk_load_command_ref load_command, mk_segment_t* segment);

//! Initializes a Segment object with the specified Mach-O image and Mach-O
//! segment load command.
_mk_export mk_error_t
mk_segment_init_with_mach_load_command(mk_macho_ref image, mk_macho_segment_load_command_ptr lc, mk_segment_t* segment);

//! Cleans up any resources held by \a segment.  It is no longer safe to
//! use \a segment after calling this function.
_mk_export void
mk_segment_free(mk_segment_ref segment);

//! Returns the Mach-O image that the specified segment resides within.
_mk_export mk_macho_ref
mk_segment_get_macho(mk_segment_ref segment);

//! Returns the load command that defines the specified segment.
_mk_export mk_load_command_ref
mk_segment_get_load_command(mk_segment_ref segment);

//! Returns range of memory (in the target address space) that the specified
//! segment occupies.
_mk_export mk_vm_range_t
mk_segment_get_target_range(mk_segment_ref segment);

//! Returns the memory object mapping the specified segment into the current
//! process.
_mk_export mk_memory_object_ref
mk_segment_get_mapping(mk_segment_ref segment);


//----------------------------------------------------------------------------//
#pragma mark -  Segment Values
//! @name       Segment Values
//!
//! These functions return values directly from the underlying Mach-O
//! segment(_64) structure.
//----------------------------------------------------------------------------//

_mk_export size_t
mk_segment_copy_name(mk_segment_ref segment, char output[16]);
_mk_export mk_vm_address_t
mk_segment_get_vmaddr(mk_segment_ref segment);
_mk_export mk_vm_size_t
mk_segment_get_vmsize(mk_segment_ref segment);
_mk_export mk_vm_address_t
mk_segment_get_fileoff(mk_segment_ref segment);
_mk_export mk_vm_size_t
mk_segment_get_filesize(mk_segment_ref segment);
_mk_export vm_prot_t
mk_segment_get_maxprot(mk_segment_ref segment);
_mk_export vm_prot_t
mk_segment_get_initprot(mk_segment_ref segment);
_mk_export uint32_t
mk_segment_get_nsects(mk_segment_ref segment);
_mk_export uint32_t
mk_segment_get_flags(mk_segment_ref segment);


//----------------------------------------------------------------------------//
#pragma mark -  Enumerating Sections
//! @name       Enumerating Sections
//----------------------------------------------------------------------------//

//! Iterate over the Mach-O section commands in the specified segment.
_mk_export mk_macho_section_command_ptr
mk_segment_next_section(mk_segment_ref segment, mk_macho_section_command_ptr previous, mk_vm_address_t* host_address);

#if __BLOCKS__
//! Iterate over the sections in the specified segment using a block.
_mk_export void
mk_segment_enumerate_sections(mk_segment_ref segment,
                              void (^enumerator)(mk_macho_section_command_ptr section, uint32_t index));
#endif


//! @} SEGMENTS !//

#endif /* _segment_h */
