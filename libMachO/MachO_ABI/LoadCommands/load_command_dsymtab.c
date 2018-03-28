//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             load_command_dsymtab.c
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

//|++++++++++++++++++++++++++++++++++++|//
static size_t
_mk_load_command_dsymtab_copy_description(mk_load_command_ref load_command, char *output, size_t output_len)
{
    return (size_t)snprintf(output, output_len, "<%s %p> {\n\
\tlocalsym = %" PRIu32 "\n\
\tnlocalsym = %" PRIu32 "\n\
\textdefsym = %" PRIu32 "\n\
\tnextdefsym = %" PRIu32 "\n\
\tiundefsym = %" PRIu32 "\n\
\tnundefsym = %" PRIu32 "\n\
\ttocoff = 0x%" PRIx32 "\n\
\tntoc = %" PRIu32 "\n\
\tmodtaboff = 0x%" PRIx32 "\n\
\tnmodtab = %" PRIu32 "\n\
\textrefsymoff = 0x%" PRIx32 "\n\
\tnextrefsyms = %" PRIu32 "\n\
\tindirectsymoff = 0x%" PRIx32 "\n\
\tnindirectsyms = %" PRIu32 "\n\
\textreloff = 0x%" PRIx32 "\n\
\tnextrel = %" PRIu32 "\n\
\tlocreloff = 0x%" PRIx32 "\n\
\tnlocrel = %" PRIu32 "\n\
}",
                            mk_type_name(load_command.type), load_command.type,
                            mk_load_command_dysymtab_get_ilocalsym(load_command),
                            mk_load_command_dysymtab_get_nlocalsym(load_command),
                            mk_load_command_dysymtab_get_iextdefsym(load_command),
                            mk_load_command_dysymtab_get_nextdefsym(load_command),
                            mk_load_command_dysymtab_get_iundefsym(load_command),
                            mk_load_command_dysymtab_get_nundefsym(load_command),
                            mk_load_command_dysymtab_get_tocoff(load_command),
                            mk_load_command_dysymtab_get_ntoc(load_command),
                            mk_load_command_dysymtab_get_modtaboff(load_command),
                            mk_load_command_dysymtab_get_nmodtab(load_command),
                            mk_load_command_dysymtab_get_extrefsymoff(load_command),
                            mk_load_command_dysymtab_get_nextrefsyms(load_command),
                            mk_load_command_dysymtab_get_indirectsymoff(load_command),
                            mk_load_command_dysymtab_get_nindirectsyms(load_command),
                            mk_load_command_dysymtab_get_extreloff(load_command),
                            mk_load_command_dysymtab_get_nextrel(load_command),
                            mk_load_command_dysymtab_get_locreloff(load_command),
                            mk_load_command_dysymtab_get_nlocrel(load_command)
                            );
}

const struct _mk_load_command_vtable _mk_load_command_dysymtab_class = {
    .base.super                 = &_mk_load_command_class,
    .base.name                  = "LC_DYSYMTAB",
    .base.copy_description      = &_mk_load_command_dsymtab_copy_description,
    .command_id                 = LC_DYSYMTAB,
    .command_base_size          = sizeof(struct dysymtab_command)
};

//|++++++++++++++++++++++++++++++++++++|//
uint32_t mk_load_command_dysymtab_id()
{ return LC_DYSYMTAB; }

//|++++++++++++++++++++++++++++++++++++|//
mk_error_t
mk_load_command_dysymtab_copy_native(mk_load_command_ref load_command, struct dysymtab_command *result)
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return MK_EINVAL);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_dysymtab_class, return MK_EINVAL);
    if (result == NULL) return MK_EINVAL;
    
    const mk_byteorder_t * const byte_order = mk_macho_get_byte_order(load_command.load_command->image);
    struct dysymtab_command *mach_dsymtab_command = (struct dysymtab_command*)load_command.load_command->mach_load_command;
    
    result->cmd = byte_order->swap32( mach_dsymtab_command->cmd );
    result->cmdsize = byte_order->swap32( mach_dsymtab_command->cmdsize );
    result->ilocalsym = byte_order->swap32( mach_dsymtab_command->ilocalsym );
    result->nlocalsym = byte_order->swap32( mach_dsymtab_command->nlocalsym );
    result->iextdefsym = byte_order->swap32( mach_dsymtab_command->iextdefsym );
    result->nextdefsym = byte_order->swap32( mach_dsymtab_command->nextdefsym );
    result->iundefsym = byte_order->swap32( mach_dsymtab_command->iundefsym );
    result->nundefsym = byte_order->swap32( mach_dsymtab_command->nundefsym );
    result->tocoff = byte_order->swap32( mach_dsymtab_command->tocoff );
    result->ntoc = byte_order->swap32( mach_dsymtab_command->ntoc );
    result->modtaboff = byte_order->swap32( mach_dsymtab_command->modtaboff );
    result->nmodtab = byte_order->swap32( mach_dsymtab_command->nmodtab );
    result->extrefsymoff = byte_order->swap32( mach_dsymtab_command->extrefsymoff );
    result->nextrefsyms = byte_order->swap32( mach_dsymtab_command->nextrefsyms );
    result->indirectsymoff = byte_order->swap32( mach_dsymtab_command->indirectsymoff );
    result->nindirectsyms = byte_order->swap32( mach_dsymtab_command->nindirectsyms );
    result->extreloff = byte_order->swap32( mach_dsymtab_command->extreloff );
    result->nextrel = byte_order->swap32( mach_dsymtab_command->nextrel );
    result->locreloff = byte_order->swap32( mach_dsymtab_command->locreloff );
    result->nlocrel = byte_order->swap32( mach_dsymtab_command->nlocrel );
    
    return MK_ESUCCESS;
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
mk_load_command_dysymtab_get_ilocalsym(mk_load_command_ref load_command)
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return UINT32_MAX);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_dysymtab_class, return UINT32_MAX);
    
    struct dysymtab_command *mach_dsymtab_command = (struct dysymtab_command*)load_command.load_command->mach_load_command;
    return mk_macho_get_byte_order(load_command.load_command->image)->swap32( mach_dsymtab_command->ilocalsym );
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
mk_load_command_dysymtab_get_nlocalsym(mk_load_command_ref load_command)
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return UINT32_MAX);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_dysymtab_class, return UINT32_MAX);
    
    struct dysymtab_command *mach_dsymtab_command = (struct dysymtab_command*)load_command.load_command->mach_load_command;
    return mk_macho_get_byte_order(load_command.load_command->image)->swap32( mach_dsymtab_command->nlocalsym );
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
mk_load_command_dysymtab_get_iextdefsym(mk_load_command_ref load_command)
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return UINT32_MAX);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_dysymtab_class, return UINT32_MAX);
    
    struct dysymtab_command *mach_dsymtab_command = (struct dysymtab_command*)load_command.load_command->mach_load_command;
    return mk_macho_get_byte_order(load_command.load_command->image)->swap32( mach_dsymtab_command->iextdefsym );
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
mk_load_command_dysymtab_get_nextdefsym(mk_load_command_ref load_command)
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return UINT32_MAX);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_dysymtab_class, return UINT32_MAX);
    
    struct dysymtab_command *mach_dsymtab_command = (struct dysymtab_command*)load_command.load_command->mach_load_command;
    return mk_macho_get_byte_order(load_command.load_command->image)->swap32( mach_dsymtab_command->nextdefsym );
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
mk_load_command_dysymtab_get_iundefsym(mk_load_command_ref load_command)
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return UINT32_MAX);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_dysymtab_class, return UINT32_MAX);
    
    struct dysymtab_command *mach_dsymtab_command = (struct dysymtab_command*)load_command.load_command->mach_load_command;
    return mk_macho_get_byte_order(load_command.load_command->image)->swap32( mach_dsymtab_command->iundefsym );
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
mk_load_command_dysymtab_get_nundefsym(mk_load_command_ref load_command)
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return UINT32_MAX);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_dysymtab_class, return UINT32_MAX);
    
    struct dysymtab_command *mach_dsymtab_command = (struct dysymtab_command*)load_command.load_command->mach_load_command;
    return mk_macho_get_byte_order(load_command.load_command->image)->swap32( mach_dsymtab_command->nundefsym );
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
mk_load_command_dysymtab_get_tocoff(mk_load_command_ref load_command)
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return UINT32_MAX);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_dysymtab_class, return UINT32_MAX);
    
    struct dysymtab_command *mach_dsymtab_command = (struct dysymtab_command*)load_command.load_command->mach_load_command;
    return mk_macho_get_byte_order(load_command.load_command->image)->swap32( mach_dsymtab_command->tocoff );
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
mk_load_command_dysymtab_get_ntoc(mk_load_command_ref load_command)
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return UINT32_MAX);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_dysymtab_class, return UINT32_MAX);
    
    struct dysymtab_command *mach_dsymtab_command = (struct dysymtab_command*)load_command.load_command->mach_load_command;
    return mk_macho_get_byte_order(load_command.load_command->image)->swap32( mach_dsymtab_command->ntoc );
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
mk_load_command_dysymtab_get_modtaboff(mk_load_command_ref load_command)
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return UINT32_MAX);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_dysymtab_class, return UINT32_MAX);
    
    struct dysymtab_command *mach_dsymtab_command = (struct dysymtab_command*)load_command.load_command->mach_load_command;
    return mk_macho_get_byte_order(load_command.load_command->image)->swap32( mach_dsymtab_command->modtaboff );
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
mk_load_command_dysymtab_get_nmodtab(mk_load_command_ref load_command)
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return UINT32_MAX);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_dysymtab_class, return UINT32_MAX);
    
    struct dysymtab_command *mach_dsymtab_command = (struct dysymtab_command*)load_command.load_command->mach_load_command;
    return mk_macho_get_byte_order(load_command.load_command->image)->swap32( mach_dsymtab_command->nmodtab );
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
mk_load_command_dysymtab_get_extrefsymoff(mk_load_command_ref load_command)
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return UINT32_MAX);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_dysymtab_class, return UINT32_MAX);
    
    struct dysymtab_command *mach_dsymtab_command = (struct dysymtab_command*)load_command.load_command->mach_load_command;
    return mk_macho_get_byte_order(load_command.load_command->image)->swap32( mach_dsymtab_command->extrefsymoff );
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
mk_load_command_dysymtab_get_nextrefsyms(mk_load_command_ref load_command)
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return UINT32_MAX);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_dysymtab_class, return UINT32_MAX);
    
    struct dysymtab_command *mach_dsymtab_command = (struct dysymtab_command*)load_command.load_command->mach_load_command;
    return mk_macho_get_byte_order(load_command.load_command->image)->swap32( mach_dsymtab_command->nextrefsyms );
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
mk_load_command_dysymtab_get_indirectsymoff(mk_load_command_ref load_command)
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return UINT32_MAX);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_dysymtab_class, return UINT32_MAX);
    
    struct dysymtab_command *mach_dsymtab_command = (struct dysymtab_command*)load_command.load_command->mach_load_command;
    return mk_macho_get_byte_order(load_command.load_command->image)->swap32( mach_dsymtab_command->indirectsymoff );
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
mk_load_command_dysymtab_get_nindirectsyms(mk_load_command_ref load_command)
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return UINT32_MAX);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_dysymtab_class, return UINT32_MAX);
    
    struct dysymtab_command *mach_dsymtab_command = (struct dysymtab_command*)load_command.load_command->mach_load_command;
    return mk_macho_get_byte_order(load_command.load_command->image)->swap32( mach_dsymtab_command->nindirectsyms );
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
mk_load_command_dysymtab_get_extreloff(mk_load_command_ref load_command)
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return UINT32_MAX);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_dysymtab_class, return UINT32_MAX);
    
    struct dysymtab_command *mach_dsymtab_command = (struct dysymtab_command*)load_command.load_command->mach_load_command;
    return mk_macho_get_byte_order(load_command.load_command->image)->swap32( mach_dsymtab_command->extreloff );
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
mk_load_command_dysymtab_get_nextrel(mk_load_command_ref load_command)
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return UINT32_MAX);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_dysymtab_class, return UINT32_MAX);
    
    struct dysymtab_command *mach_dsymtab_command = (struct dysymtab_command*)load_command.load_command->mach_load_command;
    return mk_macho_get_byte_order(load_command.load_command->image)->swap32( mach_dsymtab_command->nextrel );
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
mk_load_command_dysymtab_get_locreloff(mk_load_command_ref load_command)
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return UINT32_MAX);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_dysymtab_class, return UINT32_MAX);
    
    struct dysymtab_command *mach_dsymtab_command = (struct dysymtab_command*)load_command.load_command->mach_load_command;
    return mk_macho_get_byte_order(load_command.load_command->image)->swap32( mach_dsymtab_command->locreloff );
}

//|++++++++++++++++++++++++++++++++++++|//
uint32_t
mk_load_command_dysymtab_get_nlocrel(mk_load_command_ref load_command)
{
    _MK_LOAD_COMMAND_NOT_NULL(load_command, return UINT32_MAX);
    _MK_LOAD_COMMAND_IS_A(load_command, _mk_load_command_dysymtab_class, return UINT32_MAX);
    
    struct dysymtab_command *mach_dsymtab_command = (struct dysymtab_command*)load_command.load_command->mach_load_command;
    return mk_macho_get_byte_order(load_command.load_command->image)->swap32( mach_dsymtab_command->nlocrel );
}
