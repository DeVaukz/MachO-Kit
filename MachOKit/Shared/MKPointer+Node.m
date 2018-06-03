//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKPointer+Node.m
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

#import "MKPointer+Node.h"
#import "MKInternal.h"
#import "MKMemoryMap+Pointer.h"

@implementation MKPointer (Node)

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithOffset:(mk_vm_offset_t)offset fromParent:(MKBackedNode*)parent context:(NSDictionary*)context error:(NSError**)error
{
    mk_vm_address_t address;
    NSError *memoryMapError = nil;
    
    address = [parent.memoryMap readPointerAtOffset:offset fromAddress:parent.nodeContextAddress withDataModel:parent.dataModel error:&memoryMapError];
    
    if (memoryMapError) {
        MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_EINTERNAL_ERROR underlyingError:memoryMapError description:@"Could not read pointer value."];
        [self release]; return nil;
    }
    
    return [self initWithAddress:address node:parent context:context error:error];
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithOffset:(mk_vm_offset_t)offset fromParent:(MKBackedNode*)parent targetClass:(Class)targetClass error:(NSError**)error
{
    NSDictionary *context = nil;
    
    if (targetClass) {
        context = @{
            MKInitializationContextTargetClass: targetClass
        };
    }
    
    return [self initWithOffset:offset fromParent:parent context:context error:error];
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithOffset:(mk_vm_offset_t)offset fromParent:(MKBackedNode*)parent error:(NSError**)error
{ return [self initWithOffset:offset fromParent:parent targetClass:nil error:error]; }

@end
