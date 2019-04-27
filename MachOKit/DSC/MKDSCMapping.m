//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKDSCMapping.m
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

#import "MKDSCMapping.h"
#import "NSError+MK.h"
#import "MKDSCMappingInfo.h"
#import "MKSharedCache.h"

//----------------------------------------------------------------------------//
@implementation MKDSCMapping

@synthesize vmAddress = _vmAddress;
@synthesize vmSize = _vmSize;
@synthesize fileOffset = _fileOffset;
@synthesize maximumProtection = _maximumProtection;
@synthesize initialProtection = _initialProtection;

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithSharedCache:(MKSharedCache*)sharedCache vmAddress:(mk_vm_address_t)vmAddress vmSize:(mk_vm_size_t)vmSize fileOffset:(mk_vm_offset_t)fileOffset initialProtection:(vm_prot_t)initialProtection maximumProtection:(vm_prot_t)maximumProtection error:(NSError**)error
{
    mk_error_t err;
    NSParameterAssert(sharedCache);
    
    self = [super initWithParent:sharedCache error:error];
    if (self == nil) return nil;
    
    _vmAddress = vmAddress;
    _vmSize = vmSize;
    _fileOffset = fileOffset;
    _maximumProtection = maximumProtection;
    _initialProtection = initialProtection;
    
    // contextAddress := vmAddress + slide - fileOffset
    mk_vm_slide_t slide = sharedCache.slide;
    
    if ((err = mk_vm_address_apply_slide(vmAddress, slide, &_contextAddress))) {
        MK_ERROR_OUT = MK_MAKE_VM_ADDRESS_APPLY_SLIDE_ARITHMETIC_ERROR(err, _contextAddress, slide);
        [self release]; return nil;
    }
    
    if ((err = mk_vm_address_subtract(_contextAddress, fileOffset, &_contextAddress))) {
        MK_ERROR_OUT = MK_MAKE_VM_ADDRESS_DEFFERENCE_ARITHMETIC_ERROR(err, _contextAddress, fileOffset);
        [self release]; return nil;
    }
    
    // dyld will refuse to load the shared cache if a region's fileOffset + size
    // is greater than the actual size of the shared cache file on disk.
    // We don't care however as long as adding the two does not trigger an
    // overflow.
    if ((err = mk_vm_address_check_length(_fileOffset, _vmSize))) {
        MK_ERROR_OUT = MK_MAKE_VM_LENGTH_CHECK_ERROR(err, _fileOffset, _vmSize);
        [self release]; return nil;
    }
    
    // Also check the vmAddress + vmSize for potential overflow.
    if ((err = mk_vm_address_check_length(_vmAddress, _vmSize))) {
        MK_ERROR_OUT = MK_MAKE_VM_LENGTH_CHECK_ERROR(err, _vmAddress, _vmSize);
        [self release]; return nil;
    }
    
    // Make sure the region data is actually available
    if ([sharedCache.memoryMap hasMappingAtOffset:0 fromAddress:_contextAddress length:_vmSize] == NO) {
        MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_ENOT_FOUND description:@"Complete mapping does not exist at context-relative address %" MK_VM_PRIxADDR ".", _contextAddress];
        [self release]; return nil;
    }
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithDescriptor:(MKDSCMappingInfo*)descriptor error:(NSError**)error
{
    NSParameterAssert(descriptor);
    MKSharedCache *sharedCache = descriptor.sharedCache;
    
    return [self initWithSharedCache:sharedCache vmAddress:descriptor.address vmSize:descriptor.size fileOffset:descriptor.fileOffset initialProtection:descriptor.initProt maximumProtection:descriptor.maxProt error:error];
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithParent:(MKNode*)parent error:(NSError**)error
{
    NSAssert([parent isKindOfClass:MKDSCMappingInfo.class], @"Parent must be a MKDSCMappingInfo.");
    return [self initWithDescriptor:(id)parent error:error];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_size_t)nodeSize
{ return _vmSize; }

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_address_t)nodeAddress:(MKNodeAddressType)type
{
    switch (type) {
        case MKNodeContextAddress:
            return _contextAddress;
            break;
        case MKNodeVMAddress:
            return _vmAddress;
            break;
        default:
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Unsupported node address type." userInfo:nil];
    }
}

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        [MKFormattedNodeField fieldWithProperty:MK_PROPERTY(fileOffset) description:@"File offset" format:MKNodeFieldFormatOffset],
        [MKFormattedNodeField fieldWithProperty:MK_PROPERTY(vmAddress) description:@"VM Address" format:MKNodeFieldFormatAddress],
        [MKFormattedNodeField fieldWithProperty:MK_PROPERTY(vmSize) description:@"VM Size" format:MKNodeFieldFormatSize],
        [MKFormattedNodeField fieldWithProperty:MK_PROPERTY(maximumProtection) description:@"Maximum VM Protection" format:MKNodeFieldFormatHexCompact],
        [MKFormattedNodeField fieldWithProperty:MK_PROPERTY(initialProtection) description:@"Initial VM Protection" format:MKNodeFieldFormatHexCompact]
    ]];
}

@end
