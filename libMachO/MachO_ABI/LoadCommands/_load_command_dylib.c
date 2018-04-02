//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             _load_command_dylib.c
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
_mk_load_command_type_dylib_copy_description(mk_load_command_ref load_command, char *output, size_t output_len)
{
    char buffer[MAXPATHLEN];
    _mk_load_command_type_dylib_copy_name(load_command, buffer, sizeof(buffer));
    
    return (size_t)snprintf(output, output_len, "<%s %p> {\n\
\tname = %s\n\
\ttimestamp = %" PRIu32 "\n\
\tcurrent_version = 0x%" PRIx32 "\n\
\tcompatibility_version = 0x%" PRIx32 "\n\
\n}",
                            mk_type_name(load_command.type), load_command.type, buffer,
                            _mk_load_command_type_dylib_get_timestamp(load_command),
                            _mk_load_command_type_dylib_get_current_version(load_command),
                            _mk_load_command_type_dylib_get_current_compatibility_version(load_command));
}

//|++++++++++++++++++++++++++++++++++++|//
mk_error_t
_mk_load_command_type_dylib_copy_native(mk_load_command_ref load_command, struct dylib_command *result, size_t extra)
{
    if (result == NULL) return MK_EINVAL;
    
    const mk_byteorder_t * const byte_order = mk_macho_get_byte_order(load_command.load_command->image);
    struct dylib_command *mach_dylib_command = (struct dylib_command*)load_command.load_command->mach_load_command;
    
    result->cmd = byte_order->swap32( mach_dylib_command->cmd );
    result->cmdsize = byte_order->swap32( mach_dylib_command->cmdsize );
    result->dylib.timestamp = byte_order->swap32( mach_dylib_command->dylib.timestamp );
    result->dylib.current_version = byte_order->swap32( mach_dylib_command->dylib.current_version );
    result->dylib.compatibility_version = byte_order->swap32( mach_dylib_command->dylib.compatibility_version );
    _mk_mach_lc_str_copy_native(load_command,
                                &mach_dylib_command->dylib.name,
                                (struct load_command*)result,
                                &result->dylib.name,
                                sizeof(*result) + extra);
    
    return MK_ESUCCESS;
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
_mk_load_command_type_dylib_get_timestamp(mk_load_command_ref load_command)
{
    struct dylib_command *mach_dylib_command = (struct dylib_command*)load_command.load_command->mach_load_command;
    return mk_macho_get_byte_order(load_command.load_command->image)->swap32( mach_dylib_command->dylib.timestamp );
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
_mk_load_command_type_dylib_get_current_version(mk_load_command_ref load_command)
{
    struct dylib_command *mach_dylib_command = (struct dylib_command*)load_command.load_command->mach_load_command;
    return mk_macho_get_byte_order(load_command.load_command->image)->swap32( mach_dylib_command->dylib.current_version );
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
_mk_load_command_type_dylib_get_current_compatibility_version(mk_load_command_ref load_command)
{
    struct dylib_command *mach_dylib_command = (struct dylib_command*)load_command.load_command->mach_load_command;
    return mk_macho_get_byte_order(load_command.load_command->image)->swap32( mach_dylib_command->dylib.compatibility_version );
}

//|++++++++++++++++++++++++++++++++++++|//
size_t
_mk_load_command_type_dylib_copy_name(mk_load_command_ref load_command, char *output, size_t output_len)
{
    struct dylib_command *mach_dylib_command = (struct dylib_command*)load_command.load_command->mach_load_command;
    return _mk_mach_lc_str_copy(load_command,
                                &mach_dylib_command->dylib.name,
                                output,
                                output_len,
                                true);
}
