//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             load_command.c
//|
//|             D.V.
//|             Copyright (c) 2014-2015 D.V. All rights reserved.
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

#include "macho_abi_internal.h"

extern const struct _mk_load_command_vtable _mk_load_command_segment_class;
extern const struct _mk_load_command_vtable _mk_load_command_symtab_class;
// LC_SYMSEG - Not implemented
// LC_THREAD - Not implemented
// LC_UNIXTHREAD - Not implemented
// LC_LOADFVMLIB - Not implemented
// LC_IDFVMLIB - Not implemented
// LC_IDENT - Not implemented
// LC_FVMFILE - Not implemented
// LC_PREPAGE - Not implemented
extern const struct _mk_load_command_vtable _mk_load_command_dysymtab_class;
extern const struct _mk_load_command_vtable _mk_load_command_load_dylib_class;
extern const struct _mk_load_command_vtable _mk_load_command_id_dylib_class;
extern const struct _mk_load_command_vtable _mk_load_command_load_dylinker_class;
extern const struct _mk_load_command_vtable _mk_load_command_id_dylinker_class;
// LC_PREBOUND_DYLIB - Not implemented
extern const struct _mk_load_command_vtable _mk_load_command_routines_class;
extern const struct _mk_load_command_vtable _mk_load_command_sub_framework_class;
// LC_SUB_UMBRELLA - Not implemented
extern const struct _mk_load_command_vtable _mk_load_command_sub_client_class;
extern const struct _mk_load_command_vtable _mk_load_command_sub_library_class;
extern const struct _mk_load_command_vtable _mk_load_command_twolevel_hints_class;
extern const struct _mk_load_command_vtable _mk_load_command_prebind_cksum_class;
extern const struct _mk_load_command_vtable _mk_load_command_load_weak_dylib_class;
extern const struct _mk_load_command_vtable _mk_load_command_segment_64_class;
extern const struct _mk_load_command_vtable _mk_load_command_routines_64_class;
extern const struct _mk_load_command_vtable _mk_load_command_uuid_class;
extern const struct _mk_load_command_vtable _mk_load_command_rpath_class;
extern const struct _mk_load_command_vtable _mk_load_command_code_signature_class;
extern const struct _mk_load_command_vtable _mk_load_command_segment_split_info_class;
extern const struct _mk_load_command_vtable _mk_load_command_reexport_dylib_class;
// LC_LAZY_LOAD_DYLIB - Not implemented
extern const struct _mk_load_command_vtable _mk_load_command_encryption_info_class;
extern const struct _mk_load_command_vtable _mk_load_command_dyld_info_class;
extern const struct _mk_load_command_vtable _mk_load_command_dyld_info_only_class;
extern const struct _mk_load_command_vtable _mk_load_command_load_upward_dylib_class;
extern const struct _mk_load_command_vtable _mk_load_command_version_min_macosx_class;
extern const struct _mk_load_command_vtable _mk_load_command_version_min_iphoneos_class;
extern const struct _mk_load_command_vtable _mk_load_command_function_starts_class;
extern const struct _mk_load_command_vtable _mk_load_command_dyld_environment_class;
extern const struct _mk_load_command_vtable _mk_load_command_main_class;
extern const struct _mk_load_command_vtable _mk_load_command_data_in_code_class;
extern const struct _mk_load_command_vtable _mk_load_command_source_version_class;
extern const struct _mk_load_command_vtable _mk_load_command_code_sign_drs_class;
extern const struct _mk_load_command_vtable _mk_load_command_encryption_info_64_class;
// LC_LINKER_OPTION - Not Implemented
// LC_LINKER_OPTIMIZATION_HINT - Not Implemented

const struct _mk_load_command_vtable* _mk_load_command_classes[] = {
    &_mk_load_command_segment_class,
    &_mk_load_command_symtab_class,
    // LC_SYMSEG - Not implemented
    // LC_THREAD - Not implemented
    // LC_UNIXTHREAD - Not implemented
    // LC_LOADFVMLIB - Not implemented
    // LC_IDFVMLIB - Not implemented
    // LC_IDENT - Not implemented
    // LC_FVMFILE - Not implemented
    // LC_PREPAGE - Not implemented
    &_mk_load_command_dysymtab_class,
    &_mk_load_command_load_dylib_class,
    &_mk_load_command_id_dylib_class,
    &_mk_load_command_load_dylinker_class,
    &_mk_load_command_id_dylinker_class,
    // LC_PREBOUND_DYLIB - Not implemented
    &_mk_load_command_routines_class,
    &_mk_load_command_sub_framework_class,
    // LC_SUB_UMBRELLA - Not implemented
    &_mk_load_command_sub_client_class,
    &_mk_load_command_sub_library_class,
    &_mk_load_command_twolevel_hints_class,
    &_mk_load_command_prebind_cksum_class,
    &_mk_load_command_load_weak_dylib_class,
    &_mk_load_command_segment_64_class,
    &_mk_load_command_routines_64_class,
    &_mk_load_command_uuid_class,
    &_mk_load_command_rpath_class,
    &_mk_load_command_code_signature_class,
    &_mk_load_command_segment_split_info_class,
    &_mk_load_command_reexport_dylib_class,
    // LC_LAZY_LOAD_DYLIB - Not implemented
    &_mk_load_command_encryption_info_class,
    &_mk_load_command_dyld_info_class,
    &_mk_load_command_dyld_info_only_class,
    &_mk_load_command_load_upward_dylib_class,
    &_mk_load_command_version_min_macosx_class,
    &_mk_load_command_version_min_iphoneos_class,
    &_mk_load_command_function_starts_class,
    &_mk_load_command_dyld_environment_class,
    &_mk_load_command_main_class,
    &_mk_load_command_data_in_code_class,
    &_mk_load_command_source_version_class,
    &_mk_load_command_code_sign_drs_class,
    &_mk_load_command_encryption_info_64_class
};
const uint32_t _mk_load_command_classes_count = sizeof(_mk_load_command_classes)/sizeof(struct _mk_load_command_vtable*);

//----------------------------------------------------------------------------//
#pragma mark -  Classes
//----------------------------------------------------------------------------//

//|++++++++++++++++++++++++++++++++++++|//
static mk_context_t*
__mk_load_command_get_context(mk_type_ref self)
{ return mk_type_get_context( ((mk_load_command_t*)self)->image.type ); }

//|++++++++++++++++++++++++++++++++++++|//
static bool
__mk_load_command_equal(mk_type_ref self, mk_type_ref other)
{
    mk_load_command_t *load_command = (mk_load_command_t*)self;
    mk_load_command_t *other_command = (mk_load_command_t*)other;
    
    if (load_command->vtable != other_command->vtable) return false;
    if (!mk_type_equal(load_command->image.type, other_command->image.type)) return false;
    if (load_command->mach_load_command->cmdsize != other_command->mach_load_command->cmdsize) return false;
    
    return (memcmp(load_command->mach_load_command, other_command->mach_load_command, load_command->mach_load_command->cmdsize) == 0);
}

//|++++++++++++++++++++++++++++++++++++|//
static size_t
__mk_load_command_copy_description(mk_type_ref self, char *output, size_t output_len)
{
    return snprintf(output, output_len, "<%s %p; size = %llu>", mk_type_name(self),
                    self, mk_load_command_size((mk_load_command_t*)self));
}

const struct _mk_load_command_vtable _mk_load_command_class = {
    .base.super                 = &_mk_type_class,
    .base.name                  = "load_command",
    .base.get_context           = &__mk_load_command_get_context,
    .base.equal                 = &__mk_load_command_equal,
    .base.copy_description      = &__mk_load_command_copy_description,
    .command_id                 = 0,
    .commnd_base_size           = 0
};

//----------------------------------------------------------------------------//
#pragma mark -  Working With Mach-O Load Commands
//----------------------------------------------------------------------------//

//|++++++++++++++++++++++++++++++++++++|//
mk_error_t mk_load_command_init(const mk_macho_ref image, struct load_command* lc, mk_load_command_t* load_command)
{
    if (!image.macho) return MK_EINVAL;
    if (!lc) return MK_EINVAL;
    if (!load_command) return MK_EINVAL;
    
    // Need to first verify it is safe to dereference lc.
    if (!mk_memory_object_verify_local_pointer(&image.macho->header_mapping, 0, (vm_address_t)lc, sizeof(*lc), NULL)) {
        _mkl_error(mk_type_get_context(image.type), "Header mapping does not entirely contain load command %d in image %s", lc->cmd, image.macho->name);
        return MK_EINVALID_DATA;
    }
    if (!mk_memory_object_verify_local_pointer(&image.macho->header_mapping, 0, (vm_address_t)lc, lc->cmdsize, NULL)) {
        _mkl_error(mk_type_get_context(image.type), "Header mapping does not entirely contain load command %d in image %s", lc->cmd, image.macho->name);
        return MK_EINVALID_DATA;
    }
    
    load_command->image = image;
    load_command->mach_load_command = lc;
    
    switch (lc->cmd) {
        case LC_SEGMENT:
            load_command->vtable = &_mk_load_command_segment_class;
            break;
        case LC_SYMTAB:
            load_command->vtable = &_mk_load_command_symtab_class;
            break;
        //case LC_SYMSEG: - Not implemented
        //  load_command->vtable =
        //  break;
        //case LC_THREAD: - Not implemented
        //  load_command->vtable =
        //  break;
        //case LC_UNIXTHREAD: - Not implemented
        //  load_command->vtable =
        //  break;
        //case LC_LOADFVMLIB: - Not implemented
        //  load_command->vtable =
        //  break;
        //case LC_IDFVMLIB: - Not implemented
        //  load_command->vtable =
        //  break;
        //case LC_IDENT: - Not implemented
        //  load_command->vtable =
        //  break;
        //case LC_FVMFILE: - Not implemented
        //  load_command->vtable =
        //  break;
        //case LC_PREPAGE: - Not implemented
        //  load_command->vtable =
        //  break;
        case LC_DYSYMTAB:
            load_command->vtable = &_mk_load_command_dysymtab_class;
            break;
        case LC_LOAD_DYLIB:
            load_command->vtable = &_mk_load_command_load_dylib_class;
            break;
        case LC_ID_DYLIB:
            load_command->vtable = &_mk_load_command_id_dylib_class;
            break;
        case LC_LOAD_DYLINKER:
            load_command->vtable = &_mk_load_command_load_dylinker_class;
            break;
        case LC_ID_DYLINKER:
            load_command->vtable = &_mk_load_command_id_dylinker_class;
            break;
        //case LC_PREBOUND_DYLIB: - Not implemented
        //  load_command->vtable =
        //  break;
        case LC_ROUTINES:
            load_command->vtable = &_mk_load_command_routines_class;
            break;
        case LC_SUB_FRAMEWORK:
            load_command->vtable = &_mk_load_command_sub_framework_class;
            break;
        case LC_SUB_LIBRARY:
            load_command->vtable = &_mk_load_command_sub_framework_class;
            break;
        case LC_SUB_CLIENT:
            load_command->vtable = &_mk_load_command_sub_client_class;
            break;
        case LC_TWOLEVEL_HINTS:
            load_command->vtable = &_mk_load_command_sub_library_class;
            break;
        case LC_PREBIND_CKSUM:
            load_command->vtable = &_mk_load_command_prebind_cksum_class;
            break;
        case LC_LOAD_WEAK_DYLIB:
            load_command->vtable = &_mk_load_command_load_weak_dylib_class;
            break;
        case LC_SEGMENT_64:
            load_command->vtable = &_mk_load_command_segment_64_class;
            break;
        case LC_ROUTINES_64:
            load_command->vtable = &_mk_load_command_routines_64_class;
            break;
        case LC_UUID:
            load_command->vtable = &_mk_load_command_uuid_class;
            break;
        case LC_RPATH:
            load_command->vtable = &_mk_load_command_rpath_class;
            break;
        case LC_CODE_SIGNATURE:
            load_command->vtable = &_mk_load_command_code_signature_class;
            break;
        case LC_SEGMENT_SPLIT_INFO:
            load_command->vtable = &_mk_load_command_segment_split_info_class;
            break;
        case LC_REEXPORT_DYLIB:
            load_command->vtable = &_mk_load_command_reexport_dylib_class;
            break;
        //case LC_LAZY_LOAD_DYLIB: - Not implemented
        //  load_command->vtable =
        //  break;
        case LC_ENCRYPTION_INFO:
            load_command->vtable = &_mk_load_command_encryption_info_class;
            break;
        case LC_DYLD_INFO:
            load_command->vtable = &_mk_load_command_dyld_info_class;
            break;
        case LC_DYLD_INFO_ONLY:
            load_command->vtable = &_mk_load_command_dyld_info_only_class;
            break;
        case LC_LOAD_UPWARD_DYLIB:
            load_command->vtable = &_mk_load_command_load_upward_dylib_class;
          break;
        case LC_VERSION_MIN_MACOSX:
            load_command->vtable = &_mk_load_command_version_min_macosx_class;
            break;
        case LC_VERSION_MIN_IPHONEOS:
            load_command->vtable = &_mk_load_command_version_min_iphoneos_class;
            break;
        case LC_FUNCTION_STARTS:
            load_command->vtable = &_mk_load_command_function_starts_class;
            break;
        case LC_DYLD_ENVIRONMENT:
            load_command->vtable = &_mk_load_command_dyld_environment_class;
            break;
        case LC_MAIN:
            load_command->vtable = &_mk_load_command_main_class;
            break;
        case LC_DATA_IN_CODE:
            load_command->vtable = &_mk_load_command_data_in_code_class;
            break;
        case LC_SOURCE_VERSION:
            load_command->vtable = &_mk_load_command_source_version_class;
            break;
        case LC_DYLIB_CODE_SIGN_DRS:
            load_command->vtable = &_mk_load_command_code_sign_drs_class;
            break;
        case LC_ENCRYPTION_INFO_64:
            load_command->vtable = &_mk_load_command_encryption_info_64_class;
            break;
        //case LC_LINKER_OPTION: - Not implemented
        //  load_command->vtable =
        //  break;
        default:
            _mkl_error(mk_type_get_context(image.type), "Unknown load command %d in image %s", lc->cmd, image.macho->name);
            return MK_ENOT_FOUND;
    }
    
    return MK_ESUCCESS;
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
mk_load_command_id(mk_load_command_ref load_command)
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return 0);
    
    struct _mk_load_command_vtable *vtable = (struct _mk_load_command_vtable*)load_command.load_command->vtable;
    if (vtable->command_id)
        return vtable->command_id;
    
    fprintf(stderr, "%s must specify a valid load command id.", mk_type_name(load_command.type));
    __builtin_trap();
}

//|++++++++++++++++++++++++++++++++++++|//
mk_vm_size_t
mk_load_command_size(mk_load_command_ref load_command)
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return 0);
    return (mk_vm_size_t)(load_command.load_command)->mach_load_command->cmdsize;
}

//|++++++++++++++++++++++++++++++++++++|//
size_t
mk_load_command_base_size(const mk_load_command_ref load_command)
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return 0);
    
    struct _mk_load_command_vtable *vtable = (struct _mk_load_command_vtable*)load_command.load_command->vtable;
    if (vtable->commnd_base_size)
        return vtable->commnd_base_size;
    
    fprintf(stderr, "%s must specify a base command size.", mk_type_name(load_command.type));
    __builtin_trap();
}
