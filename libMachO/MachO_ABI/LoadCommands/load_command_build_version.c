//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             load_command_build_version.c
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
_mk_load_command_build_version_copy_description(mk_load_command_ref load_command, char *output, size_t output_len)
{
    char minos[256];
    mk_load_command_build_version_copy_minos_string(load_command, minos, sizeof(minos));
    char sdk[256];
    mk_load_command_build_version_copy_sdk_string(load_command, sdk, sizeof(sdk));
    
    return (size_t)snprintf(output, output_len, "<%s %p> {\n\
\tPlatform: %" PRIu32 "\n\
\tMinimum OS: %s\n\
\tSDK: %s\n\
}",
                            mk_type_name(load_command.type), load_command.type,
                            mk_load_command_build_version_get_platform(load_command),
                            minos, sdk);
}

const struct _mk_load_command_vtable _mk_load_command_build_version_class = {
    .base.super                 = &_mk_load_command_class,
    .base.name                  = "LC_BUILD_VERSION",
    .base.copy_description      = &_mk_load_command_build_version_copy_description,
    .command_id                 = LC_BUILD_VERSION,
    .command_base_size          = sizeof(struct build_version_command)
};

//|++++++++++++++++++++++++++++++++++++|//
uint32_t mk_load_command_build_version_id()
{ return LC_BUILD_VERSION; }

//|++++++++++++++++++++++++++++++++++++|//
mk_error_t
mk_load_command_build_version_copy_native(mk_load_command_ref load_command, struct build_version_command *result)
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return MK_EINVAL);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_build_version_class, return MK_EINVAL);
    if (result == NULL) return MK_EINVAL;
    
    const mk_byteorder_t * const byte_order = mk_macho_get_byte_order(load_command.load_command->image);
    struct build_version_command *mach_build_version_command = (struct build_version_command*)load_command.load_command->mach_load_command;
    
    result->cmd = byte_order->swap32( mach_build_version_command->cmd );
    result->cmdsize = byte_order->swap32( mach_build_version_command->cmdsize );
    result->platform = byte_order->swap32( mach_build_version_command->platform );
    result->minos = byte_order->swap32( mach_build_version_command->minos );
    result->sdk = byte_order->swap32( mach_build_version_command->sdk );
    result->ntools = byte_order->swap32( mach_build_version_command->ntools );
    
    return MK_ESUCCESS;
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
mk_load_command_build_version_get_platform(mk_load_command_ref load_command)
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return UINT32_MAX);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_build_version_class, return UINT32_MAX);
    
    struct build_version_command *mach_build_version_command = (struct build_version_command*)load_command.load_command->mach_load_command;
    return mk_macho_get_byte_order(load_command.load_command->image)->swap32( mach_build_version_command->platform );
}

//|++++++++++++++++++++++++++++++++++++|//
uint16_t
mk_load_command_build_version_get_minos_primary(mk_load_command_ref load_command)
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return UINT16_MAX);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_build_version_class, return UINT16_MAX);
    
    struct build_version_command *mach_build_version_command = (struct build_version_command*)load_command.load_command->mach_load_command;
    uint32_t version = mk_macho_get_byte_order(load_command.load_command->image)->swap32( mach_build_version_command->minos );
    return (version >> 16) & 0xFFFF;
}

//|++++++++++++++++++++++++++++++++++++|//
uint8_t
mk_load_command_build_version_get_minos_major(mk_load_command_ref load_command)
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return UINT8_MAX);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_build_version_class, return UINT8_MAX);
    
    struct build_version_command *mach_build_version_command = (struct build_version_command*)load_command.load_command->mach_load_command;
    uint32_t version = mk_macho_get_byte_order(load_command.load_command->image)->swap32( mach_build_version_command->minos );
    return (version >> 8) & 0xF;
}

//|++++++++++++++++++++++++++++++++++++|//
uint8_t
mk_load_command_build_version_get_minos_minor(mk_load_command_ref load_command)
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return UINT8_MAX);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_build_version_class, return UINT8_MAX);
    
    struct build_version_command *mach_build_version_command = (struct build_version_command*)load_command.load_command->mach_load_command;
    uint32_t version = mk_macho_get_byte_order(load_command.load_command->image)->swap32( mach_build_version_command->minos );
    return (version >> 0) & 0xF;
}

//|++++++++++++++++++++++++++++++++++++|//
size_t
mk_load_command_build_version_copy_minos_string(mk_load_command_ref load_command, char *output, size_t output_len)
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return 0);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_build_version_class, return 0);
    
    return (size_t)snprintf(output, output_len, "%i.%i.%i",
                            mk_load_command_build_version_get_minos_primary(load_command),
                            mk_load_command_build_version_get_minos_major(load_command),
                            mk_load_command_build_version_get_minos_minor(load_command));
}

//|++++++++++++++++++++++++++++++++++++|//
uint16_t
mk_load_command_build_version_get_sdk_primary(mk_load_command_ref load_command)
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return UINT16_MAX);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_build_version_class, return UINT16_MAX);
    
    struct build_version_command *mach_build_version_command = (struct build_version_command*)load_command.load_command->mach_load_command;
    uint32_t version = mk_macho_get_byte_order(load_command.load_command->image)->swap32( mach_build_version_command->sdk );
    return (version >> 16) & 0xFFFF;
}

//|++++++++++++++++++++++++++++++++++++|//
uint8_t
mk_load_command_build_version_get_sdk_major(mk_load_command_ref load_command)
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return UINT8_MAX);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_build_version_class, return UINT8_MAX);
    
    struct build_version_command *mach_build_version_command = (struct build_version_command*)load_command.load_command->mach_load_command;
    uint32_t version = mk_macho_get_byte_order(load_command.load_command->image)->swap32( mach_build_version_command->sdk );
    return (version >> 8) & 0xF;
}

//|++++++++++++++++++++++++++++++++++++|//
uint8_t
mk_load_command_build_version_get_sdk_minor(mk_load_command_ref load_command)
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return UINT8_MAX);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_build_version_class, return UINT8_MAX);
    
    struct build_version_command *mach_build_version_command = (struct build_version_command*)load_command.load_command->mach_load_command;
    uint32_t version = mk_macho_get_byte_order(load_command.load_command->image)->swap32( mach_build_version_command->sdk );
    return (version >> 0) & 0xF;
}

//|++++++++++++++++++++++++++++++++++++|//
size_t
mk_load_command_build_version_copy_sdk_string(mk_load_command_ref load_command, char *output, size_t output_len)
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return 0);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_build_version_class, return 0);
    
    return (size_t)snprintf(output, output_len, "%i.%i.%i",
                            mk_load_command_build_version_get_sdk_primary(load_command),
                            mk_load_command_build_version_get_sdk_major(load_command),
                            mk_load_command_build_version_get_sdk_minor(load_command));
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
mk_load_command_build_version_get_ntools(mk_load_command_ref load_command)
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return UINT32_MAX);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_build_version_class, return UINT32_MAX);
    
    struct build_version_command *mach_build_version_command = (struct build_version_command*)load_command.load_command->mach_load_command;
    return mk_macho_get_byte_order(load_command.load_command->image)->swap32( mach_build_version_command->ntools );
}

//|++++++++++++++++++++++++++++++++++++|//
struct build_tool_version*
mk_load_command_build_version_get_next_tool(mk_load_command_ref load_command, struct build_tool_version *previous, mk_vm_address_t *target_address)
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return NULL);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_build_version_class, return NULL);
    
    uintptr_t cmd = (uintptr_t)load_command.load_command->mach_load_command;
    uint32_t cmdsize = mk_load_command_size(load_command);
    
    struct build_tool_version *tool;
    
    if (previous == NULL)
    {
        if (mk_load_command_build_version_get_ntools(load_command) == 0)
            return NULL;
        
        // Sanity Check
        if (cmdsize < sizeof(struct build_version_command) + sizeof(struct build_tool_version)) {
            _mkl_debug(mk_type_get_context(load_command.type), "Mach-O load command 'cmdsize' [%" PRIu32 "] is less than sizeof(struct build_version_command) + sizeof(struct build_tool_version).", cmdsize);
            return NULL;
        }
        
        tool = (typeof(tool))( (uintptr_t)cmd + sizeof(struct build_version_command) );
    }
    else
    {
        // Verify the 'previous' tool pointer is within the load command.
        tool = previous;
        if (mk_vm_range_contains_address(mk_vm_range_make(cmd, cmdsize), 0, (uintptr_t)tool) != MK_ESUCCESS) {
            char buffer[512] = { 0 };
            mk_load_command_copy_short_description(load_command, buffer, sizeof(buffer));
            _mkl_debug(mk_type_get_context(load_command.type), "Previous Mach-O tool command pointer [%p] is not within load command %s.", previous, buffer);
            return NULL;
        }
        
        tool = (typeof(tool))( (uintptr_t)tool + sizeof(struct build_tool_version) );
    }
    
    // Avoid walking off the end of the load command
    if ((uintptr_t)tool >= cmd + cmdsize)
        return NULL;
    
    if (target_address)
    {
        mk_error_t err;
        mk_memory_object_ref header_mapping = mk_macho_get_header_mapping(load_command.load_command->image);
        *target_address = mk_memory_object_unmap_address(header_mapping, 0, (uintptr_t)tool, sizeof(*tool), &err);
        if (err != MK_ESUCCESS)
            return NULL;
    }
    
    return tool;
}

//|++++++++++++++++++++++++++++++++++++|//
#if __BLOCKS__
void
mk_load_command_build_version_enumerate_tools(mk_load_command_ref load_command, void (^enumerator)(struct build_tool_version *tool, uint32_t index, mk_vm_address_t target_address))
{
    struct build_tool_version *tool = NULL;
    uint32_t index = 0;
    mk_vm_address_t target_address;
    
    while ((tool = mk_load_command_build_version_get_next_tool(load_command, tool, &target_address))) {
        enumerator(tool, index++, target_address);
    }
}
#endif

//----------------------------------------------------------------------------//
#pragma mark -  Build Tools
//----------------------------------------------------------------------------//

//|++++++++++++++++++++++++++++++++++++|//
mk_error_t
mk_load_command_build_version_build_tool_version_init(mk_load_command_ref build_version, struct build_tool_version *tool, mk_load_command_build_tool_version_t *build_tool_version)
{
    if (build_version.type == NULL) return MK_EINVAL;
    if (tool == NULL) return MK_EINVAL;
    if (build_tool_version == NULL) return MK_EINVAL;
    
    uintptr_t cmd = (uintptr_t)build_version.load_command->mach_load_command;
    uint32_t cmdsize = mk_load_command_size(build_version);
    
    if (mk_vm_range_contains_range(mk_vm_range_make(cmd, cmdsize), mk_vm_range_make((uintptr_t)tool, sizeof(*tool)), false) != MK_ESUCCESS) {
        char buffer[512] = { 0 };
        mk_load_command_copy_short_description(build_version, buffer, sizeof(buffer));
        _mkl_debug(mk_type_get_context(build_version.type), "Part of Mach-O tool command (pointer = %p, size = %zd) is not within load command %s.", tool, sizeof(*tool), buffer);
        return MK_EINVAL;
    }
    
    build_tool_version->build_version = build_version;
    build_tool_version->mach_build_tool_version = tool;
    
    return MK_ESUCCESS;
}

//|++++++++++++++++++++++++++++++++++++|//
mk_error_t
mk_load_command_build_version_build_tool_version_copy_native(mk_load_command_build_tool_version_t *build_tool_version, struct build_tool_version *result)
{
    if (build_tool_version == NULL) return MK_EINVAL;
    if (result == NULL) return MK_EINVAL;
    
    const mk_byteorder_t * const byte_order = mk_macho_get_byte_order(build_tool_version->build_version.load_command->image);
    struct build_tool_version *mach_build_tool_version = (struct build_tool_version*)build_tool_version->mach_build_tool_version;
    
    result->tool = byte_order->swap32( mach_build_tool_version->tool );
    result->version = byte_order->swap32( mach_build_tool_version->version );
    
    return MK_ESUCCESS;
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
mk_load_command_build_version_build_tool_version_get_tool(mk_load_command_build_tool_version_t *build_tool_version)
{
    if (build_tool_version == NULL) return UINT32_MAX;
    struct build_tool_version *mach_build_tool_version = (struct build_tool_version*)build_tool_version->mach_build_tool_version;
    return mk_macho_get_byte_order(build_tool_version->build_version.load_command->image)->swap32( mach_build_tool_version->tool );
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
mk_load_command_build_version_build_tool_version_get_version(mk_load_command_build_tool_version_t *build_tool_version)
{
    if (build_tool_version == NULL) return UINT32_MAX;
    struct build_tool_version *mach_build_tool_version = (struct build_tool_version*)build_tool_version->mach_build_tool_version;
    return mk_macho_get_byte_order(build_tool_version->build_version.load_command->image)->swap32( mach_build_tool_version->version );
}
