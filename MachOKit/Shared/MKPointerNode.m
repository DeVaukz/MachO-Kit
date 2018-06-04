//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKPointerNode.m
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

#import "MKPointerNode.h"
#import "MKInternal.h"
#import "MKMemoryMap+Pointer.h"
#import "MKPtr.h"

#define mk_ptr_struct(OBJ)    ((struct MKPtr*)(&(OBJ->_parent)))

//----------------------------------------------------------------------------//
@implementation MKPointerNode

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithOffset:(mk_vm_offset_t)offset fromParent:(MKBackedNode*)parent context:(NSDictionary*)context error:(NSError**)error
{
    self = [super initWithOffset:offset fromParent:parent error:error];
    if (self == nil) return nil;
    
    mk_vm_address_t address;
    NSError *memoryMapError = nil;
    
    address = [self.memoryMap readPointerAtOffset:0 fromAddress:self.nodeContextAddress withDataModel:self.dataModel error:&memoryMapError];
    
    if (memoryMapError) {
        MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_EINTERNAL_ERROR underlyingError:memoryMapError description:@"Could not read pointer value."];
        [self release]; return nil;
    }
    
    if (MKPtrInitialize(mk_ptr_struct(self), parent, address, context, error) == false) {
        [self release]; return nil;
    }
    
    return self;
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

//|++++++++++++++++++++++++++++++++++++|//
- (void)dealloc
{
    MKPtrDestory(mk_ptr_struct(self));
    
    [super dealloc];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Pointer Values
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@synthesize address = _address;

//|++++++++++++++++++++++++++++++++++++|//
- (Class)targetClass
{ return MKPtrTargetClass(mk_ptr_struct(self)); }

//|++++++++++++++++++++++++++++++++++++|//
- (MKOptional*)pointee
{ return MKPtrPointee(mk_ptr_struct(self)); }

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_size_t)nodeSize
{ return self.dataModel.pointerSize; }

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    MKNodeFieldBuilder *address = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(address)
        type:MKNodeFieldTypeAddress.sharedInstance
        offset:0
        size:self.dataModel.pointerSize
    ];
    address.description = @"Pointer";
    address.options = MKNodeFieldOptionDisplayAsDetail;
    address.alternateFieldName = MK_PROPERTY(pointee);
    
    MKNodeFieldBuilder *pointee = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(pointee)
        type:(self.targetClass ? [MKNodeFieldTypeNode typeWithNodeType:self.targetClass] : nil)
    ];
    pointee.description = @"Pointee";
    pointee.options = MKNodeFieldOptionHidden;
    
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        address.build,
        pointee.build
    ]];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  NSObject
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (NSString*)description
{
    MKBackedNode *pointee = self.pointee.value;
    if (pointee)
        return [NSString stringWithFormat:@"0x%" MK_VM_PRIxADDR " -> %@", self.nodeVMAddress, pointee.description];
    else if (self.address == 0)
        return [NSString stringWithFormat:@"0x%" MK_VM_PRIxADDR " -> NULL", self.nodeVMAddress];
    else
        return [NSString stringWithFormat:@"0x%" MK_VM_PRIxADDR " -> 0x%" MK_VM_PRIxADDR "", self.nodeVMAddress, self.address];
}

@end
