//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       MKSection.h
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
#import <MachOKit/MKLCSegment.h>

@class MKSegment;

NS_ASSUME_NONNULL_BEGIN

//----------------------------------------------------------------------------//
//! @name       Section Types
//! @relates    MKSection
//!
//
typedef NS_ENUM(uint8_t, MKSectionType) {
    //! Regular section
    MKSectionTypeRegular                        = S_REGULAR,
    //! Zzero fill on demand section
    MKSectionTypeZeroFill                       = S_ZEROFILL,
    //! Section with only literal C strings
    MKSectionTypeCStringLiterals                = S_CSTRING_LITERALS,
    //! Section with only 4 byte literals
    MKSectionType4ByteLiterals                  = S_4BYTE_LITERALS,
    //! Section with only 8 byte literals
    MKSectionType8ByteLiterals                  = S_8BYTE_LITERALS,
    //! Section with only pointers to literals
    MKSectionTypeLiteralPointers                = S_LITERAL_POINTERS,
    //! Section with only non-lazy symbol pointers
    MKSectionTypeNonLazySymbolPointers          = S_NON_LAZY_SYMBOL_POINTERS,
    //! Section with only lazy symbol pointers
    MKSectionTypeLazySymbolPointers             = S_LAZY_SYMBOL_POINTERS,
    //! Section with only symbol stubs, byte size of stub in the reserved2 field
    MKSectionTypeSymbolStubs                    = S_SYMBOL_STUBS,
    //! Section with only function pointers for initialization
    MKSectionTypeModInitFunctionPointers        = S_MOD_INIT_FUNC_POINTERS,
    //! Section with only function pointers for termination
    MKSectionTypeModTermFunctionPointers        = S_MOD_TERM_FUNC_POINTERS,
    //! Section contains symbols that are to be coalesced
    MKSectionTypeCoalesced                      = S_COALESCED,
    //! Zero fill on demand section (that can be larger than 4 gigabytes)
    MKSectionTypeGBZeroFill                     = S_GB_ZEROFILL,
    //! Section with only pairs of function pointers for interposing
    MKSectionTypeInterposing                    = S_INTERPOSING,
    //! section with only 16 byte literals
    MKSectionType16ByteLiterals                 = S_16BYTE_LITERALS,
    //! Section contains DTrace Object Format
    MKSectionTypeDTraceDOF                      = S_DTRACE_DOF,
    //! Section with only lazy symbol pointers to lazy loaded dylibs
    MKSectionTypeLazyDylibSymbolPointers        = S_LAZY_DYLIB_SYMBOL_POINTERS,
    //! Template of initial values for TLVs
    MKSectionTypeThreadLocalRegular             = S_THREAD_LOCAL_REGULAR,
    //! Template of initial values for TLVs
    MKSectionTypeThreadLocalZeroFill            = S_THREAD_LOCAL_ZEROFILL,
    //! TLV descriptors
    MKSectionTypeThreadLocalVariables           = S_THREAD_LOCAL_VARIABLES,
    //! pointers to TLV descriptors
    MKSectionTypeThreadLocalVariablePointers    = S_THREAD_LOCAL_VARIABLE_POINTERS,
    //! Functions to call to initialize TLV values
    MKSectionTypeLocalInitFunctionPointers      = S_THREAD_LOCAL_INIT_FUNCTION_POINTERS,
};



//----------------------------------------------------------------------------//
//! @name       Section Attributes
//! @relates    MKSection
//!
//
typedef NS_OPTIONS(uint32_t, MKSectionAttributes) {
    //! User setable attributes
    MKSectionAttributeUserMask                  = SECTION_ATTRIBUTES_USR,
    //! Section contains only true machine instructions
    MKSectionAttributePureInstructions          = S_ATTR_PURE_INSTRUCTIONS,
    //! Section contains coalesced symbols that are not to be in a ranlib table
    //! of contents
    MKSectionAttributeNoTOC                     = S_ATTR_NO_TOC,
    //! ok to strip static symbols in this section in files with the
    //! \c MH_DYLDLINK flag
    MKSectionAttributeStripStaticSymbols        = S_ATTR_STRIP_STATIC_SYMS,
    //! No dead stripping
    MKSectionAttributeNoDeadStripping           = S_ATTR_NO_DEAD_STRIP,
    //! Blocks are live if they reference live blocks
    MKSectionAttributeLiveSupport               = S_ATTR_LIVE_SUPPORT,
    //! Used with i386 code stubs written on by dyld
    MKSectionAttributeSelfModifyingCode         = S_ATTR_SELF_MODIFYING_CODE,
    //! A debug section
    MKSectionAttributeDebug                     = S_ATTR_DEBUG,
    
    //! System setable attributes
    MKSectionAttributeSystemMask                = SECTION_ATTRIBUTES_SYS,
    //! Section contains some machine instructions
    MKSectionAttributeSomeInstructions          = S_ATTR_SOME_INSTRUCTIONS,
    //! Section has external relocation entries
    MKSectionAttributeExternalRelocations       = S_ATTR_EXT_RELOC,
    //! Section has local relocation entries
    MKSectionAttributeLocalRelocations          = S_ATTR_LOC_RELOC,
};



//----------------------------------------------------------------------------//
@interface MKSection : MKBackedNode {
@package
    mk_vm_address_t _nodeContextAddress;
    mk_vm_size_t _nodeContextSize;
    /// Data ///
    NSString *_name;
    id<MKLCSection> _loadCommand;
    uint32_t _alignment;
    mk_vm_address_t _fileOffset;
    mk_vm_address_t _vmAddress;
    mk_vm_size_t _size;
    uint32_t _flags;
}

//! Returns the subclass of \ref MKSection that is most suitable for parsing
//! the section with the provided load command.
+ (Class)classForSectionLoadCommand:(id<MKLCSection>)sectionLoadCommand inSegment:(MKSegment*)segment;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Subclassing MKSection
//! @name       Subclassing MKSection
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

+ (uint32_t)canInstantiateWithSectionLoadCommand:(id<MKLCSection>)sectionLoadCommand inSegment:(MKSegment*)segment;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Creating a Section
//! @name       Creating a Section
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

+ (nullable instancetype)sectionWithLoadCommand:(id<MKLCSection>)sectionLoadCommand inSegment:(MKSegment*)segment error:(NSError**)error;

- (nullable instancetype)initWithLoadCommand:(id<MKLCSection>)sectionLoadCommand inSegment:(MKSegment*)segment error:(NSError**)error NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithParent:(MKNode *)parent error:(NSError **)error NS_UNAVAILABLE;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  About This Section
//! @name       About This Section
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//! The name of this section, as specified in the load command.
@property (nonatomic, readonly, nullable) NSString *name;
//! The load command identifying this section.
@property (nonatomic, readonly) id<MKLCSection> loadCommand;
@property (nonatomic, readonly) uint32_t alignment;

@property (nonatomic, readonly) mk_vm_address_t fileOffset;
@property (nonatomic, readonly) mk_vm_address_t vmAddress;
@property (nonatomic, readonly) mk_vm_size_t size;

@property (nonatomic, readonly) uint32_t flags;
@property (nonatomic, readonly) MKSectionType type;
@property (nonatomic, readonly) MKSectionAttributes attributes;

@end

NS_ASSUME_NONNULL_END
