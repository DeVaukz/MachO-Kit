//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       _mach_lcstr.h
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

#ifndef __mach_lcstr_h
#define __mach_lcstr_h

//! Copies the contents of the specified load command string from the specified
//! source load command into the specified destination load command, updating
//! specified load command string with the offset.
//!
//! @param  source_load_command
//!         The load command containing the \a source_str.  The full
//!         load command must be mapped into process accessible memory.
//! @param  src_lc_str
//!         The \c lc_str structure for the source string.  This must be
//!         within \a source_lc.
//! @param  dest_lc_str
//!         A load command structure containing \a dest_str.
//! @param  dest_str
//!         The \c lc_str structure for the destination string.  This must be
//!         within \a dest_lc.
//! @param  The size of the \a dest_lc structure.
//!
//! @return
//! The number of bytes copied, not counting the terminating null character.
_mk_internal_extern size_t
_mk_mach_lc_str_copy_native(mk_load_command_ref source_load_command, union lc_str *src_lc_str,
                            struct load_command *dest_lc, union lc_str *dest_lc_str, size_t dest_cmdsize);

//! Copies the contents of the specified load command string into the provided
//! \a output buffer.
//!
//! @param  load_command
//!         The load command containing the \a source_str.  The full
//!         load command must be mapped into process accessible memory.
//! @param  lc_str
//!         The \c lc_str structure for the source string.  This must be
//!         within \a source_lc.
//! @param  output
//!         A buffer to receive the contents of the string.  May be \c NULL.
//! @param  output_len
//!         The size of the \a output buffer.
//! @param  include_terminator
//!         Forces the string copied to \a output to be \c NULL terminated
//!         regardless of whether the source string is \c NULL terminated.
//! @return
//! The number of bytes copied, not counting the terminating null character.
//! If \a outout is \c NULL, returns the length of the load command string,
//! not counting the terminating null character.
_mk_internal_extern size_t
_mk_mach_lc_str_copy(mk_load_command_ref load_command, union lc_str *lc_str,
                     char *output, size_t output_len, bool include_terminator);

#endif /* __mach_lcstr_h */
