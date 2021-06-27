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

#import <MachOKit/MKBase.h>

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
#define MK_PUSH_WARNING_WITH_ERROR(PROPERTY, CODE, UNDERLYING_ERROR, ...) \
	self.warnings = [self.warnings arrayByAddingObject:[NSError mk_errorWithDomain:MKErrorDomain code:CODE property:MK_PROPERTY(PROPERTY) underlyingError:UNDERLYING_ERROR description:__VA_ARGS__]]

/* Deprecated */
#define MK_PUSH_UNDERLYING_WARNING(PROPERTY, UNDERLYING_ERROR, ...) \
    self.warnings = [self.warnings arrayByAddingObject:[NSError mk_errorWithDomain:MKErrorDomain code:[UNDERLYING_ERROR code] property:MK_PROPERTY(PROPERTY) underlyingError:UNDERLYING_ERROR description:__VA_ARGS__]]

//----------------------------------------------------------------------------//

//! Creates an \c NSError describing the arithmetic error that occurred while
//! applying \a OFFSET to \a ADDRESS.
#define MK_MAKE_VM_ADDRESS_APPLY_OFFSET_ARITHMETIC_ERROR(CODE, ADDRESS, OFFSET) \
    [NSError mk_errorWithDomain:MKErrorDomain code:(NSInteger)CODE description:@"Arithmetic error [%s] adding offset '%s' [%" MK_VM_PRIuOFFSET "] to address '%s' [%" MK_VM_PRIxADDR "].", mk_error_string(CODE), #OFFSET, OFFSET, #ADDRESS, ADDRESS]

//! Creates an \c NSError describing the arithmetic error that ocurred while
//! applying \a SLIDE to \a ADDRESS.
#define MK_MAKE_VM_ADDRESS_APPLY_SLIDE_ARITHMETIC_ERROR(CODE, ADDRESS, SLIDE) \
[NSError mk_errorWithDomain:MKErrorDomain code:(NSInteger)CODE description:@"Arithmetic error [%s] applying slide '%s' [%" MK_VM_PRIiSLIDE "] to address '%s' [%" MK_VM_PRIxADDR "].", mk_error_string(CODE), #SLIDE, SLIDE, #ADDRESS, ADDRESS]

//! Creates an \c NSError describing the arithmetic error that ocurred while
//! removing \a SLIDE from \a ADDRESS.
#define MK_MAKE_VM_ADDRESS_REMOVE_SLIDE_ARITHMETIC_ERROR(CODE, ADDRESS, SLIDE) \
[NSError mk_errorWithDomain:MKErrorDomain code:(NSInteger)CODE description:@"Arithmetic error [%s] removing slide '%s' [%" MK_VM_PRIiSLIDE "] from address '%s' [%" MK_VM_PRIxADDR "].", mk_error_string(CODE), #SLIDE, SLIDE, #ADDRESS, ADDRESS]

//! Creates an \c NSError describing the arithmetic error that occurred while
//! adding \a RHS_ADDRESS to \a LHS_ADDRESS.
#define MK_MAKE_VM_ADDRESS_ADD_ARITHMETIC_ERROR(CODE, LHS_ADDRESS, RHS_ADDRESS) \
    [NSError mk_errorWithDomain:MKErrorDomain code:(NSInteger)CODE description:@"Arithmetic error [%s] adding address '%s' [%" MK_VM_PRIxADDR "] to address '%s' [%" MK_VM_PRIxADDR "].", mk_error_string(CODE), #RHS_ADDRESS, RHS_ADDRESS, #LHS_ADDRESS, LHS_ADDRESS]

//! Creates an \c NSError describing the arithmetic error that occurred while
//! subtracting \a RHS_ADDRESS from \a LHS_ADDRESS.
#define MK_MAKE_VM_ADDRESS_SUBTRACT_ARITHMETIC_ERROR(CODE, LHS_ADDRESS, RHS_ADDRESS) \
	MK_MAKE_VM_ADDRESS_DEFFERENCE_ARITHMETIC_ERROR(CODE, LHS_ADDRESS, RHS_ADDRESS)

//! Creates an \c NSError describing the arithmetic error that ocurred while
//! subtracting \a RHS_ADDRESS from \a LHS_ADDRESS.
#define MK_MAKE_VM_ADDRESS_DEFFERENCE_ARITHMETIC_ERROR(CODE, LHS_ADDRESS, RHS_ADDRESS) \
    [NSError mk_errorWithDomain:MKErrorDomain code:(NSInteger)CODE description:@"Arithmetic error [%s] while subtracting address '%s' [%" MK_VM_PRIxADDR "] from address '%s' [%" MK_VM_PRIxADDR "].", mk_error_string(CODE), #RHS_ADDRESS, RHS_ADDRESS, #LHS_ADDRESS, LHS_ADDRESS]

//! Creates an \c NSError describing the overflow condition
//! that would be triggered if the provided \a LENGTH was added to the
//! provided \a ADDRESS.
#define MK_MAKE_VM_LENGTH_CHECK_ERROR(CODE, ADDRESS, LENGTH) \
    [NSError mk_errorWithDomain:MKErrorDomain code:(NSInteger)CODE description:@"Adding '%s' [%" MK_VM_PRIuSIZE "] to address '%s' [%" MK_VM_PRIxADDR "] would result in an arithmetic error [%s].", #LENGTH, LENGTH, #ADDRESS, ADDRESS, mk_error_string(CODE)];

//! Creates an \c NSError describing the arithmetic error that occurred while
//! adding \a RHS_SIZE to \a LHS_OFFSET.
#define MK_MAKE_VM_OFFSET_ADD_ARITHMETIC_ERROR(CODE, LHS_OFFSET, RHS_SIZE) \
    [NSError mk_errorWithDomain:MKErrorDomain code:(NSInteger)CODE description:@"Arithmetic error [%s] while adding '%s' [%" MK_VM_PRIuSIZE "] to offset '%s' [%" MK_VM_PRIuOFFSET "].", mk_error_string(CODE), #RHS_SIZE, RHS_SIZE, #LHS_OFFSET, LHS_OFFSET]

//! Creates an \c NSError describing the arithmetic error that occurred while
//! adding \a RHS_SIZE to \a LHS_SIZE.
#define MK_MAKE_VM_SIZE_ADD_ARITHMETIC_ERROR(CODE, LHS_SIZE, RHS_SIZE) \
    [NSError mk_errorWithDomain:MKErrorDomain code:(NSInteger)CODE description:@"Arithmetic error [%s] while adding '%s' [%" MK_VM_PRIuSIZE "] to '%s' [%" MK_VM_PRIuSIZE "].", mk_error_string(CODE), #RHS_SIZE, RHS_SIZE, #LHS_SIZE, LHS_SIZE]

//! Creates an \c NSError describing the arithmetic error that occurred while
//! multiplying \a LHS_SIZE by \a RHS_MULTIPLIER.
#define MK_MAKE_VM_SIZE_MULTIPLY_ARITHMETIC_ERROR(CODE, LHS_SIZE, RHS_MULTIPLIER) \
    [NSError mk_errorWithDomain:MKErrorDomain code:(NSInteger)CODE description:@"Arithmetic error [%s] while multiplying '%s' [%" MK_VM_PRIuSIZE "] by '%s' [%" PRIu64 "].", mk_error_string(CODE), #LHS_SIZE, LHS_SIZE, #RHS_MULTIPLIER, RHS_MULTIPLIER]

//! Creates an \c NSError describing the arithmetic error that occurred while
//! multiplying \a LHS_SIZE by \a RHS_MULTIPLIER and adding the result to
//! \a BASE.
#define MK_MAKE_VM_SIZE_ADD_WITH_MULTIPLY_ARITHMETIC_ERROR(CODE, BASE, LHS_SIZE, RHS_MULTIPLIER) \
    [NSError mk_errorWithDomain:MKErrorDomain code:(NSInteger)CODE description:@"Arithmetic error [%s] while multiplying '%s' [%" MK_VM_PRIuSIZE "] by '%s' [%" PRIu64 "] and adding the result to '%s' [%" MK_VM_PRIuSIZE "].", mk_error_string(CODE), #LHS_SIZE, LHS_SIZE, #RHS_MULTIPLIER, RHS_MULTIPLIER, #BASE, BASE]

//----------------------------------------------------------------------------//
//! @name       Error Domains
//! @relates    MKError
//

//! The domain for all errors originating from Mach-O Kit.
extern NSErrorDomain const MKErrorDomain;

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
+ (instancetype)mk_errorWithDomain:(NSString*)domain code:(NSInteger)code description:(nullable NSString*)description reason:(nullable NSString*)reason, ...;

+ (instancetype)mk_errorWithDomain:(NSString*)domain code:(NSInteger)code property:(nullable NSString*)property description:(nullable NSString*)description, ...;
+ (instancetype)mk_errorWithDomain:(NSString*)domain code:(NSInteger)code property:(nullable NSString*)property description:(nullable NSString*)description reason:(nullable NSString*)reason, ...;

+ (instancetype)mk_errorWithDomain:(NSString*)domain underlyingError:(NSError*)underlyingError description:(nullable NSString*)description, ...;

+ (instancetype)mk_errorWithDomain:(NSString*)domain code:(NSInteger)code underlyingError:(nullable NSError*)underlyingError description:(nullable NSString*)description, ...;

+ (instancetype)mk_errorWithDomain:(NSString*)domain code:(NSInteger)code property:(nullable NSString*)property underlyingError:(nullable NSError*)underlyingError description:(nullable NSString*)description, ...;
+ (instancetype)mk_errorWithDomain:(NSString*)domain code:(NSInteger)code property:(nullable NSString*)property underlyingError:(nullable NSError*)underlyingError description:(nullable NSString*)description reason:(nullable NSString*)reason, ...;

//! The value associated with the \ref MKPropertyKey in this error's
//! \c userInfo dictionary.
@property (nonatomic, readonly, nullable) NSString *mk_property;

@end

NS_ASSUME_NONNULL_END
