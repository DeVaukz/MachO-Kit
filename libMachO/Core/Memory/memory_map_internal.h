//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       memory_map_internal.h
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

#ifndef _memory_map_internal_h
#define _memory_map_internal_h
#ifndef DOXYGEN

#include "memory_object_internal.h"
#include "memory_map.h"

//! @addtogroup MEMORY_MAP
//! @{
//!

//----------------------------------------------------------------------------//
#pragma mark -  Classes
//! @name       Classes
//----------------------------------------------------------------------------//

//! Member function prototype for the \ref mk_memory_map_init_object
//! polymorphic function.
typedef mk_error_t (*_mk_memory_map_init_object)(mk_memory_map_ref self, mk_vm_offset_t offset, mk_vm_address_t address, mk_vm_size_t length, bool require_full, mk_memory_object_t* memory_object);

//! Member function prototype for the \ref mk_memory_map_free_object
//! polymorphic function.
typedef void (*_mk_memory_map_free_object)(mk_memory_map_ref self, mk_memory_object_t* memory_object);

//! Member function prototype for the \ref mk_memory_map_has_mapping
//! polymorphic function.
typedef bool (*_mk_memory_map_has_mapping)(mk_memory_map_ref self, mk_vm_offset_t offset, mk_vm_address_t address, mk_vm_size_t length, mk_error_t* error);

//! Member function prototype for the \ref mk_memory_map_copy_bytes
//! polymorphic function.
typedef size_t (*_mk_memory_map_copy_bytes)(mk_memory_map_ref self, mk_vm_offset_t offset, mk_vm_address_t address, void* buffer, mk_vm_size_t length, bool require_full, mk_error_t* error);

//! Member function prototype for the \ref mk_memory_map_read_byte
//! polymorphic function.
typedef uint8_t (*_mk_memory_map_read_byte)(mk_memory_map_ref self, mk_vm_offset_t offset, mk_vm_address_t address, mk_data_model_ref data_model, mk_error_t* error);

//! Member function prototype for the \ref mk_memory_map_read_word
//! polymorphic function.
typedef uint16_t (*_mk_memory_map_read_word)(mk_memory_map_ref self, mk_vm_offset_t offset, mk_vm_address_t address, mk_data_model_ref data_model, mk_error_t* error);

//! Member function prototype for the \ref mk_memory_map_read_dword
//! polymorphic function.
typedef uint32_t (*_mk_memory_map_read_dword)(mk_memory_map_ref self, mk_vm_offset_t offset, mk_vm_address_t address, mk_data_model_ref data_model, mk_error_t* error);

//! Member function prototype for the \ref mk_memory_map_read_qword
//! polymorphic function.
typedef uint64_t (*_mk_memory_map_read_qword)(mk_memory_map_ref self, mk_vm_offset_t offset, mk_vm_address_t address, mk_data_model_ref data_model, mk_error_t* error);

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
//! @internal
//!
//! Member function table declaration for the \c memory_map type.
//
struct _mk_memory_map_vtable {
    __MK_RUNTIME_TYPE_BASE
    //! This method is abstract.  Subclasses must provide an implementation.
    _mk_memory_map_init_object init_object;
    //! This method is abstract.  Subclasses must provide an implementation.
    _mk_memory_map_free_object free_object;
    _mk_memory_map_has_mapping has_mapping;
    _mk_memory_map_copy_bytes copy_bytes;
    _mk_memory_map_read_byte read_byte;
    _mk_memory_map_read_word read_word;
    _mk_memory_map_read_dword read_dword;
    _mk_memory_map_read_qword read_qword;
};

//! The member function table for the \c memory_object type.  Contains
//! implementations of all non-abstract methods in
//! \c struct _mk_memory_map_vtable.
_mk_internal_extern
const struct _mk_memory_map_vtable _mk_memory_map_class;


//! @} MEMORY_MAP !//

#endif
#endif
