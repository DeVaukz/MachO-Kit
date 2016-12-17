//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKLCSegment.m
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

#import "MKLCSegment.h"
#import "NSError+MK.h"
#import "MKMachO.h"

//----------------------------------------------------------------------------//
@implementation MKLCSegment

@dynamic macho;
@synthesize sections = _sections;
@synthesize segname = _segname;
@synthesize vmaddr = _vmaddr;
@synthesize vmsize = _vmsize;
@synthesize fileoff = _fileoff;
@synthesize filesize = _filesize;
@synthesize maxprot = _maxprot;
@synthesize initprot = _initprot;
@synthesize nsects = _nsects;
@synthesize flags = _flags;

//|++++++++++++++++++++++++++++++++++++|//
+ (uint32_t)ID
{ return LC_SEGMENT; }

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithOffset:(mk_vm_offset_t)offset fromParent:(MKBackedNode*)parent error:(NSError**)error
{
    self = [super initWithOffset:offset fromParent:parent error:error];
    if (self == nil) return nil;
    
    struct segment_command lc;
    if ([self.memoryMap copyBytesAtOffset:offset fromAddress:parent.nodeContextAddress into:&lc length:sizeof(lc) requireFull:YES error:error] < sizeof(lc))
    { [self release]; return nil; }
    
    _vmaddr = MKSwapLValue32(lc.vmaddr, self.macho.dataModel);
    _vmsize = MKSwapLValue32(lc.vmsize, self.macho.dataModel);
    _fileoff = MKSwapLValue32(lc.fileoff, self.macho.dataModel);
    _filesize = MKSwapLValue32(lc.filesize, self.macho.dataModel);
    _maxprot = MKSwapLValue32s(lc.maxprot, self.macho.dataModel);
    _initprot = MKSwapLValue32s(lc.initprot, self.macho.dataModel);
    _nsects = MKSwapLValue32(lc.nsects, self.macho.dataModel);
    _flags = MKSwapLValue32(lc.flags, self.macho.dataModel);
    
    // Load segname
    {
        const char *bytes = lc.segname;
        NSUInteger length = strnlen(bytes, sizeof(lc.segname));
        
        _segname = [[NSString alloc] initWithBytes:bytes length:length encoding:NSUTF8StringEncoding];
        
        if (_segname == nil)
            MK_PUSH_WARNING(segname, MK_EINVALID_DATA, @"Could not form a string with data.");
        else if (length >= sizeof(lc.segname))
            MK_PUSH_WARNING(segname, MK_EINVALID_DATA, @"String is not properly terminated.");
    }
    
    // Load the sections
    {
        uint32_t sectionCount = self.nsects;
        
        NSMutableArray<MKLCSection*> *sections = [[NSMutableArray alloc] initWithCapacity:sectionCount];
        mach_vm_offset_t offset = sizeof(lc);
        mach_vm_offset_t oldOffset;
        
        while (sectionCount--) {
        @autoreleasepool {
            NSError *sectionError = nil;
            
            // It is safe to pass the mach_vm_offset_t offset as the offset
            // parameter because the offset can not grow beyond the node size,
            // which is capped at UINT32_MAX.  Any uint32_t can be acurately
            // represented by an mk_vm_offset_t.
            
            // NOTE: The sections array must contain each MKLCSection at its
            //       matching index within this segment's load command.  Do
            //       not attempt to continue after a MKLCSection fails to load
            //       as this will break the ordering.
            
            MKLCSection *sect = [[[MKLCSection alloc] initWithOffset:offset fromParent:self error:&sectionError] autorelease];
            if (sect == nil) {
                // If we fail to instantiate an instance of the MKLCSection64 it
                // means we've walked off the end of memory that can be mapped
                // by our MKMemoryMap.
                MK_PUSH_UNDERLYING_WARNING(sections, sectionError, @"Failed to instantiate section at index " PRIi32 "", (self.nsects - sectionCount));
                break;
            }
                
            oldOffset = offset;
            offset += sect.nodeSize;
                
            if (oldOffset > offset || offset > self.nodeSize) {
                // The kernel will refuse to load any MachO image in which the
                // number of sections specifed would not fit within the load
                // command's size.  We will match this behavior and throw away
                // any section which straddles the boundary.
                MK_PUSH_WARNING(sections, MK_EINVALID_DATA, @"Part of section at index " PRIi32 " is outside the enclosing load command.", (self.nsects - sectionCount));
                break;
            }
                
            [sections addObject:sect];
            [sect release];
        }}
        
        _sections = [sections copy];
        [sections release];
    }
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (void)dealloc
{
    [_sections release];
    [_segname release];
    [super dealloc];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - MKLCSegment
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_address_t)mk_vmaddr
{ return (mk_vm_address_t)self.vmaddr; }

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_size_t)mk_vmsize
{ return (mk_vm_address_t)self.vmsize; }

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_address_t)mk_fileoff
{ return (mk_vm_address_t)self.fileoff; }

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_size_t)mk_filesize
{ return (mk_vm_address_t)self.filesize; }

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(segname) description:@"Segment Name" offset:offsetof(struct segment_command, segname) size:16],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(vmaddr) description:@"VM Address" offset:offsetof(struct segment_command, vmaddr) size:sizeof(uint32_t) format:MKNodeFieldFormatHex],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(vmsize) description:@"VM Size" offset:offsetof(struct segment_command, vmsize) size:sizeof(uint32_t) format:MKNodeFieldFormatHex],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(fileoff) description:@"File Offset" offset:offsetof(struct segment_command, fileoff) size:sizeof(uint32_t) format:MKNodeFieldFormatDecimal],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(filesize) description:@"File Size " offset:offsetof(struct segment_command, filesize) size:sizeof(uint32_t) format:MKNodeFieldFormatDecimal],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(maxprot) description:@"Maximum VM Propection" offset:offsetof(struct segment_command, maxprot) size:sizeof(vm_prot_t) format:MKNodeFieldFormatHex],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(initprot) description:@"Initial VM Protection" offset:offsetof(struct segment_command, initprot) size:sizeof(vm_prot_t) format:MKNodeFieldFormatHex],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(nsects) description:@"Number Of Sections" offset:offsetof(struct segment_command, nsects) size:sizeof(uint32_t)],
        [MKFlagsNodeField fieldWithProperty:MK_PROPERTY(flags) description:@"Flags" offset:offsetof(struct segment_command, flags) size:sizeof(uint32_t) flags:@{}],
        [MKNodeField nodeFieldWithProperty:MK_PROPERTY(sections) description:@"Sections"]
    ]];
}

//|++++++++++++++++++++++++++++++++++++|//
- (NSString*)description
{ return [NSString stringWithFormat:@"<%@ %@ %p; vmaddr=0x%" PRIx32 " vmsize=%" PRIi32 ">", self.segname, self.class, self, self.vmaddr, self.vmsize]; }

@end



//----------------------------------------------------------------------------//
@implementation MKLCSection

@dynamic macho;
@synthesize sectname = _sectname;
@synthesize segname = _segname;
@synthesize addr = _addr;
@synthesize size = _size;
@synthesize offset = _offset;
@synthesize align = _align;
@synthesize reloff = _reloff;
@synthesize nreloc = _nreloc;
@synthesize flags = _flags;
@synthesize reserved1 = _reserved1;
@synthesize reserved2 = _reserved2;

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithOffset:(mk_vm_offset_t)offset fromParent:(MKBackedNode*)parent error:(NSError **)error
{
    self = [super initWithOffset:offset fromParent:parent error:error];
    if (self == nil) return self;
    
    struct section sect;
    if ([self.memoryMap copyBytesAtOffset:offset fromAddress:parent.nodeContextAddress into:&sect length:sizeof(sect) requireFull:YES error:error] < sizeof(sect))
    { [self release]; return nil; }
    
    _addr = MKSwapLValue32(sect.addr, self.macho.dataModel);
    _size = MKSwapLValue32(sect.size, self.macho.dataModel);
    _offset = MKSwapLValue32(sect.offset, self.macho.dataModel);
    _align = (typeof(_align))powf( 2, MKSwapLValue32(sect.align, self.macho.dataModel) );
    _reloff = MKSwapLValue32(sect.reloff, self.macho.dataModel);
    _nreloc = MKSwapLValue32(sect.nreloc, self.macho.dataModel);
    _flags = MKSwapLValue32(sect.flags, self.macho.dataModel);
    _reserved1 = MKSwapLValue32(sect.reserved1, self.macho.dataModel);
    _reserved2 = MKSwapLValue32(sect.reserved2, self.macho.dataModel);
    
    // Load sectname
    {
        const char *bytes = sect.sectname;
        NSUInteger length = strnlen(bytes, sizeof(sect.sectname));
        
        _sectname = [[NSString alloc] initWithBytes:bytes length:length encoding:NSUTF8StringEncoding];
        
        if (_sectname == nil)
            MK_PUSH_WARNING(sectname, MK_EINVALID_DATA, @"Could not form a string with data.");
        else if (length >= sizeof(sect.sectname))
            MK_PUSH_WARNING(sectname, MK_EINVALID_DATA, @"String is not properly terminated.");
    }
    
    // Load segname
    {
        const char *bytes = sect.segname;
        NSUInteger length = strnlen(bytes, sizeof(sect.segname));
        
        _segname = [[NSString alloc] initWithBytes:bytes length:length encoding:NSUTF8StringEncoding];
        
        if (_segname == nil)
            MK_PUSH_WARNING(segname, MK_EINVALID_DATA, @"Could not form a string with data.");
        else if (length >= sizeof(sect.sectname))
            MK_PUSH_WARNING(segname, MK_EINVALID_DATA, @"String is not properly terminated.");
    }
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (void)dealloc
{
    [_sectname release];
    [_segname release];
    [super dealloc];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - MKLCSection
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_address_t)mk_addr
{ return (mk_vm_address_t)self.addr; }

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_size_t)mk_size
{ return (mk_vm_address_t)self.size; }

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_address_t)mk_offset
{ return (mk_vm_address_t)self.offset; }

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_size_t)nodeSize
{ return sizeof(struct section); }

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(sectname) description:@"Section Name" offset:offsetof(struct section, sectname) size:16],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(segname) description:@"Segment Name" offset:offsetof(struct section, segname) size:16],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(addr) description:@"Address" offset:offsetof(struct section, addr) size:sizeof(uint32_t) format:MKNodeFieldFormatHex],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(size) description:@"Size" offset:offsetof(struct section, size) size:sizeof(uint32_t) format:MKNodeFieldFormatHex],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(offset) description:@"Offset" offset:offsetof(struct section, offset) size:sizeof(uint32_t) format:MKNodeFieldFormatDecimal],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(align) description:@"Alignment" offset:offsetof(struct section, align) size:sizeof(uint32_t)],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(reloff) description:@"Relocations Offset" offset:offsetof(struct section, reloff) size:sizeof(uint32_t)],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(nreloc) description:@"Number of Relocations" offset:offsetof(struct section, nreloc) size:sizeof(uint32_t)],
        [MKFlagsNodeField fieldWithProperty:MK_PROPERTY(flags) description:@"Flags" offset:offsetof(struct section, flags) size:sizeof(uint32_t) flags:@{}],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(reserved1) description:@"Reserved" offset:offsetof(struct section, reserved1) size:sizeof(uint32_t)],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(reserved1) description:@"Reserved" offset:offsetof(struct section, reserved2) size:sizeof(uint32_t)]
    ]];
}

@end
