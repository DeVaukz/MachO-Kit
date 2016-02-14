//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKDSCSlideInfoPage.m
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

#import "MKDSCSlideInfoPage.h"
#import "MKDSCSlideInfo.h"
#import "MKDSCSlideInfoHeader.h"
#import "NSError+MK.h"

//----------------------------------------------------------------------------//
@implementation MKDSCSlideInfoPage

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithOffset:(mk_vm_offset_t)offset fromParent:(MKBackedNode*)parent error:(NSError**)error
{
    MKDSCSlideInfo *slideInfo = [parent nearestAncestorOfType:MKDSCSlideInfo.class];
    NSParameterAssert(slideInfo);
    
    MKDSCSlideInfoHeader *slideInfoHeader = slideInfo.header;
    NSParameterAssert(slideInfoHeader);
    
    mk_vm_offset_t tocOffset = slideInfoHeader.tocOffset;
    uint32_t tocCount = slideInfoHeader.tocCount;
    
    // Verify that offset is in range of the TOC.
    // Can not overflow - tocOffset is uint32
    if (offset < tocOffset || offset > tocOffset + tocCount*sizeof(uint16_t)) {
        MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_EOUT_OF_RANGE description:@"Offset (%" MK_VM_PRIiOFFSET ") not in range of TOC.", offset];
        [self release]; return nil;
    }
    
    self = [super initWithOffset:offset fromParent:parent error:error];
    if (self == nil) return nil;
    
    if ([self.memoryMap copyBytesAtOffset:offset fromAddress:parent.nodeContextAddress into:&_entryIndex length:sizeof(uint16_t) requireFull:YES error:error] < sizeof(uint16_t))
    { [self release]; return nil; }
    
    // Lookup the corresponding bitmap.
    if (_entryIndex < slideInfo.entries.count)
        _bitmap = [slideInfo.entries[_entryIndex] retain];
    else
        MK_PUSH_WARNING(bitmap, MK_ENOT_FOUND, @"No bitmap at index %" PRIu16 " in entries table.", _entryIndex);
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithParent:(MKNode*)parent error:(NSError**)error
{
    MKDSCSlideInfo *slideInfo = [parent nearestAncestorOfType:MKDSCSlideInfo.class];
    NSParameterAssert(slideInfo);
    
    MKDSCSlideInfoHeader *slideInfoHeader = slideInfo.header;
    NSParameterAssert(slideInfoHeader);
    
    return [self initWithOffset:slideInfoHeader.tocOffset fromParent:slideInfo error:error];
}

//|++++++++++++++++++++++++++++++++++++|//
- (void)dealloc
{
    [_bitmap release];
    
    [super dealloc];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Values
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@synthesize entryIndex = _entryIndex;
@synthesize bitmap = _bitmap;

//|++++++++++++++++++++++++++++++++++++|//
- (uint32_t)pageIndex
{
    return (uint32_t)(self.nodeOffset / sizeof(uint16_t));
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_size_t)nodeSize
{ return sizeof(uint16_t); }

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        [MKNodeField nodeFieldWithProperty:MK_PROPERTY(pageIndex) description:@"Page Index"],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(entryIndex) description:@"Entry Index" offset:0 size:sizeof(uint16_t)],
        [MKNodeField nodeFieldWithProperty:MK_PROPERTY(bitmap) description:@"Bitmap"]
    ]];
}

@end
