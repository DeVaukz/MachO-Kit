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
#import "MKInternal.h"
#import "MKLEB.h"

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
    
    offset = 1;
    
    // Read the count ULEB
    {
        NSError *ULEBError = nil;
        
        if (!MKULEBRead(self, offset, &_count, &_countULEBSize, &ULEBError)) {
            MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_EINTERNAL_ERROR underlyingError:ULEBError description:@"Could not read count."];
            [self release]; return nil;
        }
        
        offset += _countULEBSize;
    }
    
    // Read the skip ULEB
    {
        NSError *ULEBError = nil;
        
        if (!MKULEBRead(self, offset, &_skip, &_skipULEBSize, &ULEBError)) {
            MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_EINTERNAL_ERROR underlyingError:ULEBError description:@"Could not read skip."];
            [self release]; return nil;
        }
        
        //offset += _skipULEBSize;
    }
    
    return self;
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Performing Binding
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (BOOL)bind:(void (^)(void))binder withContext:(struct MKBindContext*)bindContext error:(NSError**)error
{
    for (uint64_t i = 0; i < self.count; i++) {
        binder();
        
        mk_error_t err;
        if ((err = mk_vm_offset_add(bindContext->offset, self.derivedOffset, &bindContext->offset))) {
            MK_ERROR_OUT = MK_MAKE_VM_OFFSET_ADD_ARITHMETIC_ERROR(err, bindContext->offset, self.derivedOffset);
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
#pragma mark -  Bind Command Values
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@synthesize count = _count;
@synthesize skip = _skip;

//|++++++++++++++++++++++++++++++++++++|//
- (uint64_t)derivedOffset
{ return self.skip + self.dataModel.pointerSize; }

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_size_t)nodeSize
{ return 1 + _countULEBSize + _skipULEBSize; }

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    mk_vm_offset_t offset = 1;
    
    MKNodeFieldBuilder *count = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(count)
        type:MKNodeFieldTypeUnsignedQuadWord.sharedInstance
        offset:offset
        size:_countULEBSize
    ];
    count.description = @"Bind Count";
    count.options = MKNodeFieldOptionDisplayAsDetail;
    
    offset += _countULEBSize;
    
    MKNodeFieldBuilder *skip = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(skip)
        type:MKNodeFieldTypeUnsignedQuadWord.sharedInstance
        offset:offset
        size:_skipULEBSize
    ];
    skip.description = @"Skip Per Bind";
    skip.options = MKNodeFieldOptionDisplayAsDetail;
    
    //offset += _skipULEBSize;
    
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        count.build,
        skip.build
    ]];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  NSObject
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (NSString*)description
{ return [NSString stringWithFormat:@"BIND_OPCODE_DO_BIND_ULEB_TIMES_SKIPPING_ULEB(%" PRIu64 ", 0x%.8" PRIX64 ")", self.count, self.skip]; }

@end
