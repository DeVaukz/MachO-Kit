//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             load_command_sub_client.c
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
_mk_load_command_sub_client_copy_description(mk_load_command_ref load_command, char *output, size_t output_len)
{
    char buffer[MAXPATHLEN];
    mk_load_command_sub_client_copy_name(load_command, buffer, sizeof(buffer));
    
    return (size_t)snprintf(output, output_len, "<%s %p> {\n\
\tclient = %s\n\
}",
                            mk_type_name(load_command.type), load_command.type, buffer);
}

const struct _mk_load_command_vtable _mk_load_command_sub_client_class = {
    .base.super                 = &_mk_load_command_class,
    .base.name                  = "LC_SUB_CLIENT",
    .base.copy_description      = &_mk_load_command_sub_client_copy_description,
    .command_id                 = LC_SUB_CLIENT,
    .command_base_size          = sizeof(struct sub_client_command)
};

//|++++++++++++++++++++++++++++++++++++|//
uint32_t mk_load_command_sub_client_id()
{ return LC_SUB_CLIENT; }

//|++++++++++++++++++++++++++++++++++++|//
mk_error_t
mk_load_command_sub_client_copy_native(mk_load_command_ref load_command, struct sub_client_command *result, size_t extra)
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return MK_EINVAL);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_sub_client_class, return MK_EINVAL);
    if (result == NULL) return MK_EINVAL;
    
    const mk_byteorder_t * const byte_order = mk_macho_get_byte_order(load_command.load_command->image);
    struct sub_client_command *mach_sub_client_command = (struct sub_client_command*)load_command.load_command->mach_load_command;
    
    result->cmd = byte_order->swap32( mach_sub_client_command->cmd );
    result->cmdsize = byte_order->swap32( mach_sub_client_command->cmdsize );
    
    _mk_mach_lc_str_copy_native(load_command,
                                &mach_sub_client_command->client,
                                (struct load_command*)result,
                                &result->client,
                                sizeof(*result) + extra);
    
    return MK_ESUCCESS;
}

//|++++++++++++++++++++++++++++++++++++|//
size_t
mk_load_command_sub_client_copy_name(mk_load_command_ref load_command, char *output, size_t output_len)
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return 0);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_sub_client_class, return 0);
    
    struct sub_client_command *mach_sub_client_command = (struct sub_client_command*)load_command.load_command->mach_load_command;
    return _mk_mach_lc_str_copy(load_command, &mach_sub_client_command->client, output, output_len, true);
}
