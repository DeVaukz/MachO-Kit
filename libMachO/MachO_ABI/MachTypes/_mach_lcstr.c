//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             _mach_lcstr.c
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

//|++++++++++++++++++++++++++++++++++++|//
size_t
_mk_mach_lc_str_copy_native(mk_load_command_ref source_load_command, union lc_str *src_lc_str, struct load_command *dest_lc, union lc_str *dest_lc_str, size_t dest_cmdsize)
{
    const mk_macho_ref image = source_load_command.load_command->image;
    
    size_t lc_base_size = mk_load_command_base_size(source_load_command);
    
    uintptr_t src_cmd = (uintptr_t)source_load_command.load_command->mach_load_command;
    uint32_t src_cmdsize = mk_load_command_size(source_load_command);
    
    if (src_cmdsize < lc_base_size) {
        _mkl_debug(mk_type_get_context(source_load_command.type), "Source load command size [%" PRIu32 "] is < source load command base size [%zd].", src_cmdsize, lc_base_size);
        return 0;
    }
    
    // Verify that 'src_lc_str' is within the load command
    if (mk_vm_range_contains_range(mk_vm_range_make(src_cmd, src_cmdsize), mk_vm_range_make((uintptr_t)src_lc_str, sizeof(*src_lc_str)), false) != MK_ESUCCESS) {
        char buffer[512] = { 0 };
        mk_load_command_copy_short_description(source_load_command, buffer, sizeof(buffer));
        _mkl_debug(mk_type_get_context(source_load_command.type), "Source load command string pointer [%p] is not within source load command %s.", src_lc_str, buffer);
        return 0;
    }
    
    uint32_t src_lc_str_offset = mk_macho_get_byte_order(image)->swap32( src_lc_str->offset );
    
    // Verify that 'src_lc_str_offset' is within the load command.
    if (src_lc_str_offset >= src_cmdsize) {
        char buffer[512] = { 0 };
        mk_load_command_copy_short_description(source_load_command, buffer, sizeof(buffer));
        _mkl_debug(mk_type_get_context(source_load_command.type), "Source load command string offset [%" PRIu32 "] is not within source load command %s.", src_lc_str_offset, buffer);
        return 0;
    }
    
    char * src_string = (char*)( src_cmd + src_lc_str_offset );
    size_t src_string_contents_max_len = src_cmdsize - src_lc_str_offset;
    size_t src_string_contents_len = strnlen(src_string, src_string_contents_max_len);
    
    // Verify that 'dest_str' is within the destination load command
    if (mk_vm_range_contains_range(mk_vm_range_make((uintptr_t)dest_lc, dest_cmdsize), mk_vm_range_make((uintptr_t)dest_lc_str, sizeof(*dest_lc_str)), false) != MK_ESUCCESS) {
        // This is not an error, but there is nothing to do.
        return 0;
    }
    
    uint32_t dest_lc_str_offset = src_lc_str_offset;
    
    // Verify that 'dst_string_offset' is within the destination load command.
    if (dest_lc_str_offset >= dest_cmdsize) {
        // This is also not an error, but there is nothing to do...
        // ...except set dest_str->offset.
        dest_lc_str->offset = dest_lc_str_offset;
        return 0;
    }
    
    char *dest_string = (char*)( (uintptr_t)dest_lc + dest_lc_str_offset );
    size_t dest_string_contents_max_len = dest_cmdsize - dest_lc_str_offset;
    
    size_t bytes_to_copy = MIN(src_string_contents_len, dest_string_contents_max_len);
    
    dest_lc_str->offset = dest_lc_str_offset;
    memcpy(dest_string, src_string, bytes_to_copy);
    if (src_string_contents_len < dest_string_contents_max_len)
        dest_string[src_string_contents_len] = '\0';
    
    return bytes_to_copy;
}

//|++++++++++++++++++++++++++++++++++++|//
size_t
_mk_mach_lc_str_copy(mk_load_command_ref load_command, union lc_str *lc_str, char *output, size_t output_len, bool include_terminator)
{
    const mk_macho_ref image = load_command.load_command->image;
    
    size_t lc_base_size = mk_load_command_base_size(load_command);
    
    uintptr_t cmd = (uintptr_t)load_command.load_command->mach_load_command;
    uint32_t cmdsize = mk_load_command_size(load_command);
    
    if (cmdsize < lc_base_size) {
        _mkl_debug(mk_type_get_context(load_command.type), "Load command size [%" PRIu32 "] is < load command base size [%zd].", cmdsize, lc_base_size);
        return 0;
    }
    
    // Verify that 'lc_str' is within the load command
    if (mk_vm_range_contains_range(mk_vm_range_make(cmd, cmdsize), mk_vm_range_make((uintptr_t)lc_str, sizeof(*lc_str)), false) != MK_ESUCCESS) {
        char buffer[512] = { 0 };
        mk_load_command_copy_short_description(load_command, buffer, sizeof(buffer));
        _mkl_debug(mk_type_get_context(load_command.type), "Load command string pointer [%p] is not within load command %s.", lc_str, buffer);
        return 0;
    }
    
    uint32_t lc_str_offset = mk_macho_get_byte_order(image)->swap32( lc_str->offset );
    
    // Verify that 'lc_str_offset' is within the load command.
    if (lc_str_offset >= cmdsize) {
        char buffer[512] = { 0 };
        mk_load_command_copy_short_description(load_command, buffer, sizeof(buffer));
        _mkl_debug(mk_type_get_context(load_command.type), "Load command string offset [%" PRIu32 "] is not within load command %s.", lc_str_offset, buffer);
        return 0;
    }
    
    // Verify that adding the 'string_offset' won't overflow.
    // TODO - Is this check necessary?
    if (UINTPTR_MAX - lc_str_offset < cmd) {
        _mkl_debug(mk_type_get_context(load_command.type), "Adding string offset [%" PRIu32 "] to load command pointer [0x%" PRIxPTR "] would overflow.", lc_str_offset, cmd);
        return 0;
    }
    
    char *string = (char*)( cmd + lc_str_offset );
    size_t string_contents_max_len = cmdsize - lc_str_offset;
    size_t string_contents_len = strnlen(string, string_contents_max_len);
    
    if (output && output_len > 0)
    {
        size_t bytes_to_copy = MIN(string_contents_len, include_terminator ? output_len - 1 : output_len);
        
        memcpy(output, string, bytes_to_copy);
        if (string_contents_len < output_len || include_terminator)
            output[bytes_to_copy] = '\0';
        
        return bytes_to_copy;
    }
    else
        return string_contents_len;
}
