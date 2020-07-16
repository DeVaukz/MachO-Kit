//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             core_spec.m
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

SpecBegin(Core)

describe(@"mk_vm_address_remove_slide", ^{
         
    it(@"should remove a valid positivie slide", ^{
        mk_vm_address_t address = 0x10bede000;
        mk_vm_slide_t slide = 200138752;
    
        mk_vm_address_t unslid_address = 0;
        mk_error_t err = mk_vm_address_remove_slide(address, slide, &unslid_address);
    
        expect(err).to.equal(MK_ESUCCESS);
        expect(unslid_address).to.equal((mk_vm_address_t)0x100000000);
    });
    
    it(@"should remove a valid negative slide", ^{
        mk_vm_address_t address = 0xF4122000;
        mk_vm_slide_t slide = -200138752;
    
        mk_vm_address_t unslid_address = 0;
        mk_error_t err = mk_vm_address_remove_slide(address, slide, &unslid_address);
    
        expect(err).to.equal(MK_ESUCCESS);
        expect(unslid_address).to.equal((mk_vm_address_t)0x100000000);
    });
    
    it(@"should detect when removing a positivie slide would underflow", ^{
        mk_vm_address_t address = 0xbeddfff;
        mk_vm_slide_t slide = 200138752;
    
        mk_vm_address_t unslid_address = 0;
        mk_error_t err = mk_vm_address_remove_slide(address, slide, &unslid_address);
    
        expect(err).to.equal(MK_EUNDERFLOW);
    });
});

SpecEnd
