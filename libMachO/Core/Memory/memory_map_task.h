//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       memory_map_task.h
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
//! @defgroup MEMORY_MAP_TASK Task Memory Map
//! @ingroup MEMORY_MAP
//!
//! A task memory map mediates access to the VM of a mach task.
//----------------------------------------------------------------------------//

#ifndef _memory_map_task_h
#define _memory_map_task_h
#if TARGET_OS_MAC && !TARGET_OS_IPHONE

//! @addtogroup MEMORY_MAP_TASK
//! @{
//!

//----------------------------------------------------------------------------//
#pragma mark -  Types
//! @name       Types
//----------------------------------------------------------------------------//

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
//! @internal
//
typedef struct mk_memory_map_task_s {
    struct mk_memory_map_s base;
    //! The target task for this memory map.
    mach_port_t task;
} mk_memory_map_task_t;

//! The identifier for the Memory Map Task type.
_mk_export intptr_t mk_memory_map_task_type;


//----------------------------------------------------------------------------//
#pragma mark -  Creating A Task Memory Map
//! @name       Creating A Task Memory Map
//----------------------------------------------------------------------------//

_mk_export mk_error_t
mk_memory_map_task_init(mach_port_t task, mk_context_t *ctx, mk_memory_map_task_t *task_map);

_mk_export mk_error_t
mk_memory_map_task_free(mk_memory_map_task_t *task_map);


//! @} MEMORY_MAP_TASK !//

#endif
#endif /* _memory_map_task_h */
