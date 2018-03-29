//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             memory_map_spec.m
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

#include <malloc/malloc.h>

SpecBegin(memory_map)

describe(@"memory_map_self", ^{
    __block mk_memory_map_self_t memory_map;
    
    beforeAll(^{
        mk_error_t err = mk_memory_map_self_init(NULL, &memory_map);
        expect(err).to.equal(MK_ESUCCESS);
    });
    
    ///////////////
    // CORE TYPE //
    ///////////////
    
    it(@"should be of type memory_map_self", ^{
        const char * name = mk_type_name(&memory_map);
        expect(strcmp(name, "memory_map_self")).to.equal(0);
    });
    
    ////////////////
    // MEMORY MAP //
    ////////////////
    
    it(@"should map valid, page-aligned memory properly", ^{
        void *allocation = valloc(vm_page_size * 5);
        mk_vm_address_t allocation_address = (mk_vm_address_t)allocation;
        size_t allocation_size = malloc_size(allocation);
        memset(allocation, 0xAA, allocation_size);
        
        __block mk_memory_object_t memory_object;
        mk_error_t err = mk_memory_map_init_object(&memory_map, 0, (mk_vm_address_t)allocation, allocation_size, true, &memory_object);
        expect(err).to.equal(MK_ESUCCESS);
        if (err)
            return;
        
        expect(mk_memory_object_address(&memory_object)).to.equal(allocation_address);
        expect(mk_memory_object_length(&memory_object)).to.equal(allocation_size);
        expect(mk_memory_object_target_address(&memory_object)).to.equal(allocation_address);
        
        // The full range mapped previously should be available.
        expect(mk_memory_object_verify_local_pointer(&memory_object, 0, allocation_address, allocation_size, NULL)).to.beTruthy();
        // The first byte after the range should *not* be available.
        expect(mk_memory_object_verify_local_pointer(&memory_object, allocation_size, allocation_address, 1, NULL)).to.beFalsy();
        // The first byte before the mapping should not be available.
        expect(mk_memory_object_verify_local_pointer(&memory_object, 0, allocation_address - 1, allocation_size, NULL)).to.beFalsy();
        // A random range within the mapping should be visible.
        expect(mk_memory_object_verify_local_pointer(&memory_object, 50, allocation_address, 100, NULL)).to.beTruthy();
        
        // The first byte in the mapping should match the allocation start.
        vm_address_t mapping_start = mk_memory_object_remap_address(&memory_object, 0, allocation_address, allocation_size, NULL);
        expect(mapping_start).to.equal(allocation_address);
        expect(mk_memory_object_unmap_address(&memory_object, 0, mapping_start, allocation_size, NULL)).to.equal(allocation_address);
        
        expect(mk_memory_object_read_byte(&memory_object, 0, allocation_address, NULL, NULL)).to.equal(0xAA);
    });
    
    it(@"should map valid, non page-aligned memory properly", ^{
        void *allocation = valloc(vm_page_size * 5);
        mk_vm_address_t allocation_address = (mk_vm_address_t)allocation;
        size_t allocation_size = malloc_size(allocation);
        memset(allocation, 0xBB, allocation_size);
        
        mach_vm_address_t shifted_allocation_address = allocation_address+ 46;
        mach_vm_size_t shifted_allocation_size = allocation_size - 46 - 67;
        memset((void*)shifted_allocation_address, 0xCC, shifted_allocation_size);
        
        __block mk_memory_object_t memory_object;
        mk_error_t err = mk_memory_map_init_object(&memory_map, 0, shifted_allocation_address, shifted_allocation_size, true, &memory_object);
        expect(err).to.equal(MK_ESUCCESS);
        if (err)
            return;
        
        expect(mk_memory_object_address(&memory_object)).to.equal(shifted_allocation_address);
        expect(mk_memory_object_length(&memory_object)).to.beGreaterThanOrEqualTo(shifted_allocation_size);
        expect(mk_memory_object_target_address(&memory_object)).to.equal(shifted_allocation_address);
        
        // The full range mapped previously should be available.
        expect(mk_memory_object_verify_local_pointer(&memory_object, 0, shifted_allocation_address, shifted_allocation_size, NULL)).to.beTruthy();
        // The first byte after the range should *not* be available.
        expect(mk_memory_object_verify_local_pointer(&memory_object, shifted_allocation_size, shifted_allocation_address, 100, NULL)).to.beFalsy();
        // The first byte before the mapping should not be available.
        expect(mk_memory_object_verify_local_pointer(&memory_object, 0, shifted_allocation_address - 1, shifted_allocation_size, NULL)).to.beFalsy();
        // A random range within the mapping should be visible.
        expect(mk_memory_object_verify_local_pointer(&memory_object, 50, shifted_allocation_address, 100, NULL)).to.beTruthy();
        
        // The first byte in the mapping should match the allocation start.
        vm_address_t mapping_start = mk_memory_object_remap_address(&memory_object, 0, shifted_allocation_address, shifted_allocation_size, NULL);
        expect(mapping_start).to.equal(shifted_allocation_address);
        expect(mk_memory_object_unmap_address(&memory_object, 0, mapping_start, shifted_allocation_size, NULL)).to.equal(shifted_allocation_address);
        
        expect(mk_memory_object_read_byte(&memory_object, 0, shifted_allocation_address, NULL, NULL)).to.equal(0xCC);
    });
});


describe(@"memory_map_task", ^{
    __block mk_memory_map_task_t memory_map;
    
    beforeAll(^{
        mk_error_t err = mk_memory_map_task_init(mach_task_self(), NULL, &memory_map);
        expect(err).to.equal(MK_ESUCCESS);
    });
    
    afterAll(^{
        mk_memory_map_task_free(&memory_map);
    });
    
    ///////////////
    // CORE TYPE //
    ///////////////
    
    it(@"should be of type memory_map_self", ^{
        const char * name = mk_type_name(&memory_map);
        expect(strcmp(name, "memory_map_task")).to.equal(0);
    });
    
    ////////////////
    // MEMORY MAP //
    ////////////////
    
    it(@"should map valid, page-aligned memory properly", ^{
        void *allocation = valloc(vm_page_size * 5);
        mk_vm_address_t allocation_address = (mk_vm_address_t)allocation;
        size_t allocation_size = malloc_size(allocation);
        memset(allocation, 0xAA, allocation_size);
        
        __block mk_memory_object_t memory_object;
        mk_error_t err = mk_memory_map_init_object(&memory_map, 0, (mk_vm_address_t)allocation, allocation_size, true, &memory_object);
        expect(err).to.equal(MK_ESUCCESS);
        if (err)
            return;
        
        vm_address_t mapping_start = mk_memory_object_remap_address(&memory_object, 0, allocation_address, allocation_size, NULL);
        expect(mapping_start).toNot.equal(UINTPTR_MAX);
        expect(mapping_start).toNot.equal(0);
        
        // The full range mapped previously should be available.
        expect(mk_memory_object_verify_local_pointer(&memory_object, 0, mapping_start, allocation_size, NULL)).to.beTruthy();
        // The first byte after the range should *not* be available.
        expect(mk_memory_object_verify_local_pointer(&memory_object, allocation_size, mapping_start, 1, NULL)).to.beFalsy();
        // The first byte before the mapping should not be available.
        expect(mk_memory_object_verify_local_pointer(&memory_object, 0, mapping_start - 1, allocation_size, NULL)).to.beFalsy();
        // A random range within the mapping should be visible.
        expect(mk_memory_object_verify_local_pointer(&memory_object, 50, mapping_start, 100, NULL)).to.beTruthy();
        
        // The first byte in the mapping should unmap back to the allocation.
        expect(mk_memory_object_unmap_address(&memory_object, 0, mapping_start, allocation_size, NULL)).to.equal(allocation_address);
        
        expect(mk_memory_object_read_byte(&memory_object, 0, allocation_address, NULL, NULL)).to.equal(0xAA);
    });
    
    it(@"should map valid, non page-aligned memory properly", ^{
        void *allocation = valloc(vm_page_size * 5);
        mk_vm_address_t allocation_address = (mk_vm_address_t)allocation;
        size_t allocation_size = malloc_size(allocation);
        memset(allocation, 0xBB, allocation_size);
        
        mach_vm_address_t shifted_allocation_address = allocation_address+ 46;
        mach_vm_size_t shifted_allocation_size = allocation_size - 46 - 67;
        memset((void*)shifted_allocation_address, 0xCC, shifted_allocation_size);
        
        __block mk_memory_object_t memory_object;
        mk_error_t err = mk_memory_map_init_object(&memory_map, 0, shifted_allocation_address, shifted_allocation_size, true, &memory_object);
        expect(err).to.equal(MK_ESUCCESS);
        if (err)
            return;
        
        vm_address_t mapping_start = mk_memory_object_remap_address(&memory_object, 0, shifted_allocation_address, shifted_allocation_size, NULL);
        
        // The full range mapped previously should be available.
        expect(mk_memory_object_verify_local_pointer(&memory_object, 0, mapping_start, shifted_allocation_size, NULL)).to.beTruthy();
        // The first byte before the mapping should not be available.
        expect(mk_memory_object_verify_local_pointer(&memory_object, 0, mapping_start - 1, shifted_allocation_size, NULL)).to.beFalsy();
        // A random range within the mapping should be visible.
        expect(mk_memory_object_verify_local_pointer(&memory_object, 50, mapping_start, 100, NULL)).to.beTruthy();
        
        // The first byte in the mapping should unmap back to the allocation.
        expect(mk_memory_object_unmap_address(&memory_object, 0, mapping_start, shifted_allocation_size, NULL)).to.equal(shifted_allocation_address);
        
        expect(mk_memory_object_read_byte(&memory_object, 0, shifted_allocation_address, NULL, NULL)).to.equal(0xCC);
    });
});

SpecEnd
