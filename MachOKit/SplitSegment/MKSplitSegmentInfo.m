//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKSplitSegmentInfo.m
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

#import "MKSplitSegmentInfo.h"
#import "MKInternal.h"
#import "MKMachO.h"
#import "MKLCSegmentSplitInfo.h"
#import "MKSplitSegmentInfoV1.h"

//----------------------------------------------------------------------------//
@implementation MKSplitSegmentInfo

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithSize:(mk_vm_size_t)size offset:(mk_vm_offset_t)offset inImage:(MKMachOImage*)image error:(NSError**)error
{
    self = [super initWithSize:size offset:offset inImage:image error:error];
    if (self == nil) return nil;
    
    NSError *splitSegmentInfoError = nil;
    
    // Try initializing split segment v1
    {
        MKSplitSegmentInfoV1 *v1 = [[MKSplitSegmentInfoV1 alloc] initWithSize:size offset:offset inImage:image error:&splitSegmentInfoError];
        if (v1) {
            _impl = v1;
            return self;
        }
    }
    
    MK_ERROR_OUT = splitSegmentInfoError;
    [self release]; return nil;
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
    [_impl release];
    
    [super dealloc];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Values
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (MKSplitSegmentInfoV1*)v1
{
    if ([_impl isKindOfClass:MKSplitSegmentInfoV1.class])
        return _impl;
    else
        return nil;
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    MKNodeFieldBuilder *v1 = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(v1)
        type:[MKNodeFieldTypeNode typeWithNodeType:MKSplitSegmentInfoV1.class]
    ];
    v1.description = @"V1";
    v1.options = MKNodeFieldOptionDisplayAsChild;
    
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        v1.build
    ]];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  NSObject
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (NSString*)description
{ return @"Split Segment Info"; }

@end
