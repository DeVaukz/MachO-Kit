//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       MKExportTrieNode.h
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
#import <Foundation/Foundation.h>

#import <MachOKit/MKOffsetNode.h>

@class MKExportsInfo;
@class MKExportTrieBranch;

NS_ASSUME_NONNULL_BEGIN

//----------------------------------------------------------------------------//
@interface MKExportTrieNode : MKOffsetNode {
@package
    mk_vm_size_t _nodeSize;
    uint64_t _terminalInformationSize;
	NSArray<MKExportTrieBranch*> *_branches;
	uint8_t _childCount;
    size_t _terminalInformationSizeULEBSize;
}

//! Searches the subclasses of \ref MKExportTrieNode that is most suitable for
//! parsing the trie node with the provided \a terminalSize and terminal
//!	information \a contents.
+ (nullable Class)classForNodeWithTerimalSize:(uint64_t)terminalSize contents:(uint8_t*)contents;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Subclassing MKExportTrieNode
//! @name       Subclassing MKExportTrieNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//! This method is called on all \ref MKExportTrieNode subclasses when
//! determining the appropriate class to instantiate to parse the trie node
//!	with the provided \a terminalSize and terminal information \a contents.
//!
//! Subclasses should return a non-zero integer if they support parsing the
//! trie node.  The subclass that returns the largest value will be instantiated
//! with the command data.  \ref MKRebaseCommand subclasses in Mach-O Kit
//!	return a value no larger than \c 100.  You can substitute your own subclass
//!	by returning a larger value.
+ (uint32_t)canInstantiateWithTerimalSize:(uint64_t)terminalSize contents:(uint8_t*)contents;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Creating a Trie Node
//! @name       Creating a Trie Node
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//! Creates an instantiates the appropriate subclass of \ref MKExportTrieNode
//! for parsing the trie node at the provided \a offset from the \a parent.
+ (nullable instancetype)nodeAtOffset:(mk_vm_offset_t)offset fromParent:(MKExportsInfo*)parent error:(NSError**)error;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Trie Node Values
//! @name       Trie Node Values
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//!
@property (nonatomic, readonly) uint64_t terminalInformationSize;

//!
@property (nonatomic, readonly) uint8_t childCount;

//! 
@property (nonatomic, readonly) NSArray<MKExportTrieBranch*> *branches;

@end

NS_ASSUME_NONNULL_END
