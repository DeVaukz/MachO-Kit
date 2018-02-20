//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             _MKTaskMemoryMap.m
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

#import "_MKTaskMemoryMap.h"
#import "MKInternal.h"

#if TARGET_OS_MAC && !TARGET_OS_IPHONE

//----------------------------------------------------------------------------//
@implementation _MKTaskMemoryMap

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithTask:(mach_port_t)task error:(NSError**)error
{
    self = [super init];
    if (self == nil) return nil;
    
    _task = task;
    
    kern_return_t err = mach_port_mod_refs(mach_task_self(), _task, MACH_PORT_RIGHT_SEND, 1);
    if (err) {
        MK_ERROR_OUT = [NSError mk_errorWithDomain:NSMachErrorDomain code:err description:@"Failed to retain the target task port."];
        [self release]; return nil;
    }
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (void)dealloc
{
    mach_port_mod_refs(mach_task_self(), _task, MACH_PORT_RIGHT_SEND, -1);
    
    [super dealloc];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Accessing Context Memory
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (void)remapBytesAtOffset:(mk_vm_offset_t)offset fromAddress:(mk_vm_address_t)contextAddress length:(mk_vm_size_t)length requireFull:(BOOL)requireFull withHandler:(void (^)(vm_address_t address, vm_size_t length, NSError *error))handler
{
	// TODO - Investigate caching mappings.  This is too much work to be doing thousands of times.
    mk_error_t mkErr;
    
    // Compute the offset address
    if ((mkErr = mk_vm_address_apply_offset(contextAddress, offset, &contextAddress))) {
        NSError *error = [NSError mk_errorWithDomain:MKErrorDomain code:(mkErr | MK_EMEMORY_ERROR) description:@"Arithmetic error [%s] adding offset [%" MK_VM_PRIuOFFSET "] to address [0x%" MK_VM_PRIxADDR "].", mk_error_string(mkErr), offset, contextAddress];
        handler(0, 0, error);
        return;
    }
    
    mach_vm_address_t baseContextAddress = mach_vm_trunc_page(contextAddress);
    mach_vm_offset_t contextAddressOffset = contextAddress - baseContextAddress;
    
    // Derive a new length accounting for the added difference between the
    // contextAddress and the baseContextAddress, rounded to the page size.
    // This may overflow if length is sufficiently close to UINT64_MAX.
    mach_vm_size_t totalLength = mach_vm_round_page(length + contextAddressOffset);
    // Check if we have overflowed.
    if (totalLength < length)
    {
        if (!requireFull)
            totalLength = UINT64_MAX;
        else {
            NSError *error = [NSError mk_errorWithDomain:MKErrorDomain code:(MK_EBAD_ACCESS | MK_EMEMORY_ERROR) description:@"Input range (offset address = 0x%" MK_VM_PRIxADDR ", length = 0x%" MK_VM_PRIxSIZE ") is not within %@.", contextAddress, length, self];
            handler(0, 0, error);
            return;
        }
    }
    // Check if adding the totalLength to the baseContextAddress would overflow.
    else if (UINT64_MAX - totalLength < baseContextAddress)
    {
        if (!requireFull)
            totalLength = UINT64_MAX - baseContextAddress;
        else {
            NSError *error = [NSError mk_errorWithDomain:MKErrorDomain code:(MK_EBAD_ACCESS | MK_EMEMORY_ERROR) description:@"Input range (offset address = 0x%" MK_VM_PRIxADDR ", length = 0x%" MK_VM_PRIxSIZE ") is not within %@.", contextAddress, length, self];
            handler(0, 0, error);
            return;
        }
    }
    
    // totalLength should still be page aligned.
    NSAssert((totalLength & vm_page_mask) == 0x0, @"totalLength is not page aligned.");
    
    // If short mappings are permitted, determine the actual mappable size of
    // the target range.
    if (!requireFull)
    {
        mach_vm_size_t verifiedLength = 0;
        
        while (verifiedLength < length) {
            memory_object_size_t entryLength = totalLength - verifiedLength;
            mach_port_t memHandle;
            kern_return_t error;
            
            error = mach_make_memory_entry_64(_task, &entryLength, baseContextAddress + verifiedLength, VM_PROT_READ, &memHandle, MACH_PORT_NULL);
            // Break once we hit an unmappable page.
            if (error != KERN_SUCCESS)
                break;
            
            // Drop the reference
            error = mach_port_mod_refs(mach_task_self(), memHandle, MACH_PORT_RIGHT_SEND, -1);
            if (error != KERN_SUCCESS) {
                // TODO - Log this.  We're leaking ports.
            }
            
            verifiedLength += entryLength;
        }
        
        // No mappable pages found at contextAddress.
        if (verifiedLength == 0) {
            NSError *error = [NSError mk_errorWithDomain:MKErrorDomain code:(MK_EBAD_ACCESS | MK_EMEMORY_ERROR) description:@"Input range (offset address = 0x%" MK_VM_PRIxADDR ", length = 0x%" MK_VM_PRIxSIZE ") is not within %@.", contextAddress, length, self];
            handler(0, 0, error);
            return;
        }
        
        if (verifiedLength < totalLength)
            totalLength = verifiedLength;
    }
    
    mach_vm_address_t mappingAddress = 0x0;
    mach_vm_size_t mappedLength = 0;
    
    // Reserve enough pages to contain the mapping.
    kern_return_t err = mach_vm_allocate(mach_task_self(), &mappingAddress, totalLength, VM_FLAGS_ANYWHERE);
    if (err != KERN_SUCCESS) {
        NSError *error = [NSError mk_errorWithDomain:NSMachErrorDomain code:err description:@"Failed to allocate a target page range for the page remapping."];
        handler(0, 0, error);
        return;
    }
    
    //
    while (mappedLength < totalLength) {
        memory_object_size_t entryLength = totalLength - mappedLength;
        mach_port_t memHandle;
        kern_return_t err;
        
        // Create a reference to the target pages.  The returned entry may be
        // smaller than the entryLength.
        err = mach_make_memory_entry_64(_task, &entryLength, baseContextAddress + mappedLength, VM_PROT_READ, &memHandle, MACH_PORT_NULL);
        if (err != KERN_SUCCESS)
        {
            // Cleanup the reserved pages
            err = mach_vm_deallocate(mach_task_self(), mappingAddress, totalLength);
            if (err != KERN_SUCCESS) {
                // TODO - Log this.  We're leaking pages.
            }
            
            NSError *error = [NSError mk_errorWithDomain:MKErrorDomain code:(MK_EBAD_ACCESS | MK_EMEMORY_ERROR) description:@"Input range (offset address = 0x%" MK_VM_PRIxADDR ", length = 0x%" MK_VM_PRIxSIZE ") is not within %@.", contextAddress, length, self];
            handler(0, 0, error);
            return;
        }
        
        // Map the pages into our local task, overwriting the allocation used to
        // reserve the target space above.
        mach_vm_address_t targetAddress = mappingAddress + mappedLength;
        err = mach_vm_map(mach_task_self(), &targetAddress, entryLength, 0x0, VM_FLAGS_FIXED|VM_FLAGS_OVERWRITE, memHandle, 0x0, true, VM_PROT_READ, VM_PROT_READ, VM_INHERIT_COPY);
        if (err != KERN_SUCCESS)
        {
            // Cleanup the reserved pages
            err = mach_vm_deallocate(mach_task_self(), mappingAddress, totalLength);
            if (err != KERN_SUCCESS) {
                // TODO - Log this.  We're leaking pages.
            }
            
            // Drop the memory handle
            err = mach_port_mod_refs(mach_task_self(), memHandle, MACH_PORT_RIGHT_SEND, -1);
            if (err != KERN_SUCCESS) {
                // TODO - Log this.  We're leaking ports.
            }
            
            NSError *error = [NSError mk_errorWithDomain:NSMachErrorDomain code:err description:@"mach_vm_map() failed."];
            handler(0, 0, error);
            return;
        }
        
        // Drop the memory handle
        err = mach_port_mod_refs(mach_task_self(), memHandle, MACH_PORT_RIGHT_SEND, -1);
        if (err != KERN_SUCCESS) {
            // TODO - Log this.  We're leaking ports.
        }
        
        mappedLength += entryLength;
    }
    
    // Determine the correct offset into the mapping corresponding to the
    // requested address.
    contextAddress = mappingAddress + contextAddressOffset;
    length = mappedLength - (contextAddress - mappingAddress);
    
    // Call the handler.  The potential down-cast is safe because the mapping
    // would have failed if we could not bring the entire range into this
    // process.
    handler((vm_address_t)contextAddress, (vm_size_t)length, nil);
    
    // Cleanup
    err = mach_vm_deallocate(mach_task_self(), mappingAddress, mappedLength);
    if (err != KERN_SUCCESS) {
        // TODO - Warning
    }
}

@end

#endif
