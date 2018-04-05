//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             segment.c
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
__mk_segment_get_context(mk_segment_ref self)
{ return mk_type_get_context( &self.segment->command ); }

//|++++++++++++++++++++++++++++++++++++|//
static size_t
__mk_segment_copy_description(mk_segment_ref self, char *output, size_t output_len)
{
    return (size_t)snprintf(output, output_len, "<%s %p; target_address = %" MK_VM_PRIxADDR ", vmAddress = %" MK_VM_PRIxADDR ", vmSize = %" MK_VM_PRIxSIZE ">",
                            mk_type_name(self.type), self.type,
                            mk_segment_get_target_range(self).location,
                            mk_segment_get_vmaddr(self), mk_segment_get_vmsize(self));
}

const struct _mk_segment_vtable _mk_segment_class = {
    .base.super                 = &_mk_type_class,
    .base.name                  = "segment",
    .base.get_context           = &__mk_segment_get_context,
    .base.copy_description      = &__mk_segment_copy_description
};

intptr_t mk_segment_type = (intptr_t)&_mk_segment_class;

//----------------------------------------------------------------------------//
#pragma mark -  Working With Segments
//----------------------------------------------------------------------------//

//|++++++++++++++++++++++++++++++++++++|//
mk_error_t
mk_segment_init(mk_load_command_ref load_command, mk_segment_t* segment)
{
    if (segment == NULL) return MK_EINVAL;
    if (load_command.load_command == NULL) return MK_EINVAL;
    
    mk_error_t err;
    mk_macho_ref image = mk_load_command_get_macho(load_command);
    
    mk_vm_address_t vm_address;
    mk_vm_size_t vm_size;
    char seg_name[17] = { 0 };
    
    if (mk_load_command_id(load_command) == mk_load_command_segment_64_id()) {
        vm_address = mk_load_command_segment_64_get_vmaddr(load_command);
        vm_size = mk_load_command_segment_64_get_vmsize(load_command);
        mk_load_command_segment_64_copy_name(load_command, seg_name);
    } else if (mk_load_command_id(load_command) == mk_load_command_segment_id()) {
        vm_address = mk_load_command_segment_get_vmaddr(load_command);
        vm_size = mk_load_command_segment_get_vmsize(load_command);
        mk_load_command_segment_copy_name(load_command, seg_name);
    } else {
        _mkl_debug(mk_type_get_context(image.type), "Unsupported load command type [%s].", mk_type_name(load_command.type));
        return MK_EINVAL;
    }
    
    // Slide the vmAddress
    {
        mk_vm_slide_t slide = (mk_vm_slide_t)mk_macho_get_slide(image);
        
        if ((err = mk_vm_address_apply_slide(vm_address, slide, &vm_address))) {
            _mkl_debug(mk_type_get_context(image.type), "Arithmetic error [%s] applying slide [%" MK_VM_PRIiSLIDE "] to segment VM address [0x%" MK_VM_PRIxADDR "].", mk_error_string(err), slide, vm_address);
            return err;
        }
    }
    
    // __PAGEZERO in a 64-bit process can not be mapped.  The kernel sets the
    // start of the process vm map to be just after it.
    if (!strncmp(seg_name, SEG_PAGEZERO, sizeof(seg_name)))
        return MK_EUNAVAILABLE;
    
    // Due to a bug in update_dyld_shared_cache(1), the segment vmsize defined
    // in the Mach-O load commands may be invalid, and the declared size may
    // be unmappable.  This bug appears to be caused by a bug in computing the
    // correct vmsize when update_dyld_shared_cache(1) generates the single
    // shared LINKEDIT segment.  Landon F. has reported this bug to Apple
    // as rdar://13707406.
    bool allowShortMappings = false;
    if (mk_macho_is_from_shared_cache(image) && !strncmp(seg_name, SEG_LINKEDIT, sizeof(seg_name)))
        allowShortMappings = true;
    
    // Create a memory object for accessing the segment.  This will also check
    // vmAddress + vmSize for potential overflow.
    if ((err = mk_memory_map_init_object(mk_macho_get_memory_map(image), 0, vm_address, vm_size, !allowShortMappings, &segment->memory_object))) {
        _mkl_debug(mk_type_get_context(image.type), "Failed to map segment [%s] (target_address = 0x%" MK_VM_PRIxADDR ", size = 0x%" MK_VM_PRIxSIZE ").", seg_name, vm_address, vm_size);
        return err;
    }
    
    segment->vtable = &_mk_segment_class;
    mk_load_command_copy(load_command, &segment->command);
    
    return MK_ESUCCESS;
}

//|++++++++++++++++++++++++++++++++++++|//
mk_error_t
mk_segment_init_with_mach_load_command(mk_macho_ref image, mk_macho_segment_load_command_ptr lc, mk_segment_t* segment)
{
    mk_error_t err;
    mk_load_command_t load_command;
    
    if ((err = mk_load_command_init(image, lc.any, &load_command)))
        return err;
    
    return mk_segment_init(&load_command, segment);
}

//|++++++++++++++++++++++++++++++++++++|//
void
mk_segment_free(mk_segment_ref segment)
{
    mk_memory_object_free(&segment.segment->memory_object);
    segment.segment->vtable = NULL;
}

//|++++++++++++++++++++++++++++++++++++|//
mk_macho_ref mk_segment_get_macho(mk_segment_ref segment)
{ return mk_load_command_get_macho(&segment.segment->command); }

//|++++++++++++++++++++++++++++++++++++|//
mk_load_command_ref mk_segment_get_load_command(mk_segment_ref segment)
{ return (mk_load_command_ref)&segment.segment->command; }

//|++++++++++++++++++++++++++++++++++++|//
mk_vm_range_t mk_segment_get_target_range(mk_segment_ref segment)
{
    intptr_t slide = mk_macho_get_slide(mk_segment_get_macho(segment));
    // Safely applying the slide to addr was checked in the initializer.
    return mk_vm_range_make(mk_segment_get_vmaddr(segment) + (vm_offset_t)slide, mk_segment_get_vmsize(segment));
}

//|++++++++++++++++++++++++++++++++++++|//
mk_memory_object_ref mk_segment_get_mapping(mk_segment_ref segment)
{ return (mk_memory_object_ref)&segment.segment->memory_object; }

//----------------------------------------------------------------------------//
#pragma mark -  Segment Values
//----------------------------------------------------------------------------//

//|++++++++++++++++++++++++++++++++++++|//
size_t
mk_segment_copy_name(mk_segment_ref segment, char output[16])
{
    if (mk_load_command_id(&segment.segment->command) == mk_load_command_segment_64_id())
        return mk_load_command_segment_64_copy_name(&segment.segment->command, output);
    else
        return mk_load_command_segment_copy_name(&segment.segment->command, output);
}

//|++++++++++++++++++++++++++++++++++++|//
mk_vm_address_t
mk_segment_get_vmaddr(mk_segment_ref segment)
{
    if (mk_load_command_id(&segment.segment->command) == mk_load_command_segment_64_id())
        return mk_load_command_segment_64_get_vmaddr(&segment.segment->command);
    else
        return mk_load_command_segment_get_vmaddr(&segment.segment->command);
}

//|++++++++++++++++++++++++++++++++++++|//
mk_vm_size_t
mk_segment_get_vmsize(mk_segment_ref segment)
{
    if (mk_load_command_id(&segment.segment->command) == mk_load_command_segment_64_id())
        return mk_load_command_segment_64_get_vmsize(&segment.segment->command);
    else
        return mk_load_command_segment_get_vmsize(&segment.segment->command);
}

//|++++++++++++++++++++++++++++++++++++|//
mk_vm_address_t
mk_segment_get_fileoff(mk_segment_ref segment)
{
    if (mk_load_command_id(&segment.segment->command) == mk_load_command_segment_64_id())
        return mk_load_command_segment_64_get_fileoff(&segment.segment->command);
    else
        return mk_load_command_segment_get_fileoff(&segment.segment->command);
}

//|++++++++++++++++++++++++++++++++++++|//
mk_vm_size_t
mk_segment_get_filesize(mk_segment_ref segment)
{
    if (mk_load_command_id(&segment.segment->command) == mk_load_command_segment_64_id())
        return mk_load_command_segment_64_get_filesize(&segment.segment->command);
    else
        return mk_load_command_segment_get_filesize(&segment.segment->command);
}

//|++++++++++++++++++++++++++++++++++++|//
vm_prot_t
mk_segment_get_maxprot(mk_segment_ref segment)
{
    if (mk_load_command_id(&segment.segment->command) == mk_load_command_segment_64_id())
        return mk_load_command_segment_64_get_maxprot(&segment.segment->command);
    else
        return mk_load_command_segment_get_maxprot(&segment.segment->command);
}

//|++++++++++++++++++++++++++++++++++++|//
vm_prot_t
mk_segment_get_initprot(mk_segment_ref segment)
{
    if (mk_load_command_id(&segment.segment->command) == mk_load_command_segment_64_id())
        return mk_load_command_segment_64_get_initprot(&segment.segment->command);
    else
        return mk_load_command_segment_get_initprot(&segment.segment->command);
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
mk_segment_get_nsects(mk_segment_ref segment)
{
    if (mk_load_command_id(&segment.segment->command) == mk_load_command_segment_64_id())
        return mk_load_command_segment_64_get_nsects(&segment.segment->command);
    else
        return mk_load_command_segment_get_nsects(&segment.segment->command);
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
mk_segment_get_flags(mk_segment_ref segment)
{
    if (mk_load_command_id(&segment.segment->command) == mk_load_command_segment_64_id())
        return mk_load_command_segment_64_get_flags(&segment.segment->command);
    else
        return mk_load_command_segment_get_flags(&segment.segment->command);
}

//----------------------------------------------------------------------------//
#pragma mark -  Enumerating Sections
//----------------------------------------------------------------------------//

//|++++++++++++++++++++++++++++++++++++|//
mk_macho_section_command_ptr
mk_segment_next_section(mk_segment_ref segment, mk_macho_section_command_ptr previous, mk_vm_address_t* host_address)
{
    mk_macho_section_command_ptr cmd;
    
    if (mk_load_command_id(&segment.segment->command) == mk_load_command_segment_64_id())
        cmd.section_64 = mk_load_command_segment_64_next_section(&segment.segment->command, previous.section_64, host_address);
    else
        cmd.section = mk_load_command_segment_next_section(&segment.segment->command, previous.section, host_address);
    
    return cmd;
}

//|++++++++++++++++++++++++++++++++++++|//
#if __BLOCKS__
void
mk_segment_enumerate_sections(mk_segment_ref segment, void (^enumerator)(mk_macho_section_command_ptr section, uint32_t index))
{
    mk_macho_section_command_ptr section; section.any = NULL;
    uint32_t i = 0;
    while ((section = mk_segment_next_section(segment, section, NULL)).any) {
        enumerator(section, i++);
    }
}
#endif

