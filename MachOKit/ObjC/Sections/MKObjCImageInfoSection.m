//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKObjCImageInfoSection.m
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

#import "MKObjCImageInfoSection.h"
#import "MKInternal.h"
#import "MKSegment.h"
#import "MKObjCImageInfo.h"

//----------------------------------------------------------------------------//
@implementation MKObjCImageInfoSection

@synthesize imageInfo = _imageInfo;

//|++++++++++++++++++++++++++++++++++++|//
+ (uint32_t)canInstantiateWithSectionLoadCommand:(id<MKLCSection>)sectionLoadCommand inSegment:(MKSegment*)segment
{
#pragma unused (segment)
    if (self != MKObjCImageInfoSection.class)
        return 0;
    
    if ([sectionLoadCommand.segname rangeOfString:@SEG_DATA].location == 0 &&
        [sectionLoadCommand.sectname isEqualToString:@"__objc_imageinfo"])
        return 50;
    
    return 0;
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithLoadCommand:(id<MKLCSection>)sectionLoadCommand inSegment:(MKSegment*)segment error:(NSError**)error
{
    self = [super initWithLoadCommand:sectionLoadCommand inSegment:segment error:error];
    if (self == nil) return nil;
 
    // Load the Image Info
    {
        NSError *imageInfoError = nil;
        
        MKObjCImageInfo *imageInfo = [[MKObjCImageInfo alloc] initWithOffset:0 fromParent:self error:&imageInfoError];
        if (imageInfo)
            _imageInfo = [[MKOptional alloc] initWithValue:imageInfo];
        else
            _imageInfo = [[MKOptional alloc] initWithError:imageInfoError];
        
        [imageInfo release];
    }
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (void)dealloc
{
    [_imageInfo release];
    
    [super dealloc];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - MKPointer
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (MKOptional*)childNodeOccupyingVMAddress:(mk_vm_address_t)address targetClass:(Class)targetClass
{
    MKObjCImageInfo *imageInfo = self.imageInfo.value;
    if (imageInfo) {
        mk_vm_range_t range = mk_vm_range_make(imageInfo.nodeVMAddress, imageInfo.nodeSize);
        if (mk_vm_range_contains_address(range, 0, address) == MK_ESUCCESS) {
            MKOptional *child = [imageInfo childNodeOccupyingVMAddress:address targetClass:targetClass];
            if (child.value)
                return child;
            // else, fallthrough and call the super's implementation.
            // The caller may actually be looking for *this* node.
        }
    }
    
    return [super childNodeOccupyingVMAddress:address targetClass:targetClass];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    MKNodeFieldBuilder *imageInfo = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(imageInfo)
        type:[MKNodeFieldTypeNode typeWithNodeType:MKObjCImageInfo.class]
    ];
    imageInfo.description = @"Image Info";
    imageInfo.options = MKNodeFieldOptionDisplayAsDetail | MKNodeFieldOptionMergeContainerContents;
    
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        imageInfo.build
    ]];
}

@end
