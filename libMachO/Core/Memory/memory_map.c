//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             memory_map.c
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

//|++++++++++++++++++++++++++++++++++++|//
static mk_context_t*
__mk_memory_map_get_context(mk_type_ref self)
{ return ((struct mk_memory_map_s*)self)->context; }

//|++++++++++++++++++++++++++++++++++++|//
static mk_error_t
__mk_memory_map_init_object(mk_memory_map_ref self, mk_vm_offset_t offset, mk_vm_address_t address, mk_vm_size_t length, bool require_full, mk_memory_object_t* memory_object)
{
#pragma unused (self)
#pragma unused (offset)
#pragma unused (address)
#pragma unused (length)
#pragma unused (require_full)
#pragma unused (memory_object)
    _mk_assert(false, NULL, "No default implementation of mk_memory_map_init_object.");
}

//|++++++++++++++++++++++++++++++++++++|//
static void
__mk_memory_map_free_object(mk_memory_map_ref self, mk_memory_object_t* memory_object)
{
#pragma unused (self)
#pragma unused (memory_object)
    _mk_assert(false, NULL, "No default implementation of mk_memory_map_free_object.");
}

//|++++++++++++++++++++++++++++++++++++|//
static bool
__mk_memory_map_has_mapping(mk_memory_map_ref self, mk_vm_offset_t offset, mk_vm_address_t address, mk_vm_size_t length, mk_error_t* error)
{
    mk_error_t err;
    mk_memory_object_t memory_object;
    
    if ((err = mk_memory_map_init_object(self, offset, address, length, false, &memory_object))) {
        MK_ERROR_OUT = err;
        return false;
    }
    
    bool retValue = mk_memory_object_length(&memory_object) > length;
    
    mk_memory_map_free_object(self, &memory_object);
    return retValue;
}

//|++++++++++++++++++++++++++++++++++++|//
static size_t
__mk_memory_map_copy_bytes(mk_memory_map_ref self, mk_vm_offset_t offset, mk_vm_address_t address, void* buffer, mk_vm_size_t length, bool require_full, mk_error_t* error)
{
    mk_error_t err;
    mk_memory_object_t memory_object;
    
    if ((err = mk_memory_map_init_object(self, offset, address, length, require_full, &memory_object))) {
        MK_ERROR_OUT = err;
        return false;
    }
    
    vm_size_t mappingLength = mk_memory_object_length(&memory_object);
    memcpy(buffer, (void*)mk_memory_object_address(&memory_object), MIN(length, (mk_vm_size_t)mappingLength));
    
    mk_memory_map_free_object(self, &memory_object);
    return (size_t)MIN(length, (mk_vm_size_t)mappingLength);
}

//|++++++++++++++++++++++++++++++++++++|//
static uint8_t
__mk_memory_map_read_byte(mk_memory_map_ref self, mk_vm_offset_t offset, mk_vm_address_t address, mk_data_model_ref data_model, mk_error_t* error)
{
#pragma unused (data_model)
    uint8_t retValue;
    size_t readSize;
    
    readSize = mk_memory_map_copy_bytes(self, offset, address, &retValue, sizeof(uint8_t), true, error);
    if (readSize < sizeof(uint8_t))
        return 0;
    
    return retValue;
}

//|++++++++++++++++++++++++++++++++++++|//
static uint16_t
__mk_memory_map_read_word(mk_memory_map_ref self, mk_vm_offset_t offset, mk_vm_address_t address, mk_data_model_ref data_model, mk_error_t* error)
{
    uint16_t retValue;
    size_t readSize;
    
    readSize = mk_memory_map_copy_bytes(self, offset, address, &retValue, sizeof(uint16_t), true, error);
    if (readSize < sizeof(uint16_t))
        return 0;
    
    if (data_model.data_model)
        return mk_data_model_get_byte_order(data_model)->swap16( retValue );
    else
        return retValue;
}

//|++++++++++++++++++++++++++++++++++++|//
static uint32_t
__mk_memory_map_read_dword(mk_memory_map_ref self, mk_vm_offset_t offset, mk_vm_address_t address, mk_data_model_ref data_model, mk_error_t* error)
{
    uint32_t retValue;
    size_t readSize;
    
    readSize = mk_memory_map_copy_bytes(self, offset, address, &retValue, sizeof(uint32_t), true, error);
    if (readSize < sizeof(uint32_t))
        return 0;
    
    if (data_model.data_model)
        return mk_data_model_get_byte_order(data_model)->swap32( retValue );
    else
        return retValue;
}

//|++++++++++++++++++++++++++++++++++++|//
static uint64_t
__mk_memory_map_read_qword(mk_memory_map_ref self, mk_vm_offset_t offset, mk_vm_address_t address, mk_data_model_ref data_model, mk_error_t* error)
{
    uint64_t retValue;
    size_t readSize;
    
    readSize = mk_memory_map_copy_bytes(self, offset, address, &retValue, sizeof(uint64_t), true, error);
    if (readSize < sizeof(uint64_t))
        return 0;
    
    if (data_model.data_model)
        return mk_data_model_get_byte_order(data_model)->swap64( retValue );
    else
        return retValue;
}

const struct _mk_memory_map_vtable _mk_memory_map_class = {
    .base.super                 = &_mk_type_class,
    .base.name                  = "memory_map",
    .base.get_context           = &__mk_memory_map_get_context,
    .init_object                = &__mk_memory_map_init_object,
    .free_object                = &__mk_memory_map_free_object,
    .has_mapping                = &__mk_memory_map_has_mapping,
    .copy_bytes                 = &__mk_memory_map_copy_bytes,
    .read_byte                  = &__mk_memory_map_read_byte,
    .read_word                  = &__mk_memory_map_read_word,
    .read_dword                 = &__mk_memory_map_read_dword,
    .read_qword                 = &__mk_memory_map_read_qword
};

intptr_t mk_memory_map_type = (intptr_t)&_mk_memory_map_class;

//----------------------------------------------------------------------------//
#pragma mark -  Static Methods
//----------------------------------------------------------------------------//

//|++++++++++++++++++++++++++++++++++++|//
mk_memory_map_ref mk_memory_map_for_object(mk_memory_object_ref mobj)
{ return (mk_memory_map_ref)(struct mk_memory_map_s*)mobj.memory_object->mapping; }

//----------------------------------------------------------------------------//
#pragma mark -  Instance Methods
//----------------------------------------------------------------------------//

//|++++++++++++++++++++++++++++++++++++|//
mk_error_t mk_memory_map_init_object(mk_memory_map_ref map, mk_vm_offset_t offset, mk_vm_address_t address, mk_vm_size_t length, bool require_full, mk_memory_object_t* memory_object)
{ MK_TYPE_INVOKE(map, memory_map, init_object)(map, offset, address, length, require_full, memory_object); }

//|++++++++++++++++++++++++++++++++++++|//
void mk_memory_map_free_object(mk_memory_map_ref map, mk_memory_object_t* memory_object)
{ MK_TYPE_INVOKE(map, memory_map, free_object)(map, memory_object); }

//|++++++++++++++++++++++++++++++++++++|//
bool mk_memory_map_has_mapping(mk_memory_map_ref map, mk_vm_offset_t offset, mk_vm_address_t address, mk_vm_size_t length, mk_error_t* error)
{ MK_TYPE_INVOKE(map, memory_map, has_mapping)(map, offset, address, length, error); }

//|++++++++++++++++++++++++++++++++++++|//
size_t mk_memory_map_copy_bytes(mk_memory_map_ref map, mk_vm_offset_t offset, mk_vm_address_t address, void* buffer, mk_vm_size_t length, bool require_full, mk_error_t* error)
{ MK_TYPE_INVOKE(map, memory_map, copy_bytes)(map, offset, address, buffer, length, require_full, error); }

//|++++++++++++++++++++++++++++++++++++|//
uint8_t mk_memory_map_read_byte(mk_memory_map_ref map, mk_vm_offset_t offset, mk_vm_address_t address, mk_data_model_ref data_model, mk_error_t* error)
{ MK_TYPE_INVOKE(map, memory_map, read_byte)(map, offset, address, data_model, error); }

//|++++++++++++++++++++++++++++++++++++|//
uint16_t mk_memory_map_read_word(mk_memory_map_ref map, mk_vm_offset_t offset, mk_vm_address_t address, mk_data_model_ref data_model, mk_error_t* error)
{ MK_TYPE_INVOKE(map, memory_map, read_word)(map, offset, address, data_model, error); }

//|++++++++++++++++++++++++++++++++++++|//
uint32_t mk_memory_map_read_dword(mk_memory_map_ref map, mk_vm_offset_t offset, mk_vm_address_t address, mk_data_model_ref data_model, mk_error_t* error)
{ MK_TYPE_INVOKE(map, memory_map, read_dword)(map, offset, address, data_model, error); }

//|++++++++++++++++++++++++++++++++++++|//
uint64_t mk_memory_map_read_qword(mk_memory_map_ref map, mk_vm_offset_t offset, mk_vm_address_t address, mk_data_model_ref data_model, mk_error_t* error)
{ MK_TYPE_INVOKE(map, memory_map, read_qword)(map, offset, address, data_model, error); }
