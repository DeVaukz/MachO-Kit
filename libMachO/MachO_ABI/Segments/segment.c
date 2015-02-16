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
__mk_segment_get_context(mk_type_ref self)
{ return mk_type_get_context( &((mk_segment_t*)self)->segment_load_command ); }

const struct _mk_segment_vtable _mk_segment_class = {
    .base.super                 = &_mk_type_class,
    .base.name                  = "segment",
    .base.get_context           = &__mk_segment_get_context
};

//----------------------------------------------------------------------------//
#pragma mark -  Working With Segments
//----------------------------------------------------------------------------//

//|++++++++++++++++++++++++++++++++++++|//
mk_error_t
mk_segment_init(mk_load_command_ref load_command, mk_segment_t* segment)
{
    if (segment == NULL) return MK_EINVAL;
    if (load_command.type == NULL) return MK_EINVAL;
    
    mk_error_t err;
    
    if (mk_load_command_id(load_command) != mk_load_command_segment_id() && mk_load_command_id(load_command) != mk_load_command_segment_64_id()) {
        _mkl_error(mk_type_get_context(load_command.type), "The load_command used to initialize an mk_segment must be one of LC_SEGMENT or LC_SEGMENT64, got %s", mk_type_name(load_command.type));
        return MK_EINVAL;
    }
    
    mk_macho_ref image = mk_load_command_get_macho(load_command);
    
    mk_vm_address_t vm_address;
    mk_vm_size_t vm_size;
    char seg_name[17] = {0x0};
    
    if (mk_load_command_id(load_command) == mk_load_command_segment_64_id()) {
        vm_address = mk_load_command_segment_64_get_vmaddr(load_command);
        vm_size = mk_load_command_segment_64_get_vmsize(load_command);
        mk_load_command_segment_64_copy_name(load_command, seg_name);
    } else {
        vm_address = mk_load_command_segment_get_vmaddr(load_command);
        vm_size = mk_load_command_segment_get_vmsize(load_command);
        mk_load_command_segment_copy_name(load_command, seg_name);
    }
    
    // Slide the vmAddress
    {
        mk_vm_offset_t slide = mk_macho_get_slide(image);
        
        if ((err = mk_vm_address_apply_offset(vm_address, slide, &vm_address))) {
            _mkl_error(mk_type_get_context(load_command.type), "Arithmetic error %s while applying slide (%" MK_VM_PRIiOFFSET ") to vm_address (%" MK_VM_PRIxADDR ")", mk_error_string(err), slide, vm_address);
            return err;
        }
    }
    
    // Due to a bug in update_dyld_shared_cache(1), the segment vmsize defined
    // in the Mach-O load commands may be invalid, and the declared size may
    // be unmappable.  This bug appears to be caused by a bug in computing the
    // correct vmsize when update_dyld_shared_cache(1) generates the single
    // shared LINKEDIT segment.  Landon F. has reported this bug to Apple
    // as rdar://13707406.
    bool allowShortMappings = false;
    if (mk_macho_is_from_shared_cache(image) && !strncmp(seg_name, SEG_LINKEDIT, sizeof(seg_name)))
        allowShortMappings = true;
    
    // Create a memory object for accessing this segment.  This will also check
    // vmAddress + vmSize for potential overflow.
    if ((err = mk_memory_map_init_object(mk_macho_get_memory_map(image), 0, vm_address, vm_size, !allowShortMappings, &segment->memory_object))) {
        _mkl_error(mk_type_get_context(load_command.type), "Failed to init memory object for segment %s at (vmAddress = %" MK_VM_PRIxADDR ", vmSize = %" MK_VM_PRIiSIZE "", seg_name, vm_address, vm_size);
        return err;
    }
    
    segment->vtable = &_mk_segment_class;
    segment->segment_load_command = load_command;
    
    return MK_ESUCCESS;
}

//|++++++++++++++++++++++++++++++++++++|//
void
mk_segment_free(mk_segment_ref segment)
{
    mk_memory_map_free_object(mk_macho_get_memory_map(mk_load_command_get_macho(segment.segment->segment_load_command)), &segment.segment->memory_object, NULL);
    segment.segment->vtable = NULL;
}

//|++++++++++++++++++++++++++++++++++++|//
mk_macho_ref mk_segment_get_macho(mk_segment_ref segment)
{ return mk_load_command_get_macho(mk_segment_get_load_command(segment)); }

//|++++++++++++++++++++++++++++++++++++|//
mk_load_command_ref mk_segment_get_load_command(mk_segment_ref segment)
{ return segment.segment->segment_load_command; }

//|++++++++++++++++++++++++++++++++++++|//
mk_vm_range_t mk_segment_get_range(mk_segment_ref segment)
{ return mk_memory_object_host_range(mk_segment_get_mobj(segment)); }

//|++++++++++++++++++++++++++++++++++++|//
mk_memory_object_ref
mk_segment_get_mobj(mk_segment_ref segment)
{
    mk_memory_object_ref ret;
    ret.memory_object = &segment.segment->memory_object;
    return ret;
}

//----------------------------------------------------------------------------//
#pragma mark -  Segment Values
//----------------------------------------------------------------------------//

//|++++++++++++++++++++++++++++++++++++|//
size_t
mk_segment_copy_name(mk_segment_ref segment, char output[16])
{
    if (mk_load_command_id(&segment.segment->segment_load_command) == mk_load_command_segment_64_id())
        return mk_load_command_segment_64_copy_name(&segment.segment->segment_load_command, output);
    else
        return mk_load_command_segment_copy_name(segment.segment->segment_load_command, output);
}

//|++++++++++++++++++++++++++++++++++++|//
mk_vm_address_t
mk_segment_get_vmaddr(mk_segment_ref segment)
{
    if (mk_load_command_id(&segment.segment->segment_load_command) == mk_load_command_segment_64_id())
        return mk_load_command_segment_64_get_vmaddr(&segment.segment->segment_load_command);
    else
        return mk_load_command_segment_get_vmaddr(segment.segment->segment_load_command);
}

//|++++++++++++++++++++++++++++++++++++|//
mk_vm_size_t
mk_segment_get_vmsize(mk_segment_ref segment)
{
    if (mk_load_command_id(&segment.segment->segment_load_command) == mk_load_command_segment_64_id())
        return mk_load_command_segment_64_get_vmsize(&segment.segment->segment_load_command);
    else
        return mk_load_command_segment_get_vmsize(segment.segment->segment_load_command);
}

//|++++++++++++++++++++++++++++++++++++|//
mk_vm_address_t
mk_segment_get_fileoff(mk_segment_ref segment)
{
    if (mk_load_command_id(&segment.segment->segment_load_command) == mk_load_command_segment_64_id())
        return mk_load_command_segment_64_get_fileoff(&segment.segment->segment_load_command);
    else
        return mk_load_command_segment_get_fileoff(segment.segment->segment_load_command);
}

//|++++++++++++++++++++++++++++++++++++|//
mk_vm_size_t
mk_segment_get_filesize(mk_segment_ref segment)
{
    if (mk_load_command_id(&segment.segment->segment_load_command) == mk_load_command_segment_64_id())
        return mk_load_command_segment_64_get_filesize(&segment.segment->segment_load_command);
    else
        return mk_load_command_segment_get_filesize(segment.segment->segment_load_command);
}

//|++++++++++++++++++++++++++++++++++++|//
vm_prot_t
mk_segment_get_maxprot(mk_segment_ref segment)
{
    if (mk_load_command_id(&segment.segment->segment_load_command) == mk_load_command_segment_64_id())
        return mk_load_command_segment_64_get_maxprot(&segment.segment->segment_load_command);
    else
        return mk_load_command_segment_get_maxprot(segment.segment->segment_load_command);
}

//|++++++++++++++++++++++++++++++++++++|//
vm_prot_t
mk_segment_get_initprot(mk_segment_ref segment)
{
    if (mk_load_command_id(&segment.segment->segment_load_command) == mk_load_command_segment_64_id())
        return mk_load_command_segment_64_get_initprot(&segment.segment->segment_load_command);
    else
        return mk_load_command_segment_get_initprot(segment.segment->segment_load_command);
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
mk_segment_get_nsects(mk_segment_ref segment)
{
    if (mk_load_command_id(&segment.segment->segment_load_command) == mk_load_command_segment_64_id())
        return mk_load_command_segment_64_get_nsects(&segment.segment->segment_load_command);
    else
        return mk_load_command_segment_get_nsects(segment.segment->segment_load_command);
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
mk_segment_get_flags(mk_segment_ref segment)
{
    if (mk_load_command_id(&segment.segment->segment_load_command) == mk_load_command_segment_64_id())
        return mk_load_command_segment_64_get_flags(&segment.segment->segment_load_command);
    else
        return mk_load_command_segment_get_flags(segment.segment->segment_load_command);
}

//----------------------------------------------------------------------------//
#pragma mark -  Enumerating Sections
//----------------------------------------------------------------------------//

//|++++++++++++++++++++++++++++++++++++|//
void*
mk_segment_next_section(mk_segment_ref segment, void* previous)
{
    if (mk_load_command_id(&segment.segment->segment_load_command) == mk_load_command_segment_64_id())
        return (void*)mk_load_command_segment_64_next_section(segment.segment->segment_load_command, previous, NULL);
    else
        return (void*)mk_load_command_segment_next_section(segment.segment->segment_load_command, previous, NULL);
}

//|++++++++++++++++++++++++++++++++++++|//
#if __BLOCKS__
void
mk_segment_enumerate_sections(mk_segment_ref segment, void (^enumerator)(void *section, uint32_t index))
{
    if (mk_load_command_id(&segment.segment->segment_load_command) == mk_load_command_segment_64_id())
        return mk_load_command_segment_64_enumerate_sections(segment.segment->segment_load_command, ^(struct section_64 *command, uint32_t index, mk_vm_address_t __unused context_address) {
            enumerator(command, index);
        });
    else
        return mk_load_command_segment_enumerate_sections(segment.segment->segment_load_command, ^(struct section *command, uint32_t index, mk_vm_address_t __unused context_address) {
            enumerator(command, index);
        });
}
#endif

