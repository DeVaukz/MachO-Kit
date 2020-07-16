//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       export.h
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
//! @defgroup EXPORTS Exports
//! @ingroup MACH
//!
//! Parsers for Exports.
//----------------------------------------------------------------------------//

#ifndef _export_h
#define _export_h

//! @addtogroup EXPORTS
//! @{
//!

//----------------------------------------------------------------------------//
#pragma mark -  Types
//! @name       Types
//----------------------------------------------------------------------------//

//! A pointer (in the address space of the current process) to a node in the
//! export trie.
typedef const uint8_t* mk_macho_export_node_ptr;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
//! @internal
//
typedef struct mk_export_s {
    __MK_RUNTIME_BASE
    mk_exports_trie_ref exports_trie;
    // NOTE: This points to the first byte *after* the terminal size ULEB
    const uint8_t* terminal_data;
    mk_vm_size_t terminal_data_size;
} mk_export_t;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
//! The Export polymorphic type.
//
typedef union {
    mk_type_ref type;
    struct mk_export_s *export;
} mk_export_ref _mk_transparent_union;

//! The identifier for the Export type.
_mk_export intptr_t mk_export_type;

//----------------------------------------------------------------------------//
#pragma mark -  Working With Exports
//! @name       Working With Exports
//----------------------------------------------------------------------------//

//! Initializes the provided export with the provided terminal node in
//! \a exports_trie.
_mk_export mk_error_t
mk_export_init(mk_exports_trie_ref exports_trie, mk_macho_export_node_ptr node, mk_export_t* export);

//! Returns the Mach-O image that the specified export resides within.
_mk_export mk_macho_ref
mk_export_get_macho(mk_export_ref export);

//! Returns the exports trie that the specified export resides within.
_mk_export mk_exports_trie_ref
mk_export_get_exports_trie(mk_export_ref export);

//----------------------------------------------------------------------------//
#pragma mark -  Export Values
//! @name       Export Values
//----------------------------------------------------------------------------//

_mk_export mk_error_t
mk_export_get_info(mk_export_ref export, uint64_t* flags,
                   uint64_t* offset, /* Regular */
                   uint64_t* ordinal, const char** imported_name, /* Re-export */
                   uint64_t* resolver_offset /* Stub & Resolver */);


//! @} EXPORTS !//

#endif /* _export_h */
