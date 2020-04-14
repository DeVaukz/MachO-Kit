//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             export.c
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
__mk_export_get_context(mk_export_ref self)
{ return mk_type_get_context( self.export->exports_trie.type ); }

const struct _mk_export_vtable _mk_export_class = {
    .base.super                 = &_mk_type_class,
    .base.name                  = "export",
    .base.get_context           = &__mk_export_get_context
};

intptr_t mk_export_type = (intptr_t)&_mk_export_class;

//----------------------------------------------------------------------------//
#pragma mark -  Working With Exports
//----------------------------------------------------------------------------//

//|++++++++++++++++++++++++++++++++++++|//
mk_error_t
mk_export_init(mk_exports_trie_ref exports_trie, mk_macho_export_node_ptr node, mk_export_t* export)
{
    if (exports_trie.exports_trie == NULL) return MK_EINVAL;
    if (node == NULL) return MK_EINVAL;
    if (export == NULL) return MK_EINVAL;
    
    mk_memory_object_ref mobj = mk_segment_get_mapping(mk_exports_trie_get_segment(exports_trie));
    
    mk_vm_address_t terminal_address;
    uint64_t terminal_size;
    size_t terminal_size_uleb_size;
    
    // Read the terminal size
    {
        // First, verify we can safely read a single byte
        if (!mk_memory_object_verify_local_pointer(mobj, 0, (vm_address_t)node, 1, NULL)) {
            _mkl_debug(mk_type_get_context(exports_trie.exports_trie), "node is not within exports_trie.");
            return MK_EINVAL;
        }
        
        terminal_size = *(const uint8_t *)node;
        terminal_size_uleb_size = sizeof(uint8_t);
        
        // If the size is greater than 127, the size value is a uleb.
        if (terminal_size > 127) {
            mk_error_t error = MK_EOUT_OF_RANGE;
            
            // Keep trying to read a ULEB with an increaing number of bytes
            // until we succeed or hit an error other than MK_EOUT_OF_RANGE.
            // For safety, give up if the size exceeds sizeof(uint64_t) bytes
            for (vm_size_t s = 2; s <= sizeof(uint64_t); s++) {
                // Verify we can safely read the bytes
                if (!mk_memory_object_verify_local_pointer(mobj, 0, (vm_address_t)node, s, NULL)) {
                    _mkl_debug(mk_type_get_context(exports_trie.exports_trie), "node is not fully within exports_trie.");
                    return MK_EINVAL;
                }
                
                // Try to read the ULEB
                const uint8_t *start = node;
                const uint8_t *end = node + s;
                mk_error_t err = _mk_mach_trie_copy_uleb128(start, end, &terminal_size, &terminal_size_uleb_size);
                
                if (err == MK_ESUCCESS) {
                    error = MK_ESUCCESS;
                    break;
                }
                
                if (err == MK_EOUT_OF_RANGE) {
                    // Need to read more bytes to parse the ULEB
                    continue;
                }
                
                // Failed to parse ULEB
                error = err;
                break;
            }
            
            if (error != MK_ESUCCESS) {
                _mkl_debug(mk_type_get_context(exports_trie.exports_trie), "invalid 'terminal size' uleb128 (err = %s).", mk_error_string(error));
                return MK_EINVALID_DATA;
            }
        }
        
        if (terminal_size == 0) {
            _mkl_debug(mk_type_get_context(exports_trie.exports_trie), "node is not a terminal node.");
            return MK_EINVAL;
        }
    }
    
    terminal_address = mk_memory_object_unmap_address(mobj, terminal_size_uleb_size, (vm_address_t)node, terminal_size, NULL);
    if (terminal_address == MK_VM_ADDRESS_INVALID) {
        _mkl_debug(mk_type_get_context(exports_trie.exports_trie), "node is not within exports_trie.");
        return MK_EINVAL;
    }
    
    if (mk_vm_range_contains_range(mk_exports_trie_get_target_range(exports_trie), mk_vm_range_make(terminal_address, terminal_size), false)) {
        _mkl_debug(mk_type_get_context(exports_trie.exports_trie), "node is not fully within exports_trie.");
        return MK_EINVAL;
    }
    
    export->vtable = &_mk_export_class;
    export->exports_trie = exports_trie;
    // SAFE - unmap verified this would not overflow
    export->terminal_data = (const uint8_t*)node + terminal_size_uleb_size;
    export->terminal_data_size = terminal_size;
    
    return MK_ESUCCESS;
}

//|++++++++++++++++++++++++++++++++++++|//
mk_macho_ref mk_export_get_macho(mk_export_ref export)
{ return mk_exports_trie_get_macho(export.export->exports_trie); }

//|++++++++++++++++++++++++++++++++++++|//
mk_exports_trie_ref mk_export_get_exports_trie(mk_export_ref export)
{ return export.export->exports_trie; }

//----------------------------------------------------------------------------//
#pragma mark -  Export Values
//----------------------------------------------------------------------------//

//|++++++++++++++++++++++++++++++++++++|//
mk_error_t
mk_export_get_info(mk_export_ref export, uint64_t* flags,
                   uint64_t* offset,
                   uint64_t* ordinal, const char** imported_name,
                   uint64_t* resolver_offset)
{
    const uint8_t *addr = export.export->terminal_data;
    const uint8_t *end = addr + export.export->terminal_data_size;
    
    mk_error_t err;
    
    uint64_t flags_val;
    size_t flags_len;
    
    uint64_t offset_val;
    size_t offset_len;
    
    // Read flags
    if ((err = _mk_mach_trie_copy_uleb128(addr, end, &flags_val, &flags_len)))
        return err;
    
    addr += flags_len;
    
    if (flags) *flags = flags_val;
    
    // Read the offset
    if ((err = _mk_mach_trie_copy_uleb128(addr, end, &offset_val, &offset_len)))
        return err;
    
    addr += offset_len;
    
    if (flags_val & EXPORT_SYMBOL_FLAGS_REEXPORT) {
        // For REEXPORT, offset is the ordinal of the source library
        if (ordinal) *ordinal = offset_val;
        
        // See if there is an imported name
        if (addr >= end)
            return MK_EOUT_OF_RANGE;
        
        if (*(const char*)addr != '\0') {
            // TODO - Ensure the entire string is in bounds
            if (imported_name) *imported_name = (const char*)addr;
        }
        
    } else {
        if (offset) *offset = offset_val;
        
        if ((flags_val & EXPORT_SYMBOL_FLAGS_KIND_MASK) == EXPORT_SYMBOL_FLAGS_KIND_REGULAR) {
            if (flags_val & EXPORT_SYMBOL_FLAGS_STUB_AND_RESOLVER) {
                // Read the resolver offset
                if ((err = _mk_mach_trie_copy_uleb128(addr, end, resolver_offset, NULL)))
                    return err;
            }
        }
    }
    
    return MK_ESUCCESS;
}
