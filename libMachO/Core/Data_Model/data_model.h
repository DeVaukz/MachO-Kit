//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       data_model.h
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
//! @defgroup DATA_MODEL Data Model
//! @ingroup CORE
//!
//! A data model contains basic information about a specific instruction set
//! architecture.
//----------------------------------------------------------------------------//

#ifndef _data_model_h
#define _data_model_h

//! @addtogroup DATA_MODEL
//! @{
//!

//----------------------------------------------------------------------------//
#pragma mark -  Types
//! @name       Types
//----------------------------------------------------------------------------//

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
//! @internal
//
struct mk_data_model_s {
    __MK_RUNTIME_BASE
};

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
//! The Data Model polymorphic type.
//
typedef union {
    struct mk_data_model_s *data_model;
} mk_data_model_ref __attribute__((__transparent_union__));

//! The identifier for the Data Model type.
_mk_export intptr_t mk_data_model_type;

//! The identifier for the ILP32 Data Model type.
_mk_export intptr_t mk_data_model_ilp32_type;

//! The identifier for the LP64 Data Model type.
_mk_export intptr_t mk_data_model_lp64_type;


//----------------------------------------------------------------------------//
#pragma mark -  Creating A Data Model
//! @name       Creating A Data Model
//----------------------------------------------------------------------------//

//! Returns a \ref mk_data_model_t for the ILP32 data model used in
//! Intel/32-bit Mach-O images.
_mk_export mk_data_model_ref
mk_data_model_ilp32();

//! Returns a \ref mk_data_model_t for the LP64 data model used in
//! Intel/64-bit Mach-O images.
_mk_export mk_data_model_ref
mk_data_model_lp64();


//----------------------------------------------------------------------------//
#pragma mark -  Instance Methods
//! @name       Instance Methods
//----------------------------------------------------------------------------//

//! Returns a \ref mk_byteorder_t to convert data between the endianness of
//! data represented by \a data_model and the current process.
_mk_export const mk_byteorder_t*
mk_data_model_get_byte_order(mk_data_model_ref data_model);

//! Returns the size of a pointer under \a data_model.
_mk_export size_t
mk_data_model_get_pointer_size(mk_data_model_ref data_model);

//! Returns the alignment of a pointer under \a data_model.
_mk_export size_t
mk_data_model_get_pointer_alignment(mk_data_model_ref data_model);

//! Returns \c true if \a data_model represents a 64-bit ISA.
_mk_export bool
mk_data_model_is_64_bit(mk_data_model_ref data_model);


//! @} DATA_MODEL !//

#endif /* _data_model_h */
