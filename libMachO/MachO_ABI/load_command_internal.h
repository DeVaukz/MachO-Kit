//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       load_command_internal.h
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

#ifndef _load_command_internal_h
#define _load_command_internal_h
#ifndef DOXYGEN

#include "load_command.h"
#include "_load_command_dylib.h"
#include "_load_command_dylinker.h"
#include "_load_command_linkedit.h"
#include "_load_command_dyld_info.h"

//! @addtogroup LOAD_COMMANDS
//! @{
//!

_mk_export const struct _mk_load_command_vtable* _mk_load_command_classes[];
_mk_export const uint32_t _mk_load_command_classes_count;

//----------------------------------------------------------------------------//
#pragma mark -  Useful Macros
//! @name       Useful Macros
//----------------------------------------------------------------------------//

//! Executes \a ACTION if \a LC is NULL.
#define _MK_LOAD_COMMAND_NOT_NULL(LC, ACTION) \
    if (LC.load_command == NULL) {ACTION;}

//! Executes \a ACTION if \a LC is not of the expected class.
#define _MK_LOAD_COMMAND_IS_A(LC, CLASS, ACTION) \
    if (LC.load_command->vtable != &CLASS) { \
        _mkl_debug(mk_type_get_context(LC.type), "mk_load_command_t %p is of type %s, expected %s", \
        LC.type, mk_type_name(load_command.type), CLASS.base.name); \
        ACTION; \
    }


//----------------------------------------------------------------------------//
#pragma mark -  Classes
//! @name       Classes
//----------------------------------------------------------------------------//

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
//! Member function table declaration for the \c load_command type.
//
struct _mk_load_command_vtable {
    __MK_RUNTIME_TYPE_BASE
    uint32_t command_id;
    size_t commnd_base_size;
};

//! The member function table for the \c load_command type.
_mk_internal_extern
const struct _mk_load_command_vtable _mk_load_command_class;


//! @} LOAD_COMMANDS !//

#endif
#endif /* _load_command_internal_h */
