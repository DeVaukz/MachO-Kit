//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKLCSymtab.m
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

#import "MKLCSymtab.h"
#import "MKInternal.h"
#import "MKMachO.h"

//----------------------------------------------------------------------------//
@implementation MKLCSymtab

@synthesize symoff = _symoff;
@synthesize nsyms = _nsyms;
@synthesize stroff = _stroff;
@synthesize strsize = _strsize;

//|++++++++++++++++++++++++++++++++++++|//
+ (uint32_t)ID
{ return LC_SYMTAB; }

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithOffset:(mk_vm_offset_t)offset fromParent:(MKBackedNode*)parent error:(NSError**)error
{
    self = [super initWithOffset:offset fromParent:parent error:error];
    if (self == nil) return nil;
    
    struct symtab_command lc;
    if ([self.memoryMap copyBytesAtOffset:offset fromAddress:parent.nodeContextAddress into:&lc length:sizeof(lc) requireFull:YES error:error] < sizeof(lc))
    { [self release]; return nil; }
    
    _symoff = MKSwapLValue32(lc.symoff, self.macho.dataModel);
    _nsyms = MKSwapLValue32(lc.nsyms, self.macho.dataModel);
    _stroff = MKSwapLValue32(lc.stroff, self.macho.dataModel);
    _strsize = MKSwapLValue32(lc.strsize, self.macho.dataModel);
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(symoff) description:@"Symbol Table Offset" offset:offsetof(struct symtab_command, symoff) size:sizeof(uint32_t)],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(nsyms) description:@"Number of Symbols" offset:offsetof(struct symtab_command, nsyms) size:sizeof(uint32_t)],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(stroff) description:@"String Table Offset" offset:offsetof(struct symtab_command, stroff) size:sizeof(uint32_t)],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(strsize) description:@"String Table Size" offset:offsetof(struct symtab_command, strsize) size:sizeof(uint32_t)]
    ]];
}

@end
