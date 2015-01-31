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
#import "NSError+MK.h"
#import "MKMachO.h"

#import <objc/runtime.h>

//----------------------------------------------------------------------------//
@implementation MKSegment

@synthesize name = _name;
@synthesize loadCommand = _loadCommand;
@synthesize vmAddress = _vmAddress;
@synthesize vmSize = _vmSize;
@synthesize fileOffset = _fileOffset;
@synthesize fileSize = _fileSize;
@synthesize maximumProtection = _maximumProtection;
@synthesize initialProtection = _initialProtection;
@synthesize flags = _flags;

//|++++++++++++++++++++++++++++++++++++|//
+ (id*)_subclassesCache
{ static __weak NSSet *subclasses; return &subclasses; }

//|++++++++++++++++++++++++++++++++++++|//
+ (uint32_t)canInstantiateWithSegmentLoadCommand:(id<MKLCSegment>)segmentLoadCommand
{
#pragma unused (segmentLoadCommand)
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
#pragma mark - Creating a Segment
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)segmentWithLoadCommand:(id<MKLCSegment>)segmentLoadCommand error:(NSError**)error
{
    Class segmentClass = [self classForSegmentLoadCommand:segmentLoadCommand];
    NSAssert(segmentClass, @"");
    
    return [[[segmentClass alloc] initWithLoadCommand:segmentLoadCommand error:error] autorelease];
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithLoadCommand:(id<MKLCSegment>)segmentLoadCommand error:(NSError**)error
{
    NSParameterAssert(segmentLoadCommand);
    mk_error_t err;
    
    MKMachOImage *image = segmentLoadCommand.macho;
    NSParameterAssert(image);
    
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
    
    if (image.isFromMemoryDump)
    {
        _nodeContextSize = _vmSize;
        _nodeContextAddress = _vmAddress;
    }
    else
    {
        _nodeContextSize = _fileSize;
        
        // The _fileOffset of this segment is relative to the Mach-O header
        // which may not correspond to offset 0 in the context.
        if ((err = mk_vm_address_add(image.nodeContextAddress, _fileOffset, &_nodeContextAddress))) {
            MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:err description:@"Arithmetic error %s while adding _fileOffset (%" MK_VM_PRIxADDR ") to image.nodeContextAddress (%" MK_VM_PRIxADDR ")", mk_error_string(err), _fileOffset, image.nodeContextAddress];
            [self release]; return nil;
        }
    }
    
    // Slide the node address.
    {
        mk_vm_offset_t slide = (mk_vm_offset_t)image.slide;
        
        if ((err = mk_vm_address_apply_offset(_nodeContextAddress, slide, &_nodeContextAddress))) {
            MK_ERROR_OUT = MK_MAKE_VM_ARITHMETIC_ERROR(err, _nodeContextAddress, slide);
            [self release]; return nil;
        }
    }
    
    // The kernel will refuse to load a Mach-O image in which adding the
    // file offset to the file size would trigger an overflow.  It would also
    // refuse to load the image if this value was larger than the size of the
    // Mach-O, but we don't know the size of the Mach-O.
    if ((err = mk_vm_address_check_length(_fileOffset, _fileSize))) {
        MK_ERROR_OUT = MK_MAKE_VM_LENGTH_CHECK_ERROR(err, _fileOffset, _fileSize);
        [self release]; return nil;
    }
    
    // Also check the vmAddress + vmSize for potential overflow.
    if ((err = mk_vm_address_check_length(_vmAddress, _vmSize))) {
        MK_ERROR_OUT = MK_MAKE_VM_LENGTH_CHECK_ERROR(err, _vmAddress, _vmSize);
        [self release]; return nil;
    }
    
    // Due to a bug in update_dyld_shared_cache(1), the segment vmsize defined
    // in the Mach-O load commands may  be invalid, and the declared size may
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
    
    // Make sure the node data is actually available
    if ([image.memoryMap hasMappingAtOffset:0 fromAddress:_nodeContextAddress length:_nodeContextSize] == NO) {
        MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_ENOT_FOUND description:@"Segment data does not exist in memory map for image %@", image];
        [self release]; return nil;
    }
    
    // Load the sections
    {
        NSArray *sections = [segmentLoadCommand sections];
        if (sections.count != [segmentLoadCommand nsects]) {
            MK_PUSH_WARNING(MK_PROPERTY(sections), MK_EINVALID_DATA, @"Segment load command lists %" PRIi32 " sections but only %" PRIuPTR " are avaiable.", [(MKLCSegment*)segmentLoadCommand nsects], sections.count);
        }
        
        NSMutableSet *segmentSections = [[NSMutableSet alloc] init];
        
        for (id<MKLCSection> sectionLoadCommand in sections) {
            NSError *e = nil;
            MKSection *section = [MKSection sectionWithLoadCommand:sectionLoadCommand inSegment:self error:&e];
            
            if (section)
                [segmentSections addObject:section];
            else
                MK_PUSH_UNDERLYING_WARNING(MK_PROPERTY(sections), e, @"Failed to load section for %@", sectionLoadCommand);
        }
        
        _sections = [segmentSections copy];
        [segmentSections release];
    }
    
    // TODO - Handle protected binaries.  Create a proxy MKMapping that performs
    // the decryption.
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithParent:(MKNode*)parent error:(NSError**)error
{
    NSAssert([parent conformsToProtocol:@protocol(MKLCSegment)], @"");
    return [self initWithLoadCommand:(id)parent error:error];
}

//|++++++++++++++++++++++++++++++++++++|//
- (void)dealloc
{
    [_name release];
    [_loadCommand release];
    [_sections release];
    [super dealloc];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - Sections
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
#pragma mark - MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@synthesize nodeSize = _nodeContextSize;

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_address_t)nodeAddress:(MKNodeAddressType)type
{
    switch (type) {
        case MKNodeContextAddress:
            return _nodeContextAddress;
            break;
        case MKNodeVMAddress:
            return _vmAddress;
            break;
        default:
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Unsupported node address type." userInfo:nil];
    }
}

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        [MKNodeField nodeFieldWithProperty:MK_PROPERTY(name) description:@"Section Name"],
        [MKNodeField nodeFieldWithProperty:MK_PROPERTY(fileOffset) description:@"File offset"],
        [MKNodeField nodeFieldWithProperty:MK_PROPERTY(fileSize) description:@"File size"],
        [MKNodeField nodeFieldWithProperty:MK_PROPERTY(vmAddress) description:@"VM Address"],
        [MKNodeField nodeFieldWithProperty:MK_PROPERTY(vmSize) description:@"VM Size"],
        [MKNodeField nodeFieldWithProperty:MK_PROPERTY(maximumProtection) description:@"Maximum VM Protection"],
        [MKNodeField nodeFieldWithProperty:MK_PROPERTY(initialProtection) description:@"Initial VM Protection"],
        [MKNodeField nodeFieldWithProperty:MK_PROPERTY(flags) description:@"Flags"],
        [MKNodeField nodeFieldWithProperty:MK_PROPERTY(sections) description:@"Sections"],
    ]];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - NSObject
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (NSString*)description
{ return [NSString stringWithFormat:@"<%@(%@) %p>", NSStringFromClass(self.class), self.name, self]; }

@end
