//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKPointerListSection.m
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

#import "MKPointerListSection.h"
#import "MKInternal.h"
#import "MKNodeDescription.h"

#include <objc/message.h>

//----------------------------------------------------------------------------//
@implementation MKPointerListSection

//|++++++++++++++++++++++++++++++++++++|//
+ (uint32_t)canInstantiateWithSectionLoadCommand:(id<MKLCSection>)sectionLoadCommand inSegment:(MKSegment*)segment
{
#pragma unused (segment)
    if (self != MKPointerListSection.class)
        return 0;
    
    if ((sectionLoadCommand.flags & SECTION_TYPE) == S_LITERAL_POINTERS)
        return 20;
    
    return 0;
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithLoadCommand:(id<MKLCSection>)sectionLoadCommand inSegment:(MKSegment*)segment error:(NSError**)error
{
    self = [super initWithLoadCommand:sectionLoadCommand inSegment:segment error:error];
    if (self == nil) return nil;
    
    // Load pointers
    {
        NSMutableArray<MKPointerNode*> *pointers = [[NSMutableArray alloc] init];
        mk_vm_offset_t offset = 0;
        
        Class targetClass = nil;
        // Hack Hack - The -classForGenericArgumentAtIndex: isn't defined in
        //             SDK headers, which causes warnings.
        if ([self.class respondsToSelector:sel_getUid("classForGenericArgumentAtIndex:")])
            targetClass = ((Class(*)(id, SEL, NSUInteger))objc_msgSend)(self.class, sel_getUid("classForGenericArgumentAtIndex:"), 0);
        
        while (offset < self.nodeSize)
        {
            NSError *pointerError = nil;
            
            MKPointerNode *pointer = [[MKPointerNode alloc] initWithOffset:offset fromParent:self targetClass:targetClass error:&pointerError];
            if (pointer == nil) {
                MK_PUSH_WARNING_WITH_ERROR(references, MK_EINTERNAL_ERROR, pointerError, @"Could not parse pointer at offset [%" MK_VM_PRIuOFFSET "].", offset);
                break;
            }
            
            [pointers addObject:pointer];
            [pointer release];
            
            // SAFE - All pointer nodes must be within the size of this node.
            offset += pointer.nodeSize;
        }
        
        _pointerList = [pointers copy];
        [pointers release];
    }
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (void)dealloc
{
    [_pointerList release];
    
    [super dealloc];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Section Values
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@synthesize elements = _pointerList;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  MKPointer
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (MKOptional*)childNodeOccupyingVMAddress:(mk_vm_address_t)address targetClass:(Class)targetClass
{
    for (MKOffsetNode *element in self.elements) {
        mk_vm_range_t range = mk_vm_range_make(element.nodeVMAddress, element.nodeSize);
        if (mk_vm_range_contains_address(range, 0, address) == MK_ESUCCESS) {
            MKOptional *child = [element childNodeOccupyingVMAddress:address targetClass:targetClass];
            if (child.value)
                return child;
            // else, fallthrough and call the super's implementation.
            // The caller may actually be looking for *this* node.
        }
    }
    
    return [super childNodeOccupyingVMAddress:address targetClass:targetClass];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
+ (MKNodeFieldBuilder*)_elementsFieldBuilder
{
    MKNodeFieldBuilder *elements = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(elements)
        type:[MKNodeFieldTypeCollection typeWithCollectionType:[MKNodeFieldTypeNode typeWithNodeType:MKPointerNode.class]]
    ];
    elements.description = @"Element List";
    elements.options = MKNodeFieldOptionDisplayAsDetail | MKNodeFieldOptionMergeContainerContents;
    
    return elements;
}

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        self.class._elementsFieldBuilder.build
    ]];
}

@end
