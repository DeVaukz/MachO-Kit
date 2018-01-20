//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKOffsetNode.m
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

#import "MKOffsetNode.h"
#import "MKInternal.h"

//----------------------------------------------------------------------------//
@implementation MKOffsetNode

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithOffset:(mk_vm_offset_t)offset fromParent:(MKBackedNode*)parent error:(NSError**)error
{
    mk_error_t err;
    
    // Verify that calculating our context address will not overflow.
    if (parent && (err = mk_vm_address_apply_offset(parent.nodeContextAddress, offset, NULL))) {
        MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:err description:@"Arithmetic error [%s] applying offset [%" MK_VM_PRIuOFFSET "] to address [0x%" MK_VM_PRIxADDR "] of parent node %@.", mk_error_string(err), offset, parent.nodeContextAddress, parent.nodeDescription];
        [self release]; return nil;
    }
    
    // TODO: Verify that calculating the VM address will not overflow?
    
    self = [super initWithParent:parent error:error];
    if (self == nil) return nil;
    
    _nodeOffset = offset;
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithParent:(MKNode*)parent error:(NSError**)error
{ return [self initWithOffset:0 fromParent:(MKBackedNode*)parent error:error]; }

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Memory Layout
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@synthesize nodeOffset = _nodeOffset;

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_address_t)nodeAddress:(MKNodeAddressType)type
{
    MKNode *parent = self.parent;
    mk_vm_address_t parentAddress = [(MKBackedNode*)parent nodeAddress:type];
    
    if (parentAddress == MK_VM_ADDRESS_INVALID)
        return MK_VM_ADDRESS_INVALID;
    
    mk_error_t err;
    mk_vm_address_t retValue;
    
    if ((err = mk_vm_address_apply_offset(parentAddress, _nodeOffset, &retValue))) {
        // This should have been caught during initialization.
        NSString *reason = [NSString stringWithFormat:@"Arithmetic error [%s] applying offset [%" MK_VM_PRIuOFFSET "] of node %@ to address (type %lu) [0x%" MK_VM_PRIxADDR "] of parent node %@.", mk_error_string(err), _nodeOffset, self.nodeDescription, (unsigned long)type, parentAddress, parent.nodeDescription];
        @throw [NSException exceptionWithName:NSRangeException reason:reason userInfo:nil];
    }
    
    return retValue;
}

@end
