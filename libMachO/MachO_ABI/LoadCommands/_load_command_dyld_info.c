//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             _load_command_dyld_info.c
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
_mk_load_command_type_dyld_info_copy_description(mk_load_command_ref load_command, char *output, size_t output_len)
{
    return (size_t)snprintf(output, output_len, "<%s %p> {\n\
\trebase_off = 0x%" PRIx32 "\n\
\trebase_size = 0x%" PRIx32 "\n\
\tbind_off = 0x%" PRIx32 "\n\
\tbind_size = 0x%" PRIx32 "\n\
\tweak_bind_off = 0x%" PRIx32 "\n\
\tweak_bind_size = 0x%" PRIx32 "\n\
\tlazy_bind_off = 0x%" PRIx32 "\n\
\tlazy_bind_size = 0x%" PRIx32 "\n\
\texport_off = 0x%" PRIx32 "\n\
\texport_size = 0x%" PRIx32 "\n\
\n}",
                            mk_type_name(load_command.type), load_command.type,
                            _mk_load_command_type_dyld_info_get_rebase_off(load_command),
                            _mk_load_command_type_dyld_info_get_rebase_size(load_command),
                            _mk_load_command_type_dyld_info_get_bind_off(load_command),
                            _mk_load_command_type_dyld_info_get_bind_size(load_command),
                            _mk_load_command_type_dyld_info_get_weak_bind_off(load_command),
                            _mk_load_command_type_dyld_info_get_weak_bind_size(load_command),
                            _mk_load_command_type_dyld_info_get_lazy_bind_off(load_command),
                            _mk_load_command_type_dyld_info_get_lazy_bind_size(load_command),
                            _mk_load_command_type_dyld_info_get_export_off(load_command),
                            _mk_load_command_type_dyld_info_get_export_size(load_command));
}

//|++++++++++++++++++++++++++++++++++++|//
mk_error_t
_mk_load_command_type_dyld_info_copy_native(mk_load_command_ref load_command, struct dyld_info_command *result)
{
    if (result == NULL) return MK_EINVAL;
    
    const mk_byteorder_t * const byte_order = mk_macho_get_byte_order(load_command.load_command->image);
    struct dyld_info_command *mach_dyld_info_command = (struct dyld_info_command*)load_command.load_command->mach_load_command;
    
    result->cmd = byte_order->swap32( mach_dyld_info_command->cmd );
    result->cmdsize = byte_order->swap32( mach_dyld_info_command->cmdsize );
    result->rebase_off = byte_order->swap32( mach_dyld_info_command->rebase_off );
    result->rebase_size = byte_order->swap32( mach_dyld_info_command->rebase_size );
    result->bind_off = byte_order->swap32( mach_dyld_info_command->bind_off );
    result->bind_size = byte_order->swap32( mach_dyld_info_command->bind_size );
    result->weak_bind_off = byte_order->swap32( mach_dyld_info_command->weak_bind_off );
    result->weak_bind_size = byte_order->swap32( mach_dyld_info_command->weak_bind_size );
    result->lazy_bind_off = byte_order->swap32( mach_dyld_info_command->lazy_bind_off );
    result->lazy_bind_size = byte_order->swap32( mach_dyld_info_command->lazy_bind_size );
    result->export_off = byte_order->swap32( mach_dyld_info_command->export_off );
    result->export_size = byte_order->swap32( mach_dyld_info_command->export_size );
    
    return MK_ESUCCESS;
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
_mk_load_command_type_dyld_info_get_rebase_off(mk_load_command_ref load_command)
{
    struct dyld_info_command *mach_dyld_info_command = (struct dyld_info_command*)load_command.load_command->mach_load_command;
    return mk_macho_get_byte_order(load_command.load_command->image)->swap32( mach_dyld_info_command->rebase_off );
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
_mk_load_command_type_dyld_info_get_rebase_size(mk_load_command_ref load_command)
{
    struct dyld_info_command *mach_dyld_info_command = (struct dyld_info_command*)load_command.load_command->mach_load_command;
    return mk_macho_get_byte_order(load_command.load_command->image)->swap32( mach_dyld_info_command->rebase_size );
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
_mk_load_command_type_dyld_info_get_bind_off(mk_load_command_ref load_command)
{
    struct dyld_info_command *mach_dyld_info_command = (struct dyld_info_command*)load_command.load_command->mach_load_command;
    return mk_macho_get_byte_order(load_command.load_command->image)->swap32( mach_dyld_info_command->bind_off );
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
_mk_load_command_type_dyld_info_get_bind_size(mk_load_command_ref load_command)
{
    struct dyld_info_command *mach_dyld_info_command = (struct dyld_info_command*)load_command.load_command->mach_load_command;
    return mk_macho_get_byte_order(load_command.load_command->image)->swap32( mach_dyld_info_command->bind_size );
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
_mk_load_command_type_dyld_info_get_weak_bind_off(mk_load_command_ref load_command)
{
    struct dyld_info_command *mach_dyld_info_command = (struct dyld_info_command*)load_command.load_command->mach_load_command;
    return mk_macho_get_byte_order(load_command.load_command->image)->swap32( mach_dyld_info_command->weak_bind_off );
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
_mk_load_command_type_dyld_info_get_weak_bind_size(mk_load_command_ref load_command)
{
    struct dyld_info_command *mach_dyld_info_command = (struct dyld_info_command*)load_command.load_command->mach_load_command;
    return mk_macho_get_byte_order(load_command.load_command->image)->swap32( mach_dyld_info_command->weak_bind_size );
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
_mk_load_command_type_dyld_info_get_lazy_bind_off(mk_load_command_ref load_command)
{
    struct dyld_info_command *mach_dyld_info_command = (struct dyld_info_command*)load_command.load_command->mach_load_command;
    return mk_macho_get_byte_order(load_command.load_command->image)->swap32( mach_dyld_info_command->lazy_bind_off );
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
_mk_load_command_type_dyld_info_get_lazy_bind_size(mk_load_command_ref load_command)
{
    struct dyld_info_command *mach_dyld_info_command = (struct dyld_info_command*)load_command.load_command->mach_load_command;
    return mk_macho_get_byte_order(load_command.load_command->image)->swap32( mach_dyld_info_command->lazy_bind_size );
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
_mk_load_command_type_dyld_info_get_export_off(mk_load_command_ref load_command)
{
    struct dyld_info_command *mach_dyld_info_command = (struct dyld_info_command*)load_command.load_command->mach_load_command;
    return mk_macho_get_byte_order(load_command.load_command->image)->swap32( mach_dyld_info_command->export_off );
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
_mk_load_command_type_dyld_info_get_export_size(mk_load_command_ref load_command)
{
    struct dyld_info_command *mach_dyld_info_command = (struct dyld_info_command*)load_command.load_command->mach_load_command;
    return mk_macho_get_byte_order(load_command.load_command->image)->swap32( mach_dyld_info_command->export_size );
}
