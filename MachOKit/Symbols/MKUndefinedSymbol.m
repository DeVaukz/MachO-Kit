//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKUndefinedSymbol.m
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

#import "MKInternal.h"
#import "MKUndefinedSymbol.h"
#import "MKDependentLibrary.h"
#import "MKMachO+Libraries.h"
#import "MKNodeFieldSymbolFlagsType.h"

//----------------------------------------------------------------------------//
@implementation MKUndefinedSymbol

//|++++++++++++++++++++++++++++++++++++|//
+ (uint32_t)canInstantiateWithEntry:(struct nlist_64)nlist
{
    if (self != MKUndefinedSymbol.class)
        return 0;
    
    return (nlist.n_type & N_TYPE) == N_UNDF ? 40 : 0;
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - Creating a Symbol
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithOffset:(mk_vm_offset_t)offset fromParent:(MKBackedNode*)parent error:(NSError**)error
{
    self = [super initWithOffset:offset fromParent:parent error:error];
    if (self == nil) return nil;
    
    // Lookup the source library
    if (self.sourceLibraryOrdinal > SELF_LIBRARY_ORDINAL && self.sourceLibraryOrdinal <= MAX_LIBRARY_ORDINAL)
    {
        NSArray *libraries = self.macho.dependentLibraries;
        MKOptional<MKDependentLibrary*> *library = nil;
        
        // Lookup the library
        if ((NSUInteger)self.sourceLibraryOrdinal <= libraries.count)
            library = libraries[(NSUInteger)(self.sourceLibraryOrdinal - 1)];
        
        if (library.value)
            _sourceLibrary = [library.value retain];
        else
            MK_PUSH_WARNING_WITH_ERROR(sourceLibrary, MK_ENOT_FOUND, library.error, @"Could not locate library for ordinal [%" PRIi64 "].", self.sourceLibraryOrdinal);
    }
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (void)dealloc
{
    [_sourceLibrary release];
    
    [super dealloc];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Values
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@synthesize sourceLibrary = _sourceLibrary;

//|++++++++++++++++++++++++++++++++++++|//
- (MKSymbolReferenceType)referenceType
{ return self.desc & REFERENCE_TYPE; }

//|++++++++++++++++++++++++++++++++++++|//
- (MKSymbolLibraryOrdinal)sourceLibraryOrdinal
{ return GET_LIBRARY_ORDINAL(self.desc); }

//|++++++++++++++++++++++++++++++++++++|//
- (BOOL)isWeakReference
{ return !!(self.desc & N_WEAK_REF); }

//|++++++++++++++++++++++++++++++++++++|//
- (BOOL)isReferenceToWeak
{ return !!(self.desc & N_REF_TO_WEAK); }

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
+ (MKNodeFieldBuilder*)_descFieldBuilder
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-method-access"
    MKNodeFieldBuilder *desc = [super _descFieldBuilder];
#pragma clang diagnostic pop
    
    MKNodeFieldTypeBitfieldMask *referenceTypeMask = [MKNodeFieldTypeBitfieldMask new];
    referenceTypeMask.type = MKNodeFieldSymbolReferenceType.sharedInstance;
    referenceTypeMask.mask = _$((uint16_t)REFERENCE_TYPE);
    
    MKNodeFieldTypeBitfieldMask *symbolFlagsMask = [MKNodeFieldTypeBitfieldMask new];
    symbolFlagsMask.type = MKNodeFieldUndefinedSymbolFlagsType.sharedInstance;
    symbolFlagsMask.mask = _$((uint16_t)0x00F8);
    
    MKNodeFieldTypeBitfieldMask *sourceLibraryOrdinalMask = [MKNodeFieldTypeBitfieldMask new];
    sourceLibraryOrdinalMask.type = MKNodeFieldSymbolLibraryOrdinalType.sharedInstance;
    sourceLibraryOrdinalMask.mask = _$((uint16_t)0xFF00);
    sourceLibraryOrdinalMask.shift = -8;
    
    desc.type = [MKNodeFieldTypeBitfield bitfieldWithType:(id)desc.type bits:@[referenceTypeMask, symbolFlagsMask, sourceLibraryOrdinalMask] name:nil];
    desc.formatter = desc.type.formatter;
    
    [sourceLibraryOrdinalMask release];
    [symbolFlagsMask release];
    [referenceTypeMask release];
    
    return desc;
}

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    MKNodeFieldBuilder *sourceLibrary = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(sourceLibrary)
        type:[MKNodeFieldTypeNode typeWithNodeType:MKDependentLibrary.class]
    ];
    sourceLibrary.description = @"Source Library";
    sourceLibrary.options = MKNodeFieldOptionIgnoreContainerContents | MKNodeFieldOptionHideAddressAndData;
    
    // TODO - Fix this so we can inherit the parent description.
    return [MKNodeDescription nodeDescriptionWithParentDescription:nil fields:@[
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-method-access"
        [[self.class _strxFieldBuilder] build],
        [[self.class _typeFieldBuilder] build],
        [[self.class _sectFieldBuilder] build],
        [[self.class _descFieldBuilder] build],
        [[self.class _nameFieldBuilder] build],
        [[self.class _sectionFieldBuilder] build],
#pragma clang diagnostic pop
        sourceLibrary.build,
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Weverything"
        [[self _valueFieldBuilder] build]
#pragma clang diagnostic pop
    ]];
}

@end
