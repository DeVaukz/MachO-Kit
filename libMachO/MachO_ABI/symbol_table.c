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
__mk_symbol_table_get_context(mk_symbol_table_ref self)
{ return mk_type_get_context( self.symbol_table->link_edit.type ); }

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
mk_symbol_table_init(mk_segment_ref segment, mk_load_command_ref symtab_load_command, mk_load_command_ref dysymtab_load_command, mk_symbol_table_t *symbol_table)
{
    if (symbol_table == NULL) return MK_EINVAL;
    if (segment.segment == NULL) return MK_EINVAL;
    if (symtab_load_command.load_command == NULL) return MK_EINVAL;
    
    if (mk_load_command_id(symtab_load_command) != mk_load_command_symtab_id()) {
        _mkl_debug(mk_type_get_context(segment.type), "Unsupported load command type [%s].", mk_type_name(symtab_load_command.type));
        return MK_EINVAL;
    }
    if (dysymtab_load_command.load_command && mk_load_command_id(dysymtab_load_command) != mk_load_command_dysymtab_id()) {
        _mkl_debug(mk_type_get_context(segment.type), "Unsupported load command type [%s].", mk_type_name(dysymtab_load_command.type));
        return MK_EINVAL;
    }
    
    mk_macho_ref image = mk_segment_get_macho(segment);
    
    if (!mk_type_equal(mk_load_command_get_macho(symtab_load_command).type, image.type)) {
        return MK_EINVAL;
    }
    if (dysymtab_load_command.load_command && !mk_type_equal(mk_load_command_get_macho(dysymtab_load_command).type, image.type)) {
        return MK_EINVAL;
    }
    
    uint32_t lc_symoff = mk_load_command_symtab_get_symoff(symtab_load_command);
    uint32_t lc_nsyms = mk_load_command_symtab_get_nsyms(symtab_load_command);
    
    // If lc_symoff is 0, there is no symbol table.
    if (lc_symoff == 0)
        return MK_ENOT_FOUND;
    
    // This already include the slide.
    mk_vm_address_t vm_address = mk_segment_get_target_range(segment).location;
    mk_vm_size_t vm_size;
    if (mk_macho_is_64_bit(image))
        vm_size = lc_nsyms * sizeof(struct nlist_64);
    else
        vm_size = lc_nsyms * sizeof(struct nlist);
    
    mk_error_t err;
    
    // Apply the offset.
    if ((err = mk_vm_address_apply_offset(vm_address, lc_symoff, &vm_address))) {
        _mkl_debug(mk_type_get_context(segment.type), "Arithmetic error [%s] applying symbol table offset [%" PRIu32 "] to LINKEDIT segment target address [0x%" MK_VM_PRIxADDR "].", mk_error_string(err), lc_symoff, vm_address);
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
    
    // Make sure the symbol table is completely within the link_edit segment
    if ((err = mk_vm_range_contains_range(mk_segment_get_target_range(segment), symbol_table->target_range, false))) {
        char buffer[512] = { 0 };
        mk_type_copy_description(segment.type, buffer, sizeof(buffer));
        _mkl_debug(mk_type_get_context(segment.type), "Part of symbol table (target_address = 0x%" MK_VM_PRIxADDR ", size = 0x%" MK_VM_PRIxSIZE ") is not within LINKEDIT segment %s.", symbol_table->target_range.location, symbol_table->target_range.length, buffer);
        return err;
    }
    
    mk_load_command_copy(symtab_load_command, &symbol_table->symtab_command);
    if (dysymtab_load_command.load_command)
        mk_load_command_copy(dysymtab_load_command, &symbol_table->dysymtab_command);
    
    symbol_table->vtable = &_mk_symbol_table_class;
    return MK_ESUCCESS;
}

//|++++++++++++++++++++++++++++++++++++|//
mk_error_t
mk_symbol_table_init_with_mach_load_commands(mk_segment_ref segment, struct symtab_command *symtab_lc, struct dysymtab_command *dysymtab_lc, mk_symbol_table_t *symbol_table)
{
    if (segment.segment == NULL) return MK_EINVAL;
    if (symtab_lc == NULL) return MK_EINVAL;
    
    mk_error_t err;
    mk_load_command_t symtab_load_command;
    mk_load_command_t dysymtab_load_command;
    
    if ((err = mk_load_command_init(mk_segment_get_macho(segment), (struct load_command*)symtab_lc, &symtab_load_command)))
        return err;
    
    if (dysymtab_lc && (err = mk_load_command_init(mk_segment_get_macho(segment), (struct load_command*)dysymtab_lc, &dysymtab_load_command)))
        return err;
    
    return mk_symbol_table_init(segment, &symtab_load_command, (dysymtab_lc ? &dysymtab_load_command : NULL), symbol_table);
}

//|++++++++++++++++++++++++++++++++++++|//
mk_error_t
mk_symbol_table_init_with_segment(mk_segment_ref segment, mk_symbol_table_t *symbol_table)
{
    if (segment.segment == NULL) return MK_EINVAL;
    
    mk_macho_ref image = mk_segment_get_macho(segment);
    // dyld uses the *last* LC_SYMTAB in the load commands list.
    struct symtab_command *symtab_lc = (typeof(symtab_lc))mk_macho_last_command_type(image, LC_SYMTAB, NULL);
    
    if (symtab_lc == NULL) {
        char buffer[512] = { 0 };
        mk_type_copy_description(image.type, buffer, sizeof(buffer));
        _mkl_debug(mk_type_get_context(segment.type), "LC_SYMTAB load command not found in Mach-O image %s.", buffer);
        return MK_ENOT_FOUND;
    }
    
    struct dysymtab_command *dysymtab_lc = (typeof(dysymtab_lc))mk_macho_find_command(image, LC_DYSYMTAB, NULL);
    
    return mk_symbol_table_init_with_mach_load_commands(segment, symtab_lc, dysymtab_lc, symbol_table);
}

//|++++++++++++++++++++++++++++++++++++|//
void
mk_symbol_table_free(mk_symbol_table_ref symbol_table)
{
    symbol_table.symbol_table->vtable = NULL;
}

//|++++++++++++++++++++++++++++++++++++|//
mk_macho_ref mk_symbol_table_get_macho(mk_symbol_table_ref symbol_table)
{ return mk_segment_get_macho(symbol_table.symbol_table->link_edit); }

//|++++++++++++++++++++++++++++++++++++|//
mk_segment_ref mk_symbol_table_get_segment(mk_symbol_table_ref symbol_table)
{ return symbol_table.symbol_table->link_edit; }

//|++++++++++++++++++++++++++++++++++++|//
mk_vm_range_t mk_symbol_table_get_target_range(mk_symbol_table_ref symbol_table)
{ return symbol_table.symbol_table->target_range; }

//|++++++++++++++++++++++++++++++++++++|//
mk_load_command_ref
mk_symbol_table_get_symtab_load_command(mk_symbol_table_ref symbol_table)
{ return (mk_load_command_ref)&symbol_table.symbol_table->symtab_command; }

//|++++++++++++++++++++++++++++++++++++|//
mk_load_command_ref
mk_symbol_table_get_dysymtab_load_command(mk_symbol_table_ref symbol_table)
{ return (mk_load_command_ref)&symbol_table.symbol_table->dysymtab_command; }

//----------------------------------------------------------------------------//
#pragma mark -  Looking Up Symbols
//----------------------------------------------------------------------------//

//|++++++++++++++++++++++++++++++++++++|//
uint32_t mk_symbol_table_get_symbol_count(mk_symbol_table_ref symbol_table)
{ return mk_load_command_symtab_get_nsyms(&symbol_table.symbol_table->symtab_command); }

//|++++++++++++++++++++++++++++++++++++|//
mk_macho_nlist_ptr
mk_symbol_table_get_mach_symbol_at_index(mk_symbol_table_ref symbol_table, uint32_t index, mk_vm_address_t* target_address)
{
    mk_vm_address_t addr;
    size_t size;
    
    // Determine the length of the nlist entry.
    if (mk_macho_is_64_bit(mk_symbol_table_get_macho(symbol_table)))
        size = sizeof(struct nlist_64);
    else
        size = sizeof(struct nlist);
    
    if (index >= mk_symbol_table_get_symbol_count(symbol_table))
        return (mk_macho_nlist_ptr)NULL;
    
    if (mk_vm_address_apply_offset(symbol_table.symbol_table->target_range.location, index * size, &addr) != MK_ESUCCESS)
        return (mk_macho_nlist_ptr)NULL;
    
    uintptr_t symbol = mk_memory_object_remap_address(mk_segment_get_mapping(symbol_table.symbol_table->link_edit), 0, addr, size, NULL);
    if (symbol == UINTPTR_MAX)
        return (mk_macho_nlist_ptr)NULL;
    
    if (target_address) *target_address = addr;
    return (mk_macho_nlist_ptr)(void*)symbol;
}

//|++++++++++++++++++++++++++++++++++++|//
mk_macho_nlist_ptr
mk_symbol_table_next_mach_symbol(mk_symbol_table_ref symbol_table, const mk_macho_nlist_ptr previous, uint32_t* index, mk_vm_address_t* target_address)
{
    if (previous.any == NULL) {
        mk_macho_nlist_ptr retValue = mk_symbol_table_get_mach_symbol_at_index(symbol_table, 0, target_address);
        if (retValue.any != NULL && index) *index = 0;
        return retValue;
    }
    
    mk_memory_object_ref mapping = mk_segment_get_mapping(symbol_table.symbol_table->link_edit);
    
    mk_vm_address_t addr;
    size_t size;
    
    if (mk_macho_is_64_bit(mk_symbol_table_get_macho(symbol_table)))
        size = sizeof(struct nlist_64);
    else
        size = sizeof(struct nlist);
    
    addr = mk_memory_object_unmap_address(mapping, 0, (uintptr_t)previous.any, 1, NULL);
    if (addr == MK_VM_ADDRESS_INVALID) {
        char buffer[512] = { 0 };
        mk_type_copy_description(mapping.memory_object, buffer, sizeof(buffer));
        _mkl_debug(mk_type_get_context(symbol_table.type), "Previous Mach-O symbol pointer [%p] is not within LINKEDIT %s.", previous.any, buffer);
        return (mk_macho_nlist_ptr)NULL;
    }
    
    // Verify that addr is within the symbol table.
    if (mk_vm_range_contains_address(symbol_table.symbol_table->target_range, 0, addr) != MK_ESUCCESS) {
        char buffer[512] = { 0 };
        mk_type_copy_description(symbol_table.type, buffer, sizeof(buffer));
        _mkl_debug(mk_type_get_context(symbol_table.type), "Previous Mach-O symbol pointer [%p] is not within symbol table %s.", previous.any, buffer);
        return (mk_macho_nlist_ptr)NULL;
    }
    
    mk_vm_offset_t offst = addr - symbol_table.symbol_table->target_range.location;
    uint32_t idx = (uint32_t)(offst / size);
    
    mk_macho_nlist_ptr retValue = mk_symbol_table_get_mach_symbol_at_index(symbol_table, ++idx, target_address);
    if (retValue.any != NULL && index) *index = idx;
    return retValue;
}

//|++++++++++++++++++++++++++++++++++++|//
#if __BLOCKS__
void
mk_symbol_table_enumerate_mach_symbols(mk_symbol_table_ref symbol_table, uint32_t index, void (^enumerator)(const mk_macho_nlist_ptr symbol, uint32_t index, mk_vm_address_t target_address))
{
    mk_memory_object_ref mapping = mk_segment_get_mapping(symbol_table.symbol_table->link_edit);
    
    mk_vm_address_t target_address;
    mk_vm_size_t max_length;
    size_t size;
    
    if (mk_macho_is_64_bit(mk_symbol_table_get_macho(symbol_table)))
        size = sizeof(struct nlist_64);
    else
        size = sizeof(struct nlist);
    
    if (index >= mk_symbol_table_get_symbol_count(symbol_table))
        return;
    
    if (mk_vm_address_add(symbol_table.symbol_table->target_range.location, index * size, &target_address))
        return;
    
    // Determine the remaining length of the symbol table that will be iterated.
    if (mk_vm_address_subtract(symbol_table.symbol_table->target_range.length, index * size, &max_length))
        return;
    
    uintptr_t symbol = mk_memory_object_remap_address(mapping, 0, target_address, max_length, NULL);
    if (symbol == UINTPTR_MAX)
        return;
    
    do {
        enumerator((mk_macho_nlist_ptr)(void*)symbol, index, target_address);
        
        index++;
        symbol += size;
        target_address += size;
    } while (index < mk_symbol_table_get_symbol_count(symbol_table));
}
#endif
