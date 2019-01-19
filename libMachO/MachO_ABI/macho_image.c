//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             macho_image.c
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
#pragma mark -  Classes
//----------------------------------------------------------------------------//

//|++++++++++++++++++++++++++++++++++++|//
static mk_context_t*
__mk_macho_image_get_context(mk_macho_ref self)
{ return self.macho->context; }

const struct _mk_macho_image_vtable _mk_macho_image_class = {
    .base.super                 = &_mk_type_class,
    .base.name                  = "macho image",
    .base.get_context           = &__mk_macho_image_get_context
};

intptr_t mk_macho_image_type = (intptr_t)&_mk_macho_image_class;

//----------------------------------------------------------------------------//
#pragma mark -  Working With Mach-O Images
//----------------------------------------------------------------------------//

//|++++++++++++++++++++++++++++++++++++|//
mk_error_t
mk_macho_init(mk_context_t *ctx, const char *name, intptr_t slide, mk_vm_address_t header_addr, mk_memory_map_ref memory_map, mk_macho_t *image)
{
    if (image == NULL) return MK_EINVAL;
    if (name == NULL) return MK_EINVAL;
    if (memory_map.memory_map == NULL) return MK_EINVAL;
    
    // TODO - Support negative slides.
    if (slide < 0) {
        _mkl_debug(ctx, "Negative slide [%" PRIiPTR "] is not currently supported.", slide);
        return MK_EINVAL;
    }
    
    mk_error_t err;
    
    image->context = ctx;
    image->memory_map = memory_map;
    image->slide = slide;
    image->name = name;
    
    struct mach_header header;
    if (mk_memory_map_copy_bytes(memory_map, 0, header_addr, &header, sizeof(header), true, &err) < sizeof(header)) {
        _mkl_debug(ctx, "Failed to read the Mach-O header.");
        return err;
    }
    
    // Load the appropriate data model for the image
    switch (header.magic) {
        case MH_CIGAM:
        case MH_MAGIC:
            image->data_model = mk_data_model_ilp32();
            image->header_size = sizeof(struct mach_header);
            break;
        case MH_CIGAM_64:
        case MH_MAGIC_64:
            image->data_model = mk_data_model_lp64();
            image->header_size = sizeof(struct mach_header_64);
            break;
        default:
            _mkl_debug(ctx, "Bad Mach-O magic [0x%" PRIx32 "].", header.magic);
            return MK_EINVALID_DATA;
    }
    
    header.filetype = mk_data_model_get_byte_order(image->data_model)->swap32(header.filetype);
    header.sizeofcmds = mk_data_model_get_byte_order(image->data_model)->swap32(header.sizeofcmds);
    
    // Only support a subset of the MachO types at this time
    switch (header.filetype) {
        case MH_EXECUTE:
        case MH_DYLIB:
        case MH_BUNDLE:
            break;
        default:
            _mkl_debug(ctx, "Unsupported file type [%" PRIx32 "].", header.filetype);
            return MK_EINVAL;
    }
    
    // Map in the header + load commands.
    if (mk_memory_map_init_object(memory_map, 0, header_addr, (mk_vm_size_t)header.sizeofcmds + image->header_size, true, &image->header_mapping)) {
        _mkl_debug(ctx, "Failed to map Mach-O header.");
        return err;
    }
    
    image->header = (struct mach_header*)mk_memory_object_address(&image->header_mapping);
    
    // Verify the header is at the start of the mapping
    if (header.magic != image->header->magic) {
        _mkl_debug(ctx, "Mapped Mach-O header does not begin with expected magic value.");
        return MK_ECLIENT_INVALID_RESULT;
    }
    
    image->vtable = &_mk_macho_image_class;
    return MK_ESUCCESS;
}

//|++++++++++++++++++++++++++++++++++++|//
void mk_macho_free(mk_macho_ref image)
{
    mk_memory_map_free_object(image.macho->memory_map, &image.macho->header_mapping);
    image.macho->vtable = NULL;
    image.macho->context = NULL;
    image.macho->header = NULL;
}

//|++++++++++++++++++++++++++++++++++++|//
mk_memory_map_ref mk_macho_get_memory_map(mk_macho_ref image)
{ return image.macho->memory_map; }

//|++++++++++++++++++++++++++++++++++++|//
mk_memory_object_ref mk_macho_get_header_mapping(mk_macho_ref image)
{ return (mk_memory_object_ref)&image.macho->header_mapping; }

//|++++++++++++++++++++++++++++++++++++|//
mk_data_model_ref mk_macho_get_data_model(mk_macho_ref image)
{ return image.macho->data_model; }

//|++++++++++++++++++++++++++++++++++++|//
const mk_byteorder_t* mk_macho_get_byte_order(mk_macho_ref image)
{ return mk_data_model_get_byte_order(image.macho->data_model); }

//|++++++++++++++++++++++++++++++++++++|//
intptr_t mk_macho_get_slide(mk_macho_ref image)
{ return image.macho->slide; }

//|++++++++++++++++++++++++++++++++++++|//
const char* mk_macho_get_name(mk_macho_ref image)
{ return image.macho->name; }

//|++++++++++++++++++++++++++++++++++++|//
mk_vm_address_t mk_macho_get_address(mk_macho_ref image)
{ return mk_memory_object_target_address(&image.macho->header_mapping); }

//----------------------------------------------------------------------------//
#pragma mark -  Mach-O Header Values
//----------------------------------------------------------------------------//

//|++++++++++++++++++++++++++++++++++++|//
cpu_type_t mk_macho_get_cpu_type(mk_macho_ref image)
{ return (cpu_type_t)mk_macho_get_byte_order(image)->swap32( (uint32_t)image.macho->header->cputype ); }

//|++++++++++++++++++++++++++++++++++++|//
cpu_subtype_t mk_macho_get_cpu_subtype(mk_macho_ref image)
{ return (cpu_subtype_t)mk_macho_get_byte_order(image)->swap32( (uint32_t)image.macho->header->cpusubtype ); }

//|++++++++++++++++++++++++++++++++++++|//
uint32_t mk_macho_get_filetype(mk_macho_ref image)
{ return mk_macho_get_byte_order(image)->swap32( image.macho->header->filetype ); }

//|++++++++++++++++++++++++++++++++++++|//
uint32_t mk_macho_get_ncmds(mk_macho_ref image)
{ return mk_macho_get_byte_order(image)->swap32( image.macho->header->ncmds ); }

//|++++++++++++++++++++++++++++++++++++|//
uint32_t mk_macho_get_sizeofcmds(mk_macho_ref image)
{ return mk_macho_get_byte_order(image)->swap32( image.macho->header->sizeofcmds ); }

//|++++++++++++++++++++++++++++++++++++|//
uint32_t mk_macho_get_flags(mk_macho_ref image)
{ return mk_macho_get_byte_order(image)->swap32( image.macho->header->flags ); }

//|++++++++++++++++++++++++++++++++++++|//
bool mk_macho_is_64_bit(mk_macho_ref image)
{ return mk_macho_get_byte_order(image)->swap32( image.macho->header->magic ) == MH_MAGIC_64; }

//|++++++++++++++++++++++++++++++++++++|//
bool mk_macho_is_from_shared_cache(mk_macho_ref image)
{ return !!(mk_macho_get_flags(image) & 0x80000000); }

//----------------------------------------------------------------------------//
#pragma mark -  Enumerating Load Commands
//----------------------------------------------------------------------------//

//|++++++++++++++++++++++++++++++++++++|//
struct load_command*
mk_macho_next_command(mk_macho_ref image, struct load_command* previous, mk_vm_address_t* target_address)
{
    struct load_command *lc;
    
    if (previous == NULL)
    {
        if (mk_macho_get_ncmds(image) == 0)
            return NULL;
        
        // Sanity Check
        uint32_t sizeofcmds = mk_macho_get_sizeofcmds(image);
        if (sizeofcmds < sizeof(struct load_command)) {
            _mkl_debug(mk_type_get_context(image.type), "Mach-O header 'sizeofcmds' [%" PRIu32 "] is less than sizeof(struct load_command).", sizeofcmds);
            return NULL;
        }
        
        lc = (typeof(lc))( (uintptr_t)image.macho->header + image.macho->header_size );
    }
    else
    {
        // We need the size from the previous load command; first, verify the pointer.
        lc = previous;
        if (!mk_memory_object_verify_local_pointer(&image.macho->header_mapping, 0, (uintptr_t)lc, sizeof(*lc), NULL)) {
            char buffer[512] = { 0 };
            mk_type_copy_description(&image.macho->header_mapping, buffer, sizeof(buffer));
            _mkl_debug(mk_type_get_context(image.type), "Previous load command pointer [%p] is not within Mach-O header %s.", lc, buffer);
            return NULL;
        }
        
        // Advance to the next command
        lc = (typeof(lc))( (uintptr_t)previous + mk_macho_get_byte_order(image)->swap32(lc->cmdsize) );
    }
    
    // Avoid walking off the end of the load commands
    if ((uintptr_t)lc >= mk_memory_object_address(&image.macho->header_mapping) + image.macho->header_size + mk_macho_get_sizeofcmds(image))
        return NULL;
    
    // Verify that the header mapping holds at least the new load_command header
    if (!mk_memory_object_verify_local_pointer(&image.macho->header_mapping, 0, (uintptr_t)lc, sizeof(*lc), NULL)) {
        char buffer[512] = { 0 };
        mk_type_copy_description(&image.macho->header_mapping, buffer, sizeof(buffer));
        _mkl_debug(mk_type_get_context(image.type), "Failed to map load command at address [%p].  Pointer is not within Mach-O header %s.", lc, buffer);
        return NULL;
    }
    
    // Verify that the actual size
    if (!mk_memory_object_verify_local_pointer(&image.macho->header_mapping, 0, (uintptr_t)lc, mk_macho_get_byte_order(image)->swap32(lc->cmdsize), NULL)) {
        char buffer[512] = { 0 };
        mk_type_copy_description(&image.macho->header_mapping, buffer, sizeof(buffer));
        _mkl_debug(mk_type_get_context(image.type), "Failed to map load command at address [%p].  Part of the load command is not within Mach-O header %s.", lc, buffer);
        return NULL;
    }
    
    if (target_address)
    {
        mk_error_t err;
        *target_address = mk_memory_object_unmap_address(&image.macho->header_mapping, 0, (vm_address_t)lc, sizeof(*lc), &err);
        if (err != MK_ESUCCESS)
            return NULL;
    }
    
    return lc;
}

//|++++++++++++++++++++++++++++++++++++|//
#if __BLOCKS__
void mk_macho_enumerate_commands(mk_macho_ref image, void (^enumerator)(struct load_command* lc, uint32_t index, mk_vm_address_t target_address))
{
    struct load_command *lc = NULL;
    uint32_t index = 0;
    mk_vm_address_t target_address;
    
    while ((lc = mk_macho_next_command(image, lc, &target_address))) {
        enumerator(lc, index++, target_address);
    }
}
#endif

//|++++++++++++++++++++++++++++++++++++|//
struct load_command*
mk_macho_next_command_type(mk_macho_ref image, struct load_command* previous, uint32_t expected_command, mk_vm_address_t* target_address)
{
    struct load_command *lc = previous;
    
    // Iterate commands until we either find a match, or reach the end
    while ((lc = mk_macho_next_command(image, lc, target_address)) != NULL) {
        // Return a match
        if (mk_macho_get_byte_order(image)->swap32(lc->cmd) == expected_command) {
            return lc;
        }
    }
    
    // No match found
    return NULL;
}

//|++++++++++++++++++++++++++++++++++++|//
struct load_command* mk_macho_find_command(mk_macho_ref image, uint32_t expected_command, mk_vm_address_t* target_address)
{ return mk_macho_next_command_type(image, NULL, expected_command, target_address); }

//|++++++++++++++++++++++++++++++++++++|//
struct load_command* mk_macho_last_command_type(mk_macho_ref image, uint32_t expected_command, mk_vm_address_t* target_address)
{
    struct load_command *lc = NULL;
    struct load_command *next = NULL;
    
    while ((next = mk_macho_next_command_type(image, lc, expected_command, target_address)) != NULL) {
        lc = next;
    }
    
    return lc;
}

