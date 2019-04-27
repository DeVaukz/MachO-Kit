//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKFixup.m
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

#import "MKFixup.h"
#import "MKInternal.h"
#import "MKRebaseInfo.h"
#import "MKRebaseCommand.h"
#import "MKMachO+Segments.h"
#import "MKSegment.h"

//----------------------------------------------------------------------------//
@implementation MKFixup

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithContext:(struct MKRebaseContext*)rebaseContext error:(NSError**)error
{
	NSParameterAssert(rebaseContext->info != nil);
	
    self = [super initWithParent:rebaseContext->info error:error];
    if (self == nil) return nil;
	
	_nodeOffset = rebaseContext->actionStartOffset;
	
    _type = rebaseContext->type;
    _offset = rebaseContext->offset;
    
    // Lookup the segment
    _segment = [self.macho.segments[@(rebaseContext->segmentIndex)] retain];
    // dyld will refuse to load a Mach-O if the segment index is out of bounds.
    if (_segment == nil) {
        // TODO - Do we care?  Could this be a warning instead?
        MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_ENOT_FOUND description:@"No segment at index [%u].", rebaseContext->segmentIndex];
        [self release]; return nil;
    }
    
    // Verify that the fixup location is within the segment
    mk_error_t err;
    mk_vm_address_t segmentAddress = _segment.vmAddress;
    
    mk_vm_range_t segmentRange = mk_vm_range_make(segmentAddress, _segment.vmSize);
    // dyld will refuse to load a Mach-O if a fixup address is not within the segment.
    if ((err = mk_vm_range_contains_address(segmentRange, _offset, segmentAddress))) {
        // TODO - Do we care?  Could this be a warning instead?
        MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:err description:@"The offset [%" MK_VM_PRIuOFFSET "] is not within the %@ segement (index %u).", rebaseContext->offset, _segment, rebaseContext->segmentIndex];
        [self release]; return nil;
    }
    
    // Try to find the section
    _section = (typeof(_section))[[_segment childNodeOccupyingVMAddress:self.address targetClass:MKSection.class] retain];
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithParent:(MKNode*)parent error:(NSError**)error
{
#pragma unused(parent)
#pragma unused(error)
	@throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"-initWithParent:error: unavailable." userInfo:nil];
}

//|++++++++++++++++++++++++++++++++++++|//
- (void)dealloc
{
    [_section release];
    [_segment release];
    
    [super dealloc];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - 	Values
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@synthesize segment = _segment;
@synthesize section = _section;
@synthesize offset = _offset;
@synthesize type = _type;

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_address_t)address
{
    // SAFE - Range check in initializer would have failed.
    return self.segment.vmAddress + self.offset;
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - 	MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_address_t)nodeAddress:(MKNodeAddressType)type
{
	// SAFE - _nodeOffset comes from the rebase commands, which are within the MKRebaseInfo.
	return [(MKBackedNode*)self.parent nodeAddress:type] + _nodeOffset;
}

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    MKNodeFieldBuilder *segment = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(segment)
        type:[MKNodeFieldTypeNode typeWithNodeType:MKSegment.class]
    ];
    segment.description = @"Segment";
    segment.options = MKNodeFieldOptionDisplayAsDetail | MKNodeFieldOptionIgnoreContainerContents | MKNodeFieldOptionHideAddressAndData;
    
    MKNodeFieldBuilder *section = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(section)
        type:[MKNodeFieldTypeNode typeWithNodeType:MKSection.class]
    ];
    section.description = @"Section";
    section.options = MKNodeFieldOptionDisplayAsDetail | MKNodeFieldOptionIgnoreContainerContents | MKNodeFieldOptionHideAddressAndData;
    
    MKNodeFieldBuilder *address = [MKNodeFieldBuilder
       builderWithProperty:MK_PROPERTY(address)
       type:MKNodeFieldTypeAddress.sharedInstance
    ];
    address.description = @"Address";
    address.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *type = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(type)
        type:MKNodeFieldRebaseType.sharedInstance
    ];
    type.description = @"Type";
    type.options = MKNodeFieldOptionDisplayAsDetail;
    
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        segment.build,
        section.build,
        address.build,
        type.build,
    ]];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - 	NSObject
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (NSString*)description
{
    NSString *type = nil;
    switch (self.type) {
        case MKRebaseTypePointer:
            type = @"pointer";
            break;
        case MKRebaseTypeTextAbsolute32:
            type = @"text abs32";
            break;
        case MKRebaseTypeTextPcrel32:
            type = @"text prcel32";
            break;
        default:
            break;
    }
    
    return [NSString stringWithFormat:@"%@ %@ 0x%.8" MK_VM_PRIxADDR " %@", self.segment.name, self.section.value.name, self.address, type];
}

@end
