//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             load_command_dyld_environment.c
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

const struct _mk_load_command_vtable _mk_load_command_dyld_environment_class = {
    .base.super                 = &_mk_load_command_class,
    .base.name                  = "LC_DYLD_ENVIRONMENT",
    .base.copy_description      = &_mk_load_command_type_dylinker_description,
    .command_id                 = LC_DYLD_ENVIRONMENT,
    .command_base_size          = sizeof(struct dylinker_command)
};

//|++++++++++++++++++++++++++++++++++++|//
uint32_t mk_load_command_dyld_environment_id()
{ return LC_DYLD_ENVIRONMENT; }

//|++++++++++++++++++++++++++++++++++++|//
mk_error_t
mk_load_command_dyld_environment_copy_native(mk_load_command_ref load_command, struct dylinker_command *result, size_t extra)
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return MK_EINVAL);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_dyld_environment_class, return MK_EINVAL);
    return _mk_load_command_type_dylinker_copy_native(load_command, result, extra);
}

//|++++++++++++++++++++++++++++++++++++|//
size_t
mk_load_command_dyld_environment_copy_name(mk_load_command_ref load_command, char *output, size_t output_len)
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return 0);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_dyld_environment_class, return 0);
    return _mk_load_command_type_dylinker_copy_name(load_command, output, output_len);
}
