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
#import <Foundation/Foundation.h>

#import <MachOKit/MKBackedNode.h>

@class MKSharedCache;
@class MKDSCLocalSymbolsHeader;
@class MKDSCSymbolTable;
@class MKDSCStringTable;
@class MKDSCDylibInfos;

NS_ASSUME_NONNULL_BEGIN

//----------------------------------------------------------------------------//
@interface MKDSCLocalSymbols : MKBackedNode {
@package
    MKMemoryMap *_memoryMap;
    mk_vm_address_t _contextAddress;
    mk_vm_address_t _vmAddress;
    mk_vm_size_t _size;
    // Header //
    MKDSCLocalSymbolsHeader *_header;
    MKDSCSymbolTable *_symbolTable;
    MKDSCStringTable *_stringTable;
    MKDSCDylibInfos *_entriesTable;
}

- (nullable instancetype)initWithSharedCache:(MKSharedCache*)sharedCache error:(NSError**)error NS_DESIGNATED_INITIALIZER;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Header and Symbols
//! @name       Header and Symbols
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//! 
@property (nonatomic, readonly) MKDSCLocalSymbolsHeader *header;

//!
@property (nonatomic, readonly, nullable) MKDSCSymbolTable *symbolTable;

//!
@property (nonatomic, readonly, nullable) MKDSCStringTable *stringTable;

//!
@property (nonatomic, readonly, nullable) MKDSCDylibInfos *entriesTable;

@end

NS_ASSUME_NONNULL_END
