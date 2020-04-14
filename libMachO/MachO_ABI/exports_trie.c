//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             exports_trie.c
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
__mk_exports_trie_get_context(mk_exports_trie_ref self)
{ return mk_type_get_context( self.exports_trie->link_edit.type ); }

const struct _mk_exports_trie_vtable _mk_exports_trie_class = {
    .base.super                 = &_mk_type_class,
    .base.name                  = "exports trie",
    .base.get_context           = &__mk_exports_trie_get_context
};

intptr_t mk_exports_trie_type = (intptr_t)&_mk_exports_trie_class;

//----------------------------------------------------------------------------//
#pragma mark -  Working With The Exports Trie
//----------------------------------------------------------------------------//

//|++++++++++++++++++++++++++++++++++++|//
mk_error_t
mk_exports_trie_init(mk_segment_ref link_edit_segment, mk_load_command_ref load_command, mk_exports_trie_t *exports_trie)
{
    if (exports_trie == NULL) return MK_EINVAL;
    if (link_edit_segment.segment == NULL) return MK_EINVAL;
    if (load_command.load_command == NULL) return MK_EINVAL;
    
    uint32_t lc_trieoff;
    uint32_t lc_triesize;
    
    if (mk_load_command_id(load_command) == mk_load_command_dyld_exports_trie_id()) {
        lc_trieoff = mk_load_command_dyld_exports_trie_get_dataoff(load_command);
        lc_triesize = mk_load_command_dyld_exports_trie_get_datasize(load_command);
    } else if (mk_load_command_id(load_command) == mk_load_command_dyld_info_id()) {
        lc_trieoff = mk_load_command_dyld_info_get_export_off(load_command);
        lc_triesize = mk_load_command_dyld_info_get_export_size(load_command);
    } else if (mk_load_command_id(load_command) == mk_load_command_dyld_info_only_id()) {
        lc_trieoff = mk_load_command_dyld_info_only_get_export_off(load_command);
        lc_triesize = mk_load_command_dyld_info_only_get_export_size(load_command);
    } else {
        _mkl_debug(mk_type_get_context(link_edit_segment.type), "Unsupported load command type [%s].", mk_type_name(load_command.type));
        return MK_EINVAL;
    }
    
    if (!mk_type_equal(mk_load_command_get_macho(load_command).type, mk_segment_get_macho(link_edit_segment).type)) {
        return MK_EINVAL;
    }
    
    // If lc_triesize is 0, there is no exports trie.
    if (lc_triesize == 0)
        return MK_ENOT_FOUND;
    
    // This already includes the slide.
    mk_vm_address_t vm_address = mk_segment_get_target_range(link_edit_segment).location;
    mk_vm_size_t vm_size = lc_triesize;
    
    mk_error_t err;
    
    // Apply the offset.
    if ((err = mk_vm_address_apply_offset(vm_address, lc_trieoff, &vm_address))) {
        _mkl_debug(mk_type_get_context(link_edit_segment.type), "Arithmetic error [%s] applying exports trie offset [%" PRIu32 "] to LINKEDIT segment target address [0x%" MK_VM_PRIxADDR "].", mk_error_string(err), lc_trieoff, vm_address);
        return err;
    }
    
    // For some reason we need to subtract the fileOffset of the __LINKEDIT
    // segment.
    if ((err = mk_vm_address_subtract(vm_address, mk_segment_get_fileoff(link_edit_segment), &vm_address))) {
        _mkl_debug(mk_type_get_context(link_edit_segment.type), "Arithmetic error [%s] subtracting LINKEDIT segment file offset [0x%" MK_VM_PRIxADDR "] from exports trie target address [0x%" MK_VM_PRIxADDR "].", mk_error_string(err), mk_segment_get_fileoff(link_edit_segment), vm_address);
        return err;
    }
    
    exports_trie->link_edit = link_edit_segment;
    exports_trie->target_range = mk_vm_range_make(vm_address, vm_size);
    
    // Make sure the expoirts trie is completely within the link_edit segment
    if ((err = mk_vm_range_contains_range(mk_segment_get_target_range(link_edit_segment), exports_trie->target_range, false))) {
        char buffer[512] = { 0 };
        mk_type_copy_description(link_edit_segment.type, buffer, sizeof(buffer));
        _mkl_debug(mk_type_get_context(link_edit_segment.type), "Part of exports trie (target_address = 0x%" MK_VM_PRIxADDR ", size = 0x%" MK_VM_PRIxSIZE ") is not within LINKEDIT segment %s.", exports_trie->target_range.location, exports_trie->target_range.length, buffer);
        return err;
    }
    
    exports_trie->vtable = &_mk_exports_trie_class;
    return MK_ESUCCESS;
}

//|++++++++++++++++++++++++++++++++++++|//
mk_error_t
mk_exports_trie_init_with_mach_load_command(mk_segment_ref link_edit_segment, struct load_command *lc, mk_exports_trie_t *exports_trie)
{
    if (link_edit_segment.segment == NULL) return MK_EINVAL;
    if (lc == NULL) return MK_EINVAL;
    
    mk_error_t err;
    mk_load_command_t load_command;
    
    if ((err = mk_load_command_init(mk_segment_get_macho(link_edit_segment), lc, &load_command)))
        return err;
    
    return mk_exports_trie_init(link_edit_segment, &load_command, exports_trie);
}

//|++++++++++++++++++++++++++++++++++++|//
mk_error_t
mk_exports_trie_init_with_segment(mk_segment_ref link_edit_segment, mk_exports_trie_t *exports_trie)
{
    if (link_edit_segment.segment == NULL) return MK_EINVAL;
    
    mk_macho_ref image = mk_segment_get_macho(link_edit_segment);
    // dyld uses the *last* load commands list.
    struct load_command *lc_exports_trie = mk_macho_last_command_type(image, LC_DYLD_EXPORTS_TRIE, NULL);
    struct load_command *lc_dyld_info = mk_macho_last_command_type(image, LC_DYLD_INFO, NULL);
    struct load_command *lc_dyld_info_only = mk_macho_last_command_type(image, LC_DYLD_INFO_ONLY, NULL);
    
    // dyld prefers LC_DYLD_EXPORTS_TRIE if it is present
    struct load_command *lc = lc_exports_trie ?: (lc_dyld_info ?: lc_dyld_info_only);
    
    if (lc == NULL) {
        char buffer[512] = { 0 };
        mk_type_copy_description(image.type, buffer, sizeof(buffer));
        _mkl_debug(mk_type_get_context(link_edit_segment.type), "LC_DYLD_EXPORTS_TRIE or LC_DYLD_INFO_{ONLY} load commands not found in Mach-O image %s.", buffer);
        return MK_ENOT_FOUND;
    }
    
    return mk_exports_trie_init_with_mach_load_command(link_edit_segment, lc, exports_trie);
}

//|++++++++++++++++++++++++++++++++++++|//
void
mk_exports_trie_free(mk_exports_trie_ref exports_trie)
{
    exports_trie.exports_trie->vtable = NULL;
}

//|++++++++++++++++++++++++++++++++++++|//
mk_macho_ref
mk_exports_trie_get_macho(mk_exports_trie_ref exports_trie)
{ return mk_segment_get_macho(exports_trie.exports_trie->link_edit); }

//|++++++++++++++++++++++++++++++++++++|//
mk_segment_ref
mk_exports_trie_get_segment(mk_exports_trie_ref exports_trie)
{ return exports_trie.exports_trie->link_edit; }

//|++++++++++++++++++++++++++++++++++++|//
mk_vm_range_t
mk_exports_trie_get_target_range(mk_exports_trie_ref exports_trie)
{ return exports_trie.exports_trie->target_range; }

//----------------------------------------------------------------------------//
#pragma mark -  Walking The Exports Trie
//----------------------------------------------------------------------------//

//|++++++++++++++++++++++++++++++++++++|//
mk_error_t
mk_exports_trie_get_terminal_node_for_symbol(mk_exports_trie_ref exports_trie, const char *symbol, mk_vm_address_t* target_address, mk_macho_export_node_ptr *result)
{
    mk_memory_object_ref mobj = mk_segment_get_mapping(exports_trie.exports_trie->link_edit);
    
    mk_vm_range_t target_range = exports_trie.exports_trie->target_range;
    mk_vm_offset_t current_offset = 0;
    
    while (current_offset < mk_vm_range_length(target_range)) {
        mk_error_t err;
        
        mk_vm_address_t target_addr = mk_vm_range_start(target_range);
        mk_vm_size_t target_size = mk_vm_range_length(target_range);
        
        if ((err = mk_vm_size_subtract_offset(target_size, current_offset, &target_size))) {
            _mkl_debug(mk_type_get_context(exports_trie.type), "Error [%s] subtracting current offset [0x%" MK_VM_PRIuOFFSET "] from export trie size [%" MK_VM_PRIxSIZE "].  Offset is not within exports trie.", mk_error_string(err), current_offset, target_size);
            return err;
        }
        
        // Map the exports trie into the current process
        vm_address_t addr = mk_memory_object_remap_address(mobj, current_offset, target_addr, target_size, &err);
        // SAFE - Remap verified this would not overflow
        vm_address_t end = addr + (vm_size_t)target_size;
        if (addr == UINTPTR_MAX) {
            // This should not happen, initialization of exports_trie would have
            // failed.
            return err;
        }
        target_addr += current_offset;
        
        // Save the starting address, for logging.
        mk_vm_address_t node_target_addr = target_addr;
        
        uint64_t terminalSize;
        size_t terminalSizeULEBSize;
        
        // Read the terminal size
        if ((err = _mk_mach_trie_copy_uleb128((uint8_t*)addr, (uint8_t*)end, &terminalSize, &terminalSizeULEBSize))) {
            _mkl_debug(mk_type_get_context(exports_trie.type), "Invalid 'terminal size' uleb128 (err = %s) for node starting at target address [0x%" MK_VM_PRIxADDR "] in exports trie.", mk_error_string(err), node_target_addr);
            return err;
        }
        
        if (*symbol == '\0' && terminalSize != 0) {
            // Found it
            if (target_address) *target_address = target_addr;
            if (result) *result = (mk_macho_export_node_ptr)addr;
            return MK_ESUCCESS;
        }
        
        // Advance past the terminal size ULEB
        if ((err = mk_vm_range_contains_address(target_range, terminalSizeULEBSize, target_addr))) {
            _mkl_debug(mk_type_get_context(exports_trie.type), "Error [%s] adding 'terminal size' uleb128 size [%zd] to current target address pointer [0x%" MK_VM_PRIxADDR "] for node starting at target address [0x%" MK_VM_PRIxADDR "].  New target address pointer is not within exports trie.", mk_error_string(err), terminalSizeULEBSize, target_addr, node_target_addr);
            return err;
        }
        target_addr += terminalSizeULEBSize;
        addr += terminalSizeULEBSize;
        
        // Advance to the child count
        if ((err = mk_vm_range_contains_address(target_range, terminalSize, target_addr))) {
            _mkl_debug(mk_type_get_context(exports_trie.type), "Error [%s] adding 'terminal size' [%" PRIu64 "] to current target address pointer [0x%" MK_VM_PRIxADDR "] for node starting at target address [0x%" MK_VM_PRIxADDR "].  New target address pointer is not within exports trie.", mk_error_string(err), terminalSize, target_addr, node_target_addr);
            return err;
        }
        target_addr += terminalSize;
        addr += terminalSize;
        
        // Read the child count
        uint8_t childCount = *(const uint8_t*)addr;
        
        // Advance past the child count byte
        if ((err = mk_vm_range_contains_address(target_range, sizeof(uint8_t), target_addr))) {
            _mkl_debug(mk_type_get_context(exports_trie.type), "Error [%s] adding 'child count' byte size [%zd] to current target address pointer [0x%" MK_VM_PRIxADDR "] for node starting at target address [0x%" MK_VM_PRIxADDR "].  New target address pointer is not within exports trie.", mk_error_string(err), sizeof(uint8_t), target_addr, node_target_addr);
            return err;
        }
        target_addr += sizeof(uint8_t);
        addr += sizeof(uint8_t);
        
        uint64_t branchOffset = 0;
        size_t branchOffsetULBESize;
        
        for (; childCount > 0; childCount--) {
            const char *s = symbol;
            bool wrongEdge = false;
            
            char *c = (char*)addr;
            char *c_end = (char*)end;
            size_t c_off = 0;
            while (&c[c_off] != c_end && c[c_off] != '\0') {
                if (!wrongEdge) {
                    if (c[c_off] != *s)
                        wrongEdge = true;
                    s++;
                }
                c_off++;
            }
            
            // Advance past the child branch label
            if ((err = mk_vm_range_contains_address(target_range, c_off, target_addr))) {
                _mkl_debug(mk_type_get_context(exports_trie.type), "Error [%s] adding 'child branch label' length [%zd] to current target address pointer [0x%" MK_VM_PRIxADDR "] for node starting at target address [0x%" MK_VM_PRIxADDR "].  New target address pointer is not within exports trie.", mk_error_string(err), c_off, target_addr, node_target_addr);
                return err;
            }
            target_addr += c_off;
            addr += c_off;
            
            // Advance past the NULL terminator
            if ((err = mk_vm_range_contains_address(target_range, 1, target_addr))) {
                _mkl_debug(mk_type_get_context(exports_trie.type), "Error [%s] adding 'child branch label' terminator length [%d] to current target address pointer [0x%" MK_VM_PRIxADDR "] for node starting at target address [0x%" MK_VM_PRIxADDR "].  New target address pointer is not within exports trie.", mk_error_string(err), 1, target_addr, node_target_addr);
                return err;
            }
            target_addr += 1;
            addr += 1;
            
            // Read the offset ULEB
            if ((err = _mk_mach_trie_copy_uleb128((uint8_t*)addr, (uint8_t*)end, &branchOffset, &branchOffsetULBESize))) {
                _mkl_debug(mk_type_get_context(exports_trie.type), "Invalid 'child branch offset' uleb128 (err = %s) for node at target address [0x%" MK_VM_PRIxADDR "] in exports trie.", mk_error_string(err), node_target_addr);
                return err;
            }
            
            if (wrongEdge) {
                // Advance past the offset ULEB to the next child
                if ((err = mk_vm_range_contains_address(target_range, branchOffsetULBESize, target_addr))) {
                    _mkl_debug(mk_type_get_context(exports_trie.type), "Error [%s] adding 'child branch offset' uleb128 size [%zd] to current target address pointer [0x%" MK_VM_PRIxADDR "] for node starting at target address [0x%" MK_VM_PRIxADDR "].  New target address pointer is not within exports trie.", mk_error_string(err), branchOffsetULBESize, target_addr, node_target_addr);
                    return err;
                }
                target_addr += branchOffsetULBESize;
                addr += branchOffsetULBESize;
                
                branchOffset = 0;
            } else {
                // Symbol matches so far.  Advance to the child's node.
                symbol = s;
                break;
            }
        }
        
        if (branchOffset != 0) {
            // Set branch offset as the current offset and loop again
            current_offset = branchOffset;
        } else {
            // Did not find a child branch to continue with.  Symbol does
            // not exist in the trie
            break;
        }
    }
    
    return MK_ENOT_FOUND;
}
