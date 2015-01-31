//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       logging.h
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
//! @defgroup LOGGING Logging
//! @ingroup CORE
//!
//! Logging component of libMachO.  Supports compile-time and run-time
//! configurable log levels.
//----------------------------------------------------------------------------//

#ifndef _logging_h
#define _logging_h

//! @addtogroup LOGGING
//! @{
//!

//----------------------------------------------------------------------------//
#pragma mark -  Types
//! @name       Types
//----------------------------------------------------------------------------//

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
//! Log levels.
//
typedef enum {
    MK_LOGGING_LEVEL_OFF = 0,
    //! fine-grained debugging information
    MK_LOGGING_LEVEL_TRACE,
    //! coarse-grained debugging information
    MK_LOGGING_LEVEL_DEBUG,
    //! informational message
    MK_LOGGING_LEVEL_INFO,
    //! warning
    MK_LOGGING_LEVEL_WARNING,
    //! error situation
    MK_LOGGING_LEVEL_ERROR,
    //! critical situation
    MK_LOGGING_LEVEL_CRITICAL,
    //! critical situation
    MK_LOGGING_LEVEL_FATAL,
    
    _MK_LOGGING_LEVEL_COUNT,
    _MK_LOGGING_LEVEL_FIRST = 0,
    _MK_LOGGING_LEVEL_LAST  = _MK_LOGGING_LEVEL_COUNT-1
} mk_logging_level_t;

//! Prototype for a logger function definition.
typedef void (*mk_logger_c)(void* context, void* reserved, mk_logging_level_t level,
                            const char * file, int line, const char * function,
                            const char* msg, ...);


//----------------------------------------------------------------------------//
#pragma mark -  Functions
//! @name       Functions
//----------------------------------------------------------------------------//

//! Returns the name of the provided logging level.
_mk_export const char*
mk_string_for_logging_level(mk_logging_level_t level);


//----------------------------------------------------------------------------//
#pragma mark -  Switches
//! @name       Switches
//----------------------------------------------------------------------------//

//! The compile time configurable logging level.
//!
//! Configure this to be the lowest logging level you want to receive log
//! messages with.
#ifndef MK_LOGGING_LEVEL
#   define MK_LOGGING_LEVEL MK_LOGGING_LEVEL_TRACE
#endif

//! The runtime configurable logging level.
//!
//! Defaults to the value of \ref MK_LOGGING_LEVEL and cannot be raised
//! above the value of \ref MK_LOGGING_LEVEL.
extern mk_logging_level_t mk_logging_level;


//! @} LOGGING !//

#endif /* _logging_h */
