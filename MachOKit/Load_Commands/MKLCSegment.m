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
#import "MKInternal.h"
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
+ (uint32_t)canInstantiateWithLoadCommandID:(uint32_t)commandID
{
    if (self != MKLCSegment.class)
        return 0;
    
    return commandID == [self ID] ? 10 : 0;
}

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
            
            MKLCSection *sect = [[MKLCSection alloc] initWithOffset:offset fromParent:self error:&sectionError];
            if (sect == nil) {
                // If we fail to instantiate an instance of MKLCSection it
                // means we've walked off the end of memory that can be mapped
                // by our MKMemoryMap.
                MK_PUSH_UNDERLYING_WARNING(sections, sectionError, @"Failed to instantiate section at index " PRIi32 "", (self.nsects - sectionCount));
                break;
            }
                
            oldOffset = offset;
            offset += sect.nodeSize;
                
            if (oldOffset > offset || offset > self.nodeSize) {
                // The kernel will refuse to load any Mach-O image in which the
                // number of sections specifed would not fit within the load
                // command's size.  We will match this behavior and throw away
                // any section which straddles the boundary.
                MK_PUSH_WARNING(sections, MK_EINVALID_DATA, @"Part of section at index " PRIi32 " is outside the enclosing load command.", (self.nsects - sectionCount));
                [sect release];
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
    __unused struct segment_command lc;
    
    MKNodeFieldBuilder *segname = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(segname)
        type:nil /* TODO ? */
        offset:offsetof(typeof(lc), segname)
        size:sizeof(lc.segname)
    ];
    segname.description = @"Segment Name";
    segname.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *vmaddr = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(vmaddr)
        type:MKNodeFieldTypeUnsignedDoubleWord.sharedInstance
        offset:offsetof(typeof(lc), vmaddr)
        size:sizeof(lc.vmaddr)
    ];
    vmaddr.description = @"VM Address";
    vmaddr.formatter = [MKHexNumberFormatter hexNumberFormatterWithDigits:(size_t)(sizeof(lc.vmaddr)*2)];
    vmaddr.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *vmsize = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(vmsize)
        type:MKNodeFieldTypeUnsignedDoubleWord.sharedInstance
        offset:offsetof(typeof(lc), vmsize)
        size:sizeof(lc.vmsize)
    ];
    vmsize.description = @"VM Size";
    vmsize.formatter = [MKHexNumberFormatter hexNumberFormatterWithDigits:(size_t)(sizeof(lc.vmsize)*2)];
    vmsize.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *fileoff = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(fileoff)
        type:MKNodeFieldTypeUnsignedDoubleWord.sharedInstance
        offset:offsetof(typeof(lc), fileoff)
        size:sizeof(lc.fileoff)
    ];
    fileoff.description = @"File Offset";
    fileoff.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *filesize = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(filesize)
        type:MKNodeFieldTypeUnsignedDoubleWord.sharedInstance
        offset:offsetof(typeof(lc), filesize)
        size:sizeof(lc.filesize)
    ];
    filesize.description = @"File Size";
    filesize.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *maxprot = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(maxprot)
        type:MKNodeFieldVMProtectionType.sharedInstance
        offset:offsetof(typeof(lc), maxprot)
        size:sizeof(lc.maxprot)
    ];
    maxprot.description = @"Maximum VM Propection";
    maxprot.options = MKNodeFieldOptionDisplayAsDetail;
#ifdef TESTS
    maxprot.formatter = [MKHexNumberFormatter hexNumberFormatterWithDigits:(size_t)(sizeof(lc.maxprot)*2)];
#endif

    MKNodeFieldBuilder *initprot = [MKNodeFieldBuilder
       builderWithProperty:MK_PROPERTY(initprot)
       type:MKNodeFieldVMProtectionType.sharedInstance
       offset:offsetof(typeof(lc), initprot)
       size:sizeof(lc.initprot)
    ];
    initprot.description = @"Initial VM Propection";
    initprot.options = MKNodeFieldOptionDisplayAsDetail;
#ifdef TESTS
    initprot.formatter = [MKHexNumberFormatter hexNumberFormatterWithDigits:(size_t)(sizeof(lc.initprot)*2)];
#endif
    
    MKNodeFieldBuilder *nsects = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(nsects)
        type:MKNodeFieldTypeUnsignedDoubleWord.sharedInstance
        offset:offsetof(typeof(lc), nsects)
        size:sizeof(lc.nsects)
    ];
    nsects.description = @"Number Of Sections";
    nsects.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *flags = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(flags)
        type:MKNodeFieldSegmentFlagsType.sharedInstance
        offset:offsetof(typeof(lc), flags)
        size:sizeof(lc.flags)
    ];
    flags.description = @"Flags";
    flags.options = MKNodeFieldOptionDisplayAsDetail;
#ifdef TESTS
    flags.formatter = NSFormatter.mk_hexCompactFormatter;
#endif
    
    MKNodeFieldBuilder *sections = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(sections)
        type:[MKNodeFieldTypeCollection typeWithCollectionType:[MKNodeFieldTypeNode typeWithNodeType:MKLCSection.class]]
    ];
    sections.description = @"Sections";
    sections.options = MKNodeFieldOptionDisplayAsChild | MKNodeFieldOptionMergeWithParent;
    
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        segname.build,
        vmaddr.build,
        vmsize.build,
        fileoff.build,
        filesize.build,
        maxprot.build,
        initprot.build,
        nsects.build,
        flags.build,
        sections.build
    ]];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - NSObject
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (NSString*)description
{ return [NSString stringWithFormat:@"%@ (%@)", super.description, self.segname]; }

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
    __unused struct section sc;
    
    MKNodeFieldBuilder *sectname = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(sectname)
        type:nil /* TODO ? */
        offset:offsetof(typeof(sc), sectname)
        size:sizeof(sc.sectname)
    ];
    sectname.description = @"Section Name";
    sectname.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *segname = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(segname)
        type:nil /* TODO ? */
        offset:offsetof(typeof(sc), segname)
        size:sizeof(sc.segname)
    ];
    segname.description = @"Segment Name";
    segname.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *addr = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(addr)
        type:MKNodeFieldTypeUnsignedDoubleWord.sharedInstance
        offset:offsetof(typeof(sc), addr)
        size:sizeof(sc.addr)
    ];
    addr.description = @"Address";
    addr.options = MKNodeFieldOptionDisplayAsDetail;
    addr.formatter = [MKHexNumberFormatter hexNumberFormatterWithDigits:(size_t)(sizeof(sc.addr)*2)];
    
    MKNodeFieldBuilder *size = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(size)
        type:MKNodeFieldTypeUnsignedDoubleWord.sharedInstance
        offset:offsetof(typeof(sc), size)
        size:sizeof(sc.size)
    ];
    size.description = @"Size";
    size.options = MKNodeFieldOptionDisplayAsDetail;
#ifdef TESTS
    size.formatter = [MKHexNumberFormatter hexNumberFormatterWithDigits:(size_t)(sizeof(sc.size)*2)];
#endif
    
    MKNodeFieldBuilder *offset = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(offset)
        type:MKNodeFieldTypeUnsignedDoubleWord.sharedInstance
        offset:offsetof(typeof(sc), offset)
        size:sizeof(sc.offset)
    ];
    offset.description = @"Offset";
    offset.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *align = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(align)
        type:MKNodeFieldTypeUnsignedDoubleWord.sharedInstance
        offset:offsetof(typeof(sc), align)
        size:sizeof(sc.align)
    ];
    align.description = @"Alignment";
    align.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *reloff = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(reloff)
        type:MKNodeFieldTypeUnsignedDoubleWord.sharedInstance
        offset:offsetof(typeof(sc), reloff)
        size:sizeof(sc.reloff)
    ];
    reloff.description = @"Relocations Offset";
    reloff.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *nreloc = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(nreloc)
        type:MKNodeFieldTypeUnsignedDoubleWord.sharedInstance
        offset:offsetof(typeof(sc), nreloc)
        size:sizeof(sc.nreloc)
    ];
    nreloc.description = @"Number of Relocations";
    nreloc.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *flags = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(flags)
        type:MKNodeFieldSectionFlagsType.sharedInstance
        offset:offsetof(typeof(sc), flags)
        size:sizeof(sc.flags)
    ];
    flags.description = @"Flags";
    flags.options = MKNodeFieldOptionDisplayAsDetail;
#ifdef TESTS
    flags.formatter = NSFormatter.mk_hexCompactFormatter;
#endif
    
    MKNodeFieldBuilder *reserved1 = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(reserved1)
        type:MKNodeFieldTypeUnsignedDoubleWord.sharedInstance
        offset:offsetof(typeof(sc), reserved1)
        size:sizeof(sc.reserved1)
    ];
    reserved1.description = @"Reserved1";
    reserved1.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *reserved2 = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(reserved2)
        type:MKNodeFieldTypeUnsignedDoubleWord.sharedInstance
        offset:offsetof(typeof(sc), reserved2)
        size:sizeof(sc.reserved2)
    ];
    reserved2.description = @"Reserved2";
    reserved2.options = MKNodeFieldOptionDisplayAsDetail;
    
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        sectname.build,
        segname.build,
        addr.build,
        size.build,
        offset.build,
        align.build,
        reloff.build,
        nreloc.build,
        flags.build,
        reserved1.build,
        reserved2.build
    ]];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - NSObject
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (NSString*)description
{ return [NSString stringWithFormat:@"Section Header (%@)", self.sectname]; }

@end
