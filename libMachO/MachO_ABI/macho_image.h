//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       macho_image.h
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

#ifndef _macho_image_h
#define _macho_image_h

#include <mach-o/loader.h>
#include <mach-o/nlist.h>

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
typedef struct mk_macho_s {
    __MK_RUNTIME_BASE
    
    // The context associated with this Mach-O.
    mk_context_t *context;
    
    // The memory map to use for this image.
    mk_memory_map_ref memory_map;
    // See \ref mk_data_model
    mk_data_model_ref data_model;
    
    // The binary's dyld-reported reported vmaddr slide.  This will be zero
    // for binaries on disk.
    intptr_t slide;
    // The binary image's name/path.
    const char *name;
    
    // Memory object mapping the Mach-O header and load commands into the
    // current process.
    mk_memory_object_t header_mapping;
    // The Mach-O header. For our purposes, the 32-bit and 64-bit headers are
    // identical. Note that the header values may require byte-swapping for
    // the local process' use.
    struct mach_header *header;
    // Total size, in bytes, of the Mach-O header. This may differ from the
    // header field above, as the above field does not include the full
    // mach_header_64 extensions to the mach_header.
    mk_vm_size_t header_size;
} mk_macho_t;

    
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
//! The Mach-O image polymorphic type.
//
typedef union {
    struct mk_macho_s *macho;
} mk_macho_ref __attribute__((__transparent_union__));

//! The identifier for the Mach-O Image type.
_mk_export intptr_t mk_macho_image_type;


//----------------------------------------------------------------------------//
#pragma mark -  Working With MachO Binaries
//! @name       Working With MachO Binaries
//----------------------------------------------------------------------------//

//! Initializes a new MachO image.
_mk_export mk_error_t
mk_macho_init(mk_context_t* ctx, const char* name, intptr_t slide, mk_vm_address_t header_addr,
              mk_memory_map_ref memory_map, mk_macho_t* image);

//! Cleans up resources held by a MachO image.
_mk_export void
mk_macho_free(mk_macho_ref image);
    
//! Returns the \ref mk_memory_map_ref the provided \a image was initialized
//! with.
_mk_export mk_memory_map_ref
mk_macho_get_memory_map(mk_macho_ref image);

//! The \ref data_model representing the architecture the provided \a image
//! is built to run on.
_mk_export mk_data_model_ref
mk_macho_get_data_model(mk_macho_ref image);

//! Shortcut to retrieving the \c byte_order from the \c data_model returned
//! by calling \ref mk_macho_data_model.
_mk_export const mk_byteorder_t*
mk_macho_get_byte_order(mk_macho_ref image);

//! Shortcut to calling \ref mk_data_model_is_64_bit on the underlying
//! data model.
_mk_export bool
mk_macho_is_64_bit(mk_macho_ref image);
    
//! Returns the slide that the provided \a image was initialized with.
_mk_export intptr_t
mk_macho_get_slide(mk_macho_ref image);
    
//! Returns the name that the provided \a image was initialized with.
_mk_export const char*
mk_macho_get_name(mk_macho_ref image);
    
//! Returns the header address that the provided \a image was initialized with.
_mk_export mk_vm_address_t
mk_macho_get_address(mk_macho_ref image);
    

//----------------------------------------------------------------------------//
#pragma mark -  Mach-O Header Values
//! @name       Mach-O Header Values
//----------------------------------------------------------------------------//

_mk_export cpu_type_t
mk_macho_get_cpu_type(mk_macho_ref image);
_mk_export cpu_subtype_t
mk_macho_get_cpu_subtype(mk_macho_ref image);
_mk_export uint32_t
mk_macho_get_filetype(mk_macho_ref image);
_mk_export uint32_t
mk_macho_get_ncmds(mk_macho_ref image);
_mk_export uint32_t
mk_macho_get_sizeofcmds(mk_macho_ref image);
_mk_export uint32_t
mk_macho_get_flags(mk_macho_ref image);
    
//! Returns \c true if the provided \a image is part of the dy;d shared cache.
_mk_export bool
mk_macho_is_from_shared_cache(mk_macho_ref image);


//----------------------------------------------------------------------------//
#pragma mark -  Enumerating Load Commands
//! @name       Enumerating Load Commands
//----------------------------------------------------------------------------//

//! Iterate over the available Mach-O LC_CMD entries.
//!
//! @param  image
//!         The image to iterate
//! @param  previous
//!         The previously returned load command, or \c NULL to iterate from
//!         the first command.
//! @param  host_address [out]
//!         If not \c NULL, populated with the host-relative address of the
//!         load command upon successful return.
//! @return
//! A process-relative pointer to the load command or \c NULL if there was an
//! error.  The returned command is gauranteed to be readable, and fully within
//! the process address space.
_mk_export struct load_command*
mk_macho_next_command(mk_macho_ref image, struct load_command* previous,
                      mk_vm_address_t* host_address);

#if __BLOCKS__
//! Iterate over the available Mach-O LC_CMD entries using a block.
_mk_export void
mk_macho_enumerate_commands(mk_macho_ref image,
                            void (^enumerator)(struct load_command* command, uint32_t index, mk_vm_address_t host_address));
#endif

//! Iterate over the available Mach-O LC_CMD entries.
//!
//! @param  image
//!         The image to iterate
//! @param  previous
//!         The previously returned load command, or \c NULL to iterate from
//!         the first command.
//! @param  expectedCommand
//!         The LC_* command type to be returned. Only commands matching this
//!         type will be returned by the iterator.
//! @param  host_address [out]
//!         If not \c NULL, populated with the host-relative address of the
//!         load command upon successful return.
//! @return
//! A process-relative pointer to the load command or \c NULL if there was an
//! error.  The returned command is gauranteed to be readable, and fully within
//! the process address space.
_mk_export struct load_command*
mk_macho_next_command_type(mk_macho_ref image, struct load_command* previous,
                           uint32_t expected_command, mk_vm_address_t* host_address);

//! Find the first instance of the specified command type.
//!
//! @param  image
//!         The image to iterate.
//! @param  expectedCommand
//!         The LC_* command type to be returned.
//! @param  host_address [out]
//!         If not \c NULL, populated with the host-relative address of the
//!         load command upon successful return.
//! @return
//! A process-relative pointer to the load command or \c NULL if there was an
//! error.  The returned command is gauranteed to be readable, and fully within
//! the process address space.
_mk_export struct load_command*
mk_macho_find_command(mk_macho_ref image, uint32_t expected_command, mk_vm_address_t* host_address);


//! @} MACH !//

#endif /* _macho_image_h */
