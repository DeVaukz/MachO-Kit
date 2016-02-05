//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             memory_map_task.c
//|
//|             D.V.
//|             Copyright (c) 2014-2015 D.V. All rights reserved.
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

#include "core_internal.h"

#if TARGET_OS_MAC && !(TARGET_OS_EMBEDDED || TARGET_OS_SIMULATOR)

//----------------------------------------------------------------------------//
#pragma mark -  Classes
//----------------------------------------------------------------------------//

//|++++++++++++++++++++++++++++++++++++|//
static mk_error_t
__mk_memory_map_task_init_object(mk_memory_map_ref self, mk_vm_offset_t offset, mk_vm_address_t context_address, mk_vm_size_t length, bool require_full, mk_memory_object_t* memory_object)
{
    mk_error_t mk_err;
    
    // Verify that the offset value won't overrun a native pointer and compute
    // the offset address
    if ((mk_err = mk_vm_address_apply_offset(context_address, offset, &context_address))) {
        _mkl_error(mk_type_get_context(self.memory_map), "Arithmetic error %s when adding input offset %" MK_VM_PRIiOFFSET " to input address 0x%" MK_VM_PRIxADDR ".", mk_error_string(mk_err), offset, context_address);
        return mk_err;
    }
    
    mach_vm_address_t base_context_address = mach_vm_trunc_page(context_address);
    mach_vm_offset_t context_address_offset = context_address - base_context_address;
    
    // Derive a new length accounting for the added difference between the
    // contextAddress and the baseContextAddress, rounded to the page size.
    // This may overflow if length is sufficiently close to UINT64_MAX.
    mach_vm_size_t total_length = mach_vm_round_page(length + context_address_offset);
    // Check if we have overflowed.
    if (total_length < length)
    {
        if (!require_full)
            total_length = UINT64_MAX;
        else {
            _mkl_error(mk_type_get_context(self.memory_map), "Input range (offset address = 0x%" MK_VM_PRIxADDR ", length = %" MK_VM_PRIuSIZE ") is not within <%s %p>.", context_address, length, mk_type_name(self.memory_map), self.memory_map);
            return MK_EBAD_ACCESS;
        }
    }
    // Check if adding the total_length to the base_context_address would overflow.
    else if (UINT64_MAX - total_length < base_context_address)
    {
        if (!require_full)
            total_length = UINT64_MAX - base_context_address;
        else {
            _mkl_error(mk_type_get_context(self.memory_map), "Input range (offset address = 0x%" MK_VM_PRIxADDR ", length = %" MK_VM_PRIuSIZE ") is not within <%s %p>.", context_address, length, mk_type_name(self.memory_map), self.memory_map);
            return MK_EBAD_ACCESS;
        }
    }
    
    // total_length should still be page aligned.
    _mk_assert((total_length & vm_page_mask) == 0x0, mk_type_get_context(self.memory_map), "total_length must be page aligned.");
    
    // If short mappings are permitted, determine the actual mappable size of
    // the target range.
    if (!require_full)
    {
        mach_vm_size_t verified_length = 0;
        
        while (verified_length < length) {
            memory_object_size_t entry_length = total_length - verified_length;
            mach_port_t mem_handle;
            kern_return_t error;
            
            error = mach_make_memory_entry_64(self.memory_map_task->task, &entry_length, base_context_address + verified_length, VM_PROT_READ, &mem_handle, MACH_PORT_NULL);
            // Break once we hit an unmappable page.
            if (error != KERN_SUCCESS)
                break;
            
            // Drop the reference
            error = mach_port_mod_refs(mach_task_self(), mem_handle, MACH_PORT_RIGHT_SEND, -1);
            if (error != KERN_SUCCESS) {
                // TODO - Log this.  We're leaking ports.
            }
            
            verified_length += entry_length;
        }
        
        // No mappable pages found at contextAddress.
        if (verified_length == 0) {
            _mkl_error(mk_type_get_context(self.memory_map), "Input range (offset address = 0x%" MK_VM_PRIxADDR ", length = %" MK_VM_PRIuSIZE ") is not within <%s %p>.", context_address, length, mk_type_name(self.memory_map), self.memory_map);
            return MK_EBAD_ACCESS;
        }
        
        if (verified_length < total_length)
            total_length = verified_length;
    }
    
    mach_vm_address_t mapping_address = 0x0;
    mach_vm_size_t mapped_length = 0;
    
    // Reserve enough pages to contain the mapping.
    kern_return_t err = mach_vm_allocate(mach_task_self(), &mapping_address, total_length, VM_FLAGS_ANYWHERE);
    if (err != KERN_SUCCESS) {
        _mkl_error(mk_type_get_context(self.memory_map), "Failed to allocate a target page range for the page remapping.");
        return MK_EBAD_ACCESS;
    }
    
    //
    while (mapped_length < total_length) {
        memory_object_size_t entry_length = total_length - mapped_length;
        mach_port_t mem_handle;
        kern_return_t err;
        
        // Create a reference to the target pages.  The returned entry may be
        // smaller than the entryLength.
        err = mach_make_memory_entry_64(self.memory_map_task->task, &entry_length, base_context_address + mapped_length, VM_PROT_READ, &mem_handle, MACH_PORT_NULL);
        if (err != KERN_SUCCESS)
        {
            // Cleanup the reserved pages
            err = mach_vm_deallocate(mach_task_self(), mapping_address, total_length);
            if (err != KERN_SUCCESS) {
                // TODO - Log this.  We're leaking pages.
            }
            
            _mkl_error(mk_type_get_context(self.memory_map), "Input range (offset address = 0x%" MK_VM_PRIxADDR ", length = %" MK_VM_PRIiSIZE ") is not within memory map.", context_address, length);
            return MK_EBAD_ACCESS;
        }
        
        // Map the pages into our local task, overwriting the allocation used to
        // reserve the target space above.
        mach_vm_address_t targetAddress = mapping_address + mapped_length;
        err = mach_vm_map(mach_task_self(), &targetAddress, entry_length, 0x0, VM_FLAGS_FIXED|VM_FLAGS_OVERWRITE, mem_handle, 0x0, true, VM_PROT_READ, VM_PROT_READ, VM_INHERIT_COPY);
        if (err != KERN_SUCCESS)
        {
            // Cleanup the reserved pages
            err = mach_vm_deallocate(mach_task_self(), mapping_address, total_length);
            if (err != KERN_SUCCESS) {
                // TODO - Log this.  We're leaking pages.
            }
            
            // Drop the memory handle
            err = mach_port_mod_refs(mach_task_self(), mem_handle, MACH_PORT_RIGHT_SEND, -1);
            if (err != KERN_SUCCESS) {
                // TODO - Log this.  We're leaking ports.
            }
            
            _mkl_error(mk_type_get_context(self.memory_map), "mach_vm_map() failure.");
            return MK_EBAD_ACCESS;
        }
        
        // Drop the memory handle
        err = mach_port_mod_refs(mach_task_self(), mem_handle, MACH_PORT_RIGHT_SEND, -1);
        if (err != KERN_SUCCESS) {
            // TODO - Log this.  We're leaking ports.
        }
        
        mapped_length += entry_length;
    }
    
    // Determine the correct offset into the mapping corresponding to the
    // requested address.
    vm_address_t vm_address = (vm_address_t)(mapping_address + context_address_offset);
    length = mapped_length + context_address_offset;
    
    // Initialize the memory object.
    memory_object->vtable = &_mk_memory_object_class;
    memory_object->mapping = self.memory_map;
    memory_object->host_address = context_address;
    memory_object->address = vm_address;
    memory_object->length = (vm_size_t)length;
    memory_object->reserved1 = mapping_address;
    memory_object->reserved1 = mapped_length;
    
    return MK_ESUCCESS;
}

//|++++++++++++++++++++++++++++++++++++|//
static void
__mk_memory_map_task_free_object(mk_memory_map_ref self, mk_memory_object_t* memory_object)
{
#pragma unused (self)
    kern_return_t err = mach_vm_deallocate(mach_task_self(), memory_object->reserved1, memory_object->reserved2);
    if (err != KERN_SUCCESS) {
        // TODO - Warning
    }
}

const struct _mk_memory_map_vtable _mk_memory_map_task_class = {
    .base.super                 = &_mk_memory_map_class,
    .base.name                  = "memory_map_task",
    .init_object                = &__mk_memory_map_task_init_object,
    .free_object                = &__mk_memory_map_task_free_object
};

intptr_t mk_memory_map_task_type = (intptr_t)&_mk_memory_map_task_class;

//----------------------------------------------------------------------------//
#pragma mark -  Creating A Task Memory Map
//----------------------------------------------------------------------------//

//|++++++++++++++++++++++++++++++++++++|//
mk_error_t
mk_memory_map_task_init(mach_port_t task, mk_context_t *ctx, mk_memory_map_task_t *task_map)
{
    kern_return_t err = mach_port_mod_refs(mach_task_self(), task, MACH_PORT_RIGHT_SEND, 1);
    if (err) {
        _mkl_error(ctx, "Failed to retain task port");
        return MK_EINTERNAL_ERROR;
    }
    
    task_map->base.vtable = &_mk_memory_map_task_class;
    task_map->base.context = ctx;
    task_map->task = task;
    
    return MK_ESUCCESS;
}

//|++++++++++++++++++++++++++++++++++++|//
mk_error_t
mk_memory_map_task_free(mk_memory_map_task_t *task_map)
{
    mach_port_mod_refs(mach_task_self(), task_map->task, MACH_PORT_RIGHT_SEND, -1);
    task_map->base.vtable = NULL;
    
    return MK_ESUCCESS;
}

#endif
