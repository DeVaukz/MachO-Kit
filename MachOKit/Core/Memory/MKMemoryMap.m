//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKMemoryMap.m
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

#import "MKMemoryMap.h"
#import "MKInternal.h"
#import "_MKFileMemoryMap.h"
#import "_MKTaskMemoryMap.h"

//----------------------------------------------------------------------------//
@implementation MKMemoryMap

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)memoryMapWithContentsOfFile:(NSURL*)fileURL error:(NSError**)error
{ return [[[_MKFileMemoryMap alloc] initWithURL:fileURL error:error] autorelease]; }

#if TARGET_OS_MAC && !TARGET_OS_IPHONE
//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)memoryMapWithTask:(mach_port_t)task error:(NSError**)error
{ return [[[_MKTaskMemoryMap alloc] initWithTask:task error:error] autorelease]; }
#endif

//|++++++++++++++++++++++++++++++++++++|//
- (id)init
{
    if (self.class == MKMemoryMap.class)
        @throw [NSException exceptionWithName:NSGenericException reason:@"-init unavailable." userInfo:nil];
    else
        return [super init];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Accessing Context Memory
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_size_t)mappingSizeAtOffset:(mk_vm_offset_t)offset fromAddress:(mk_vm_address_t)contextAddress length:(mk_vm_size_t)length error:(NSError**)error
{
    __block mk_vm_size_t retValue = 0;
    
    [self remapBytesAtOffset:offset fromAddress:contextAddress length:length requireFull:NO withHandler:^(vm_address_t __unused address, vm_size_t l, __unused NSError *e) {
        MK_ERROR_OUT = e;
        retValue = l;
    }];
    
    return retValue;
}

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_size_t)mappingSizeAtOffset:(mk_vm_offset_t)offset fromAddress:(mk_vm_address_t)contextAddress length:(mk_vm_size_t)length
{ return [self mappingSizeAtOffset:offset fromAddress:contextAddress length:length error:NULL]; }

//|++++++++++++++++++++++++++++++++++++|//
- (BOOL)hasMappingAtOffset:(mk_vm_offset_t)offset fromAddress:(mk_vm_address_t)contextAddress length:(mk_vm_size_t)length error:(NSError**)error
{
    __block BOOL retValue = NO;
    
    [self remapBytesAtOffset:offset fromAddress:contextAddress length:length requireFull:NO withHandler:^(vm_address_t __unused address, vm_size_t l, NSError *e) {
        MK_ERROR_OUT = e;
        retValue = (l >= length);
    }];
    
    return retValue;
}

//|++++++++++++++++++++++++++++++++++++|//
- (BOOL)hasMappingAtOffset:(mk_vm_offset_t)offset fromAddress:(mk_vm_address_t)contextAddress length:(mk_vm_size_t)length
{ return [self hasMappingAtOffset:offset fromAddress:contextAddress length:length error:NULL]; }

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Accessing Context Memory
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (void)remapBytesAtOffset:(mk_vm_offset_t)offset fromAddress:(mk_vm_address_t)contextAddress length:(mk_vm_size_t)length requireFull:(BOOL)requireFull withHandler:(void (^)(vm_address_t address, vm_size_t length, NSError *error))handler
{
#pragma unused (offset)
#pragma unused (contextAddress)
#pragma unused (length)
#pragma unused (requireFull)
#pragma unused (handler)
	@throw [NSException exceptionWithName:NSGenericException reason:@"Subclasses must implement -remapBytesAtOffset:fromAddress:length:requireFull:withHandler:." userInfo:nil];
}

//|++++++++++++++++++++++++++++++++++++|//
- (NSData*)dataAtOffset:(mk_vm_offset_t)offset fromAddress:(mk_vm_address_t)contextAddress length:(mk_vm_size_t)length requireFull:(BOOL)requireFull error:(NSError**)error
{
    __block NSData *retValue = nil;
    __block NSError *localError = nil;
    
    [self remapBytesAtOffset:offset fromAddress:contextAddress length:length requireFull:requireFull withHandler:^(vm_address_t address, vm_size_t length, NSError *error) {
        localError = error;
        if (error)
            return;
        
        retValue = [[NSData alloc] initWithBytes:(void*)address length:length];
    }];
    
    MK_ERROR_OUT = localError;
    return [retValue autorelease];
}

//|++++++++++++++++++++++++++++++++++++|//
- (vm_size_t)copyBytesAtOffset:(mk_vm_offset_t)offset fromAddress:(mk_vm_address_t)contextAddress into:(void*)buffer length:(mk_vm_size_t)length requireFull:(BOOL)requireFull error:(NSError**)error
{
    __block vm_size_t retValue;
    __block NSError *localError;
    
    [self remapBytesAtOffset:offset fromAddress:contextAddress length:length requireFull:requireFull withHandler:^(vm_address_t address, vm_size_t mappingLength, NSError *error) {
        localError = error;
        if (error)
            return;
        
        memcpy(buffer, (void*)address, (vm_size_t)MIN(length, (mk_vm_size_t)mappingLength));
        retValue = (vm_size_t)length;
    }];
    
    MK_ERROR_OUT = localError;
    return retValue;
}

//|++++++++++++++++++++++++++++++++++++|//
- (uint8_t)readByteAtOffset:(mk_vm_offset_t)offset fromAddress:(mk_vm_address_t)contextAddress withDataModel:(id<MKDataModel>)dataModel error:(NSError**)error
{
#pragma unused (dataModel)
    
    uint8_t retValue;
    mach_vm_size_t readSize;
    
    readSize = [self copyBytesAtOffset:offset fromAddress:contextAddress into:&retValue length:sizeof(uint8_t) requireFull:YES error:error];
    if (readSize < sizeof(uint8_t))
        return 0;
    
    return retValue;
}

//|++++++++++++++++++++++++++++++++++++|//
- (uint16_t)readWordAtOffset:(mk_vm_offset_t)offset fromAddress:(mk_vm_address_t)contextAddress withDataModel:(id<MKDataModel>)dataModel error:(NSError**)error
{
    uint16_t retValue;
    mach_vm_size_t readSize;
    
    readSize = [self copyBytesAtOffset:offset fromAddress:contextAddress into:&retValue length:sizeof(uint16_t) requireFull:YES error:error];
    if (readSize < sizeof(uint16_t))
        return 0;
    
    if (dataModel.byteOrder)
        return dataModel.byteOrder->swap16( retValue );
    else
        return retValue;
}

//|++++++++++++++++++++++++++++++++++++|//
- (uint32_t)readDoubleWordAtOffset:(mk_vm_offset_t)offset fromAddress:(mk_vm_address_t)contextAddress withDataModel:(id<MKDataModel>)dataModel error:(NSError**)error
{
    uint32_t retValue;
    mach_vm_size_t readSize;
    
    readSize = [self copyBytesAtOffset:offset fromAddress:contextAddress into:&retValue length:sizeof(uint32_t) requireFull:YES error:error];
    if (readSize < sizeof(uint32_t))
        return 0;
    
    if (dataModel.byteOrder)
        return dataModel.byteOrder->swap32( retValue );
    else
        return retValue;
}

//|++++++++++++++++++++++++++++++++++++|//
- (uint64_t)readQuadWordAtOffset:(mk_vm_offset_t)offset fromAddress:(mk_vm_address_t)contextAddress withDataModel:(id<MKDataModel>)dataModel error:(NSError**)error
{
    uint64_t retValue;
    mach_vm_size_t readSize;
    
    readSize = [self copyBytesAtOffset:offset fromAddress:contextAddress into:&retValue length:sizeof(uint64_t) requireFull:YES error:error];
    if (readSize < sizeof(uint64_t))
        return 0;
    
    if (dataModel.byteOrder)
        return dataModel.byteOrder->swap64( retValue );
    else
        return retValue;
}

@end
