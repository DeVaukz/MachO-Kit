//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKSegment.m
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

#import "MKSegment.h"
#import "MKInternal.h"
#import "MKMachO.h"

#import <objc/runtime.h>

//----------------------------------------------------------------------------//
@implementation MKSegment

//|++++++++++++++++++++++++++++++++++++|//
+ (id*)_subclassesCache
{ static NSSet *subclasses; return &subclasses; }

//|++++++++++++++++++++++++++++++++++++|//
+ (uint32_t)canInstantiateWithSegmentLoadCommand:(id<MKLCSegment>)segmentLoadCommand
{
#pragma unused (segmentLoadCommand)
    if (self != MKSegment.class)
        return 0;
    
    return 10;
}

//|++++++++++++++++++++++++++++++++++++|//
+ (Class)classForSegmentLoadCommand:(id<MKLCSegment>)segmentLoadCommand
{
    return [self bestSubclassWithRanking:^uint32_t(Class cls) {
        return [cls canInstantiateWithSegmentLoadCommand:segmentLoadCommand];
    }];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Creating a Segment
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)segmentWithLoadCommand:(id<MKLCSegment>)segmentLoadCommand error:(NSError**)error
{
    Class segmentClass = [self classForSegmentLoadCommand:segmentLoadCommand];
    if (segmentClass == NULL) {
        NSString *reason = [NSString stringWithFormat:@"No segment for load command: %@.", [(MKNode*)segmentLoadCommand nodeDescription]];
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:reason userInfo:nil];
    }
    
    return [[[segmentClass alloc] initWithLoadCommand:segmentLoadCommand error:error] autorelease];
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithLoadCommand:(id<MKLCSegment>)segmentLoadCommand error:(NSError**)error
{
    NSParameterAssert(segmentLoadCommand.macho != nil);
    
    MKMachOImage *image = segmentLoadCommand.macho;
    NSError *arithmeticError = nil;
    mk_error_t err;
    
    self = [super initWithParent:image error:error];
    if (self == nil) return nil;
    
    _vmAddress = [segmentLoadCommand mk_vmaddr];
    _vmSize = [segmentLoadCommand mk_vmsize];
    _fileOffset = [segmentLoadCommand mk_fileoff];
    _fileSize = [segmentLoadCommand mk_filesize];
    
    _name = [[segmentLoadCommand segname] copy];
    _loadCommand = [segmentLoadCommand retain];
    _maximumProtection = [segmentLoadCommand maxprot];
    _initialProtection = [segmentLoadCommand initprot];
    _flags = [segmentLoadCommand flags];
    
    if (image.isFromMemory)
    {
        _nodeContextSize = _vmSize;
        _nodeContextAddress = _vmAddress;
        
        // Slide the node address.
        {
            mk_vm_slide_t slide = image.slide;
            
            if ((err = mk_vm_address_apply_slide(_nodeContextAddress, slide, &_nodeContextAddress))) {
                arithmeticError = MK_MAKE_VM_ADDRESS_APPLY_SLIDE_ARITHMETIC_ERROR(err, _nodeContextAddress, slide);
                MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_EINTERNAL_ERROR underlyingError:arithmeticError description:@"Could not determine the context address."];
                [self release]; return nil;
            }
        }
    }
    else
    {
        _nodeContextSize = _fileSize;
        
        // The _fileOffset of this segment is relative to the Mach-O header
        // which may not correspond to offset 0 in the context.
        if ((err = mk_vm_address_add(image.nodeContextAddress, _fileOffset, &_nodeContextAddress))) {
            arithmeticError = MK_MAKE_VM_ADDRESS_ADD_ARITHMETIC_ERROR(err, image.nodeContextAddress, _fileOffset);
            MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_EINTERNAL_ERROR underlyingError:arithmeticError description:@"Could not determine the context address."];
            [self release]; return nil;
        }
    }
    
    // The kernel will refuse to load a Mach-O image in which adding the
    // file offset to the file size would trigger an overflow.  It would also
    // refuse to load the image if this value was larger than the size of the
    // Mach-O, but we don't know the size of the Mach-O.
    if ((err = mk_vm_address_check_length(_fileOffset, _fileSize))) {
        arithmeticError = MK_MAKE_VM_LENGTH_CHECK_ERROR(err, _fileOffset, _fileSize);
        MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_EINTERNAL_ERROR underlyingError:arithmeticError description:@"Invalid file offset or file size."];
        [self release]; return nil;
    }
    
    // Also check the vmAddress + vmSize for potential overflow.
    if ((err = mk_vm_address_check_length(_vmAddress, _vmSize))) {
        arithmeticError = MK_MAKE_VM_LENGTH_CHECK_ERROR(err, _vmAddress, _vmSize);
        MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_EINTERNAL_ERROR underlyingError:arithmeticError description:@"Invalid VM address or VM size."];
        [self release]; return nil;
    }
    
    // Due to a bug in update_dyld_shared_cache(1), the segment vmsize defined
    // in the Mach-O load commands may be invalid, and the declared size may
    // be unmappable.  This bug appears to be caused by a bug in computing the
    // correct vmsize when update_dyld_shared_cache(1) generates the single
    // shared LINKEDIT segment.  Landon F. has reported this bug to Apple
    // as rdar://13707406.
    if (image.isFromSharedCache && [[(MKLCSegment*)segmentLoadCommand segname] isEqualToString:@SEG_LINKEDIT])
    {
        [self.memoryMap remapBytesAtOffset:0 fromAddress:_nodeContextAddress length:_nodeContextSize requireFull:NO withHandler:^(vm_address_t __unused address, vm_size_t length, NSError *error) {
            // If there was an error, just bail out.  We will catch the error
            // in the next check.
            if (error) return;
            
            if (length < _nodeContextSize) {
                // TODO - Warn about this
                _nodeContextSize = length;
                _vmSize = length;
                _fileSize = length;
            }
        }];
    }
    
    // Make sure the data is actually available
    if ([self.memoryMap hasMappingAtOffset:0 fromAddress:_nodeContextAddress length:_nodeContextSize] == NO) {
        MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_ENOT_FOUND description:@"Segment data does not exist in the memory map."];
        [self release]; return nil;
    }
    
    // Load the sections
    {
        NSArray *sections = [segmentLoadCommand sections];
        if (sections.count != [segmentLoadCommand nsects]) {
            MK_PUSH_WARNING(sections, MK_EINVALID_DATA, @"Segment load command specifies [%" PRIu32 "] sections but only [%" PRIuPTR "] were parsed by the load command.", [(MKLCSegment*)segmentLoadCommand nsects], sections.count);
        }
        
        NSMutableSet *segmentSections = [[NSMutableSet alloc] init];
        
        for (id<MKLCSection> sectionLoadCommand in sections) {
            NSError *sectionError = nil;
            
            MKSection *section = [MKSection sectionWithLoadCommand:sectionLoadCommand inSegment:self error:&sectionError];
            if (section == nil) {
                MK_PUSH_WARNING_WITH_ERROR(sections, MK_EINTERNAL_ERROR, sectionError, @"Could not create section for load command: %@.", [(MKNode*)sectionLoadCommand nodeDescription]);
                continue;
            }
            
            [segmentSections addObject:section];
        }
        
        _sections = [segmentSections copy];
        [segmentSections release];
    }
    
    // TODO - Handle protected binaries.  Create a proxy MKMemoryMap that
    // performs the decryption.
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithParent:(MKNode*)parent error:(NSError**)error
{
    NSParameterAssert([parent conformsToProtocol:@protocol(MKLCSegment)]);
    
    return [self initWithLoadCommand:(id)parent error:error];
}

//|++++++++++++++++++++++++++++++++++++|//
- (void)dealloc
{
    [_sections release];
    [_loadCommand release];
    [_name release];
    
    [super dealloc];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Segment Values
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@synthesize name = _name;
@synthesize loadCommand = _loadCommand;
@synthesize vmAddress = _vmAddress;
@synthesize vmSize = _vmSize;
@synthesize fileOffset = _fileOffset;
@synthesize fileSize = _fileSize;
@synthesize maximumProtection = _maximumProtection;
@synthesize initialProtection = _initialProtection;
@synthesize flags = _flags;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Sections
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@synthesize sections = _sections;

//|++++++++++++++++++++++++++++++++++++|//
- (MKSection*)sectionForLoadCommand:(id<MKLCSection>)sectionLoadCommand
{
    for (MKSection *section in self.sections) {
        if ([section.loadCommand isEqual:sectionLoadCommand])
            return section;
    }
    
    return nil;
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  MKPointer
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (MKOptional*)childNodeOccupyingVMAddress:(mk_vm_address_t)address targetClass:(Class)targetClass
{
    for (MKSection *section in self.sections) {
        mk_vm_range_t range = mk_vm_range_make(section.nodeVMAddress, section.nodeSize);
        if (mk_vm_range_contains_address(range, 0, address) == MK_ESUCCESS) {
            MKOptional *child = [section childNodeOccupyingVMAddress:address targetClass:targetClass];
            if (child.value)
                return child;
            // else, fallthrough and call the super's implementation.
            // The caller may actually be looking for *this* node.
        }
    }
    
    return [super childNodeOccupyingVMAddress:address targetClass:targetClass];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@synthesize nodeSize = _nodeContextSize;

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_address_t)nodeAddress:(MKNodeAddressType)type
{
    switch (type) {
        case MKNodeContextAddress:
            return _nodeContextAddress;
        case MKNodeVMAddress:
            return _vmAddress;
        default: {
            NSString *reason = [NSString stringWithFormat:@"Invalid node address type [%lu].", (unsigned long)type];
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:nil];
        }
    }
}

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    MKNodeFieldBuilder *name = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(name)
        type:MKNodeFieldTypeString.sharedInstance
    ];
    name.description = @"Segment Name";
    name.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *fileOffset = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(fileOffset)
        type:MKNodeFieldTypeAddress.sharedInstance
    ];
    fileOffset.description = @"File offset";
    fileOffset.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *fileSize = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(fileSize)
        type:MKNodeFieldTypeSize.sharedInstance
    ];
    fileSize.description = @"File size";
    fileSize.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *vmAddress = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(vmAddress)
        type:MKNodeFieldTypeAddress.sharedInstance
    ];
    vmAddress.description = @"VM Address";
    vmAddress.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *vmSize = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(vmSize)
        type:MKNodeFieldTypeSize.sharedInstance
    ];
    vmSize.description = @"VM Size";
    vmSize.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *maximumProtection = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(maximumProtection)
        type:MKNodeFieldVMProtectionType.sharedInstance
    ];
    maximumProtection.description = @"Maximum VM Protection";
    maximumProtection.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *initialProtection = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(initialProtection)
        type:MKNodeFieldVMProtectionType.sharedInstance
    ];
    initialProtection.description = @"Initial VM Protection";
    initialProtection.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *flags = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(flags)
        type:MKNodeFieldSegmentFlagsType.sharedInstance
    ];
    flags.description = @"Flags";
    flags.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *sections = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(sections)
        type:[MKNodeFieldTypeCollection typeWithCollectionType:[MKNodeFieldTypeNode typeWithNodeType:MKSection.class]]
    ];
    sections.description = @"Sections";
    sections.options = MKNodeFieldOptionDisplayAsChild;
    
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        name.build,
        fileOffset.build,
        fileSize.build,
        vmAddress.build,
        vmSize.build,
        maximumProtection.build,
        initialProtection.build,
        flags.build,
        sections.build
    ]];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  NSObject
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (NSString*)description
{ return self.name; }

@end
