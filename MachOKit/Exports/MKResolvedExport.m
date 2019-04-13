//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKResolvedExport.m
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

#import "MKResolvedExport.h"
#import "MKInternal.h"
#import "MKExportTrieTerminalNode.h"

//----------------------------------------------------------------------------//
@implementation MKResolvedExport

//|++++++++++++++++++++++++++++++++++++|//
+ (uint32_t)canInstantiateWithTrieNodes:(NSArray<MKExportTrieNode*>*)nodes
{
    if (self != MKResolvedExport.class)
        return 0;
    
	MKExportTrieTerminalNode *terminalNode = (MKExportTrieTerminalNode*)nodes.lastObject;
	
	return (terminalNode.flags & EXPORT_SYMBOL_FLAGS_STUB_AND_RESOLVER) ? 40 : 0;
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithTrieNodes:(NSArray<MKExportTrieNode*>*)nodes error:(NSError**)error
{
	self = [super initWithTrieNodes:nodes error:error];
	if (self == nil) return nil;
	
	MKExportTrieTerminalNode *terminalNode = (MKExportTrieTerminalNode*)nodes.lastObject;

	_resolverAddress = terminalNode.resolver;
	
	return self;
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - 	Export Information
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@synthesize resolverAddress = _resolverAddress;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
	MKNodeFieldBuilder *resolver = [MKNodeFieldBuilder
		builderWithProperty:MK_PROPERTY(resolverAddress)
		type:MKNodeFieldTypeAddress.sharedInstance
	];
	resolver.description = @"Resolver Address";
	resolver.options = MKNodeFieldOptionDisplayAsDetail;
	
	return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
		resolver.build
	]];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  NSObject
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (NSString*)_optionsDescription
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Weverything"
    NSString *options = [super _optionsDescription];
#pragma clang diagnostic pop
    
    NSMutableString *mutableOptions;
    if (options)
        mutableOptions = [options mutableCopy];
    else
        mutableOptions = [NSMutableString new];
    
    if (mutableOptions.length > 0)
        [mutableOptions appendString:@", "];
    [mutableOptions appendFormat:@"resolver=0x%.8" PRIX64 "", self.resolverAddress];
    
    return [mutableOptions autorelease];
}

@end
