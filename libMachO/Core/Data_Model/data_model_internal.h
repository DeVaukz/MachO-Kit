//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       data_model_internal.h
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

#ifndef _data_model_internal_h
#define _data_model_internal_h
#ifndef DOXYGEN

//! @addtogroup DATA_MODEL
//! @{
//!

//----------------------------------------------------------------------------//
#pragma mark -  Classes
//! @name       Classes
//----------------------------------------------------------------------------//

//! Member function prototype for the \ref mk_data_model_get_byte_order
//! polymorphic function.  Your implementation should return a pointer to the
//! \ref mk_byteorder_t for the data model.
typedef const mk_byteorder_t* (*_mk_data_model_get_byte_order)(mk_data_model_ref self, void* reserved);

//! Member function prototype for the \ref mk_data_model_get_pointer_size
//! polymorphic function.  Your implementation should return the size of a
//! pointer for the data model.
typedef size_t (*_mk_data_model_get_pointer_size)(mk_data_model_ref self, void* reserved);

//! Member function prototype for the \ref mk_data_model_get_pointer_alignment
//! polymorphic function.  Your implementation should return the alignment of
//! a pointer for the data model.
typedef size_t (*_mk_data_model_get_pointer_alignment)(mk_data_model_ref self, void* reserved);

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
//! @internal
//!
//! Member function table declaration for the \c data_model type.
//
struct _mk_data_model_vtable {
    __MK_RUNTIME_TYPE_BASE
    //! This method is abstract.  Subclasses must provide an implementation.
    _mk_data_model_get_byte_order get_byte_order;
    //! This method is abstract.  Subclasses must provide an implementation.
    _mk_data_model_get_pointer_size get_pointer_size;
    //! This method is abstract.  Subclasses must provide an implementation.
    _mk_data_model_get_pointer_alignment get_pointer_alignment;
};

//! The member function table for the\c data_model type.  Contains
//! implementations of all non-abstract methods in
//! \c struct mk_data_model_vtable.
_mk_internal_extern
const struct _mk_data_model_vtable _mk_data_model_class;


//! @} DATA_MODEL !//

#endif
#endif /* _data_model_internal_h */
