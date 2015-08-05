//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKSharedCache.m
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

#import "MKSharedCache.h"
#import "NSError+MK.h"
#import "MKDSCHeader.h"
#import "MKDSCMappingInfo.h"
#import "MKDSCMapping.h"
#import "MKDSCImageInfo.h"

#include <objc/runtime.h>
#include <mach/shared_region.h>

//----------------------------------------------------------------------------//
@implementation MKSharedCache

//|++++++++++++++++++++++++++++++++++++|//
- (nullable instancetype)initWithFlags:(MKSharedCacheFlags)flags atAddress:(mk_vm_address_t)contextAddress inMapping:(MKMemoryMap*)mapping error:(NSError**)error
{
    NSParameterAssert(mapping);
    
    mk_error_t err;
    NSError *localError = nil;
    mk_vm_address_t sharedRegionBase;
    
    self = [super initWithParent:nil error:error];
    if (self == nil) return nil;
    
    _memoryMap = [mapping retain];
    _contextAddress = contextAddress;
    
    // Read the Magic
    {
        char magic[17] = {0};
        if (![mapping copyBytesAtOffset:0 fromAddress:contextAddress into:magic length:sizeof(magic) requireFull:YES error:error])
        { [self release]; return nil; }
        
        // First 4 bytes must == 'dyld'
        if (strncmp(&magic[0], "dyld", 4)) {
            MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_EINVAL description:@"Unknown Shared Cache magic: %s", magic];
            [self release]; return nil;
        }
        
        // TODO - Support parsing shared cache v0.
        if (strncmp(&magic[5], "v1", 2)) {
            MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_EINVAL description:@"Unknown Shared Cache version: %s", magic];
            [self release]; return nil;
        }
        
        _version = 1;
        
        // Architecture
        if (strcmp(magic, "dyld_v1    i386") == 0) {
            _dataModel = [[MKILP32DataModel sharedDataModel] retain];
            _cpuType = CPU_TYPE_I386;
            _cpuSubtype = CPU_SUBTYPE_I386_ALL;
            sharedRegionBase = SHARED_REGION_BASE_I386;
        } else if (strcmp(magic, "dyld_v1 x86_64h") == 0) {
            _dataModel = [[MKLP64DataModel sharedDataModel] retain];
            _cpuType = CPU_TYPE_X86_64;
            _cpuSubtype = CPU_SUBTYPE_X86_64_H;
            sharedRegionBase = SHARED_REGION_BASE_X86_64;
        } else if (strcmp(magic, "dyld_v1  x86_64") == 0) {
            _dataModel = [[MKLP64DataModel sharedDataModel] retain];
            _cpuType = CPU_TYPE_X86_64;
            _cpuSubtype = CPU_SUBTYPE_X86_64_ALL;
            sharedRegionBase = SHARED_REGION_BASE_X86_64;
        } else if (strcmp(magic, "dyld_v1   arm64") == 0) {
            _dataModel = [[MKLP64DataModel sharedDataModel] retain];
            _cpuType = CPU_TYPE_ARM64;
            _cpuSubtype = CPU_SUBTYPE_ARM64_ALL;
            sharedRegionBase = SHARED_REGION_BASE_ARM64;
        } else if (strcmp(magic, "dyld_v1  armv7s") == 0) {
            _dataModel = [[MKILP32DataModel sharedDataModel] retain];
            _cpuType = CPU_TYPE_ARM;
            _cpuSubtype = CPU_SUBTYPE_ARM_V7S;
            sharedRegionBase = SHARED_REGION_BASE_ARM;
        } else if (strcmp(magic, "dyld_v1  armv7k") == 0) {
            _dataModel = [[MKILP32DataModel sharedDataModel] retain];
            _cpuType = CPU_TYPE_ARM;
            _cpuSubtype = CPU_SUBTYPE_ARM_V7K;
            sharedRegionBase = SHARED_REGION_BASE_ARM;
        } else if (strcmp(magic, "dyld_v1  armv7f") == 0) {
            _dataModel = [[MKILP32DataModel sharedDataModel] retain];
            _cpuType = CPU_TYPE_ARM;
            _cpuSubtype = CPU_SUBTYPE_ARM_V7F;
            sharedRegionBase = SHARED_REGION_BASE_ARM;
        } else if (strcmp(magic, "dyld_v1   armv7") == 0) {
            _dataModel = [[MKILP32DataModel sharedDataModel] retain];
            _cpuType = CPU_TYPE_ARM;
            _cpuSubtype = CPU_SUBTYPE_ARM_V7;
            sharedRegionBase = SHARED_REGION_BASE_ARM;
        } else if (strcmp(magic, "dyld_v1   armv6") == 0) {
            _dataModel = [[MKILP32DataModel sharedDataModel] retain];
            _cpuType = CPU_TYPE_ARM;
            _cpuSubtype = CPU_SUBTYPE_ARM_V6;
            sharedRegionBase = SHARED_REGION_BASE_ARM;
        } else if (strcmp(magic, "dyld_v1   armv5") == 0) {
            _dataModel = [[MKILP32DataModel sharedDataModel] retain];
            _cpuType = CPU_TYPE_ARM;
            _cpuSubtype = CPU_SUBTYPE_ARM_ALL; //TODO - Find a better value
            sharedRegionBase = SHARED_REGION_BASE_ARM;
        } else {
            MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_EINVAL description:@"Unknown Shared Cache architecture: %s", magic];
            [self release]; return nil;
        }
    }
    
    // Can now parse the full header
    _header = [[MKDSCHeader alloc] initWithOffset:0 fromParent:self error:&localError];
    if (_header == nil) {
        MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:localError.code underlyingError:localError description:@"Failed to load shared cache header."];
        [self release]; return nil;
    }
    
    // Handle flags
    {
        // If neither the MKSharedCacheFromSourceFile or MKSharedCacheFromVM
        // were specified, attempt to detect whether we are parsing a
        // dyld_shared_cache_[arch] from disk.  The best heuristic is a
        // contextAddress of 0.
        if (!(flags & MKSharedCacheFromSourceFile) && !(flags & MKSharedCacheFromVM)) {
            if (contextAddress == 0)
                flags |= MKSharedCacheFromSourceFile;
            else
                flags |= MKSharedCacheFromVM;
        }
        
        _flags = flags;
    }
    
    // Parse mapping descriptors
    {
        uint32_t mappingDescriptorCount = _header.mappingCount;
        
        NSMutableArray<MKDSCMappingInfo*> *mappingDescriptors = [[NSMutableArray alloc] initWithCapacity:mappingDescriptorCount];
        mach_vm_offset_t offset = _header.mappingOffset;
        mach_vm_offset_t oldOffset;
        
        while (mappingDescriptorCount--)
        @autoreleasepool {
                
            NSError *mappingDescriptorError = nil;
            
            MKDSCMappingInfo *mdsc = [[MKDSCMappingInfo alloc] initWithOffset:offset fromParent:self error:&mappingDescriptorError];
            if (mdsc == nil) {
                // If we fail to instantiate an instance of the MKDSCMappingInfo
                // it means we've walked off the end of memory that can be
                // mapped by our MKMemoryMap.
                MK_PUSH_UNDERLYING_WARNING(mappingInfos, mappingDescriptorError, @"Failed to instantiate mapping info at index %" PRIi32 "", _header.mappingCount - mappingDescriptorCount);
                break;
            }
            
            oldOffset = offset;
            offset += mdsc.nodeSize;
            
            [mappingDescriptors addObject:mdsc];
            
            // dyld doesn't care how many mappings are present in the shared
            // cache.  Neither do we, as long as there was not an overflow.
            if (oldOffset > offset) {
                MK_PUSH_WARNING(mappingInfos, MK_EOVERFLOW, @"Adding size of mapping info at index %" PRIi32 " to offset into mapping infos triggered an overflow.", _header.mappingCount - mappingDescriptorCount);
                break;
            }
        }
        
        _mappingInfos = [mappingDescriptors copy];
        [mappingDescriptors release];
    }
    
    // We need at least the first mapping to be present to compute the slide
    // and vmAddress.
    if (_mappingInfos.count < 1) {
        MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_EINVAL underlyingError:localError description:@"Shared cache requires at least one mapping to be present."];
        [self release]; return nil;
    }
    
    mk_vm_address_t loadAddress = _mappingInfos[0].address;
    
    // Compute the slide
    //
    // dyld assumes an existing shared cache has been slide if the mapping
    // offset is >= than 72 (but it always is? sizeof(dyld_cache_header)
    // == 104?) and there is a slide info struct.
    if (_header.mappingOffset >= 0x48 && _header.slideInfoOffset != 0)
    {
        // Shared cache slide is the delta of the current context-relative
        // address of the first region, and the preferred address of the
        // first region.  dyld determines the preferred load address of the
        // first region by peeking at the shared cache file on disk.
        // We don't have that luxury.  Instead we use the hard coded values
        // from <mach/shared_region.h>.
        //
        // TODO - Provide an option to manually specify the slide.
        err = mk_vm_address_difference(loadAddress, sharedRegionBase, &_slide);
        if (err != MK_ESUCCESS) {
            MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:err description:@"Could not compute shared cache slide (" MK_VM_PRIxADDR " - " MK_VM_PRIxADDR ").", loadAddress, sharedRegionBase];
            [self release]; return nil;
        }
    }
    
    // vmAddress is the un-slid address of the first region
    if ((err = mk_vm_address_apply_slide(loadAddress, -1 * _slide, &_vmAddress))) {
        MK_ERROR_OUT = MK_MAKE_VM_ARITHMETIC_ERROR(err, loadAddress, _slide);
        [self release]; return nil;
    }
    
    // Load mappings
    {
        NSMutableArray<MKDSCMapping*> *mappings = [[NSMutableArray alloc] initWithCapacity:3];
        
        for (MKDSCMappingInfo *descriptor in _mappingInfos)
        {
            NSError *localError = nil;
            
            MKDSCMapping *mapping = [[MKDSCMapping alloc] initWithDescriptor:descriptor error:&localError];
            if (mapping == nil) {
                MK_PUSH_UNDERLYING_WARNING(segments, localError, @"Failed to create MKDSCMapping for descriptor %@", descriptor);
                continue;
            }
            
            [mappings addObject:mapping];
        }
        
        _mappings = [mappings copy];
        [mappings release];
    }
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithParent:(MKBackedNode*)parent error:(NSError**)error
{
    NSParameterAssert(parent);
    
    MKMemoryMap *mapping = parent.memoryMap;
    NSParameterAssert(mapping);
    
    self = [self initWithFlags:0 atAddress:0 inMapping:mapping error:error];
    if (!self) return nil;
    
    objc_storeWeak(&_parent, parent);
    
    return self;
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - Retrieving the Initialization Context
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@synthesize dataModel = _dataModel;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - Getting Shared Cache Metadata
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (BOOL)isSourceFile
{ return !!(_flags & MKSharedCacheFromSourceFile); }

@synthesize slide = _slide;

@synthesize version = _version;
@synthesize cpuType = _cpuType;
@synthesize cpuSubtype = _cpuSubtype;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - Header and Mappings
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@synthesize header = _header;
@synthesize mappingInfos = _mappingInfos;
@synthesize mappings = _mappings;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (MKMemoryMap*)memoryMap
{ return _memoryMap; }

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_size_t)nodeSize
{ return 0; }

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
        [MKNodeField nodeFieldWithProperty:MK_PROPERTY(slide) description:@"Slide"],
        [MKNodeField nodeFieldWithProperty:MK_PROPERTY(header) description:@"Shared Cache Header"],
        [MKNodeField nodeFieldWithProperty:MK_PROPERTY(mappingInfos) description:@"Mapping Descriptors"],
        [MKNodeField nodeFieldWithProperty:MK_PROPERTY(mappings) description:@"Mappings"],
        [MKNodeField nodeFieldWithProperty:MK_PROPERTY(imageInfos) description:@"Image Descriptors"],
    ]];
}

@end
