//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKFatBinary.m
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

#import "MKFatBinary.h"
#import "MKInternal.h"
#import "MKFatArch.h"

#include <mach-o/fat.h>

//----------------------------------------------------------------------------//
@implementation MKFatBinary

@synthesize architectures = _architectures;
@synthesize magic = _magic;
@synthesize nfat_arch = _nfat_arch;

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithMemoryMap:(MKMemoryMap*)memoryMap error:(NSError**)error
{
    NSParameterAssert(memoryMap != nil);
    
    self = [super initWithParent:nil error:error];
    if (self == nil) return nil;
    
    _memoryMap = [memoryMap retain];
    
    struct fat_header header;
    NSError *memoryMapError = nil;
    
    if ([self.memoryMap copyBytesAtOffset:0 fromAddress:0 into:&header length:sizeof(header) requireFull:YES error:&memoryMapError] < sizeof(header)) {
        MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_EINTERNAL_ERROR underlyingError:memoryMapError description:@"Could not read FAT header."];
        [self release]; return nil;
    }
    
    _magic = MKSwapLValue32(header.magic, self.dataModel);
    _nfat_arch = MKSwapLValue32(header.nfat_arch, self.dataModel);
    
    // Check for the proper magic value
    if (_magic != FAT_MAGIC) {
        MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_EINVAL description:@"Bad FAT magic [0x%" PRIx32 "].", _magic];
        [self release]; return nil;
    }
    
    // Load Architectures
    {
        NSMutableArray *architectures = [[NSMutableArray alloc] init];
        mk_vm_offset_t offset = sizeof(header);
        
        // Cast to mk_vm_size_t is safe; nodeSize can't be larger than UINT32_MAX.
        while ((mk_vm_size_t)offset < sizeof(struct fat_arch) * _nfat_arch)
        {
            NSError *architectureError = nil;
            MKFatArch *arch = [[MKFatArch alloc] initWithOffset:offset fromParent:self error:&architectureError];
            
            if (arch == nil) {
                MK_PUSH_WARNING_WITH_ERROR(architectures, MK_EINTERNAL_ERROR, architectureError, @"Could not parse architecture at offset [%" MK_VM_PRIuOFFSET "].", offset);
                break;
            }
            
            [architectures addObject:arch];
            [arch release];
            
            // SAFE - Architecture node size is constant.
            offset += arch.nodeSize;
        }
        
        _architectures = [architectures copy];
        [architectures release];
    }
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithParent:(MKNode*)parent error:(NSError **)error
{ return [self initWithMemoryMap:parent.memoryMap error:error]; }

//|++++++++++++++++++++++++++++++++++++|//
- (void)dealloc
{
    [_architectures release];
    [_memoryMap release];
    
    [super dealloc];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (MKMemoryMap*)memoryMap
{ return _memoryMap; }

//|++++++++++++++++++++++++++++++++++++|//
- (id<MKDataModel>)dataModel
{ return [MKPPC32DataModel sharedDataModel]; }

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_size_t)nodeSize
{ return sizeof(struct fat_header) + sizeof(struct fat_arch) * self.nfat_arch; }

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_address_t)nodeAddress:(MKNodeAddressType)type
{
    switch (type) {
        case MKNodeContextAddress:
            return 0;
        default:
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Unsupported node address type." userInfo:nil];
    }
}

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    MKNodeFieldBuilder *magic = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(magic)
        type:[MKNodeFieldTypeEnumeration enumerationWithUnderlyingType:MKNodeFieldTypeDoubleWord.sharedInstance name:nil elements:@{
            @(FAT_MAGIC): @"FAT_MAGIC",
            @(FAT_MAGIC_64): @"FAT_MAGIC_64"
        }]
        offset:offsetof(struct fat_header, magic)
    ];
    magic.description = @"FAT Magic";
    magic.formatter = [MKFormatterChain formatterChainWithLastFormatter:NSFormatter.mk_uppercaseHexFormatter, magic.formatter, nil];
    magic.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *nfat_arch = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(nfat_arch)
        type:MKNodeFieldTypeDoubleWord.sharedInstance
        offset:offsetof(struct fat_header, nfat_arch)
    ];
    nfat_arch.description = @"Number of Architectures";
    nfat_arch.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *architectures = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(architectures)
        type:[MKNodeFieldTypeCollection typeWithCollectionType:[MKNodeFieldTypeNode typeWithNodeType:MKFatArch.class]]
    ];
    architectures.description = @"Architectures";
    architectures.options = MKNodeFieldOptionDisplayAsChild | MKNodeFieldOptionDisplayAsDetail | MKNodeFieldOptionMergeWithParent;
    
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        magic.build,
        nfat_arch.build,
        architectures.build
    ]];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  NSObject
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (NSString*)description
{ return @"Fat Binary"; }

@end
