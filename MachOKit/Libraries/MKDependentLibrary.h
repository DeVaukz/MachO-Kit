//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       MKDependentLibrary.h
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

#import <MachOKit/MKAddressedNode.h>
#import <MachOKit/MKDylibVersion.h>

@class MKDylibLoadCommand;

NS_ASSUME_NONNULL_BEGIN

//----------------------------------------------------------------------------//
@interface MKDependentLibrary : MKAddressedNode {
@package
    MKDylibLoadCommand *_loadCommand;
}

//! Initializes the receiver with the provided Mach-O.
- (nullable instancetype)initWithLoadCommand:(MKDylibLoadCommand*)loadCommand error:(NSError**)error;

//! The pathname of the library.
@property (nonatomic, readonly) NSString *name;

//! The build time stamp of the library.
@property (nonatomic, readonly) NSDate *timestamp;

//! The current version of the library.
@property (nonatomic, readonly) MKDylibVersion *currentVersion;

//! The compatibility version of the library.
@property (nonatomic, readonly) MKDylibVersion *compatibilityVersion;

//! \c YES if the library must be present at dynamic-link time.
@property (nonatomic, readonly) BOOL required;

//!
@property (nonatomic, readonly) BOOL weak;

//!
@property (nonatomic, readonly) BOOL upward;

//!
@property (nonatomic, readonly) BOOL rexported;

@end

NS_ASSUME_NONNULL_END
