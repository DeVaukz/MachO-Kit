//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKLCLinkerOption.m
//|
//|             Milen Dzhumerov
//|             Copyright (c) 2020-2020 Milen Dzhumerov. All rights reserved.
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

#import "MKLCLinkerOption.h"

@implementation MKLCLinkerOption

@synthesize nstrings = _nstrings;
@synthesize strings = _strings;

//|++++++++++++++++++++++++++++++++++++|//
+ (uint32_t)ID
{ return LC_LINKER_OPTION; }

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithOffset:(mk_vm_offset_t)offset fromParent:(MKBackedNode*)parent error:(NSError**)error
{
    self = [super initWithOffset:offset fromParent:parent error:error];
    if (self == nil) return nil;
    
    struct linker_option_command lc;
    if ([self.memoryMap copyBytesAtOffset:offset fromAddress:parent.nodeContextAddress into:&lc length:sizeof(lc) requireFull:YES error:error] < sizeof(lc))
    { [self release]; return nil; }
    
    _nstrings = MKSwapLValue32(lc.count, self.macho.dataModel);
    
    {
        uint32_t stringCount = self.nstrings;
        NSMutableArray<MKCString *> *strings = [[NSMutableArray alloc] initWithCapacity:stringCount];
        mach_vm_offset_t offset = sizeof(lc);
        
        while (stringCount--) {
            @autoreleasepool {
                
                NSError *stringError = nil;
                MKCString *string = [[MKCString alloc] initWithOffset:offset fromParent:self error:&stringError];
                if (string == nil) {
                    MK_PUSH_UNDERLYING_WARNING(strings, stringError, @"Failed to read string at index " PRIi32 "", (self.nstrings - (stringCount + 1 /** as already decremented */)));
                    break;
                }
                
                if (string.nodeSize < 1) {
                    MK_PUSH_WARNING(strings, MK_EINVALID_DATA, @"String needs to contain at least terminating NULL char");
                    break;
                }
                
                
                offset += string.nodeSize;
                
                [strings addObject:string];
                [string release];
            }
        }
        
        _strings = [strings copy];
        [strings release];
    }
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
+ (uint32_t)canInstantiateWithLoadCommandID:(uint32_t)commandID
{
    if (self != MKLCLinkerOption.class)
        return 0;
    
    return commandID == [self ID] ? 10 : 0;
}

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    __unused struct linker_option_command loc;
    
    MKNodeFieldBuilder *nstrings = [MKNodeFieldBuilder
                                    builderWithProperty:MK_PROPERTY(nstrings)
                                    type:MKNodeFieldTypeUnsignedDoubleWord.sharedInstance
                                    offset:offsetof(typeof(loc), count)
                                    size:sizeof(loc.count)
                                    ];
    nstrings.description = @"Number Of Strings";
    nstrings.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *strings = [MKNodeFieldBuilder
                                   builderWithProperty:MK_PROPERTY(strings)
                                   type:[MKNodeFieldTypeCollection typeWithCollectionType:[MKNodeFieldTypeNode typeWithNodeType:MKCString.class]]
                                   ];
    strings.description = @"Strings";
    strings.options = MKNodeFieldOptionDisplayAsDetail | MKNodeFieldOptionMergeWithParent;
    
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        nstrings.build,
        strings.build,
    ]];
}

@end
