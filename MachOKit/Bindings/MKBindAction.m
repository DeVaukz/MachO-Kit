//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKBindAction.m
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

#import "MKBindAction.h"
#import "MKInternal.h"
#import "MKBindingsInfo.h"
#import "MKBindCommand.h"
#import "MKDependentLibrary.h"
#import "MKMachO+Libraries.h"
#import "MKMachO+Segments.h"
#import "MKSegment.h"
#import "MKSection.h"

//----------------------------------------------------------------------------//
@implementation MKBindAction

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithContext:(struct MKBindContext*)bindContext error:(NSError**)error
{
	NSParameterAssert(bindContext->info != nil);
	
	self = [super initWithParent:bindContext->info error:error];
    if (self == nil) return nil;
	
	_nodeOffset = bindContext->actionStartOffset;
	
	_type = bindContext->type;
	
    _sourceLibraryOrdinal = bindContext->libraryOrdinal;
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
		
    } else if (_sourceLibraryOrdinal != MKLibraryOrdinalSelf &&
               _sourceLibraryOrdinal != MKLibraryOrdinalMainExecutable &&
               _sourceLibraryOrdinal != MKLibraryOrdinalFlatLookup) {
        // This is a malformed Mach-O (according to dyld).  But we don't care.
        MK_PUSH_WARNING(sourceLibrary, MK_EOUT_OF_RANGE, @"Unknown special library ordinal [%" PRIi64 "].", _sourceLibraryOrdinal);
    }
	
    _symbolName = [bindContext->symbolName retain];
    _symbolOptions = bindContext->symbolFlags;
    
    _offset = bindContext->offset;
    _addend = bindContext->addend;
    
    // Lookup the segment
    _segment = [self.macho.segments[@(bindContext->segmentIndex)] retain];
    if (_segment == nil) {
        MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_ENOT_FOUND description:@"No segment at index [%u].", bindContext->segmentIndex];
        [self release]; return nil;
    }
    
    // Verify that the bind location is within the segment
    mk_error_t err;
    mk_vm_address_t segmentAddress = _segment.vmAddress;
    
    mk_vm_range_t segmentRange = mk_vm_range_make(segmentAddress, _segment.vmSize);
    if ((err = mk_vm_range_contains_address(segmentRange, _offset, segmentAddress))) {
        MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_EOUT_OF_RANGE description:@"The offset [%" MK_VM_PRIuOFFSET "] is not within the %@ segement (index %u).", _offset, _segment, bindContext->segmentIndex];
        [self release]; return nil;
    }
    
    // Try to find the section
	_section = (typeof(_section))[[_segment childNodeOccupyingVMAddress:self.address targetClass:MKSection.class] retain];
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithParent:(MKNode*)parent error:(NSError**)error
{
#pragma unused(parent)
#pragma unused(error)
    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"-initWithParent:error: unavailable." userInfo:nil];
}

//|++++++++++++++++++++++++++++++++++++|//
- (void)dealloc
{
    [_section release];
    [_segment release];
    [_symbolName release];
    [_sourceLibrary release];
    
    [super dealloc];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Binding Information
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@synthesize type = _type;
@synthesize sourceLibraryOrdinal = _sourceLibraryOrdinal;
@synthesize sourceLibrary = _sourceLibrary;
@synthesize symbolName = _symbolName;
@synthesize symbolFlags = _symbolOptions;
@synthesize addend = _addend;
@synthesize segment = _segment;
@synthesize section = _section;
@synthesize offset = _offset;

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_address_t)address
{
    // SAFE - Range check in initializer would have failed.
    return self.segment.vmAddress + self.offset;
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_address_t)nodeAddress:(MKNodeAddressType)type
{
	// SAFE - _nodeOffset comes from the rebase commands, which are within the MKBindingsInfo.
	return [(MKBackedNode*)self.parent nodeAddress:type] + _nodeOffset;
}

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
	MKNodeFieldBuilder *type = [MKNodeFieldBuilder
		builderWithProperty:MK_PROPERTY(type)
		type:MKNodeFieldBindType.sharedInstance
	];
	type.description = @"Type";
	type.options = MKNodeFieldOptionDisplayAsDetail;
	
	MKNodeFieldBuilder *sourceLibraryOrdinal = [MKNodeFieldBuilder
		builderWithProperty:MK_PROPERTY(sourceLibraryOrdinal)
		type:MKNodeFieldTypeQuadWord.sharedInstance
	];
	sourceLibraryOrdinal.description = @"Library Ordinal";
	sourceLibraryOrdinal.options = MKNodeFieldOptionDisplayAsDetail;
	
	MKNodeFieldBuilder *sourceLibrary = [MKNodeFieldBuilder
		builderWithProperty:MK_PROPERTY(sourceLibrary)
		type:[MKNodeFieldTypeNode typeWithNodeType:MKDependentLibrary.class]
	];
	sourceLibrary.description = @"Library";
	sourceLibrary.options = MKNodeFieldOptionDisplayAsDetail | MKNodeFieldOptionIgnoreContainerContents | MKNodeFieldOptionHideAddressAndData;
	
	MKNodeFieldBuilder *symbolName = [MKNodeFieldBuilder
		builderWithProperty:MK_PROPERTY(symbolName)
		type:MKNodeFieldTypeString.sharedInstance
	];
	symbolName.description = @"Symbol Name";
	symbolName.options = MKNodeFieldOptionDisplayAsDetail;
	
	MKNodeFieldBuilder *symbolFlags = [MKNodeFieldBuilder
		builderWithProperty:MK_PROPERTY(symbolFlags)
		type:MKNodeFieldBindSymbolFlagsType.sharedInstance
	];
	symbolFlags.description = @"Symbol Flags";
	symbolFlags.options = MKNodeFieldOptionDisplayAsDetail;
	
	MKNodeFieldBuilder *addend = [MKNodeFieldBuilder
		builderWithProperty:MK_PROPERTY(addend)
		type:MKNodeFieldTypeQuadWord.sharedInstance
	];
	addend.description = @"Addend";
	addend.options = MKNodeFieldOptionDisplayAsDetail;
	
	MKNodeFieldBuilder *segment = [MKNodeFieldBuilder
		builderWithProperty:MK_PROPERTY(segment)
		type:[MKNodeFieldTypeNode typeWithNodeType:MKSegment.class]
	];
	segment.description = @"Segment";
	segment.options = MKNodeFieldOptionDisplayAsDetail | MKNodeFieldOptionIgnoreContainerContents | MKNodeFieldOptionHideAddressAndData;
	
	MKNodeFieldBuilder *section = [MKNodeFieldBuilder
		builderWithProperty:MK_PROPERTY(section)
		type:[MKNodeFieldTypeNode typeWithNodeType:MKSection.class]
	];
	section.description = @"Section";
	section.options = MKNodeFieldOptionDisplayAsDetail | MKNodeFieldOptionIgnoreContainerContents | MKNodeFieldOptionHideAddressAndData;
	
	MKNodeFieldBuilder *address = [MKNodeFieldBuilder
		builderWithProperty:MK_PROPERTY(address)
		type:MKNodeFieldTypeAddress.sharedInstance
	];
	address.description = @"Address";
	address.options = MKNodeFieldOptionDisplayAsDetail;
	
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        type.build,
        sourceLibraryOrdinal.build,
        sourceLibrary.build,
        symbolName.build,
        symbolFlags.build,
        addend.build,
        segment.build,
        section.build,
        address.build
    ]];
}

@end



//----------------------------------------------------------------------------//
@implementation MKWeakBindAction
@end



//----------------------------------------------------------------------------//
@implementation MKLazyBindAction
@end
