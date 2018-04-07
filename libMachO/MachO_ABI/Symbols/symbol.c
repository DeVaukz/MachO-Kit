//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             symbol.c
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
__mk_symbol_get_context(mk_symbol_ref self)
{ return mk_type_get_context( self.symbol->symbol_table.type ); }

const struct _mk_symbol_vtable _mk_symbol_class = {
    .base.super                 = &_mk_type_class,
    .base.name                  = "symbol",
    .base.get_context           = &__mk_symbol_get_context
};

intptr_t mk_symbol_type = (intptr_t)&_mk_symbol_class;

//----------------------------------------------------------------------------//
#pragma mark -  Working With Symbols
//----------------------------------------------------------------------------//

//|++++++++++++++++++++++++++++++++++++|//
mk_error_t
mk_symbol_init(mk_symbol_table_ref symbol_table, mk_macho_nlist_ptr nlist, mk_symbol_t* symbol)
{
    if (symbol_table.symbol_table == NULL) return MK_EINVAL;
    if (nlist.any == NULL) return MK_EINVAL;
    if (symbol == NULL) return MK_EINVAL;
    
    mk_memory_object_ref mapping = mk_segment_get_mapping(mk_symbol_table_get_segment(symbol_table));
    
    mk_vm_address_t nlist_address;
    vm_size_t nlist_size;
    
    if (mk_macho_is_64_bit(mk_symbol_table_get_macho(symbol_table)))
        nlist_size = sizeof(struct nlist_64);
    else
        nlist_size = sizeof(struct nlist);
    
    nlist_address = mk_memory_object_unmap_address(mapping, 0, (vm_address_t)nlist.any, nlist_size, NULL);
    if (nlist_address == MK_VM_ADDRESS_INVALID) {
        _mkl_error(mk_type_get_context(symbol_table.symbol_table), "nlist is not within symbol_table.");
        return MK_EINVAL;
    }
    
    if (mk_vm_range_contains_range(mk_symbol_table_get_target_range(symbol_table), mk_vm_range_make(nlist_address, nlist_size), false)) {
        _mkl_error(mk_type_get_context(symbol_table.symbol_table), "nlist is not within symbol_table.");
        return MK_EINVAL;
    }
    
    symbol->vtable = &_mk_symbol_class;
    symbol->symbol_table = symbol_table;
    symbol->nlist = nlist;
    
    return MK_ESUCCESS;
}

//|++++++++++++++++++++++++++++++++++++|//
mk_macho_ref mk_symbol_get_macho(mk_symbol_ref symbol)
{ return mk_symbol_table_get_macho(symbol.symbol->symbol_table); }

//|++++++++++++++++++++++++++++++++++++|//
mk_symbol_table_ref mk_symbol_get_symbol_table(mk_symbol_ref symbol)
{ return symbol.symbol->symbol_table; }

//|++++++++++++++++++++++++++++++++++++|//
mk_vm_range_t
mk_symbol_get_target_range(mk_symbol_ref symbol)
{
    mk_memory_object_ref mapping = mk_segment_get_mapping(mk_symbol_table_get_segment(symbol.symbol->symbol_table));
    
    size_t size;
    if (mk_macho_is_64_bit(mk_symbol_get_macho(symbol)))
        size = sizeof(struct nlist_64);
    else
        size = sizeof(struct nlist);
    
    mk_vm_address_t addr = mk_memory_object_unmap_address(mapping, 0, (uintptr_t)symbol.symbol->nlist.any, size, NULL);
    
    return mk_vm_range_make(addr, size);
}

//----------------------------------------------------------------------------//
#pragma mark -  Symbol Values
//----------------------------------------------------------------------------//

//|++++++++++++++++++++++++++++++++++++|//
uint32_t mk_symbol_get_strx(mk_symbol_ref symbol)
{ return mk_macho_get_byte_order(mk_symbol_get_macho(symbol))->swap32( symbol.symbol->nlist.nlist->n_un.n_strx ); }

//|++++++++++++++++++++++++++++++++++++|//
uint8_t mk_symbol_get_type(mk_symbol_ref symbol)
{ return symbol.symbol->nlist.nlist->n_type; }

//|++++++++++++++++++++++++++++++++++++|//
uint8_t mk_symbol_get_sect(mk_symbol_ref symbol)
{ return symbol.symbol->nlist.nlist->n_sect; }

//|++++++++++++++++++++++++++++++++++++|//
int16_t mk_symbol_get_desc(mk_symbol_ref symbol)
{ return (int16_t)mk_macho_get_byte_order(mk_symbol_get_macho(symbol))->swap16( (uint16_t)symbol.symbol->nlist.nlist->n_desc ); }

//|++++++++++++++++++++++++++++++++++++|//
uint64_t
mk_symbol_get_value(mk_symbol_ref symbol)
{
    mk_macho_ref image = mk_symbol_get_macho(symbol);
    mk_data_model_ref data_model = mk_macho_get_data_model(image);
    
    if (mk_macho_is_64_bit(image))
        return mk_data_model_get_byte_order(data_model)->swap64( symbol.symbol->nlist.nlist_64->n_value );
    else
        return mk_data_model_get_byte_order(data_model)->swap32( symbol.symbol->nlist.nlist->n_value );
}
