//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKDSCSlideInfoBitmap.m
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

#import "MKDSCSlideInfoBitmap.h"
#import "MKDSCSlideInfo.h"
#import "MKDSCSlideInfoHeader.h"
#import "NSError+MK.h"

//----------------------------------------------------------------------------//
@implementation MKDSCSlideInfoBitmap

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithOffset:(mk_vm_offset_t)offset size:(mk_vm_size_t)size fromParent:(MKBackedNode*)parent error:(NSError**)error
{
    NSError *localError;
    
    self = [super initWithOffset:offset fromParent:parent error:error];
    if (self == nil) return nil;
    
    // Check that the data is available
    if ([self.memoryMap hasMappingAtOffset:offset fromAddress:parent.nodeContextAddress length:size error:&localError] == NO) {
        MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_ENOT_FOUND underlyingError:localError description:@"Bitmap does not exist at offset 0x%" MK_VM_PRIxOFFSET " from %@.", offset, parent];
        [self release]; return nil;
    }
    
    _size = size;
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithOffset:(mk_vm_offset_t)offset fromParent:(MKBackedNode*)parent error:(NSError**)error
{
    MKDSCSlideInfo *slideInfo = [parent nearestAncestorOfType:MKDSCSlideInfo.class];
    NSParameterAssert(slideInfo);
    
    MKDSCSlideInfoHeader *slideInfoHeader = slideInfo.header;
    NSParameterAssert(slideInfoHeader);
    
    mk_vm_offset_t entriesOffset = slideInfoHeader.entriesOffset;
    mk_vm_size_t entrySize = slideInfoHeader.entriesSize;
    uint32_t entryCount = slideInfoHeader.entriesCount;
    
    // Verify that offset is in range of the entries table.
    // Can not overflow - entriesOffset and entrySize were uint32
    if (offset < entriesOffset || offset > entriesOffset + entrySize*entryCount) {
        MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_EOUT_OF_RANGE description:@"Offset (%" MK_VM_PRIiOFFSET ") not in range of entry list.", offset];
        [self release]; return nil;
    }
    
    return [self initWithOffset:offset size:entrySize fromParent:slideInfo error:error];
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithParent:(MKNode*)parent error:(NSError**)error
{
    MKDSCSlideInfo *slideInfo = [parent nearestAncestorOfType:MKDSCSlideInfo.class];
    NSParameterAssert(slideInfo);
    
    MKDSCSlideInfoHeader *slideInfoHeader = slideInfo.header;
    NSParameterAssert(slideInfoHeader);
    
    return [self initWithOffset:slideInfoHeader.entriesOffset fromParent:slideInfo error:error];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@synthesize nodeSize = _size;

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{ return [super layout]; /* No fields here */ }

@end
