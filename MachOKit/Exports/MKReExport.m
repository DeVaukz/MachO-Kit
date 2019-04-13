//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKReExport.m
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

#import "MKReExport.h"
#import "MKInternal.h"
#import "MKCString.h"
#import "MKMachO+Libraries.h"
#import "MKDependentLibrary.h"
#import "MKExportTrieTerminalNode.h"

//----------------------------------------------------------------------------//
@implementation MKReExport

//|++++++++++++++++++++++++++++++++++++|//
+ (uint32_t)canInstantiateWithTrieNodes:(NSArray<MKExportTrieNode*>*)nodes
{
	MKExportTrieTerminalNode *terminalNode = (MKExportTrieTerminalNode*)nodes.lastObject;
	
	return (self == MKReExport.class && terminalNode.flags & EXPORT_SYMBOL_FLAGS_REEXPORT) ? 50 : 0;
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithTrieNodes:(NSArray<MKExportTrieNode*>*)nodes error:(NSError**)error
{
	self = [super initWithTrieNodes:nodes error:error];
	if (self == nil) return nil;
	
	MKExportTrieTerminalNode *terminalNode = (MKExportTrieTerminalNode*)nodes.lastObject;
	
	_sourceLibraryOrdinal = terminalNode.ordinal;
    if (_sourceLibraryOrdinal > 0) {
        NSArray *libraries = self.macho.dependentLibraries;
        MKOptional<MKDependentLibrary*> *library = nil;
        
        // Lookup the library
        if ((NSUInteger)_sourceLibraryOrdinal <= libraries.count)
            library = libraries[(NSUInteger)(_sourceLibraryOrdinal - 1)];
        
        if (library.value)
            _sourceLibrary = [library.value retain];
        else
            MK_PUSH_WARNING_WITH_ERROR(sourceLibrary, MK_ENOT_FOUND, library.error, @"Could not locate library for ordinal [%" PRIi64 "].", _sourceLibraryOrdinal);
    } else {
        MK_PUSH_WARNING(sourceLibrary, MK_EOUT_OF_RANGE, @"Unsupported special library ordinal [%" PRIi64 "] in an export.", _sourceLibraryOrdinal);
    }
    
	_importedName = [terminalNode.importedName.string retain];
	
	return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (void)dealloc
{
	[_importedName release];
    [_sourceLibrary release];
	
	[super dealloc];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - 	Export Information
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@synthesize sourceLibraryOrdinal = _sourceLibraryOrdinal;
@synthesize sourceLibrary = _sourceLibrary;
@synthesize importedName = _importedName;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
	MKNodeFieldBuilder *sourceLibraryOrdinal = [MKNodeFieldBuilder
		builderWithProperty:MK_PROPERTY(sourceLibraryOrdinal)
		type:MKNodeFieldTypeQuadWord.sharedInstance
	];
	sourceLibraryOrdinal.description = @"Source Library Ordinal";
	sourceLibraryOrdinal.options = MKNodeFieldOptionDisplayAsDetail;
	
    MKNodeFieldBuilder *sourceLibrary = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(sourceLibrary)
        type:[MKNodeFieldTypeNode typeWithNodeType:MKDependentLibrary.class]
    ];
    sourceLibrary.description = @"Source Library";
    sourceLibrary.options = MKNodeFieldOptionDisplayAsDetail | MKNodeFieldOptionIgnoreContainerContents;
    
    MKNodeFieldBuilder *importedName = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(importedName)
        type:MKNodeFieldTypeString.sharedInstance
    ];
    importedName.description = @"Imported Name";
    importedName.options = MKNodeFieldOptionDisplayAsDetail;
    
	return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
		sourceLibraryOrdinal.build,
        sourceLibrary.build,
        importedName.build
	]];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  NSObject
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (NSString*)description
{
    // Source
    NSString *source = nil;
    {
        // The dyldinfo tool omits any version number when displaying the source
        // library name of a reexport.
        // <https://opensource.apple.com/source/ld64/ld64-409.12/src/other/dyldinfo.cpp.auto.html>
        NSString *sourceLibraryName = self.sourceLibrary.description;
        NSRange firstDot = [sourceLibraryName rangeOfString:@"."];
        if (firstDot.location != NSNotFound)
            sourceLibraryName = [sourceLibraryName substringToIndex:firstDot.location];
        
        if (self.importedName)
            source = [NSString stringWithFormat:@"(%@ from %@)", self.importedName, sourceLibraryName];
        else
            source = [NSString stringWithFormat:@"(from %@)", sourceLibraryName];
    }
    
    if (source)
        return [NSString stringWithFormat:@"[re-export] %@ %@", super.description, source];
    else
        return [NSString stringWithFormat:@"[re-export] %@", super.description];
}

@end
