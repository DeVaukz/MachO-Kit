//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             data_model_spec.m
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

#include <TargetConditionals.h>

SpecBegin(data_model)

describe(@"ILP32", ^{
    mk_data_model_ref ilp32 = mk_data_model_ilp32();
    
    it(@"should have 4 byte pointers", ^{
        expect(mk_data_model_get_pointer_size(ilp32)).to.equal(@(4));
        expect(mk_data_model_get_pointer_alignment(ilp32)).to.equal(@(4));
    });
    
    it(@"should properly byte swap", ^{
#if !TARGET_RT_BIG_ENDIAN
        uint16_t in16 = 0x0102;
        uint32_t in32 = 0x01020304;
        uint64_t in64 = 0x0102030405060708;
        
        expect(mk_data_model_get_byte_order(ilp32)->swap16( in16 )).to.equal(@(0x0102));
        expect(mk_data_model_get_byte_order(ilp32)->swap32( in32 )).to.equal(@(0x01020304));
        expect(mk_data_model_get_byte_order(ilp32)->swap64( in64 )).to.equal(@(0x0102030405060708));
#else
#error Implement this
#endif
    });
});


describe(@"LP64", ^{
    mk_data_model_ref lp64 = mk_data_model_lp64();
    
    it(@"should have 8 byte pointers", ^{
        expect(mk_data_model_get_pointer_size(lp64)).to.equal(@(8));
        expect(mk_data_model_get_pointer_alignment(lp64)).to.equal(@(8));
    });
    
    it(@"should properly byte swap", ^{
#if !TARGET_RT_BIG_ENDIAN
        uint16_t in16 = 0x0102;
        uint32_t in32 = 0x01020304;
        uint64_t in64 = 0x0102030405060708;
        
        expect(mk_data_model_get_byte_order(lp64)->swap16( in16 )).to.equal(@(0x0102));
        expect(mk_data_model_get_byte_order(lp64)->swap32( in32 )).to.equal(@(0x01020304));
        expect(mk_data_model_get_byte_order(lp64)->swap64( in64 )).to.equal(@(0x0102030405060708));
#else
#error Implement this
#endif
    });
});

describe(@"A Bridged Data Model", ^{
    mk_data_model_ref ppc32;
    ppc32.data_model = (__bridge_retained void*)[MKDarwinPPC32DataModel sharedDataModel];
    
    it(@"should have 4 byte pointers", ^{
        expect(mk_data_model_get_pointer_size(ppc32)).to.equal(@(4));
        expect(mk_data_model_get_pointer_alignment(ppc32)).to.equal(@(4));
    });
    
    it(@"should properly byte swap", ^{
#if !TARGET_RT_BIG_ENDIAN
        uint16_t in16 = 0x0102;
        uint32_t in32 = 0x01020304;
        uint64_t in64 = 0x0102030405060708;
        
        expect(mk_data_model_get_byte_order(ppc32)->swap16( in16 )).to.equal(@(0x0201));
        expect(mk_data_model_get_byte_order(ppc32)->swap32( in32 )).to.equal(@(0x04030201));
        expect(mk_data_model_get_byte_order(ppc32)->swap64( in64 )).to.equal(@(0x0807060504030201));
#else
#error Implement this
#endif
    });
});

SpecEnd
