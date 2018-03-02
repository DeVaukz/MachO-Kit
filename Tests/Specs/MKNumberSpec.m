//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKNumberSpec.m
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

/* Copied from MKInternal.h */
#define _$(X) _Generic((X), \
    uint8_t: [NSNumber mk_numberWithUnsignedByte:(X)], \
    uint16_t: [NSNumber mk_numberWithUnsignedWord:(X)], \
    uint32_t: [NSNumber mk_numberWithUnsignedDoubleWord:(X)], \
    uint64_t: [NSNumber mk_numberWithUnsignedQuadWord:(X)], \
    default: @(X) \
)

SpecBegin(MKNumber)

//----------------------------------------------------------------------------//
describe(@"Initialization", ^{
    
    it(@"should produce an NSNumber with objCType 'c' for a int8_t input", ^{
        int8_t value = 1;
        NSNumber *variableNumber = _$(value);
        expect(*(variableNumber.objCType)).to.equal('c');
        
        NSNumber *immediateNumber = _$((int8_t)1);
        expect(*(immediateNumber.objCType)).to.equal('c');
        
        NSNumber *number = [NSNumber mk_numberWithByte:1];
        expect(*(number.objCType)).to.equal('c');
        
        NSNumber *numberCopy = [number copy];
        expect(*(numberCopy.objCType)).to.equal('c');
    });
    
    it(@"should produce an NSNumber with objCType 'C' for a uint8_t input", ^{
        uint8_t value = 1;
        NSNumber *variableNumber = _$(value);
        expect(*(variableNumber.objCType)).to.equal('C');
        
        NSNumber *immediateNumber = _$((uint8_t)1);
        expect(*(immediateNumber.objCType)).to.equal('C');
        
        NSNumber *number = [NSNumber mk_numberWithUnsignedByte:1];
        expect(*(number.objCType)).to.equal('C');
        
        NSNumber *numberCopy = [number copy];
        expect(*(numberCopy.objCType)).to.equal('C');
    });
    
    it(@"should produce an NSNumber with objCType 's' for a int16_t input", ^{
        int16_t value = 1;
        NSNumber *variableNumber = _$(value);
        expect(*(variableNumber.objCType)).to.equal('s');
        
        NSNumber *immediateNumber = _$((int16_t)1);
        expect(*(immediateNumber.objCType)).to.equal('s');
        
        NSNumber *number = [NSNumber mk_numberWithWord:1];
        expect(*(number.objCType)).to.equal('s');
        
        NSNumber *numberCopy = [number copy];
        expect(*(numberCopy.objCType)).to.equal('s');
    });
    
    it(@"should produce an NSNumber with objCType 'S' for a uint16_t input", ^{
        uint16_t value = 1;
        NSNumber *variableNumber = _$(value);
        expect(*(variableNumber.objCType)).to.equal('S');
        
        NSNumber *immediateNumber = _$((uint16_t)1);
        expect(*(immediateNumber.objCType)).to.equal('S');
        
        NSNumber *number = [NSNumber mk_numberWithUnsignedWord:1];
        expect(*(number.objCType)).to.equal('S');
        
        NSNumber *numberCopy = [number copy];
        expect(*(numberCopy.objCType)).to.equal('S');
    });
    
    it(@"should produce an NSNumber with objCType 'i' for a int32_t input", ^{
        int32_t value = 1;
        NSNumber *variableNumber = _$(value);
        expect(*(variableNumber.objCType)).to.equal('i');
        
        NSNumber *immediateNumber = _$((int32_t)1);
        expect(*(immediateNumber.objCType)).to.equal('i');
        
        NSNumber *number = [NSNumber mk_numberWithDoubleWord:1];
        expect(*(number.objCType)).to.equal('i');
        
        NSNumber *numberCopy = [number copy];
        expect(*(numberCopy.objCType)).to.equal('i');
    });
    
    it(@"should produce an NSNumber with objCType 'I' for a uint32_t input", ^{
        uint32_t value = 1;
        NSNumber *variableNumber = _$(value);
        expect(*(variableNumber.objCType)).to.equal('I');
        
        NSNumber *immediateNumber = _$((uint32_t)1);
        expect(*(immediateNumber.objCType)).to.equal('I');
        
        NSNumber *number = [NSNumber mk_numberWithUnsignedDoubleWord:1];
        expect(*(number.objCType)).to.equal('I');
        
        NSNumber *numberCopy = [number copy];
        expect(*(numberCopy.objCType)).to.equal('I');
    });
    
    it(@"should produce an NSNumber with objCType 'q' for a int64_t input", ^{
        int64_t value = 1;
        NSNumber *variableNumber = _$(value);
        expect(*(variableNumber.objCType)).to.equal('q');
        
        NSNumber *immediateNumber = _$((int64_t)1);
        expect(*(immediateNumber.objCType)).to.equal('q');
        
        NSNumber *number = [NSNumber mk_numberWithQuadWord:1];
        expect(*(number.objCType)).to.equal('q');
        
        NSNumber *numberCopy = [number copy];
        expect(*(numberCopy.objCType)).to.equal('q');
    });
    
    it(@"should produce an NSNumber with objCType 'Q' for a uint64_t input", ^{
        uint64_t value = 1;
        NSNumber *variableNumber = _$(value);
        expect(*(variableNumber.objCType)).to.equal('Q');
        
        NSNumber *immediateNumber = _$((uint64_t)1);
        expect(*(immediateNumber.objCType)).to.equal('Q');
        
        NSNumber *number = [NSNumber mk_numberWithUnsignedQuadWord:1];
        expect(*(number.objCType)).to.equal('Q');
        
        NSNumber *numberCopy = [number copy];
        expect(*(numberCopy.objCType)).to.equal('Q');
    });
    
});



//----------------------------------------------------------------------------//
describe(@"mk_UnsignedValue", ^{
    
    it(@"should return the correct value and bits for a int8_t", ^{
        NSNumber *number = [NSNumber mk_numberWithByte:-1];
        
        size_t bits;
        uint64_t value = [number mk_UnsignedValue:&bits];
        
        expect(value).to.equal((uint64_t)0xFF);
        expect(bits).to.equal(8);
    });
    
    it(@"should return the correct value and bits for a uint8_t", ^{
        NSNumber *number = [NSNumber mk_numberWithUnsignedByte:255];
        
        size_t bits;
        uint64_t value = [number mk_UnsignedValue:&bits];
        
        expect(value).to.equal((uint64_t)0xFF);
        expect(bits).to.equal(8);
    });
    
    it(@"should return the correct value and bits for a int16_t", ^{
        NSNumber *number = [NSNumber mk_numberWithWord:-1];
        
        size_t bits;
        uint64_t value = [number mk_UnsignedValue:&bits];
        
        expect(value).to.equal((uint64_t)0xFFFF);
        expect(bits).to.equal(16);
    });
    
    it(@"should return the correct value and bits for a uint16_t", ^{
        NSNumber *number = [NSNumber mk_numberWithUnsignedWord:65535];
        
        size_t bits;
        uint64_t value = [number mk_UnsignedValue:&bits];
        
        expect(value).to.equal((uint64_t)0xFFFF);
        expect(bits).to.equal(16);
    });
    
    it(@"should return the correct value and bits for a int32_t", ^{
        NSNumber *number = [NSNumber mk_numberWithDoubleWord:-1];
        
        size_t bits;
        uint64_t value = [number mk_UnsignedValue:&bits];
        
        expect(value).to.equal((uint64_t)0xFFFFFFFF);
        expect(bits).to.equal(32);
    });
    
    it(@"should return the correct value and bits for a uint32_t", ^{
        NSNumber *number = [NSNumber mk_numberWithUnsignedDoubleWord:4294967295];
        
        size_t bits;
        uint64_t value = [number mk_UnsignedValue:&bits];
        
        expect(value).to.equal((uint64_t)0xFFFFFFFF);
        expect(bits).to.equal(32);
    });
    
    it(@"should return the correct value and bits for a int64_t", ^{
        NSNumber *number = [NSNumber mk_numberWithQuadWord:-1];
        
        size_t bits;
        uint64_t value = [number mk_UnsignedValue:&bits];
        
        expect(value).to.equal((uint64_t)0xFFFFFFFFFFFFFFFF);
        expect(bits).to.equal(64);
    });
    
    it(@"should return the correct value and bits for a uint64_t", ^{
        NSNumber *number = [NSNumber mk_numberWithUnsignedQuadWord:ULONG_LONG_MAX];
        
        size_t bits;
        uint64_t value = [number mk_UnsignedValue:&bits];
        
        expect(value).to.equal((uint64_t)0xFFFFFFFFFFFFFFFF);
        expect(bits).to.equal(64);
    });
    
});

SpecEnd
