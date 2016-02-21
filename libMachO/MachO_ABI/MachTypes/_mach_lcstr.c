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
_mk_mach_lc_str_copy_native(mk_load_command_ref source_lc, union lc_str *source_str, struct load_command *dest_lc, union lc_str *dest_str, size_t dest_cmd_size)
{
    const struct load_command *src_lc = source_lc.load_command->mach_load_command;
    const mk_macho_ref image = source_lc.load_command->image;
    size_t lc_base_size = mk_load_command_base_size(source_lc);
    
    size_t src_cmd_size = mk_macho_get_byte_order(image)->swap32( src_lc->cmdsize );
    mk_vm_range_t src_cmd_range = mk_vm_range_make((mk_vm_address_t)src_lc, src_cmd_size);
    
    if (lc_base_size > src_cmd_size) {
        _mkl_error(mk_type_get_context(image.macho), "Input lc_base_size is > source_lc->cmdsize.");
        return 0;
    }
    
    size_t src_string_contents_len = src_cmd_size - lc_base_size;
    uint32_t src_string_offset = mk_macho_get_byte_order(image)->swap32( source_str->offset );
    char * src_string = (char*)( (uint8_t*)src_lc + src_string_offset );
    
    if (mk_vm_range_contains_range(src_cmd_range, mk_vm_range_make((mk_vm_address_t)src_string, src_string_contents_len), false) == false)
    {
        // We can't handle this case in copy_native.  What would we assign to
        // dest_str->offset?
        _mkl_error(mk_type_get_context(image.macho), "source_str is not within source_lc.");
        return 0;
    }
    
    // Get the actual length of the source string.
    src_string_contents_len = strnlen(src_string, src_string_contents_len);
    
    dest_str->offset = src_string_offset;
    
    mk_vm_range_t dst_cmd_range = mk_vm_range_make((mk_vm_address_t)dest_lc, dest_cmd_size);
    
    if (src_string_offset > dest_cmd_size) {
        _mkl_error(mk_type_get_context(image.macho), "src_string_offset is > dest_cmd_size.");
        return 0;
    }
    
    size_t dst_string_contents_len = dest_cmd_size - lc_base_size;
    char *dst_string = (char*)( (uint8_t*)dest_lc + dest_str->offset );
    
    strncpy(dst_string, src_string, dst_string_contents_len);
    
    if (mk_vm_range_contains_address(dst_cmd_range, dst_string_contents_len, (mk_vm_address_t)dst_string)) {
        dst_string[dst_string_contents_len] = '\0';
        return dst_string_contents_len + 1;
    } else
        return dst_string_contents_len;
}

//|++++++++++++++++++++++++++++++++++++|//
size_t
_mk_mach_lc_str_copy(mk_load_command_ref source_lc, union lc_str *source_str, char *output, size_t output_len, bool include_terminator)
{
    const struct load_command *lc = source_lc.load_command->mach_load_command;
    const mk_macho_ref image = source_lc.load_command->image;
    size_t lc_base_size = mk_load_command_base_size(source_lc);
    
    uint32_t cmd_len = mk_macho_get_byte_order(image)->swap32( lc->cmdsize );
    mk_vm_range_t cmd_range = mk_vm_range_make((mk_vm_address_t)lc, cmd_len);
    
    if (lc_base_size > cmd_len) {
        _mkl_error(mk_type_get_context(image.macho), "Input lc_base_size is > lc->cmdsize.");
        return 0;
    }
    
    size_t string_contents_len = cmd_len - lc_base_size;
    uint32_t string_offset = mk_macho_get_byte_order(image)->swap32( source_str->offset );
    char * string = (char*)( (uint8_t*)lc + string_offset );
    
    if (mk_vm_range_contains_range(cmd_range, mk_vm_range_make((mk_vm_address_t)string, string_contents_len), false))
    {
        string_contents_len = strnlen(string, string_contents_len);
        
        if (output && output_len != 0)
        {
            strncpy(output, string, MIN(string_contents_len, output_len));
            if (string_contents_len < output_len || include_terminator)
                output[string_contents_len] = '\0';
        }
        
        return include_terminator ? string_contents_len+1 : string_contents_len;
    }
    else
    {
        // TODO?
        _mkl_error(mk_type_get_context(image.macho), "Input str is not within the provided load command.");
        return 0;
    }
}
