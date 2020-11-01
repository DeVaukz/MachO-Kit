//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             load_command_build_version.c
//|
//|             Milen Dzhumerov
//|             Copyright (c) 2020-2020 Milen Dzhumerov. All rights reserved.
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
static size_t
_mk_load_command_linker_option_copy_description(__unused mk_load_command_ref load_command, char *output, size_t output_len)
{
    char all_options_buffer[512];
    bzero(all_options_buffer, sizeof(all_options_buffer));
    
    // invariant:
    //   - chars at "strings_length" and beyond are all NULL
    //   - chars at indexes less than "strings_length" are non-NULL
    //   - strings_length < sizeof(description_buffer)
    size_t strings_length = 0;
    uint32_t num_strings = mk_load_command_linker_option_get_nstrings(load_command);
    if (num_strings == UINT32_MAX) {
        return 0;
    }
    
    for (uint32_t i = 0; i < num_strings; ++i) {
        char current_option_buffer[512];
        size_t copy_result = mk_load_command_linker_option_copy_string(load_command, i, current_option_buffer, sizeof(current_option_buffer));
        if (copy_result == 0) {
            return 0;
        }
        
        size_t remaining_length = sizeof(all_options_buffer) - strings_length;
        size_t char_count = (size_t)snprintf(&all_options_buffer[strings_length], remaining_length, "\t%s\n", current_option_buffer);
        if (char_count + 1 /* NULL char */ > remaining_length) {
            return 0;
        }
        
        strings_length += char_count; // point at the first NULL char
    }
    
    return (size_t)snprintf(output, output_len, "<%s %p> {\n%s}",
                                mk_type_name(load_command.type), load_command.type,
                                all_options_buffer);
}

const struct _mk_load_command_vtable _mk_load_command_linker_option_class = {
    .base.super                 = &_mk_load_command_class,
    .base.name                  = "LC_LINKER_OPTION",
    .base.copy_description      = &_mk_load_command_linker_option_copy_description,
    .command_id                 = LC_LINKER_OPTION,
    .command_base_size          = sizeof(struct linker_option_command)
};

//|++++++++++++++++++++++++++++++++++++|//
uint32_t mk_load_command_linker_option_id()
{ return LC_LINKER_OPTION; }

uint32_t
mk_load_command_linker_option_get_nstrings(mk_load_command_ref load_command)
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return UINT32_MAX);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_linker_option_class, return UINT32_MAX);
    
    struct linker_option_command *linker_option_command = (struct linker_option_command*)load_command.load_command->mach_load_command;
    return mk_macho_get_byte_order(load_command.load_command->image)->swap32( linker_option_command->count );
}

//|++++++++++++++++++++++++++++++++++++|//
static const char*
mk_load_command_linker_option_get_string(mk_load_command_ref load_command, uint32_t requested_index, size_t *string_length) {
    uint32_t nstrings = mk_load_command_linker_option_get_nstrings(load_command);
    if (nstrings == UINT32_MAX || requested_index >= nstrings) {
        return NULL;
    }

    struct linker_option_command *linker_option_command = (struct linker_option_command*)load_command.load_command->mach_load_command;
    char *command_end = ((char*)linker_option_command) + linker_option_command->cmdsize;
    char *current_option = ((char*)linker_option_command) + sizeof(struct linker_option_command);
    uint32_t current_index = 0;
    
    while (current_index <= requested_index && current_option < command_end) {
        size_t max_len = (size_t)(command_end - current_option);
        size_t current_string_len = strnlen(current_option, max_len);
        if (current_string_len == max_len) {
            // By the command spec, all strings must be NULL terminated
            return NULL;
        }
        
        if (current_index == requested_index) {
            if (string_length) {
                *string_length = current_string_len;
            }
            return current_option;
        }
        
        ++current_index;
        current_option += current_string_len + 1 /* NULL char */;
    }
    
    // Last processed NULL-terminated string ends exactly at the command end
    return NULL;
}

//|++++++++++++++++++++++++++++++++++++|//
size_t
mk_load_command_linker_option_copy_string(mk_load_command_ref load_command, uint32_t requested_index, char *output, size_t output_len)
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return 0);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_linker_option_class, return 0);
    
    size_t current_string_len = 0;
    const char *current_option_start = mk_load_command_linker_option_get_string(load_command, requested_index, &current_string_len);
    
    if (output != NULL && output_len > 0) {
        size_t bytes_to_copy = MIN(current_string_len, output_len - 1 /* NULL char */);
        memcpy(output, current_option_start, bytes_to_copy);
        output[bytes_to_copy] = '\0';
        
        return bytes_to_copy;
    }
    
    return current_string_len;
}

//|++++++++++++++++++++++++++++++++++++|//
#if __BLOCKS__
void
mk_load_command_linker_option_enumerate_strings(mk_load_command_ref load_command,
                                              void (^enumerator)(const char *string, uint32_t index, bool *stop))
{
    uint32_t nstrings = mk_load_command_linker_option_get_nstrings(load_command);
    if (nstrings == UINT32_MAX || enumerator == NULL) {
        return;
    }
    
    for (uint32_t i = 0; i < nstrings; ++i) {
        const char *string = mk_load_command_linker_option_get_string(load_command, i, NULL);
        if (string != NULL) {
            bool stop = false;
            enumerator(string, i, &stop);
            if (stop) {
                break;
            }
        }
    }
}
#endif
