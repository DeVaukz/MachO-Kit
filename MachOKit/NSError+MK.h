//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       NSError+MK.h
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
@import Foundation;

NS_ASSUME_NONNULL_BEGIN

//! Converts the provided property identifier into an \c NSString literal.
#define MK_PROPERTY(PROPERTY) @#PROPERTY

//! Creates an \c NSError instance for the property with the provided identifer
//! and adds it to the warnings list for the current node.
//!
//! Usage:
//!
//!     MK_PUSH_WARNING(someProperty, MK_EINVALID_DATA, @"Invalid data!")
//!
//! @note
//! May only be used within the context of an \ref MKNode or subclass.
#define MK_PUSH_WARNING(PROPERTY, CODE, ...) \
    self.warnings = [self.warnings arrayByAddingObject:[NSError mk_errorWithDomain:MKErrorDomain code:CODE property:MK_PROPERTY(PROPERTY) description:__VA_ARGS__]]

//! Similar to \ref MK_PUSH_WARNING but includes an extra parameter to specify
//! the underlying error that triggered the warning.
#define MK_PUSH_UNDERLYING_WARNING(PROPERTY, UNDERLYING_ERROR, ...) \
    self.warnings = [self.warnings arrayByAddingObject:[NSError mk_errorWithDomain:MKErrorDomain code:[UNDERLYING_ERROR code] property:MK_PROPERTY(PROPERTY) underlyingError:UNDERLYING_ERROR description:__VA_ARGS__]]

//----------------------------------------------------------------------------//

//! Creates and returns an \c NSError describing the arithmetic error
//! that occurred while applying the provided \a OFFSET to the provided
//! \a ADDRESS.
#define MK_MAKE_VM_ARITHMETIC_ERROR(CODE, ADDRESS, OFFSET) \
    [NSError mk_errorWithDomain:MKErrorDomain code:CODE description:@"Arithmetic error %s while applying %s (%" MK_VM_PRIiOFFSET ") to %s (%" MK_VM_PRIxADDR ")", mk_error_string(CODE), #OFFSET, OFFSET, #ADDRESS, ADDRESS]

//! Creates and returns an \c NSError describing the overflow condition
//! that would be triggered if the provided \a LENGTH was added to the
//! provided \a ADDRESS.
#define MK_MAKE_VM_LENGTH_CHECK_ERROR(CODE, ADDRESS, LENGTH) \
    [NSError mk_errorWithDomain:MKErrorDomain code:CODE description:@"Adding %s (%" MK_VM_PRIiSIZE ") to %s (%" MK_VM_PRIxADDR ") would trigger %s.", #LENGTH, LENGTH, #ADDRESS, ADDRESS, mk_error_string(CODE)];

//----------------------------------------------------------------------------//
//! @name       Error Domains
//! @relates    MKError
//

//! The domain for all errors originating rom Mach-O Kit.
extern NSString * const MKErrorDomain;

//----------------------------------------------------------------------------//
//! @name       User info dictionary keys
//! @relates    MKError
//

//! The value for this key is an \c NSString containg the name of the node
//! property to which this error applies, or \c nil for errors not specific to
//! a node property.
//!
//! This key may appear in the \c userInfo dictionary of \c NSError instances
//! with the \ref MKErrorDomain.
//!
//! @seealso    MK_PROPERTY
extern NSString * const MKPropertyKey;



//----------------------------------------------------------------------------//
//! Mach-O Kit extensions to \c NSError.
//!
@interface NSError (MKError)

//! Creates and initializes an NSError object for a given domain and code
//! with a given description.
+ (instancetype)mk_errorWithDomain:(NSString*)domain code:(NSInteger)code description:(nullable NSString*)description, ...;
+ (instancetype)mk_errorWithDomain:(NSString*)domain code:(NSInteger)code property:(NSString*)property description:(nullable NSString*)description, ...;
+ (instancetype)mk_errorWithDomain:(NSString*)domain code:(NSInteger)code underlyingError:(NSError*)underlyingError description:(nullable NSString*)description, ...;
+ (instancetype)mk_errorWithDomain:(NSString*)domain code:(NSInteger)code property:(NSString*)property underlyingError:(NSError*)underlyingError description:(nullable NSString*)description, ...;

//! The value associated with the \ref MKPropertyKey in this error's
//! \c userInfo dictionary.
@property (nonatomic, readonly, nullable) NSString *mk_property;

@end

NS_ASSUME_NONNULL_END
