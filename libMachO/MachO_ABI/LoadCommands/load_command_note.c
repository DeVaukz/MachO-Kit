//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             load_command_note.c
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
_mk_load_command_note_copy_description(mk_load_command_ref load_command, char *output, size_t output_len)
{
    char buffer[17] = { 0 };
    mk_load_command_note_copy_data_owner(load_command, buffer);
    
    return (size_t)snprintf(output, output_len, "<%s %p> {\n\
\tdata_owner = %s\n\
\toffset = 0x%" PRIx64 "\n\
\tsize = 0x%" PRIx64 "\n\
}",
                            mk_type_name(load_command.type), load_command.type, buffer,
                            mk_load_command_note_get_offset(load_command),
                            mk_load_command_note_get_size(load_command));
}

const struct _mk_load_command_vtable _mk_load_command_note_class = {
    .base.super                 = &_mk_load_command_class,
    .base.name                  = "LC_NOTE",
    .base.copy_description      = &_mk_load_command_note_copy_description,
    .command_id                 = LC_NOTE,
    .command_base_size          = sizeof(struct note_command)
};

//|++++++++++++++++++++++++++++++++++++|//
uint32_t mk_load_command_note_id()
{ return LC_NOTE; }

//|++++++++++++++++++++++++++++++++++++|//
mk_error_t
mk_load_command_note_copy_native(mk_load_command_ref load_command, struct note_command *result)
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return MK_EINVAL);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_note_class, return MK_EINVAL);
    if (result == NULL) return MK_EINVAL;
    
    const mk_byteorder_t * const byte_order = mk_macho_get_byte_order(load_command.load_command->image);
    struct note_command *mach_note_command = (struct note_command*)load_command.load_command->mach_load_command;
    
    result->cmd = byte_order->swap32( mach_note_command->cmd );
    result->cmdsize = byte_order->swap32( mach_note_command->cmdsize );
    memcpy(result->data_owner, mach_note_command->data_owner, sizeof(result->data_owner));
    result->offset = byte_order->swap64( mach_note_command->offset );
    result->size = byte_order->swap64( mach_note_command->size );
    
    return MK_ESUCCESS;
}

//|++++++++++++++++++++++++++++++++++++|//
size_t
mk_load_command_note_copy_data_owner(mk_load_command_ref load_command, char output[16])
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return 0);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_note_class, return 0);
    
    struct note_command *mach_note_command = (struct note_command*)load_command.load_command->mach_load_command;
    memcpy(output, mach_note_command->data_owner, sizeof(mach_note_command->data_owner));
    
    return sizeof(mach_note_command->data_owner);
}

//|++++++++++++++++++++++++++++++++++++|//
uint64_t
mk_load_command_note_get_offset(mk_load_command_ref load_command)
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return UINT64_MAX);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_note_class, return UINT64_MAX);
    
    struct note_command *mach_note_command = (struct note_command*)load_command.load_command->mach_load_command;
    return mk_macho_get_byte_order(load_command.load_command->image)->swap64( mach_note_command->offset );
}

//|++++++++++++++++++++++++++++++++++++|//
uint64_t
mk_load_command_note_get_size(mk_load_command_ref load_command)
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return UINT64_MAX);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_note_class, return UINT64_MAX);
    
    struct note_command *mach_note_command = (struct note_command*)load_command.load_command->mach_load_command;
    return mk_macho_get_byte_order(load_command.load_command->image)->swap64( mach_note_command->size );
}
