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
#import "NSError+MK.h"
#import "MKMachO.h"
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
    self = [super initWithOffset:bindContext->actionStartOffset fromParent:bindContext->info error:error];
    if (self == nil) return nil;
    
    _nodeSize = bindContext->actionSize;
    
    _libraryOrdinal = bindContext->libraryOrdinal;
    if (_libraryOrdinal > 0) {
        // Lookup the library
        if ((NSUInteger)_libraryOrdinal <= self.macho.dependentLibraries.count)
            _sourceLibrary = [self.macho.dependentLibraries[(NSUInteger)(_libraryOrdinal - 1)].value retain];
        if (_sourceLibrary == nil)
            MK_PUSH_WARNING(sourceLibrary, MK_ENOT_FOUND, @"Could not locate library for ordinal %li", _libraryOrdinal);
    } else if (_libraryOrdinal != MKLibraryOrdinalSelf &&
               _libraryOrdinal != MKLibraryOrdinalMainExecutable &&
               _libraryOrdinal != MKLibraryOrdinalFlatLookup) {
        // This is a malformed Mach-O (according to dyld).
        // But we don't care.
        MK_PUSH_WARNING(sourceLibrary, MK_EOUT_OF_RANGE, @"Unknown special library ordinal %li", _libraryOrdinal);
    }
    
    _type = bindContext->type;
    
    _symbolName = [bindContext->symbolName retain];
    _symbolOptions = bindContext->symbolFlags;
    
    _offset = bindContext->offset;
    _addend = bindContext->addend;
    
    // Lookup the segment
    if (bindContext->segmentIndex < self.macho.segments.count)
        _segment = [self.macho.segments[@(bindContext->segmentIndex)] retain];
    if (_segment == nil) {
        MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_ENOT_FOUND description:@"No segment at index %u.", bindContext->segmentIndex];
        [self release]; return nil;
    }
    
    // Verify that the bind location is within the segment
    mk_error_t err;
    mk_vm_address_t segmentAddress = _segment.vmAddress;
    
    mk_vm_range_t segmentRange = mk_vm_range_make(segmentAddress, _segment.vmSize);
    if ((err = mk_vm_range_contains_address(segmentRange, _offset, segmentAddress))) {
        MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_EOUT_OF_RANGE description:@"Offset (%" MK_VM_PRIiOFFSET ") is not within the section at index %u.", bindContext->segmentIndex];
        [self release]; return nil;
    }
    
    // Try to find the section
    for (MKSection *section in _segment.sections) {
        mk_vm_range_t sectionRange = mk_vm_range_make(section.vmAddress, section.size);
        if (MK_ESUCCESS == mk_vm_range_contains_address(sectionRange, 0, self.address)) {
            _section = [section retain];
            break;
        }
    }
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithOffset:(mk_vm_offset_t)offset fromParent:(MKBackedNode*)parent error:(NSError**)error
{
#pragma unused(offset)
#pragma unused(parent)
#pragma unused(error)
    @throw [NSException exceptionWithName:NSGenericException reason:@"Currently unavailable" userInfo:nil];
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithParent:(MKNode*)parent error:(NSError**)error
{
#pragma unused(parent)
#pragma unused(error)
    @throw [NSException exceptionWithName:NSGenericException reason:@"Currently unavailable" userInfo:nil];
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
#pragma mark - Values
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@synthesize type = _type;
@synthesize libraryOrdinal = _libraryOrdinal;
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
#pragma mark - MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@synthesize nodeSize = _nodeSize;

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    // TODO - Adopt the new description system.
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        [MKNodeField nodeFieldWithProperty:MK_PROPERTY(type) description:@"Type"],
        [MKNodeField nodeFieldWithProperty:MK_PROPERTY(libraryOrdinal) description:@"Library Ordinal"],
        [MKNodeField nodeFieldWithProperty:MK_PROPERTY(sourceLibrary) description:@"Library"],
        [MKNodeField nodeFieldWithProperty:MK_PROPERTY(symbolName) description:@"Symbol Name"],
        [MKNodeField nodeFieldWithProperty:MK_PROPERTY(symbolFlags) description:@"Symbol Flags"],
        [MKNodeField nodeFieldWithProperty:MK_PROPERTY(addend) description:@"Addend"],
        [MKNodeField nodeFieldWithProperty:MK_PROPERTY(segment) description:@"Segment"],
        [MKNodeField nodeFieldWithProperty:MK_PROPERTY(section) description:@"Section"],
        [MKNodeField nodeFieldWithProperty:MK_PROPERTY(address) description:@"Address"]
    ]];
}

@end



//----------------------------------------------------------------------------//
@implementation MKWeakBindAction
@end



//----------------------------------------------------------------------------//
@implementation MKLazyBindAction
@end
