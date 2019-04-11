//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKSection.m
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

#import "MKSection.h"
#import "MKInternal.h"
#import "MKMachO.h"
#import "MKSegment.h"
#import "MKLCSegment.h"
#import "MKLCSegment64.h"

//----------------------------------------------------------------------------//
@implementation MKSection

//|++++++++++++++++++++++++++++++++++++|//
+ (id*)_subclassesCache
{ static NSSet *subclasses; return &subclasses; }

//|++++++++++++++++++++++++++++++++++++|//
+ (uint32_t)canInstantiateWithSectionLoadCommand:(id<MKLCSection>)sectionLoadCommand inSegment:(MKSegment*)segment
{
#pragma unused (sectionLoadCommand)
#pragma unused (segment)
    if (self != MKSection.class)
        return 0;
    
    return 10;
}

//|++++++++++++++++++++++++++++++++++++|//
+ (Class)classForSectionLoadCommand:(id<MKLCSection>)sectionLoadCommand inSegment:(MKSegment*)segment;
{
    return [self bestSubclassWithRanking:^uint32_t(Class cls) {
        return [cls canInstantiateWithSectionLoadCommand:sectionLoadCommand inSegment:segment];
    }];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Creating a Section
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)sectionWithLoadCommand:(id<MKLCSection>)sectionLoadCommand inSegment:(MKSegment*)segment error:(NSError**)error
{
    Class sectionClass = [self classForSectionLoadCommand:sectionLoadCommand inSegment:segment];
    if (sectionClass == NULL) {
        NSString *reason = [NSString stringWithFormat:@"No section for load command: %@.", [(MKNode*)sectionLoadCommand nodeDescription]];
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:reason userInfo:nil];
    }
    
    return [[[sectionClass alloc] initWithLoadCommand:sectionLoadCommand inSegment:segment error:error] autorelease];
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithLoadCommand:(id<MKLCSection>)sectionLoadCommand inSegment:(MKSegment*)segment error:(NSError**)error
{
    NSParameterAssert(sectionLoadCommand != nil);
    NSParameterAssert(segment != nil);
    NSError *arithmeticError = nil;
    mk_error_t err;
    
    self = [super initWithParent:segment error:error];
    if (self == nil) return nil;
    
    _name = [[sectionLoadCommand sectname] copy];
    _loadCommand = [sectionLoadCommand retain];
    _alignment = [sectionLoadCommand align];
    _flags = [sectionLoadCommand flags];
    
    _vmAddress = [sectionLoadCommand mk_addr];
    _size = [sectionLoadCommand mk_size];
    _fileOffset = [sectionLoadCommand mk_offset];
    
    // Verify that this section is fully within it's segment's VM memory.
    if ((err = mk_vm_range_contains_range(mk_vm_range_make(segment.vmAddress, segment.vmSize), mk_vm_range_make(_vmAddress, _size), false))) {
        MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:err description:@"Section [%@] is not within segment: %@.", sectionLoadCommand, segment.nodeDescription];
        [self release]; return nil;
    }
    
    // Verify that the segment is fully within it's segment's file mapping.
    // This is not an error (assuming we can map the memory, see below).
    // If the section type is \c S_ZEROFILL then the section lies within the
    // zero-fill memory of its enclosing segment and has no corresponding
    // memory in the file.
    if (!(self.type == S_ZEROFILL) && (err = mk_vm_range_contains_range(mk_vm_range_make(segment.fileOffset, segment.fileSize), mk_vm_range_make(_fileOffset, _size), false))) {
        MK_PUSH_WARNING(fileOffset, MK_ENOT_FOUND, @"File offset [%" MK_VM_PRIxADDR "] is not within segment: %@.", _fileOffset, segment.nodeDescription);
    }
    
    // Determine the context address of this section.
    if (segment.macho.isFromMemory)
    {
        _nodeContextAddress = _vmAddress;
        _nodeContextSize = _size;
        
        // Slide the context address.
        {
            mk_vm_offset_t slide = (mk_vm_offset_t)segment.macho.slide;
            
            if ((err = mk_vm_address_apply_offset(_nodeContextAddress, slide, &_nodeContextAddress))) {
                arithmeticError = MK_MAKE_VM_ADDRESS_APPLY_SLIDE_ARITHMETIC_ERROR(err, _nodeContextAddress, slide);
                MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_EINTERNAL_ERROR underlyingError:arithmeticError description:@"Could not determine the context address."];
                [self release]; return nil;
            }
        }
    }
    else if (self.type == S_ZEROFILL || self.type == S_THREAD_LOCAL_ZEROFILL)
    {
        _nodeContextAddress = 0;
        _nodeContextSize = 0;
    }
    else
    {
        // SAFE - File range check would have failed if this could wrap around.
        _nodeContextAddress = _fileOffset - segment.fileOffset;
        _nodeContextSize = _size;
        
        if ((err = mk_vm_address_add(_nodeContextAddress, segment.nodeContextAddress, &_nodeContextAddress))) {
            arithmeticError = MK_MAKE_VM_ADDRESS_ADD_ARITHMETIC_ERROR(err, _nodeContextAddress, segment.nodeContextAddress);
            MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_EINTERNAL_ERROR underlyingError:arithmeticError description:@"Could not determine the context address."];
            [self release]; return nil;
        }
    }
    
    // This should have already been verified at the segment level but we'll
    // verify again.
    if (_nodeContextSize != 0 && [segment.memoryMap hasMappingAtOffset:0 fromAddress:_nodeContextAddress length:_size] == NO) {
        MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_ENOT_FOUND description:@"Section data does not exist in the memory map."];
        [self release]; return nil;
    }
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithParent:(MKNode*)parent error:(NSError**)error
{
#pragma unused(parent)
#pragma unused(error)
    // TODO - We could actually provide an implementation of this method.
    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"-initWithParent:error: unavailable." userInfo:nil];
}

//|++++++++++++++++++++++++++++++++++++|//
- (void)dealloc
{
    [_name release];
    [_loadCommand release];
    
    [super dealloc];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Section Values
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@synthesize name = _name;
@synthesize loadCommand = _loadCommand;
@synthesize alignment = _alignment;
@synthesize fileOffset = _fileOffset;
@synthesize vmAddress = _vmAddress;
@synthesize size = _size;

//|++++++++++++++++++++++++++++++++++++|//
- (MKSectionType)type
{ return _flags & SECTION_TYPE; }

//|++++++++++++++++++++++++++++++++++++|//
- (MKSectionUserAttributes)userAttributes
{ return _flags & SECTION_ATTRIBUTES_USR; }

//|++++++++++++++++++++++++++++++++++++|//
- (MKSectionSystemAttributes)systemAttributes
{ return _flags & SECTION_ATTRIBUTES_SYS; }

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
            break;
        case MKNodeVMAddress:
            return _vmAddress;
            break;
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
    name.description = @"Section Name";
    name.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *alignment = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(alignment)
        type:MKNodeFieldTypeDoubleWord.sharedInstance
    ];
    alignment.description = @"Alignment";
    alignment.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *fileOffset = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(fileOffset)
        type:MKNodeFieldTypeAddress.sharedInstance
    ];
    fileOffset.description = @"File offset";
    fileOffset.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *vmAddress = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(vmAddress)
        type:MKNodeFieldTypeAddress.sharedInstance
    ];
    vmAddress.description = @"VM Address";
    vmAddress.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *size = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(size)
        type:MKNodeFieldTypeSize.sharedInstance
    ];
    size.description = @"Size";
    size.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *type = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(type)
        type:MKNodeFieldSectionType.sharedInstance
    ];
    type.description = @"Section Type";
    type.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *userAttributes = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(userAttributes)
        type:MKNodeFieldSectionUserAttributesType.sharedInstance
    ];
    userAttributes.description = @"User Attributes";
    userAttributes.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *systemAttributes = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(systemAttributes)
        type:MKNodeFieldSectionUserAttributesType.sharedInstance
    ];
    systemAttributes.description = @"System Attributes";
    systemAttributes.options = MKNodeFieldOptionDisplayAsDetail;
    
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        name.build,
        alignment.build,
        fileOffset.build,
        vmAddress.build,
        size.build,
        type.build,
        userAttributes.build,
        systemAttributes.build
    ]];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  NSObject
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (NSString*)description
{ return [NSString stringWithFormat:@"%@,%@", self.loadCommand.segname, self.name]; }

@end
