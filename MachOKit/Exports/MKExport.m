//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKExport.m
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

#import "MKExport.h"
#import "MKInternal.h"
#import "MKCString.h"
#import "MKExportTrieNode.h"
#import "MKExportTrieTerminalNode.h"
#import "MKExportTrieBranch.h"

//----------------------------------------------------------------------------//
@implementation MKExport

//|++++++++++++++++++++++++++++++++++++|//
+ (id*)_subclassesCache
{ static NSSet *subclasses; return &subclasses; }

//|++++++++++++++++++++++++++++++++++++|//
+ (uint32_t)canInstantiateWithTrieNodes:(NSArray<MKExportTrieNode*> *)nodes
{
#pragma unused(nodes)
	return (self == MKExport.class) ? 10 : 0;
}

//|++++++++++++++++++++++++++++++++++++|//
+ (Class)classForTrieNodes:(NSArray<MKExportTrieNode*> *)nodes
{
	Class subclass = [self bestSubclassWithRanking:^uint32_t(Class cls) {
		return [cls canInstantiateWithTrieNodes:nodes];
	}];
	
	return subclass;
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Creating an Export
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)exportForTrieNodes:(NSArray<MKExportTrieNode*> *)nodes error:(NSError**)error
{
	MKExportTrieTerminalNode *terminalNode = (MKExportTrieTerminalNode*)nodes.lastObject;
	NSAssert([terminalNode isKindOfClass:MKExportTrieTerminalNode.class], @"The final node in the provided branch must be a terminal node.");
	
	Class exportClass = [self classForTrieNodes:nodes];
	
    NSAssert(exportClass != nil, @"No class for branch.");
	return [[[exportClass alloc] initWithTrieNodes:nodes error:error] autorelease];
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithTrieNodes:(NSArray<MKExportTrieNode*> *)nodes error:(NSError**)error
{
	MKExportTrieTerminalNode *terminalNode = (MKExportTrieTerminalNode*)nodes.lastObject;
	NSAssert([terminalNode isKindOfClass:MKExportTrieTerminalNode.class], @"The final node in the provided branch must be a terminal node.");
	
	self = [super initWithParent:terminalNode error:error];
	if (self == nil) return nil;
	
	_flags = terminalNode.flags;
	
    // Build up the export name
    @autoreleasepool
    {
        _name = @"";
        
        for (NSUInteger i = 1; i < nodes.count; i++) {
            MKExportTrieNode *current = nodes[i-1];
            MKExportTrieNode *next = nodes[i];
            
            MKExportTrieBranch *branch = nil;
            for (MKExportTrieBranch *c in current.branches) {
                if (next.nodeOffset == c.offset)
                    branch = c;
            }
            NSAssert(branch != nil, @"%@ is not referenced by any branches of %@.", next.nodeDescription, current.nodeDescription);
            
            NSString *prefix = branch.prefix.string;
            if (prefix == nil) {
				MK_PUSH_WARNING(name, MK_EINVALID_DATA, @"Branch %@ of %@ does not contain a prefix.", branch.nodeDescription, current.nodeDescription);
                break;
            }
            
            _name = [_name stringByAppendingString:prefix];
        }
		
		_name = [_name retain];
    }
    
	return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithParent:(MKNode*)parent error:(NSError**)error
{
#pragma unused(parent)
#pragma unused(error)
    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"-initWithParent:error unavailable." userInfo:nil];
}

//|++++++++++++++++++++++++++++++++++++|//
- (void)dealloc
{
    [_name release];
    
    [super dealloc];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Export Information
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@synthesize name = _name;

//|++++++++++++++++++++++++++++++++++++|//
- (MKExportKind)kind
{ return _flags & (uint64_t)EXPORT_SYMBOL_FLAGS_KIND_MASK; }

//|++++++++++++++++++++++++++++++++++++|//
- (MKExportOptions)options
{ return _flags & ~(uint64_t)EXPORT_SYMBOL_FLAGS_KIND_MASK; }

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_address_t)nodeAddress:(MKNodeAddressType)type
{ return [(MKBackedNode*)self.parent nodeAddress:type]; }

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
	MKNodeFieldBuilder *kind = [MKNodeFieldBuilder
		builderWithProperty:MK_PROPERTY(kind)
		type:MKNodeFieldExportKindType.sharedInstance
	];
	kind.description = @"Kind";
	kind.options = MKNodeFieldOptionDisplayAsDetail;
	
	MKNodeFieldBuilder *options = [MKNodeFieldBuilder
		builderWithProperty:MK_PROPERTY(options)
		type:MKNodeFieldExportOptionsType.sharedInstance
	];
	options.description = @"Options";
	options.options = MKNodeFieldOptionDisplayAsDetail;
	
	MKNodeFieldBuilder *name = [MKNodeFieldBuilder
		builderWithProperty:MK_PROPERTY(name)
		type:MKNodeFieldTypeString.sharedInstance
	];
	name.description = @"Name";
	name.options = MKNodeFieldOptionDisplayAsDetail;
	
	return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
		kind.build,
		options.build,
		name.build
	]];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  NSObject
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (NSString*)_optionsDescription
{
    NSString *options = nil;
    if (self.kind != EXPORT_SYMBOL_FLAGS_KIND_REGULAR || self.options != 0)
    {
        NSMutableString *mutableOptions = [NSMutableString string];
        
        if (self.options & EXPORT_SYMBOL_FLAGS_WEAK_DEFINITION) {
            [mutableOptions appendString:@"weak_def"];
        }
        
        if (self.kind == EXPORT_SYMBOL_FLAGS_KIND_THREAD_LOCAL) {
            if (mutableOptions.length > 0)
                [mutableOptions appendString:@", "];
            [mutableOptions appendString:@"per-thread"];
        }
        
        if (self.kind == EXPORT_SYMBOL_FLAGS_KIND_ABSOLUTE) {
            if (mutableOptions.length > 0)
                [mutableOptions appendString:@", "];
            [mutableOptions appendString:@"absolute"];
        }
        
        if (mutableOptions.length > 0)
            options = mutableOptions;
    }
    
    return options;
}

//|++++++++++++++++++++++++++++++++++++|//
- (NSString*)description
{
    // Options
    NSString *options = [self _optionsDescription];
    
    if (options)
        return [NSString stringWithFormat:@"%@ [%@]", self.name, options];
    else
        return [NSString stringWithFormat:@"%@", self.name];
}

@end
