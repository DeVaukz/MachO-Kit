//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             _MKFileMemoryMap.m
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

#import "_MKFileMemoryMap.h"
#import "MKInternal.h"

//----------------------------------------------------------------------------//
@implementation _MKFileMemoryMap

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithURL:(NSURL*)fileURL error:(NSError**)error
{
    self = [super init];
    if (self == nil) return nil;
    
    _fileData = [[NSData alloc] initWithContentsOfURL:fileURL options:NSDataReadingMappedIfSafe error:error];
    if (_fileData == nil) { [self release]; return nil; }
    
    _fileURL = [fileURL retain];
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (void)dealloc
{
    [_fileData release];
    [_fileURL release];
    
    [super dealloc];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Accessing Context Memory
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (void)remapBytesAtOffset:(mk_vm_offset_t)offset fromAddress:(mk_vm_address_t)contextAddress length:(mk_vm_size_t)length requireFull:(BOOL)requireFull withHandler:(void (^)(vm_address_t address, vm_size_t length, NSError *error))handler
{
    mk_error_t err;
    mk_vm_address_t offsetAddress;
    
    // Compute the offset address.
    if ((err = mk_vm_address_apply_offset(contextAddress, offset, &offsetAddress))) {
        NSError *error = [NSError mk_errorWithDomain:MKErrorDomain code:(NSInteger)(err | MK_EMEMORY_ERROR) description:@"Arithmetic error [%s] adding offset [%" MK_VM_PRIuOFFSET "] to address [0x%" MK_VM_PRIxADDR "].", mk_error_string(err), offset, contextAddress];
        handler(0, 0, error);
        return;
    }
    
    mk_vm_size_t fileLength = (mach_vm_size_t)_fileData.length;
    
    // contextAddress must be within [0, fileLength)
    if (offsetAddress >= fileLength || (requireFull && (MK_VM_SIZE_MAX - length < offsetAddress || offsetAddress + length > fileLength)))
    {
        NSError *error = [NSError mk_errorWithDomain:MKErrorDomain code:(NSInteger)(MK_EBAD_ACCESS | MK_EMEMORY_ERROR) description:@"Input range (offset address = 0x%" MK_VM_PRIxADDR ", length = %" MK_VM_PRIxSIZE ") is not within %@", offsetAddress, length, self];
        handler(0, 0, error);
        return;
    }
    
    // Safe - contextAddress >= fileLength would be true otherwise.
    vm_address_t fileOffset = (vm_address_t)_fileData.bytes + (vm_address_t)offsetAddress;
    vm_size_t mappingLength = (vm_size_t)MIN(length, fileLength - (vm_address_t)offsetAddress);
    
    handler(fileOffset, mappingLength, nil);
}

@end
