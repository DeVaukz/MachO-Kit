//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       MKNodeFieldSTABType.h
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

#include <mach-o/stab.h>

#import <MachOKit/MKNodeFieldTypeByte.h>
#import <MachOKit/MKNodeFieldEnumerationType.h>

NS_ASSUME_NONNULL_BEGIN

//----------------------------------------------------------------------------//
//! @name       STAB Type
//! @relates    MKNodeFieldSTABType
//!
//
typedef uint8_t MKSTABType NS_TYPED_EXTENSIBLE_ENUM;

static const MKSTABType MKSTABTypeGlobalSymbol                  = N_GSYM;
static const MKSTABType MKSTABTypeProcedureName                 = N_FNAME;
static const MKSTABType MKSTABTypeProcedure                     = N_FUN;
static const MKSTABType MKSTABTypeStaticSymbol                  = N_STSYM;
static const MKSTABType MKSTABTypeLocalCommonSymbol             = N_LCSYM;
static const MKSTABType MKSTABTypeBeginNSect                    = N_BNSYM;
static const MKSTABType MKSTABTypeASTFilePath                   = N_AST;
static const MKSTABType MKSTABTypeOPT                           = N_OPT;
static const MKSTABType MKSTABTypeRegisterSymbol                = N_RSYM;
static const MKSTABType MKSTABTypeSourceLine                    = N_SLINE;
static const MKSTABType MKSTABTypeEndNSect                      = N_ENSYM;
static const MKSTABType MKSTABTypeStructureELT                  = N_SSYM;
static const MKSTABType MKSTABTypeSourceFileName                = N_SO;
static const MKSTABType MKSTABTypeObjectFileName                = N_OSO;
static const MKSTABType MKSTABTypeLocalSymbol                   = N_LSYM;
static const MKSTABType MKSTABTypeBeginIncludeFile              = N_BINCL;
static const MKSTABType MKSTABTypeIncludedFileName              = N_SOL;
static const MKSTABType MKSTABTypeCompilerParameters            = N_PARAMS;
static const MKSTABType MKSTABTypeCompilerVersion               = N_VERSION;
static const MKSTABType MKSTABTypeCompilerOptimizationLevel     = N_OLEVEL;
static const MKSTABType MKSTABTypeParameter                     = N_PSYM;
static const MKSTABType MKSTABTypeEndIncludeFile                = N_EINCL;
static const MKSTABType MKSTABTypeAlternateEntry                = N_ENTRY;
static const MKSTABType MKSTABTypeLeftBracket                   = N_LBRAC;
static const MKSTABType MKSTABTypeDeletedIncludeFile            = N_EXCL;
static const MKSTABType MKSTABTypeRightBracket                  = N_RBRAC;
static const MKSTABType MKSTABTypeBeginCommon                   = N_BCOMM;
static const MKSTABType MKSTABTypeEndCommon                     = N_ECOMM;
static const MKSTABType MKSTABTypeEndCommonLocalName            = N_ECOML;
static const MKSTABType MKSTABTypeSecondSTABLengthInformation   = N_LENG;



//----------------------------------------------------------------------------//
@interface MKNodeFieldSTABType : MKNodeFieldTypeUnsignedByte <MKNodeFieldEnumerationType>

+ (instancetype)sharedInstance;

@end

NS_ASSUME_NONNULL_END
