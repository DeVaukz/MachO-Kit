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
#import "MKMachO.h"
#import "MKNodeFieldCPUType.h"
#import "MKNodeFieldCPUSubType.h"

//----------------------------------------------------------------------------//
@implementation MKMachHeader

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithOffset:(mk_vm_offset_t)offset fromParent:(MKBackedNode*)parent error:(NSError**)error
{
    NSParameterAssert(parent.dataModel);
    
    self = [super initWithOffset:offset fromParent:parent error:error];
    if (self == nil) return nil;
    
    struct mach_header lc;
    if ([self.memoryMap copyBytesAtOffset:offset fromAddress:parent.nodeContextAddress into:&lc length:sizeof(lc) requireFull:YES error:error] < sizeof(lc))
    { [self release]; return nil; }
    
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
- (mach_vm_size_t)nodeSize
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
        type:[MKNodeFieldTypeEnumeration enumerationWithUnderlyingType:MKNodeFieldTypeUnsignedDoubleWord.sharedInstance name:nil elements:@{
            @((typeof(mh.magic))MH_OBJECT): @"MH_OBJECT",
            @((typeof(mh.magic))MH_EXECUTE): @"MH_EXECUTE",
            @((typeof(mh.magic))MH_FVMLIB): @"MH_FVMLIB",
            @((typeof(mh.magic))MH_CORE): @"MH_CORE",
            @((typeof(mh.magic))MH_PRELOAD): @"MH_PRELOAD",
            @((typeof(mh.magic))MH_DYLIB): @"MH_DYLIB",
            @((typeof(mh.magic))MH_DYLINKER): @"MH_DYLINKER",
            @((typeof(mh.magic))MH_BUNDLE): @"MH_BUNDLE",
            @((typeof(mh.magic))MH_DYLIB_STUB): @"MH_DYLIB_STUB",
            @((typeof(mh.magic))MH_DSYM): @"MH_DSYM",
            @((typeof(mh.magic))MH_KEXT_BUNDLE): @"MH_KEXT_BUNDLE"
        }]
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
        type:[MKNodeFieldTypeOptionSet optionSetWithUnderlyingType:MKNodeFieldTypeUnsignedDoubleWord.sharedInstance name:nil options:@{
            @((typeof(mh.flags))MH_NOUNDEFS): @"MH_NOUNDEFS",
            @((typeof(mh.flags))MH_INCRLINK): @"MH_INCRLINK",
            @((typeof(mh.flags))MH_DYLDLINK): @"MH_DYLDLINK",
            @((typeof(mh.flags))MH_BINDATLOAD): @"MH_BINDATLOAD",
            @((typeof(mh.flags))MH_SPLIT_SEGS): @"MH_SPLIT_SEGS",
            @((typeof(mh.flags))MH_LAZY_INIT): @"MH_LAZY_INIT",
            @((typeof(mh.flags))MH_TWOLEVEL): @"MH_TWOLEVEL",
            @((typeof(mh.flags))MH_FORCE_FLAT): @"MH_FORCE_FLAT",
            @((typeof(mh.flags))MH_NOMULTIDEFS): @"MH_NOMULTIDEFS",
            @((typeof(mh.flags))MH_NOFIXPREBINDING): @"MH_NOFIXPREBINDING",
            @((typeof(mh.flags))MH_PREBINDABLE): @"MH_PREBINDABLE",
            @((typeof(mh.flags))MH_ALLMODSBOUND): @"MH_ALLMODSBOUND",
            @((typeof(mh.flags))MH_SUBSECTIONS_VIA_SYMBOLS): @"MH_SUBSECTIONS_VIA_SYMBOLS",
            @((typeof(mh.flags))MH_WEAK_DEFINES): @"MH_WEAK_DEFINES",
            @((typeof(mh.flags))MH_BINDS_TO_WEAK): @"MH_BINDS_TO_WEAK",
            @((typeof(mh.flags))MH_ALLOW_STACK_EXECUTION): @"MH_ALLOW_STACK_EXECUTION",
            @((typeof(mh.flags))MH_ROOT_SAFE): @"MH_ROOT_SAFE",
            @((typeof(mh.flags))MH_SETUID_SAFE): @"MH_SETUID_SAFE",
            @((typeof(mh.flags))MH_NO_REEXPORTED_DYLIBS): @"MH_NO_REEXPORTED_DYLIBS",
            @((typeof(mh.flags))MH_PIE): @"MH_PIE",
            @((typeof(mh.flags))MH_DEAD_STRIPPABLE_DYLIB): @"MH_DEAD_STRIPPABLE_DYLIB",
            @((typeof(mh.flags))MH_HAS_TLV_DESCRIPTORS): @"MH_HAS_TLV_DESCRIPTORS",
            @((typeof(mh.flags))MH_NO_HEAP_EXECUTION): @"MH_NO_HEAP_EXECUTION",
            @((typeof(mh.flags))MH_APP_EXTENSION_SAFE): @"MH_APP_EXTENSION_SAFE",
        }]
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
