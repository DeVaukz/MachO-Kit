//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             section.c
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
__mk_section_get_context(mk_section_ref self)
{ return mk_type_get_context( self.section->segment.type ); }

//|++++++++++++++++++++++++++++++++++++|//
static size_t
__mk_section_copy_description(mk_section_ref self, char *output, size_t output_len)
{
    return (size_t)snprintf(output, output_len, "<%s %p; target_address = %" MK_VM_PRIxADDR ", vmAddress = %" MK_VM_PRIxADDR ", vmSize = %" MK_VM_PRIxSIZE ">",
                            mk_type_name(self.type), self.type,
                            mk_section_get_target_range(self).location,
                            mk_section_get_addr(self), mk_section_get_size(self));
}

const struct _mk_section_vtable _mk_section_class = {
    .base.super                 = &_mk_type_class,
    .base.name                  = "section",
    .base.get_context           = &__mk_section_get_context,
    .base.copy_description      = &__mk_section_copy_description
};

intptr_t mk_section_type = (intptr_t)&_mk_section_class;

//----------------------------------------------------------------------------//
#pragma mark -  Working With Sections
//----------------------------------------------------------------------------//

//|++++++++++++++++++++++++++++++++++++|//
mk_error_t
mk_section_init(mk_segment_ref segment, mk_load_command_section section_command, mk_section_t* section)
{
    if (segment.segment == NULL) return MK_EINVAL;
    if (section_command.any == NULL) return MK_EINVAL;
    if (section == NULL) return MK_EINVAL;
    
    mk_error_t err;
    
    mk_macho_ref image = mk_segment_get_macho(segment);
    mk_memory_object_ref mapping = mk_segment_get_mapping(segment);
    bool is64 = (mk_load_command_id(mk_segment_get_load_command(segment)) == mk_load_command_segment_64_id());
    
    mk_vm_address_t vm_address;
    mk_vm_size_t vm_size;
    char sect_name[17] = { 0 };
    char seg_name[17] = { 0 };
    
    if (is64)
    {
        // Copy lc_section
        section->command_64 = *section_command.section_64;
        
        vm_address = mk_load_command_segment_64_section_get_addr(section_command.section_64);
        vm_size = mk_load_command_segment_64_section_get_size(section_command.section_64);
        mk_load_command_segment_64_section_copy_name(section_command.section_64, sect_name);
        mk_load_command_segment_64_section_copy_segment_name(section_command.section_64, seg_name);
    }
    else
    {
        // Copy lc_section
        section->command = *section_command.section;
        
        vm_address = mk_load_command_segment_section_get_addr(section_command.section);
        vm_size = mk_load_command_segment_section_get_size(section_command.section);
        mk_load_command_segment_section_copy_name(section_command.section, sect_name);
        mk_load_command_segment_section_copy_segment_name(section_command.section, seg_name);
    }
    
    // Slide the vmAddress
    {
        mk_vm_slide_t slide = (mk_vm_slide_t)mk_macho_get_slide(image);
        
        if ((err = mk_vm_address_apply_slide(vm_address, slide, &vm_address))) {
            _mkl_debug(mk_type_get_context(segment.type), "Arithmetic error [%s] applying slide [%" MK_VM_PRIiSLIDE "] to section VM address [0x%" MK_VM_PRIxADDR "].", mk_error_string(err), slide, vm_address);
            return err;
        }
    }
    
    // Verify that this section is fully within it's segment's memory.
    if (mk_vm_range_contains_range(mk_memory_object_target_range(mapping), mk_vm_range_make(vm_address, vm_size), false) != MK_ESUCCESS) {
        char buffer[512] = { 0 };
        mk_type_copy_description(segment.type, buffer, sizeof(buffer));
        _mkl_debug(mk_type_get_context(segment.type), "Part of section [%s] (target_address = 0x%" MK_VM_PRIxADDR ", size = 0x%" MK_VM_PRIxSIZE ") is not within segment %s.", sect_name, vm_address, vm_size, buffer);
        return err;
    }
    
    section->vtable = &_mk_section_class;
    section->segment = segment;
    
    return MK_ESUCCESS;
}

//|++++++++++++++++++++++++++++++++++++|//
mk_error_t
mk_section_init_wih_mach_section_command(mk_segment_ref segment, mk_macho_section_command_ptr lc_section, mk_section_t* section)
{
    if (segment.segment == NULL) return MK_EINVAL;
    if (lc_section.any == NULL) return MK_EINVAL;
    if (section == NULL) return MK_EINVAL;
    
    mk_load_command_ref load_command = mk_segment_get_load_command(segment);
    
    if (mk_load_command_id(load_command) == mk_load_command_segment_64_id()) {
        mk_load_command_section_64_t sec;
        mk_error_t err;
        
        if ((err = mk_load_command_segment_64_section_init(load_command, lc_section.section_64, &sec)))
            return err;
        
        return mk_section_init(segment, &sec, section);
    } else {
        mk_load_command_section_t sec;
        mk_error_t err;
        
        if ((err = mk_load_command_segment_section_init(load_command, lc_section.section, &sec)))
            return err;
        
        return mk_section_init(segment, &sec, section);
    }
}

//|++++++++++++++++++++++++++++++++++++|//
mk_macho_ref mk_section_get_macho(mk_section_ref section)
{ return mk_segment_get_macho(section.section->segment); }

//|++++++++++++++++++++++++++++++++++++|//
mk_segment_ref mk_section_get_segment(mk_section_ref section)
{ return section.section->segment; }

//|++++++++++++++++++++++++++++++++++++|//
mk_vm_range_t
mk_section_get_target_range(mk_section_ref section)
{
    intptr_t slide = mk_macho_get_slide(mk_section_get_macho(section));
    // Safely applying the slide to addr was checked in the initializer.
    return mk_vm_range_make(mk_section_get_addr(section) + (vm_offset_t)slide, mk_section_get_size(section));
}

//|++++++++++++++++++++++++++++++++++++|//
mk_error_t
mk_section_init_mapping(mk_section_ref section, mk_memory_object_t *mobj)
{
    mk_memory_map_ref memory_map = mk_memory_map_for_object(mk_segment_get_mapping(section.section->segment));
    mk_vm_range_t range = mk_section_get_target_range(section);
    
    // Stub libraries have a zero length __TEXT,__text.  In this case, return
    // MK_ENOT_FOUND instead of letting the memory map return MK_EBAD_ACCESS.
    if (range.length == 0) {
        return MK_ENOT_FOUND;
    }
    
    return mk_memory_map_init_object(memory_map, 0, range.location, range.length, false, mobj);
}

//----------------------------------------------------------------------------//
#pragma mark -  Section Values
//----------------------------------------------------------------------------//

//|++++++++++++++++++++++++++++++++++++|//
size_t
mk_section_copy_name(mk_section_ref section, char output[16])
{
    if (mk_load_command_id(mk_segment_get_load_command(section.section->segment)) == mk_load_command_segment_64_id())
        return mk_load_command_segment_64_section_copy_name(&section.section->command_64, output);
    else
        return mk_load_command_segment_section_copy_name(&section.section->command, output);
}

//|++++++++++++++++++++++++++++++++++++|//
size_t
mk_section_copy_segment_name(mk_section_ref section, char output[16])
{
    if (mk_load_command_id(mk_segment_get_load_command(section.section->segment)) == mk_load_command_segment_64_id())
        return mk_load_command_segment_64_section_copy_segment_name(&section.section->command_64, output);
    else
        return mk_load_command_segment_section_copy_segment_name(&section.section->command, output);
}

//|++++++++++++++++++++++++++++++++++++|//
mk_vm_address_t
mk_section_get_addr(mk_section_ref section)
{
    if (mk_load_command_id(mk_segment_get_load_command(section.section->segment)) == mk_load_command_segment_64_id())
        return mk_load_command_segment_64_section_get_addr(&section.section->command_64);
    else
        return mk_load_command_segment_section_get_addr(&section.section->command);
}

//|++++++++++++++++++++++++++++++++++++|//
mk_vm_size_t
mk_section_get_size(mk_section_ref section)
{
    if (mk_load_command_id(mk_segment_get_load_command(section.section->segment)) == mk_load_command_segment_64_id())
        return mk_load_command_segment_64_section_get_size(&section.section->command_64);
    else
        return mk_load_command_segment_section_get_size(&section.section->command);
}

//|++++++++++++++++++++++++++++++++++++|//
mk_vm_address_t
mk_section_get_offset(mk_section_ref section)
{
    if (mk_load_command_id(mk_segment_get_load_command(section.section->segment)) == mk_load_command_segment_64_id())
        return mk_load_command_segment_64_section_get_offset(&section.section->command_64);
    else
        return mk_load_command_segment_section_get_offset(&section.section->command);
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
mk_section_get_align(mk_section_ref section)
{
    if (mk_load_command_id(mk_segment_get_load_command(section.section->segment)) == mk_load_command_segment_64_id())
        return mk_load_command_segment_64_section_get_align(&section.section->command_64);
    else
        return mk_load_command_segment_section_get_align(&section.section->command);
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
mk_section_get_reloff(mk_section_ref section)
{
    if (mk_load_command_id(mk_segment_get_load_command(section.section->segment)) == mk_load_command_segment_64_id())
        return mk_load_command_segment_64_section_get_reloff(&section.section->command_64);
    else
        return mk_load_command_segment_section_get_reloff(&section.section->command);
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
mk_section_get_nreloc(mk_section_ref section)
{
    if (mk_load_command_id(mk_segment_get_load_command(section.section->segment)) == mk_load_command_segment_64_id())
        return mk_load_command_segment_64_section_get_nreloc(&section.section->command_64);
    else
        return mk_load_command_segment_section_get_nreloc(&section.section->command);
}

//|++++++++++++++++++++++++++++++++++++|//
uint8_t
mk_section_get_type(mk_section_ref section)
{
    if (mk_load_command_id(mk_segment_get_load_command(section.section->segment)) == mk_load_command_segment_64_id())
        return mk_load_command_segment_64_section_get_type(&section.section->command_64);
    else
        return mk_load_command_segment_section_get_type(&section.section->command);
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
mk_section_get_attributes(mk_section_ref section)
{
    if (mk_load_command_id(mk_segment_get_load_command(section.section->segment)) == mk_load_command_segment_64_id())
        return mk_load_command_segment_64_section_get_attributes(&section.section->command_64);
    else
        return mk_load_command_segment_section_get_attributes(&section.section->command);
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
mk_section_get_reserved1(mk_section_ref section)
{
    if (mk_load_command_id(mk_segment_get_load_command(section.section->segment)) == mk_load_command_segment_64_id())
        return mk_load_command_segment_64_section_get_reserved1(&section.section->command_64);
    else
        return mk_load_command_segment_section_get_reserved1(&section.section->command);
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
mk_section_get_reserved2(mk_section_ref section)
{
    if (mk_load_command_id(mk_segment_get_load_command(section.section->segment)) == mk_load_command_segment_64_id())
        return mk_load_command_segment_64_section_get_reserved2(&section.section->command_64);
    else
        return mk_load_command_segment_section_get_reserved2(&section.section->command);
}

