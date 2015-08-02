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
__mk_indirect_symbol_table_get_context(mk_type_ref self)
{ return mk_type_get_context( &((mk_symbol_table_t*)self)->link_edit ); }

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
mk_indirect_symbol_table_init(mk_segment_ref link_edit, mk_load_command_ref dysymtab_cmd, mk_indirect_symbol_table_t *symbol_table)
{
    if (symbol_table == NULL) return MK_EINVAL;
    if (link_edit.segment == NULL) return MK_EINVAL;
    if (dysymtab_cmd.load_command == NULL || mk_load_command_id(dysymtab_cmd) != mk_load_command_dysymtab_id()) return MK_EINVAL;
    
    if (mk_load_command_get_macho(dysymtab_cmd).macho != mk_segment_get_macho(link_edit).macho)
        return MK_EINVAL;
    
    uint32_t indirectsymoff = mk_load_command_dysymtab_get_indirectsymoff(dysymtab_cmd);
    uint32_t nindirectsyms = mk_load_command_dysymtab_get_nindirectsyms(dysymtab_cmd);
    
    if (indirectsymoff == 0)
        return MK_ENOT_FOUND;
    
    mk_vm_address_t vm_address = mk_segment_get_range(link_edit).location;
    mk_error_t err;
    
    // This already include the slide.
    if ((err = mk_vm_address_add(vm_address, indirectsymoff, &vm_address))) {
        _mkl_error(mk_type_get_context(link_edit.segment), "Arithmetic error %s while adding offset (%" PRIi32 ") to __LINKEDIT vm_address (0x%" MK_VM_PRIxADDR ")", mk_error_string(err), indirectsymoff, vm_address);
        return err;
    }
    
    // For some reason we need to subtract the fileOffset of the __LINKEDIT
    // segment.
    if ((err = mk_vm_address_subtract(vm_address, mk_segment_get_fileoff(link_edit), &vm_address))) {
        _mkl_error(mk_type_get_context(link_edit.segment), "Arithmetic error %s while subtracting __LINKEDIT fileOffset (0x%" MK_VM_PRIxADDR ") from (0x%" MK_VM_PRIxADDR ")", mk_error_string(err), mk_segment_get_fileoff(link_edit), vm_address);
        return err;
    }
    
    symbol_table->link_edit = link_edit;
    symbol_table->range = mk_vm_range_make(vm_address, nindirectsyms * sizeof(uint32_t));
    
    // Make sure we are fully within the link_edit segment
    if ((err = mk_vm_range_contains_range(mk_segment_get_range(link_edit), symbol_table->range, false))) {
        _mkl_error(mk_type_get_context(link_edit.segment), "__LINKEDIT segment does not fully contain the indirect symbol table.");
        return err;
    }
    
    symbol_table->vtable = &_mk_indirect_symbol_table_class;
    return MK_ESUCCESS;
}

//|++++++++++++++++++++++++++++++++++++|//
mk_error_t
mk_indirect_symbol_table_init_with_mach_dysymtab(mk_segment_ref link_edit, struct dysymtab_command *mach_dysymtab, mk_indirect_symbol_table_t *symbol_table)
{
    if (link_edit.segment == NULL) return MK_EINVAL;
    if (mach_dysymtab == NULL) return MK_EINVAL;
    
    mk_error_t err;
    mk_load_command_t dysymtab_cmd;
    
    if ((err = mk_load_command_init(mk_segment_get_macho(link_edit), (struct load_command*)mach_dysymtab, &dysymtab_cmd)))
        return err;
    
    return mk_indirect_symbol_table_init(link_edit, &dysymtab_cmd, symbol_table);
}

//|++++++++++++++++++++++++++++++++++++|//
mk_error_t
mk_indirect_symbol_table_init_with_segment(mk_segment_ref link_edit, mk_indirect_symbol_table_t *symbol_table)
{
    if (link_edit.segment == NULL) return MK_EINVAL;
    
    struct load_command *mach_dysymtab = mk_macho_find_command(mk_segment_get_macho(link_edit), LC_DYSYMTAB, NULL);
    if (mach_dysymtab == NULL) {
        _mkl_error(mk_type_get_context(link_edit.segment), "No LC_DYSYMTAB command in %s", mk_macho_get_name(mk_segment_get_macho(link_edit)));
        return MK_ENOT_FOUND;
    }
    
    return mk_indirect_symbol_table_init_with_mach_dysymtab(link_edit, (struct dysymtab_command*)mach_dysymtab, symbol_table);
}

//|++++++++++++++++++++++++++++++++++++|//
mk_macho_ref mk_indirect_symbol_table_get_macho(mk_indirect_symbol_table_ref symbol_table)
{ return mk_segment_get_macho(symbol_table.symbol_table->link_edit); }

//|++++++++++++++++++++++++++++++++++++|//
mk_segment_ref mk_indirect_symbol_table_get_seg_link_edit(mk_indirect_symbol_table_ref symbol_table)
{ return symbol_table.symbol_table->link_edit; }

//|++++++++++++++++++++++++++++++++++++|//
mk_vm_range_t mk_indirect_symbol_table_get_range(mk_indirect_symbol_table_ref symbol_table)
{ return symbol_table.symbol_table->range; }

//|++++++++++++++++++++++++++++++++++++|//
uint32_t mk_indirect_symbol_table_get_count(mk_indirect_symbol_table_ref symbol_table)
{ return (uint32_t)(symbol_table.symbol_table->range.length / sizeof(uint32_t)); }

//----------------------------------------------------------------------------//
#pragma mark -  Looking Up Symbols
//----------------------------------------------------------------------------//

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
mk_indirect_symbol_table_get_value_at_index(mk_indirect_symbol_table_ref symbol_table, uint32_t index, mk_vm_address_t* host_address)
{
    mk_vm_offset_t sym_off;
    vm_address_t addr;
    
    if (index >= mk_indirect_symbol_table_get_count(symbol_table))
        return UINT32_MAX;
    
    // Compute the offset of the value at index.
    sym_off = index * sizeof(uint32_t);
    
    addr = mk_memory_object_remap_address(mk_segment_get_mobj(symbol_table.symbol_table->link_edit), sym_off, symbol_table.symbol_table->range.location, sizeof(uint32_t), NULL);
    if (addr == UINTPTR_MAX)
        return UINT32_MAX;
    
    mk_vm_address_apply_offset(symbol_table.symbol_table->range.location, sym_off, host_address);
    return *(uint32_t*)addr;
}

//|++++++++++++++++++++++++++++++++++++|//
#if __BLOCKS__
void
mk_indirect_symbol_table_enumerate_values(mk_indirect_symbol_table_ref symbol_table, uint32_t index,
                                          void (^enumerator)(uint32_t value, uint32_t index, mk_vm_address_t host_address))
{
    mk_vm_address_t value_addr;
    vm_address_t addr;
    
    if (index >= mk_indirect_symbol_table_get_count(symbol_table))
        return;
    if (mk_vm_address_add(symbol_table.symbol_table->range.location, index * sizeof(uint32_t), &value_addr))
        return;
    addr = mk_memory_object_remap_address(mk_segment_get_mobj(symbol_table.symbol_table->link_edit), 0, value_addr, symbol_table.symbol_table->range.length, NULL);
    if (addr == UINTPTR_MAX)
        return;
    
    do {
        enumerator(*(uint32_t*)addr, index, value_addr);
        
        index++;
        value_addr += sizeof(uint32_t);
        addr  += sizeof(uint32_t);
    } while (index < mk_indirect_symbol_table_get_count(symbol_table));
}
#endif

