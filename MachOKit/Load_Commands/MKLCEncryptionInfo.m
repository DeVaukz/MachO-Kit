//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKLCEncryptionInfo.m
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

#import "MKLCEncryptionInfo.h"
#import "MKInternal.h"
#import "MKMachO.h"

//----------------------------------------------------------------------------//
@implementation MKLCEncryptionInfo

@synthesize cryptoff = _cryptoff;
@synthesize cryptsize = _cryptsize;
@synthesize cryptid = _cryptid;

//|++++++++++++++++++++++++++++++++++++|//
+ (uint32_t)ID
{ return LC_ENCRYPTION_INFO; }

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithOffset:(mk_vm_offset_t)offset fromParent:(MKBackedNode*)parent error:(NSError**)error
{
    self = [super initWithOffset:offset fromParent:parent error:error];
    if (self == nil) return nil;
    
    struct encryption_info_command lc;
    if ([self.memoryMap copyBytesAtOffset:offset fromAddress:parent.nodeContextAddress into:&lc length:sizeof(lc) requireFull:YES error:error] < sizeof(lc))
    { [self release]; return nil; }
    
    _cryptoff = MKSwapLValue32(lc.cryptoff, self.macho.dataModel);
    _cryptsize = MKSwapLValue32(lc.cryptsize, self.macho.dataModel);
    _cryptid = MKSwapLValue32(lc.cryptid, self.macho.dataModel);
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(cryptoff) description:@"Encrypted Range Offset" offset:offsetof(struct encryption_info_command, cryptoff) size:sizeof(uint32_t)],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(cryptsize) description:@"Encrypted Range Size" offset:offsetof(struct encryption_info_command, cryptsize) size:sizeof(uint32_t)],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(cryptid) description:@"Encryption System" offset:offsetof(struct encryption_info_command, cryptid) size:sizeof(uint32_t)]
    ]];
}

@end
