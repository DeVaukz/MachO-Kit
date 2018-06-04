//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKObjCProtocolList.m
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

#import "MKObjCProtocolList.h"
#import "MKInternal.h"
#import "MKObjCProtocol.h"

struct objc_protocollist_32 {
    uint32_t count;
    uint32_t list[0];
};

struct objc_protocollist_64 {
    uint64_t count;
    uint64_t list[0];
};

//----------------------------------------------------------------------------//
@implementation MKObjCProtocolList

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithOffset:(mk_vm_offset_t)offset fromParent:(MKBackedNode*)parent error:(NSError**)error
{
    self = [super initWithOffset:offset fromParent:parent error:error];
    if (self == nil) return nil;
    
    __block NSError *memoryMapError = nil;
    mk_error_t err;
    
    id<MKDataModel> dataModel = self.dataModel;
    size_t pointerSize = dataModel.pointerSize;
    size_t entsize = dataModel.pointerSize;
    
    if (pointerSize == 8)
    {
        struct objc_protocollist_64 lst;
        if ([self.memoryMap copyBytesAtOffset:offset fromAddress:parent.nodeContextAddress into:&lst length:sizeof(lst) requireFull:YES error:error] < sizeof(lst)) {
            MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_EINTERNAL_ERROR underlyingError:memoryMapError description:@"Could not read objc_protocollist."];
            [self release]; return nil;
        }
        
        _count = MKSwapLValue64(lst.count, dataModel);
        _nodeSize = sizeof(lst);
    }
    else if (pointerSize == 4)
    {
        struct objc_protocollist_32 lst;
        if ([self.memoryMap copyBytesAtOffset:offset fromAddress:parent.nodeContextAddress into:&lst length:sizeof(lst) requireFull:YES error:error] < sizeof(lst)) {
            MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_EINTERNAL_ERROR underlyingError:memoryMapError description:@"Could not read objc_protocollist."];
            [self release]; return nil;
        }
        
        _count = MKSwapLValue32(lst.count, dataModel);
        _nodeSize = sizeof(lst);
    }
    else
    {
        NSString *reason = [NSString stringWithFormat:@"Unsupported pointer size [%zu].", pointerSize];
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:nil];
    }
    
    // Compute the node size
    if ((err = mk_vm_size_add_with_multiply(_nodeSize, entsize, _count, &_nodeSize))) {
        MK_ERROR_OUT = MK_MAKE_VM_SIZE_ADD_WITH_MULTIPLY_ARITHMETIC_ERROR(err, _nodeSize, entsize, _count);
        [self release]; return nil;
    }
    
    // Check if the full length is mappable.  If it is not, shrink the size to
    // the mappable region and emit a warning.
    [self.memoryMap remapBytesAtOffset:0 fromAddress:self.nodeContextAddress length:_nodeSize requireFull:NO withHandler:^(__unused vm_address_t address, vm_size_t length, NSError *e) {
        if (address == 0x0) { memoryMapError = e; return; }
        
        if (length < _nodeSize) {
            MK_PUSH_WARNING(elements, MK_ESIZE, @"Expected protocol list size is [%" MK_VM_PRIuSIZE "] bytes but only [%" MK_VM_PRIuSIZE "] bytes could be read.  Truncating.", _nodeSize, length);
            _nodeSize = length;
        }
    }];
    
    if (memoryMapError) {
        MK_ERROR_OUT = memoryMapError;
        [self release]; return nil;
    }
    
    // In the inerest of robustness, we won't care if all/part of the node falls
    // outside of its parent's range.  However, we will emit a warning.
    mk_vm_range_t parentRange = mk_vm_range_make([(MKBackedNode*)self.parent nodeVMAddress], [(MKBackedNode*)self.parent nodeSize]);
    mk_vm_range_t nodeRange = mk_vm_range_make(self.nodeVMAddress, self.nodeSize);
    if (mk_vm_range_contains_range(parentRange, nodeRange, false)) {
        MK_PUSH_WARNING(nil, MK_EOUT_OF_RANGE, @"Protocol list size [%" MK_VM_PRIuSIZE "] extends beyond parent node: %@.", self.nodeSize, self.parent.nodeDescription);
    }
    
    // Load elements
    {
        NSMutableArray *elements = [[NSMutableArray alloc] initWithCapacity:(NSUInteger)_count];
        mk_vm_offset_t offset = pointerSize;
        
        for (uint32_t i = 0; i < _count; i++)
        {
            NSError *elementError = nil;
            
            MKPointerNode *element = [[MKPointerNode alloc] initWithOffset:offset fromParent:self targetClass:MKObjCProtocol.class error:&elementError];
            if (element == nil) {
                MK_PUSH_UNDERLYING_WARNING(elements, elementError, @"Could not parse element at index [%" PRIu32 "].", i);
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
                MK_PUSH_WARNING(elements, MK_EOUT_OF_RANGE, @"Part of element at index [%" PRIu32 "] is beyond protocol list size.", i);
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
- (void)dealloc
{
    [_elements release];
    
    [super dealloc];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  List Values
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@synthesize elements = _elements;
@synthesize count = _count;

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
    struct objc_protocollist_64 list64;
    struct objc_protocollist_32 list32;
    
    size_t pointerSize = self.dataModel.pointerSize;
    
#define FIELD_TYPE(type64, type32) (pointerSize == 8 ? type64.sharedInstance : type32.sharedInstance)
#define FIELD_OFFSET(field) (pointerSize == 8 ? offsetof(typeof(list64), field) : offsetof(typeof(list32), field))
#define FIELD_SIZE(field) (pointerSize == 8 ? sizeof(list64.field) : sizeof(list32.field))
    
    MKNodeFieldBuilder *count = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(count)
        type:FIELD_TYPE(MKNodeFieldTypeUnsignedQuadWord, MKNodeFieldTypeUnsignedDoubleWord)
        offset:FIELD_OFFSET(count)
        size:FIELD_SIZE(count)
    ];
    count.description = @"Count";
    count.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *elements = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(elements)
        type:[MKNodeFieldTypeCollection typeWithCollectionType:[MKNodeFieldTypeNode typeWithNodeType:MKObjCProtocol.class]]
    ];
    elements.description = @"Elements";
    elements.options = MKNodeFieldOptionDisplayAsDetail | MKNodeFieldOptionMergeContainerContents;
    
#undef FIELD_SIZE
#undef FIELD_OFFSET
#undef FIELD_TYPE
    
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        count.build,
        elements.build
    ]];
}

@end
