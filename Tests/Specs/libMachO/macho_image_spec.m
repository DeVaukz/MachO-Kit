//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             macho_image_spec.m
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

#include <dlfcn.h>
#include <mach-o/dyld.h>
#include <mach-o/dyld_images.h>

SpecBegin(macho_image)

describe(@"mk_macho_image", ^{
    __block mk_memory_map_self_t memory_map;
    
    beforeAll(^{
        mk_error_t err = mk_memory_map_self_init(NULL, &memory_map);
        expect(err).to.equal(MK_ESUCCESS);
    });
    
    it(@"should initialize with all images in this process", ^{
        mk_macho_t macho;
        
        for(uint32_t i=0; i<_dyld_image_count(); i++)
        {
            mk_vm_address_t headerAddress = (mk_vm_address_t)_dyld_get_image_header(i);
            intptr_t slide = _dyld_get_image_vmaddr_slide(i);
            const char * name = _dyld_get_image_name(i);
            
            mk_error_t err = mk_macho_init(NULL, name, slide, headerAddress, &memory_map, &macho);
            expect(err).to.equal(MK_ESUCCESS);
            
            expect(macho.slide).to.equal(slide);
            expect(strcmp(macho.name, name)).to.equal(0);
            
            mk_macho_free(&macho);
        }
    });
});

SpecEnd