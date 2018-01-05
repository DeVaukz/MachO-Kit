//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKLEB.m
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

#import "MKLEB.h"
#import "MKInternal.h"

#include "_mach_trie.h"

//|++++++++++++++++++++++++++++++++++++|//
static bool
MKLEBRead(bool isSLEB, MKBackedNode *node, mk_vm_offset_t offset, void *LEBValue, size_t *ULEBSize, NSError **error)
{
    NSCParameterAssert(node != nil);
    
    mk_error_t err;
    mk_vm_address_t address;
    
    if ((err = mk_vm_address_apply_offset(node.nodeContextAddress, offset, &address))) {
        MK_ERROR_OUT = MK_MAKE_VM_ADDRESS_APPLY_OFFSET_ARITHMETIC_ERROR(err, node.nodeContextAddress, offset);
        return false;
    }
	
	MKBackedNode *boundingNode = node;
	mk_vm_size_t maxLength = boundingNode.nodeSize;
	
    // If the node size is less than the offset, then the node is *probably*
    // initializing and is dependent on knowing the size of this LEB to
    // compute its own size. Hop up a level and use the node's parent to
    // compute a rough max size.
	if (maxLength <= offset)
	{
		mk_vm_range_t boundingRange;
		
		while (boundingNode != nil) {
			boundingRange = mk_vm_range_make(boundingNode.nodeContextAddress, boundingNode.nodeSize);
			
			if (mk_vm_range_contains_address(boundingRange, 0, address) == MK_ESUCCESS)
				break;
			
			boundingNode = (MKBackedNode*)boundingNode.parent;
			if (![boundingNode isKindOfClass:MKBackedNode.class])
				boundingNode = nil;
		}
		
		if (boundingNode) {
			// Compute the offset of 'address' into the bounding range and subtract that
			// from 'maxLength'.
			//
			// SAFE - 'address' is within the bounding range.
			maxLength = boundingRange.length - (address - boundingRange.location);
		} else {
			// Fallback
			boundingNode = nil;
			maxLength = MK_VM_SIZE_MAX;
		}
	}
    
    __block boolean_t success = false;
    
    [node.memoryMap remapBytesAtOffset:0 fromAddress:address length:maxLength requireFull:NO withHandler:^(vm_address_t address, vm_size_t length, NSError *e) {
        if (length == 0x0) { MK_ERROR_OUT = e; return; }
        
        mk_error_t err;
        uint8_t *start = (uint8_t*)address;
        uint8_t *end = (uint8_t*)(address + length);
		
		if (isSLEB) {
			if ((err = _mk_mach_trie_copy_sleb128(start, end, LEBValue, ULEBSize))) {
				MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:err description:@"Invalid sleb128 (err = %s).", mk_error_string(err)];
				return;
			}
		} else {
			if ((err = _mk_mach_trie_copy_uleb128(start, end, LEBValue, ULEBSize))) {
				MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:err description:@"Invalid uleb128 (err = %s).", mk_error_string(err)];
				return;
			}
		}
        
        success = true;
    }];
    
    return success;
}

//|++++++++++++++++++++++++++++++++++++|//
bool
MKULEBRead(MKBackedNode *node, mk_vm_offset_t offset, uint64_t *ULEBValue, size_t *ULEBSize, NSError **error)
{ return MKLEBRead(false, node, offset, ULEBValue, ULEBSize, error); }

//|++++++++++++++++++++++++++++++++++++|//
bool
MKSLEBRead(MKBackedNode *node, mk_vm_offset_t offset, int64_t *ULEBValue, size_t *ULEBSize, NSError **error)
{ return MKLEBRead(true, node, offset, ULEBValue, ULEBSize, error); }
