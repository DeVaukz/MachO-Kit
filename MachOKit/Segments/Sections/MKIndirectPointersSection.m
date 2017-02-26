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

@synthesize pointers = _pointers;
@synthesize indirectSymbolIndex = _indirectSymbolIndex;

//|++++++++++++++++++++++++++++++++++++|//
+ (uint32_t)canInstantiateWithSectionLoadCommand:(id<MKLCSection>)sectionLoadCommand inSegment:(MKSegment*)segment
{
#pragma unused (segment)
    
    MKSectionType type = [sectionLoadCommand flags] & SECTION_TYPE;
    return (type == MKSectionTypeLazySymbolPointers || type == MKSectionTypeNonLazySymbolPointers) ? 50 : 0;
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithLoadCommand:(id<MKLCSection>)sectionLoadCommand inSegment:(MKSegment*)segment error:(NSError**)error
{
    self = [super initWithLoadCommand:sectionLoadCommand inSegment:segment error:error];
    if (self == nil) return nil;
    
    _indirectSymbolIndex = [sectionLoadCommand reserved1];
    
    NSMutableArray<MKIndirectPointer*> *pointers = [[NSMutableArray alloc] init];
    mk_vm_offset_t offset = 0;
    
    // Cast to mk_vm_size_t is safe; nodeSize can't be larger than UINT32_MAX.
    while ((mk_vm_size_t)offset < self.nodeSize)
    {
        NSError *e = nil;
        MKIndirectPointer *pointer = [[MKIndirectPointer alloc] initWithOffset:offset fromParent:self error:&e];
        if (pointer == nil) {
            MK_PUSH_UNDERLYING_WARNING(MK_PROPERTY(pointers), e, @"Could not load pointer at offset %" MK_VM_PRIiOFFSET ".", offset);
            break;
        }
        
        [pointers addObject:pointer];
        [pointer release];
        
        // Safe.  All pointers must be within the size of this node.
        offset += pointer.nodeSize;
    }
    
    _pointers = [pointers copy];
    [pointers release];
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (void)dealloc
{
    [_pointers release];
    
    [super dealloc];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        [MKNodeField nodeFieldWithProperty:MK_PROPERTY(pointers) description:@"Pointers"]
    ]];
}

@end
