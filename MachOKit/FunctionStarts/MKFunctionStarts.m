//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKFunctionStarts.m
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

#import "MKFunctionStarts.h"
#import "MKInternal.h"
#import "MKMachO.h"
#import "MKLCFunctionStarts.h"
#import "MKFunctionOffset.h"
#import "MKFunction.h"

//----------------------------------------------------------------------------//
@implementation MKFunctionStarts

@synthesize offsets = _offsets;
@synthesize functions = _functions;

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithSize:(mk_vm_size_t)size offset:(mk_vm_offset_t)offset inImage:(MKMachOImage*)image error:(NSError**)error
{
    self = [super initWithSize:size offset:offset inImage:image error:error];
    if (self == nil) return nil;
    
    // Parse the function offsets
    @autoreleasepool
    {
        NSMutableArray<MKFunctionOffset*> *offsets = [[NSMutableArray alloc] initWithCapacity:(NSUInteger)size/3];
        mk_vm_offset_t offset = 0;
        
        while (offset < self.nodeSize)
        {
            NSError *functionOffsetError = nil;
            
            MKFunctionOffset *functionOffset = [[MKFunctionOffset alloc] initWithOffset:offset fromParent:self error:&functionOffsetError];
            if (functionOffset == nil) {
                MK_PUSH_WARNING_WITH_ERROR(offsets, MK_EINTERNAL_ERROR, functionOffsetError, @"Could not parse function offset at offset [%" MK_VM_PRIuOFFSET "].", offset);
                break;
            }
            
            [offsets addObject:functionOffset];
            [functionOffset release];
            
            // SAFE - All function offset nodes must be within the size of this node.
            offset += functionOffset.nodeSize;
        }
        
        _offsets = [offsets copy];
        [offsets release];
    }
    
    // Determine the function addresses
    @autoreleasepool
    {
        NSMutableArray<MKFunction*> *functions = [[NSMutableArray alloc] initWithCapacity:(NSUInteger)size/3];
        
        mk_error_t err;
        NSError *functionError = nil;
        struct MKFunctionStartsContext context = { 0, .info = self };
        
        // The initial offset is the delta from the start of __TEXT
        context.address = self.macho.nodeVMAddress;
        
        // TODO - Thumb needs some special handling.  See FunctionStartsAtom<A>::encode()
        // <https://opensource.apple.com/source/ld64/ld64-274.2/src/ld/LinkEdit.hpp.auto.html>
        
        for (MKFunctionOffset *offset in _offsets) {
            context.offset = offset;
            
            mk_vm_offset_t nextFunctionOffset = offset.offset;
            if (nextFunctionOffset == 0)
                break;
            
            if ((err = mk_vm_address_apply_offset(context.address, nextFunctionOffset, &context.address))) {
                functionError = MK_MAKE_VM_ADDRESS_APPLY_OFFSET_ARITHMETIC_ERROR(err, context.address, nextFunctionOffset);
                MK_PUSH_WARNING_WITH_ERROR(functions, MK_EINTERNAL_ERROR, functionError, @"Function list generation failed at offset: %@.", context.offset.nodeDescription);
                break;
            }
            
            MKFunction *function = [[MKFunction alloc] initWithContext:&context error:&functionError];
            
            if (function == nil) {
                MK_PUSH_WARNING_WITH_ERROR(functions, MK_EINTERNAL_ERROR, functionError, @"Function list generation failed at offset: %@.", context.offset.nodeDescription);
                break;
            }
            
            [functions addObject:function];
            [function release];
        }
        
        _functions = [functions copy];
        [functions release];
    }
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithImage:(MKMachOImage*)image error:(NSError**)error
{
    NSParameterAssert(image != nil);
    
    // Find LC_FUNCTION_STARTS
    MKLCFunctionStarts *functionStartsLoadCommand = nil;
    {
        NSArray<MKLCFunctionStarts*> *commands = [image loadCommandsOfType:LC_FUNCTION_STARTS];
        
        if (commands.count > 1)
            MK_PUSH_WARNING(nil, MK_EINVALID_DATA, @"Image contains multiple LC_FUNCTION_STARTS load commands.  Ignoring %@.", commands.lastObject);
        
        if (commands.count == 0) {
            // Not an error - Image has no function starts information.
            [self release]; return nil;
        }
        
        functionStartsLoadCommand = [[commands.firstObject retain] autorelease];
    }
    
    return [self initWithSize:functionStartsLoadCommand.datasize offset:functionStartsLoadCommand.dataoff inImage:image error:error];
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithParent:(MKNode*)parent error:(NSError**)error
{ return [self initWithImage:parent.macho error:error]; }

//|++++++++++++++++++++++++++++++++++++|//
- (void)dealloc
{
    [_functions release];
    [_offsets release];
    
    [super dealloc];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    MKNodeFieldBuilder *offsets = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(offsets)
        type:[MKNodeFieldTypeCollection typeWithCollectionType:[MKNodeFieldTypeNode typeWithNodeType:MKFunctionOffset.class]]
    ];
    offsets.description = @"Offsets";
    offsets.options = MKNodeFieldOptionDisplayAsChild | MKNodeFieldOptionDisplayContainerContentsAsDetail;
    
    MKNodeFieldBuilder *functions = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(functions)
        type:[MKNodeFieldTypeCollection typeWithCollectionType:[MKNodeFieldTypeNode typeWithNodeType:MKFunction.class]]
    ];
    functions.description = @"Functions";
    functions.options = MKNodeFieldOptionDisplayAsChild | MKNodeFieldOptionDisplayContainerContentsAsDetail;
    
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        offsets.build,
        functions.build
    ]];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  NSObject
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (NSString*)description
{ return @"Function Starts"; }

@end
