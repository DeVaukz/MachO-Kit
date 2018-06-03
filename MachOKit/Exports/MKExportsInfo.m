//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKExportsInfo.m
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

#import "MKExportsInfo.h"
#import "NSError+MK.h"
#import "MKMachO.h"
#import "MKLCDyldInfo.h"
#import "MKExportTrieNode.h"
#import "MKExportTrieTerminalNode.h"
#import "MKExportTrieBranch.h"
#import "MKExport.h"

//----------------------------------------------------------------------------//
@implementation MKExportsInfo

@synthesize nodes = _nodes;
@synthesize exports = _exports;

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithSize:(mk_vm_size_t)size offset:(mk_vm_offset_t)offset inImage:(MKMachOImage*)image error:(NSError**)error
{
	self = [super initWithSize:size offset:offset inImage:image error:error];
	if (self == nil) return nil;
	
	// An size of zero indicates that the images does not have any exports.
	if (self.nodeSize == 0) {
		// Not an error.
		[self release]; return nil;
	}
	
	// Parse the trie
	{
		NSMutableArray<__kindof MKExportTrieNode*> *nodes = [[NSMutableArray alloc] initWithCapacity:(NSUInteger)self.nodeSize/64];
		mk_vm_offset_t offset = 0;
		
		while (offset < self.nodeSize)
		{
			NSError *trieNodeError = nil;
			
			MKExportTrieNode *node = [MKExportTrieNode nodeAtOffset:offset fromParent:self error:&trieNodeError];
			if (node == nil) {
				// TODO - If a malformed Mach-O added garbage data between nodes it would
				// break our current parsing approach but would not (afaict) be rejected by
				// dyld.  Our parsing should be improved to handle this case.
				MK_PUSH_UNDERLYING_WARNING(nodes, trieNodeError, @"Could not parse trie node at offset [%" MK_VM_PRIiOFFSET "].", offset);
				break;
			}
			
			[nodes addObject:node];
			
			// SAFE - All trie nodes must be within the size of this node.
			offset += node.nodeSize;
		}
		
		_nodes = [nodes copy];
		[nodes release];
	}
	
	// Build the exports list
	@autoreleasepool
	{
        NSMutableArray<MKExport*> *exports = [[NSMutableArray alloc] init];
		
		if (_nodes.count > 0)
		{
			// depth first, postorder traversal
			
			NSMutableArray<MKExportTrieNode*> *path = [[NSMutableArray alloc] init];
			NSMutableArray<__kindof MKNode*> *queue = [[NSMutableArray alloc] init];
			
			// Seed the queue with the root node
			[path addObject:_nodes.firstObject];
			[queue addObject:_nodes.firstObject];
			for (id child in _nodes.firstObject.branches.reverseObjectEnumerator)
				[queue addObject:child];
			
			while (queue.count != 0) {
				__kindof MKNode *next = queue.lastObject;
				[queue removeLastObject];
				
				if ([next isKindOfClass:MKExportTrieBranch.class]) {
					NSError *traversalError = nil;
					MKExportTrieBranch *branch = next;
					mk_vm_address_t targetAddress;
					mk_error_t err;
					
					if ((err = mk_vm_address_apply_offset(self.nodeVMAddress, branch.offset, &targetAddress))) {
						traversalError = MK_MAKE_VM_ADDRESS_APPLY_OFFSET_ARITHMETIC_ERROR(err, self.nodeVMAddress, branch.offset);
						MK_PUSH_WARNING_WITH_ERROR(exports, MK_ENOT_FOUND, traversalError, @"Could not locate the trie node referenced by branch %@ of %@.", branch.nodeDescription, branch.parent.nodeDescription);
						continue;
					}
					
					MKOptional<MKExportTrieNode*> *targetNode = (typeof(targetNode))[self childNodeAtVMAddress:targetAddress targetClass:MKExportTrieNode.class];
					if (targetNode.value == nil) {
						traversalError = [NSError mk_errorWithDomain:MKErrorDomain code:MK_ENOT_FOUND underlyingError:targetNode.error description:@"No trie node at address [0x%" MK_VM_PRIxADDR "]", targetAddress];
						MK_PUSH_WARNING_WITH_ERROR(exports, MK_ENOT_FOUND, traversalError, @"Could not locate the trie node referenced by branch %@ of %@.", branch.nodeDescription, branch.parent.nodeDescription);
						continue;
					}
					
					[path addObject:targetNode.value];
					[queue addObject:targetNode.value];
					for (id child in targetNode.value.branches.reverseObjectEnumerator)
						[queue addObject:child];
					
				} else {
					NSAssert(next == path.lastObject, @"Branch mismatch.");
					
					if ([next isKindOfClass:MKExportTrieTerminalNode.class]) {
						NSError *exportError = nil;
						MKExport *export = [MKExport exportForTrieNodes:path error:&exportError];
						
						if (export) {
							[exports addObject:export];
						} else {
							MK_PUSH_WARNING_WITH_ERROR(exports, MK_EINTERNAL_ERROR, exportError, @"Could not create export for terminal node %@.", next.nodeDescription);
						}
					}
					
					[path removeLastObject];
				}
			}
			
			[queue release];
			[path release];
			
			[exports sortUsingComparator:^(MKExport *left, MKExport *right) {
				if (left.nodeVMAddress < right.nodeVMAddress) return NSOrderedAscending;
				else if (left.nodeVMAddress > right.nodeVMAddress) return NSOrderedDescending;
				else return NSOrderedSame;
			}];
		}
		
        _exports = [exports copy];
        [exports release];
	}
	
	return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)_initWithDyldInfo:(MKLCDyldInfo*)dyldInfo inImage:(MKMachOImage*)image error:(NSError**)error
{ return [self initWithSize:dyldInfo.export_size offset:dyldInfo.export_off inImage:image error:error]; }

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithImage:(MKMachOImage*)image error:(NSError**)error
{
	NSParameterAssert(image != nil);
	
	// Find LC_DYLD_INFO
	MKLCDyldInfo *dyldInfoLoadCommand = nil;
	{
		NSMutableArray *commands = [[NSMutableArray alloc] initWithCapacity:1];
		
		NSArray *dyldInfoCommands = [image loadCommandsOfType:LC_DYLD_INFO];
		if (dyldInfoCommands) [commands addObjectsFromArray:dyldInfoCommands];
		
		NSArray *dyldInfoOnlyCommands = [image loadCommandsOfType:LC_DYLD_INFO_ONLY];
		if (dyldInfoOnlyCommands) [commands addObjectsFromArray:dyldInfoOnlyCommands];
		
		if (commands.count > 1)
			MK_PUSH_WARNING(nil, MK_EINVALID_DATA, @"Image contains multiple LC_DYLD_INFO load commands.  Ignoring %@.", commands.lastObject);
		
		if (commands.count == 0) {
			MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_ENOT_FOUND description:@"Image does not contain a LC_DYLD_INFO load command."];
			[commands release];
			[self release]; return nil;
		}
		
		dyldInfoLoadCommand = [[commands.firstObject retain] autorelease];
		[commands release];
	}
	
	return [self _initWithDyldInfo:dyldInfoLoadCommand inImage:image error:error];
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithParent:(MKNode*)parent error:(NSError**)error
{ return [self initWithImage:parent.macho error:error]; }

//|++++++++++++++++++++++++++++++++++++|//
- (void)dealloc
{
    [_exports release];
	[_nodes release];
	
	[super dealloc];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  MKPointer
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (MKOptional*)childNodeOccupyingVMAddress:(mk_vm_address_t)address targetClass:(Class)targetClass
{
	for (MKExportTrieNode *node in self.nodes) {
		mk_vm_range_t range = mk_vm_range_make(node.nodeVMAddress, node.nodeSize);
		if (mk_vm_range_contains_address(range, 0, address) == MK_ESUCCESS) {
			MKOptional *child = [node childNodeOccupyingVMAddress:address targetClass:targetClass];
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
- (MKNodeDescription*)layout
{
	MKNodeFieldBuilder *nodes = [MKNodeFieldBuilder
		builderWithProperty:MK_PROPERTY(nodes)
		type:[MKNodeFieldTypeCollection typeWithCollectionType:[MKNodeFieldTypeNode typeWithNodeType:MKExportTrieNode.class]]
	];
	nodes.description = @"Opcodes";
	nodes.options = MKNodeFieldOptionDisplayAsChild | MKNodeFieldOptionDisplayCollectionContentsAsDetail;
	
	MKNodeFieldBuilder *exports = [MKNodeFieldBuilder
		builderWithProperty:MK_PROPERTY(exports)
		type:[MKNodeFieldTypeCollection typeWithCollectionType:[MKNodeFieldTypeNode typeWithNodeType:MKExport.class]]
	];
	exports.description = @"Exports";
	exports.options = MKNodeFieldOptionDisplayAsChild | MKNodeFieldOptionDisplayCollectionContentsAsDetail;
	
	return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
		nodes.build,
		exports.build
	]];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  NSObject
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (NSString*)description
{ return @"Export Info"; }

@end
