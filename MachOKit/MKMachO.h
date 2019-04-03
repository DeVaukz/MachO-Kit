//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       MKMachO.h
//!
//! @author     D.V.
//! @copyright  Copyright (c) 2014-2015 D.V. All rights reserved.
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

#include <MachOKit/macho.h>
@import Foundation;

#import <MachOKit/MKBackedNode.h>
#import <MachOKit/MKMachOFieldType.h>
#import <MachOKit/MKNode+MachO.h>
#import <MachOKit/MKOffsetNode+AddressBasedInitialization.h>

@protocol MKLCSegment;
@class MKMachOImage;
@class MKMachHeader;
@class MKLoadCommand;
@class MKDependentLibrary;
@class MKFunctionStarts;
@class MKRebaseInfo;
@class MKDataInCode;
@class MKSplitSegmentInfo;
@class MKBindingsInfo;
@class MKWeakBindingsInfo;
@class MKLazyBindingsInfo;
@class MKExportsInfo;
@class MKStringTable;
@class MKSymbolTable;
@class MKIndirectSymbolTable;

NS_ASSUME_NONNULL_BEGIN

//----------------------------------------------------------------------------//
//! @name       Mach-O Image Options
//! @relates    MKMachOImage
//
typedef NS_OPTIONS(NSUInteger, MKMachOImageFlags) {
    //! The Mach-O image has been processed by the dynamic linker.
    MKMachOImageProcessedByDYLD         = 1UL << 0
};



//----------------------------------------------------------------------------//
//! An instance of \c MKMachOImage parses a single Mach-O.
//
@interface MKMachOImage : MKBackedNode {
@package
    mk_context_t _context;
    MKMemoryMap *_mapping;
    id<MKDataModel> _dataModel;
    MKMachOImageFlags _flags;
    NSString *_name;
    // Address //
    mk_vm_address_t _contextAddress;
    mk_vm_address_t _vmAddress;
    mk_vm_slide_t _slide;
    // Header //
    MKMachHeader *_header;
    NSArray<MKLoadCommand*> *_loadCommands;
    // Dependents //
    NSArray<MKOptional<MKDependentLibrary*>*>  *_dependentLibraries;
    // Segments //
    NSDictionary *_segments;
    // Function Starts //
    MKOptional<MKFunctionStarts*> *_functionStarts;
    // Rebase //
    MKOptional<MKRebaseInfo*> *_rebaseInfo;
    // Data In Code //
    MKOptional<MKDataInCode*> *_dataInCode;
    // Split Segment //
    MKOptional<MKSplitSegmentInfo*> *_splitSegment;
    // Bindings //
    MKOptional<MKBindingsInfo*> *_bindingsInfo;
    MKOptional<MKWeakBindingsInfo*> *_weakBindingsInfo;
    MKOptional<MKLazyBindingsInfo*> *_lazyBindingsInfo;
    // Exports //
    MKOptional<MKExportsInfo*> *_exportsInfo;
    // Symbols //
    MKOptional<MKStringTable*> *_stringTable;
    MKOptional<MKSymbolTable*> *_symbolTable;
    MKOptional<MKIndirectSymbolTable*> *_indirectSymbolTable;
}

- (nullable instancetype)initWithName:(nullable const char*)name flags:(MKMachOImageFlags)flags atAddress:(mk_vm_address_t)contextAddress inMapping:(MKMemoryMap*)mapping error:(NSError**)error NS_DESIGNATED_INITIALIZER;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Retrieving the Initialization Context
//! @name       Retrieving the Initialization Context
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//! The libMachO context.
@property (nonatomic, readonly) mk_context_t *context;

//! The flags that this Mach-O image was initialized with.
@property (nonatomic, readonly) MKMachOImageFlags flags;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Getting Image Metadata
//! @name       Getting Image Metadata
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//! The name that this Mach-O image was initialized with.
@property (nonatomic, readonly, nullable) NSString *name;

//! The slide value for this Mach-O image.
@property (nonatomic, readonly) mk_vm_slide_t slide;

//! Indicates whether this Mach-O image is from dyld's shared cache.
@property (nonatomic, readonly) BOOL isFromSharedCache;

//! Indicates whether this Mach-O image is from a memory dump (or live memory).
@property (nonatomic, readonly) BOOL isFromMemory;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Header
//! @name       Header
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//! The header of this image.
@property (nonatomic, readonly) MKMachHeader *header;

//! The architecture of this image.
@property (nonatomic, readonly) mk_architecture_t architecture;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Load Commands
//! @name       Load Commands
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//! An array containing instances of \ref MKLoadCommand, each representing a
//! load commands from this Mach-O image.  Load commands are ordered as they
//! appear in the Mach-O header.  The count of the returned array may be less
//! than the value of ncmds in the \ref header, if the Mach-O is malformed
//! and trailing load commands could not be read.
@property (nonatomic, readonly) NSArray<__kindof MKLoadCommand*> *loadCommands;

//! Filters the \ref loadCommands array to those of the specified \a type
//! and returns the result.  The relative ordering of the returned load
//! commands is preserved.
- (NSArray<__kindof MKLoadCommand*> *)loadCommandsOfType:(uint32_t)type;

@end

NS_ASSUME_NONNULL_END
