//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKDylibLoadCommand.m
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

#import "MKDylibLoadCommand.h"
#import "MKInternal.h"
#import "MKMachO.h"
#import "MKCString.h"

//----------------------------------------------------------------------------//
@implementation MKDylibLoadCommand

@synthesize name = _name;
@synthesize timestamp = _timestamp;
@synthesize current_version = _current_version;
@synthesize compatibility_version = _compatibility_version;

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithOffset:(mk_vm_offset_t)offset fromParent:(MKBackedNode*)parent error:(NSError**)error
{
    self = [super initWithOffset:offset fromParent:parent error:error];
    if (self == nil) return nil;
    
    struct dylib_command lc;
    if ([self.memoryMap copyBytesAtOffset:offset fromAddress:parent.nodeContextAddress into:&lc length:sizeof(lc) requireFull:YES error:error] < sizeof(lc))
    { [self release]; return nil; }
    
    MKSwapLValue32(lc.dylib.name.offset, self.macho.dataModel);
    _name = [[MKCString alloc] initWithOffset:lc.dylib.name.offset fromParent:self error:error];
    
    MKSwapLValue32(lc.dylib.timestamp, self.macho.dataModel);
    _timestamp = [[NSDate alloc] initWithTimeIntervalSince1970:lc.dylib.timestamp];
    
    MKSwapLValue32(lc.dylib.current_version, self.macho.dataModel);
    _current_version = [[MKDylibVersion alloc] initWithMachVersion:lc.dylib.current_version];
    
    MKSwapLValue32(lc.dylib.compatibility_version, self.macho.dataModel);
    _compatibility_version = [[MKDylibVersion alloc] initWithMachVersion:lc.dylib.compatibility_version];
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (void)dealloc
{
    [_name release];
    [_timestamp release];
    [_current_version release];
    [_compatibility_version release];
    
    [super dealloc];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    __unused struct dylib_command dc;
    
    MKNodeFieldBuilder *offset = [MKNodeFieldBuilder
        builderWithProperty:@"name.nodeOffset"
        type:nil // TODO -
        offset:offsetof(struct dylib_command, dylib.name.offset)
        size:sizeof(dc.dylib.name.offset)
    ];
    offset.description = @"Str Offset";
    offset.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *timestamp = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(timestamp)
        type:nil // TODO -
        offset:offsetof(struct dylib_command, dylib.timestamp)
        size:sizeof(dc.dylib.timestamp)
    ];
    timestamp.description = @"Time Stamp";
    timestamp.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *current_version = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(current_version)
        type:nil // TODO -
        offset:offsetof(struct dylib_command, dylib.current_version)
        size:sizeof(dc.dylib.current_version)
    ];
    current_version.name = @"current version";
    current_version.description = @"Current Version";
    current_version.formatter = nil;
    current_version.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *compatibility_version = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(compatibility_version)
        type:nil // TODO -
        offset:offsetof(struct dylib_command, dylib.compatibility_version)
        size:sizeof(dc.dylib.compatibility_version)
    ];
    compatibility_version.name = @"compatibility version";
    compatibility_version.description = @"Compatibility Version";
    compatibility_version.formatter = nil;
    compatibility_version.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *name = [MKNodeFieldBuilder
        builderWithProperty:@"name"
        type:nil // TODO?
    ];
    name.description = @"Name";
    name.options = MKNodeFieldOptionDisplayAsDetail;
    
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        offset.build,
        timestamp.build,
        current_version.build,
        compatibility_version.build,
        name.build,
    ]];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - NSObject
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (NSString*)description
{ return [NSString stringWithFormat:@"%@ (%@)", super.description, [self.name.description componentsSeparatedByString:@"/"].lastObject]; }

@end
