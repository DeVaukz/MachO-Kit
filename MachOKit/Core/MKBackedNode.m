//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKBackedNode.m
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

#import "MKBackedNode.h"
#import "MKInternal.h"

//----------------------------------------------------------------------------//
@implementation MKBackedNode

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithParent:(MKNode*)parent error:(NSError**)error
{
    if (parent && ![parent isKindOfClass:MKBackedNode.class]) {
        NSString *reason = [NSString stringWithFormat:@"The parent of an MKBackedNode must be an MKBackedNode, not %@.", NSStringFromClass(parent.class)];
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:nil];
    }
    
    return [super initWithParent:parent error:error];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Memory Layout
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_size_t)nodeSize
{ @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Subclasses must implement -nodeSize." userInfo:nil]; }

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Accessing the Underlying Data
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (NSData*)data
{ return [self.memoryMap dataAtOffset:0 fromAddress:self.nodeContextAddress length:self.nodeSize requireFull:YES error:NULL]; }

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Looking Up Ancestor Nodes By Address
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (MKResult*)ancestorNodeOccupyingAddress:(mk_vm_address_t)address type:(MKNodeAddressType)addressType targetClass:(Class)targetClass includeReceiver:(BOOL)includeReceiver
{
	MKBackedNode *node = includeReceiver ? self : (MKBackedNode*)self.parent;
	
	// Walk up the parent chain until we find a node containing the address.
	for (; node && [node isKindOfClass:MKBackedNode.class]; node = (MKBackedNode*)node.parent) {
		if (targetClass && ![node isKindOfClass:targetClass])
			continue;
		
		mk_vm_range_t nodeRange = mk_vm_range_make([node nodeAddress:addressType], node.nodeSize);
		
		// TODO - Rework MKMachOImage so that we don't need this hack.
		if (nodeRange.length == 0)
			return [MKResult resultWithValue:node];
		
		if (mk_vm_range_contains_address(nodeRange, 0, address) == MK_ESUCCESS)
			return [MKResult resultWithValue:node];
	}
	
	return [MKResult result];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Looking Up Child Nodes By Address
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (MKResult*)childNodeOccupyingVMAddress:(mk_vm_address_t)address targetClass:(Class)targetClass
{
	mk_vm_range_t range = mk_vm_range_make(self.nodeVMAddress, self.nodeSize);
	if (mk_vm_range_contains_address(range, 0, address) == MK_ESUCCESS && (targetClass == nil || [self isKindOfClass:targetClass]))
		return [MKResult resultWithValue:self];
	else
		return [MKResult result];
}

//|++++++++++++++++++++++++++++++++++++|//
- (MKResult*)childNodeAtVMAddress:(mk_vm_address_t)address targetClass:(Class)targetClass
{
	MKResult<MKBackedNode*> *child = [self childNodeOccupyingVMAddress:address targetClass:nil];
	
	// Some nodes may want to 'create' the child node upon request.
	if (child.value && child.value != self)
		child = [child.value childNodeAtVMAddress:address targetClass:targetClass];
	
	if (child.value) {
		if (child.value.nodeVMAddress == address && (targetClass == nil || [child.value isKindOfClass:targetClass]))
			// Found a child node at address
			return child;
		else
			// Did not find a child node at address, or the class did not match
			return [MKResult result];
	} else
		// There was an error finding (or creating) the child node at address.
		return child;
}

//|++++++++++++++++++++++++++++++++++++|//
- (MKResult*)childNodeAtVMAddress:(mk_vm_address_t)address
{ return [self childNodeAtVMAddress:address targetClass:nil]; }

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Node Array Searching & Sorting
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

+ (NSArray<__kindof MKBackedNode *> *)sortNodeArray:(NSArray<MKResult<__kindof MKBackedNode *> *> *)array
{
    NSMutableArray *filteredArray = [NSMutableArray arrayWithCapacity:array.count];
    for (MKResult *node in array) {
        if (node.value)
            [filteredArray addObject:node.value];
    }
    [filteredArray sortUsingComparator:^NSComparisonResult(MKBackedNode *left, MKBackedNode *right) {
        mk_vm_address_t leftAddr = left.nodeVMAddress;
        mk_vm_address_t rightAddr = right.nodeVMAddress;
        if (leftAddr == rightAddr) return NSOrderedSame;
        else if (leftAddr < rightAddr) return NSOrderedAscending;
        else return NSOrderedDescending;
    }];
    return [[filteredArray copy] autorelease];
}

+ (MKResult<__kindof MKBackedNode *> *)childNodeOccupyingVMAddress:(mk_vm_address_t)address targetClass:(Class)targetClass inSortedArray:(NSArray<__kindof MKBackedNode *> *)array {
    NSInteger lo = 0;
    NSInteger hi = (NSInteger)array.count - 1;
    while (lo <= hi) {
        NSInteger mid = (lo + hi) / 2;
        MKBackedNode *midElement = array[(NSUInteger)mid];
        mk_vm_address_t midAddress = midElement.nodeVMAddress;
        
        // do this check first since if address is lower than midAddress, midElement can't
        // contain it and we can skip the range check
        if (address < midAddress) {
            hi = mid - 1;
            continue;
        }
        
        // if address >= midAddress, check if it's within midElement's range
        mk_vm_range_t range = mk_vm_range_make(midAddress, midElement.nodeSize);
        if (mk_vm_range_contains_address(range, 0, address) == MK_ESUCCESS) {
            return [midElement childNodeOccupyingVMAddress:address targetClass:targetClass];
        } else {
            // address is higher than midElement
            lo = mid + 1;
        }
    }
    return [MKResult result];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  NSObject
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (NSString*)compactDescription
{
	IMP nodeDescriptionMethod = [MKBackedNode instanceMethodForSelector:@selector(description)];
	IMP descriptionMethod = [self methodForSelector:@selector(description)];
	
	if (descriptionMethod != nodeDescriptionMethod)
		return [NSString stringWithFormat:@"<%@: address = 0x%" MK_VM_PRIxADDR ", size = 0x%" MK_VM_PRIxSIZE ", %@>", NSStringFromClass(self.class), self.nodeContextAddress, self.nodeSize, self.description];
	else
    	return [NSString stringWithFormat:@"<%@: address = 0x%" MK_VM_PRIxADDR ", size = 0x%" MK_VM_PRIxSIZE ">", NSStringFromClass(self.class), self.nodeContextAddress, self.nodeSize];
}

//|++++++++++++++++++++++++++++++++++++|//
- (NSString*)description
{
	return [NSString stringWithFormat:@"<%@ %p: address = 0x%" MK_VM_PRIxADDR ", size = 0x%" MK_VM_PRIxSIZE ">", NSStringFromClass(self.class), self, self.nodeContextAddress, self.nodeSize];
}

@end
