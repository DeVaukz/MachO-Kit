//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKFatArch.m
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

#import "MKFatArch.h"
#import "MKInternal.h"
#import "MKNodeFieldCPUType.h"
#import "MKNodeFieldCPUSubType.h"

#include <mach-o/fat.h>

//----------------------------------------------------------------------------//
@implementation MKFatArch

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithOffset:(mk_vm_offset_t)offset fromParent:(MKBackedNode*)parent error:(NSError**)error
{
    self = [super initWithOffset:offset fromParent:parent error:error];
    if (self == nil) return nil;
    
    struct fat_arch slice;
    NSError *memoryMapError = nil;
    
    if ([self.memoryMap copyBytesAtOffset:0 fromAddress:self.nodeContextAddress into:&slice length:sizeof(slice) requireFull:YES error:&memoryMapError] < sizeof(slice)) {
        MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_EINTERNAL_ERROR underlyingError:memoryMapError description:@"Could not read fat_arch."];
        [self release]; return nil;
    }
    
    _cputype = MKSwapLValue32s(slice.cputype, self.dataModel);
    _cpusubtype = MKSwapLValue32s(slice.cpusubtype, self.dataModel);
    _offset = MKSwapLValue32(slice.offset, self.dataModel);
    _size = MKSwapLValue32(slice.size, self.dataModel);
    _align = 1 << MKSwapLValue32(slice.align, self.dataModel);
    
    return self;
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Values
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (mk_architecture_t)architecture
{ return mk_architecture_create(self.cputype, self.cpusubtype); }

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  fat_arch Values
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@synthesize cputype = _cputype;
@synthesize cpusubtype = _cpusubtype;
@synthesize offset = _offset;
@synthesize size = _size;
@synthesize align = _align;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_size_t)nodeSize
{ return sizeof(struct fat_arch); }

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    MKNodeFieldBuilder *cpuType = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(cputype)
        type:MKNodeFieldCPUType.sharedInstance
        offset:offsetof(struct fat_arch, cputype)
    ];
    cpuType.description = @"CPU Type";
    cpuType.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *cpuSubType = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(cpusubtype)
        type:[MKNodeFieldCPUSubType cpuSubTypeForCPUType:self.cputype]
        offset:offsetof(struct fat_arch, cpusubtype)
    ];
    cpuSubType.description = @"CPU SubType";
    cpuSubType.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *offset = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(offset)
        type:MKNodeFieldTypeDoubleWord.sharedInstance
        offset:offsetof(struct fat_arch, offset)
    ];
    offset.description = @"Offset";
    offset.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *size = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(size)
        type:MKNodeFieldTypeDoubleWord.sharedInstance
        offset:offsetof(struct fat_arch, size)
    ];
    size.description = @"Size";
    size.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *alignment = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(align)
        type:MKNodeFieldTypeDoubleWord.sharedInstance
        offset:offsetof(struct fat_arch, align)
    ];
    alignment.description = @"Alignment";
    alignment.options = MKNodeFieldOptionDisplayAsDetail;
    
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        cpuType.build,
        cpuSubType.build,
        offset.build,
        size.build,
        alignment.build
    ]];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  NSObject
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (NSString*)description
{
    char description[50];
    size_t descriptionLen = mk_architecture_copy_description(self.architecture, description, sizeof(description));
    NSString *architecture = [[[NSString alloc] initWithBytes:(void*)description length:descriptionLen encoding:NSASCIIStringEncoding] autorelease];
    
    return [NSString stringWithFormat:@"Fat Arch (%@)", architecture];
}

@end
