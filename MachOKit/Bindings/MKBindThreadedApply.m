//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKBindThreadedApply.m
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

#import "MKBindThreadedApply.h"
#import "MKInternal.h"
#import "MKSegment.h"

//----------------------------------------------------------------------------//
@implementation MKBindThreadedApply

//|++++++++++++++++++++++++++++++++++++|//
+ (uint8_t)subopcode
{ return BIND_SUBOPCODE_THREADED_APPLY; }

//|++++++++++++++++++++++++++++++++++++|//
+ (NSString*)name
{ return @"BIND_SUBOPCODE_THREADED_APPLY"; }

//|++++++++++++++++++++++++++++++++++++|//
+ (uint32_t)canInstantiateWithOpcode:(uint8_t)opcode immediate:(uint8_t)immediate
{
    if (self != MKBindThreadedApply.class)
        return 0;
    
    return (opcode == [self opcode] && immediate == [self subopcode]) ? 10 : 0;
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Performing Binding
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (BOOL)bind:(void (^)(void))binder withContext:(struct MKBindContext*)bindContext error:(NSError**)error
{
    id<MKDataModel> dataModel = self.dataModel;
    NSAssert(dataModel != nil, @"Missing datamodel");
    
    // Threaded bind opcodes should only appear in 64-bit binaries
    size_t pointerSize = dataModel.pointerSize;
    if (pointerSize != 8) {
        MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_EUNAVAILABLE description:@"Unsupported pointer size [%zu].", pointerSize];
        return NO;
    }
    
    MKSegment *segment = bindContext->segment;
    if (segment == nil) {
        MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_ENOT_FOUND description:@"No segment set."];
        return NO;
    }
    
    mk_error_t err;
    mk_vm_address_t segmentAddress = segment.vmAddress;
    mk_vm_range_t segmentRange = mk_vm_range_make(segmentAddress, segment.vmSize);
    
    uint64_t delta = 0;
    do {
        bindContext->derivedOffset = bindContext->segmentOffset;
        
        // Verify that the offset location is within the segment
        if ((err = mk_vm_range_contains_address(segmentRange, bindContext->derivedOffset, segmentAddress))) {
            MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_EOUT_OF_RANGE description:@"The offset [%" MK_VM_PRIuOFFSET "] is not within %@ segement (index %u).", bindContext->derivedOffset, bindContext->segment, bindContext->segmentIndex];
            return NO;
        }
        
        NSError *memoryMapError = nil;
        uint64_t value;
        
        if ([segment.memoryMap copyBytesAtOffset:bindContext->derivedOffset fromAddress:segment.nodeContextAddress into:&value length:sizeof(value) requireFull:YES error:&memoryMapError] < sizeof(value)) {
            MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_EINTERNAL_ERROR underlyingError:memoryMapError description:@"Could not read value at offset [%" MK_VM_PRIuOFFSET "] in %@ segment.", bindContext->derivedOffset, segment.description];
            return NO;
        }
        
        bindContext->threadedBindValue.raw = MKSwapLValue64(value, dataModel);
        
        // Need to preserve the original 'type' to match the dyld behavior
        uint8_t savedType = bindContext->type;
        bindContext->type = bindContext->threadedBindValue.isBind ? BIND_TYPE_THREADED_BIND : BIND_TYPE_THREADED_REBASE;
        
        binder();
        
        // Restore the previous 'type'
        bindContext->type = savedType;
        
        delta = bindContext->threadedBindValue.delta * dataModel.pointerSize;
        if ((err = mk_vm_offset_add(bindContext->segmentOffset, delta, &bindContext->segmentOffset))) {
            MK_ERROR_OUT = MK_MAKE_VM_OFFSET_ADD_ARITHMETIC_ERROR(err, bindContext->segmentOffset, delta);
            return NO;
        }
        
    } while (delta != 0);
    
    return YES;
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_size_t)nodeSize
{ return 1; }

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  NSObject
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (NSString*)description
{ return self.class.name; }

@end
