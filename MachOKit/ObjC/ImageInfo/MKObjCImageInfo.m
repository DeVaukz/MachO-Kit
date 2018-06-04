//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKObjCImageInfo.m
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

#import "MKObjCImageInfo.h"
#import "MKInternal.h"

#define SwiftVersionMaskShift   8
#define SwiftVersionMask        (0xff << SwiftVersionMaskShift)

struct objc_image_info {
    uint32_t version;
    uint32_t flags;
};

//----------------------------------------------------------------------------//
@implementation MKObjCImageInfo

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithOffset:(mk_vm_offset_t)offset fromParent:(MKBackedNode*)parent error:(NSError**)error
{
    self = [super initWithOffset:offset fromParent:parent error:error];
    if (self == nil) return nil;
    
    struct objc_image_info ii;
    NSError *imageInfoError = nil;
    
    if ([self.memoryMap copyBytesAtOffset:offset fromAddress:parent.nodeContextAddress into:&ii length:sizeof(ii) requireFull:YES error:&imageInfoError] < sizeof(ii)) {
        MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_EINTERNAL_ERROR underlyingError:imageInfoError description:@"Could not read image info."];
        [self release]; return nil;
    }
    
    _version = MKSwapLValue32(ii.version, self.dataModel);
    _flags = MKSwapLValue32(ii.flags, self.dataModel);
    
    return self;
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Image Info Values
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@synthesize version = _version;
@synthesize flags = _flags;

//|++++++++++++++++++++++++++++++++++++|//
- (MKObjCImageFlags)imageFlags
{ return _flags; }

//|++++++++++++++++++++++++++++++++++++|//
- (MKObjCImageSwiftVersion)swiftVersion
{ return (_flags & SwiftVersionMask) >> SwiftVersionMaskShift; }

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_size_t)nodeSize
{ return sizeof(struct objc_image_info); }

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    __unused struct objc_image_info ii;
    
    MKNodeFieldBuilder *version = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(version)
        type:MKNodeFieldTypeUnsignedDoubleWord.sharedInstance
        offset:offsetof(typeof(ii), version)
    ];
    version.description = @"Version";
    version.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *flags = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(flags)
        type:MKNodeFieldObjCImageInfoFlagsType.sharedInstance
        offset:offsetof(typeof(ii), flags)
    ];
    flags.description = @"Flags";
    flags.options = MKNodeFieldOptionDisplayAsDetail;
#ifdef TESTS
    flags.formatter = [NSFormatter mk_hexCompactFormatter];
#endif
    
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        version.build,
        flags.build
    ]];
}

@end
