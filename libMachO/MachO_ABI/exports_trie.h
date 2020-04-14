//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       exports_trie.h
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

#ifndef _exports_trie_h
#define _exports_trie_h

//! @addtogroup MACH
//! @{
//!

//----------------------------------------------------------------------------//
#pragma mark -  Types
//! @name       Types
//----------------------------------------------------------------------------//

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
//! @internal
//
typedef struct mk_exports_trie_s {
    __MK_RUNTIME_BASE
    //! Link edit segment
    mk_segment_ref link_edit;
    //! The range of the exports trie in the target.
    mk_vm_range_t target_range;
} mk_exports_trie_t;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
//! The Exports Trie type.
//
typedef union {
    mk_type_ref type;
    struct mk_exports_trie_s *exports_trie;
} mk_exports_trie_ref _mk_transparent_union;

//! The identifier for the Exports Trie type.
_mk_export intptr_t mk_exports_trie_type;


//----------------------------------------------------------------------------//
#pragma mark -  Includes
//----------------------------------------------------------------------------//

#include "export.h"


//----------------------------------------------------------------------------//
#pragma mark -  Working With The Exports Trie
//! @name       Working With The Exports Trie
//----------------------------------------------------------------------------//

//! Initializes a Exports Trie object.
//!
//! @param  link_edit_segment
//!         The LINKEDIT segment.  Must remain valid for the lifetime of the
//!         exports trie object.
//! @param  load_command
//!         One of the LC_DYLD_EXPORTS_TRIE, LC_DYLD_INFO, or LC_DYLD_INFO_ONLY
//!         load commands that defines the exports trie.
//! @param  exports_trie
//!         A valid \ref mk_exports_trie_t structure.
_mk_export mk_error_t
mk_exports_trie_init(mk_segment_ref link_edit_segment, mk_load_command_ref load_command, mk_exports_trie_t *exports_trie);

//! Initializes a Exports Trie object with the specified Mach-O
//! LC_DYLD_EXPORTS_TRIE, LC_DYLD_INFO, or LC_DYLD_INFO_ONLY load command.
_mk_export mk_error_t
mk_exports_trie_init_with_mach_load_command(mk_segment_ref link_edit_segment, struct load_command *lc, mk_exports_trie_t *exports_trie);

//! Initializes a Exports Trie object.
_mk_export mk_error_t
mk_exports_trie_init_with_segment(mk_segment_ref link_edit_segment, mk_exports_trie_t *exports_trie);

//! Cleans up any resources held by \a exports_trie.  It is no longer safe to
//! use \a exports_trie after calling this function.
_mk_export void
mk_exports_trie_free(mk_exports_trie_ref exports_trie);

//! Returns the Mach-O image that the given exports trie resides within.
_mk_export mk_macho_ref
mk_exports_trie_get_macho(mk_exports_trie_ref exports_trie);

//! Returns the LINKEDIT segment that the given exports trie resides
//! within.
_mk_export mk_segment_ref
mk_exports_trie_get_segment(mk_exports_trie_ref exports_trie);

//! Returns range of memory (in the target address space) that the given
//! exports trie occupies.
_mk_export mk_vm_range_t
mk_exports_trie_get_target_range(mk_exports_trie_ref exports_trie);


//----------------------------------------------------------------------------//
#pragma mark -  Walking The Exports Trie
//! @name       Walking The Exports Trie
//----------------------------------------------------------------------------//

//! Retrieves the pointer to the terminal node for \a symbol. The resulting
//! pointer should only be considered valid for the lifetime of \a exports_trie.
//!
//! @return
//! Returns \c MK_ESUCCESS if a terminal node for \a symbol was found.
//! Returns \c MK_ENOT_FOUND if a terminal node for \a symbol was not found.
_mk_export mk_error_t
mk_exports_trie_get_terminal_node_for_symbol(mk_exports_trie_ref exports_trie, const char *symbol, mk_vm_address_t* target_address, mk_macho_export_node_ptr *result);


//! @} MACH !//

#endif /* _exports_trie_h */
