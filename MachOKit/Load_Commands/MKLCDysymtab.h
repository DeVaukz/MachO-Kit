//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       MKLCDysymtab.h
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

#import <MachOKit/MKLoadCommand.h>

NS_ASSUME_NONNULL_BEGIN

//----------------------------------------------------------------------------//
//! Parser for \c LC_DYSYMTAB.
//
@interface MKLCDysymtab : MKLoadCommand {
@package
    uint32_t _ilocalsym;
    uint32_t _nlocalsym;
    uint32_t _iextdefsym;
    uint32_t _nextdefsym;
    uint32_t _iundefsym;
    uint32_t _nundefsym;
    uint32_t _tocoff;
    uint32_t _ntoc;
    uint32_t _modtaboff;
    uint32_t _nmodtab;
    uint32_t _extrefsymoff;
    uint32_t _nextrefsyms;
    uint32_t _indirectsymoff;
    uint32_t _nindirectsyms;
    uint32_t _extreloff;
    uint32_t _nextrel;
    uint32_t _locreloff;
    uint32_t _nlocrel;
}

@property (nonatomic, readonly) uint32_t ilocalsym;
@property (nonatomic, readonly) uint32_t nlocalsym;

@property (nonatomic, readonly) uint32_t iextdefsym;
@property (nonatomic, readonly) uint32_t nextdefsym;

@property (nonatomic, readonly) uint32_t iundefsym;
@property (nonatomic, readonly) uint32_t nundefsym;

@property (nonatomic, readonly) uint32_t tocoff;
@property (nonatomic, readonly) uint32_t ntoc;

@property (nonatomic, readonly) uint32_t modtaboff;
@property (nonatomic, readonly) uint32_t nmodtab;

@property (nonatomic, readonly) uint32_t extrefsymoff;
@property (nonatomic, readonly) uint32_t nextrefsyms;

@property (nonatomic, readonly) uint32_t indirectsymoff;
@property (nonatomic, readonly) uint32_t nindirectsyms;

@property (nonatomic, readonly) uint32_t extreloff;
@property (nonatomic, readonly) uint32_t nextrel;

@property (nonatomic, readonly) uint32_t locreloff;
@property (nonatomic, readonly) uint32_t nlocrel;

@end

NS_ASSUME_NONNULL_END
