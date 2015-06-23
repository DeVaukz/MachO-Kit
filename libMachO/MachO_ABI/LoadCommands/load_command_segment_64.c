//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             load_command_segment_64.c
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
_mk_load_command_segment_64_copy_description(mk_load_command_ref load_command, char *output, size_t output_len)
{
    char buffer[17] = { 0 };
    mk_load_command_segment_64_copy_name(load_command, buffer);
    
    return (size_t)snprintf(output, output_len, "<%s %p> {\n\
\tsegname = %s\n\
\tvmaddr = 0x%" PRIx64 "\n\
\tvmsize = %" PRIu64 "\n\
\tfileoff = %" PRIu64 "\n\
\tfilesize = %" PRIu64 "\n\
\tmaxprot = 0x%X\n\
\tinitprot = 0x%X\n\
\tnsects = %" PRIu32 "\n\
}",
                            mk_type_name(load_command.type), load_command.type, buffer,
                            mk_load_command_segment_64_get_vmaddr(load_command),
                            mk_load_command_segment_64_get_vmsize(load_command),
                            mk_load_command_segment_64_get_fileoff(load_command),
                            mk_load_command_segment_64_get_filesize(load_command),
                            mk_load_command_segment_64_get_maxprot(load_command),
                            mk_load_command_segment_64_get_initprot(load_command),
                            mk_load_command_segment_64_get_nsects(load_command));
}

const struct _mk_load_command_vtable _mk_load_command_segment_64_class = {
    .base.super                 = &_mk_load_command_class,
    .base.name                  = "LC_SEGMENT_64",
    .base.copy_description      = &_mk_load_command_segment_64_copy_description,
    .command_id                 = LC_SEGMENT_64
};

//|++++++++++++++++++++++++++++++++++++|//
uint32_t mk_load_command_segment_64_id()
{ return LC_SEGMENT_64; }

//|++++++++++++++++++++++++++++++++++++|//
mk_error_t
mk_load_command_segment_64_copy_native(mk_load_command_ref load_command, struct segment_command_64 *result)
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return MK_EINVAL);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_segment_64_class, return MK_EINVAL);
    if (result == NULL) return MK_EINVAL;
    
    const mk_byteorder_t * const byte_order = mk_macho_get_byte_order(load_command.load_command->image);
    struct segment_command_64 *mach_segment_command = (struct segment_command_64*)load_command.load_command->mach_load_command;
    
    result->cmd = byte_order->swap32( mach_segment_command->cmd );
    result->cmdsize = byte_order->swap32( mach_segment_command->cmdsize );
    memcpy(result->segname, mach_segment_command->segname, sizeof(result->segname));
    result->vmaddr = byte_order->swap64( mach_segment_command->vmaddr );
    result->vmsize = byte_order->swap64( mach_segment_command->vmsize );
    result->fileoff = byte_order->swap64( mach_segment_command->fileoff );
    result->filesize = byte_order->swap64( mach_segment_command->filesize );
    result->maxprot = (vm_prot_t)byte_order->swap32( (uint32_t)mach_segment_command->maxprot );
    result->initprot = (vm_prot_t)byte_order->swap32( (uint32_t)mach_segment_command->initprot );
    result->nsects = byte_order->swap32( mach_segment_command->nsects );
    result->flags = byte_order->swap32( mach_segment_command->flags );
    
    return MK_ESUCCESS;
}

//|++++++++++++++++++++++++++++++++++++|//
size_t
mk_load_command_segment_64_copy_name(mk_load_command_ref load_command, char output[16])
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return 0);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_segment_64_class, return 0);
    
    struct segment_command_64 *mach_segment_command = (struct segment_command_64*)load_command.load_command->mach_load_command;
    memcpy(output, mach_segment_command->segname, sizeof(mach_segment_command->segname));
    
    return sizeof(mach_segment_command->segname);
}

//|++++++++++++++++++++++++++++++++++++|//
uint64_t
mk_load_command_segment_64_get_vmaddr(mk_load_command_ref load_command)
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return UINT64_MAX);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_segment_64_class, return UINT64_MAX);
    struct segment_command_64 *mach_segment_command = (struct segment_command_64*)load_command.load_command->mach_load_command;
    return mk_macho_get_byte_order(load_command.load_command->image)->swap64( mach_segment_command->vmaddr );
}

//|++++++++++++++++++++++++++++++++++++|//
uint64_t
mk_load_command_segment_64_get_vmsize(mk_load_command_ref load_command)
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return UINT64_MAX);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_segment_64_class, return UINT64_MAX);
    struct segment_command_64 *mach_segment_command = (struct segment_command_64*)load_command.load_command->mach_load_command;
    return mk_macho_get_byte_order(load_command.load_command->image)->swap64( mach_segment_command->vmsize );
}

//|++++++++++++++++++++++++++++++++++++|//
uint64_t
mk_load_command_segment_64_get_fileoff(mk_load_command_ref load_command)
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return UINT64_MAX);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_segment_64_class, return UINT64_MAX);
    struct segment_command_64 *mach_segment_command = (struct segment_command_64*)load_command.load_command->mach_load_command;
    return mk_macho_get_byte_order(load_command.load_command->image)->swap64( mach_segment_command->fileoff );
}

//|++++++++++++++++++++++++++++++++++++|//
uint64_t
mk_load_command_segment_64_get_filesize(mk_load_command_ref load_command)
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return UINT64_MAX);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_segment_64_class, return UINT64_MAX);
    struct segment_command_64 *mach_segment_command = (struct segment_command_64*)load_command.load_command->mach_load_command;
    return mk_macho_get_byte_order(load_command.load_command->image)->swap64( mach_segment_command->filesize );
}

//|++++++++++++++++++++++++++++++++++++|//
vm_prot_t
mk_load_command_segment_64_get_maxprot(mk_load_command_ref load_command)
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return INT_MAX);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_segment_64_class, return INT_MAX);
    struct segment_command_64 *mach_segment_command = (struct segment_command_64*)load_command.load_command->mach_load_command;
    return (vm_prot_t)mk_macho_get_byte_order(load_command.load_command->image)->swap32( (uint32_t)mach_segment_command->maxprot );
}

//|++++++++++++++++++++++++++++++++++++|//
vm_prot_t
mk_load_command_segment_64_get_initprot(mk_load_command_ref load_command)
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return INT_MAX);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_segment_64_class, return INT_MAX);
    struct segment_command_64 *mach_segment_command = (struct segment_command_64*)load_command.load_command->mach_load_command;
    return (vm_prot_t)mk_macho_get_byte_order(load_command.load_command->image)->swap32( (uint32_t)mach_segment_command->initprot );
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
mk_load_command_segment_64_get_nsects(mk_load_command_ref load_command)
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return UINT32_MAX);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_segment_64_class, return UINT32_MAX);
    struct segment_command_64 *mach_segment_command = (struct segment_command_64*)load_command.load_command->mach_load_command;
    return mk_macho_get_byte_order(load_command.load_command->image)->swap32( mach_segment_command->nsects );
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
mk_load_command_segment_64_get_flags(mk_load_command_ref load_command)
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return UINT32_MAX);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_segment_64_class, return UINT32_MAX);
    struct segment_command_64 *mach_segment_command = (struct segment_command_64*)load_command.load_command->mach_load_command;
    return mk_macho_get_byte_order(load_command.load_command->image)->swap32( mach_segment_command->flags );
}

//|++++++++++++++++++++++++++++++++++++|//
struct section_64*
mk_load_command_segment_64_next_section(mk_load_command_ref load_command, struct section_64 *previous, mk_vm_address_t *context_address)
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return NULL);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_segment_64_class, return NULL);
    
    struct section_64 *sec;
    
    if (previous == NULL)
    {
        if (mk_load_command_segment_64_get_nsects(load_command) == 0)
            return NULL;
        
        // Sanity Check
        if (mk_load_command_size(load_command) < sizeof(struct segment_command_64) + sizeof(struct section_64)) {
            _mkl_debug(mk_type_get_context(load_command.type), "Mach-O segment load command is less than sizeof(struct section_64) in %s", load_command.load_command->image.macho->name);
            return NULL;
        }
        
        sec = (typeof(sec))( (uint8_t*)load_command.load_command->mach_load_command + sizeof(struct segment_command_64) );
    }
    else
    {
        // We need the size from the previous section; first, verify the pointer.
        sec = previous;
        if (!mk_memory_object_verify_local_pointer(&load_command.load_command->image.macho->header_mapping, 0, (vm_address_t)sec, sizeof(*sec), NULL))
        {
            _mkl_debug(mk_type_get_context(load_command.type), "Failed to map section at address %p in: %s", sec, load_command.load_command->image.macho->name);
            return NULL;
        }
        
        sec = (typeof(sec))( ((uint8_t *)previous) + sizeof(struct section_64) );
    }
    
    // Avoid walking off the end of the segment command
    if ((uintptr_t)sec >= (uintptr_t)load_command.load_command->mach_load_command + mk_load_command_size(load_command))
        return NULL;
    
    // Verify that the header mapping holds the new section
    if (!mk_memory_object_verify_local_pointer(&load_command.load_command->image.macho->header_mapping, 0, (vm_address_t)sec, sizeof(*sec), NULL)) {
        _mkl_debug(mk_type_get_context(load_command.type), "Failed to map section command at address %p in: %s", sec, load_command.load_command->image.macho->name);
        return NULL;
    }
    
    if (context_address)
    {
        mk_error_t err;
        *context_address = mk_memory_object_unmap_address(&load_command.load_command->image.macho->header_mapping, 0, (vm_address_t)sec, sizeof(*sec), &err);
        if (err != MK_ESUCCESS)
            return NULL;
    }
    
    return sec;
}

//|++++++++++++++++++++++++++++++++++++|//
#if __BLOCKS__
void
mk_load_command_segment_64_enumerate_sections(mk_load_command_ref load_command, void (^enumerator)(struct section_64 *command, uint32_t index, mk_vm_address_t context_address))
{
    struct section_64 *sec = NULL;
    uint32_t index = 0;
    mk_vm_address_t context_address;
    
    while ((sec = mk_load_command_segment_64_next_section(load_command, sec, &context_address))) {
        enumerator(sec, index++, context_address);
    }
}
#endif

//----------------------------------------------------------------------------//
#pragma mark -  Section
//----------------------------------------------------------------------------//

//|++++++++++++++++++++++++++++++++++++|//
mk_error_t
mk_load_command_segment_64_section_init(mk_load_command_ref segment, struct section_64 *sec, mk_load_command_section_64_t *section)
{
    if (!segment.type) return MK_EINVAL;
    if (!sec) return MK_EINVAL;
    if (!section) return MK_EINVAL;
    
    if (!mk_memory_object_verify_local_pointer(&segment.load_command->image.macho->header_mapping, 0, (vm_address_t)sec, sizeof(*sec), NULL)) {
        _mkl_debug(mk_type_get_context(segment.type), "Header mapping does not entirely contain section for image %s", segment.load_command->image.macho->name);
        return MK_EINVALID_DATA;
    }
    
    section->segment = segment;
    section->mach_section = sec;
    
    return MK_ESUCCESS;
}

//|++++++++++++++++++++++++++++++++++++|//
mk_error_t
mk_load_command_segment_64_section_copy_native(mk_load_command_section_64_t *section, struct section_64 *result)
{
    if (section == NULL) return MK_EINVAL;
    if (result == NULL) return MK_EINVAL;
    
    const mk_byteorder_t * const byte_order = mk_macho_get_byte_order(section->segment.load_command->image);
    struct section_64 *mach_section = (struct section_64*)section->mach_section;
    
    memcpy(result->sectname, mach_section->sectname, sizeof(mach_section->sectname));
    memcpy(result->segname, mach_section->segname, sizeof(mach_section->segname));
    result->addr = byte_order->swap64( mach_section->addr );
    result->size = byte_order->swap64( mach_section->size );
    result->offset = byte_order->swap32( mach_section->offset );
    result->align = byte_order->swap32( mach_section->align );
    result->reloff = byte_order->swap32( mach_section->reloff );
    result->nreloc = byte_order->swap32( mach_section->nreloc );
    result->flags = byte_order->swap32( mach_section->flags );
    result->reserved1 = byte_order->swap32( mach_section->reserved1 );
    result->reserved2 = byte_order->swap32( mach_section->reserved2 );
    result->reserved3 = byte_order->swap32( mach_section->reserved3 );
    
    return MK_ESUCCESS;
}

//|++++++++++++++++++++++++++++++++++++|//
size_t
mk_load_command_segment_64_section_copy_name(mk_load_command_section_64_t *section, char output[16])
{
    if (section == NULL) return 0;
    
    struct section_64 *mach_section = (struct section_64*)section->mach_section;
    memcpy(output, mach_section->sectname, sizeof(mach_section->sectname));
    
    return sizeof(mach_section->sectname);
}

//|++++++++++++++++++++++++++++++++++++|//
size_t
mk_load_command_segment_64_section_copy_segment_name(mk_load_command_section_64_t *section, char output[16])
{
    if (section == NULL) return 0;
    
    struct section_64 *mach_section = (struct section_64*)section->mach_section;
    memcpy(output, mach_section->segname, sizeof(mach_section->segname));
    
    return sizeof(mach_section->segname);
}

//|++++++++++++++++++++++++++++++++++++|//
uint64_t
mk_load_command_segment_64_section_get_addr(mk_load_command_section_64_t *section)
{
    if (section == NULL) return UINT64_MAX;
    struct section_64 *mach_section = (struct section_64*)section->mach_section;
    return mk_macho_get_byte_order(section->segment.load_command->image)->swap64( mach_section->addr );
}

//|++++++++++++++++++++++++++++++++++++|//
uint64_t
mk_load_command_segment_64_section_get_size(mk_load_command_section_64_t *section)
{
    if (section == NULL) return UINT64_MAX;
    struct section_64 *mach_section = (struct section_64*)section->mach_section;
    return mk_macho_get_byte_order(section->segment.load_command->image)->swap64( mach_section->size );
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
mk_load_command_segment_64_section_get_offset(mk_load_command_section_64_t *section)
{
    if (section == NULL) return UINT32_MAX;
    struct section_64 *mach_section = (struct section_64*)section->mach_section;
    return mk_macho_get_byte_order(section->segment.load_command->image)->swap32( mach_section->offset );
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
mk_load_command_segment_64_section_get_align(mk_load_command_section_64_t *section)
{
    if (section == NULL) return UINT32_MAX;
    struct section_64 *mach_section = (struct section_64*)section->mach_section;
    return mk_macho_get_byte_order(section->segment.load_command->image)->swap32( mach_section->align );
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
mk_load_command_segment_64_section_get_reloff(mk_load_command_section_64_t *section)
{
    if (section == NULL) return UINT32_MAX;
    struct section_64 *mach_section = (struct section_64*)section->mach_section;
    return mk_macho_get_byte_order(section->segment.load_command->image)->swap32( mach_section->reloff );
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
mk_load_command_segment_64_section_get_nreloc(mk_load_command_section_64_t *section)
{
    if (section == NULL) return UINT32_MAX;
    struct section_64 *mach_section = (struct section_64*)section->mach_section;
    return mk_macho_get_byte_order(section->segment.load_command->image)->swap32( mach_section->nreloc );
}

//|++++++++++++++++++++++++++++++++++++|//
uint8_t
mk_load_command_segment_64_section_get_type(mk_load_command_section_64_t *section)
{
    if (section == NULL) return UINT8_MAX;
    struct section_64 *mach_section = (struct section_64*)section->mach_section;
    return mk_macho_get_byte_order(section->segment.load_command->image)->swap32( mach_section->flags ) & SECTION_TYPE;
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
mk_load_command_segment_64_section_get_attributes(mk_load_command_section_64_t *section)
{
    if (section == NULL) return UINT32_MAX;
    struct section_64 *mach_section = (struct section_64*)section->mach_section;
    return mk_macho_get_byte_order(section->segment.load_command->image)->swap32( mach_section->flags ) & SECTION_ATTRIBUTES;
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
mk_load_command_segment_64_section_get_reserved1(mk_load_command_section_64_t *section)
{
    if (section == NULL) return UINT32_MAX;
    struct section_64 *mach_section = (struct section_64*)section->mach_section;
    return mk_macho_get_byte_order(section->segment.load_command->image)->swap32( mach_section->reserved1 );
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
mk_load_command_segment_64_section_get_reserved2(mk_load_command_section_64_t *section)
{
    if (section == NULL) return UINT32_MAX;
    struct section_64 *mach_section = (struct section_64*)section->mach_section;
    return mk_macho_get_byte_order(section->segment.load_command->image)->swap32( mach_section->reserved2 );
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
mk_load_command_segment_64_section_get_reserved3(mk_load_command_section_64_t *section)
{
    if (section == NULL) return UINT32_MAX;
    struct section_64 *mach_section = (struct section_64*)section->mach_section;
    return mk_macho_get_byte_order(section->segment.load_command->image)->swap32( mach_section->reserved3 );
}
