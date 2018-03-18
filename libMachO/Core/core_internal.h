//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       core_internal.h
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

#ifndef _core_private_h
#define _core_private_h
#ifndef DOXYGEN

#include "internal.h"
#include "core.h"

//! @addtogroup CORE
//! @{
//!

//----------------------------------------------------------------------------//
#pragma mark -  Classes
//! @name       Classes
//----------------------------------------------------------------------------//

//! Member function prototype for the \ref mk_type_get_context polymorphic
//! function.  Your implementation should return a pointer to the
//! \ref mk_context_t associated with this instance, or \c NULL if no context
//! is associated with this. instance.
typedef mk_context_t* (*_mk_type_get_context)(mk_type_ref self);

//! Member function prototype for the \ref mk_type_equal polymorphic
//! function.  Your implementation should return \c true if this instance
//! and other type instance are equivalent, \c false otherwise.
typedef bool (*_mk_type_equal)(mk_type_ref self, mk_type_ref other);

//! Member function prototype for the \ref mk_type_copy_description polymorphic
//! function.  Your implementation should write a texture description of this
//! instance to the \a output buffer, respecting the size of the buffer
//! specified by \a output_len.  Return the number of bytes written.
typedef size_t (*_mk_type_copy_description)(mk_type_ref self, char* output, size_t output_len);

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
//! Member function table declaration for the root type.
//
struct _mk_type_vtable {
#if __MACHOKIT__
    //! Used for bridging between libMachO and Mach-O Kit.  libMachO types
    //! must leave this field \c NULL.
    const void *metaclass;
#endif
    const void *super;
    const char *name;
    _mk_type_get_context get_context;
    _mk_type_equal equal;
    _mk_type_copy_description copy_description;
};

//! The preamble to all member function table declarations for types
//! which descend from the root type.  This must be kept in sync with
//! \ref struct _mk_type_vtable.
#define __MK_RUNTIME_TYPE_BASE   struct _mk_type_vtable base;

//! The member function table for the root type.  Contains default
//! implementations of all the methods in \c struct _mk_type_vtable.
_mk_internal_extern
const struct _mk_type_vtable _mk_type_class;


//----------------------------------------------------------------------------//
#pragma mark -  Types
//! @name       Types
//----------------------------------------------------------------------------//

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
//! The preamble to all type declarations.  Do not include this structure
//! directly.  Use the \ref __MK_RUNTIME_TYPE_BASE macro instead.
//
typedef struct _mk_runtime_base_s {
    //! vtable
    void *vtable;
} _mk_runtime_base_t;


//----------------------------------------------------------------------------//
#pragma mark -  Runtime
//! @name       Runtime
//----------------------------------------------------------------------------//

#if __LP64__
// TODO - Find a better way to handle the bridging or remove it altogether.
_mk_weak_import const uintptr_t objc_debug_isa_class_mask;
#endif

//! Helper macro for invoking a method on a bridged MachOKit type provided to
//! a polymorphic libMachO function.
#if __MACHOKIT__
    #if __LP64__
    #define MK_OBJC_BRIDGED_INVOKE(INSTANCE, TYPE, CAST, SELECTOR_STRING) \
        if (objc_debug_isa_class_mask && ((struct _mk_type_vtable*)((uintptr_t)INSTANCE.TYPE->vtable & objc_debug_isa_class_mask))->metaclass != NULL) \
            return ((CAST)objc_msgSend)(INSTANCE.TYPE, sel_getUid(SELECTOR_STRING)); \
        if ( ((struct _mk_type_vtable*)INSTANCE.TYPE->vtable)->metaclass != NULL ) \
            return ((CAST)objc_msgSend)(INSTANCE.TYPE, sel_getUid(SELECTOR_STRING));
    #else
    #define MK_OBJC_BRIDGED_INVOKE(INSTANCE, TYPE, CAST, SELECTOR_STRING) \
        if ( ((struct _mk_type_vtable*)INSTANCE.TYPE->vtable)->metaclass != NULL ) \
            return ((CAST)objc_msgSend)(INSTANCE.TYPE, sel_getUid(SELECTOR_STRING));
    #endif
#else
    #define MK_OBJC_BRIDGED_INVOKE(INSTANCE, TYPE, CAST, SELECTOR_STRING)
#endif

//! Helper macro for invoking instance methods of an instance of a type.
#define MK_TYPE_INVOKE(INSTANCE, TYPE, METHOD) \
    struct _mk_ ## TYPE ## _vtable *vtable = (typeof(vtable))INSTANCE.TYPE->vtable; \
    while (vtable->METHOD == NULL) { \
        vtable = (typeof(vtable))((struct _mk_type_vtable *)vtable)->super;\
    } \
    return vtable->METHOD

//! Returns the context associated with the provided instance of any
//! polymorphic type.
_mk_internal_extern mk_context_t*
mk_type_get_context(mk_type_ref mk);


//----------------------------------------------------------------------------//
#pragma mark -  Includes
//----------------------------------------------------------------------------//

#include "logging_internal.h"
#include "data_model_internal.h"
#include "memory_map_internal.h"


//! @} CORE !//

#endif
#endif /* _core_private_h */
