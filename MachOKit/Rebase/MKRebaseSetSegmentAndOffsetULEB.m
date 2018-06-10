//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKRebaseSetSegmentAndOffsetULEB.m
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

#import "MKRebaseSetSegmentAndOffsetULEB.h"
#import "MKInternal.h"
#import "MKLEB.h"

//----------------------------------------------------------------------------//
@implementation MKRebaseSetSegmentAndOffsetULEB

//|++++++++++++++++++++++++++++++++++++|//
+ (uint8_t)opcode
{ return REBASE_OPCODE_SET_SEGMENT_AND_OFFSET_ULEB; }

//|++++++++++++++++++++++++++++++++++++|//
+ (NSString*)name
{ return @"REBASE_OPCODE_SET_SEGMENT_AND_OFFSET_ULEB"; }

//|++++++++++++++++++++++++++++++++++++|//
+ (uint32_t)canInstantiateWithOpcode:(uint8_t)opcode
{
    if (self != MKRebaseSetSegmentAndOffsetULEB.class)
        return 0;
    
    return opcode == [self opcode] ? 10 : 0;
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithOffset:(mk_vm_offset_t)offset fromParent:(MKBackedNode*)parent error:(NSError**)error
{
    self = [super initWithOffset:offset fromParent:parent error:error];
    if (self == nil) return nil;
	
	// Read the offset ULEB
	{
		NSError *ULEBError = nil;
		
		if (!MKULEBRead(self, 1, &_offset, &_offsetULEBSize, &ULEBError)) {
			MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_EINTERNAL_ERROR underlyingError:ULEBError description:@"Could not read offset."];
			[self release]; return nil;
		}
	}
	
    return self;
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - 	Performing Rebasing
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (BOOL)rebase:(void (^)(void))rebase withContext:(struct MKRebaseContext*)rebaseContext error:(NSError**)error
{
#pragma unused(rebase)
#pragma unused(error)
	rebaseContext->segmentIndex = self.segmentIndex;
	rebaseContext->offset = self.offset;
	
	return YES;
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - 	Rebase Command Values
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@synthesize offset = _offset;

//|++++++++++++++++++++++++++++++++++++|//
- (unsigned)segmentIndex
{ return _data & REBASE_IMMEDIATE_MASK; }

//|++++++++++++++++++++++++++++++++++++|//
- (uint64_t)derivedOffset
{ return self.offset; }

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - 	MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_size_t)nodeSize
{ return 1 + _offsetULEBSize; }

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_size_t)offsetFieldSize
{ return _offsetULEBSize; }
- (mk_vm_offset_t)offsetFieldOffset
{
    return 1;
}

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    MKNodeFieldBuilder *segmentIndex = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(segmentIndex)
        type:[MKNodeFieldTypeBitfield bitfieldWithType:MKNodeFieldTypeUnsignedByte.sharedInstance mask:@((uint8_t)REBASE_IMMEDIATE_MASK) name:nil]
        offset:0
        size:sizeof(uint8_t)
    ];
    segmentIndex.description = @"Segment";
    segmentIndex.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *offset = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(offset)
        type:MKNodeFieldTypeUnsignedQuadWord.sharedInstance
    ];
    offset.description = @"Offset";
    offset.dataRecipe = MKNodeFieldDataOperationExtractDynamicSubrange.sharedInstance;
    offset.options = MKNodeFieldOptionDisplayAsDetail;
    
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        segmentIndex.build,
        offset.build
    ]];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - 	NSObject
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (NSString*)description
{ return [NSString stringWithFormat:@"%@(%u, 0x%.8" PRIX64 ")", self.class.name, self.segmentIndex, self.offset]; }

@end
