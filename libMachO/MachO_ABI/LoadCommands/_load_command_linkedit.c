//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             _load_command_linkedit.c
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
_mk_load_command_type_linkedit_description(mk_load_command_ref load_command, char *output, size_t output_len)
{
    return (size_t)snprintf(output, output_len, "<%s %p> {\n\
\tdataoff = 0x%" PRIx32 "\n\
\tdatasize = 0x%" PRIx32 "\n\
}",
                            mk_type_name(load_command.type), load_command.type,
                            _mk_load_command_type_linkedit_get_dataoff(load_command),
                            _mk_load_command_type_linkedit_get_datasize(load_command));
}

//|++++++++++++++++++++++++++++++++++++|//
mk_error_t
_mk_load_command_type_linkedit_copy_native(mk_load_command_ref load_command, struct linkedit_data_command *result)
{
    if (result == NULL) return MK_EINVAL;
    
    const mk_byteorder_t * const byte_order = mk_macho_get_byte_order(load_command.load_command->image);
    struct linkedit_data_command *mach_code_signature_command = (struct linkedit_data_command*)load_command.load_command->mach_load_command;
    
    result->cmd = byte_order->swap32( mach_code_signature_command->cmd );
    result->cmdsize = byte_order->swap32( mach_code_signature_command->cmdsize );
    result->dataoff = byte_order->swap32( mach_code_signature_command->dataoff );
    result->datasize = byte_order->swap32( mach_code_signature_command->datasize );
    
    return MK_ESUCCESS;
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
_mk_load_command_type_linkedit_get_dataoff(mk_load_command_ref load_command)
{
    struct linkedit_data_command *mach_code_signature_command = (struct linkedit_data_command*)load_command.load_command->mach_load_command;
    return mk_macho_get_byte_order(load_command.load_command->image)->swap32( mach_code_signature_command->dataoff );
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
_mk_load_command_type_linkedit_get_datasize(mk_load_command_ref load_command)
{
    struct linkedit_data_command *mach_code_signature_command = (struct linkedit_data_command*)load_command.load_command->mach_load_command;
    return mk_macho_get_byte_order(load_command.load_command->image)->swap32( mach_code_signature_command->datasize );
}
