//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             load_command_version_min_tvos.c
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
_mk_load_command_min_version_tvos_copy_description(mk_load_command_ref load_command, char *output, size_t output_len)
{
    char version[256];
    mk_load_command_version_min_tvos_copy_version_string(load_command, version, sizeof(version));
    char sdk[256];
    mk_load_command_version_min_tvos_copy_sdk_string(load_command, sdk, sizeof(sdk));
    
    return (size_t)snprintf(output, output_len, "<%s %p> {\n\
\tVersion: %s\n\
\tSDK: %s\n\
}",
                            mk_type_name(load_command.type), load_command.type, version, sdk);
}

const struct _mk_load_command_vtable _mk_load_command_version_min_tvos_class = {
    .base.super                 = &_mk_load_command_class,
    .base.name                  = "LC_VERSION_MIN_TVOS",
    .base.copy_description      = &_mk_load_command_min_version_tvos_copy_description,
    .command_id                 = LC_VERSION_MIN_TVOS,
    .command_base_size          = sizeof(struct version_min_command)
};

//|++++++++++++++++++++++++++++++++++++|//
uint32_t mk_load_command_version_min_tvos_id()
{ return LC_VERSION_MIN_TVOS; }

//|++++++++++++++++++++++++++++++++++++|//
mk_error_t
mk_load_command_version_min_tvos_copy_native(mk_load_command_ref load_command, struct version_min_command *result)
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return MK_EINVAL);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_version_min_tvos_class, return MK_EINVAL);
    if (result == NULL) return MK_EINVAL;
    
    const mk_byteorder_t * const byte_order = mk_macho_get_byte_order(load_command.load_command->image);
    struct version_min_command *mach_version_min_command = (struct version_min_command*)load_command.load_command->mach_load_command;
    
    result->cmd = byte_order->swap32( mach_version_min_command->cmd );
    result->cmdsize = byte_order->swap32( mach_version_min_command->cmdsize );
    result->version = byte_order->swap32( mach_version_min_command->version );
    result->sdk = byte_order->swap32( mach_version_min_command->sdk );
    
    return MK_ESUCCESS;
}

//|++++++++++++++++++++++++++++++++++++|//
uint8_t
mk_load_command_version_min_tvos_get_version_primary(mk_load_command_ref load_command)
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return UINT8_MAX);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_version_min_tvos_class, return UINT8_MAX);
    
    struct version_min_command *mach_version_min_command = (struct version_min_command*)load_command.load_command->mach_load_command;
    uint32_t version = mk_macho_get_byte_order(load_command.load_command->image)->swap32( mach_version_min_command->version );
    return (version >> 16) & 0xF;
}

//|++++++++++++++++++++++++++++++++++++|//
uint8_t
mk_load_command_version_min_tvos_get_version_major(mk_load_command_ref load_command)
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return UINT8_MAX);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_version_min_tvos_class, return UINT8_MAX);
    
    struct version_min_command *mach_version_min_command = (struct version_min_command*)load_command.load_command->mach_load_command;
    uint32_t version = mk_macho_get_byte_order(load_command.load_command->image)->swap32( mach_version_min_command->version );
    return (version >> 8) & 0xF;
}

//|++++++++++++++++++++++++++++++++++++|//
uint8_t
mk_load_command_version_min_tvos_get_version_minor(mk_load_command_ref load_command)
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return UINT8_MAX);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_version_min_tvos_class, return UINT8_MAX);
    
    struct version_min_command *mach_version_min_command = (struct version_min_command*)load_command.load_command->mach_load_command;
    uint32_t version = mk_macho_get_byte_order(load_command.load_command->image)->swap32( mach_version_min_command->version );
    return (version >> 0) & 0xF;
}

//|++++++++++++++++++++++++++++++++++++|//
size_t
mk_load_command_version_min_tvos_copy_version_string(mk_load_command_ref load_command, char *output, size_t output_len)
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return 0);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_version_min_tvos_class, return 0);
    
    return (size_t)snprintf(output, output_len, "%i.%i.%i",
                            mk_load_command_version_min_tvos_get_version_primary(load_command),
                            mk_load_command_version_min_tvos_get_version_major(load_command),
                            mk_load_command_version_min_tvos_get_version_minor(load_command));
}

//|++++++++++++++++++++++++++++++++++++|//
uint8_t
mk_load_command_version_min_tvos_get_sdk_primary(mk_load_command_ref load_command)
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return UINT8_MAX);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_version_min_tvos_class, return UINT8_MAX);
    
    struct version_min_command *mach_version_min_command = (struct version_min_command*)load_command.load_command->mach_load_command;
    uint32_t sdk = mk_macho_get_byte_order(load_command.load_command->image)->swap32( mach_version_min_command->sdk );
    return (sdk >> 16) & 0xF;
}

//|++++++++++++++++++++++++++++++++++++|//
uint8_t
mk_load_command_version_min_tvos_get_sdk_major(mk_load_command_ref load_command)
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return UINT8_MAX);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_version_min_tvos_class, return UINT8_MAX);
    
    struct version_min_command *mach_version_min_command = (struct version_min_command*)load_command.load_command->mach_load_command;
    uint32_t sdk = mk_macho_get_byte_order(load_command.load_command->image)->swap32( mach_version_min_command->sdk );
    return (sdk >> 8) & 0xF;
}

//|++++++++++++++++++++++++++++++++++++|//
uint8_t
mk_load_command_version_min_tvos_get_sdk_minor(mk_load_command_ref load_command)
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return UINT8_MAX);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_version_min_tvos_class, return UINT8_MAX);
    
    struct version_min_command *mach_version_min_command = (struct version_min_command*)load_command.load_command->mach_load_command;
    uint32_t sdk = mk_macho_get_byte_order(load_command.load_command->image)->swap32( mach_version_min_command->sdk );
    return (sdk >> 0) & 0xF;
}

//|++++++++++++++++++++++++++++++++++++|//
size_t
mk_load_command_version_min_tvos_copy_sdk_string(mk_load_command_ref load_command, char *output, size_t output_len)
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return 0);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_version_min_tvos_class, return 0);
    
    return (size_t)snprintf(output, output_len, "%i.%i.%i",
                            mk_load_command_version_min_tvos_get_sdk_primary(load_command),
                            mk_load_command_version_min_tvos_get_sdk_major(load_command),
                            mk_load_command_version_min_tvos_get_sdk_minor(load_command));
}
