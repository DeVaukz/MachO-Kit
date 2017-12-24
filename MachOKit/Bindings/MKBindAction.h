//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       MKBindAction.h
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

#import <MachOKit/MKOffsetNode.h>
#import <MachOKit/MKBindContext.h>

@class MKBindCommand;
@class MKBindingsInfo;
@class MKDependentLibrary;
@class MKSegment;
@class MKSection;

NS_ASSUME_NONNULL_BEGIN

//----------------------------------------------------------------------------//
//! @name       Special Ordinals
//! @relates    MKBindAction
//!
//
typedef NS_ENUM(int64_t, MKLibraryOrdinal) {
    MKLibraryOrdinalSelf                = BIND_SPECIAL_DYLIB_SELF,
    MKLibraryOrdinalMainExecutable      = BIND_SPECIAL_DYLIB_MAIN_EXECUTABLE,
    MKLibraryOrdinalFlatLookup          = BIND_SPECIAL_DYLIB_FLAT_LOOKUP
};



//----------------------------------------------------------------------------//
//! @name       Bind Options
//! @relates    MKBindAction
//!
//
typedef NS_OPTIONS(uint8_t, MKBindOptions) {
    MKBindOptionWeakImport                = BIND_SYMBOL_FLAGS_WEAK_IMPORT,
    MKBindOptionNonWeakDefinition         = BIND_SYMBOL_FLAGS_NON_WEAK_DEFINITION
};



//----------------------------------------------------------------------------//
//! @name       Bind Types
//! @relates    MKBindAction
//!
//
typedef NS_ENUM(uint8_t, MKBindType) {
    MKBindTypePointer                     = BIND_TYPE_POINTER,
    MKBindTypeTextAbsolute32              = BIND_TYPE_TEXT_ABSOLUTE32,
    MKBindTypeTextPcrel32                 = BIND_TYPE_TEXT_PCREL32
};



//----------------------------------------------------------------------------//
@interface MKBindAction : MKOffsetNode {
@package
    mk_vm_size_t _nodeSize;
    MKLibraryOrdinal _libraryOrdinal;
    MKDependentLibrary *_sourceLibrary;
    NSString *_symbolName;
    MKSegment *_segment;
    MKSection *_section;
    mk_vm_offset_t _offset;
    int64_t _addend;
    MKBindOptions _symbolOptions;
    MKBindType _type;
}

- (nullable instancetype)initWithParent:(null_unspecified MKNode*)parent error:(NSError**)error NS_UNAVAILABLE;
- (nullable instancetype)initWithOffset:(mk_vm_offset_t)offset fromParent:(MKBackedNode*)parent error:(NSError**)error NS_UNAVAILABLE;

- (nullable instancetype)initWithContext:(struct MKBindContext*)bindContext error:(NSError**)error NS_DESIGNATED_INITIALIZER;

//! Bind type.
@property (nonatomic, readonly) MKBindType type;

//!
@property (nonatomic, readonly) MKLibraryOrdinal libraryOrdinal;

//!
@property (nonatomic, readonly, nullable) MKDependentLibrary *sourceLibrary;

//!
@property (nonatomic, readonly) NSString *symbolName;

//!
@property (nonatomic, readonly) MKBindOptions symbolFlags;

//!
@property (nonatomic, readonly) int64_t addend;

//! The segment in which the bind location resides.
@property (nonatomic, readonly) MKSegment *segment;

//! Offset from the start of the segment to the bind location.
@property (nonatomic, readonly) mk_vm_offset_t offset;

//! VM address of the bind location.
@property (nonatomic, readonly) mk_vm_address_t address;

//! The section in which the bind location resides, or \c nil if it
//! does not reside in a known section.
@property (nonatomic, readonly, nullable) MKSection *section;

@end



//----------------------------------------------------------------------------//
@interface MKWeakBindAction : MKBindAction
@end



//----------------------------------------------------------------------------//
@interface MKLazyBindAction : MKBindAction
@end

NS_ASSUME_NONNULL_END
