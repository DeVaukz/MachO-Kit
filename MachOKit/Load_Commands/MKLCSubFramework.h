//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       MKLCSubFramework.h
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
#import <MachOKit/MKCString.h>

NS_ASSUME_NONNULL_BEGIN

//----------------------------------------------------------------------------//
//! Parser for \c LC_SUB_FRAMEWORK.
//!
//! A dynamically linked shared library may be a subframework of an umbrella
//! framework.  If so it will be linked with "-umbrella umbrella_name" where
//! Where "umbrella_name" is the name of the umbrella framework. A subframework
//! can only be linked against by its umbrella framework or other subframeworks
//! that are part of the same umbrella framework.  Otherwise the static link
//! editor produces an error and states to link against the umbrella framework.
//! The name of the umbrella framework for subframeworks is recorded in the
//! following structure.
//
@interface MKLCSubFramework : MKLoadCommand {
@package
    MKCString *_umbrella;
}

//! The umbrella framework name.
@property (nonatomic, readonly) MKCString *umbrella;

@end

NS_ASSUME_NONNULL_END
