//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKBindDoBindULEBTimesSkippingULEB.m
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

#import "MKBindDoBindULEBTimesSkippingULEB.h"
#import "NSError+MK.h"
#import "MKMachO.h"
#import "MKBindingsInfo.h"

#include "_mach_trie.h"

//----------------------------------------------------------------------------//
@implementation MKBindDoBindULEBTimesSkippingULEB

//|++++++++++++++++++++++++++++++++++++|//
+ (uint8_t)opcode
{ return BIND_OPCODE_DO_BIND_ULEB_TIMES_SKIPPING_ULEB; }

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
        size_t size = 0;
        
        if ((err = _mk_mach_trie_copy_uleb128(start, end, &_count, &size))) {
            MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:err description:@"Could not read uleb128."];
            return;
        }
        
        // SAFE - the output_size of _mk_mach_trie_copy_uleb128 is constrained
        //        to 32-bits.
        _size += size;
        start += size;
        size = 0;
        
        if ((err = _mk_mach_trie_copy_uleb128(start, end, &_skip, &size))) {
            MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:err description:@"Could not read uleb128."];
            return;
        }
        
        // SAFE - the output_size of _mk_mach_trie_copy_uleb128 is constrained
        //        to 32-bits.
        _size += size;
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
    for (uint64_t i = 0; i < self.count; i++) {
        binder();
        
        mk_error_t err;
        if ((err = mk_vm_offset_add(bindContext->offset, self.offset, &bindContext->offset))) {
            MK_ERROR_OUT = MK_MAKE_VM_OFFSET_ADD_ARITHMETIC_ERROR(err, bindContext->offset, self.offset);
            return NO;
        }
    }
    
    // Reset
    bindContext->command = nil;
    
    return YES;
}

//|++++++++++++++++++++++++++++++++++++|//
- (BOOL)weakBind:(void (^)(void))binder withContext:(struct MKBindContext*)bindContext error:(NSError**)error
{ return [self bind:binder withContext:bindContext error:error]; }

//|++++++++++++++++++++++++++++++++++++|//
- (BOOL)lazyBind:(void (^)(void))binder withContext:(struct MKBindContext*)bindContext error:(NSError**)error
{
#pragma unused(binder)
#pragma unused(bindContext)
    // Lazy bindings only use BIND_OPCODE_DO_BIND.  This command should
    // never appear in a lazy binding.
    MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_EINVALID_DATA description:@"Unexpected BIND_OPCODE_DO_BIND_ULEB_TIMES_SKIPPING_ULEB opcode in a lazy binding."];
    
    return NO;
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - Values
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@synthesize count = _count;
@synthesize skip = _skip;

//|++++++++++++++++++++++++++++++++++++|//
- (uint64_t)offset
{ return self.skip + self.dataModel.pointerSize; }

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_size_t)nodeSize
{ return _size + 1; }

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    // TODO - Adopt the new description system.  We need to keep track of the
    // count and skip uleb sizes.
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        [MKNodeField nodeFieldWithProperty:MK_PROPERTY(count) description:@"Bind Count"],
        [MKNodeField nodeFieldWithProperty:MK_PROPERTY(skip) description:@"Skip Per Bind"],
        [MKNodeField nodeFieldWithProperty:MK_PROPERTY(offset) description:@"Offset Per Bind"]
    ]];
}

//|++++++++++++++++++++++++++++++++++++|//
- (NSString*)description
{ return [NSString stringWithFormat:@"BIND_OPCODE_DO_BIND_ULEB_TIMES_SKIPPING_ULEB(%" PRIu64 ", 0x%.8" PRIX64 ")", self.count, self.skip]; }

@end
