//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKDSCSlidPointer.m
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

#import "MKDSCSlidPointer.h"
#import "MKDSCSlideInfo.h"
#import "MKDSCSlideInfoPage.h"
#import "MKDSCSlideInfoBitmap.h"
#import "NSError+MK.h"

//----------------------------------------------------------------------------//
@implementation MKDSCSlidPointer

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithOffset:(uint32_t)bitOffset inEntryForPage:(MKDSCSlideInfoPage*)page error:(NSError**)error
{
    NSParameterAssert(page);
    
    MKDSCSlideInfo *slideInfo = [page nearestAncestorOfType:MKDSCSlideInfo.class];
    NSParameterAssert(slideInfo);
    
    self = [super initWithParent:slideInfo error:error];
    if (self == nil) return nil;
    
    _page = [page retain];
    
    // For performance we don't actually check if the bit is set.
    NSAssert(bitOffset <= page.bitmap.nodeSize * 8, @"Bit offset %" PRIu32 " is greater than the number of bits in bitmap %" MK_VM_PRIuSIZE ".", bitOffset, page.bitmap.nodeSize * 8);
    
    _bitOffset = bitOffset;
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithParent:(__unused MKNode*)parent error:(__unused NSError**)error
{
    // TODO - Could do something.
    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Use -initWithOffset:inEntryForPage:error: instead." userInfo:nil];
}

//|++++++++++++++++++++++++++++++++++++|//
- (void)dealloc
{
    [_page dealloc];
    
    [super dealloc];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Values
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@synthesize page = _page;

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_offset_t)pointerOffset
{
    return (_page.pageIndex * self.page.bitmap.nodeSize) + (_bitOffset * 4);
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_size_t)nodeSize
{ return _page.nodeSize; }

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_address_t)nodeAddress:(MKNodeAddressType)type
{ return [_page nodeAddress:type]; }

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        [MKNodeField nodeFieldWithProperty:MK_PROPERTY(pointerOffset) description:@"Pointer Offset"],
        [MKNodeField nodeFieldWithProperty:MK_PROPERTY(page) description:@"Page"]
    ]];
}

@end
