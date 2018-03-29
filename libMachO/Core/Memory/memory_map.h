//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       memory_map.h
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
//! @defgroup MEMORY Memory
//! @ingroup CORE
//!
//! The memory module provides an abstraction which mediates access to data,
//! regardless of where it resides.
//----------------------------------------------------------------------------//

//----------------------------------------------------------------------------//
//! @defgroup MEMORY_MAP Memory Map
//! @ingroup MEMORY
//----------------------------------------------------------------------------//

#ifndef _memory_map_h
#define _memory_map_h

#include "memory_object.h"

//! @addtogroup MEMORY_MAP
//! @{
//!

//----------------------------------------------------------------------------//
#pragma mark -  Types
//! @name       Types
//----------------------------------------------------------------------------//

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
//! @internal
//
struct mk_memory_map_s {
    __MK_RUNTIME_BASE
    // An optional context associated with this memory map.
    mk_context_t *context;
};

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
//! The Memory Map polymorphic type.
//
typedef union {
    struct mk_memory_map_s *memory_map;
    struct mk_memory_map_task_s *memory_map_task;
    struct mk_memory_map_self_s *memory_map_self;
} mk_memory_map_ref _mk_transparent_union;

//! The identifier for the Memory Map type.
_mk_export intptr_t mk_memory_map_type;


//----------------------------------------------------------------------------//
#pragma mark -  Static Methods
//! @name       Static Methods
//----------------------------------------------------------------------------//

//! Returns a reference to the \c memory_map that initialized the specified
//! memory object.
_mk_export mk_memory_map_ref
mk_memory_map_for_object(mk_memory_object_ref mobj);


//----------------------------------------------------------------------------//
#pragma mark -  Instance Methods
//! @name       Instance Methods
//----------------------------------------------------------------------------//

//! Maps the data at (\a address + \a offset) into the current process and
//! initializes a memory object, which can then be used to access the data.
//!
//! @param  offset
//!         An offset to be added to \a address.
//! @param  address
//!         The host-relative address to map.
//! @param  length
//!         The number of bytes to be mapped.
//! @param  requireFull
//!         If \c YES, initialization fails if the full length can not be
//!         mapped.
//! @param  memory_object
//!         A valid \ref mk_memory_object_t structure.
_mk_export mk_error_t
mk_memory_map_init_object(mk_memory_map_ref map, mk_vm_offset_t offset, mk_vm_address_t address, mk_vm_size_t length, bool require_full, mk_memory_object_t* memory_object);

//! Cleans up any resources held by \a memory_object.  It is no longer safe to
//! use \a memory_object after calling this function.
_mk_export void
mk_memory_map_free_object(mk_memory_map_ref map, mk_memory_object_t* memory_object);

//! Returns \c true if \a length bytes at (\a address + \a offset) can be
//! accessed using the specified memory map.
_mk_export bool
mk_memory_map_has_mapping(mk_memory_map_ref map, mk_vm_offset_t offset, mk_vm_address_t address, mk_vm_size_t length, mk_error_t* error);

//! Copies \a length bytes at \a offset from \a address into \a buffer.
_mk_export size_t
mk_memory_map_copy_bytes(mk_memory_map_ref map, mk_vm_offset_t offset, mk_vm_address_t address, void* buffer, mk_vm_size_t length, bool require_full, mk_error_t* error);

//! Returns the byte at \a offset from \a address, performing any necessary
//! byte-swapping.
_mk_export uint8_t
mk_memory_map_read_byte(mk_memory_map_ref map, mk_vm_offset_t offset, mk_vm_address_t address, mk_data_model_ref data_model, mk_error_t* error);

//! Returns the word at \a offset from \a address, performing any necessary
//! byte-swapping.
_mk_export uint16_t
mk_memory_map_read_word(mk_memory_map_ref map, mk_vm_offset_t offset, mk_vm_address_t address, mk_data_model_ref data_model, mk_error_t* error);

//! Returns the double word at \a offset from \a address, performing any
//! necessary byte-swapping.
_mk_export uint32_t
mk_memory_map_read_dword(mk_memory_map_ref map, mk_vm_offset_t offset, mk_vm_address_t address, mk_data_model_ref data_model, mk_error_t* error);

//! Returns the quad word at \a offset from \a address, performing any
//! necessary byte-swapping.
_mk_export uint64_t
mk_memory_map_read_qword(mk_memory_map_ref map, mk_vm_offset_t offset, mk_vm_address_t address, mk_data_model_ref data_model, mk_error_t* error);


//! @} MEMORY_MAP !//

#endif /* _memory_map_h */
