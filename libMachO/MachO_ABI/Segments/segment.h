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
//! Parsers for Segments.
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
//! @internal
//
typedef struct mk_segment_s {
    __MK_RUNTIME_BASE
    // The load command identifying this segment
    mk_load_command_t segment_load_command;
    // Memory object for accessing this segment.
    mk_memory_object_t memory_object;
} mk_segment_t;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
//! The Segment polymorphic type.
//
typedef union {
    mk_type_ref type;
    struct mk_segment_s *segment;
} mk_segment_ref __attribute__((__transparent_union__));


//----------------------------------------------------------------------------//
#pragma mark -  Working With Segments
//! @name       Working With Segments
//----------------------------------------------------------------------------//

//! Initializes the provided segment with the provided Mach load command.
_mk_export mk_error_t
mk_segment_init(mk_load_command_ref load_command, mk_segment_t* segment);

//! Releases any resources held by \a segment
_mk_export void
mk_segment_free(mk_segment_ref segment);

//! Returns the image that \a segment resides within.
_mk_export mk_macho_ref
mk_segment_get_macho(mk_segment_ref segment);

//! Returns a memory object that can be used to safely access \a segments
//! contents.
_mk_export mk_memory_object_ref
mk_segment_get_mobj(mk_segment_ref segment);


//----------------------------------------------------------------------------//
#pragma mark -  Segment Values
//! @name       Segment Values
//----------------------------------------------------------------------------//

_mk_export size_t
mk_segment_copy_name(mk_segment_ref segment, char output[16]);
_mk_export mk_vm_address_t
mk_segment_get_vm_address(mk_segment_ref segment);
_mk_export mk_vm_size_t
mk_segment_get_vm_size(mk_segment_ref segment);
_mk_export mk_vm_address_t
mk_segment_get_file_offset(mk_segment_ref segment);
_mk_export mk_vm_size_t
mk_segment_get_file_size(mk_segment_ref segment);
_mk_export vm_prot_t
mk_segment_get_max_vm_prot(mk_segment_ref segment);
_mk_export vm_prot_t
mk_segment_get_initial_vm_prot(mk_segment_ref segment);
_mk_export uint32_t
mk_segment_get_nsects(mk_segment_ref segment);
_mk_export uint32_t
mk_segment_get_flags(mk_segment_ref segment);


//! @} LOAD_COMMANDS !//

#endif /* _segment_h */
