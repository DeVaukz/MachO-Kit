//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       core.h
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

//----------------------------------------------------------------------------//
//! @defgroup CORE Core
//!
//! The CORE module contains essential types and functions used by the other
//! modules of libMachO and Mach-O kit.
//----------------------------------------------------------------------------//

#ifndef _core_h
#define _core_h

#include "base.h"

#include <mach/mach.h>
#if TARGET_OS_MAC && !TARGET_OS_IPHONE
#   include <mach/mach_vm.h>
#   define MK_HAVE_MACH_VM 1
#endif

//! @addtogroup CORE
//! @{
//!

//----------------------------------------------------------------------------//
#pragma mark -  Types
//! @name       Types
//----------------------------------------------------------------------------//

//! The largest address value that can be represented by the
//! \ref mk_vm_address_t type.
#define MK_VM_ADDRESS_MAX UINT64_MAX
//! The largest address value that can be represented by the
//! \ref mk_vm_size_t type.
#define MK_VM_SIZE_MAX UINT64_MAX
//! The largest offset value that can be represented by the
//! \ref mk_vm_offset_t type.
#define MK_VM_OFF_MAX UINT64_MAX
//! The smallest offset value that can be represented by the
//! \ref mk_vm_offset_t type.
#define MK_VM_OFF_MIN 0
//! The largest offset value that can be represented by the
//! \ref mk_vm_slide_t type.
#define MK_VM_SLIDE_MAX INT64_MAX
//! The smallest offset value that can be represented by the
//! \ref mk_vm_slide_t type.
#define MK_VM_SLIDE_MIN INT64_MIN

//! An invalid address value.
#define MK_VM_ADDRESS_INVALID MK_VM_ADDRESS_MAX
//! An invalid size value.
#define MK_VM_SIZE_INVALID MK_VM_SIZE_MAX
//! An invalid offset value.
#define MK_VM_OFFSET_INVALID MK_VM_OFF_MAX

//! Print formatter for the \ref mk_vm_address_t type.
#define MK_VM_PRIxADDR PRIx64
#define MK_VM_PRIXADDR PRIX64
//! Print formatters for the \ref mk_vm_size_t type.
#define MK_VM_PRIxSIZE PRIx64
#define MK_VM_PRIiSIZE PRIi64
#define MK_VM_PRIuSIZE PRIu64
//! Print formatters for the \ref mk_vm_offset_t type.
#define MK_VM_PRIXOFFSET PRIX64
#define MK_VM_PRIxOFFSET PRIx64
#define MK_VM_PRIiOFFSET PRIi64 // TODO - Remove this
#define MK_VM_PRIuOFFSET PRIu64
//! Print formatters for the \ref mk_vm_slide_t type.
#define MK_VM_PRIiSLIDE PRIi64

//! Architecture-independent VM address type.
#if MK_HAVE_MACH_VM
    typedef mach_vm_address_t mk_vm_address_t;
#else
    typedef uint64_t mk_vm_address_t;
#endif

//! Architecture-independent VM size type.
#if MK_HAVE_MACH_VM
    typedef mach_vm_size_t mk_vm_size_t;
#else
    typedef uint64_t mk_vm_size_t;
#endif

//! Architecture-independent VM offset type.
#if MK_HAVE_MACH_VM
	typedef mach_vm_offset_t mk_vm_offset_t;
#else
	typedef uint64_t mk_vm_offset_t;
#endif

//! Architecture-independent VM slide type.
typedef int64_t mk_vm_slide_t;


//----------------------------------------------------------------------------//
#pragma mark -  Errors
//! @name       Errors
//----------------------------------------------------------------------------//

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
//! Error Return Codes
//
typedef enum {
    //! Success
    MK_ESUCCESS = 0,
    //! A platform API call failed, or other indirect error.
    MK_EINTERNAL_ERROR,
    //! A callout to the application returned an error.
    MK_ECLIENT_ERROR,
    //! A callout to the application returned invalid data.
    MK_ECLIENT_INVALID_RESULT,
    //! Invalid argument
    MK_EINVAL,
    //! The input data is in an unknown or invalid format.
    MK_EINVALID_DATA,
    //! The requested item could not be found.
    MK_ENOT_FOUND,
    //! The requested item is unavailable.
    MK_EUNAVAILABLE,
    //! A derived value needed for the operation could not be computed.
    MK_EDERIVED,
    //!
    MK_EOUT_OF_RANGE,
    //!
    MK_ESIZE,
    //! Adding the provided inputs would result in an overflow.
    MK_EOVERFLOW,
    //! Adding the provided inputs would result in an underflow.
    MK_EUNDERFLOW,
    //! Memory at the input address can not be accessed.
    MK_EBAD_ACCESS
} mk_error_t;

//! A mask applied to the returned error code if the error occurred while
//! accessing memory in a memory map or memory object.
#define MK_EMEMORY_ERROR 0x80000000

//! Assigns the rvalue to the error output parameter of the current method,
//! which must be named \c error.
//!
//! Usage:
//!
//!     MK_ERROR_OUT = anNSErrorRValue.
//!
#define MK_ERROR_OUT if (error) *error

//! Returns a string representation of \a error.
_mk_export const char *
mk_error_string(mk_error_t error);


//----------------------------------------------------------------------------//
#pragma mark -  Ranges
//! @name       Ranges
//----------------------------------------------------------------------------//

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
//! A structure used to describe a portion of host memory.
//
typedef struct {
    mk_vm_address_t location;
    mk_vm_size_t length;
} mk_vm_range_t;

//! Creates and returns a new \ref mk_vm_range_t with the provided \a location
//! and \a length.
_mk_export mk_vm_range_t
mk_vm_range_make(mk_vm_address_t location, mk_vm_size_t length);

//! Returns the address of the first byte in \a range.
_mk_export mk_vm_address_t
mk_vm_range_start(mk_vm_range_t range);

//! Returns the address of the last byte in \a range.
_mk_export mk_vm_address_t
mk_vm_range_end(mk_vm_range_t range);

//! Returns \ref MK_ESUCCESS if (\a address + \a offset) is within \a range.
_mk_export mk_error_t
mk_vm_range_contains_address(mk_vm_range_t range, mk_vm_offset_t offset, mk_vm_address_t address);

//! If \a partial is \c false, returns \ref MK_ESUCCESS if \a inner_range is
//! fully within \a outer_range.  If \a partial is \c false, returns
//! \ref MK_ESUCCESS if all or part of \a inner_range is within \a outer_range.
_mk_export mk_error_t
mk_vm_range_contains_range(mk_vm_range_t outer_range, mk_vm_range_t inner_range, bool partial);


//----------------------------------------------------------------------------//
#pragma mark -  Safe Arithmetic Operations
//! @name       Safe Arithmetic Operations
//----------------------------------------------------------------------------//

//! Safely computes \a addr + \a offset and stores the result in \a result.
//! If there was an overflow, \ref MK_EOVERFLOW is returned and \a result is
//! unmodified.
_mk_export mk_error_t
mk_vm_address_apply_offset(mk_vm_address_t addr, mk_vm_offset_t offset, mk_vm_address_t *result);

//! Safely computes \a addr + \a slide and stores the result in \a result.
//! If there was an overflow, \ref MK_EOVERFLOW is returned and \a result is
//! unmodified.  If there was an underflow, \ref MK_EUNDERFLOW is returned and
//! \a result is unmodified.
_mk_export mk_error_t
mk_vm_address_apply_slide(mk_vm_address_t addr, mk_vm_slide_t slide, mk_vm_address_t *result);

//! Safely computes \a addr - \a slide and stores the result in \a result.
//! If there was an overflow, \ref MK_EOVERFLOW is returned and \a result is
//! unmodified.  If there was an underflow, \ref MK_EUNDERFLOW is returned and
//! \a result is unmodified.
_mk_export mk_error_t
mk_vm_address_remove_slide(mk_vm_address_t addr, mk_vm_slide_t slide, mk_vm_address_t *result);

//! Safely computes \a addr1 + \a addr2 and stores the result in \a result.
//! If there was an overflow, \ref MK_EOVERFLOW is returned and \a result is
//! unmodified.
_mk_export mk_error_t
mk_vm_address_add(mk_vm_address_t addr1, mk_vm_address_t addr2, mk_vm_address_t *result);

//! Safely computes \a left - \a right and stores the result in \a result.
//! If \a right > \a left, \ref MK_EUNDERFLOW is returned and \a result is
//! unmodified.
_mk_export mk_error_t
mk_vm_address_subtract(mk_vm_address_t left, mk_vm_address_t right, mk_vm_offset_t *result);

//! Safely computes \a left - \a right and stores the result in \a result.
_mk_export mk_error_t
mk_vm_address_difference(mk_vm_address_t left, mk_vm_address_t right, mk_vm_slide_t *result);

//! Returns \ref MK_ESUCCESS if \a length can safely be applied to \a addr
//! without causing an overflow.
_mk_export mk_error_t
mk_vm_address_check_length(mk_vm_address_t addr, mk_vm_size_t length);

//! Safely computes \a offset + \a size and stores the result in \a result.
//! If there was an overflow, \ref MK_EOVERFLOW is returned and \a result is
//! unmodified.
_mk_export mk_error_t
mk_vm_offset_add(mk_vm_offset_t offset, mk_vm_size_t size, mk_vm_offset_t *result);

//! Safely computes \a left + \a right and stores the result in \a result.
//! If there was an overflow, \ref MK_EOVERFLOW is returned and \a result is
//! unmodified.
_mk_export mk_error_t
mk_vm_size_add(mk_vm_size_t left, mk_vm_size_t right, mk_vm_size_t *result);

//! Safely computes \a size * \a multiplier and stores the result in \a result.
//! If there was an overflow, \ref MK_EOVERFLOW is returned and \a result is
//! unmodified.
_mk_export mk_error_t
mk_vm_size_multiply(mk_vm_size_t size, uint64_t multiplier, mk_vm_size_t *result);

//! Safely computes \a base + (\a size * \a multiplier) and stores the result in
//! \a result.  If there was an overflow, \ref MK_EOVERFLOW is returned and
//! \a result is unmodified.
_mk_export mk_error_t
mk_vm_size_add_with_multiply(mk_vm_size_t base, mk_vm_size_t size, uint64_t multiplier, mk_vm_size_t *result);


//----------------------------------------------------------------------------//
#pragma mark -  Byte Order
//! @name       Byte Order
//----------------------------------------------------------------------------//

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
//! A collection of byte swapping functions used to provide byte order neutral
//! polymorphism when parsing Mach-O and other file formats.
//
typedef struct {
    //! The byte-swap function to use for 16-bit values.
    uint16_t (*swap16)(uint16_t);
    //! The byte-swap function to use for 32-bit values.
    uint32_t (*swap32)(uint32_t);
    //! The byte-swap function to use for 64-bit values.
    uint64_t (*swap64)(uint64_t);
    //! The byte-swap function to use for arbitrary length values.
    uint8_t* (*swap_any)(uint8_t *input, size_t length);
    
#ifdef __cplusplus
public:
    //! Byte swap a 16-bit value
    uint16_t swap (uint16_t v) const { return swap16(v); }
    //! Byte swap a 32-bit value
    uint32_t swap (uint32_t v) const { return swap32(v); }
    //! Byte swap a 64-bit value
    uint64_t swap (uint64_t v) const { return swap64(v); }
    //! Byte swap an arbitrary length value.
    uint8_t* swap (uint8_t *input, size_t length) const { return swap_any(input, length); }
#endif
} mk_byteorder_t;

//! A \ref mk_byteorder_t that performs no byte-swapping.
_mk_export const mk_byteorder_t mk_byteorder_direct;
//! A \ref mk_byteorder_t that performs byte-swapping.
_mk_export const mk_byteorder_t mk_byteorder_swapped;


//----------------------------------------------------------------------------//
#pragma mark -  Runtime
//! @name       Runtime
//----------------------------------------------------------------------------//

#ifndef DOXYGEN
//! @internal
//! The preamble of all type declarations.
//! 
//! @note   This must be kept in sync with \ref _mk_runtime_base_t.
#define __MK_RUNTIME_BASE   \
    const void* vtable;
#endif

//! A reference to an instance of any polymorphic type.
typedef void* mk_type_ref;

//! Returns a boolean indicating whether the provided instance of any
//! polymorphic type is a member of \a type.
_mk_export bool
mk_type_is(mk_type_ref mk, intptr_t type);

//! Returns a boolean indicating whether the provided instance of any
//! polymorphic type is a member or subtype of \a type.
_mk_export bool
mk_type_is_kind_of(mk_type_ref mk, intptr_t type);

//! Returns the name name of the provided instance of any polymorphic type.
_mk_export const char*
mk_type_name(mk_type_ref mk);

//! Returns \c true if the two instances of any polymorphic type are equal.
_mk_export bool
mk_type_equal(mk_type_ref mk1, mk_type_ref mk2);

//! Copies a description of any polymorphic type into the provided \a output
//! buffer.  Returns the number of bytes copied, not counting the terminating
//! null character.  If \a outout is \c NULL, returns the length of the complete
//! description, not counting the terminating null character.
_mk_export size_t
mk_type_copy_description(mk_type_ref mk, char* output, size_t output_len);


//----------------------------------------------------------------------------//
#pragma mark -  Includes
//----------------------------------------------------------------------------//

#include "logging.h"
#include "context.h"
#include "data_model.h"
#include "memory_map.h"
#include "memory_map_self.h"
#include "memory_map_task.h"


//! @} CORE !//

#endif /* _core_h */
