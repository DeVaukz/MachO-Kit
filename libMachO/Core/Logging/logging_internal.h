//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       logging_internal.h
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

#ifndef _logging_internal_h
#define _logging_internal_h
#ifndef DOXYGEN

#include "logging.h"

//! @addtogroup LOGGING
//! @{
//!

//----------------------------------------------------------------------------//
#pragma mark -  Logging Macros
//! @name       Logging Macros
//----------------------------------------------------------------------------//

//! @internal
//! Logs a message if the specified log level is active.
//!
//! @param  CONTEXT
//!         The \ref mk_context_s for the current file.
//! @param  LEVEL
//!         A log level without the DK_LOGGING_LEVEL_ prefix.
//! @param  FORMAT
//!         A format string of type NSString (may include %@).
//! @param  ...
//!         An optional arguments required by the format string
#define _mk_log(CONTEXT, LEVEL, FORMAT, ...)                                \
    do {                                                                    \
        if (MK_LOGGING_LEVEL > 0 && mk_logging_level > 0 &&                 \
            LEVEL >= MK_LOGGING_LEVEL && LEVEL >= mk_logging_level)         \
        {                                                                   \
            if (CONTEXT)                                                    \
                ((mk_context_t*)CONTEXT)->logger(                           \
                    CONTEXT, NULL, LEVEL,                                   \
                    __FILE__, __LINE__, __PRETTY_FUNCTION__,                \
                    FORMAT, ##__VA_ARGS__);                                 \
            else {                                                          \
                fprintf(stderr, "[Mach-O Kit - %s] %s:%i ",                 \
                  mk_string_for_logging_level(LEVEL), __FILE__, __LINE__);  \
                fprintf(stderr, FORMAT, ##__VA_ARGS__);                     \
                fprintf(stderr, "\n");                                      \
            }                                                               \
        }                                                                   \
} while (0)

//! Shortcut for calling \ref _mk_log with \ref MK_LOGGING_LEVEL_TRACE.
#define _mkl_trace(CONTEXT, FORMAT, ...)                                    \
    _mk_log(CONTEXT, MK_LOGGING_LEVEL_TRACE, FORMAT, ##__VA_ARGS__)

//! Shortcut for calling \ref _mk_log with \ref MK_LOGGING_LEVEL_DEBUG.
#define _mkl_debug(CONTEXT, FORMAT, ...)                                    \
    _mk_log(CONTEXT, MK_LOGGING_LEVEL_DEBUG, FORMAT, ##__VA_ARGS__)

//! Shortcut for calling \ref _mk_log with \ref MK_LOGGING_LEVEL_INFO.
#define _mkl_inform(CONTEXT, FORMAT, ...)                                   \
    _mk_log(CONTEXT, MK_LOGGING_LEVEL_INFO, FORMAT, ##__VA_ARGS__)

//! Shortcut for calling \ref _mk_log with \ref MK_LOGGING_LEVEL_ERROR.
#define _mkl_error(CONTEXT, FORMAT, ...)                                    \
    _mk_log(CONTEXT, MK_LOGGING_LEVEL_ERROR, FORMAT, ##__VA_ARGS__)

//! Shortcut for calling \ref _mk_log with \ref MK_LOGGING_LEVEL_FATAL.
#define _mkl_fatal(CONTEXT, FORMAT, ...)                                    \
    _mk_log(CONTEXT, MK_LOGGING_LEVEL_FATAL, FORMAT, ##__VA_ARGS__)


//----------------------------------------------------------------------------//
#pragma mark -  Assertions
//! @name       Assertions
//----------------------------------------------------------------------------//

//! Terminates the program if the provided condition is \c false.
#define _mk_assert(ASSERTION, CONTEXT, MESSAGE, ...) do { \
    if (__builtin_expect(!(ASSERTION), 0)) { \
        _mkl_fatal(CONTEXT, MESSAGE, ##__VA_ARGS__); \
        fprintf(stderr, "[Mach-O Kit] %s:%i Assertion '%s' failed!\n", __FILE__, __LINE__, #ASSERTION); \
        __builtin_trap(); \
    } \
} while (0)


//! @} LOGGING !//

#endif
#endif /* _logging_internal_h */
