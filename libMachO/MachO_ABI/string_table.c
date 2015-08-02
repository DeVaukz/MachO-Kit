//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             string_table.c
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

#include "macho_abi_internal.h"

//----------------------------------------------------------------------------//
#pragma mark -  Classes
//----------------------------------------------------------------------------//

//|++++++++++++++++++++++++++++++++++++|//
static mk_context_t*
__mk_string_table_get_context(mk_type_ref self)
{ return mk_type_get_context( &((mk_string_table_t*)self)->link_edit ); }

const struct _mk_string_table_vtable _mk_string_table_class = {
    .base.super                 = &_mk_type_class,
    .base.name                  = "string table",
    .base.get_context           = &__mk_string_table_get_context
};

intptr_t mk_string_table_type = (intptr_t)&_mk_string_table_class;

//----------------------------------------------------------------------------//
#pragma mark -  Working With The String Table
//----------------------------------------------------------------------------//

//|++++++++++++++++++++++++++++++++++++|//
mk_error_t
mk_string_table_init(mk_segment_ref link_edit, mk_load_command_ref symtab_cmd, mk_string_table_t *string_table)
{
    if (string_table == NULL) return MK_EINVAL;
    if (link_edit.segment == NULL) return MK_EINVAL;
    if (symtab_cmd.load_command == NULL || mk_load_command_id(symtab_cmd) != mk_load_command_symtab_id()) return MK_EINVAL;
    
    if (mk_load_command_get_macho(symtab_cmd).macho != mk_segment_get_macho(link_edit).macho)
        return MK_EINVAL;
    
    uint32_t stroff = mk_load_command_symtab_get_stroff(symtab_cmd);
    uint32_t strsize = mk_load_command_symtab_get_strsize(symtab_cmd);
    
    if (stroff == 0)
        return MK_ENOT_FOUND;
    
    mk_vm_address_t vm_address = mk_segment_get_range(link_edit).location;
    mk_error_t err;
    
    // This already include the slide.
    if ((err = mk_vm_address_add(vm_address, stroff, &vm_address))) {
        _mkl_error(mk_type_get_context(link_edit.segment), "Arithmetic error %s while adding offset (%" PRIi32 ") to __LINKEDIT vm_address (0x%" MK_VM_PRIxADDR ")", mk_error_string(err), stroff, vm_address);
        return err;
    }
    
    // For some reason we need to subtract the fileOffset of the __LINKEDIT
    // segment.
    if ((err = mk_vm_address_subtract(vm_address, mk_segment_get_fileoff(link_edit), &vm_address))) {
        _mkl_error(mk_type_get_context(link_edit.segment), "Arithmetic error %s while subtracting __LINKEDIT file offset (0x%" MK_VM_PRIxADDR ") from (0x%" MK_VM_PRIxADDR ")", mk_error_string(err), mk_segment_get_fileoff(link_edit), vm_address);
        return err;
    }
    
    string_table->link_edit = link_edit;
    string_table->range = mk_vm_range_make(vm_address, strsize);
    
    // Make sure we are fully within the link_edit segment
    if ((err = mk_vm_range_contains_range(mk_segment_get_range(link_edit), string_table->range, false))) {
        _mkl_error(mk_type_get_context(link_edit.segment), "__LINKEDIT segment does not fully contain the string table.");
        return err;
    }
    
    string_table->vtable = &_mk_string_table_class;
    return MK_ESUCCESS;
}

//|++++++++++++++++++++++++++++++++++++|//
mk_error_t
mk_string_table_init_with_mach_symtab(mk_segment_ref link_edit, struct symtab_command *mach_symtab, mk_string_table_t *string_table)
{
    if (link_edit.segment == NULL) return MK_EINVAL;
    if (mach_symtab == NULL) return MK_EINVAL;
    
    mk_error_t err;
    mk_load_command_t symtab_cmd;
    
    if ((err = mk_load_command_init(mk_segment_get_macho(link_edit), (struct load_command*)mach_symtab, &symtab_cmd)))
        return err;
    
    return mk_string_table_init(link_edit, &symtab_cmd, string_table);
}

//|++++++++++++++++++++++++++++++++++++|//
mk_error_t
mk_string_table_init_with_segment(mk_segment_ref link_edit, mk_string_table_t *string_table)
{
    if (link_edit.segment == NULL) return MK_EINVAL;
    
    struct load_command *mach_symtab = mk_macho_find_command(mk_segment_get_macho(link_edit), LC_SYMTAB, NULL);
    if (mach_symtab == NULL) {
        _mkl_error(mk_type_get_context(link_edit.segment), "No LC_SYMTAB command in %s", mk_macho_get_name(mk_segment_get_macho(link_edit)));
        return MK_ENOT_FOUND;
    }
    
    return mk_string_table_init_with_mach_symtab(link_edit, (struct symtab_command*)mach_symtab, string_table);
}

//|++++++++++++++++++++++++++++++++++++|//
void
mk_string_table_free(mk_string_table_ref string_table)
{
    string_table.string_table->vtable = NULL;
}

//|++++++++++++++++++++++++++++++++++++|//
mk_macho_ref mk_string_table_get_macho(mk_string_table_ref string_table)
{ return mk_segment_get_macho(string_table.string_table->link_edit); }

//|++++++++++++++++++++++++++++++++++++|//
mk_segment_ref mk_string_table_get_seg_link_edit(mk_string_table_ref string_table)
{ return string_table.string_table->link_edit; }

//|++++++++++++++++++++++++++++++++++++|//
mk_vm_range_t mk_string_table_get_range(mk_string_table_ref string_table)
{ return string_table.string_table->range; }

//----------------------------------------------------------------------------//
#pragma mark -  Looking Up Strings
//----------------------------------------------------------------------------//

//|++++++++++++++++++++++++++++++++++++|//
const char*
mk_string_table_get_string_at_offset(mk_string_table_ref string_table, uint32_t offset, mk_vm_address_t* host_address)
{
    mk_vm_address_t addr;
    mk_vm_size_t len;
    
    if (mk_vm_address_add(string_table.string_table->range.location, offset, &addr))
        return NULL;
    
    // Verify that offset is within the string table.
    if (mk_vm_range_contains_address(string_table.string_table->range, 0, addr))
        return NULL;
    
    // Determine the maximum length
    len = string_table.string_table->range.length - offset;
    
    vm_address_t string = mk_memory_object_remap_address(mk_segment_get_mobj(string_table.string_table->link_edit), 0, addr, len, NULL);
    if (string == UINTPTR_MAX)
        return NULL;
    
    // TODO - What if the string is not NULL terminated, or the NULL terminator
    // is outside our range?
    if (host_address) *host_address = addr;
    return (const char*)string;
}

//|++++++++++++++++++++++++++++++++++++|//
size_t
mk_string_table_copy_string_at_offset(mk_string_table_ref string_table, uint32_t offset, char buffer[], size_t max_len)
{
    mk_vm_address_t addr;
    mk_vm_size_t len;
    
    if (mk_vm_address_add(string_table.string_table->range.location, offset, &addr))
        return 0;
    
    // Verify that offset is within the string table.
    if (mk_vm_range_contains_address(string_table.string_table->range, 0, addr))
        return 0;
    
    // Determine the maximum length
    len = string_table.string_table->range.length - offset;
    
    vm_address_t string = mk_memory_object_remap_address(mk_segment_get_mobj(string_table.string_table->link_edit), 0, addr, len, NULL);
    if (string == UINTPTR_MAX)
        return 0;
    
    // Do not include the NULL byte.
    size_t string_len = strnlen((const char*)string, (size_t)len);
    memcpy(buffer, (void*)string, MIN(string_len, max_len));
    return MIN(string_len, max_len);
}

//|++++++++++++++++++++++++++++++++++++|//
const char*
mk_string_table_next_string(mk_string_table_ref string_table, const char* previous, uint32_t* offset, mk_vm_address_t* host_address)
{
    mk_vm_size_t len;
    mk_vm_address_t addr = mk_memory_object_unmap_address(mk_segment_get_mobj(string_table.string_table->link_edit), 0, (vm_address_t)previous, 1, NULL);
    if (addr == MK_VM_ADDRESS_INVALID) {
        _mkl_error(mk_type_get_context(string_table.string_table), "Previous value %p is not within <mk_string_table %p>", previous, string_table.string_table);
        return NULL;
    }
    
    // Verify that addr is within the string table.
    if (mk_vm_range_contains_address(string_table.string_table->range, 0, addr)) {
        _mkl_error(mk_type_get_context(string_table.string_table), "Previous value %p is not within <mk_string_table %p>", previous, string_table.string_table);
        return NULL;
    }
    
    // Downcast is safe because we already verified addr is in our range.
    uint32_t offst = (uint32_t)(addr - string_table.string_table->range.location);
    
    // Determine the previous maximum length
    len = string_table.string_table->range.length - offst;
    
    offst += strnlen(previous, (size_t)len);
    offst += 1; // Null byte.
    
    const char *retValue = mk_string_table_get_string_at_offset(string_table, offst, host_address);
    if (retValue && offset) *offset = offst;
    return retValue;
}

//|++++++++++++++++++++++++++++++++++++|//
#if __BLOCKS__
void
mk_string_table_enumerate_strings(mk_string_table_ref string_table, uint32_t offset, void (^enumerator)(const char* string, uint32_t offset, mk_vm_address_t context_address))
{
    mk_vm_size_t max_length;
    mk_vm_address_t host_address;
    vm_address_t address;
    
    if (mk_vm_address_add(string_table.string_table->range.location, offset, &host_address))
        return;
    
    // Verify that offset address is within the string table.
    if (mk_vm_range_contains_address(string_table.string_table->range, 0, host_address))
        return;
    
    // Determine the maximum length
    max_length = string_table.string_table->range.location - offset;
    
    address = mk_memory_object_remap_address(mk_segment_get_mobj(string_table.string_table->link_edit), 0, host_address, max_length, NULL);
    if (address == UINTPTR_MAX)
        return;
    
    do {
        enumerator((const char*)address, offset, host_address);
        
        size_t len = strnlen((const char*)address, (size_t)max_length) + 1;
        host_address += len;
        address += len;
        // If this happens to wrap around, host_address would have gone out of
        // range.
        max_length -= len;
        
    } while (mk_vm_range_contains_address(string_table.string_table->range, 0, host_address));
}
#endif
