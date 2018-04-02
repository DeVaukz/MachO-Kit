//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             load_command_segment.c
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

//----------------------------------------------------------------------------//
#pragma mark -  Segment
//----------------------------------------------------------------------------//

//|++++++++++++++++++++++++++++++++++++|//
static size_t
_mk_load_command_segment_copy_description(mk_load_command_ref load_command, char *output, size_t output_len)
{
    char buffer[17] = { 0 };
    mk_load_command_segment_copy_name(load_command, buffer);
    
    return (size_t)snprintf(output, output_len, "<%s %p> {\n\
\tsegname = %s\n\
\tvmaddr = 0x%" PRIx32 "\n\
\tvmsize = 0x%" PRIx32 "\n\
\tfileoff = 0x%" PRIx32 "\n\
\tfilesize = 0x%" PRIx32 "\n\
\tmaxprot = 0x%X\n\
\tinitprot = 0x%X\n\
\tnsects = %" PRIu32 "\n\
}",
                            mk_type_name(load_command.type), load_command.type, buffer,
                            mk_load_command_segment_get_vmaddr(load_command),
                            mk_load_command_segment_get_vmsize(load_command),
                            mk_load_command_segment_get_fileoff(load_command),
                            mk_load_command_segment_get_filesize(load_command),
                            mk_load_command_segment_get_maxprot(load_command),
                            mk_load_command_segment_get_initprot(load_command),
                            mk_load_command_segment_get_nsects(load_command));
}

const struct _mk_load_command_vtable _mk_load_command_segment_class = {
    .base.super                 = &_mk_load_command_class,
    .base.name                  = "LC_SEGMENT",
    .base.copy_description      = &_mk_load_command_segment_copy_description,
    .command_id                 = LC_SEGMENT,
    .command_base_size          = sizeof(struct segment_command)
};

//|++++++++++++++++++++++++++++++++++++|//
uint32_t mk_load_command_segment_id()
{ return LC_SEGMENT; }

//|++++++++++++++++++++++++++++++++++++|//
mk_error_t
mk_load_command_segment_copy_native(mk_load_command_ref load_command, struct segment_command *result)
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return MK_EINVAL);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_segment_class, return MK_EINVAL);
    if (result == NULL) return MK_EINVAL;
    
    const mk_byteorder_t * const byte_order = mk_macho_get_byte_order(load_command.load_command->image);
    struct segment_command *mach_segment_command = (struct segment_command*)load_command.load_command->mach_load_command;
    
    result->cmd = byte_order->swap32( mach_segment_command->cmd );
    result->cmdsize = byte_order->swap32( mach_segment_command->cmdsize );
    memcpy(result->segname, mach_segment_command->segname, sizeof(result->segname));
    result->vmaddr = byte_order->swap32( mach_segment_command->vmaddr );
    result->vmsize = byte_order->swap32( mach_segment_command->vmsize );
    result->fileoff = byte_order->swap32( mach_segment_command->fileoff );
    result->filesize = byte_order->swap32( mach_segment_command->filesize );
    result->maxprot = (vm_prot_t)byte_order->swap32( (uint32_t)mach_segment_command->maxprot );
    result->initprot = (vm_prot_t)byte_order->swap32( (uint32_t)mach_segment_command->initprot );
    result->nsects = byte_order->swap32( mach_segment_command->nsects );
    result->flags = byte_order->swap32( mach_segment_command->flags );
    
    return MK_ESUCCESS;
}

//|++++++++++++++++++++++++++++++++++++|//
size_t
mk_load_command_segment_copy_name(mk_load_command_ref load_command, char output[16])
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return 0);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_segment_class, return 0);
    
    struct segment_command *mach_segment_command = (struct segment_command*)load_command.load_command->mach_load_command;
    memcpy(output, mach_segment_command->segname, sizeof(mach_segment_command->segname));
    
    return sizeof(mach_segment_command->segname);
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
mk_load_command_segment_get_vmaddr(mk_load_command_ref load_command)
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return UINT32_MAX);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_segment_class, return UINT32_MAX);
    
    struct segment_command *mach_segment_command = (struct segment_command*)load_command.load_command->mach_load_command;
    return mk_macho_get_byte_order(load_command.load_command->image)->swap32( mach_segment_command->vmaddr );
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
mk_load_command_segment_get_vmsize(mk_load_command_ref load_command)
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return UINT32_MAX);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_segment_class, return UINT32_MAX);
    
    struct segment_command *mach_segment_command = (struct segment_command*)load_command.load_command->mach_load_command;
    return mk_macho_get_byte_order(load_command.load_command->image)->swap32( mach_segment_command->vmsize );
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
mk_load_command_segment_get_fileoff(mk_load_command_ref load_command)
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return UINT32_MAX);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_segment_class, return UINT32_MAX);
    
    struct segment_command *mach_segment_command = (struct segment_command*)load_command.load_command->mach_load_command;
    return mk_macho_get_byte_order(load_command.load_command->image)->swap32( mach_segment_command->fileoff );
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
mk_load_command_segment_get_filesize(mk_load_command_ref load_command)
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return UINT32_MAX);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_segment_class, return UINT32_MAX);
    
    struct segment_command *mach_segment_command = (struct segment_command*)load_command.load_command->mach_load_command;
    return mk_macho_get_byte_order(load_command.load_command->image)->swap32( mach_segment_command->filesize );
}

//|++++++++++++++++++++++++++++++++++++|//
vm_prot_t
mk_load_command_segment_get_maxprot(mk_load_command_ref load_command)
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return INT_MAX);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_segment_class, return INT_MAX);
    
    struct segment_command *mach_segment_command = (struct segment_command*)load_command.load_command->mach_load_command;
    return (vm_prot_t)mk_macho_get_byte_order(load_command.load_command->image)->swap32( (uint32_t)mach_segment_command->maxprot );
}

//|++++++++++++++++++++++++++++++++++++|//
vm_prot_t
mk_load_command_segment_get_initprot(mk_load_command_ref load_command)
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return INT_MAX);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_segment_class, return INT_MAX);
    
    struct segment_command *mach_segment_command = (struct segment_command*)load_command.load_command->mach_load_command;
    return (vm_prot_t)mk_macho_get_byte_order(load_command.load_command->image)->swap32( (uint32_t)mach_segment_command->initprot );
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
mk_load_command_segment_get_nsects(mk_load_command_ref load_command)
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return UINT32_MAX);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_segment_class, return UINT32_MAX);
    
    struct segment_command *mach_segment_command = (struct segment_command*)load_command.load_command->mach_load_command;
    return mk_macho_get_byte_order(load_command.load_command->image)->swap32( mach_segment_command->nsects );
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
mk_load_command_segment_get_flags(mk_load_command_ref load_command)
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return UINT32_MAX);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_segment_class, return UINT32_MAX);
    
    struct segment_command *mach_segment_command = (struct segment_command*)load_command.load_command->mach_load_command;
    return mk_macho_get_byte_order(load_command.load_command->image)->swap32( mach_segment_command->flags );
}

//|++++++++++++++++++++++++++++++++++++|//
struct section*
mk_load_command_segment_next_section(mk_load_command_ref load_command, struct section *previous, mk_vm_address_t *target_address)
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return NULL);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_segment_class, return NULL);
    
    uintptr_t cmd = (uintptr_t)load_command.load_command->mach_load_command;
    uint32_t cmdsize = mk_load_command_size(load_command);
    
    struct section *sec;
    
    if (previous == NULL)
    {
        if (mk_load_command_segment_get_nsects(load_command) == 0)
            return NULL;
        
        // Sanity Check
        if (cmdsize < sizeof(struct segment_command) + sizeof(struct section)) {
            _mkl_debug(mk_type_get_context(load_command.load_command), "Mach-O load command 'cmdsize' [%" PRIu32 "] is less than sizeof(struct segment_command) + sizeof(struct section).", cmdsize);
            return NULL;
        }
        
        sec = (typeof(sec))( (uintptr_t)cmd + sizeof(struct segment_command) );
    }
    else
    {
        // Verify the 'previous' section pointer is within the load command.
        sec = previous;
        if (mk_vm_range_contains_address(mk_vm_range_make(cmd, cmdsize), 0, (uintptr_t)sec) != MK_ESUCCESS) {
            char buffer[512] = { 0 };
            mk_load_command_copy_short_description(load_command, buffer, sizeof(buffer));
            _mkl_debug(mk_type_get_context(load_command.load_command), "Previous Mach-O section command pointer [%p] is not within load command %s.", previous, buffer);
            return NULL;
        }
        
        sec = (typeof(sec))( (uintptr_t)sec + sizeof(struct section) );
    }
    
    // Avoid walking off the end of the segment command
    if ((uintptr_t)sec >= cmd + cmdsize)
        return NULL;
    
    if (target_address)
    {
        mk_error_t err;
        mk_memory_object_ref header_mapping = mk_macho_get_header_mapping(load_command.load_command->image);
        *target_address = mk_memory_object_unmap_address(header_mapping, 0, (uintptr_t)sec, sizeof(*sec), &err);
        if (err != MK_ESUCCESS)
            return NULL;
    }
    
    return sec;
}

//|++++++++++++++++++++++++++++++++++++|//
#if __BLOCKS__
void
mk_load_command_segment_enumerate_sections(mk_load_command_ref load_command, void (^enumerator)(struct section *command, uint32_t index, mk_vm_address_t target_address))
{
    struct section *sec = NULL;
    uint32_t index = 0;
    mk_vm_address_t target_address;
    
    while ((sec = mk_load_command_segment_next_section(load_command, sec, &target_address))) {
        enumerator(sec, index++, target_address);
    }
}
#endif

//----------------------------------------------------------------------------//
#pragma mark -  Section
//----------------------------------------------------------------------------//

//|++++++++++++++++++++++++++++++++++++|//
mk_error_t
mk_load_command_segment_section_init(mk_load_command_ref segment, struct section *sec, mk_load_command_section_t *section)
{
    if (segment.type == NULL) return MK_EINVAL;
    if (sec == NULL) return MK_EINVAL;
    if (section == NULL) return MK_EINVAL;
    
    uintptr_t cmd = (uintptr_t)segment.load_command->mach_load_command;
    uint32_t cmdsize = mk_load_command_size(segment);
    
    if (mk_vm_range_contains_range(mk_vm_range_make(cmd, cmdsize), mk_vm_range_make((uintptr_t)sec, sizeof(*sec)), false) != MK_ESUCCESS) {
        char buffer[512] = { 0 };
        mk_load_command_copy_short_description(segment, buffer, sizeof(buffer));
        _mkl_debug(mk_type_get_context(segment.type), "Part of Mach-O section command (pointer = %p, size = %zd) is not within load command %s.", sec, sizeof(*sec), buffer);
        return MK_EINVAL;
    }
    
    section->segment = segment;
    section->mach_section = sec;
    
    return MK_ESUCCESS;
}

//|++++++++++++++++++++++++++++++++++++|//
mk_error_t
mk_load_command_segment_section_copy_native(mk_load_command_section_t *section, struct section *result)
{
    if (section == NULL) return MK_EINVAL;
    if (result == NULL) return MK_EINVAL;
    
    const mk_byteorder_t * const byte_order = mk_macho_get_byte_order(section->segment.load_command->image);
    struct section *mach_section = (struct section*)section->mach_section;
    
    memcpy(result->sectname, mach_section->sectname, sizeof(mach_section->sectname));
    memcpy(result->segname, mach_section->segname, sizeof(mach_section->segname));
    result->addr = byte_order->swap32( mach_section->addr );
    result->size = byte_order->swap32( mach_section->size );
    result->offset = byte_order->swap32( mach_section->offset );
    result->align = byte_order->swap32( mach_section->align );
    result->reloff = byte_order->swap32( mach_section->reloff );
    result->nreloc = byte_order->swap32( mach_section->nreloc );
    result->flags = byte_order->swap32( mach_section->flags );
    result->reserved1 = byte_order->swap32( mach_section->reserved1 );
    result->reserved2 = byte_order->swap32( mach_section->reserved2 );
    
    return MK_ESUCCESS;
}

//|++++++++++++++++++++++++++++++++++++|//
size_t
mk_load_command_segment_section_copy_name(mk_load_command_section_t *section, char output[16])
{
    if (section == NULL) return UINT32_MAX;
    
    struct section *mach_section = (struct section*)section->mach_section;
    memcpy(output, mach_section->sectname, sizeof(mach_section->sectname));
    
    return sizeof(mach_section->sectname);
}

//|++++++++++++++++++++++++++++++++++++|//
size_t
mk_load_command_segment_section_copy_segment_name(mk_load_command_section_t *section, char output[16])
{
    if (section == NULL) return UINT32_MAX;
    
    struct section *mach_section = (struct section*)section->mach_section;
    memcpy(output, mach_section->segname, sizeof(mach_section->segname));
    
    return sizeof(mach_section->segname);
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
mk_load_command_segment_section_get_addr(mk_load_command_section_t *section)
{
    if (section == NULL) return UINT32_MAX;
    struct section *mach_section = (struct section*)section->mach_section;
    return mk_macho_get_byte_order(section->segment.load_command->image)->swap32( mach_section->addr );
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
mk_load_command_segment_section_get_size(mk_load_command_section_t *section)
{
    if (section == NULL) return UINT32_MAX;
    struct section *mach_section = (struct section*)section->mach_section;
    return mk_macho_get_byte_order(section->segment.load_command->image)->swap32( mach_section->size );
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
mk_load_command_segment_section_get_offset(mk_load_command_section_t *section)
{
    if (section == NULL) return UINT32_MAX;
    struct section *mach_section = (struct section*)section->mach_section;
    return mk_macho_get_byte_order(section->segment.load_command->image)->swap32( mach_section->offset );
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
mk_load_command_segment_section_get_align(mk_load_command_section_t *section)
{
    if (section == NULL) return UINT32_MAX;
    struct section *mach_section = (struct section*)section->mach_section;
    return mk_macho_get_byte_order(section->segment.load_command->image)->swap32( mach_section->align );
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
mk_load_command_segment_section_get_reloff(mk_load_command_section_t *section)
{
    if (section == NULL) return UINT32_MAX;
    struct section *mach_section = (struct section*)section->mach_section;
    return mk_macho_get_byte_order(section->segment.load_command->image)->swap32( mach_section->reloff );
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
mk_load_command_segment_section_get_nreloc(mk_load_command_section_t *section)
{
    if (section == NULL) return UINT32_MAX;
    struct section *mach_section = (struct section*)section->mach_section;
    return mk_macho_get_byte_order(section->segment.load_command->image)->swap32( mach_section->nreloc );
}

//|++++++++++++++++++++++++++++++++++++|//
uint8_t
mk_load_command_segment_section_get_type(mk_load_command_section_t *section)
{
    if (section == NULL) return UINT8_MAX;
    struct section *mach_section = (struct section*)section->mach_section;
    return mk_macho_get_byte_order(section->segment.load_command->image)->swap32( mach_section->flags ) & SECTION_TYPE;
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
mk_load_command_segment_section_get_attributes(mk_load_command_section_t *section)
{
    if (section == NULL) return UINT32_MAX;
    struct section *mach_section = (struct section*)section->mach_section;
    return mk_macho_get_byte_order(section->segment.load_command->image)->swap32( mach_section->flags ) & SECTION_ATTRIBUTES;
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
mk_load_command_segment_section_get_reserved1(mk_load_command_section_t *section)
{
    if (section == NULL) return UINT32_MAX;
    struct section *mach_section = (struct section*)section->mach_section;
    return mk_macho_get_byte_order(section->segment.load_command->image)->swap32( mach_section->reserved1 );
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
mk_load_command_segment_section_get_reserved2(mk_load_command_section_t *section)
{
    if (section == NULL) return UINT32_MAX;
    struct section *mach_section = (struct section*)section->mach_section;
    return mk_macho_get_byte_order(section->segment.load_command->image)->swap32( mach_section->reserved2 );
}
