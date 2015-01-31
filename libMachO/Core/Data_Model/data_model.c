//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             data_model.c
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

#include "core_internal.h"

//----------------------------------------------------------------------------//
#pragma mark -  Classes
//----------------------------------------------------------------------------//

static struct mk_data_model_vtable __mk_data_model_class = {
    .base.super             = &_mk_type_class,
    .base.name              = "data_model"
};

//----------------------------------------------------------------------------//
#pragma mark -  Static Types
//----------------------------------------------------------------------------//

struct mk_data_model_s ILP32_byte_order = {
    .vtable                 = &__mk_data_model_class,
#if TARGET_RT_BIG_ENDIAN
    .byte_order             = &mk_byteorder_swapped,
#else
    .byte_order             = &mk_byteorder_direct,
#endif
    .pointer_size           = 4,
    .pointer_alignment      = 4
};

struct mk_data_model_s LP64_byte_order = {
    .vtable                 = &__mk_data_model_class,
#if TARGET_RT_BIG_ENDIAN
    .byte_order             = &mk_byteorder_swapped,
#else
    .byte_order             = &mk_byteorder_direct,
#endif
    .pointer_size           = 8,
    .pointer_alignment      = 8
};

//----------------------------------------------------------------------------//
#pragma mark -  Interacting With Memory Objects
//----------------------------------------------------------------------------//

//|++++++++++++++++++++++++++++++++++++|//
mk_data_model_ref
mk_data_model_ilp32()
{
    mk_data_model_ref data_model;
    data_model.data_model = &ILP32_byte_order;
    return data_model;
}

//|++++++++++++++++++++++++++++++++++++|//
mk_data_model_ref
mk_data_model_lp64()
{
    mk_data_model_ref data_model;
    data_model.data_model = &LP64_byte_order;
    return data_model;
}

//----------------------------------------------------------------------------//
#pragma mark -  Instance Methods
//----------------------------------------------------------------------------//

//|++++++++++++++++++++++++++++++++++++|//
const mk_byteorder_t*
mk_data_model_get_byte_order(mk_data_model_ref data_model)
{ return data_model.data_model->byte_order; }

//|++++++++++++++++++++++++++++++++++++|//
size_t
mk_data_model_get_pointer_size(mk_data_model_ref data_model)
{ return data_model.data_model->pointer_size; }

//|++++++++++++++++++++++++++++++++++++|//
size_t
mk_data_model_get_pointer_alignment(mk_data_model_ref data_model)
{ return data_model.data_model->pointer_alignment; }
