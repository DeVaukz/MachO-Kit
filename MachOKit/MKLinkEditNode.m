//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKLinkEditNode.m
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

#import "MKLinkEditNode.h"
#import "NSError+MK.h"
#import "MKMachO.h"
#import "MKMachO+Segments.h"
#import "MKSegment.h"

//----------------------------------------------------------------------------//
@implementation MKLinkEditNode

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithSize:(mk_vm_size_t)size offset:(mk_vm_offset_t)offset inImage:(MKMachOImage*)image error:(NSError**)error
{
    NSAssert([image isKindOfClass:MKMachOImage.class], @"The parent of this node must be an MKMachOImage.");
    mk_error_t err;
    
    // Make sure there is a __LINKEDIT segment.
    MKSegment *linkeditSegment = [image segmentsWithName:@SEG_LINKEDIT].firstObject;
    if (linkeditSegment == nil) {
        MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_ENOT_FOUND description:@"Image does not have a __LINKEDIT segment."];
        [self release]; return nil;
    }
    
    self = [super initWithParent:image error:error];
    if (self == nil) return nil;
    
    // Despite the image being our real parent node, all of our data should
    // be within the __LINKEDIT segment.  Thus, we use the memory map of the
    // __LINKEDIT segment for accessing the symbol table.
    _memoryMap = linkeditSegment.memoryMap;
    NSParameterAssert(_memoryMap);
    
    if (image.isFromMemoryDump)
    {
        if ((err = mk_vm_address_add(linkeditSegment.vmAddress, offset, &_nodeContextAddress))) {
            MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:err description:@"Arithmetic error %s while adding offset (%" MK_VM_PRIiOFFSET ") to __LINKEDIT vmAddress (0x%" MK_VM_PRIxADDR ")", mk_error_string(err), offset, linkeditSegment.vmAddress];
            [self release]; return nil;
        }
        
        if ((err = mk_vm_address_substract(_nodeContextAddress, linkeditSegment.fileOffset, &_nodeContextAddress))) {
            MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:err description:@"Arithmetic error %s while subtracting __LINKEDIT fileOffset (0x%" MK_VM_PRIxADDR ") from (0x%" MK_VM_PRIxADDR ")", mk_error_string(err), linkeditSegment.fileOffset, _nodeContextAddress];
            [self release]; return nil;
        }
        
        // Slide the context address.
        {
            mk_vm_offset_t slide = (mk_vm_offset_t)image.slide;
            
            if ((err = mk_vm_address_apply_offset(_nodeContextAddress, slide, &_nodeContextAddress))) {
                MK_ERROR_OUT = MK_MAKE_VM_ARITHMETIC_ERROR(err, _nodeContextAddress, slide);
                [self release]; return nil;
            }
        }
        
        _nodeVMAddress = _nodeContextAddress;
    }
    else
    {
        // TODO - Investigate whether this is the correct way.
        
        // Context Address
        if ((err = mk_vm_address_apply_offset(image.nodeContextAddress, offset, &_nodeContextAddress))) {
            MK_ERROR_OUT = MK_MAKE_VM_ARITHMETIC_ERROR(err, image.nodeContextAddress, offset);
            [self release]; return nil;
        }
        
        // VM Address
        if ((err = mk_vm_address_apply_offset(image.nodeVMAddress, offset, &_nodeVMAddress))) {
            MK_ERROR_OUT = MK_MAKE_VM_ARITHMETIC_ERROR(err, image.nodeContextAddress, offset);
            [self release]; return nil;
        }
    }
    
    _nodeSize = size;
    
    // Make sure the node data is available
    {
        NSError *localError = nil;
        
        if ([_memoryMap hasMappingAtOffset:0 fromAddress:_nodeContextAddress length:_nodeSize error:&localError] == NO) {
            MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_ENOT_FOUND underlyingError:localError description:@"%@ data does not exist at address 0x%" MK_VM_PRIxADDR " for image %@.", NSStringFromClass(self.class), _nodeContextAddress, image];
            [self release]; return nil;
        }
    }
    
    return self;
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@synthesize memoryMap = _memoryMap;
@synthesize nodeSize = _nodeSize;

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_address_t)nodeAddress:(MKNodeAddressType)type
{
    switch (type) {
        case MKNodeContextAddress:
            return _nodeContextAddress;
        case MKNodeVMAddress:
            return _nodeVMAddress;
        default:
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Unsupported node address type." userInfo:nil];
    }
}

@end
