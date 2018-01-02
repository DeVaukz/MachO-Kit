//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKOffsetNode+AddressBasedInitialization.m
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

#import "MKOffsetNode+AddressBasedInitialization.h"
#import "MKInternal.h"
#import "MKMachO.h"

//----------------------------------------------------------------------------//
@implementation MKOffsetNode (AddressBasedInitialization)

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)nodeVMAddress:(mk_vm_address_t)address inImage:(MKMachOImage*)image error:(NSError**)error
{
    MKOptional<MKBackedNode*> *existing = [image childNodeAtVMAddress:address];
    
    if (existing.value) {
        if ([existing.value isKindOfClass:self]) {
            return (id)existing.value;
        } else {
            /* Fall through */
        }
    } else if (existing.error) {
        MK_ERROR_OUT = existing.error;
        return nil;
    }
    
    return [[[self alloc] initWithVMAddress:address inImage:image error:error] autorelease];
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithVMAddress:(mk_vm_address_t)address inImage:(MKMachOImage*)image error:(NSError**)error
{
    NSParameterAssert(image);
    
    MKBackedNode *deepestParent = [image childNodeOccupyingVMAddress:address targetClass:nil].value;
    if (deepestParent == nil) {
        MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_ENOT_FOUND description:@"No parent node for address 0x%" MK_VM_PRIxADDR " in image.", address];
        [self release]; return nil;
    }
    
    mk_error_t err;
    mk_vm_offset_t offset;
    
    if ((err = mk_vm_address_subtract(address, deepestParent.nodeVMAddress, &offset))) {
        MK_ERROR_OUT = MK_MAKE_VM_ADDRESS_DEFFERENCE_ARITHMETIC_ERROR(err, address, deepestParent.nodeVMAddress);
        [self release]; return nil;
    }
    
    return [self initWithOffset:offset fromParent:deepestParent error:error];
}

@end
