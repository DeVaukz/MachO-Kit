//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKDataModelSpec.m
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

SpecBegin(MKDataModel)

describe(@"The ILP32 Data Model", ^{
    MKILP32DataModel *ilp32 = [[MKILP32DataModel alloc] initWithEndianness:MKDataEndiannessLittle];
    
    it(@"should have 4 byte pointers", ^{
        expect(ilp32.pointerSize).to.equal(@(4));
        expect(ilp32.pointerSize).to.equal(@(4));
    });
    
    it(@"should properly byte swap", ^{
    #if !TARGET_RT_BIG_ENDIAN
        uint32_t in32 = MH_CIGAM;
        uint32_t in64 = MH_CIGAM_64;
        
        expect(ilp32.byteOrder->swap32( in32 )).to.equal(@(MH_CIGAM));
        expect(ilp32.byteOrder->swap64( in64 )).to.equal(@(MH_CIGAM_64));
    #else
        #error Implement this
    #endif
    });
});


describe(@"The LP64 Data Model", ^{
    MKLP64DataModel *lp64 = [[MKLP64DataModel alloc] initWithEndianness:MKDataEndiannessLittle];
    
    it(@"should have 4 byte pointers", ^{
        expect(lp64.pointerSize).to.equal(@(8));
        expect(lp64.pointerSize).to.equal(@(8));
    });
    
    it(@"should properly byte swap", ^{
    #if !TARGET_RT_BIG_ENDIAN
        uint32_t in32 = MH_CIGAM;
        uint32_t in64 = MH_CIGAM_64;
        
        expect(lp64.byteOrder->swap32( in32 )).to.equal(@(MH_CIGAM));
        expect(lp64.byteOrder->swap64( in64 )).to.equal(@(MH_CIGAM_64));
    #else
        #error Implement this
    #endif
    });
});

SpecEnd
