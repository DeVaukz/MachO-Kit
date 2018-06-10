//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKExportTrieNode.m
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

#import "MKExportTrieNode.h"
#import "MKInternal.h"
#import "MKLEB.h"
#import "MKExportsInfo.h"
#import "MKExportTrieBranch.h"

//----------------------------------------------------------------------------//
@implementation MKExportTrieNode

//|++++++++++++++++++++++++++++++++++++|//
+ (id*)_subclassesCache
{ static NSSet *subclasses; return &subclasses; }

//|++++++++++++++++++++++++++++++++++++|//
+ (uint32_t)canInstantiateWithTerimalSize:(uint64_t)terminalSize contents:(uint8_t*)contents
{
#pragma unused(terminalSize)
#pragma unused(contents)
    if (self != MKExportTrieNode.class)
        return 0;
    
    return 10;
}

//|++++++++++++++++++++++++++++++++++++|//
+ (Class)classForNodeWithTerimalSize:(uint64_t)terminalSize contents:(uint8_t*)contents
{
	return [self bestSubclassWithRanking:^(Class cls) {
		return [cls canInstantiateWithTerimalSize:terminalSize contents:contents];
	}];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -	Creating a Node
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
bool ReadTerminalSize(uint64_t *result, size_t *size, mk_vm_offset_t offset, MKBackedNode *node, NSError **error)
{
	// Most terminal sizes fit within a single byte
	{
		uint8_t terminalSize = 0;
		
		if ([node.memoryMap copyBytesAtOffset:offset fromAddress:node.nodeContextAddress into:&terminalSize length:sizeof(uint8_t) requireFull:YES error:error] < sizeof(uint8_t))
			return false;
		
		*result = terminalSize;
		*size = 1;
	}
    
    if (*result > 127)
	{
		if (!MKULEBRead(node, offset, result, size, error))
			return false;
    }
    
    return true;
}

//|++++++++++++++++++++++++++++++++++++|//
+ (nullable instancetype)nodeAtOffset:(mk_vm_offset_t)offset fromParent:(MKExportsInfo*)parent error:(NSError**)error
{
	__block NSError *memoryMapError = nil;
	uint64_t terminalSize;
	size_t ulebSize;
	
	if (ReadTerminalSize(&terminalSize, &ulebSize, offset, parent, &memoryMapError) == false) {
		MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_EINTERNAL_ERROR underlyingError:memoryMapError description:@"Could not read terminal size at offset [%" MK_VM_PRIuOFFSET "] from %@.", offset, parent.nodeDescription];
		return nil;
	}
	
	// SAFE - Memory reading would have failed.
	mk_vm_address_t address = parent.nodeContextAddress + offset;
	__block Class nodeClass = nil;
	
	[parent.memoryMap remapBytesAtOffset:ulebSize fromAddress:address length:terminalSize requireFull:YES withHandler:^(vm_address_t address, __unused vm_size_t length, NSError *e) {
		if (address == 0x0) { memoryMapError = e; return; }
		
		nodeClass = [self classForNodeWithTerimalSize:terminalSize contents:(uint8_t*)address];
	}];
	
	if (memoryMapError) {
		MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_EINTERNAL_ERROR underlyingError:memoryMapError description:@"Could not read terminal information at offset [%" MK_VM_PRIuOFFSET "] from %@.", offset + ulebSize, parent.nodeDescription];
		return false;
	}
	
	NSAssert(nodeClass != nil, @"No class for trie node.");
    return [[[nodeClass alloc] initWithOffset:offset fromParent:parent error:error] autorelease];
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithOffset:(mk_vm_offset_t)offset fromParent:(MKBackedNode*)parent error:(NSError**)error
{
    self = [super initWithOffset:offset fromParent:parent error:error];
    if (self == nil) return nil;
	
    mk_error_t err;
    
    offset = 0;
	
    // Read terminal information size
	{
		NSError *terminalSizeError = nil;
		
		if (ReadTerminalSize(&_terminalInformationSize, &_terminalInformationSizeULEBSize, 0, self, &terminalSizeError) == false) {
			MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_EINTERNAL_ERROR underlyingError:terminalSizeError description:@"Could not read terminal size."];
			[self release]; return nil;
		}
		
		offset += _terminalInformationSizeULEBSize;
	}
	
	// Parse terminal information.
	if ([self _parseTerminalInformationAtOffset:offset error:error] == NO) {
		[self release]; return nil;
	}
	
	// Branch information begins after the terminal information, the size of which was
	// read from the terminal size.
    if ((err = mk_vm_offset_add(offset, _terminalInformationSize, &offset))) {
        MK_ERROR_OUT = MK_MAKE_VM_OFFSET_ADD_ARITHMETIC_ERROR(err, offset, _terminalInformationSize);
        [self release]; return nil;
    }
    
    // Read the branches
	{
		NSError *branchError = nil;
		
		if ([self.memoryMap copyBytesAtOffset:offset fromAddress:self.nodeContextAddress into:&_childCount length:sizeof(uint8_t) requireFull:YES error:&branchError] < sizeof(uint8_t)) {
			MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_EINTERNAL_ERROR underlyingError:branchError description:@"Could not read child count."];;
			[self release]; return nil;
		}
		if ((err = mk_vm_offset_add(offset, 1, &offset))) {
			MK_ERROR_OUT = MK_MAKE_VM_OFFSET_ADD_ARITHMETIC_ERROR(err, offset, 1);
			[self release]; return nil;
		}
		
		NSMutableArray *branches = [[NSMutableArray alloc] initWithCapacity:_childCount];
		
		for (uint8_t i = 0; i < _childCount; i++) {
			MKExportTrieBranch *branch = [[MKExportTrieBranch alloc] initWithOffset:offset fromParent:self error:&branchError];
			if (branch == nil) {
				MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_EINVALID_DATA underlyingError:branchError description:@"Could not parse branch at index [%" PRIi8 "].", i];
				[branches release];
				[self release]; return nil;
			}
			
            // SAFE - All branch nodes must be within the size of this node.
            offset += branch.nodeSize;
			
			[branches addObject:branch];
			[branch release];
		}
		
		_nodeSize = offset;
		
		_branches = [branches copy];
		[branches release];
	}
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (BOOL)_parseTerminalInformationAtOffset:(mk_vm_offset_t)offset error:(NSError**)error
{
#pragma unused(offset)
#pragma unused(error)
	/* For subclasses */
	return YES;
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Trie Node Values
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@synthesize terminalInformationSize = _terminalInformationSize;
@synthesize childCount = _childCount;
@synthesize branches = _branches;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@synthesize nodeSize = _nodeSize;

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_size_t)terminalInformationSizeFieldSize
{ return _terminalInformationSizeULEBSize; }
- (mk_vm_offset_t)terminalInformationSizeFieldOffset
{
    return 0;
}

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_size_t)childCountFieldSize
{ return [MKNodeFieldTypeUnsignedByte.sharedInstance sizeForNode:self]; }
- (mk_vm_offset_t)childCountFieldOffset
{
    return 0
        + _terminalInformationSizeULEBSize
        + _terminalInformationSize;
}

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
	MKNodeFieldBuilder *terminalInformationSize = [MKNodeFieldBuilder
		builderWithProperty:MK_PROPERTY(terminalInformationSize)
		type:MKNodeFieldTypeUnsignedQuadWord.sharedInstance
	];
	terminalInformationSize.description = @"Terminal Size";
    terminalInformationSize.dataRecipe = MKNodeFieldDataOperationExtractDynamicSubrange.sharedInstance;
	terminalInformationSize.options = MKNodeFieldOptionDisplayAsDetail;
	
	MKNodeFieldBuilder *childCount = [MKNodeFieldBuilder
		builderWithProperty:MK_PROPERTY(childCount)
		type:MKNodeFieldTypeUnsignedByte.sharedInstance
	];
	childCount.description = @"Child Count";
    childCount.dataRecipe = MKNodeFieldDataOperationExtractDynamicSubrange.sharedInstance;
	childCount.options = MKNodeFieldOptionDisplayAsDetail;
	
	MKNodeFieldBuilder *branches = [MKNodeFieldBuilder
		builderWithProperty:MK_PROPERTY(branches)
		type:[MKNodeFieldTypeCollection typeWithCollectionType:[MKNodeFieldTypeNode typeWithNodeType:MKExportTrieBranch.class]]
	];
	branches.description = @"Branches";
	branches.options = MKNodeFieldOptionDisplayAsDetail | MKNodeFieldOptionMergeContainerContents;
	
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
		terminalInformationSize.build,
		childCount.build,
		branches.build
    ]];
}

@end
