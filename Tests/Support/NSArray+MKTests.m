//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             NSArray+MKTests.m
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

#import "NSArray+MKTests.h"

//----------------------------------------------------------------------------//
@implementation NSArray (MKTests)

//|++++++++++++++++++++++++++++++++++++|//
- (void)mk_sliceWithTest:(NS_NOESCAPE BOOL (^)(id obj))test andEnumerate:(NS_NOESCAPE void (^)(id seperator, NSArray<id> *slice))enumerator
{
    NSRange range = NSMakeRange(0, 0);
    
    for (NSInteger i = (NSInteger)self.count - 1; i >= 0; i--) {
        NSString *obj = self[(NSUInteger)i];
        
        if (test(obj)) {
            enumerator(obj, [self subarrayWithRange:range]);
            
            range.length = 0;
        } else {
            range.location = (NSUInteger)i;
            range.length++;
        }
    }
    
    if (range.length > 0) {
        enumerator(nil, [self subarrayWithRange:range]);
    }
}

//|++++++++++++++++++++++++++++++++++++|//
- (void)mk_sliceWithHeirarchyTest:(NS_NOESCAPE NSUInteger (^)(id obj))test andEnumerate:(NS_NOESCAPE void (^)(id header, NSArray<id> *children))enumerator
{
    if (self.count < 1)
        return;
    
    NSUInteger currentLevel = test(self.firstObject);
    NSRange currentRange = NSMakeRange(0, 1);
    
    for (NSUInteger i = 1; i < self.count; i++) {
        NSUInteger level = test(self[i]);
        
        if (level <= currentLevel) {
            enumerator(self[currentRange.location++], --currentRange.length > 0 ? [self subarrayWithRange:currentRange] : nil);
            currentRange.location = i;
            currentRange.length = 1;
        } else {
            currentRange.length++;
        }
    }
    
    if (currentRange.length > 0) {
        enumerator(self[currentRange.location++], --currentRange.length > 0 ? [self subarrayWithRange:currentRange] : nil);
    }
    
    return;
}

@end
