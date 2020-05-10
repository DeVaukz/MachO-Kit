//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       MKNodeFieldMachOFlagsType.h
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

#include <mach-o/loader.h>

#import <MachOKit/MKNodeFieldTypeDoubleWord.h>
#import <MachOKit/MKNodeFieldOptionSetType.h>

NS_ASSUME_NONNULL_BEGIN

//----------------------------------------------------------------------------//
//! @name       Mach-O File Flags
//! @relates    MKNodeFieldMachOFlagsType
//
typedef NS_OPTIONS(uint32_t, MKMachOFlags) {
    MKMachOFlagNoUndefinedReferences           = MH_NOUNDEFS,
    MKMachOFlagIncrementalLink                 = MH_INCRLINK,
    MKMachOFlagDYLDLink                        = MH_DYLDLINK,
    MKMachOFlagBindAtLoad                      = MH_BINDATLOAD,
    MKMachOFlagPrebound                        = MH_PREBOUND,
    MKMachOFlagSplitSegments                   = MH_SPLIT_SEGS,
    MKMachOFlagLazyInit                        = MH_LAZY_INIT,
    MKMachOFlagTwoLevelNamespace               = MH_TWOLEVEL,
    MKMachOFlagForceFlatNamespace              = MH_FORCE_FLAT,
    MKMachOFlagNoMultipleDefinitions           = MH_NOMULTIDEFS,
    MKMachOFlagNoFixPrebinding                 = MH_NOFIXPREBINDING,
    MKMachOFlagPrebindable                     = MH_PREBINDABLE,
    MKMachOFlagAllModulesBound                 = MH_ALLMODSBOUND,
    MKMachOFlagSubsectionsViaSymbols           = MH_SUBSECTIONS_VIA_SYMBOLS,
    MKMachOFlagCanonical                       = MH_CANONICAL,
    MKMachOFlagWeakDefines                     = MH_WEAK_DEFINES,
    MKMachOFlagBindsToWeak                     = MH_BINDS_TO_WEAK,
    MKMachOFlagAllowStackExecution             = MH_ALLOW_STACK_EXECUTION,
    MKMachOFlagRootSafe                        = MH_ROOT_SAFE,
    MKMachOFlagSetUIDSafe                      = MH_SETUID_SAFE,
    MKMachOFlagNoReExportedDylibs              = MH_NO_REEXPORTED_DYLIBS,
    MKMachOFlagPositionIndependentExecutable   = MH_PIE,
    MKMachOFlagDeadStrippableDylib             = MH_DEAD_STRIPPABLE_DYLIB,
    MKMachOFlagHasTLVDescriptors               = MH_HAS_TLV_DESCRIPTORS,
    MKMachOFlagNoHeapExecution                 = MH_NO_HEAP_EXECUTION,
    MKMachOFlagAppExtensionSafe                = MH_APP_EXTENSION_SAFE,
    MKMachOFlagNListOutOfSyncWithDyldInfo      = MH_NLIST_OUTOFSYNC_WITH_DYLDINFO,
    MKMachOFlagSimSupport                      = MH_SIM_SUPPORT,
    MKMachOFlagInCache                         = MH_DYLIB_IN_CACHE
};



//----------------------------------------------------------------------------//
@interface MKNodeFieldMachOFlagsType : MKNodeFieldTypeUnsignedDoubleWord <MKNodeFieldOptionSetType>

+ (instancetype)sharedInstance;

@end

NS_ASSUME_NONNULL_END
