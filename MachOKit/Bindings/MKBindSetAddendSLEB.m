//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKBindSetAddendSLEB.m
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

#import "MKBindSetAddendSLEB.h"
#import "NSError+MK.h"
#import "MKMachO.h"
#import "MKBindingsInfo.h"

#include "_mach_trie.h"

//----------------------------------------------------------------------------//
@implementation MKBindSetAddendSLEB

//|++++++++++++++++++++++++++++++++++++|//
+ (uint8_t)opcode
{ return BIND_OPCODE_SET_ADDEND_SLEB; }

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithOffset:(mk_vm_offset_t)offset fromParent:(MKBackedNode*)parent error:(NSError**)error
{
    self = [super initWithOffset:offset fromParent:parent error:error];
    if (self == nil) return nil;
    
    __block BOOL success = NO;
    
    [self.memoryMap remapBytesAtOffset:1 fromAddress:self.nodeContextAddress length:(parent.nodeSize - (offset + 1)) requireFull:NO withHandler:^(vm_address_t address, vm_size_t length, NSError *e) {
        if (address == 0x0) { *error = e; return; }
        
        mk_error_t err;
        uint8_t *start = (uint8_t*)address;
        uint8_t *end = (uint8_t*)(address + length);
        
        if ((err = _mk_mach_trie_copy_sleb128(start, end, &_addend, &_size))) {
            MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:err description:@"Could not read sleb128."];
            return;
        }
        
        success = YES;
    }];
    
    if (!success)
        return nil;
    
    return self;
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - Performing Binding
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (BOOL)bind:(void (^)(void))binder withContext:(struct MKBindContext*)bindContext error:(NSError**)error
{
#pragma unused(binder)
#pragma unused(error)
    bindContext->addend = self.addend;
    return YES;
}

//|++++++++++++++++++++++++++++++++++++|//
- (BOOL)weakBind:(void (^)(void))binder withContext:(struct MKBindContext*)bindContext error:(NSError**)error
{ return [self bind:binder withContext:bindContext error:error]; }

//|++++++++++++++++++++++++++++++++++++|//
- (BOOL)lazyBind:(void (^)(void))binder withContext:(struct MKBindContext*)bindContext error:(NSError**)error
{ return [self bind:binder withContext:bindContext error:error]; }

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - Values
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@synthesize addend = _addend;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_size_t)nodeSize
{ return _size + 1; }

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    MKNodeFieldBuilder *addend = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(addend)
        type:MKNodeFieldTypeUnsignedQuadWord.sharedInstance
    ];
    addend.description = @"Addend";
    addend.options = MKNodeFieldOptionDisplayAsDetail;
    
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        addend.build
    ]];
}

//|++++++++++++++++++++++++++++++++++++|//
- (NSString*)description
{ return [NSString stringWithFormat:@"BIND_OPCODE_SET_ADDEND_SLEB(%" PRIi64 ")", self.addend]; }

@end
