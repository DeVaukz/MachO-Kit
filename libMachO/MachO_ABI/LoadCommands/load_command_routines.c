//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             load_command_routines.c
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
_mk_load_command_routines_copy_description(mk_load_command_ref load_command, char *output, size_t output_len)
{
    return (size_t)snprintf(output, output_len, "<%s %p> {\n\
\tinit_address = 0x%" PRIx32 "\n\
\tinit_module = %" PRIi32 "\n\
}",
                            mk_type_name(load_command.type), load_command.type,
                            mk_load_command_routines_get_init_address(load_command),
                            mk_load_command_routines_get_init_module(load_command));
}

const struct _mk_load_command_vtable _mk_load_command_routines_class = {
    .base.super                 = &_mk_load_command_class,
    .base.name                  = "LC_ROUTINES",
    .base.copy_description      = &_mk_load_command_routines_copy_description,
    .command_id                 = LC_ROUTINES,
    .command_base_size          = sizeof(struct routines_command)
};

//|++++++++++++++++++++++++++++++++++++|//
uint32_t mk_load_command_routines_id()
{ return LC_ROUTINES; }

//|++++++++++++++++++++++++++++++++++++|//
mk_error_t mk_load_command_routines_copy_native(mk_load_command_ref load_command, struct routines_command *result)
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return MK_EINVAL);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_routines_class, return MK_EINVAL);
    if (result == NULL) return MK_EINVAL;
    
    const mk_byteorder_t * const byte_order = mk_macho_get_byte_order(load_command.load_command->image);
    struct routines_command *mach_routines_command = (struct routines_command*)load_command.load_command->mach_load_command;
    
    result->cmd = byte_order->swap32( mach_routines_command->cmd );
    result->cmdsize = byte_order->swap32( mach_routines_command->cmdsize );
    result->init_address = byte_order->swap32( mach_routines_command->init_address );
    result->init_module = byte_order->swap32( mach_routines_command->init_module );
    result->reserved1 = byte_order->swap32( mach_routines_command->reserved1 );
    result->reserved2 = byte_order->swap32( mach_routines_command->reserved2 );
    result->reserved3 = byte_order->swap32( mach_routines_command->reserved3 );
    result->reserved4 = byte_order->swap32( mach_routines_command->reserved4 );
    result->reserved5 = byte_order->swap32( mach_routines_command->reserved5 );
    result->reserved6 = byte_order->swap32( mach_routines_command->reserved6 );
    
    return MK_ESUCCESS;
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t mk_load_command_routines_get_init_address(mk_load_command_ref load_command)
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return UINT32_MAX);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_routines_class, return UINT32_MAX);
    
    struct routines_command *mach_routines_command = (struct routines_command*)load_command.load_command->mach_load_command;
    return mk_macho_get_byte_order(load_command.load_command->image)->swap32( mach_routines_command->init_address );
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t mk_load_command_routines_get_init_module(mk_load_command_ref load_command)
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return UINT32_MAX);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_routines_class, return UINT32_MAX);
    
    struct routines_command *mach_routines_command = (struct routines_command*)load_command.load_command->mach_load_command;
    return mk_macho_get_byte_order(load_command.load_command->image)->swap32( mach_routines_command->init_module );
}
