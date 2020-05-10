//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       MKLCSubLibrary.h
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
//! Parser for \c LC_SUB_LIBRARY.
//!
//! A dynamically linked shared library may be a sub_library of another shared
//! library.  If so it will be linked with "-sub_library library_name" where
//! Where "library_name" is the name of the sub_library shared library.  When
//! staticly linking when -twolevel_namespace is in effect a twolevel namespace
//! shared library will only cause its subframeworks and those frameworks
//! listed as sub_umbrella frameworks and libraries listed as sub_libraries to
//! be implicited linked in.  Any other dependent dynamic libraries will not be
//! linked it when -twolevel_namespace is in effect.  The primary library
//! recorded by the static linker when resolving a symbol in these libraries
//! will be the umbrella framework (or dynamic library). Zero or more sub_library
//! shared libraries may be use by an umbrella framework or (or dynamic library).
//! The name of a sub_library framework is recorded in the following structure.
//! For example /usr/lib/libobjc_profile.A.dylib would be recorded as "libobjc".
//
@interface MKLCSubLibrary : MKLoadCommand {
@package
    MKCString *_sub_library;
}

//! The sub_library name.
@property (nonatomic, readonly) MKCString *sub_library;

@end

NS_ASSUME_NONNULL_END
