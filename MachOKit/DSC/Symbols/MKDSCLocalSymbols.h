//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       MKDSCLocalSymbols.h
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

@class MKDSCSymbolsInfo;
@class MKDSCSymbolTable;
@class MKDSCStringTable;
@class MKDSCEntriesTable;

NS_ASSUME_NONNULL_BEGIN

//----------------------------------------------------------------------------//
@interface MKDSCLocalSymbols : MKBackedNode {
@package
    mk_vm_address_t _contextAddress;
    mk_vm_address_t _vmAddress;
    mk_vm_size_t _size;
    // Header //
    MKDSCSymbolsInfo *_header;
    MKDSCSymbolTable *_symbolTable;
    MKDSCStringTable *_stringTable;
    MKDSCEntriesTable *_entriesTable;
}

//!
- (nullable instancetype)initWithSize:(mk_vm_size_t)size atAddress:(mk_vm_address_t)contextAddress parent:(MKNode*)parent error:(NSError**)error NS_DESIGNATED_INITIALIZER;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Header and Symbols
//! @name       Header and Symbols
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//! 
@property (nonatomic, readonly) MKDSCSymbolsInfo *header;

//!
@property (nonatomic, readonly) MKDSCSymbolTable *symbolTable;

//!
@property (nonatomic, readonly) MKDSCStringTable *stringTable;

//!
@property (nonatomic, readonly) MKDSCEntriesTable *entriesTable;

@end

NS_ASSUME_NONNULL_END
