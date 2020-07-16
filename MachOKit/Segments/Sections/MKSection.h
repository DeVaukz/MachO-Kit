//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       MKSection.h
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

#import <MachOKit/MKBackedNode.h>
#import <MachOKit/MKMachOFieldType.h>
#import <MachOKit/MKLCSegment.h>

@class MKSegment;

NS_ASSUME_NONNULL_BEGIN

//----------------------------------------------------------------------------//
@interface MKSection : MKBackedNode {
@package
    mk_vm_address_t _nodeContextAddress;
    mk_vm_size_t _nodeContextSize;
    /// Data ///
    NSString *_name;
    id<MKLCSection> _loadCommand;
    uint32_t _alignment;
    mk_vm_address_t _fileOffset;
    mk_vm_address_t _vmAddress;
    mk_vm_size_t _size;
    uint32_t _flags;
}

//! Returns the subclass of \ref MKSection that is most suitable for the
//! section with the provided load command.
+ (Class)classForSectionLoadCommand:(id<MKLCSection>)sectionLoadCommand inSegment:(MKSegment*)segment;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Subclassing MKSection
//! @name       Subclassing MKSection
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//! This method is called on all \ref MKSection subclasses when determining
//! the appropriate class to instantiate for the provided load command.
//!
//! Subclasses should return a non-zero integer if they support the section.
//! The subclass that returns the largest value will be instantiated.
//! \ref MKSection subclasses in Mach-O Kit return a value no larger than
//! \c 100.  You can substitute your own subclass by returning a larger value.
+ (uint32_t)canInstantiateWithSectionLoadCommand:(id<MKLCSection>)sectionLoadCommand inSegment:(MKSegment*)segment;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Creating a Section
//! @name       Creating a Section
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//! Creates an instantiates the appropriate subclass of \ref MKSection
//! for the provided load command.
+ (nullable instancetype)sectionWithLoadCommand:(id<MKLCSection>)sectionLoadCommand inSegment:(MKSegment*)segment error:(NSError**)error;

- (nullable instancetype)initWithLoadCommand:(id<MKLCSection>)sectionLoadCommand inSegment:(MKSegment*)segment error:(NSError**)error NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithParent:(MKNode *)parent error:(NSError **)error NS_UNAVAILABLE;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  About This Section
//! @name       About This Section
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//! The name of the section, as specified in the load command.
@property (nonatomic, readonly, nullable) NSString *name;
//! The load command identifying the section.
@property (nonatomic, readonly) id<MKLCSection> loadCommand;

@property (nonatomic, readonly) uint32_t alignment;

@property (nonatomic, readonly) mk_vm_address_t fileOffset;
@property (nonatomic, readonly) mk_vm_address_t vmAddress;
@property (nonatomic, readonly) mk_vm_size_t size;

@property (nonatomic, readonly) MKSectionType type;
@property (nonatomic, readonly) MKSectionUserAttributes userAttributes;
@property (nonatomic, readonly) MKSectionSystemAttributes systemAttributes;

@end

NS_ASSUME_NONNULL_END
