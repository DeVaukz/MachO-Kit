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
        _mkl_error(mk_type_get_context(load_command.type), "load_command used to initialize an mk_segment must be one of LC_SEGMENT or LC_SEGMENT64, got %s", mk_type_name(load_command.type));
        return MK_EINVAL;
    }
    
    mk_macho_ref image = load_command.load_command->image;
    
    char segname[17] = {0x0};
    mk_load_command_segment_copy_name(load_command, segname);
    
    mk_vm_address_t vmAddress;
    mk_vm_size_t vmSize;
    
    if (mk_load_command_id(load_command) == mk_load_command_segment_64_id()) {
        vmAddress = mk_load_command_segment_64_get_vmaddr(load_command);
        vmSize = mk_load_command_segment_64_get_vmsize(load_command);
    } else {
        vmAddress = mk_load_command_segment_get_vmaddr(load_command);
        vmSize = mk_load_command_segment_get_vmsize(load_command);
    }
    
    // Pre-flight sliding the node address.
    {
        mk_vm_offset_t slide = mk_macho_get_slide(image);
        
        if ((err = mk_vm_address_apply_offset(vmAddress, slide, NULL))) {
            _mkl_error(mk_type_get_context(load_command.type), "Arithmetic error %s while applying slide (%" MK_VM_PRIiOFFSET ") to vmAddress (%" MK_VM_PRIxADDR ")", mk_error_string(err), slide, vmAddress);
            return err;
        }
    }
    
    // Check the vmAddress + vmSize for potential overflow.
    if ((err = mk_vm_address_check_length(vmAddress, vmSize))) {
        _mkl_error(mk_type_get_context(load_command.type), "Adding vmSize (%" MK_VM_PRIiSIZE ") to vmAddress (%" MK_VM_PRIxADDR ") would trigger %s.", vmSize, vmAddress, mk_error_string(err));
        return err;
    }
    
    // Due to a bug in update_dyld_shared_cache(1), the segment vmsize defined
    // in the Mach-O load commands may be invalid, and the declared size may
    // be unmappable.  This bug appears to be caused by a bug in computing the
    // correct vmsize when update_dyld_shared_cache(1) generates the single
    // shared LINKEDIT segment.  Landon F. has reported this bug to Apple
    // as rdar://13707406.
    bool allowShortMappings = false;
    if (mk_macho_is_from_shared_cache(image) && !strncmp(segname, SEG_LINKEDIT, sizeof(segname)))
        allowShortMappings = true;
    
    segment->vtable = &_mk_segment_class;
    segment->segment_load_command = *load_command.load_command;
    
    // Create a memory object for accessing this segment.
    if ((err = mk_memory_map_init_object(mk_macho_get_memory_map(image), 0, vmAddress, vmSize, !allowShortMappings, &segment->memory_object))) {
        _mkl_error(mk_type_get_context(load_command.type), "Failed to init memory object for segment %s at (vmAddress = %" MK_VM_PRIxADDR ", vmSize = %" MK_VM_PRIiSIZE "", segname, vmAddress, vmSize);
        return err;
    }
    
    return MK_ESUCCESS;
}

//|++++++++++++++++++++++++++++++++++++|//
void
mk_segment_free(mk_segment_ref segment)
{
    mk_memory_map_free_object(segment.segment->segment_load_command.image.macho->memory_map, &segment.segment->memory_object, NULL);
    segment.segment->vtable = NULL;
}

//|++++++++++++++++++++++++++++++++++++|//
mk_macho_ref mk_segment_get_macho(mk_segment_ref segment)
{ return segment.segment->segment_load_command.image; }

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
        return mk_load_command_segment_copy_name(&segment.segment->segment_load_command, output);
}

//|++++++++++++++++++++++++++++++++++++|//
mk_vm_address_t
mk_segment_get_vm_address(mk_segment_ref segment)
{
    if (mk_load_command_id(&segment.segment->segment_load_command) == mk_load_command_segment_64_id())
        return mk_load_command_segment_64_get_vmaddr(&segment.segment->segment_load_command);
    else
        return mk_load_command_segment_get_vmaddr(&segment.segment->segment_load_command);
}

//|++++++++++++++++++++++++++++++++++++|//
mk_vm_size_t
mk_segment_get_vm_size(mk_segment_ref segment)
{
    if (mk_load_command_id(&segment.segment->segment_load_command) == mk_load_command_segment_64_id())
        return mk_load_command_segment_64_get_vmsize(&segment.segment->segment_load_command);
    else
        return mk_load_command_segment_get_vmsize(&segment.segment->segment_load_command);
}

//|++++++++++++++++++++++++++++++++++++|//
mk_vm_address_t
mk_segment_get_file_offset(mk_segment_ref segment)
{
    if (mk_load_command_id(&segment.segment->segment_load_command) == mk_load_command_segment_64_id())
        return mk_load_command_segment_64_get_fileoff(&segment.segment->segment_load_command);
    else
        return mk_load_command_segment_get_fileoff(&segment.segment->segment_load_command);
}

//|++++++++++++++++++++++++++++++++++++|//
mk_vm_size_t
mk_segment_get_file_size(mk_segment_ref segment)
{
    if (mk_load_command_id(&segment.segment->segment_load_command) == mk_load_command_segment_64_id())
        return mk_load_command_segment_64_get_filesize(&segment.segment->segment_load_command);
    else
        return mk_load_command_segment_get_filesize(&segment.segment->segment_load_command);
}

//|++++++++++++++++++++++++++++++++++++|//
vm_prot_t
mk_segment_get_max_vm_prot(mk_segment_ref segment)
{
    if (mk_load_command_id(&segment.segment->segment_load_command) == mk_load_command_segment_64_id())
        return mk_load_command_segment_64_get_maxprot(&segment.segment->segment_load_command);
    else
        return mk_load_command_segment_get_maxprot(&segment.segment->segment_load_command);
}

//|++++++++++++++++++++++++++++++++++++|//
vm_prot_t
mk_segment_get_initial_vm_prot(mk_segment_ref segment)
{
    if (mk_load_command_id(&segment.segment->segment_load_command) == mk_load_command_segment_64_id())
        return mk_load_command_segment_64_get_initprot(&segment.segment->segment_load_command);
    else
        return mk_load_command_segment_get_initprot(&segment.segment->segment_load_command);
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
mk_segment_get_nsects(mk_segment_ref segment)
{
    if (mk_load_command_id(&segment.segment->segment_load_command) == mk_load_command_segment_64_id())
        return mk_load_command_segment_64_get_nsects(&segment.segment->segment_load_command);
    else
        return mk_load_command_segment_get_nsects(&segment.segment->segment_load_command);
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
mk_segment_get_flags(mk_segment_ref segment)
{
    if (mk_load_command_id(&segment.segment->segment_load_command) == mk_load_command_segment_64_id())
        return mk_load_command_segment_64_get_flags(&segment.segment->segment_load_command);
    else
        return mk_load_command_segment_get_flags(&segment.segment->segment_load_command);
}
