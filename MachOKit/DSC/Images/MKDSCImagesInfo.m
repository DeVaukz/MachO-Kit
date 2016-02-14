//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKDSCImagesInfo.m
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

#import "MKDSCImagesInfo.h"
#import "NSError+MK.h"
#import "MKSharedCache.h"
#import "MKDSCHeader.h"
#import "MKDSCImage.h"

#include "dyld_cache_format.h"

//----------------------------------------------------------------------------//
@implementation MKDSCImagesInfo

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithSharedCache:(MKSharedCache*)sharedCache error:(NSError**)error
{
    NSParameterAssert(sharedCache);
    mk_error_t err;
    
    self = [super initWithParent:sharedCache error:error];
    if (self == nil) return nil;
    
    mk_vm_address_t sharedCacheAddress = sharedCache.nodeContextAddress;
    mk_vm_address_t sharedCacheVMAddress = sharedCache.nodeVMAddress;
    mk_vm_offset_t imagesInfoOffset = sharedCache.header.imagesOffset;
    uint32_t imagesCount = sharedCache.header.imagesCount;
    
    if ((err = mk_vm_address_apply_offset(sharedCacheAddress, imagesInfoOffset, &_contextAddress))) {
        MK_ERROR_OUT = MK_MAKE_VM_ADDRESS_APPLY_OFFSET_ARITHMETIC_ERROR(err, sharedCacheAddress, imagesInfoOffset);
        [self release]; return nil;
    }
    
    if ((err = mk_vm_address_apply_offset(sharedCacheVMAddress, imagesInfoOffset, &_vmAddress))) {
        MK_ERROR_OUT = MK_MAKE_VM_ADDRESS_APPLY_OFFSET_ARITHMETIC_ERROR(err, sharedCacheVMAddress, imagesInfoOffset);
        [self release]; return nil;
    }
    
    _size = imagesCount * sizeof(struct dyld_cache_image_info);
    
    // Load image descriptors
    {
        uint32_t imageDescriptorCount = imagesCount;
        
        NSMutableArray<MKDSCImage*> *images = [[NSMutableArray alloc] initWithCapacity:imageDescriptorCount];
        
        mach_vm_offset_t offset = imagesInfoOffset;
        mach_vm_offset_t oldOffset;
        
        while (imageDescriptorCount--)
        @autoreleasepool {
                
            NSError *e = nil;
                
            MKDSCImage *image = [[MKDSCImage alloc] initWithOffset:offset fromParent:self error:&e];
            if (image == nil) {
                // If we fail to instantiate an instance of the MKDSCImage
                // it means we've walked off the end of memory that can be
                // mapped by our MKMemoryMap.
                MK_PUSH_UNDERLYING_WARNING(images, e, @"Failed to load image descriptor at index %" PRIu32 ".", imagesCount - imageDescriptorCount);
                break;
            }
                
            oldOffset = offset;
            offset += image.nodeSize;
                
            [images addObject:image];
            [image release];
            
            if (oldOffset > offset) {
                MK_PUSH_WARNING(images, MK_EOVERFLOW, @"Encountered an overflow while advancing the parser to the image descriptor following index %" PRIu32 ".", imagesCount - imageDescriptorCount);
                break;
            }
        }
        
        _images = [images copy];
        [images release];
    }

    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithParent:(MKNode*)parent error:(NSError**)error
{ return [self initWithSharedCache:parent.sharedCache error:error]; }

//|++++++++++++++++++++++++++++++++++++|//
- (void)dealloc
{
    [_images release];
    
    [super dealloc];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Images
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@synthesize images = _images;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@synthesize nodeSize = _size;

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_address_t)nodeAddress:(MKNodeAddressType)type
{
    switch (type) {
        case MKNodeContextAddress:
            return _contextAddress;
        case MKNodeVMAddress:
            return _vmAddress;
        default:
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Unsupported node address type." userInfo:nil];
    }
}

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        [MKNodeField nodeFieldWithProperty:MK_PROPERTY(images) description:@"Images"]
    ]];
}

@end
