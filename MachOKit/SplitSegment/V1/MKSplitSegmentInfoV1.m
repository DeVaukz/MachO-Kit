//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKSplitSegmentInfoV1.m
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

#import "MKSplitSegmentInfoV1.h"
#import "MKInternal.h"
#import "MKMachO.h"
#import "MKLCSegmentSplitInfo.h"
#import "MKSplitSegmentInfoV1Entry.h"
#import "MKSplitSegmentInfoV1Opcode.h"
#import "MKSplitSegmentInfoV1Offset.h"
#import "MKSplitSegmentInfoV1Terminator.h"
#import "MKSplitSegmentInfoV1Fixup.h"

//----------------------------------------------------------------------------//
@implementation MKSplitSegmentInfoV1

@synthesize entries = _entries;
@synthesize terminator = _terminator;
@synthesize fixups = _fixups;

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithSize:(mk_vm_size_t)size offset:(mk_vm_offset_t)offset inImage:(MKMachOImage*)image error:(NSError**)error
{
    self = [super initWithSize:size offset:offset inImage:image error:error];
    if (self == nil) return nil;
    
    // Load entries
    @autoreleasepool
    {
        NSMutableArray<__kindof MKSplitSegmentInfoV1Entry*> *entries = [[NSMutableArray alloc] initWithCapacity:2];
        mk_vm_offset_t offset = 0;
        
        // Cast to mk_vm_size_t is safe; nodeSize can't be larger than UINT32_MAX.
        while (offset < self.nodeSize)
        {
            // Read one entry
            {
                NSError *entryError = nil;
                
                MKSplitSegmentInfoV1Entry *entry = [[MKSplitSegmentInfoV1Entry alloc] initWithOffset:offset fromParent:self error:&entryError];
                if (entry == nil) {
                    MK_PUSH_WARNING_WITH_ERROR(entries, MK_EINTERNAL_ERROR, entryError, @"Could not parse entry at offset [%" MK_VM_PRIuOFFSET "].", offset);
                    break;
                }
                
                [entries addObject:entry];
                [entry release];
                
                // TODO
                offset += entry.nodeSize;
            }
            
            // Check for a second terminator after the end of the entry.
            {
                NSError *memoryMapError = nil;
                uint8_t nextByte;
                
                if ([self.memoryMap copyBytesAtOffset:offset fromAddress:self.nodeContextAddress into:&nextByte length:sizeof(uint8_t) requireFull:YES error:&memoryMapError] < sizeof(uint8_t)) {
                    MK_PUSH_WARNING_WITH_ERROR(nil, MK_EINTERNAL_ERROR, memoryMapError, @"Could not read byte at offset [%" MK_VM_PRIuOFFSET "].", offset);
                    break;
                }
                
                // It's the terminator...
                if (nextByte == 0) {
                    NSError *terminatorError = nil;
                    
                    MKSplitSegmentInfoV1Terminator *terminatorNode = [[MKSplitSegmentInfoV1Terminator alloc] initWithOffset:offset fromParent:self error:&terminatorError];
                    if (terminatorNode == nil) {
                        MK_PUSH_WARNING_WITH_ERROR(terminator, MK_EINTERNAL_ERROR, terminatorError, @"Could not parse terminator at offset [%" MK_VM_PRIuOFFSET "].", offset);
                        break;
                    }
                    
                    _terminator = terminatorNode;
                    
                    // TODO
                    offset += terminatorNode.nodeSize;
                    
                    // We're finished
                    break;
                }
            }
        }
        
        _entries = [entries copy];
        [entries release];
    }
    
    // Determine the fixup addresses
    @autoreleasepool
    {
        NSMutableArray<MKSplitSegmentInfoV1Fixup*> *fixups = [[NSMutableArray alloc] initWithCapacity:(NSUInteger)size/3];
        
        mk_error_t err;
        NSError *fixupError = nil;
        struct MKSplitSegmentInfoV1Context context = { 0 };
        
        for (MKSplitSegmentInfoV1Entry *entry in _entries) {
            context.info = entry;
            context.type = entry.opcode.kind;
            context.address = 0;
            
            for (MKSplitSegmentInfoV1Offset *offset in entry.offsets) {
                context.offset = offset;
                
                mk_vm_offset_t nextOffset = offset.offset;
                // A zero offset should have been picked up as a terminator.
                NSAssert(nextOffset != 0, @"");
                
                if ((err = mk_vm_address_apply_offset(context.address, nextOffset, &context.address))) {
                    fixupError = MK_MAKE_VM_ADDRESS_APPLY_OFFSET_ARITHMETIC_ERROR(err, context.address, nextOffset);
                    MK_PUSH_WARNING_WITH_ERROR(fixups, MK_EINTERNAL_ERROR, fixupError, @"Fixup list generation failed at offset: %@.", context.offset.nodeDescription);
                    break;
                }
                
                MKSplitSegmentInfoV1Fixup *fixup = [[MKSplitSegmentInfoV1Fixup alloc] initWithContext:&context error:&fixupError];
                if (fixup == nil) {
                    MK_PUSH_WARNING_WITH_ERROR(fixups, MK_EINTERNAL_ERROR, fixupError, @"Fixup list generation failed at offset: %@.", context.offset.nodeDescription);
                    break;
                }
                
                [fixups addObject:fixup];
                [fixup release];
            }
        }
        
        _fixups = [fixups copy];
        [fixups release];
    }
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithImage:(MKMachOImage*)image error:(NSError**)error
{
    NSParameterAssert(image != nil);
    
    // Find LC_SEGMENT_SPLIT_INFO
    MKLCSegmentSplitInfo *segmentSplitInfoLoadCommand = nil;
    {
        NSArray<MKLCSegmentSplitInfo*> *commands = [image loadCommandsOfType:LC_SEGMENT_SPLIT_INFO];
        
        if (commands.count > 1)
            MK_PUSH_WARNING(nil, MK_EINVALID_DATA, @"Image contains multiple LC_SEGMENT_SPLIT_INFO load commands.  Ignoring %@.", commands.lastObject);
        
        if (commands.count == 0) {
            // Not an error - Image has no split segment information.
            [self release]; return nil;
        }
        
        segmentSplitInfoLoadCommand = [[commands.firstObject retain] autorelease];
    }
    
    return [self initWithSize:segmentSplitInfoLoadCommand.datasize offset:segmentSplitInfoLoadCommand.dataoff inImage:image error:error];
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithParent:(MKNode*)parent error:(NSError**)error
{ return [self initWithImage:parent.macho error:error]; }

//|++++++++++++++++++++++++++++++++++++|//
- (void)dealloc
{
    [_fixups release];
    [_terminator release];
    [_entries release];
    
    [super dealloc];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    MKNodeFieldBuilder *entries = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(entries)
        type:[MKNodeFieldTypeCollection typeWithCollectionType:[MKNodeFieldTypeNode typeWithNodeType:MKSplitSegmentInfoV1Entry.class]]
    ];
    entries.description = @"Offsets";
    entries.options = MKNodeFieldOptionDisplayAsDetail | MKNodeFieldOptionMergeContainerContents;
    
    MKNodeFieldBuilder *terminator = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(terminator)
        type:[MKNodeFieldTypeNode typeWithNodeType:MKSplitSegmentInfoV1Terminator.class]
    ];
    terminator.description = @"Terminator";
    terminator.options = MKNodeFieldOptionDisplayAsDetail | MKNodeFieldOptionMergeContainerContents;
    
    MKNodeFieldBuilder *fixups = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(fixups)
        type:[MKNodeFieldTypeCollection typeWithCollectionType:[MKNodeFieldTypeNode typeWithNodeType:MKSplitSegmentInfoV1Fixup.class]]
    ];
    fixups.description = @"Fixups";
    fixups.options = MKNodeFieldOptionDisplayAsChild | MKNodeFieldOptionDisplayContainerContentsAsDetail;
    
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        entries.build,
        terminator.build,
        fixups.build
    ]];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  NSObject
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (NSString*)description
{ return @"V1"; }

@end
