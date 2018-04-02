//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       load_command_version_min_tvos.h
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

#ifndef load_command_version_min_tvos_h
#define load_command_version_min_tvos_h

//! @addtogroup LOAD_COMMANDS
//! @{
//!

//----------------------------------------------------------------------------//
#pragma mark -  Version Min tvOS
//! @name       Version Min tvOS
//----------------------------------------------------------------------------//

_mk_export uint32_t
mk_load_command_version_min_tvos_id(void);

_mk_export mk_error_t
mk_load_command_version_min_tvos_copy_native(mk_load_command_ref load_command, struct version_min_command *result);

_mk_export uint8_t
mk_load_command_version_min_tvos_get_version_primary(mk_load_command_ref load_command);
_mk_export uint8_t
mk_load_command_version_min_tvos_get_version_major(mk_load_command_ref load_command);
_mk_export uint8_t
mk_load_command_version_min_tvos_get_version_minor(mk_load_command_ref load_command);

_mk_export size_t
mk_load_command_version_min_tvos_copy_version_string(mk_load_command_ref load_command, char *output, size_t output_len);

_mk_export uint8_t
mk_load_command_version_min_tvos_get_sdk_primary(mk_load_command_ref load_command);
_mk_export uint8_t
mk_load_command_version_min_tvos_get_sdk_major(mk_load_command_ref load_command);
_mk_export uint8_t
mk_load_command_version_min_tvos_get_sdk_minor(mk_load_command_ref load_command);

_mk_export size_t
mk_load_command_version_min_tvos_copy_sdk_string(mk_load_command_ref load_command, char *output, size_t output_len);

//! @} LOAD_COMMANDS !//

#endif /* load_command_version_min_tvos_h */
