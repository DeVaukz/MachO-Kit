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
__mk_section_get_context(mk_type_ref self)
{ return mk_type_get_context( &((mk_section_t*)self)->segment ); }

const struct _mk_section_vtable _mk_section_class = {
    .base.super                 = &_mk_type_class,
    .base.name                  = "section",
    .base.get_context           = &__mk_section_get_context
};

intptr_t mk_section_type = (intptr_t)&_mk_section_class;

//----------------------------------------------------------------------------//
#pragma mark -  Working With Sections
//----------------------------------------------------------------------------//

//|++++++++++++++++++++++++++++++++++++|//
mk_error_t
mk_section_init(mk_segment_ref segment, mk_load_command_section lc_section, mk_section_t* section)
{
    if (segment.segment == NULL) return MK_EINVAL;
    if (lc_section.any == NULL) return MK_EINVAL;
    if (section == NULL) return MK_EINVAL;
    
    mk_error_t err;
    
    mk_macho_ref image = mk_segment_get_macho(segment);
    mk_load_command_ref load_command = mk_segment_get_load_command(segment);
    bool is64 = (mk_load_command_id(load_command) == mk_load_command_segment_64_id());
    
    mk_vm_address_t vm_address;
    mk_vm_size_t vm_size;
    char sect_name[17] = {0x0};
    char seg_name[17] = {0x0};
    
    if (is64)
    {
        // Copy lc_section
        section->section_64 = *lc_section.section_64;
        
        vm_address = mk_load_command_segment_64_section_get_addr(&section->section_64);
        vm_size = mk_load_command_segment_64_section_get_size(&section->section_64);
        mk_load_command_segment_64_section_copy_name(&section->section_64, sect_name);
        mk_load_command_segment_64_section_copy_segment_name(&section->section_64, seg_name);
    }
    else
    {
        // Copy lc_section
        section->section = *lc_section.section;
        
        vm_address = mk_load_command_segment_section_get_addr(&section->section);
        vm_size = mk_load_command_segment_section_get_size(&section->section);
        mk_load_command_segment_section_copy_name(&section->section, sect_name);
        mk_load_command_segment_section_copy_segment_name(&section->section, seg_name);
    }
    
    // Slide the vmAddress
    {
        mk_vm_offset_t slide = (mk_vm_offset_t)mk_macho_get_slide(image);
        
        if ((err = mk_vm_address_apply_offset(vm_address, slide, &vm_address))) {
            _mkl_error(mk_type_get_context(load_command.type), "Arithmetic error %s while applying slide (%" MK_VM_PRIiOFFSET ") to vm_address (%" MK_VM_PRIxADDR ")", mk_error_string(err), slide, vm_address);
            return err;
        }
    }
    
    // Verify that this section is fully within it's segment's memory.
    if (mk_vm_range_contains_range(mk_memory_object_host_range(mk_segment_get_mobj(segment)), mk_vm_range_make(vm_address, vm_size), false) != MK_ESUCCESS) {
        _mkl_error(mk_type_get_context(load_command.type), "Section %s is not within segment %s", sect_name, seg_name);
        return err;
    }
    
    section->vtable = &_mk_section_class;
    section->segment = segment;
    
    return MK_ESUCCESS;
}

//|++++++++++++++++++++++++++++++++++++|//
mk_error_t
mk_section_init_wih_mach_section(mk_segment_ref segment, mk_mach_section mach_section, mk_section_t* section)
{
    if (segment.segment == NULL) return MK_EINVAL;
    if (mach_section.any == NULL) return MK_EINVAL;
    if (section == NULL) return MK_EINVAL;
    
    mk_load_command_ref load_command = mk_segment_get_load_command(segment);
    
    if (mk_load_command_id(load_command) == mk_load_command_segment_64_id()) {
        mk_load_command_section_64_t sec;
        mk_error_t err;
        
        if ((err = mk_load_command_segment_64_section_init(load_command, mach_section.section_64, &sec)))
            return err;
        
        return mk_section_init(segment, &sec, section);
    } else {
        mk_load_command_section_t sec;
        mk_error_t err;
        
        if ((err = mk_load_command_segment_section_init(load_command, mach_section.section, &sec)))
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
mk_section_get_range(mk_section_ref section)
{
    intptr_t slide = mk_macho_get_slide(mk_section_get_macho(section));
    // Safely applying the slide to addr was pre-flighted in the initializer.
    return mk_vm_range_make(mk_section_get_addr(section) + (vm_offset_t)slide, mk_section_get_size(section));
}

//|++++++++++++++++++++++++++++++++++++|//
mk_error_t
mk_section_init_mobj(mk_section_ref section, mk_memory_object_t *mobj)
{
    mk_vm_range_t range = mk_section_get_range(section);
    return mk_memory_map_init_object(mk_macho_get_memory_map(mk_section_get_macho(section)), 0, range.location, range.length, false, mobj);
}

//----------------------------------------------------------------------------//
#pragma mark -  Section Values
//----------------------------------------------------------------------------//

//|++++++++++++++++++++++++++++++++++++|//
size_t
mk_section_copy_name(mk_section_ref section, char output[16])
{
    if (mk_load_command_id(mk_segment_get_load_command(section.section->segment)) == mk_load_command_segment_64_id())
        return mk_load_command_segment_64_section_copy_name(&section.section->section_64, output);
    else
        return mk_load_command_segment_section_copy_name(&section.section->section, output);
}

//|++++++++++++++++++++++++++++++++++++|//
size_t
mk_section_copy_segment_name(mk_section_ref section, char output[16])
{
    if (mk_load_command_id(mk_segment_get_load_command(section.section->segment)) == mk_load_command_segment_64_id())
        return mk_load_command_segment_64_section_copy_segment_name(&section.section->section_64, output);
    else
        return mk_load_command_segment_section_copy_segment_name(&section.section->section, output);
}

//|++++++++++++++++++++++++++++++++++++|//
mk_vm_address_t
mk_section_get_addr(mk_section_ref section)
{
    if (mk_load_command_id(mk_segment_get_load_command(section.section->segment)) == mk_load_command_segment_64_id())
        return mk_load_command_segment_64_section_get_addr(&section.section->section_64);
    else
        return mk_load_command_segment_section_get_addr(&section.section->section);
}

//|++++++++++++++++++++++++++++++++++++|//
mk_vm_size_t
mk_section_get_size(mk_section_ref section)
{
    if (mk_load_command_id(mk_segment_get_load_command(section.section->segment)) == mk_load_command_segment_64_id())
        return mk_load_command_segment_64_section_get_size(&section.section->section_64);
    else
        return mk_load_command_segment_section_get_size(&section.section->section);
}

//|++++++++++++++++++++++++++++++++++++|//
mk_vm_address_t
mk_section_get_offset(mk_section_ref section)
{
    if (mk_load_command_id(mk_segment_get_load_command(section.section->segment)) == mk_load_command_segment_64_id())
        return mk_load_command_segment_64_section_get_offset(&section.section->section_64);
    else
        return mk_load_command_segment_section_get_offset(&section.section->section);
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
mk_section_get_align(mk_section_ref section)
{
    if (mk_load_command_id(mk_segment_get_load_command(section.section->segment)) == mk_load_command_segment_64_id())
        return mk_load_command_segment_64_section_get_align(&section.section->section_64);
    else
        return mk_load_command_segment_section_get_align(&section.section->section);
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
mk_section_get_reloff(mk_section_ref section)
{
    if (mk_load_command_id(mk_segment_get_load_command(section.section->segment)) == mk_load_command_segment_64_id())
        return mk_load_command_segment_64_section_get_offset(&section.section->section_64);
    else
        return mk_load_command_segment_section_get_offset(&section.section->section);
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
mk_section_get_nreloc(mk_section_ref section)
{
    if (mk_load_command_id(mk_segment_get_load_command(section.section->segment)) == mk_load_command_segment_64_id())
        return mk_load_command_segment_64_section_get_nreloc(&section.section->section_64);
    else
        return mk_load_command_segment_section_get_nreloc(&section.section->section);
}

//|++++++++++++++++++++++++++++++++++++|//
uint8_t
mk_section_get_type(mk_section_ref section)
{
    if (mk_load_command_id(mk_segment_get_load_command(section.section->segment)) == mk_load_command_segment_64_id())
        return mk_load_command_segment_64_section_get_type(&section.section->section_64);
    else
        return mk_load_command_segment_section_get_type(&section.section->section);
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
mk_section_get_attributes(mk_section_ref section)
{
    if (mk_load_command_id(mk_segment_get_load_command(section.section->segment)) == mk_load_command_segment_64_id())
        return mk_load_command_segment_64_section_get_attributes(&section.section->section_64);
    else
        return mk_load_command_segment_section_get_attributes(&section.section->section);
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
mk_section_get_reserved1(mk_section_ref section)
{
    if (mk_load_command_id(mk_segment_get_load_command(section.section->segment)) == mk_load_command_segment_64_id())
        return mk_load_command_segment_64_section_get_reserved1(&section.section->section_64);
    else
        return mk_load_command_segment_section_get_reserved1(&section.section->section);
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
mk_section_get_reserved2(mk_section_ref section)
{
    if (mk_load_command_id(mk_segment_get_load_command(section.section->segment)) == mk_load_command_segment_64_id())
        return mk_load_command_segment_64_section_get_reserved2(&section.section->section_64);
    else
        return mk_load_command_segment_section_get_reserved2(&section.section->section);
}

