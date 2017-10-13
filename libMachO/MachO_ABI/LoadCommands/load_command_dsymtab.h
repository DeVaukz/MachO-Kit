//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       load_command_dsymtab.h
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

#ifndef _load_command_dsymtab_h
#define _load_command_dsymtab_h

//! @addtogroup LOAD_COMMANDS
//! @{
//!

//----------------------------------------------------------------------------//
#pragma mark -  Dsymtab
//! @name       Dsymtab
//----------------------------------------------------------------------------//

_mk_export uint32_t
mk_load_command_dysymtab_id(void);

_mk_export mk_error_t
mk_load_command_dysymtab_copy_native(mk_load_command_ref load_command, struct dysymtab_command *result);

_mk_export uint32_t
mk_load_command_dysymtab_get_ilocalsym(mk_load_command_ref load_command);
_mk_export uint32_t
mk_load_command_dysymtab_get_nlocalsym(mk_load_command_ref load_command);

_mk_export uint32_t
mk_load_command_dysymtab_get_iextdefsym(mk_load_command_ref load_command);
_mk_export uint32_t
mk_load_command_dysymtab_get_nextdefsym(mk_load_command_ref load_command);

_mk_export uint32_t
mk_load_command_dysymtab_get_iundefsym(mk_load_command_ref load_command);
_mk_export uint32_t
mk_load_command_dysymtab_get_nundefsym(mk_load_command_ref load_command);

_mk_export uint32_t
mk_load_command_dysymtab_get_tocoff(mk_load_command_ref load_command);
_mk_export uint32_t
mk_load_command_dysymtab_get_ntoc(mk_load_command_ref load_command);

_mk_export uint32_t
mk_load_command_dysymtab_get_modtaboff(mk_load_command_ref load_command);
_mk_export uint32_t
mk_load_command_dysymtab_get_nmodtab(mk_load_command_ref load_command);

_mk_export uint32_t
mk_load_command_dysymtab_get_extrefsymoff(mk_load_command_ref load_command);
_mk_export uint32_t
mk_load_command_dysymtab_get_nextrefsyms(mk_load_command_ref load_command);

_mk_export uint32_t
mk_load_command_dysymtab_get_indirectsymoff(mk_load_command_ref load_command);
_mk_export uint32_t
mk_load_command_dysymtab_get_nindirectsyms(mk_load_command_ref load_command);

_mk_export uint32_t
mk_load_command_dysymtab_get_extreloff(mk_load_command_ref load_command);
_mk_export uint32_t
mk_load_command_dysymtab_get_nextrel(mk_load_command_ref load_command);

_mk_export uint32_t
mk_load_command_dysymtab_get_locreloff(mk_load_command_ref load_command);
_mk_export uint32_t
mk_load_command_dysymtab_get_nlocrel(mk_load_command_ref load_command);


//! @} LOAD_COMMANDS !//

#endif /* _load_command_dsymtab_h */
