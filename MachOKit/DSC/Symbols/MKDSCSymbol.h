//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       MKDSCSymbol.h
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

@class MKCString;
@class MKDSCDylibSymbolInfo;

NS_ASSUME_NONNULL_BEGIN

//----------------------------------------------------------------------------//
@interface MKDSCSymbol : MKOffsetNode {
@package
    uint32_t _strx;
    uint8_t _type;
    uint8_t _sect;
    uint16_t _desc;
    uint64_t _value;
    MKCString *_name;
    MKDSCDylibSymbolInfo *_dylib;
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Acessing Symbol Metadata
//! @name       Acessing Symbol Metadata
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//! The index of this stmbol in the symbol table.
@property (nonatomic, readonly) uint32_t index;

//!
@property (nonatomic, readonly, nullable) MKDSCDylibSymbolInfo *dylib;

//! The entry in the string table referenced by this symbol.  May be \c nil.
@property (nonatomic, readonly, nullable) MKCString *name;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  nlist Values
//! @name       nlist Values
//!
//! @brief      These values are extracted directly from the nlist structure
//!             without modification or cleanup.
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//! An offset into the string table, or zero if the symbol has a null or ""
//! name.  The string at this offset, if any, is assigned to the
//! \ref name property of this symbol.
@property (nonatomic, readonly) uint32_t strx;
//! Type information for the symbol.  This is actually a bitfield the format
//! of which is discussed in <mach-o/nlist.h>.
@property (nonatomic, readonly) uint8_t type;
@property (nonatomic, readonly) uint8_t sect;
@property (nonatomic, readonly) uint16_t desc;
@property (nonatomic, readonly) uint64_t value;

@end

NS_ASSUME_NONNULL_END
