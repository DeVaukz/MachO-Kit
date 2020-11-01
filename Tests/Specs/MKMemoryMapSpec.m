//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKMemoryMapSpec.m
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

SpecBegin(MKMemoryMap)

describe(@"a file memory map", ^{
    __block MKMemoryMap *map;
    __block NSData *fileData;
    
    beforeAll(^{
        NSError *error;
        NSURL *foundationURL = [NSURL fileURLWithPath:@"/System/Library/Frameworks/Foundation.framework/Foundation"];
        map = [MKMemoryMap memoryMapWithContentsOfFile:foundationURL error:&error];
        expect(map).toNot.beNil();
        expect(error).to.beNil();
        fileData = [map valueForKey:@"_fileData"];
    });
    
    it(@"should properly remap a valid address", ^{
        __block vm_address_t address;
        __block mach_vm_size_t length;
        __block NSError *error;
        
        // First test - Pass offset as context address
        [map remapBytesAtOffset:0 fromAddress:4096 length:5484640 requireFull:NO withHandler:^(vm_address_t a, vm_size_t l, NSError *e) {
            address = a;
            length = l;
            error = e;
        }];
        expect(error).to.beNil();
        expect(address).toNot.equal(@(0));
        expect(length).to.beGreaterThanOrEqualTo(@(5484640));
        
        // Second test - Pass offset as offset
        [map remapBytesAtOffset:4096 fromAddress:0 length:5484640 requireFull:NO withHandler:^(vm_address_t a, vm_size_t l, NSError *e) {
            address = a;
            length = l;
            error = e;
        }];
        expect(error).to.beNil();
        expect(address).toNot.equal(@(0));
        expect(length).to.beGreaterThanOrEqualTo(@(5484640));
    });
    
    it(@"should report that it has valid mappings", ^{
        expect([map hasMappingAtOffset:4096 fromAddress:0 length:5484640]).to.beTruthy();
    });
});


describe(@"a task memory map", ^{
    __block MKMemoryMap *map;
    
    beforeAll(^{
        NSError *error;
        map = [MKMemoryMap memoryMapWithTask:mach_task_self() error:&error];
        expect(map).toNot.beNil();
        expect(error).to.beNil();
    });
    
    it(@"should properly remap a valid, page aligned address", ^{
        void *allocation = valloc(vm_page_size * 5);
        size_t allocationSize = malloc_size(allocation);
        memset(allocation, 0xAA, allocationSize);
        
        [map remapBytesAtOffset:0 fromAddress:(mach_vm_address_t)allocation length:allocationSize requireFull:YES withHandler:^(vm_address_t address, vm_size_t length, NSError *error) {
            expect(error).to.beNil();
            expect(length).to.beGreaterThanOrEqualTo(allocationSize);
            expect( memcmp((void*)address, allocation, length) ).to.equal(0);
        }];
        
        free(allocation);
    });
    
    it(@"should properly remap a valid, non-page aligned address", ^{
        void *allocation = valloc(vm_page_size * 5);
        size_t allocationSize = malloc_size(allocation);
        memset(allocation, 0xBB, allocationSize);
        
        mach_vm_address_t shiftedAllocation = (mach_vm_address_t)allocation + 46;
        mach_vm_size_t shiftedSize = allocationSize - 46 - 67;
        memset((void*)shiftedAllocation, 0xCC, shiftedSize);
        
        [map remapBytesAtOffset:46 fromAddress:(mach_vm_address_t)allocation length:shiftedSize requireFull:YES withHandler:^(vm_address_t address, vm_size_t length, NSError *error) {
            expect(error).to.beNil();
            expect(length).to.beGreaterThanOrEqualTo(shiftedSize);
            expect( memcmp((void*)address, (void*)shiftedAllocation, length) ).to.equal(0);
        }];
        
        free(allocation);
    });
    
    it(@"should fail when asked to remap an invalid range", ^{
        [map remapBytesAtOffset:0 fromAddress:0 length:vm_page_size requireFull:YES withHandler:^(vm_address_t __unused address, vm_size_t __unused length, NSError *error) {
            expect(error).toNot.beNil();
        }];
    });
});

SpecEnd
