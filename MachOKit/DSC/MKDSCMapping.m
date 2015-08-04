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

@synthesize mappingInfo = _mappingInfo;
@synthesize vmAddress = _vmAddress;
@synthesize vmSize = _vmSize;
@synthesize fileOffset = _fileOffset;
@synthesize maximumProtection = _maximumProtection;
@synthesize initialProtection = _initialProtection;

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithDescriptor:(MKDSCMappingInfo*)descriptor error:(NSError**)error
{
    NSParameterAssert(descriptor);
    mk_error_t err;
    
    MKSharedCache *sharedCache = descriptor.sharedCache;
    NSParameterAssert(sharedCache);
    
    self = [super initWithParent:sharedCache error:error];
    if (self == nil) return nil;
    
    _descriptor = [descriptor retain];
    
    _vmAddress = descriptor.address;
    _vmSize = descriptor.size;
    _fileOffset = descriptor.fileOffset;
    _maximumProtection = descriptor.maxProt;
    _initialProtection = descriptor.initProt;
    
    if (sharedCache.isSourceFile)
    {
        if ((err = mk_vm_address_apply_offset(sharedCache.nodeContextAddress, _fileOffset, &_contextAddress))) {
            MK_ERROR_OUT = MK_MAKE_VM_ARITHMETIC_ERROR(err, sharedCache.nodeContextAddress, _fileOffset);
            [self release]; return nil;
        }
    }
    else
    {
        _contextAddress = _vmAddress;
    }
    
    // Verify that applying the slide would not trigger an arithmetic error.
    {
        mk_vm_slide_t slide = sharedCache.slide;
        
        if ((err = mk_vm_address_apply_slide(_vmAddress, slide, NULL))) {
            MK_ERROR_OUT = MK_MAKE_VM_ARITHMETIC_ERROR(err, _vmAddress, slide);
            [self release]; return nil;
        }
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
        MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_ENOT_FOUND description:@"Region data does not exist in memory map for %@", sharedCache];
        [self release]; return nil;
    }
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithParent:(MKNode*)parent error:(NSError**)error
{
    NSAssert([parent isKindOfClass:MKDSCMappingInfo.class], @"");
    return [self initWithDescriptor:(id)parent error:error];
}

//|++++++++++++++++++++++++++++++++++++|//
- (void)dealloc
{
    [_descriptor release];
    [super dealloc];
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
        [MKNodeField nodeFieldWithProperty:MK_PROPERTY(fileOffset) description:@"File offset"],
        [MKNodeField nodeFieldWithProperty:MK_PROPERTY(vmAddress) description:@"VM Address"],
        [MKNodeField nodeFieldWithProperty:MK_PROPERTY(vmSize) description:@"VM Size"],
        [MKNodeField nodeFieldWithProperty:MK_PROPERTY(maximumProtection) description:@"Maximum VM Protection"],
        [MKNodeField nodeFieldWithProperty:MK_PROPERTY(initialProtection) description:@"Initial VM Protection"]
    ]];
}

@end
