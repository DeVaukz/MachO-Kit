//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKFormatterSpec.m
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

SpecBegin(MKFormatter)

//----------------------------------------------------------------------------//
describe(@"MKComboFormatter", ^{
    NSFormatter *rawValueFormatter = NSFormatter.mk_decimalNumberFormatter;
    MKEnumerationFormatter *refinedValueFormatter = [MKEnumerationFormatter new];
    refinedValueFormatter.elements =  @{
        @(1): @"ONE",
        @(2): @"TWO",
        @(3): @"THREE"
    };
    
    describe(@"with the RefinedValue style", ^{
        MKComboFormatter *formatter = [MKComboFormatter new];
        formatter.rawValueFormatter = rawValueFormatter;
        formatter.refinedValueFormatter = refinedValueFormatter;
        formatter.style = MKComboFormatterStyleRefinedValue;
        
        it(@"should format a value that is formatted by the refinedValueFormatter", ^{
            expect([formatter stringForObjectValue:@(1)]).to.equal(@"ONE");
        });
        
        it(@"should format a value that is not formatted by the refinedValueFormatter", ^{
            expect([formatter stringForObjectValue:@(0)]).to.beNil();
        });
    });
    
    describe(@"with the RawAndRefinedValue1 style", ^{
        MKComboFormatter *formatter = [MKComboFormatter new];
        formatter.rawValueFormatter = rawValueFormatter;
        formatter.refinedValueFormatter = refinedValueFormatter;
        formatter.style = MKComboFormatterStyleRawAndRefinedValue1;
        
        it(@"should format a value that is formatted by the refinedValueFormatter", ^{
            expect([formatter stringForObjectValue:@(2)]).to.equal(@"2 TWO");
        });
        
        it(@"should format a value that is not formatted by the refinedValueFormatter", ^{
            expect([formatter stringForObjectValue:@(0)]).to.equal(@"0");
        });
    });
    
    describe(@"with the RawAndRefinedValue2 style", ^{
        MKComboFormatter *formatter = [MKComboFormatter new];
        formatter.rawValueFormatter = rawValueFormatter;
        formatter.refinedValueFormatter = refinedValueFormatter;
        formatter.style = MKComboFormatterStyleRawAndRefinedValue2;
        
        it(@"should format a value that is formatted by the refinedValueFormatter", ^{
            expect([formatter stringForObjectValue:@(3)]).to.equal(@"3 (THREE)");
        });
        
        it(@"should format a value that is not formatted by the refinedValueFormatter", ^{
            expect([formatter stringForObjectValue:@(0)]).to.equal(@"0");
        });
    });
    
    it(@"should conform to NSCopying", ^{
        MKComboFormatter *formatter = [MKComboFormatter new];
        formatter.rawValueFormatter = rawValueFormatter;
        formatter.refinedValueFormatter = refinedValueFormatter;
        formatter.style = MKComboFormatterStyleRefinedValue;
        
        MKComboFormatter *copy = [formatter copy];
        
        //expect(copy.rawValueFormatter).to.equal(formatter.rawValueFormatter);
        //expect(copy.refinedValueFormatter).to.equal(formatter.refinedValueFormatter);
        expect(copy.style).to.equal(formatter.style);
    });
    
    it(@"should conform to NSCoding", ^{
        MKComboFormatter *formatter = [MKComboFormatter new];
        formatter.rawValueFormatter = rawValueFormatter;
        formatter.refinedValueFormatter = refinedValueFormatter;
        formatter.style = MKComboFormatterStyleRefinedValue;
        
        NSData *archivedData = [NSKeyedArchiver archivedDataWithRootObject:formatter];
        MKComboFormatter *copy = [NSKeyedUnarchiver unarchiveObjectWithData:archivedData];
        
        //expect(copy.rawValueFormatter).to.equal(formatter.rawValueFormatter);
        //expect(copy.refinedValueFormatter).to.equal(formatter.refinedValueFormatter);
        expect(copy.style).to.equal(formatter.style);
    });
});



//----------------------------------------------------------------------------//
describe(@"MKEnumerationFormatter", ^{
    
    MKEnumerationFormatterElements *elements = @{
        @(1): @"ONE",
        @(2): @"TWO",
        @(3): @"THREE"
    };
    
    describe(@"with no name", ^{
        MKEnumerationFormatter *formatter = [MKEnumerationFormatter new];
        formatter.elements = elements;
        formatter.fallbackFormatter = NSFormatter.mk_decimalNumberFormatter;
        
        it(@"should format a value in the elements dictionary", ^{
            expect([formatter stringForObjectValue:@(1)]).to.equal(@"ONE");
        });
        
        it(@"should return nil when asked to format a value not in the elements dictionary", ^{
            expect([formatter stringForObjectValue:@(0)]).to.beNil();
        });
    });
    
    describe(@"with no fallbackFormatter", ^{
        MKEnumerationFormatter *formatter = [MKEnumerationFormatter new];
        formatter.elements = elements;
        formatter.name = @"Enumeration";
        
        it(@"should format a value in the elements dictionary", ^{
            expect([formatter stringForObjectValue:@(2)]).to.equal(@"TWO");
        });
        
        it(@"should return nil when asked to format a value not in the elements dictionary", ^{
            expect([formatter stringForObjectValue:@(0)]).to.beNil();
        });
    });
    
    describe(@"with a name and fallbackFormatter", ^{
        MKEnumerationFormatter *formatter = [MKEnumerationFormatter new];
        formatter.elements = elements;
        formatter.name = @"Enumeration";
        formatter.fallbackFormatter = NSFormatter.mk_decimalNumberFormatter;
        
        it(@"should format a value in the elements dictionary", ^{
            expect([formatter stringForObjectValue:@(3)]).to.equal(@"THREE");
        });
        
        it(@"should use the fallback formatter", ^{
            expect([formatter stringForObjectValue:@(0)]).to.equal(@"Enumeration(0)");
        });
    });
    
    it(@"should conform to NSCopying", ^{
        MKEnumerationFormatter *formatter = [MKEnumerationFormatter new];
        formatter.elements = elements;
        formatter.name = @"Enumeration";
        formatter.fallbackFormatter = NSFormatter.mk_decimalNumberFormatter;
        
        MKEnumerationFormatter *copy = [formatter copy];
        
        expect(copy.name).to.equal(formatter.name);
        expect(copy.elements).to.equal(formatter.elements);
        //expect(copy.fallbackFormatter).to.equal(formatter.fallbackFormatter);
    });
    
    it(@"should conform to NSCoding", ^{
        MKEnumerationFormatter *formatter = [MKEnumerationFormatter new];
        formatter.elements = elements;
        formatter.name = @"Enumeration";
        formatter.fallbackFormatter = NSFormatter.mk_decimalNumberFormatter;
        
        NSData *archivedData = [NSKeyedArchiver archivedDataWithRootObject:formatter];
        MKEnumerationFormatter *copy = [NSKeyedUnarchiver unarchiveObjectWithData:archivedData];
        
        expect(copy.name).to.equal(formatter.name);
        expect(copy.elements).to.equal(formatter.elements);
        //expect(copy.fallbackFormatter).to.equal(formatter.fallbackFormatter);
    });
    
});



//----------------------------------------------------------------------------//
describe(@"MKOptionSetFormatter", ^{
    
    MKOptionSetFormatterOptions *optionsWithoutZero = @{
        @((uint32_t)(1U << 0)): @"ONE",
        @((uint32_t)(1U << 1)): @"TWO"
    };
    
    MKOptionSetFormatterOptions *optionsWithZero = @{
        @((uint32_t)(0)): @"ZERO",
        @((uint32_t)(1U << 0)): @"ONE",
        @((uint32_t)(1U << 1)): @"TWO"
    };
    
    MKOptionSetFormatterOptions *optionsWithOverlappingValues = @{
        @((uint32_t)(3U)): @"THREE"
    };
    
    MKOptionSetFormatter *formatter = [MKOptionSetFormatter new];
    formatter.options = optionsWithoutZero;
    formatter.zeroBehavior = MKOptionSetFormatterZeroBehaviorZeroString;
    
    it(@"should format a 1-bit value with all bits represented in the options dictionary", ^{
        expect([formatter stringForObjectValue:@((uint32_t)0x1)]).to.equal(@"ONE");
    });
    
    it(@"should format a multi-bit value with all bits represented in the options dictionary", ^{
        expect([formatter stringForObjectValue:@((uint32_t)0x3)]).to.equal(@"ONE TWO");
    });
    
    it(@"should format a value with no bits represented in the options dictionary", ^{
        expect([formatter stringForObjectValue:@((uint32_t)0x4)]).to.equal(@"(1<<2)");
    });
    
    it(@"should format a value with some bits represented in the options dictionary", ^{
        expect([formatter stringForObjectValue:@((uint32_t)0x5)]).to.equal(@"ONE (1<<2)");
    });
    
    describe(@"with the ZeroString zero behavior", ^{
        it(@"should format a zero value when 0 is not in the options dictionary", ^{
            MKOptionSetFormatter *formatter = [MKOptionSetFormatter new];
            formatter.options = optionsWithoutZero;
            formatter.zeroBehavior = MKOptionSetFormatterZeroBehaviorZeroString;
            
            expect([formatter stringForObjectValue:@((uint32_t)0)]).to.equal(@"0");
        });
        
        it(@"should format a zero value when 0 is in the options dictionary", ^{
            MKOptionSetFormatter *formatter = [MKOptionSetFormatter new];
            formatter.options = optionsWithZero;
            formatter.zeroBehavior = MKOptionSetFormatterZeroBehaviorZeroString;
            
            expect([formatter stringForObjectValue:@((uint32_t)0)]).to.equal(@"ZERO");
        });
    });
    
    describe(@"with the EmptyString zero behavior", ^{
        it(@"should format a zero value when 0 is not in the options dictionary", ^{
            MKOptionSetFormatter *formatter = [MKOptionSetFormatter new];
            formatter.options = optionsWithoutZero;
            formatter.zeroBehavior = MKOptionSetFormatterZeroBehaviorEmptyString;
            
            expect([formatter stringForObjectValue:@((uint32_t)0)]).to.equal(@"");
        });
        
        it(@"should format a zero value when 0 is in the options dictionary", ^{
            MKOptionSetFormatter *formatter = [MKOptionSetFormatter new];
            formatter.options = optionsWithZero;
            formatter.zeroBehavior = MKOptionSetFormatterZeroBehaviorEmptyString;
            
            expect([formatter stringForObjectValue:@((uint32_t)0)]).to.equal(@"ZERO");
        });
    });
    
    describe(@"with the Nil zero behavior", ^{
        it(@"should format a zero value when 0 is not in the options dictionary", ^{
            MKOptionSetFormatter *formatter = [MKOptionSetFormatter new];
            formatter.options = optionsWithoutZero;
            formatter.zeroBehavior = MKOptionSetFormatterZeroBehaviorNil;
            
            expect([formatter stringForObjectValue:@((uint32_t)0)]).to.beNil();
        });
        
        it(@"should format a zero value when 0 is in the options dictionary", ^{
            MKOptionSetFormatter *formatter = [MKOptionSetFormatter new];
            formatter.options = optionsWithZero;
            formatter.zeroBehavior = MKOptionSetFormatterZeroBehaviorNil;
            
            expect([formatter stringForObjectValue:@((uint32_t)0)]).to.equal(@"ZERO");
        });
    });
    
    describe(@"with partial matching behavior", ^{
        it(@"should match partial values", ^{
            MKOptionSetFormatter *formatter = [MKOptionSetFormatter new];
            formatter.options = optionsWithOverlappingValues;
            formatter.partialMatching = YES;
            
            expect([formatter stringForObjectValue:@((uint32_t)(1U))]).to.equal(@"THREE");
        });
    });
    
    it(@"should conform to NSCopying", ^{
        MKOptionSetFormatter *copy = [formatter copy];
        
        expect(copy.options).to.equal(formatter.options);
        expect(copy.zeroBehavior).to.equal(formatter.zeroBehavior);
    });
    
    it(@"should conform to NSCoding", ^{
        NSData *archivedData = [NSKeyedArchiver archivedDataWithRootObject:formatter];
        MKOptionSetFormatter *copy = [NSKeyedUnarchiver unarchiveObjectWithData:archivedData];
        
        expect(copy.options).to.equal(formatter.options);
        expect(copy.zeroBehavior).to.equal(formatter.zeroBehavior);
    });
});

SpecEnd
