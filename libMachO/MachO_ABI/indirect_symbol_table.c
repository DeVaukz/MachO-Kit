//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             indirect_symbol_table.c
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
__mk_indirect_symbol_table_get_context(mk_indirect_symbol_table_ref self)
{ return mk_type_get_context( self.symbol_table->link_edit.type ); }

const struct _mk_indirect_symbol_table_vtable _mk_indirect_symbol_table_class = {
    .base.super                 = &_mk_type_class,
    .base.name                  = "indirect symbol table",
    .base.get_context           = &__mk_indirect_symbol_table_get_context
};

intptr_t mk_indirect_symbol_table_type = (intptr_t)&_mk_indirect_symbol_table_class;

//----------------------------------------------------------------------------//
#pragma mark -  Working With The Symbol Table
//----------------------------------------------------------------------------//

//|++++++++++++++++++++++++++++++++++++|//
mk_error_t
mk_indirect_symbol_table_init(mk_segment_ref segment, mk_load_command_ref load_command, mk_indirect_symbol_table_t *symbol_table)
{
    if (symbol_table == NULL) return MK_EINVAL;
    if (segment.segment == NULL) return MK_EINVAL;
    if (load_command.load_command == NULL) return MK_EINVAL;
    
    if (mk_load_command_id(load_command) != mk_load_command_dysymtab_id()) {
        _mkl_debug(mk_type_get_context(segment.type), "Unsupported load command type [%s].", mk_type_name(load_command.type));
        return MK_EINVAL;
    }
    
    if (!mk_type_equal(mk_load_command_get_macho(load_command).type, mk_segment_get_macho(segment).type)) {
        return MK_EINVAL;
    }
    
    uint32_t lc_indirectsymoff = mk_load_command_dysymtab_get_indirectsymoff(load_command);
    uint32_t lc_nindirectsyms = mk_load_command_dysymtab_get_nindirectsyms(load_command);
    
    // If lc_indirectsymoff is 0, there is no indirect symbol table.
    if (lc_indirectsymoff == 0)
        return MK_ENOT_FOUND;
    
    mk_vm_address_t vm_address = mk_segment_get_target_range(segment).location;
    mk_vm_size_t vm_size = lc_nindirectsyms * sizeof(uint32_t);
    
    mk_error_t err;
    
    // Apply the offset.
    if ((err = mk_vm_address_add(vm_address, lc_indirectsymoff, &vm_address))) {
        _mkl_debug(mk_type_get_context(segment.type), "Arithmetic error [%s] applying indirect symbol table offset [%" PRIu32 "] to LINKEDIT segment target address [0x%" MK_VM_PRIxADDR "].", mk_error_string(err), lc_indirectsymoff, vm_address);
        return err;
    }
    
    // For some reason we need to subtract the fileOffset of the __LINKEDIT
    // segment.
    if ((err = mk_vm_address_subtract(vm_address, mk_segment_get_fileoff(segment), &vm_address))) {
        _mkl_debug(mk_type_get_context(segment.type), "Arithmetic error [%s] subtracting LINKEDIT segment file offset [0x%" MK_VM_PRIxADDR "] from symbol table target address [0x%" MK_VM_PRIxADDR "].", mk_error_string(err), mk_segment_get_fileoff(segment), vm_address);
        return err;
    }
    
    symbol_table->link_edit = segment;
    symbol_table->target_range = mk_vm_range_make(vm_address, vm_size);
    
    // Make sure the indirect symbol table is completely within the link_edit segment
    if ((err = mk_vm_range_contains_range(mk_segment_get_target_range(segment), symbol_table->target_range, false))) {
        char buffer[512] = { 0 };
        mk_type_copy_description(segment.type, buffer, sizeof(buffer));
        _mkl_debug(mk_type_get_context(segment.type), "Part of indirect symbol table (target_address = 0x%" MK_VM_PRIxADDR ", size = 0x%" MK_VM_PRIxSIZE ") is not within LINKEDIT segment %s.", symbol_table->target_range.location, symbol_table->target_range.length, buffer);
        return err;
    }
    
    mk_load_command_copy(load_command, &symbol_table->dysymtab_command);
    
    symbol_table->vtable = &_mk_indirect_symbol_table_class;
    return MK_ESUCCESS;
}

//|++++++++++++++++++++++++++++++++++++|//
mk_error_t
mk_indirect_symbol_table_init_with_mach_load_command(mk_segment_ref segment, struct dysymtab_command *lc, mk_indirect_symbol_table_t *symbol_table)
{
    if (segment.segment == NULL) return MK_EINVAL;
    if (lc == NULL) return MK_EINVAL;
    
    mk_error_t err;
    mk_load_command_t load_command;
    
    if ((err = mk_load_command_init(mk_segment_get_macho(segment), (struct load_command*)lc, &load_command)))
        return err;
    
    return mk_indirect_symbol_table_init(segment, &load_command, symbol_table);
}

//|++++++++++++++++++++++++++++++++++++|//
mk_error_t
mk_indirect_symbol_table_init_with_segment(mk_segment_ref segment, mk_indirect_symbol_table_t *symbol_table)
{
    if (segment.segment == NULL) return MK_EINVAL;
    
    mk_macho_ref image = mk_segment_get_macho(segment);
    // dyld uses the *last* LC_DYSYMTAB in the load commands list.
    struct load_command *lc = mk_macho_last_command_type(image, LC_DYSYMTAB, NULL);
    
    if (lc == NULL) {
        char buffer[512] = { 0 };
        mk_type_copy_description(image.type, buffer, sizeof(buffer));
        _mkl_debug(mk_type_get_context(segment.type), "LC_DYSYMTAB load command not found in Mach-O image %s.", buffer);
        return MK_ENOT_FOUND;
    }
    
    return mk_indirect_symbol_table_init_with_mach_load_command(segment, (struct dysymtab_command*)lc, symbol_table);
}

//|++++++++++++++++++++++++++++++++++++|//
void
mk_indirect_symbol_table_free(mk_indirect_symbol_table_ref symbol_table)
{
    symbol_table.symbol_table->vtable = NULL;
}

//|++++++++++++++++++++++++++++++++++++|//
mk_macho_ref mk_indirect_symbol_table_get_macho(mk_indirect_symbol_table_ref symbol_table)
{ return mk_segment_get_macho(symbol_table.symbol_table->link_edit); }

//|++++++++++++++++++++++++++++++++++++|//
mk_segment_ref mk_indirect_symbol_table_get_segment(mk_indirect_symbol_table_ref symbol_table)
{ return symbol_table.symbol_table->link_edit; }

//|++++++++++++++++++++++++++++++++++++|//
mk_vm_range_t mk_indirect_symbol_table_get_target_range(mk_indirect_symbol_table_ref symbol_table)
{ return symbol_table.symbol_table->target_range; }

//----------------------------------------------------------------------------//
#pragma mark -  Looking Up Entries
//----------------------------------------------------------------------------//

//|++++++++++++++++++++++++++++++++++++|//
uint32_t mk_indirect_symbol_table_get_entry_count(mk_indirect_symbol_table_ref symbol_table)
{ return mk_load_command_dysymtab_get_nindirectsyms(&symbol_table.symbol_table->dysymtab_command); }

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
mk_indirect_symbol_table_get_entry_at_index(mk_indirect_symbol_table_ref symbol_table, uint32_t index, mk_vm_address_t* target_address)
{
    mk_vm_address_t addr;
    
    if (index >= mk_indirect_symbol_table_get_entry_count(symbol_table))
        return UINT32_MAX;
    
    if (mk_vm_address_apply_offset(symbol_table.symbol_table->target_range.location, index * sizeof(uint32_t), &addr) != MK_ESUCCESS)
        return UINT32_MAX;
    
    uintptr_t entry = mk_memory_object_remap_address(mk_segment_get_mapping(symbol_table.symbol_table->link_edit), 0, addr, sizeof(uint32_t), NULL);
    if (addr == UINTPTR_MAX)
        return UINT32_MAX;
    
    if (target_address) *target_address = addr;
    return *(uint32_t*)entry;
}

//|++++++++++++++++++++++++++++++++++++|//
#if __BLOCKS__
void
mk_indirect_symbol_table_enumerate_entries(mk_indirect_symbol_table_ref symbol_table, uint32_t index,
                                           void (^enumerator)(uint32_t value, uint32_t index, mk_vm_address_t host_address))
{
    mk_memory_object_ref mapping = mk_segment_get_mapping(symbol_table.symbol_table->link_edit);
    
    mk_vm_address_t target_address;
    mk_vm_size_t max_length;
    
    if (index >= mk_indirect_symbol_table_get_entry_count(symbol_table))
        return;
    
    if (mk_vm_address_add(symbol_table.symbol_table->target_range.location, index * sizeof(uint32_t), &target_address))
        return;
    
    // Determine the remaining length of the indirect symbol table that will be iterated.
    if (mk_vm_address_subtract(symbol_table.symbol_table->target_range.length, index * sizeof(uint32_t), &max_length))
        return;
    
    uintptr_t entry = mk_memory_object_remap_address(mapping, 0, target_address, max_length, NULL);
    if (entry == UINTPTR_MAX)
        return;
    
    do {
        enumerator(*(uint32_t*)entry, index, target_address);
        
        index++;
        entry += sizeof(uint32_t);
        target_address += sizeof(uint32_t);
    } while (index < mk_indirect_symbol_table_get_entry_count(symbol_table));
}
#endif
