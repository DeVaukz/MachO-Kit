//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       load_command_build_version.h
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

#ifndef _load_command_build_version_h
#define _load_command_build_version_h

//! @addtogroup LOAD_COMMANDS
//! @{
//!

//----------------------------------------------------------------------------//
#pragma mark -  Build Version
//! @name       Build Version
//----------------------------------------------------------------------------//

_mk_export uint32_t
mk_load_command_build_version_id(void);

_mk_export mk_error_t
mk_load_command_build_version_copy_native(mk_load_command_ref load_command, struct build_version_command *result);

_mk_export uint32_t
mk_load_command_build_version_get_platform(mk_load_command_ref load_command);

_mk_export uint16_t
mk_load_command_build_version_get_minos_primary(mk_load_command_ref load_command);
_mk_export uint8_t
mk_load_command_build_version_get_minos_major(mk_load_command_ref load_command);
_mk_export uint8_t
mk_load_command_build_version_get_minos_minor(mk_load_command_ref load_command);

_mk_export size_t
mk_load_command_build_version_copy_minos_string(mk_load_command_ref load_command, char *output, size_t output_len);

_mk_export uint16_t
mk_load_command_build_version_get_sdk_primary(mk_load_command_ref load_command);
_mk_export uint8_t
mk_load_command_build_version_get_sdk_major(mk_load_command_ref load_command);
_mk_export uint8_t
mk_load_command_build_version_get_sdk_minor(mk_load_command_ref load_command);

_mk_export size_t
mk_load_command_build_version_copy_sdk_string(mk_load_command_ref load_command, char *output, size_t output_len);

_mk_export uint32_t
mk_load_command_build_version_get_ntools(mk_load_command_ref load_command);

_mk_export struct build_tool_version*
mk_load_command_build_version_get_next_tool(mk_load_command_ref load_command, struct build_tool_version *previous, mk_vm_address_t *target_address);

#if __BLOCKS__
//! Iterate over the build tools using a block.
_mk_export void
mk_load_command_build_version_enumerate_tools(mk_load_command_ref load_command,
                                              void (^enumerator)(struct build_tool_version *tool, uint32_t index, mk_vm_address_t target_address));
#endif


//----------------------------------------------------------------------------//
#pragma mark -  Build Tools
//! @name       Build Tools
//----------------------------------------------------------------------------//

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
//! @internal
//
typedef struct mk_load_command_build_tool_version_s {
    // The build_version command that the build tool version resides within.
    mk_load_command_ref build_version;
    // Pointer to the Mach-O build_tool_version structure.
    struct build_tool_version *mach_build_tool_version;
} mk_load_command_build_tool_version_t;

//! Initializes a new build tool version.
_mk_export mk_error_t
mk_load_command_build_version_build_tool_version_init(mk_load_command_ref build_version, struct build_tool_version *tool, mk_load_command_build_tool_version_t *build_tool_version);

_mk_export mk_error_t
mk_load_command_build_version_build_tool_version_copy_native(mk_load_command_build_tool_version_t *build_tool_version, struct build_tool_version *result);

_mk_export uint32_t
mk_load_command_build_version_build_tool_version_get_tool(mk_load_command_build_tool_version_t *build_tool_version);
_mk_export uint32_t
mk_load_command_build_version_build_tool_version_get_version(mk_load_command_build_tool_version_t *build_tool_version);


//! @} LOAD_COMMANDS !//

#endif /* _load_command_build_version_h */
