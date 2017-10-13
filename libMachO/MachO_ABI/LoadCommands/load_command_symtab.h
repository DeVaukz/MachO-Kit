//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       load_command_symtab.h
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

#ifndef _load_command_symtab_h
#define _load_command_symtab_h

//! @addtogroup LOAD_COMMANDS
//! @{
//!

//----------------------------------------------------------------------------//
#pragma mark -  Symtab
//! @name       Symtab
//----------------------------------------------------------------------------//

_mk_export uint32_t
mk_load_command_symtab_id(void);

_mk_export mk_error_t
mk_load_command_symtab_copy_native(mk_load_command_ref load_command, struct symtab_command *result);

_mk_export uint32_t
mk_load_command_symtab_get_symoff(mk_load_command_ref load_command);
_mk_export uint32_t
mk_load_command_symtab_get_nsyms(mk_load_command_ref load_command);

_mk_export uint32_t
mk_load_command_symtab_get_stroff(mk_load_command_ref load_command);
_mk_export uint32_t
mk_load_command_symtab_get_strsize(mk_load_command_ref load_command);


//! @} LOAD_COMMANDS !//

#endif /* _load_command_symtab_h */
