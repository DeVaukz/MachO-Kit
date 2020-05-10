//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       MKLCSegment.h
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

#import <MachOKit/MKLoadCommand.h>

@class MKMachOImage;
@class MKLCSection;

NS_ASSUME_NONNULL_BEGIN

//----------------------------------------------------------------------------//
@protocol MKLCSegment <NSObject>
@property (nonatomic, readonly) MKMachOImage *macho;
@property (nonatomic, readonly) NSArray /*MKLCSection*/ *sections;
@property (nonatomic, readonly, nullable) NSString *segname;
@property (nonatomic, readonly) mk_vm_address_t mk_vmaddr;
@property (nonatomic, readonly) mk_vm_size_t mk_vmsize;
@property (nonatomic, readonly) mk_vm_address_t mk_fileoff;
@property (nonatomic, readonly) mk_vm_size_t mk_filesize;
@property (nonatomic, readonly) vm_prot_t maxprot;
@property (nonatomic, readonly) vm_prot_t initprot;
@property (nonatomic, readonly) uint32_t nsects;
@property (nonatomic, readonly) uint32_t flags;
@end


//----------------------------------------------------------------------------//
@protocol MKLCSection <NSObject>
@property (nonatomic, readonly) MKMachOImage *macho;
@property (nonatomic, readonly, nullable) NSString *sectname;
@property (nonatomic, readonly, nullable) NSString *segname;
@property (nonatomic, readonly) mk_vm_address_t mk_addr;
@property (nonatomic, readonly) mk_vm_size_t mk_size;
@property (nonatomic, readonly) mk_vm_address_t mk_offset;
@property (nonatomic, readonly) uint32_t align;
@property (nonatomic, readonly) uint32_t reloff;
@property (nonatomic, readonly) uint32_t nreloc;
@property (nonatomic, readonly) uint32_t flags;
@property (nonatomic, readonly) uint32_t reserved1;
@property (nonatomic, readonly) uint32_t reserved2;
@end



//----------------------------------------------------------------------------//
//! Parser for \c LC_SEGMENT.
//!
//! The segment load command indicates that a part of the file is to
//! be mapped into the task's address space.  The size of the segment in
//! memory may be larger than than on disk, in which case the remaining bytes
//! are zero filled.
//
@interface MKLCSegment : MKLoadCommand <MKLCSegment> {
@package
    NSArray<MKLCSection*> *_sections;
    NSString *_segname;
    uint32_t _vmaddr;
    uint32_t _vmsize;
    uint32_t _fileoff;
    uint32_t _filesize;
    vm_prot_t _maxprot;
    vm_prot_t _initprot;
    uint32_t _nsects;
    uint32_t _flags;
}

//! An array of \ref MKLCSection instances, each representing a section
//! specified in the load command.
@property (nonatomic, readonly) NSArray<MKLCSection*> *sections;

//! Segment name.
@property (nonatomic, readonly, nullable) NSString *segname;
//! The memory address of the segment.
@property (nonatomic, readonly) uint32_t vmaddr;
//! The memory size of the segment.
@property (nonatomic, readonly) uint32_t vmsize;
//! File offset of the segment.
@property (nonatomic, readonly) uint32_t fileoff;
//! The number of bytes to map from the file.
@property (nonatomic, readonly) uint32_t filesize;
//! Maximum VM protection.
@property (nonatomic, readonly) vm_prot_t maxprot;
//! Initial VM protection.
@property (nonatomic, readonly) vm_prot_t initprot;
//! Number of sections in the segment.
@property (nonatomic, readonly) uint32_t nsects;
//! Flags.
@property (nonatomic, readonly) uint32_t flags;

@end



//----------------------------------------------------------------------------//
//! Parser for a section declaration inside of a segment load command.
//
@interface MKLCSection : MKOffsetNode <MKLCSection> {
@package
    NSString *_sectname;
    NSString *_segname;
    uint32_t _addr;
    uint32_t _size;
    uint32_t _offset;
    uint32_t _align;
    uint32_t _reloff;
    uint32_t _nreloc;
    uint32_t _flags;
    uint32_t _reserved1;
    uint32_t _reserved2;
}

//! The name of the section.
@property (nonatomic, readonly, nullable) NSString *sectname;
//! The name of the segment the section is within.
@property (nonatomic, readonly, nullable) NSString *segname;
//! Memory address of the section.
@property (nonatomic, readonly) uint32_t addr;
//! Size in bytes of the section.
@property (nonatomic, readonly) uint32_t size;
//! File offset of the section.
@property (nonatomic, readonly) uint32_t offset;
//! The alignment of the section, in bytes.
@property (nonatomic, readonly) uint32_t align;
//! File offset of the relocation entries.
@property (nonatomic, readonly) uint32_t reloff;
//! The number of relocation entries.
@property (nonatomic, readonly) uint32_t nreloc;
//! Flags (section type and attributes).
@property (nonatomic, readonly) uint32_t flags;
//! Reserved (for offset or index).
@property (nonatomic, readonly) uint32_t reserved1;
//! Reserved (for count or sizeof).
@property (nonatomic, readonly) uint32_t reserved2;

@end

NS_ASSUME_NONNULL_END
