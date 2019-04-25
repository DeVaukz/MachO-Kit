//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKBindActionBind.m
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

#import "MKBindActionBind.h"
#import "MKInternal.h"
#import "MKDependentLibrary.h"
#import "MKMachO+Libraries.h"

//----------------------------------------------------------------------------//
@implementation MKBindActionBind

//|++++++++++++++++++++++++++++++++++++|//
+ (uint32_t)canInstantiateWithContext:(struct MKBindContext*)bindContext
{
#pragma unused (bindContext)
    if (self != MKBindActionBind.class)
        return 0;
    
    return 10;
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithContext:(struct MKBindContext*)bindContext error:(NSError**)error
{
    self = [super initWithContext:bindContext error:error];
    if (self == nil) return nil;
    
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
    _addend = bindContext->addend;
    _symbolOptions = bindContext->symbolFlags;
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (void)dealloc
{
    [_symbolName release];
    [_sourceLibrary release];
    
    [super dealloc];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Binding Information
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@synthesize sourceLibraryOrdinal = _sourceLibraryOrdinal;
@synthesize sourceLibrary = _sourceLibrary;
@synthesize symbolName = _symbolName;
@synthesize symbolFlags = _symbolOptions;
@synthesize addend = _addend;

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
    
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        sourceLibraryOrdinal.build,
        sourceLibrary.build,
        symbolName.build,
        symbolFlags.build,
        addend.build
    ]];
}

@end



//----------------------------------------------------------------------------//
@implementation MKBindActionWeakBind
@end



//----------------------------------------------------------------------------//
@implementation MKBindActionLazyBind
@end
