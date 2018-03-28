//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             load_command_encryption_info_64.c
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
_mk_load_command_encryption_info_64_copy_description(mk_load_command_ref load_command, char *output, size_t output_len)
{
    return (size_t)snprintf(output, output_len, "<%s %p> {\n\
\tcryptoff = 0x%" PRIx32 "\n\
\tcryptsize = 0x%" PRIx32 "\n\
\tcryptid = 0x%" PRIx32 "\n\
}",
                            mk_type_name(load_command.type), load_command.type,
                            mk_load_command_encryption_info_64_get_cryptoff(load_command),
                            mk_load_command_encryption_info_64_get_cryptsize(load_command),
                            mk_load_command_encryption_info_64_get_cryptid(load_command));
}

const struct _mk_load_command_vtable _mk_load_command_encryption_info_64_class = {
    .base.super                 = &_mk_load_command_class,
    .base.name                  = "LC_ENCRYPTION_INFO_64",
    .base.copy_description      = &_mk_load_command_encryption_info_64_copy_description,
    .command_id                 = LC_ENCRYPTION_INFO_64,
    .command_base_size          = sizeof(struct encryption_info_command_64)
};

//|++++++++++++++++++++++++++++++++++++|//
uint32_t mk_load_command_encryption_info_64_id()
{ return LC_ENCRYPTION_INFO_64; }

//|++++++++++++++++++++++++++++++++++++|//
mk_error_t
mk_load_command_encryption_info_64_copy_native(mk_load_command_ref load_command, struct encryption_info_command_64 *result)
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return MK_EINVAL);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_encryption_info_64_class, return MK_EINVAL);
    if (result == NULL) return MK_EINVAL;
    
    const mk_byteorder_t * const byte_order = mk_macho_get_byte_order(load_command.load_command->image);
    struct encryption_info_command_64 *mach_encryption_info_command = (struct encryption_info_command_64*)load_command.load_command->mach_load_command;
    
    result->cmd = byte_order->swap32( mach_encryption_info_command->cmd );
    result->cmdsize = byte_order->swap32( mach_encryption_info_command->cmdsize );
    result->cryptoff = byte_order->swap32( mach_encryption_info_command->cryptoff );
    result->cryptsize = byte_order->swap32( mach_encryption_info_command->cryptsize );
    result->cryptid = byte_order->swap32( mach_encryption_info_command->cryptid );
    
    return MK_ESUCCESS;
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
mk_load_command_encryption_info_64_get_cryptoff(mk_load_command_ref load_command)
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return UINT32_MAX);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_encryption_info_64_class, return UINT32_MAX);
    
    struct encryption_info_command_64 *mach_encryption_info_command = (struct encryption_info_command_64*)load_command.load_command->mach_load_command;
    return mk_macho_get_byte_order(load_command.load_command->image)->swap32( mach_encryption_info_command->cryptoff );
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
mk_load_command_encryption_info_64_get_cryptsize(mk_load_command_ref load_command)
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return UINT32_MAX);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_encryption_info_64_class, return UINT32_MAX);
    
    struct encryption_info_command_64 *mach_encryption_info_command = (struct encryption_info_command_64*)load_command.load_command->mach_load_command;
    return mk_macho_get_byte_order(load_command.load_command->image)->swap32( mach_encryption_info_command->cryptsize );
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
mk_load_command_encryption_info_64_get_cryptid(mk_load_command_ref load_command)
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return UINT32_MAX);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_encryption_info_64_class, return UINT32_MAX);
    
    struct encryption_info_command_64 *mach_encryption_info_command = (struct encryption_info_command_64*)load_command.load_command->mach_load_command;
    return mk_macho_get_byte_order(load_command.load_command->image)->swap32( mach_encryption_info_command->cryptid );
}
