//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       _load_command_dylib.h
//!
//! @author     D.V.
//! @copyright  Copyright (c) 2014-2015 D.V. All rights reserved.
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

#ifndef __load_command_dylib_h
#define __load_command_dylib_h
#ifndef DOXYGEN

//! @addtogroup LOAD_COMMANDS
//! @{
//!

//----------------------------------------------------------------------------//
#pragma mark -  Dylib
//! @name       Dylib
//----------------------------------------------------------------------------//

_mk_internal_extern size_t
_mk_load_command_type_dylib_copy_description(mk_load_command_ref load_command, char *output, size_t output_len);
_mk_internal_extern mk_error_t
_mk_load_command_type_dylib_copy_native(mk_load_command_ref load_command, struct dylib_command *result, size_t extra);

_mk_internal_extern uint32_t
_mk_load_command_type_dylib_get_timestamp(mk_load_command_ref load_command);
_mk_internal_extern uint32_t
_mk_load_command_type_dylib_get_current_version(mk_load_command_ref load_command);
_mk_internal_extern uint32_t
_mk_load_command_type_dylib_get_current_compatibility_version(mk_load_command_ref load_command);
_mk_internal_extern size_t
_mk_load_command_type_dylib_copy_name(mk_load_command_ref load_command, char *output, size_t output_len);


//! @} LOAD_COMMANDS !//

#endif
#endif /* __load_command_dylib_h */
