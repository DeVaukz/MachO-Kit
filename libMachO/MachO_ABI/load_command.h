//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       load_command.h
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
//! @defgroup LOAD_COMMANDS Load Commands
//! @ingroup MACH
//!
//! Parsers for Mach-O load commands.
//----------------------------------------------------------------------------//

#ifndef _load_command_h
#define _load_command_h

//! @addtogroup LOAD_COMMANDS
//! @{
//!

//----------------------------------------------------------------------------//
#pragma mark -  Types
//! @name       Types
//----------------------------------------------------------------------------//

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
//! @internal
//
typedef struct mk_load_command_s {
    __MK_RUNTIME_BASE
    // The Mach-O image that the load command resides within.
    mk_macho_ref image;
    // Pointer to the Mach-O load command structure.
    struct load_command *mach_load_command;
} mk_load_command_t;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
//! The Load Command polymorphic type.
//
typedef union {
    mk_type_ref type;
    struct mk_load_command_s *load_command;
} mk_load_command_ref _mk_transparent_union;

//! The identifier for the Load Command type.
_mk_export intptr_t mk_load_command_type;


//----------------------------------------------------------------------------//
#pragma mark -  Includes
//----------------------------------------------------------------------------//

#include "load_command_segment.h"
#include "load_command_symtab.h"
#include "load_command_dsymtab.h"
#include "load_command_load_dylib.h"
#include "load_command_id_dylib.h"
#include "load_command_load_dylinker.h"
#include "load_command_id_dylinker.h"
#include "load_command_routines.h"
#include "load_command_sub_framework.h"
#include "load_command_sub_client.h"
#include "load_command_sub_library.h"
#include "load_command_twolevel_hints.h"
#include "load_command_prebind_cksum.h"
#include "load_command_load_weak_dylib.h"
#include "load_command_segment_64.h"
#include "load_command_routines_64.h"
#include "load_command_uuid.h"
#include "load_command_rpath.h"
#include "load_command_code_signature.h"
#include "load_command_segment_split_info.h"
#include "load_command_reexport_dylib.h"
#include "load_command_lazy_load_dylib.h"
#include "load_command_encryption_info.h"
#include "load_command_dyld_info.h"
#include "load_command_dyld_info_only.h"
#include "load_command_load_upward_dylib.h"
#include "load_command_version_min_macosx.h"
#include "load_command_version_min_iphoneos.h"
#include "load_command_function_starts.h"
#include "load_command_dyld_environment.h"
#include "load_command_main.h"
#include "load_command_data_in_code.h"
#include "load_command_source_version.h"
#include "load_command_dylib_code_sign_drs.h"
#include "load_command_encryption_info_64.h"
#include "load_command_version_min_tvos.h"
#include "load_command_version_min_watchos.h"
#include "load_command_note.h"
#include "load_command_build_version.h"


//----------------------------------------------------------------------------//
#pragma mark -  Static Methods
//! @name       Static Methods
//----------------------------------------------------------------------------//

//! Returns the id of the specified Mach-O load command, or 0 if there was an
//! error.
_mk_export uint32_t
mk_mach_load_command_id(mk_macho_ref image, struct load_command* lc);


//----------------------------------------------------------------------------//
#pragma mark -  Working With Load Commands
//! @name       Working With Load Commands
//----------------------------------------------------------------------------//

//! Initializes a load command object.
_mk_export mk_error_t
mk_load_command_init(mk_macho_ref image, struct load_command* lc, mk_load_command_t* load_command);

//! Initializes \a copy with the contents of the specified load command.
_mk_export mk_error_t
mk_load_command_copy(mk_load_command_ref load_command, mk_load_command_t* copy);

//! Returns the Mach-O image that the specified load command resides within.
_mk_export mk_macho_ref
mk_load_command_get_macho(mk_load_command_ref load_command);

//! Returns range of memory (in the target address space) that the specified
//! load command occupies.
_mk_export mk_vm_range_t
mk_load_command_get_target_range(mk_load_command_ref load_command);

//! Returns the address (in the target address space) of the specified load
//! command.
_mk_export mk_vm_address_t
mk_load_command_get_target_address(mk_load_command_ref load_command);


//----------------------------------------------------------------------------//
#pragma mark -  Load Command Values
//! @name       Load Command Values
//----------------------------------------------------------------------------//

//! Returns the id of the specified load command.  This will match the value
//! defined in \c <mach-o/loader.h> for the load command type.
_mk_export uint32_t
mk_load_command_id(mk_load_command_ref load_command);

//! Returns the size of the specified load command.
_mk_export uint32_t
mk_load_command_size(mk_load_command_ref load_command);

//! Returns the base size of the Mach-O load command structure for the
//! specified load command.
_mk_export size_t
mk_load_command_base_size(mk_load_command_ref load_command);


//! @} LOAD_COMMANDS !//

#endif /* _load_command_h */
