//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKPointer.m
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

#import "MKPointer.h"
#import "NSError+MK.h"

#import "MKPtr.h"

#define mk_ptr_struct(OBJ)    ((struct MKPtr*)(&(OBJ->_parent)))

//----------------------------------------------------------------------------//
@implementation MKPointer

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)init
{ @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"-init unavailable." userInfo:nil]; }

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithAddress:(mk_vm_address_t)address node:(MKBackedNode*)sourceNode context:(NSDictionary*)context error:(NSError**)error
{
    self = [super init];
    
    if (MKPtrInitialize(mk_ptr_struct(self), sourceNode, address, context, error) == false) {
        [self release]; return nil;
    }
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithOffset:(mk_vm_offset_t)offset fromParent:(MKBackedNode*)parent context:(NSDictionary*)context error:(NSError**)error
{
    mk_vm_address_t address;
    NSError *localError = nil;
    
    id<MKDataModel> dataModel = parent.dataModel;
    NSAssert(dataModel != nil, @"Parent node must have a data model.");
    
    if (dataModel.pointerSize == 8)
        address = [parent.memoryMap readQuadWordAtOffset:offset fromAddress:parent.nodeContextAddress withDataModel:dataModel error:&localError];
    else if (dataModel.pointerSize == 4)
        address = [parent.memoryMap readDoubleWordAtOffset:offset fromAddress:parent.nodeContextAddress withDataModel:dataModel error:&localError];
    else
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Unsupported pointer size." userInfo:nil];
    
    if (localError) {
        MK_ERROR_OUT = localError;
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

//|++++++++++++++++++++++++++++++++++++|//
- (void)dealloc
{
    MKPtrDestory(mk_ptr_struct(self));
    
    [super dealloc];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - Values
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_address_t)address
{ return _address; }

//|++++++++++++++++++++++++++++++++++++|//
- (Class)targetClass
{ return MKPtrTargetClass(mk_ptr_struct(self)); }

//|++++++++++++++++++++++++++++++++++++|//
- (MKOptional*)pointee
{ return MKPtrPointee(mk_ptr_struct(self)); }

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - NSObject
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (NSString*)description
{
    MKOptional *pointee = self.pointee;
    if (pointee.value)
        return [NSString stringWithFormat:@"-> %@", pointee];
    else
        return [NSString stringWithFormat:@"-> 0x%" MK_VM_PRIxADDR "", self.address];
}

@end
