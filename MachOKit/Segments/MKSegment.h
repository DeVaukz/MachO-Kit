//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       MKSegment.h
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
@import Foundation;

#import <MachOKit/MKBackedNode.h>
#import <MachOKit/MKMachOFieldType.h>
#import <MachOKit/MKLCSegment.h>
#import <MachOKit/MKSection.h>

@class MKMachOImage;

NS_ASSUME_NONNULL_BEGIN

//----------------------------------------------------------------------------//
//! An instance of \c MKSegment represents a contiguous range of memory mapped
//! from the binary into memory when the Mach-O is loaded.  Each segment is
//! identified by an instance of \ref MKLCSegment or \ref MKLCSegment64 in
//! the load commands.
//
@interface MKSegment : MKBackedNode {
@package
    mk_vm_address_t _nodeContextAddress;
    mk_vm_size_t _nodeContextSize;
    //
    NSString *_name;
    id<MKLCSegment> _loadCommand;
    NSArray<MKOptional<MKSection*>*> *_sections;
    NSMapTable<id<MKLCSection>, MKOptional<MKSection*>*> *_sectionsByLoadCommand;
    //
    mk_vm_address_t _vmAddress;
    mk_vm_size_t _vmSize;
    mk_vm_address_t _fileOffset;
    mk_vm_size_t _fileSize;
    vm_prot_t _maximumProtection;
    vm_prot_t _initialProtection;
    MKSegmentFlags _flags;
}

//! Returns the subclass of \ref MKSegment that is most suitable for the
//! segment with the provided load command.
+ (Class)classForSegmentLoadCommand:(id<MKLCSegment>)segmentLoadCommand;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Subclassing MKSegment
//! @name       Subclassing MKSegment
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//! This method is called on all \ref MKSegment subclasses when determining
//! the appropriate class to instantiate for the provided load command.
//!
//! Subclasses should return a non-zero integer if they support the segment.
//! The subclass that returns the largest value will be instantiated.
//! \ref MKSegment subclasses in Mach-O Kit return a value no larger than
//! \c 100.  You can substitute your own subclass by returning a larger value.
+ (uint32_t)canInstantiateWithSegmentLoadCommand:(id<MKLCSegment>)segmentLoadCommand;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Creating a Segment
//! @name       Creating a Segment
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//! Creates an instantiates the appropriate subclass of \ref MKSegment
//! for the provided load command.
+ (nullable instancetype)segmentWithLoadCommand:(id<MKLCSegment>)segmentLoadCommand error:(NSError**)error;

- (nullable instancetype)initWithLoadCommand:(id<MKLCSegment>)segmentLoadCommand error:(NSError**)error NS_DESIGNATED_INITIALIZER;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  About This Segment
//! @name       About This Segment
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//! The name of the segment, as specified in the load command.
@property (nonatomic, readonly, nullable) NSString *name;
//! The load command identifying the segment.
@property (nonatomic, readonly) id<MKLCSegment> loadCommand;

@property (nonatomic, readonly) mk_vm_address_t vmAddress;
@property (nonatomic, readonly) mk_vm_size_t vmSize;
@property (nonatomic, readonly) mk_vm_address_t fileOffset;
@property (nonatomic, readonly) mk_vm_size_t fileSize;

@property (nonatomic, readonly) vm_prot_t maximumProtection;
@property (nonatomic, readonly) vm_prot_t initialProtection;

@property (nonatomic, readonly) MKSegmentFlags flags;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Sections
//! @name       Sections
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//! A list of \ref MKSection instances, each representing a section within
//! the segment.
@property (nonatomic, readonly) NSArray<MKOptional<__kindof MKSection*>*> *sections;

//! Returns the \ref MKSection from the \ref sections array at the given
//! \a index.
- (MKOptional<__kindof MKSection*> *)segmentAtIndex:(NSUInteger)index;

//! Returns the \ref MKSection from the \ref sections array that is identified
//! by the provided load command.
- (MKOptional<__kindof MKSection*> *)sectionForLoadCommand:(id<MKLCSection>)sectionLoadCommand;

@end

NS_ASSUME_NONNULL_END
