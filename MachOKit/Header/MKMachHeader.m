//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKMachHeader.m
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

#import "MKMachHeader.h"
#import "MKInternal.h"
#import "MKNodeFieldCPUType.h"
#import "MKNodeFieldCPUSubType.h"
#import "MKNodeFieldMachOFileType.h"
#import "MKNodeFieldMachOFlagsType.h"

//----------------------------------------------------------------------------//
@implementation MKMachHeader

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithOffset:(mk_vm_offset_t)offset fromParent:(MKBackedNode*)parent error:(NSError**)error
{
    self = [super initWithOffset:offset fromParent:parent error:error];
    if (self == nil) return nil;
    
    struct mach_header lc;
    NSError *memoryMapError = nil;
    
    if ([self.memoryMap copyBytesAtOffset:0 fromAddress:self.nodeContextAddress into:&lc length:sizeof(lc) requireFull:YES error:error] < sizeof(lc)) {
        MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_EINTERNAL_ERROR underlyingError:memoryMapError description:@"Could not read header."];
        [self release]; return nil;
    }
    
    _magic = MKSwapLValue32(lc.magic, self.dataModel);
    _cputype = MKSwapLValue32s(lc.cputype, self.dataModel);
    _cpusubtype = MKSwapLValue32s(lc.cpusubtype, self.dataModel);
    _filetype = MKSwapLValue32(lc.filetype, self.dataModel);
    _ncmds = MKSwapLValue32(lc.ncmds, self.dataModel);
    _sizeofcmds = MKSwapLValue32(lc.sizeofcmds, self.dataModel);
    _flags = MKSwapLValue32(lc.flags, self.dataModel);
    
    return self;
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Mach-O Header Values
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@synthesize magic = _magic;
@synthesize cputype = _cputype;
@synthesize cpusubtype = _cpusubtype;
@synthesize filetype = _filetype;
@synthesize ncmds = _ncmds;
@synthesize sizeofcmds = _sizeofcmds;
@synthesize flags = _flags;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_size_t)nodeSize
{ return sizeof(struct mach_header); }

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    __unused struct mach_header mh;
    
    MKNodeFieldBuilder *magic = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(magic)
        type:[MKNodeFieldTypeEnumeration enumerationWithUnderlyingType:MKNodeFieldTypeUnsignedDoubleWord.sharedInstance name:nil elements:@{
            @((typeof(mh.magic))MH_MAGIC): @"MH_MAGIC",
            @((typeof(mh.magic))MH_CIGAM): @"MH_CIGAM",
            @((typeof(mh.magic))MH_MAGIC_64): @"MH_MAGIC_64",
            @((typeof(mh.magic))MH_CIGAM_64): @"MH_CIGAM_64",
        }]
        offset:offsetof(typeof(mh), magic)
    ];
    magic.description = @"Magic Number";
    magic.formatter = [MKFormatterChain formatterChainWithLastFormatter:NSFormatter.mk_uppercaseHexFormatter, magic.formatter, nil];
    magic.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *cputype = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(cputype)
        type:MKNodeFieldCPUType.sharedInstance
        offset:offsetof(typeof(mh), cputype)
    ];
    cputype.description = @"CPU Type";
    cputype.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *cpusubtype = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(cpusubtype)
        type:[MKNodeFieldCPUSubType cpuSubTypeForCPUType:self.cputype]
        offset:offsetof(typeof(mh), cpusubtype)
    ];
    cpusubtype.description = @"CPU SubType";
    cpusubtype.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *filetype = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(filetype)
        type:MKNodeFieldMachOFileType.sharedInstance
        offset:offsetof(typeof(mh), filetype)
    ];
    filetype.description = @"File Type";
    filetype.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *ncmds = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(ncmds)
        type:MKNodeFieldTypeUnsignedDoubleWord.sharedInstance
        offset:offsetof(typeof(mh), ncmds)
    ];
    ncmds.description = @"Number of Load Commands";
    ncmds.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *sizeofcmds = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(sizeofcmds)
        type:MKNodeFieldTypeUnsignedDoubleWord.sharedInstance
        offset:offsetof(typeof(mh), sizeofcmds)
    ];
    sizeofcmds.description = @"Size of Load Commands";
    sizeofcmds.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *flags = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(flags)
        type:MKNodeFieldMachOFlagsType.sharedInstance
        offset:offsetof(typeof(mh), flags)
    ];
    flags.description = @"Flags";
    flags.options = MKNodeFieldOptionDisplayAsDetail;
    
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        magic.build,
        cputype.build,
        cpusubtype.build,
        filetype.build,
        ncmds.build,
        sizeofcmds.build,
        flags.build
    ]];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  NSObject
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (NSString*)description
{ return @"Mach Header"; }

@end
