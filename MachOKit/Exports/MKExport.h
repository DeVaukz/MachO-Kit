//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       MKExport.h
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

#import <MachOKit/MKAddressedNode.h>

// <https://opensource.apple.com/source/dyld/dyld-519.2.1/src/ImageLoaderMachOCompressed.cpp.auto.html>
#ifndef EXPORT_SYMBOL_FLAGS_KIND_ABSOLUTE
	#define EXPORT_SYMBOL_FLAGS_KIND_ABSOLUTE			0x02
#endif

@class MKExportsInfo;
@class MKExportTrieNode;

NS_ASSUME_NONNULL_BEGIN

//----------------------------------------------------------------------------//
//! @name       Export Symbol Kind
//! @relates    MKExport
//!
//
typedef NS_ENUM(uint8_t, MKExportSymbolKind) {
	MKExportSymbolKindRegular           = EXPORT_SYMBOL_FLAGS_KIND_REGULAR,
	MKExportSymbolKindThreadLocal       = EXPORT_SYMBOL_FLAGS_KIND_THREAD_LOCAL,
	MKExportSymbolKindAbsolute          = EXPORT_SYMBOL_FLAGS_KIND_ABSOLUTE
};



//----------------------------------------------------------------------------//
//! @name       Export Symbol Options
//! @relates    MKExport
//!
//
typedef NS_OPTIONS(uint64_t, MKExportOptions) {
	MKExportOptionWeakDefinition        = EXPORT_SYMBOL_FLAGS_WEAK_DEFINITION,
	MKExportOptionReExport              = EXPORT_SYMBOL_FLAGS_REEXPORT,
	MKExportOptionStubAndResolver       = EXPORT_SYMBOL_FLAGS_STUB_AND_RESOLVER,
};



//----------------------------------------------------------------------------//
@interface MKExport : MKAddressedNode {
@package
	mk_vm_size_t _nodeSize;
	uint64_t _flags;
    NSString *_name;
}

//! Returns the subclass of \ref MKExport that is most suitable for
//! representing the export found by walking the tire and encountering the
//!	provided sequence of trie \a nodes.
+ (nullable Class)classForTrieNodes:(NSArray<MKExportTrieNode*> *)nodes;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Subclassing MKExport
//! @name       Subclassing MKExport
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//! This method is called on all \ref MKExport subclasses when
//! determining the appropriate class to instantiate.
//!
//! Subclasses should return a non-zero integer if they support representing
//!	the export found by walking the tire and encountering the provided sequence
//!	of trie \a nodes.  The subclass that returns the largest value will be
//!	instantiated.  \ref MKExport subclasses in Mach-O Kit return a value no
//!	larger than \c 100.  You can substitute your own subclass by returning a
//!	larger value.
+ (uint32_t)canInstantiateWithTrieNodes:(NSArray<MKExportTrieNode*> *)nodes;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Creating an Export
//! @name       Creating an Export
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//! Creates and instantiates the appropriate subclass of \ref MKExport
//! for representing the export found by walking the tire and encountering the
//!	provided sequence of trie \a nodes.
+ (nullable instancetype)exportForTrieNodes:(NSArray<MKExportTrieNode*> *)nodes error:(NSError**)error;

- (nullable instancetype)initWithTrieNodes:(NSArray<MKExportTrieNode*> *)nodes error:(NSError**)error NS_DESIGNATED_INITIALIZER;

- (nullable instancetype)initWithParent:(null_unspecified MKNode*)parent error:(NSError**)error NS_UNAVAILABLE;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Export Information
//! @name       Export Information
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//!
@property (nonatomic, readonly) MKExportSymbolKind kind;

//!
@property (nonatomic, readonly) MKExportOptions options;

//! The export name
@property (nonatomic, readonly) NSString *name;

@end

NS_ASSUME_NONNULL_END
