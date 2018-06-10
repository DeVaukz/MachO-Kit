//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKRebaseDoRebaseULEBTimesSkippingULEB.m
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

#import "MKRebaseDoRebaseULEBTimesSkippingULEB.h"
#import "MKInternal.h"
#import "MKLEB.h"

//----------------------------------------------------------------------------//
@implementation MKRebaseDoRebaseULEBTimesSkippingULEB

//|++++++++++++++++++++++++++++++++++++|//
+ (uint8_t)opcode
{ return REBASE_OPCODE_DO_REBASE_ULEB_TIMES_SKIPPING_ULEB; }

//|++++++++++++++++++++++++++++++++++++|//
+ (NSString*)name
{ return @"REBASE_OPCODE_DO_REBASE_ULEB_TIMES_SKIPPING_ULEB"; }

//|++++++++++++++++++++++++++++++++++++|//
+ (uint32_t)canInstantiateWithOpcode:(uint8_t)opcode
{
    if (self != MKRebaseDoRebaseULEBTimesSkippingULEB.class)
        return 0;
    
    return opcode == [self opcode] ? 10 : 0;
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithOffset:(mk_vm_offset_t)offset fromParent:(MKBackedNode*)parent error:(NSError**)error
{
    self = [super initWithOffset:offset fromParent:parent error:error];
    if (self == nil) return nil;
	
	offset = 1;
	
	// Read the count ULEB
	{
		NSError *ULEBError = nil;
		
		if (!MKULEBRead(self, offset, &_count, &_countULEBSize, &ULEBError)) {
			MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_EINTERNAL_ERROR underlyingError:ULEBError description:@"Could not read count."];
			[self release]; return nil;
		}
		
		offset += _countULEBSize;
	}
	
	// Read the skip ULEB
	{
		NSError *ULEBError = nil;
		
		if (!MKULEBRead(self, offset, &_skip, &_skipULEBSize, &ULEBError)) {
			MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_EINTERNAL_ERROR underlyingError:ULEBError description:@"Could not read skip."];
			[self release]; return nil;
		}
		
		//offset += _skipULEBSize;
	}
    
    return self;
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - 	Performing Rebasing
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (BOOL)rebase:(void (^)(void))rebase withContext:(struct MKRebaseContext*)rebaseContext error:(NSError**)error
{
	for (uint64_t i = 0; i < self.count; i++) {
		rebase();
		
		mk_error_t err;
		if ((err = mk_vm_offset_add(rebaseContext->offset, self.derivedOffset, &rebaseContext->offset))) {
			MK_ERROR_OUT = MK_MAKE_VM_OFFSET_ADD_ARITHMETIC_ERROR(err, rebaseContext->offset, self.derivedOffset);
			return NO;
		}
	}
	
	// Reset
	rebaseContext->command = nil;
	
	return YES;
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - 	Rebase Command Values
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@synthesize count = _count;
@synthesize skip = _skip;

//|++++++++++++++++++++++++++++++++++++|//
- (uint64_t)derivedOffset
{ return self.skip + self.dataModel.pointerSize; }

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - 	MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_size_t)nodeSize
{ return 1 + _countULEBSize + _skipULEBSize; }

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_size_t)countFieldSize
{ return _countULEBSize; }
- (mk_vm_offset_t)countFieldOffset
{
    return 1;
}

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_size_t)skipFieldSize
{ return _skipULEBSize; }
- (mk_vm_offset_t)skipFieldOffset
{
    return 1
        + _countULEBSize;
}

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    MKNodeFieldBuilder *count = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(count)
        type:MKNodeFieldTypeUnsignedQuadWord.sharedInstance
    ];
    count.description = @"Rebase Count";
    count.dataRecipe = MKNodeFieldDataOperationExtractDynamicSubrange.sharedInstance;
    count.options = MKNodeFieldOptionDisplayAsDetail;
	
    MKNodeFieldBuilder *skip = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(skip)
        type:MKNodeFieldTypeUnsignedQuadWord.sharedInstance
    ];
    skip.description = @"Skip";
    skip.dataRecipe = MKNodeFieldDataOperationExtractDynamicSubrange.sharedInstance;
    skip.options = MKNodeFieldOptionDisplayAsDetail;
	
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        count.build,
        skip.build
    ]];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - 	NSObject
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (NSString*)description
{ return [NSString stringWithFormat:@"%@(%" PRIu64 ", %" PRIu64 ")", self.class.name, self.count, self.skip]; }

@end
