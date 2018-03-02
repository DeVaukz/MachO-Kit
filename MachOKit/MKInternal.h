//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       MKInternal.h
//!
//! @author     D.V.
//! @copyright  Copyright (c) 2014-2015 D.V. All rights reserved.
//!
//! @brief
//! The root include for MachOKit.
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

#ifndef _MKInternal_h
#define _MKInternal_h

#include "internal.h"

#import "NSError+MK.h"
#import "NSNumber+MK.h"

//----------------------------------------------------------------------------//
#pragma mark -  Boxing
/// @name       Boxing
//----------------------------------------------------------------------------//

//! Replacement for \c @() that correctly handles unsigned integers.
#define _$(X) _Generic((X), \
    uint8_t: [NSNumber mk_numberWithUnsignedByte:(X)], \
    uint16_t: [NSNumber mk_numberWithUnsignedWord:(X)], \
    uint32_t: [NSNumber mk_numberWithUnsignedDoubleWord:(X)], \
    uint64_t: [NSNumber mk_numberWithUnsignedQuadWord:(X)], \
    default: @(X) \
)

//----------------------------------------------------------------------------//
#pragma mark -  Singleton
/// @name       Singleton
//----------------------------------------------------------------------------//

//! Helper macro to define -init and +sharedInstance methods for a singleton.
#define MKMakeSingletonInitializer(TYPE) \
static TYPE *s_ ## TYPE = nil; \
+ (instancetype)sharedInstance \
{ \
    if (self == TYPE.class) { \
        if (s_ ## TYPE == nil) \
            s_ ## TYPE = [TYPE new]; \
        return s_ ## TYPE; \
    } else { \
        return [[self new] autorelease]; /*TODO - */ \
    } \
} \
- (instancetype)init \
{ \
    if (s_ ## TYPE == nil || self.class != TYPE.class) { \
        return [super init]; \
    } \
    \
    [self release]; \
    return [[TYPE sharedInstance] retain]; \
}



#endif /* _MKInternal_h */
