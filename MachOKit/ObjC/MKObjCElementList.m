//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKObjCElementList.m
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

#import "MKObjCElementList.h"
#import "NSError+MK.h"
#import "MKBackedNode+Pointer.h"

struct objc_entlist {
    uint32_t entsizeAndFlags;
    uint32_t count;
    uint8_t bytes[0];
};

//----------------------------------------------------------------------------//
@implementation MKObjCElementList

//|++++++++++++++++++++++++++++++++++++|//
+ (Class)classForGenericArgumentAtIndex:(__unused NSUInteger)index
{ @throw [NSException exceptionWithName:NSGenericException reason:@"Subclasses must implement +classForGenericArgumentAtIndex:" userInfo:nil];; }

//|++++++++++++++++++++++++++++++++++++|//
+ (uint32_t)flagMask
{ return 0; }

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithOffset:(mk_vm_offset_t)offset fromParent:(MKBackedNode*)parent error:(NSError**)error
{
    self = [super initWithOffset:offset fromParent:parent error:error];
    if (self == nil) return nil;
    
    id<MKDataModel> dataModel = self.dataModel;
    NSAssert(dataModel != nil, @"Parent node must have a data model.");
    
    __block NSError *localError = nil;
    mk_error_t err;
    
    struct objc_entlist lst;
    if ([self.memoryMap copyBytesAtOffset:offset fromAddress:parent.nodeContextAddress into:&lst length:sizeof(lst) requireFull:YES error:error] < sizeof(lst))
    { [self release]; return nil; }
    
    _entsizeAndFlags = MKSwapLValue32(lst.entsizeAndFlags, dataModel);
    _count = MKSwapLValue32(lst.count, dataModel);
    
    // Compute the node size
    if ((err = mk_vm_size_add_with_multiply(sizeof(struct objc_entlist), self.entsize, _count, &_nodeSize))) {
        MK_ERROR_OUT = MK_MAKE_VM_SIZE_ADD_WITH_MULTIPLY_ARITHMETIC_ERROR(err, _nodeSize, self.entsize, _count);
        [self release]; return nil;
    }
    
    // Check if the full length is mappable.  If it is not, shrink the size to
    // the mappable region and emit a warning.
    [self.memoryMap remapBytesAtOffset:0 fromAddress:self.nodeContextAddress length:_nodeSize requireFull:NO withHandler:^(__unused vm_address_t address, vm_size_t length, NSError *e) {
        if (length == 0 || e) {
            localError = e;
            return;
        }
        
        if (length < _nodeSize) {
            _nodeSize = length;
            // TODO - Warning.
        }
    }];
    
    if (localError) {
        MK_ERROR_OUT = localError;
        [self release]; return nil;
    }
    
    // In the inerest of robustness, we won't care if all/part of the node falls
    // outside of its parent's range.  However, we will emit a warning.
    // TODO - Warning.
    
    // Load elements
    {
        NSMutableArray *elements = [[NSMutableArray alloc] initWithCapacity:_count];
        
        Class targetClass = [self.class classForGenericArgumentAtIndex:0];
        
        mk_vm_offset_t offset = offsetof(typeof(lst), bytes);
        
        for (uint32_t i = 0; i < _count; i++) {
            NSError *e = nil;
            
            MKOffsetNode *element = [[targetClass alloc] initWithOffset:offset fromParent:self error:&e];
            
            // Use the entsize, rather than the parsed element's nodeSize, when
            // advancing the offset.
            offset += self.entsize;
            
            if (element == nil) {
                MK_PUSH_UNDERLYING_WARNING(ivars, e, @"Failed to load element at index %" PRIu32 ".", i);
                // We might be able to continue parsing additional elemements,
                // but that would break the ordering so just stop here.
                break;
            }
            else if (element.nodeSize != self.entsize) {
                MK_PUSH_WARNING(elements, MK_ESIZE, @"Element at index %" PRIu32 " has an unexpected size.  Expected " PRIu32 " bytes, parsed " MK_VM_PRIuSIZE " bytes.", i, self.entsize, element.nodeSize);
            }
            
            // While we could permit readable elements that extend beyond the
            // size computed from the list header, that could potentially give
            // invalid data.
            if (offset > _nodeSize) {
                MK_PUSH_WARNING(elements, MK_EOUT_OF_RANGE, @"Part of element at index %" PRIu32 " is beyond element list size.", i);
                break;
            }
            
            [elements addObject:element];
            [element release];
            
            // No need for an overflow check - (entsize * _count) was previously
            // determined to be safe.
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
#pragma mark - Values
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@synthesize elements = _elements;
@synthesize count = _count;

//|++++++++++++++++++++++++++++++++++++|//
- (uint32_t)flags
{ return _entsizeAndFlags & self.class.flagMask; }

//|++++++++++++++++++++++++++++++++++++|//
- (uint32_t)entsize
{ return _entsizeAndFlags & ~self.class.flagMask; }

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - MKPointer
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
#pragma mark - MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@synthesize nodeSize = _nodeSize;

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    struct objc_entlist lst;
    
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(entsize) description:@"Entry Size" offset:offsetof(typeof(lst), entsizeAndFlags) size:sizeof(lst.entsizeAndFlags)],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(count) description:@"Count" offset:offsetof(typeof(lst), count) size:sizeof(lst.count)],
        [MKNodeField nodeFieldWithProperty:MK_PROPERTY(elements) description:@"Elements"]
    ]];
}

@end
