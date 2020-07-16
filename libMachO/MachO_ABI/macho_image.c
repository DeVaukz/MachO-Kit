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
mk_macho_init_with_slide(mk_context_t *ctx, const char *name, mk_vm_slide_t slide, mk_vm_address_t address, mk_memory_map_ref memory_map, mk_macho_t *image)
{
    if (image == NULL) return MK_EINVAL;
    if (name == NULL) return MK_EINVAL;
    if (memory_map.memory_map == NULL) return MK_EINVAL;
    
    // TODO - Support negative slides.
    if (slide < 0) {
        _mkl_debug(ctx, "Negative slide [%" MK_VM_PRIiSLIDE "] is not currently supported.", slide);
        return MK_EINVAL;
    }
    
    mk_error_t err;
    
    image->context = ctx;
    image->memory_map = memory_map;
    image->slide = slide;
    image->name = name;
    
    struct mach_header header;
    if (mk_memory_map_copy_bytes(memory_map, 0, address, &header, sizeof(header), true, &err) < sizeof(header)) {
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
        case MH_DYLINKER:
        case MH_BUNDLE:
            break;
        default:
            _mkl_debug(ctx, "Unsupported file type [%" PRIx32 "].", header.filetype);
            return MK_EINVAL;
    }
    
    // Map in the header + load commands.
    if (mk_memory_map_init_object(memory_map, 0, address, (mk_vm_size_t)header.sizeofcmds + image->header_size, true, &image->header_mapping)) {
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
mk_error_t
mk_macho_init(mk_context_t *ctx, const char *name, mk_vm_address_t address, mk_memory_map_ref memory_map, mk_macho_t *image)
{
    mk_error_t err;
    
    err = mk_macho_init_with_slide(ctx, name, 0, address, memory_map, image);
    if (err != MK_ESUCCESS)
        return err;
    
    // dyld has two approaches to computing the image slide.
    //
    // In dyld2 mode, when mapping an image that requires sliding
    // ImageLoaderMachO::assignSegmentAddresses() computes the slide as
    // the difference between the start of the mapping for the first sgement
    // and the preferred load address of the first segment (that is, the value
    // in the 'vmaddr' field of the segment load command).  Here,
    // 'first segment' refers to the segment with the lowest preferred load
    // address.
    //
    // NOTE: This approach is not used for determining the slide of the main
    // executable.  The executable's slide is provided to dyld by the kernel.
    //
    // Another approach, implemented in both ImageLoaderMachO::computeSlide()
    // (for dyld2) and MachOLoaded::getSlide() (for dyld3), computes the slide
    // as the difference between the load address of the image (i.e, the address
    // of the Mach-O header) and the preferred load address of the first segment
    // with the name '__TEXT' that appears in the list of load commands.
    //
    // The slide value returned by _dyld_get_image_vmaddr_slide() is
    // computed using the second approach in both dyld2 and dyld3 mode.
    //
    // The 'side' argument passed to a callback registered with
    // _dyld_register_func_for_add_image() is computed using the first approach
    // in dyld2 mode and the second approach in dyld3 mode.
    //
    // The first approach will be used to determine the slide here.
    const uint32_t SEGMENT_COMMAND = mk_macho_is_64_bit(image) ? LC_SEGMENT_64 : LC_SEGMENT;
    mk_vm_address_t low_address = (mk_vm_address_t)(-1);
    struct load_command *lc = NULL;
    
    while ((lc = mk_macho_next_command_type(image, lc, SEGMENT_COMMAND, NULL)) != NULL) {
        mk_load_command_t load_command;
        
        if ((err = mk_load_command_init(image, (struct load_command*)lc, &load_command)))
            goto slide_fail;
        
        mk_vm_address_t segment_vmaddr;
        mk_vm_size_t segment_vmsize;
        mk_vm_size_t segment_filesize;
        
        if (mk_macho_is_64_bit(image)) {
            segment_vmaddr = mk_load_command_segment_64_get_vmaddr(&load_command);
            segment_vmsize = mk_load_command_segment_64_get_vmsize(&load_command);
            segment_filesize = mk_load_command_segment_64_get_filesize(&load_command);
            // Sanity check
            if (segment_vmaddr == UINT64_MAX || segment_vmsize == UINT64_MAX || segment_filesize == UINT64_MAX)
                goto slide_fail;
        } else {
            segment_vmaddr = mk_load_command_segment_get_vmaddr(&load_command);
            segment_vmsize = mk_load_command_segment_get_vmsize(&load_command);
            segment_filesize = mk_load_command_segment_get_filesize(&load_command);
            // Sanity check
            if (segment_vmaddr == UINT32_MAX || segment_vmsize == UINT32_MAX || segment_filesize == UINT32_MAX)
                goto slide_fail;
        }
        
        // We need to one additional check to skip the first zero-fill segment
        // that is not present on disk (__PAGEZERO).  dyld does not skip
        // this segment when determining the first segment, but it should never
        // appear in a library (xnu maps the main executable's segments and
        // tells dyld what their slide is).  It is not clear if dyld would
        // accept a library or bundle image containing a __PAGEZERO segment,
        // and what the affect would be on the computation of that image's slide
        // (TODO).
        if (segment_vmaddr == 0 && segment_vmsize != 0 && segment_filesize == 0)
            continue;
        
        if (segment_vmaddr < low_address)
            low_address = segment_vmaddr;
    }
    
    // This assumes that the Mach-O header (the image's load address) is at the
    // start of the first mapped segment.  It is not clear whether it would be
    // possible to craft a Mach-O that violates this assumption but would still
    // be accepted by xnu/dyld (TODO).
    mk_vm_slide_t slide;
    if ((err = mk_vm_address_difference(address, low_address, &slide)))
        goto slide_fail;
    
    image->slide = slide;
    
    return MK_ESUCCESS;
    
slide_fail:
    mk_macho_free(image);
    return MK_EDERIVED;
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
mk_vm_slide_t mk_macho_get_slide(mk_macho_ref image)
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
{ return !!(mk_macho_get_flags(image) & MH_DYLIB_IN_CACHE); }

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

