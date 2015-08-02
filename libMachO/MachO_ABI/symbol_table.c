//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             symbol_table.c
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
__mk_symbol_table_get_context(mk_type_ref self)
{ return mk_type_get_context( &((mk_symbol_table_t*)self)->link_edit ); }

const struct _mk_symbol_table_vtable _mk_symbol_table_class = {
    .base.super                 = &_mk_type_class,
    .base.name                  = "symbol table",
    .base.get_context           = &__mk_symbol_table_get_context
};

intptr_t mk_symbol_table_type = (intptr_t)&_mk_symbol_table_class;

//----------------------------------------------------------------------------//
#pragma mark -  Working With The Symbol Table
//----------------------------------------------------------------------------//

//|++++++++++++++++++++++++++++++++++++|//
mk_error_t
mk_symbol_table_init(mk_segment_ref link_edit, mk_load_command_ref symtab_cmd, mk_load_command_ref dysymtab_cmd, mk_symbol_table_t *symbol_table)
{
    if (symbol_table == NULL) return MK_EINVAL;
    if (link_edit.segment == NULL) return MK_EINVAL;
    if (symtab_cmd.load_command == NULL || mk_load_command_id(symtab_cmd) != mk_load_command_symtab_id()) return MK_EINVAL;
    if (dysymtab_cmd.load_command && mk_load_command_id(dysymtab_cmd) != mk_load_command_dysymtab_id()) return MK_EINVAL;
    
    if (mk_load_command_get_macho(symtab_cmd).macho != mk_segment_get_macho(link_edit).macho)
        return MK_EINVAL;
    if (dysymtab_cmd.load_command && mk_load_command_get_macho(dysymtab_cmd).macho != mk_segment_get_macho(link_edit).macho)
        return MK_EINVAL;
    
    uint32_t symoff = mk_load_command_symtab_get_symoff(symtab_cmd);
    uint32_t nsyms = mk_load_command_symtab_get_nsyms(symtab_cmd);
    mk_vm_size_t symsize;
    if (mk_data_model_is_64_bit(mk_macho_get_data_model(mk_segment_get_macho(link_edit))))
        symsize = nsyms * sizeof(struct nlist_64);
    else
        symsize = nsyms * sizeof(struct nlist);
    
    if (symoff == 0)
        return MK_ENOT_FOUND;
    
    mk_vm_address_t vm_address = mk_segment_get_range(link_edit).location;
    mk_error_t err;
    
    // This already include the slide.
    if ((err = mk_vm_address_add(vm_address, symoff, &vm_address))) {
        _mkl_error(mk_type_get_context(link_edit.segment), "Arithmetic error %s while adding offset (%" PRIi32 ") to __LINKEDIT vm_address (0x%" MK_VM_PRIxADDR ")", mk_error_string(err), symoff, vm_address);
        return err;
    }
    
    // For some reason we need to subtract the fileOffset of the __LINKEDIT
    // segment.
    if ((err = mk_vm_address_subtract(vm_address, mk_segment_get_fileoff(link_edit), &vm_address))) {
        _mkl_error(mk_type_get_context(link_edit.segment), "Arithmetic error %s while subtracting __LINKEDIT fileOffset (0x%" MK_VM_PRIxADDR ") from (0x%" MK_VM_PRIxADDR ")", mk_error_string(err), mk_segment_get_fileoff(link_edit), vm_address);
        return err;
    }
    
    symbol_table->link_edit = link_edit;
    symbol_table->range = mk_vm_range_make(vm_address, symsize);
    symbol_table->symbol_count = nsyms;
    
    // Make sure we are fully within the link_edit segment
    if ((err = mk_vm_range_contains_range(mk_segment_get_range(link_edit), symbol_table->range, false))) {
        _mkl_error(mk_type_get_context(link_edit.segment), "__LINKEDIT segment does not fully contain the symbol table.");
        return err;
    }
    
    if (dysymtab_cmd.load_command)
        mk_load_command_copy(dysymtab_cmd, &symbol_table->dysymtab_cmd);
    
    symbol_table->vtable = &_mk_symbol_table_class;
    return MK_ESUCCESS;
}

//|++++++++++++++++++++++++++++++++++++|//
mk_error_t
mk_symbol_table_init_with_mach_symtab(mk_segment_ref link_edit, struct symtab_command *mach_symtab, struct dysymtab_command *mach_dysymtab, mk_symbol_table_t *symbol_table)
{
    if (link_edit.segment == NULL) return MK_EINVAL;
    if (mach_symtab == NULL) return MK_EINVAL;
    
    mk_error_t err;
    mk_load_command_t symtab_cmd;
    mk_load_command_t dysymtab_cmd;
    
    if ((err = mk_load_command_init(mk_segment_get_macho(link_edit), (struct load_command*)mach_symtab, &symtab_cmd)))
        return err;
    
    if (mach_dysymtab && (err = mk_load_command_init(mk_segment_get_macho(link_edit), (struct load_command*)mach_dysymtab, &dysymtab_cmd)))
        return err;
    
    return mk_symbol_table_init(link_edit, &symtab_cmd, (mach_dysymtab ? &dysymtab_cmd : NULL), symbol_table);
}

//|++++++++++++++++++++++++++++++++++++|//
mk_error_t
mk_symbol_table_init_with_segment(mk_segment_ref link_edit, mk_symbol_table_t *symbol_table)
{
    if (link_edit.segment == NULL) return MK_EINVAL;
    
    struct load_command *mach_symtab = mk_macho_find_command(mk_segment_get_macho(link_edit), LC_SYMTAB, NULL);
    if (mach_symtab == NULL) {
        _mkl_error(mk_type_get_context(link_edit.segment), "No LC_SYMTAB command in %s", mk_macho_get_name(mk_segment_get_macho(link_edit)));
        return MK_ENOT_FOUND;
    }
    
    struct load_command *mach_dysymtab = mk_macho_find_command(mk_segment_get_macho(link_edit), LC_DYSYMTAB, NULL);
    
    return mk_symbol_table_init_with_mach_symtab(link_edit, (struct symtab_command*)mach_symtab, (struct dysymtab_command*)mach_dysymtab, symbol_table);
}

//|++++++++++++++++++++++++++++++++++++|//
mk_macho_ref mk_symbol_table_get_macho(mk_symbol_table_ref symbol_table)
{ return mk_segment_get_macho(symbol_table.symbol_table->link_edit); }

//|++++++++++++++++++++++++++++++++++++|//
mk_segment_ref mk_symbol_table_get_seg_link_edit(mk_symbol_table_ref symbol_table)
{ return symbol_table.symbol_table->link_edit; }

//|++++++++++++++++++++++++++++++++++++|//
mk_vm_range_t mk_symbol_table_get_range(mk_symbol_table_ref symbol_table)
{ return symbol_table.symbol_table->range; }

//|++++++++++++++++++++++++++++++++++++|//
uint32_t mk_symbol_table_get_count(mk_symbol_table_ref symbol_table)
{ return symbol_table.symbol_table->symbol_count; }

//|++++++++++++++++++++++++++++++++++++|//
mk_load_command_ref
mk_symbol_table_get_dysymtab_load_command(mk_symbol_table_ref symbol_table)
{
    mk_load_command_ref lc;
    lc.load_command = &symbol_table.symbol_table->dysymtab_cmd;
    return lc;
}

//----------------------------------------------------------------------------//
#pragma mark -  Looking Up Symbols
//----------------------------------------------------------------------------//

//|++++++++++++++++++++++++++++++++++++|//
mk_mach_nlist
mk_symbol_table_get_symbol_at_index(mk_symbol_table_ref symbol_table, uint32_t index, mk_vm_address_t* host_address)
{
    mk_mach_nlist symbol; symbol.any = NULL;
    mk_vm_offset_t sym_off;
    mk_vm_size_t sym_size;
    vm_address_t addr;
    
    if (index >= symbol_table.symbol_table->symbol_count)
        return symbol;
    
    if (mk_data_model_get_pointer_size(mk_macho_get_data_model(mk_symbol_table_get_macho(symbol_table))) == 8)
        sym_size = sizeof(struct nlist_64);
    else
        sym_size = sizeof(struct nlist);
    
    // Compute the offset of the symbol at index.
    sym_off = index * sym_size;
    
    addr = mk_memory_object_remap_address(mk_segment_get_mobj(symbol_table.symbol_table->link_edit), sym_off, symbol_table.symbol_table->range.location, sym_size, NULL);
    if (addr == UINTPTR_MAX)
        return symbol;
    
    mk_vm_address_apply_offset(symbol_table.symbol_table->range.location, sym_off, host_address);
    symbol.any = (void*)addr;
    return symbol;
}

//|++++++++++++++++++++++++++++++++++++|//
mk_mach_nlist
mk_symbol_table_next_mach_symbol(mk_symbol_table_ref symbol_table, const mk_mach_nlist previous, uint32_t* index, mk_vm_address_t* host_address)
{
    mk_mach_nlist symbol; symbol.any = NULL;
    mk_vm_offset_t sym_off;
    mk_vm_address_t sym_addr;
    mk_vm_size_t sym_size;
    uint32_t sym_index;
    
    sym_addr = mk_memory_object_unmap_address(mk_segment_get_mobj(symbol_table.symbol_table->link_edit), 0, (vm_address_t)previous.any, 1, NULL);
    if (sym_addr == MK_VM_ADDRESS_INVALID) {
        _mkl_error(mk_type_get_context(symbol_table.symbol_table), "Previous value %p is not within <mk_symbol_table %p>", previous.any, symbol_table.symbol_table);
        return symbol;
    }
    
    // Verify that previous is within the symbol table.
    if (mk_vm_range_contains_address(symbol_table.symbol_table->range, 0, sym_addr)) {
        _mkl_error(mk_type_get_context(symbol_table.symbol_table), "Previous value %p is not within <mk_symbol_table %p>", previous.any, symbol_table.symbol_table);
        return symbol;
    }
    
    if (mk_data_model_get_pointer_size(mk_macho_get_data_model(mk_symbol_table_get_macho(symbol_table))) == 8)
        sym_size = sizeof(struct nlist_64);
    else
        sym_size = sizeof(struct nlist);
    
    sym_off = sym_addr - symbol_table.symbol_table->range.location;
    sym_index = (uint32_t)(sym_off / sym_size);
    
    mk_mach_nlist retValue = mk_symbol_table_get_symbol_at_index(symbol_table, ++sym_index, host_address);
    if (retValue.any != NULL && index) *index = sym_index;
    return retValue;
}

//|++++++++++++++++++++++++++++++++++++|//
#if __BLOCKS__
void
mk_symbol_table_enumerate_mach_symbols(mk_symbol_table_ref symbol_table, uint32_t index, void (^enumerator)(const mk_mach_nlist symbol, uint32_t index, mk_vm_address_t host_address))
{
    mk_mach_nlist symbol;
    mk_vm_size_t sym_size;
    mk_vm_address_t sym_addr;
    mk_vm_size_t map_length;
    uint32_t sym_index;
    vm_address_t addr;
    
    if (mk_data_model_get_pointer_size(mk_macho_get_data_model(mk_symbol_table_get_macho(symbol_table))) == 8)
        sym_size = sizeof(struct nlist_64);
    else
        sym_size = sizeof(struct nlist);
    
    sym_index = index;
    if (sym_index >= symbol_table.symbol_table->symbol_count)
        return;
    if (mk_vm_address_add(symbol_table.symbol_table->range.location, sym_index * sym_size, &sym_addr))
        return;
    if (mk_vm_address_subtract(symbol_table.symbol_table->range.length, sym_index * sym_size, &map_length))
        return;
    addr = mk_memory_object_remap_address(mk_segment_get_mobj(symbol_table.symbol_table->link_edit), 0, sym_addr, map_length, NULL);
    if (addr == UINTPTR_MAX)
        return;
    
    do {
        symbol.any = (void*)addr;
        enumerator(symbol, sym_index, sym_addr);
        
        sym_index++;
        sym_addr += sym_size;
        addr  += sym_size;
    } while (sym_index < symbol_table.symbol_table->symbol_count);
}
#endif
