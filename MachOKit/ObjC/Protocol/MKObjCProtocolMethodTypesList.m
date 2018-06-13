//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKObjCProtocolMethodTypesList.m
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

#import "MKObjCProtocolMethodTypesList.h"
#import "MKInternal.h"

//----------------------------------------------------------------------------//
@implementation MKObjCProtocolMethodTypesList

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithOffset:(mk_vm_offset_t)offset methodCount:(uint32_t)count fromParent:(MKBackedNode*)parent error:(NSError**)error
{
    self = [super initWithOffset:offset fromParent:parent error:error];
    if (self == nil) return nil;
    
    __block NSError *memoryMapError = nil;
    mk_error_t err;
    
    size_t entsize = self.dataModel.pointerSize;
    
    // Compute the node size
    if ((err = mk_vm_size_multiply(entsize, count, &_nodeSize))) {
        MK_ERROR_OUT = MK_MAKE_VM_SIZE_MULTIPLY_ARITHMETIC_ERROR(err, entsize, count);
        [self release]; return nil;
    }
    
    // Check if the full length is mappable.  If it is not, shrink the size to
    // the mappable region and emit a warning.
    [self.memoryMap remapBytesAtOffset:0 fromAddress:self.nodeContextAddress length:_nodeSize requireFull:NO withHandler:^(vm_address_t address, vm_size_t length, NSError *e) {
        if (address == 0x0) { memoryMapError = e; return; }
        
        if (length < _nodeSize) {
            MK_PUSH_WARNING(elements, MK_ESIZE, @"Expected list size is [%" MK_VM_PRIuSIZE "] bytes but only [%" MK_VM_PRIuSIZE "] bytes could be read.  Truncating.", _nodeSize, length);
            _nodeSize = length;
        }
    }];
    
    if (memoryMapError) {
        MK_ERROR_OUT = memoryMapError;
        [self release]; return nil;
    }
    
    // In the interest of robustness, we won't care if all/part of the node falls
    // outside of its parent's range.  However, we will emit a warning.
    mk_vm_range_t parentRange = mk_vm_range_make([(MKBackedNode*)self.parent nodeVMAddress], [(MKBackedNode*)self.parent nodeSize]);
    mk_vm_range_t nodeRange = mk_vm_range_make(self.nodeVMAddress, self.nodeSize);
    if (mk_vm_range_contains_range(parentRange, nodeRange, false)) {
        MK_PUSH_WARNING(nil, MK_EOUT_OF_RANGE, @"List size [%" MK_VM_PRIuSIZE "] extends beyond parent node: %@.", self.nodeSize, self.parent.nodeDescription);
    }
    
    // Load elements
    {
        NSMutableArray *elements = [[NSMutableArray alloc] initWithCapacity:count];
        mk_vm_offset_t offset = 0;
        
        for (uint32_t i = 0; i < count; i++)
        {
            NSError *elementError = nil;
            
            MKPointerNode *element = [[MKPointerNode alloc] initWithOffset:offset fromParent:self targetClass:MKCString.class error:&elementError];
            if (element == nil) {
                MK_PUSH_WARNING_WITH_ERROR(elements, MK_EINTERNAL_ERROR, elementError, @"Could not parse element at index [%" PRIu32 "].", i);
                // We might be able to continue parsing additional elemements,
                // but that would break the ordering so just stop here.
                break;
            }
            
            // Use the entsize, rather than the parsed element's nodeSize, when
            // advancing the offset.
            // SAFE - Computing the node size would have failed if this could
            //        overflow.
            offset += entsize;
            
            if (element.nodeSize != entsize) {
                MK_PUSH_WARNING(elements, MK_ESIZE, @"Element at index [%" PRIu32 "] has an unexpected size.  Expected [%" PRIu32 "] bytes but parsed [" MK_VM_PRIuSIZE "] bytes.", i, entsize, element.nodeSize);
            }
            
            // While we could permit readable elements that extend beyond the
            // size computed from the list header, that could potentially give
            // invalid data.
            if (offset > _nodeSize) {
                MK_PUSH_WARNING(elements, MK_EOUT_OF_RANGE, @"Part of element at index [%" PRIu32 "] is beyond list size.", i);
                [element release];
                break;
            }
            
            [elements addObject:element];
            [element release];
        }
        
        _elements = [elements copy];
        [elements release];
    }
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithOffset:(mk_vm_offset_t)offset fromParent:(MKBackedNode*)parent error:(NSError**)error
{
    NSNumber *methodCount = NSThread.currentThread.threadDictionary[@"ExtendedTypeInfoCount"];
    if ([methodCount isKindOfClass:NSNumber.class] == NO) {
        MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:0 description:@"Missing required context."];
        [self release]; return nil;
    }
    
    return [self initWithOffset:offset methodCount:methodCount.unsignedIntValue fromParent:parent error:error];
}

//|++++++++++++++++++++++++++++++++++++|//
- (void)dealloc
{
    [_elements release];
    
    [super dealloc];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  List Values
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@synthesize elements = _elements;

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

@synthesize nodeSize = _nodeSize;

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    MKNodeFieldBuilder *elements = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(elements)
        type:[MKNodeFieldTypeCollection typeWithCollectionType:[MKNodeFieldTypeNode typeWithNodeType:MKCString.class]]
    ];
    elements.description = @"Elements";
    elements.options = MKNodeFieldOptionDisplayAsDetail | MKNodeFieldOptionMergeContainerContents;
    
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        elements.build
    ]];
}

@end
