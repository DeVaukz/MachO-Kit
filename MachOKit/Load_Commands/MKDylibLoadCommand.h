//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       MKDylibLoadCommand.h
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
#import <MachOKit/MKDylibVersion.h>
#import <MachOKit/MKCString.h>

NS_ASSUME_NONNULL_BEGIN

//----------------------------------------------------------------------------//
//! The \c MKDylibLoadCommand class is the common parent class for all
//! specialization of \ref MKLoadCommand which reference a dynamically
//! linked shared library.
//!
//! Dynamically linked shared libraries are identified by two things.  The
//! pathname (the name of the library as found for execution), and the
//! compatibility version number.  The pathname must match and the
//! compatibility number in the user of the library must be greater than or
//! equal to the library being used.  The time stamp is used to record the
//! time a library was built and copied into user so it can be use to
//! determine if the library used at runtime is exactly the same as used to
//! build the program.
//
@interface MKDylibLoadCommand : MKLoadCommand {
@package
    MKCString *_name;
    NSDate *_timestamp;
    MKDylibVersion *_current_version;
    MKDylibVersion *_compatibility_version;
}

//! The pathname of the library.
@property (nonatomic, readonly) MKCString *name;

//! The build time stamp of the library.
@property (nonatomic, readonly) NSDate *timestamp;

//! The current version number of the library.
@property (nonatomic, readonly) MKDylibVersion *current_version;

//! The compatibility version number of the library.
@property (nonatomic, readonly) MKDylibVersion *compatibility_version;

@end

NS_ASSUME_NONNULL_END
