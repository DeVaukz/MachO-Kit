//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       MKMemoryMap.h
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

#import <MachOKit/MKBase.h>
#import <MachOKit/MKDataModel.h>

NS_ASSUME_NONNULL_BEGIN

//----------------------------------------------------------------------------//
@interface MKMemoryMap : NSObject

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Creating A Memory Mapping
//! @name       Creating A Memory Mapping
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//! Creates and returns an \ref MKMemoryMap for the contents of the file
//! at the provided \a fileURL.
+ (nullable instancetype)memoryMapWithContentsOfFile:(NSURL*)fileURL error:(NSError**)error;

//! Creates and returns an \ref MKMemoryMap for the contents of another
//! task's memory.
+ (nullable instancetype)memoryMapWithTask:(mach_port_t)task error:(NSError**)error;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  About Context Memory
//! @name       About Context Memory
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

- (mk_vm_size_t)mappingSizeAtOffset:(mk_vm_offset_t)offset fromAddress:(mk_vm_address_t)contextAddress length:(mk_vm_size_t)length;

- (mk_vm_size_t)mappingSizeAtOffset:(mk_vm_offset_t)offset fromAddress:(mk_vm_address_t)contextAddress length:(mk_vm_size_t)length error:(NSError**)error;

- (BOOL)hasMappingAtOffset:(mk_vm_offset_t)offset fromAddress:(mk_vm_address_t)contextAddress length:(mk_vm_size_t)length;

- (BOOL)hasMappingAtOffset:(mk_vm_offset_t)offset fromAddress:(mk_vm_address_t)contextAddress length:(mk_vm_size_t)length error:(NSError**)error;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Accessing Context Memory
//! @name       Accessing Context Memory
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//! Converts the address at (\a address + \a offset) into an address
//! accessible from the current process and invokes the \a handler.
//!
//! This method is abstract and must be implemented by subclasses.
//! Your implementation should be reentrant.
//!
//! @param  offset
//!         An offset to be added to \a address prior to conversion.
//! @param  contextAddress
//!         A context-relative address.
//! @param  length
//!         The number of bytes to be read.  If \a requireFull is \c YES, the
//!         conversion fails if one or more bytes would be inaccessible.
//! @param  requireFull
//!         See the description of \a length.
//! @param  handler
//!         Invoked with the address and length of the mapped bytes.
//!
//! @note
//! The address passed to the provided \a handler should only be considered
//! valid for the duration of the handler's execution.
- (void)remapBytesAtOffset:(mk_vm_offset_t)offset fromAddress:(mk_vm_address_t)contextAddress length:(mk_vm_size_t)length requireFull:(BOOL)requireFull withHandler:(void (^)(vm_address_t address, vm_size_t length, NSError * _Nullable error))handler;

- (nullable NSData*)dataAtOffset:(mk_vm_offset_t)offset fromAddress:(mk_vm_address_t)contextAddress length:(mk_vm_size_t)length requireFull:(BOOL)requireFull error:(NSError**)error;

- (vm_size_t)copyBytesAtOffset:(mk_vm_offset_t)offset fromAddress:(mk_vm_address_t)contextAddress into:(void*)buffer length:(mk_vm_size_t)length requireFull:(BOOL)requireFull error:(NSError**)error;

- (uint8_t)readByteAtOffset:(mk_vm_offset_t)offset fromAddress:(mk_vm_address_t)contextAddress withDataModel:(nullable MKDataModel*)dataModel error:(NSError**)error;

- (uint16_t)readWordAtOffset:(mk_vm_offset_t)offset fromAddress:(mk_vm_address_t)contextAddress withDataModel:(nullable MKDataModel*)dataModel error:(NSError**)error;

- (uint32_t)readDoubleWordAtOffset:(mk_vm_offset_t)offset fromAddress:(mk_vm_address_t)contextAddress withDataModel:(nullable MKDataModel*)dataModel error:(NSError**)error;

- (uint64_t)readQuadWordAtOffset:(mk_vm_offset_t)offset fromAddress:(mk_vm_address_t)contextAddress withDataModel:(nullable MKDataModel*)dataModel error:(NSError**)error;

@end

NS_ASSUME_NONNULL_END
