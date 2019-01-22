//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKSplitSegmentInfoV1Fixup.m
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

#import "MKSplitSegmentInfoV1Fixup.h"
#import "MKInternal.h"
#import "MKSplitSegmentInfoV1.h"
#import "MKSplitSegmentInfoV1Offset.h"

//----------------------------------------------------------------------------//
@implementation MKSplitSegmentInfoV1Fixup

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithContext:(struct MKSplitSegmentInfoV1Context*)context error:(NSError**)error
{
    NSParameterAssert(context->info != nil);
    
    self = [super initWithParent:context->offset error:error];
    if (self == nil) return nil;
    
    _address = context->address;
    
    // TODO - Should this be factored into subclasses?
    if (context->type >= DYLD_CACHE_ADJ_V1_ARM_MOVT) {
        _kind = DYLD_CACHE_ADJ_V1_ARM_MOVT;
        _extra = context->type - DYLD_CACHE_ADJ_V1_ARM_MOVT;
    }
    else if (context->type >= DYLD_CACHE_ADJ_V1_ARM_THUMB_MOVT) {
        _kind = DYLD_CACHE_ADJ_V1_ARM_THUMB_MOVT;
        _extra = context->type - DYLD_CACHE_ADJ_V1_ARM_THUMB_MOVT;
    }
    else {
        _kind = context->type;
        _extra = 0;
    }
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithParent:(MKNode*)parent error:(NSError**)error
{
#pragma unused(parent)
#pragma unused(error)
    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"-initWithParent:error: unavailable." userInfo:nil];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Values
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@synthesize address = _address;
@synthesize kind = _kind;
@synthesize extra = _extra;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_address_t)nodeAddress:(MKNodeAddressType)type
{ return [(MKBackedNode*)self.parent nodeAddress:type]; }

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    MKNodeFieldBuilder *address = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(address)
        type:MKNodeFieldTypeAddress.sharedInstance
    ];
    address.description = @"Address";
    address.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *kind = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(kind)
        type:MKNodeFieldSplitSegmentInfoV1FixupType.sharedInstance
    ];
    kind.description = @"Kind";
    kind.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *extra = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(extra)
        type:MKNodeFieldTypeUnsignedByte.sharedInstance
    ];
    extra.description = @"Extra";
    extra.options = MKNodeFieldOptionDisplayAsDetail;
    
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        address.build,
        kind.build,
        extra.build
    ]];
}

@end
