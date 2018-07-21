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
__mk_string_table_get_context(mk_string_table_ref self)
{ return mk_type_get_context( self.string_table->link_edit.type ); }

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
mk_string_table_init(mk_segment_ref segment, mk_load_command_ref load_command, mk_string_table_t *string_table)
{
    if (string_table == NULL) return MK_EINVAL;
    if (segment.segment == NULL) return MK_EINVAL;
    if (load_command.load_command == NULL) return MK_EINVAL;
    
    if (mk_load_command_id(load_command) != mk_load_command_symtab_id()) {
        _mkl_debug(mk_type_get_context(segment.type), "Unsupported load command type [%s].", mk_type_name(load_command.type));
        return MK_EINVAL;
    }
    
    if (!mk_type_equal(mk_load_command_get_macho(load_command).type, mk_segment_get_macho(segment).type)) {
        return MK_EINVAL;
    }
    
    uint32_t lc_stroff = mk_load_command_symtab_get_stroff(load_command);
    uint32_t lc_strsize = mk_load_command_symtab_get_strsize(load_command);
    
    // If lc_stroff is 0, there is no string table.
    if (lc_stroff == 0)
        return MK_ENOT_FOUND;
    
    // This already includes the slide.
    mk_vm_address_t vm_address = mk_segment_get_target_range(segment).location;
    mk_vm_size_t vm_size = lc_strsize;
    
    mk_error_t err;
    
    // Apply the offset.
    if ((err = mk_vm_address_apply_offset(vm_address, lc_stroff, &vm_address))) {
        _mkl_debug(mk_type_get_context(segment.type), "Arithmetic error [%s] applying string table offset [%" PRIu32 "] to LINKEDIT segment target address [0x%" MK_VM_PRIxADDR "].", mk_error_string(err), lc_stroff, vm_address);
        return err;
    }
    
    // For some reason we need to subtract the fileOffset of the __LINKEDIT
    // segment.
    if ((err = mk_vm_address_subtract(vm_address, mk_segment_get_fileoff(segment), &vm_address))) {
        _mkl_debug(mk_type_get_context(segment.type), "Arithmetic error [%s] subtracting LINKEDIT segment file offset [0x%" MK_VM_PRIxADDR "] from string table target address [0x%" MK_VM_PRIxADDR "].", mk_error_string(err), mk_segment_get_fileoff(segment), vm_address);
        return err;
    }
    
    string_table->link_edit = segment;
    string_table->target_range = mk_vm_range_make(vm_address, vm_size);
    
    // Make sure the string table is completely within the link_edit segment
    if ((err = mk_vm_range_contains_range(mk_segment_get_target_range(segment), string_table->target_range, false))) {
        char buffer[512] = { 0 };
        mk_type_copy_description(segment.type, buffer, sizeof(buffer));
        _mkl_debug(mk_type_get_context(segment.type), "Part of string table (target_address = 0x%" MK_VM_PRIxADDR ", size = 0x%" MK_VM_PRIxSIZE ") is not within LINKEDIT segment %s.", string_table->target_range.location, string_table->target_range.length, buffer);
        return err;
    }
    
    string_table->vtable = &_mk_string_table_class;
    return MK_ESUCCESS;
}

//|++++++++++++++++++++++++++++++++++++|//
mk_error_t
mk_string_table_init_with_mach_load_command(mk_segment_ref segment, struct symtab_command *lc, mk_string_table_t *string_table)
{
    if (segment.segment == NULL) return MK_EINVAL;
    if (lc == NULL) return MK_EINVAL;
    
    mk_error_t err;
    mk_load_command_t load_command;
    
    if ((err = mk_load_command_init(mk_segment_get_macho(segment), (struct load_command*)lc, &load_command)))
        return err;
    
    return mk_string_table_init(segment, &load_command, string_table);
}

//|++++++++++++++++++++++++++++++++++++|//
mk_error_t
mk_string_table_init_with_segment(mk_segment_ref segment, mk_string_table_t *string_table)
{
    if (segment.segment == NULL) return MK_EINVAL;
    
    mk_macho_ref image = mk_segment_get_macho(segment);
    // dyld uses the *last* LC_SYMTAB in the load commands list.
    struct load_command *lc = mk_macho_last_command_type(image, LC_SYMTAB, NULL);
    
    if (lc == NULL) {
        char buffer[512] = { 0 };
        mk_type_copy_description(image.type, buffer, sizeof(buffer));
        _mkl_debug(mk_type_get_context(segment.type), "LC_SYMTAB load command not found in Mach-O image %s.", buffer);
        return MK_ENOT_FOUND;
    }
    
    return mk_string_table_init_with_mach_load_command(segment, (struct symtab_command*)lc, string_table);
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
mk_segment_ref mk_string_table_get_segment(mk_string_table_ref string_table)
{ return string_table.string_table->link_edit; }

//|++++++++++++++++++++++++++++++++++++|//
mk_vm_range_t mk_string_table_get_target_range(mk_string_table_ref string_table)
{ return string_table.string_table->target_range; }

//----------------------------------------------------------------------------//
#pragma mark -  Looking Up Strings
//----------------------------------------------------------------------------//

//|++++++++++++++++++++++++++++++++++++|//
const char*
mk_string_table_get_string_at_offset(mk_string_table_ref string_table, uint32_t offset, mk_vm_address_t* target_address)
{
    mk_vm_address_t addr;
    mk_vm_size_t len;
    
    if (mk_vm_address_apply_offset(string_table.string_table->target_range.location, offset, &addr) != MK_ESUCCESS)
        return NULL;
    
    // Verify that offset is within the string table.
    if (mk_vm_range_contains_address(string_table.string_table->target_range, 0, addr) != MK_ESUCCESS)
        return NULL;
    
    // Determine the maximum length
    len = string_table.string_table->target_range.length - offset;
    
    uintptr_t string = mk_memory_object_remap_address(mk_segment_get_mapping(string_table.string_table->link_edit), 0, addr, len, NULL);
    if (string == UINTPTR_MAX)
        return NULL;
    
    // TODO - What if the string is not NULL terminated, or the NULL terminator
    // is outside our range?
    if (target_address) *target_address = addr;
    return (const char*)string;
}

//|++++++++++++++++++++++++++++++++++++|//
size_t
mk_string_table_copy_string_at_offset(mk_string_table_ref string_table, uint32_t offset, char buffer[], size_t max_len)
{
    mk_vm_address_t addr;
    mk_vm_size_t len;
    
    if (mk_vm_address_apply_offset(string_table.string_table->target_range.location, offset, &addr) != MK_ESUCCESS)
        return 0;
    
    // Verify that offset is within the string table.
    if (mk_vm_range_contains_address(string_table.string_table->target_range, 0, addr) != MK_ESUCCESS)
        return 0;
    
    // Determine the maximum length
    len = string_table.string_table->target_range.length - offset;
    
    uintptr_t string = mk_memory_object_remap_address(mk_segment_get_mapping(string_table.string_table->link_edit), 0, addr, len, NULL);
    if (string == UINTPTR_MAX)
        return 0;
    
    // Do not include the NULL byte.
    size_t string_len = strnlen((const char*)string, (size_t)len);
    memcpy(buffer, (void*)string, MIN(string_len, max_len));
    return MIN(string_len, max_len);
}

//|++++++++++++++++++++++++++++++++++++|//
const char*
mk_string_table_next_string(mk_string_table_ref string_table, const char* previous, uint32_t* offset, mk_vm_address_t* target_address)
{
    if (previous == NULL) {
        const char *retValue = mk_string_table_get_string_at_offset(string_table, 0, target_address);
        if (retValue && offset) *offset = 0;
        return retValue;
    }
    
    mk_memory_object_ref mapping = mk_segment_get_mapping(string_table.string_table->link_edit);
    
    mk_vm_size_t len;
    mk_vm_address_t addr;
    
    addr = mk_memory_object_unmap_address(mapping, 0, (uintptr_t)previous, 1, NULL);
    if (addr == MK_VM_ADDRESS_INVALID) {
        char buffer[512] = { 0 };
        mk_type_copy_description(mapping.memory_object, buffer, sizeof(buffer));
        _mkl_debug(mk_type_get_context(string_table.type), "Previous string pointer [%p] is not within LINKEDIT %s.", previous, buffer);
        return NULL;
    }
    
    // Verify that addr is within the string table.
    if (mk_vm_range_contains_address(string_table.string_table->target_range, 0, addr) != MK_ESUCCESS) {
        char buffer[512] = { 0 };
        mk_type_copy_description(string_table.type, buffer, sizeof(buffer));
        _mkl_debug(mk_type_get_context(string_table.type), "Previous string pointer [%p] is not within string table %s.", previous, buffer);
        return NULL;
    }
    
    // Downcast is safe because we already verified addr is in range.
    uint32_t offst = (uint32_t)(addr - string_table.string_table->target_range.location);
    
    // Determine the previous maximum length.
    len = string_table.string_table->target_range.length - offst;
    
    offst += strnlen(previous, (size_t)len);
    offst += 1; // Null byte.
    
    const char *retValue = mk_string_table_get_string_at_offset(string_table, offst, target_address);
    if (retValue && offset) *offset = offst;
    return retValue;
}

//|++++++++++++++++++++++++++++++++++++|//
#if __BLOCKS__
void
mk_string_table_enumerate_strings(mk_string_table_ref string_table, uint32_t offset, void (^enumerator)(const char* string, uint32_t offset, mk_vm_address_t target_address))
{
    mk_memory_object_ref mapping = mk_segment_get_mapping(string_table.string_table->link_edit);
    
    mk_vm_address_t target_address;
    mk_vm_size_t max_length;
    
    if (mk_vm_address_add(string_table.string_table->target_range.location, offset, &target_address))
        return;
    
    // Verify that offset address is within the string table.
    if (mk_vm_range_contains_address(string_table.string_table->target_range, 0, target_address))
        return;
    
    // Determine the maximum length
    max_length = string_table.string_table->target_range.length - offset;
    
    uintptr_t string = mk_memory_object_remap_address(mapping, 0, target_address, max_length, NULL);
    if (string == UINTPTR_MAX)
        return;
    
    do {
        enumerator((const char*)string, offset, target_address);
        
        size_t len = strnlen((const char*)string, (size_t)max_length) + 1;
        target_address += len;
        string += len;
        // If this happens to wrap around, host_address would have gone out of
        // range.
        max_length -= len;
        
    } while (mk_vm_range_contains_address(string_table.string_table->target_range, 0, target_address) == MK_ESUCCESS);
}
#endif
