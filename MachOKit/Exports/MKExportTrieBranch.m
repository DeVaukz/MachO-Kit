//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKExportTrieBranch.m
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

#import "MKExportTrieBranch.h"
#import "MKInternal.h"
#import "MKLEB.h"
#import "MKCString.h"

//----------------------------------------------------------------------------//
@implementation MKExportTrieBranch

@synthesize prefix = _prefix;
@synthesize offset = _offset;

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithOffset:(mk_vm_offset_t)offset fromParent:(MKBackedNode*)parent error:(NSError**)error
{
	self = [super initWithOffset:offset fromParent:parent error:error];
	if (self == nil) return nil;
	
    offset = 0;
    
    // Read the prefix
    {
        NSError *stringError = nil;
        
        _prefix = [[MKCString alloc] initWithOffset:offset fromParent:self error:&stringError];
        if (_prefix == nil) {
            MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_EINTERNAL_ERROR underlyingError:stringError description:@"Could not read prefix."];
            [self release]; return nil;
        }
        
        offset += _prefix.nodeSize;
    }
    
    // Read the offset
    {
        NSError *ULEBError = nil;
        
        if (!MKULEBRead(self, offset, &_offset, &_offsetULEBSize, &ULEBError)) {
            MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_EINTERNAL_ERROR underlyingError:ULEBError description:@"Could not read offset."];
            [self release]; return nil;
        }
        
        //offset += _offsetULEBSize;
    }
    
	return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (void)dealloc
{
	[_prefix release];
	
	[super dealloc];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_size_t)nodeSize
{ return _prefix.nodeSize + _offsetULEBSize; }

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_size_t)offsetFieldSize
{ return _offsetULEBSize; }
- (mk_vm_offset_t)offsetFieldOffset
{
    return 0
        + self.prefix.nodeSize;
}

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
	MKNodeFieldBuilder *prefix = [MKNodeFieldBuilder
		builderWithProperty:MK_PROPERTY(prefix)
		type:[MKNodeFieldTypeNode typeWithNodeType:MKCString.class]
	];
	prefix.description = @"Node Label";
	prefix.options = MKNodeFieldOptionDisplayAsDetail | MKNodeFieldOptionIgnoreContainerContents;
	
	MKNodeFieldBuilder *offset = [MKNodeFieldBuilder
		builderWithProperty:MK_PROPERTY(offset)
		type:MKNodeFieldTypeUnsignedQuadWord.sharedInstance
	];
	offset.description = @"Next Node Offset";
    offset.dataRecipe = MKNodeFieldDataOperationExtractDynamicSubrange.sharedInstance;
	offset.options = MKNodeFieldOptionDisplayAsDetail;
	
	return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
		prefix.build,
		offset.build
	]];
}

@end
