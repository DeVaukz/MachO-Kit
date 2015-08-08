//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKSharedCache+Images.m
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

#import "MKSharedCache+Images.h"
#import "NSError+MK.h"
#import "MKDSCHeader.h"
#import "MKDSCImageInfo.h"

//----------------------------------------------------------------------------//
@implementation MKSharedCache (Images)

//|++++++++++++++++++++++++++++++++++++|//
- (NSArray*)imageInfos
{
    if (_imageInfos == nil)
    @autoreleasepool {
        uint32_t imageDescriptorCount = _header.imagesCount;
        
        NSMutableArray<MKDSCImageInfo*> *imageDescriptors = [[NSMutableArray alloc] initWithCapacity:imageDescriptorCount];
        mach_vm_offset_t offset = _header.imagesOffset;
        mach_vm_offset_t oldOffset;
        
        while (imageDescriptorCount--)
        @autoreleasepool {
                
            NSError *imageDescriptorError = nil;
                
            MKDSCImageInfo *idsc = [[MKDSCImageInfo alloc] initWithOffset:offset fromParent:self error:&imageDescriptorError];
            if (idsc == nil) {
                // If we fail to instantiate an instance of the MKDSCMappingInfo
                // it means we've walked off the end of memory that can be
                // mapped by our MKMemoryMap.
                MK_PUSH_UNDERLYING_WARNING(mappingInfos, imageDescriptorError, @"Failed to instantiate image info at index %" PRIi32 "", imageDescriptorCount - imageDescriptorCount);
                break;
            }
                
            oldOffset = offset;
            offset += idsc.nodeSize;
                
            [imageDescriptors addObject:idsc];
                
            // dyld doesn't care how many mappings are present in the shared
            // cache.  Neither do we, as long as there was not an overflow.
            if (oldOffset > offset) {
                MK_PUSH_WARNING(mappingInfos, MK_EOVERFLOW, @"Adding size of image info at index %" PRIi32 " to offset into mapping infos triggered an overflow.", imageDescriptorCount - imageDescriptorCount);
                break;
            }
        }
        
        _imageInfos = [imageDescriptors copy];
        [imageDescriptors release];
    }
    
    return _imageInfos;
}

@end
