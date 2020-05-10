//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       MKLCBuildVersion.h
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
#import <MachOKit/MKVersion.h>

@class MKLCBuildToolVersion;

NS_ASSUME_NONNULL_BEGIN

//----------------------------------------------------------------------------//
//! Parser for \c LC_BUILD_VERSION.
//!
//! The build_version_command contains the minimum OS version that the
//! binary was built to run on.
//
@interface MKLCBuildVersion : MKLoadCommand {
@package
    NSArray<MKLCBuildToolVersion*> *_tools;
    uint32_t _platform;
    MKVersion *_minos;
    MKVersion *_sdk;
    uint32_t _ntools;
}

//!
@property (nonatomic, readonly) NSArray<MKLCBuildToolVersion*> *tools;

//! The platform.
@property (nonatomic, readonly) uint32_t platform;
//! The minimum version of the OS the binary was built to run on.
@property (nonatomic, readonly) MKVersion *minos;
//! The SDK version that the binary was linked with.
@property (nonatomic, readonly) MKVersion *sdk;
//! Number of build tools
@property (nonatomic, readonly) uint32_t ntools;

@end



//----------------------------------------------------------------------------//
//! Parser for a build tool version declaration inside of a build version
//! load command.
//
@interface MKLCBuildToolVersion : MKOffsetNode {
@package
    uint32_t _tool;
    uint32_t _version;
}

//! The build tool.
@property (nonatomic, readonly) uint32_t tool;
//! The build tool version number.
@property (nonatomic, readonly) uint32_t version;

@end

NS_ASSUME_NONNULL_END
