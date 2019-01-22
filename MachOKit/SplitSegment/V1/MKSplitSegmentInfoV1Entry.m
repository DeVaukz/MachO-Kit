//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKSplitSegmentInfoV1Entry.m
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

#import "MKSplitSegmentInfoV1Entry.h"
#import "MKInternal.h"
#import "MKSplitSegmentInfoV1Opcode.h"
#import "MKSplitSegmentInfoV1Offset.h"
#import "MKSplitSegmentInfoV1Terminator.h"

//----------------------------------------------------------------------------//
@implementation MKSplitSegmentInfoV1Entry

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithOffset:(mk_vm_offset_t)offset fromParent:(MKBackedNode*)parent error:(NSError**)error
{
    self = [super initWithOffset:offset fromParent:parent error:error];
    if (self == nil) return nil;
    
    offset = 0;
    
    // Read the opcode
    {
        NSError *opcodeError = nil;
        
        MKSplitSegmentInfoV1Opcode *opcodeNode = [[MKSplitSegmentInfoV1Opcode alloc] initWithOffset:offset fromParent:self error:&opcodeError];
        if (opcodeNode == nil) {
            MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_EINTERNAL_ERROR underlyingError:opcodeError description:@"Could not parse opcode at offset [%" MK_VM_PRIuOFFSET "].", offset];
            [self release]; return nil;
        }
        
        _opcode = opcodeNode;
        
        // TODO -
        offset += opcodeNode.nodeSize;
    }
    
    // Read the offsets
    @autoreleasepool
    {
        NSMutableArray<__kindof MKSplitSegmentInfoV1Offset*> *offsets = [[NSMutableArray alloc] init];
        
        while (1)
        {
            NSError *memoryMapError = nil;
            uint8_t nextByte;
            
            // Peek at the next byte
            if ([self.memoryMap copyBytesAtOffset:offset fromAddress:self.nodeContextAddress into:&nextByte length:sizeof(uint8_t) requireFull:YES error:&memoryMapError] < sizeof(uint8_t)) {
                MK_PUSH_WARNING_WITH_ERROR(offsets, MK_EINTERNAL_ERROR, memoryMapError, @"Could not read byte at offset [%" MK_VM_PRIuOFFSET "].", offset);
                break;
            }
            
            // It's a(nother) offset...
            if (nextByte != 0) {
                NSError *offsetError = nil;
                
                MKSplitSegmentInfoV1Offset *offsetNode = [[MKSplitSegmentInfoV1Offset alloc] initWithOffset:offset fromParent:self error:&offsetError];
                if (offsetNode == nil) {
                    MK_PUSH_WARNING_WITH_ERROR(offsets, MK_EINTERNAL_ERROR, offsetError, @"Could not parse offset at offset [%" MK_VM_PRIuOFFSET "].", offset);
                    break;
                }
                
                [offsets addObject:offsetNode];
                [offsetNode release];
                
                // TODO -
                offset += offsetNode.nodeSize;
            }
            // It's the terminator...
            else {
                NSError *terminatorError = nil;
                
                MKSplitSegmentInfoV1Terminator *terminatorNode = [[MKSplitSegmentInfoV1Terminator alloc] initWithOffset:offset fromParent:self error:&terminatorError];
                if (terminatorNode == nil) {
                    MK_PUSH_WARNING_WITH_ERROR(terminator, MK_EINTERNAL_ERROR, terminatorError, @"Could not parse terminator at offset [%" MK_VM_PRIuOFFSET "].", offset);
                    break;
                }
                
                _terminator = terminatorNode;
                
                // TODO -
                offset += terminatorNode.nodeSize;
                
                // We're finished
                break;
            }
        }
        
        _offsets = [offsets copy];
        [offsets release];
    }
    
    _nodeSize = offset;
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (void)dealloc
{
    [_terminator release];
    [_offsets release];
    [_opcode release];
    
    [super dealloc];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Values
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@synthesize opcode = _opcode;
@synthesize offsets = _offsets;
@synthesize terminator = _terminator;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_size_t)nodeSize
{ return _nodeSize; }

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    MKNodeFieldBuilder *opcode = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(opcode)
        type:[MKNodeFieldTypeNode typeWithNodeType:MKSplitSegmentInfoV1Opcode.class]
    ];
    opcode.description = @"Opcode";
    opcode.options = MKNodeFieldOptionDisplayAsDetail | MKNodeFieldOptionMergeContainerContents;
    
    MKNodeFieldBuilder *offsets = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(offsets)
        type:[MKNodeFieldTypeCollection typeWithCollectionType:[MKNodeFieldTypeNode typeWithNodeType:MKSplitSegmentInfoV1Offset.class]]
    ];
    offsets.description = @"Offsets";
    offsets.options = MKNodeFieldOptionDisplayAsDetail | MKNodeFieldOptionMergeContainerContents;
    
    MKNodeFieldBuilder *terminator = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(terminator)
        type:[MKNodeFieldTypeNode typeWithNodeType:MKSplitSegmentInfoV1Terminator.class]
    ];
    terminator.description = @"Terminator";
    terminator.options = MKNodeFieldOptionDisplayAsDetail | MKNodeFieldOptionMergeContainerContents;
    
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        opcode.build,
        offsets.build,
        terminator.build
    ]];
}

@end
