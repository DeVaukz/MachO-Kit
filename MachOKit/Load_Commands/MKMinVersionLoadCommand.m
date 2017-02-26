//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKMinVersionLoadCommand.m
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

#import "MKMinVersionLoadCommand.h"
#import "MKInternal.h"
#import "MKMachO.h"

//----------------------------------------------------------------------------//
@implementation MKMinVersionLoadCommand

@synthesize version = _version;
@synthesize sdk = _sdk;

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithOffset:(mk_vm_offset_t)offset fromParent:(MKBackedNode*)parent error:(NSError**)error
{
    self = [super initWithOffset:offset fromParent:parent error:error];
    if (self == nil) return nil;
    
    struct version_min_command lc;
    if ([self.memoryMap copyBytesAtOffset:offset fromAddress:parent.nodeContextAddress into:&lc length:sizeof(lc) requireFull:YES error:error] < sizeof(lc))
    { [self release]; return nil; }
    
    MKSwapLValue32(lc.version, self.macho.dataModel);
    _version = [[MKVersion alloc] initWithMachVersion:lc.version];
    if (_version == nil) { [self release]; return nil; }
    
    MKSwapLValue32(lc.sdk, self.macho.dataModel);
    _sdk = [[MKVersion alloc] initWithMachVersion:lc.sdk];
    if (_sdk == nil) { [self release]; return nil; }
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (void)dealloc
{
    [_version release];
    [_sdk release];
    
    [super dealloc];
}

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    __unused struct version_min_command vmc;
    
    MKNodeFieldBuilder *version = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(version)
        type:nil // TODO -
        offset:offsetof(struct version_min_command, version)
        size:sizeof(vmc.version)
    ];
    version.description = @"Version";
    version.formatter = nil;
    version.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *sdk = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(sdk)
        type:nil // TODO -
        offset:offsetof(struct version_min_command, sdk)
        size:sizeof(vmc.sdk)
    ];
    sdk.description = @"SDK";
    sdk.formatter = nil;
    sdk.options = MKNodeFieldOptionDisplayAsDetail;
    
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        version.build,
        sdk.build
    ]];
}

@end
