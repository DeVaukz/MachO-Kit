//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       MKSharedCache.h
//!
//! @author     D.V.
//! @copyright  Copyright (c) 2014-2015 D.V. All rights reserved.
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

#include <MachOKit/macho.h>
#import <Foundation/Foundation.h>

#import <MachOKit/MKNode+SharedCache.h>
#import <MachOKit/MKBackedNode.h>

@class MKDSCHeader;
@class MKDSCMappingInfo;
@class MKDSCMapping;
@class MKDSCImagesInfo;
@class MKDSCSlideInfo;
@class MKDSCLocalSymbols;

NS_ASSUME_NONNULL_BEGIN

//----------------------------------------------------------------------------//
//! @name       Shared Cache Options
//! @relates    MKSharedCacheFlags
//
typedef NS_OPTIONS(NSUInteger, MKSharedCacheFlags) {
    //! The mapped shared cache is from a \c dyld_shared_cache_[arch] file
    //! on disk.  This option is mutually excludive with
    //! \ref MKSharedCacheFromVM.
    MKSharedCacheFromSourceFile                 = 0x1,
    //! The mapped shared cache is from process memory or a memory dump,
    //! and has been loaded by dyld.  This option is mutually exclusive with
    //! \ref MKSharedCacheFromSourceFile.
    MKSharedCacheFromVM                         = 0x2,
};



//----------------------------------------------------------------------------//
@interface MKSharedCache : MKBackedNode {
@package
    MKMemoryMap *_memoryMap;
    MKDataModel* _dataModel;
    MKSharedCacheFlags _flags;
    NSUInteger _version;
    cpu_type_t _cpuType;
    cpu_subtype_t _cpuSubtype;
    // Address //
    mk_vm_address_t _contextAddress;
    mk_vm_address_t _vmAddress;
    mk_vm_slide_t _slide;
    // Header //
    MKDSCHeader *_header;
    // Mappings //
    NSArray<MKDSCMappingInfo*> *_mappingInfos;
    NSArray<MKDSCMapping*> *_mappings;
    // Images //
    MKDSCImagesInfo *_imagesInfo;
    // Slide //
    MKDSCSlideInfo *_slideInfo;
    // Symbols //
    MKDSCLocalSymbols *_localSymbols;
}

//! 
- (nullable instancetype)initWithFlags:(MKSharedCacheFlags)flags atAddress:(mk_vm_address_t)contextAddress inMapping:(MKMemoryMap*)memoryMap error:(NSError**)error NS_DESIGNATED_INITIALIZER;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Getting Shared Cache Metadata
//! @name       Getting Shared Cache Metadata
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//! Returns \c YES if the Shared Cache was initialized with a
//! \c dyld_shared_cache_[arch] file from disk.
@property (nonatomic, readonly) BOOL isSourceFile;
//! The dervided slide value for the shared cache.
@property (nonatomic, readonly) mk_vm_slide_t slide;

//!
@property (nonatomic, readonly) NSUInteger version;
//!
@property (nonatomic, readonly) cpu_type_t cpuType;
//!
@property (nonatomic, readonly) cpu_subtype_t cpuSubtype;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Header and Mappings
//! @name       Header and Mappings
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//!
@property (nonatomic, readonly) MKDSCHeader *header;

//!
@property (nonatomic, readonly) NSArray<MKDSCMappingInfo*> *mappingInfos;

//!
@property (nonatomic, readonly) NSArray<MKDSCMapping*> *mappings;

@end

NS_ASSUME_NONNULL_END
