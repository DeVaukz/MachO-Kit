//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             load_command_source_version.c
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
_mk_load_command_source_version_copy_description(mk_load_command_ref load_command, char *output, size_t output_len)
{
    char version[256];
    mk_load_command_source_version_copy_version_string(load_command, version, sizeof(version));
    
    return (size_t)snprintf(output, output_len, "<%s %p> {\n\
\tSource Version: %s\n\
}",
                            mk_type_name(load_command.type), load_command.type, version);
}

const struct _mk_load_command_vtable _mk_load_command_source_version_class = {
    .base.super                 = &_mk_load_command_class,
    .base.name                  = "LC_SOURCE_VERSION",
    .base.copy_description      = &_mk_load_command_source_version_copy_description,
    .command_id                 = LC_SOURCE_VERSION,
    .command_base_size          = sizeof(struct source_version_command)
};

//|++++++++++++++++++++++++++++++++++++|//
uint32_t mk_load_command_source_version_id()
{ return LC_SOURCE_VERSION; }

//|++++++++++++++++++++++++++++++++++++|//
mk_error_t
mk_load_command_source_version_copy_native(mk_load_command_ref load_command, struct source_version_command *result)
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return MK_EINVAL);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_source_version_class, return MK_EINVAL);
    if (result == NULL) return MK_EINVAL;
    
    const mk_byteorder_t * const byte_order = mk_macho_get_byte_order(load_command.load_command->image);
    struct source_version_command *mach_source_version_command = (struct source_version_command*)load_command.load_command->mach_load_command;
    
    result->cmd = byte_order->swap32( mach_source_version_command->cmd );
    result->cmdsize = byte_order->swap32( mach_source_version_command->cmdsize );
    result->version = byte_order->swap64( mach_source_version_command->version );
    
    return MK_ESUCCESS;
}

//|++++++++++++++++++++++++++++++++++++|//
mk_error_t
mk_load_command_source_version_copy_components(mk_load_command_ref load_command, uint32_t components[5])
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return MK_EINVAL);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_source_version_class, return MK_EINVAL);
    if (components == NULL) return MK_EINVAL;
    
    struct source_version_command *mach_source_version_command = (struct source_version_command*)load_command.load_command->mach_load_command;
    uint64_t version = mk_macho_get_byte_order(load_command.load_command->image)->swap64( mach_source_version_command->version );
    
    components[0] = (version >> 40) & 0x7FFFFF;
    components[1] = (version >> 30) & 0x3FF;
    components[2] = (version >> 20) & 0x3FF;
    components[3] = (version >> 10) & 0x3FF;
    components[4] = (version >> 0) & 0x3FF;
    
    return MK_ESUCCESS;
}

//|++++++++++++++++++++++++++++++++++++|//
size_t
mk_load_command_source_version_copy_version_string(mk_load_command_ref load_command, char *output, size_t output_len)
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return 0);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_source_version_class, return 0);
    
    uint32_t components[5];
    mk_load_command_source_version_copy_components(load_command, components);
    
    return (size_t)snprintf(output, output_len, "%i.%i.%i.%i.%i", components[0], components[1], components[2], components[3], components[4]);
}
