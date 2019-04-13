//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKIndirectPointersSection.m
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

#import "MKIndirectPointersSection.h"
#import "MKInternal.h"

//----------------------------------------------------------------------------//
@implementation MKIndirectPointersSection

//|++++++++++++++++++++++++++++++++++++|//
+ (uint32_t)canInstantiateWithSectionLoadCommand:(id<MKLCSection>)sectionLoadCommand inSegment:(MKSegment*)segment
{
#pragma unused (segment)
    if (self != MKIndirectPointersSection.class)
        return 0;
    
    if ((sectionLoadCommand.flags & SECTION_TYPE) == S_LAZY_SYMBOL_POINTERS)
        return 50;
    
    if ((sectionLoadCommand.flags & SECTION_TYPE) == S_NON_LAZY_SYMBOL_POINTERS)
        return 50;
    
    if ((sectionLoadCommand.flags & SECTION_TYPE) == S_LAZY_DYLIB_SYMBOL_POINTERS)
        return 50;
    
    return 0;
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithLoadCommand:(id<MKLCSection>)sectionLoadCommand inSegment:(MKSegment*)segment error:(NSError**)error
{
    self = [super initWithLoadCommand:sectionLoadCommand inSegment:segment error:error];
    if (self == nil) return nil;
    
    _indirectSymbolTableIndex = [sectionLoadCommand reserved1];
    
    return self;
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Section Values
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@synthesize indirectSymbolTableIndex = _indirectSymbolTableIndex;

//|++++++++++++++++++++++++++++++++++++|//
- (NSRange)indirectSymbolTableRange
{
    uint32_t index = self.indirectSymbolTableIndex;
    // SAFE - nodeSize can't be larger than uint32_t.
    uint32_t count = (uint32_t)self.nodeSize / self.indirectSymbolTableEntrySize;
    
    return NSMakeRange(index, count);
}

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_size_t)indirectSymbolTableEntrySize
{ return self.dataModel.pointerSize; }

@end
