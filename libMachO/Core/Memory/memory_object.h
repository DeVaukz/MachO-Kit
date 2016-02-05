//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       memory_object.h
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
//! @defgroup MEMORY_OBJECT Memory Object
//! @ingroup MEMORY
//----------------------------------------------------------------------------//

#ifndef _memory_object_h
#define _memory_object_h

//! @addtogroup MEMORY_OBJECT
//! @{
//!

//----------------------------------------------------------------------------//
#pragma mark -  Types
//! @name       Types
//----------------------------------------------------------------------------//

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
//! @internal
//
typedef struct mk_memory_object_s {
    __MK_RUNTIME_BASE
    // A pointer back to the memory map that initialized this object.
    struct mk_memory_map_s *mapping;
    // The host-relative address of the mapped memory.
    mk_vm_address_t host_address;
    // The in-memory address at which the target address has been mapped.
    vm_address_t address;
    // The total requested length of the mapping. This value is the literal
    // requested length.
    vm_size_t length;
    // Implementation specific.
    uint64_t reserved1;
    uint64_t reserved2;
} mk_memory_object_t;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
//! The Memory Object polymorphic type.
//
typedef union {
    struct mk_memory_object_s *memory_object;
} mk_memory_object_ref __attribute__((__transparent_union__));

//! The identifier for the Memory Object type.
_mk_export intptr_t mk_memory_object_type;


//----------------------------------------------------------------------------//
#pragma mark -  Instance Methods
//! @name       Instance Methods
//----------------------------------------------------------------------------//

//! Cleans up any resources held by \a memory_object.  It is no longer safe to
//! use \a memory_object after calling this function.
_mk_export void
mk_memory_object_free(mk_memory_object_ref memory_object);

//! Returns the base process-relative address of \a mobj.
//!
//! @param  mobj
//!         An initialized memory object.
_mk_export vm_address_t
mk_memory_object_address(mk_memory_object_ref mobj);

//! Returns the length of \a mobj.
//!
//! @param  mobj
//!         An initialized memory object.
_mk_export vm_size_t
mk_memory_object_length(mk_memory_object_ref mobj);

//! Returns the base host-relative address of \a mobj.
//!
//! @param  mobj
//!         An initialized memory object.
_mk_export mk_vm_address_t
mk_memory_object_host_address(mk_memory_object_ref mobj);

//! Returns the process-relative range of memory represented by \a mobj.
//!
//! @param  mobj
//!         An initialized memory object.
_mk_export mk_vm_range_t
mk_memory_object_range(mk_memory_object_ref mobj);

//! Returns the host-relative range of memory represented by \a mobj.
//!
//! @param  mobj
//!         An initialized memory object.
_mk_export mk_vm_range_t
mk_memory_object_host_range(mk_memory_object_ref mobj);

//! Verifies that \a length bytes starting at the process-relative
//! (\a address + \a offset) is within \a mobj's mapped range.
//!
//! @param  mobj
//!         An initialized memory object.
//! @param  address
//!         A process-relative address.
//! @param  offset
//!         An offset to be applied to \a address prior to verifying the
//!         address range.
//! @param  length
//!         The number of bytes that should be readable at
//!         \a address + \a offset.
_mk_export bool
mk_memory_object_verify_local_pointer(mk_memory_object_ref mobj, vm_offset_t offset, vm_address_t address, vm_size_t length, mk_error_t* error);

//! Validates the availability of (\a address + \a offset) via \a mobj and
//! returns a process-relative pointer to the memory.
//!
//! @param  mobj
//!         An initialized memory object.
//! @param  address
//!         The base host-relative address to be read.
//! @param  offset
//!         An offset to be applied to \a address prior to verifying the
//!         address range.
//! @param  length
//!         The total number of bytes that should be readable at \a address.
_mk_export vm_address_t
mk_memory_object_remap_address(mk_memory_object_ref mobj, mk_vm_offset_t offset, mk_vm_address_t address, mk_vm_size_t length, mk_error_t* error);

//! The reverse of the remap operation, verifies the process-relative \a address
//! then converts it into a host-relative address.
//!
//! @param  mobj
//!         An initialized memory object.
//! @param  address
//!         The base process-relative address to be unmapped.
//! @param  offset
//!         An offset to be applied to \a address prior to verifying the
//!         address range.
//! @param  length
//!         The total number of bytes that should be readable at \a address.
_mk_export mk_vm_address_t
mk_memory_object_unmap_address(mk_memory_object_ref mobj, vm_offset_t offset, vm_address_t address, vm_size_t length, mk_error_t* error);

//! Returns the byte at \a offset + \a address in \a mobj, performing
//! any necessary byte-swapping.
_mk_export uint8_t
mk_memory_object_read_byte(mk_memory_object_ref mobj, mk_vm_offset_t offset, mk_vm_address_t address, mk_data_model_ref data_model, mk_error_t *error);

//! Returns the word at \a offset + \a address in \a mobj, performing
//! any necessary byte-swapping.
_mk_export uint16_t
mk_memory_object_read_word(mk_memory_object_ref mobj, mk_vm_offset_t offset, mk_vm_address_t address, mk_data_model_ref data_model, mk_error_t *error);

//! Returns the dword at \a offset + \a address in \a mobj, performing
//! any necessary byte-swapping.
_mk_export uint32_t
mk_memory_object_read_dword(mk_memory_object_ref mobj, mk_vm_offset_t offset, mk_vm_address_t address, mk_data_model_ref data_model, mk_error_t *error);

//! Returns the dword at \a offset + \a address in \a mobj, performing
//! any necessary byte-swapping.
_mk_export uint64_t
mk_memory_object_read_qword(mk_memory_object_ref mobj, mk_vm_offset_t offset, mk_vm_address_t address, mk_data_model_ref data_model, mk_error_t *error);


//! @} MEMORY_OBJECT !//

#endif /* _memory_object_h */
