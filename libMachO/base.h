//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       base.h
//!
//! @author     D.V.
//! @copyright  Copyright (c) 2014-2015 D.V. All rights reserved.
//!
//! @brief
//! Various macros.
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

#ifndef _base_h
#define _base_h

#include <stdio.h>
#include <stdbool.h>
#include <stdint.h>
#include <stddef.h>
#include <unistd.h>

#ifdef __APPLE__
    #include <Availability.h>
    #include <TargetConditionals.h>
#endif

//----------------------------------------------------------------------------//
#pragma mark -  Annotations
/// @name       Annotations
//----------------------------------------------------------------------------//

#if __GNUC__
#   define _mk_noreturn __attribute__((__noreturn__))
#   define _mk_unused __attribute__((__unused__))
#else
#   define _mk_noreturn
#   define _mk_unused
#endif


//----------------------------------------------------------------------------//
#pragma mark -  Declarations
/// @name       Declarations
//----------------------------------------------------------------------------//

// Enums and Options
#if (__cplusplus && __cplusplus >= 201103L && (__has_extension(cxx_strong_enums) || __has_feature(objc_fixed_enum))) || (!__cplusplus && __has_feature(objc_fixed_enum))
#define MK_ENUM(_type, _name) enum _name : _type _name; enum _name : _type
#if (__cplusplus)
#define MK_OPTIONS(_type, _name) _type _name; enum : _type
#else
#define MK_OPTIONS(_type, _name) enum _name : _type _name; enum _name : _type
#endif
#else
#define MK_ENUM(_type, _name) _type _name; enum
#define MK_OPTIONS(_type, _name) _type _name; enum
#endif

// Transparent Union
#if defined(DOXYGEN)
#   define _mk_transparent_union
#elif __GNUC__ && !defined(__cplusplus)
#   define _mk_transparent_union __attribute__((__transparent_union__))
#else
#   define _mk_transparent_union
#endif

//----------------------------------------------------------------------------//
#pragma mark -  Visibility
/// @name       Visibility
//----------------------------------------------------------------------------//

//! Hide the following definition from other modules.
#if defined(DOXYGEN)
#   define _mk_internal
#elif __GNUC__
#   define _mk_internal __attribute__((visibility("hidden")))
#else
#   define _mk_internal
#endif

//! Indicate the existance of the following declaration to other translation
//! units.
#if defined(DOXYGEN)
#    define _mk_export
#elif __GNUC__ && defined(__cplusplus)
#    define _mk_export extern "C" __attribute__((visibility("default")))
#elif __GNUC__
#   define _mk_export extern __attribute__((visibility("default")))
#else
#    define _mk_export extern
#endif

//! Hide the following declaration from other modules.
#if defined(DOXYGEN)
#   define _mk_internal_extern
#elif __GNUC__ && defined(__cplusplus)
#   define _mk_internal_extern extern "C" __attribute__((visibility("hidden")))
#elif __GNUC__
#   define _mk_internal_extern extern __attribute__((visibility("hidden")))
#else
#   define _mk_internal_extern extern
#endif

//! Inline the declaration
#if defined(DOXYGEN)
#   define _mk_inline
#elif __GNUC__ || __has_attribute(always_inline)
#   define _mk_inine inline __attribute__((__always_inline__))
#else
#   define _mk_inine inline
#endif

//----------------------------------------------------------------------------//
#pragma mark -  Swift
/// @name       Swift
//----------------------------------------------------------------------------//

#if __has_attribute(swift_private)
#   define _mk_refined_for_swift __attribute__((__swift_private__))
#else
#   define _mk_refined_for_swift
#endif

//! Swift refinment
#if __has_attribute(swift_name)
#   define _mk_swift_name(_name) __attribute__((swift_name(#_name)))
#else
#   define _mk_swift_name(_name)
#endif


#endif /* _base_h */
