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
#import "NSError+MK.h"
#import "MKBackedNode+Pointer.h"
#import "MKMachO.h"
#import "MKRebaseInfo.h"
#import "MKRebaseCommand.h"
#import "MKMachO+Segments.h"
#import "MKSegment.h"

//----------------------------------------------------------------------------//
@implementation MKFixup

//|++++++++++++++++++++++++++++++++++++|//
- (nullable instancetype)initWithType:(uint8_t)type offset:(mk_vm_offset_t)offset segment:(unsigned)segmentIndex atCommand:(MKRebaseCommand*)command error:(NSError**)error
{
    self = [super initWithOffset:command.nodeOffset fromParent:(MKBackedNode*)command.parent error:error];
    if (self == nil) return nil;
    
    _type = type;
    _offset = offset;
    _nodeSize = command.nodeSize;
    
    // Lookup the segment
    _segment = [self.macho.segments[@(segmentIndex)] retain];
    if (_segment == nil) {
        MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_ENOT_FOUND description:@"No segment at index %u.", segmentIndex];
        [self release]; return nil;
    }
    
    // Verify that the offset is within section
    mk_error_t err;
    mk_vm_address_t segmentAddress = _segment.vmAddress;
    
    mk_vm_range_t segmentRange = mk_vm_range_make(segmentAddress, _segment.vmSize);
    if ((err = mk_vm_range_contains_address(segmentRange, _offset, segmentAddress))) {
        MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_EOUT_OF_RANGE description:@"Section at index %u does not contain the provided offset (%" MK_VM_PRIiOFFSET ").", segmentIndex];
        [self release]; return nil;
    }
    
    // Try to find the section
    _section = [_segment childNodeAtVMAddress:self.address];
    if ([_section isKindOfClass:MKSection.class])
        _section = [_section retain];
    else
        _section = nil;
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithOffset:(mk_vm_offset_t)offset fromParent:(MKBackedNode*)parent error:(NSError**)error
{
#pragma unused(offset)
#pragma unused(parent)
#pragma unused(error)
    @throw [NSException exceptionWithName:NSGenericException reason:@"Unavailable" userInfo:nil];
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithParent:(MKNode*)parent error:(NSError**)error
{
#pragma unused(parent)
#pragma unused(error)
    @throw [NSException exceptionWithName:NSGenericException reason:@"Unavailable" userInfo:nil];
}

//|++++++++++++++++++++++++++++++++++++|//
- (void)dealloc
{
    [_section release];
    [_segment release];
    
    [super dealloc];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - Values
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
#pragma mark - MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@synthesize nodeSize = _nodeSize;

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        [MKNodeField nodeFieldWithProperty:MK_PROPERTY(segment) description:@"Segment"],
        [MKNodeField nodeFieldWithProperty:MK_PROPERTY(section) description:@"Section"],
        [MKNodeField nodeFieldWithProperty:MK_PROPERTY(address) description:@"Address"],
        [MKNodeField nodeFieldWithProperty:MK_PROPERTY(type) description:@"Type"],
    ]];
}

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
    
    return [NSString stringWithFormat:@"%@ %@ 0x%.8" MK_VM_PRIxADDR " %@", self.segment.name, self.section.name, self.address, type];
}

@end
