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

#if TARGET_OS_MAC && !TARGET_OS_IPHONE

//----------------------------------------------------------------------------//
#pragma mark -  Classes
//----------------------------------------------------------------------------//

//|++++++++++++++++++++++++++++++++++++|//
static mk_error_t
__mk_memory_map_task_init_object(mk_memory_map_ref self, mk_vm_offset_t offset, mk_vm_address_t address, mk_vm_size_t length, bool require_full, mk_memory_object_t* memory_object)
{
    mk_context_t *ctx = mk_type_get_context(self.memory_map);
    
    // Verify that adding the offset value will not overflow.
    if (MK_VM_ADDRESS_MAX - offset < address) {
        _mkl_debug(ctx, "Adding input offset [%" MK_VM_PRIuOFFSET "] to input address [0x%" MK_VM_PRIxADDR "] would overflow.", offset, address);
        return MK_EOVERFLOW;
    }
    
    // Compute the offset address
    mk_vm_address_t context_address = address + offset;
    
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
            _mkl_debug(ctx, "Input range (offset target address = 0x%" MK_VM_PRIxADDR ", length = %" MK_VM_PRIuSIZE ") is not valid.", context_address, length);
            return MK_EOVERFLOW;
        }
    }
    // Check if adding the total_length to the base_context_address would overflow.
    else if (UINT64_MAX - total_length < base_context_address)
    {
        if (!require_full)
            total_length = UINT64_MAX - base_context_address;
        else {
            _mkl_debug(ctx, "Input range (offset target address = 0x%" MK_VM_PRIxADDR ", length = %" MK_VM_PRIuSIZE ") is not valid.", context_address, length);
            return MK_EOVERFLOW;
        }
    }
    
    // total_length should still be page aligned.
    _mk_assert((total_length & vm_page_mask) == 0, ctx, "total_length must be page aligned.");
    
    // If short mappings are permitted, determine the actual mappable size of
    // the target range.
    if (!require_full)
    {
        mach_vm_size_t verified_length = 0;
        
        while (verified_length < length) {
            memory_object_size_t entry_length = total_length - verified_length;
            mach_port_t mem_handle;
            kern_return_t kr;
            
            kr = mach_make_memory_entry_64(self.memory_map_task->task, &entry_length, base_context_address + verified_length, VM_PROT_READ, &mem_handle, MACH_PORT_NULL);
            // Break once we hit an unmappable page.
            if (kr != KERN_SUCCESS)
                break;
            
            // Drop the reference
            kr = mach_port_mod_refs(mach_task_self(), mem_handle, MACH_PORT_RIGHT_SEND, -1);
            if (kr != KERN_SUCCESS) {
                _mkl_inform(ctx, "Failed to drop memory entry send right.  mach_port_mod_refs() returned error [%i].  #Port #Leak", kr);
            }
            
            verified_length += entry_length;
        }
        
        // No mappable pages found at contextAddress.
        if (verified_length == 0) {
            int target_pid = -1;
            pid_for_task(self.memory_map_task->task, &target_pid);
            _mkl_debug(ctx, "Input range (offset target address = 0x%" MK_VM_PRIxADDR ", length = %" MK_VM_PRIuSIZE ") is not valid in target task (PID = %i).", context_address, length, target_pid);
            return MK_EBAD_ACCESS;
        }
        
        if (verified_length < total_length)
            total_length = verified_length;
    }
    
    mach_vm_address_t mapping_address = 0x0;
    mach_vm_size_t mapped_length = 0;
    
    // Reserve enough pages to contain the mapping.
    kern_return_t kr = mach_vm_allocate(mach_task_self(), &mapping_address, total_length, VM_FLAGS_ANYWHERE);
    if (kr != KERN_SUCCESS) {
        _mkl_error(ctx, "Failed to allocate space for mapping memory from target task.  mach_vm_allocate() returned error [%i].", kr);
        return MK_EINTERNAL_ERROR;
    }
    
    // Perform the mapping
    while (mapped_length < total_length) {
        memory_object_size_t entry_length = total_length - mapped_length;
        mach_port_t mem_handle;
        kern_return_t kr;
        
        // Create a reference to the target pages.  The returned entry may be
        // smaller than the entryLength.
        kr = mach_make_memory_entry_64(self.memory_map_task->task, &entry_length, base_context_address + mapped_length, VM_PROT_READ, &mem_handle, MACH_PORT_NULL);
        if (kr != KERN_SUCCESS)
        {
            // Cleanup the reserved pages
            kr = mach_vm_deallocate(mach_task_self(), mapping_address, total_length);
            if (kr != KERN_SUCCESS) {
                _mkl_inform(ctx, "Failed to drop memory entry send right.  mach_port_mod_refs() returned error [%i].  #Port #Leak", kr);
            }
            
            int target_pid = -1;
            pid_for_task(self.memory_map_task->task, &target_pid);
            _mkl_debug(ctx, "Memory region (target address = 0x%" MK_VM_PRIxADDR ", length = %" MK_VM_PRIuSIZE ") is not valid in target process (PID = %i).  mach_make_memory_entry_64() returned error [%i].", base_context_address + mapped_length, entry_length, target_pid, kr);
            return MK_EBAD_ACCESS;
        }
        
        // Map the pages into our local task, overwriting the allocation used to
        // reserve the target space above.
        mach_vm_address_t targetAddress = mapping_address + mapped_length;
        kr = mach_vm_map(mach_task_self(), &targetAddress, entry_length, 0x0, VM_FLAGS_FIXED|VM_FLAGS_OVERWRITE, mem_handle, 0x0, true, VM_PROT_READ, VM_PROT_READ, VM_INHERIT_COPY);
        if (kr != KERN_SUCCESS)
        {
            // Cleanup the reserved pages
            kr = mach_vm_deallocate(mach_task_self(), mapping_address, total_length);
            if (kr != KERN_SUCCESS) {
                _mkl_inform(ctx, "Failed to deallocate space for mapping target process memory.  mach_vm_deallocate() returned error [%i].  #Memory #Leak", kr);
            }
            
            // Drop the memory handle
            kr = mach_port_mod_refs(mach_task_self(), mem_handle, MACH_PORT_RIGHT_SEND, -1);
            if (kr != KERN_SUCCESS) {
                _mkl_inform(ctx, "Failed to drop memory entry send right.  mach_port_mod_refs() returned error [%i].  #Port #Leak", kr);
            }
            
            _mkl_error(ctx, "Failed to map target process memory.  mach_vm_map() returned error [%i].", kr);
            return MK_EINTERNAL_ERROR;
        }
        
        // Drop the memory handle
        kr = mach_port_mod_refs(mach_task_self(), mem_handle, MACH_PORT_RIGHT_SEND, -1);
        if (kr != KERN_SUCCESS) {
            _mkl_inform(ctx, "Failed to drop memory entry send right.  mach_port_mod_refs() returned error [%i].  #Port #Leak", kr);
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
    memory_object->target_address = context_address;
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
    kern_return_t err = mach_vm_deallocate(mach_task_self(), memory_object->reserved1, memory_object->reserved2);
    if (err != KERN_SUCCESS) {
        _mkl_inform(mk_type_get_context(self.memory_map), "Failed to cleanup mapped target memory.  mach_vm_deallocate() returned error [%i].  #Memory #Leak", err);
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
    if (err != KERN_SUCCESS) {
        _mkl_error(ctx, "Failed to retain target task port.  mach_port_mod_refs() returned error [%i].  #Port", err);
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
    kern_return_t err = mach_port_mod_refs(mach_task_self(), task_map->task, MACH_PORT_RIGHT_SEND, -1);
    if (err != KERN_SUCCESS) {
        _mkl_inform(mk_type_get_context(task_map), "Failed to drop target task send right.  mach_port_mod_refs() returned error [%i].  #Port #Leak", err);
    }
    task_map->base.vtable = NULL;
    
    return MK_ESUCCESS;
}

#endif
