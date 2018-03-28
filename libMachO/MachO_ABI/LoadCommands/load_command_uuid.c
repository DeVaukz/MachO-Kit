//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             load_command_uuid.c
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
static size_t
_mk_load_command_uuid_copy_description(mk_load_command_ref load_command, char *output, size_t output_len)
{
    struct uuid_command *mach_uuid_command = (struct uuid_command*)load_command.load_command->mach_load_command;
    char uuid_pretty_print[sizeof(mach_uuid_command->uuid) * 2 + 4 + 1];
    mk_load_command_uuid_copy_prety_uuid(load_command, true, uuid_pretty_print, sizeof(uuid_pretty_print));
    
    return (size_t)snprintf(output, output_len, "<%s %p> %s", mk_type_name(load_command.type), load_command.type, uuid_pretty_print);
}

const struct _mk_load_command_vtable _mk_load_command_uuid_class = {
    .base.super                 = &_mk_load_command_class,
    .base.name                  = "LC_UUID",
    .base.copy_description      = &_mk_load_command_uuid_copy_description,
    .command_id                 = LC_UUID,
    .command_base_size          = sizeof(struct uuid_command)
};

//|++++++++++++++++++++++++++++++++++++|//
uint32_t mk_load_command_uuid_id()
{ return LC_UUID; }

//|++++++++++++++++++++++++++++++++++++|//
mk_error_t
mk_load_command_uuid_copy_native(mk_load_command_ref load_command, struct uuid_command *result)
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return MK_EINVAL);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_uuid_class, return MK_EINVAL);
    if (result == NULL) return MK_EINVAL;
    
    const mk_byteorder_t * const byte_order = mk_macho_get_byte_order(load_command.load_command->image);
    struct uuid_command *mach_uuid_command = (struct uuid_command*)load_command.load_command->mach_load_command;
    
    result->cmd = byte_order->swap32( mach_uuid_command->cmd );
    result->cmdsize = byte_order->swap32( mach_uuid_command->cmdsize );
    memcpy(result->uuid, mach_uuid_command->uuid, sizeof(result->uuid));
    
    return MK_ESUCCESS;
}

//|++++++++++++++++++++++++++++++++++++|//
mk_error_t
mk_load_command_uuid_copy_uuid(mk_load_command_ref load_command, uint8_t output[16])
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return MK_EINVAL);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_uuid_class, return MK_EINVAL);
    
    struct uuid_command *mach_uuid_command = (struct uuid_command*)load_command.load_command->mach_load_command;
    memcpy(output, mach_uuid_command->uuid, 16);
    
    return MK_ESUCCESS;
}

//|++++++++++++++++++++++++++++++++++++|//
size_t
mk_load_command_uuid_copy_prety_uuid(mk_load_command_ref load_command, bool include_seperators, char *output, size_t output_len)
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return 0);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_uuid_class, return 0);
    
    struct uuid_command *mach_uuid_command = (struct uuid_command*)load_command.load_command->mach_load_command;
    
    // Each byte in the UUID requires 2 hex digits + four dashes (optional) + null terminator
    char internal_buffer[sizeof(mach_uuid_command->uuid) * 2 + 4 + 1];
    unsigned int internal_buffer_pos = 0;
    
    if (output)
    {
        for (unsigned int i = 0; i < sizeof(mach_uuid_command->uuid); i++) {
            snprintf(&internal_buffer[internal_buffer_pos], 3, "%02X", mach_uuid_command->uuid[i]);
            internal_buffer_pos += 2;
            if ((i == 3 || i == 5 || i == 7 || i == 9) && include_seperators)
                internal_buffer[internal_buffer_pos++] = '-';
        }
        
        memcpy(output, internal_buffer, MIN(sizeof(internal_buffer), output_len));
        // Always end with a NULL byte, regardless of length.
        output[output_len - 1] = '\0';
    }
    
    return sizeof(internal_buffer);
}

