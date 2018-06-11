//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKUString.m
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

#import "MKUString.h"
#import "MKInternal.h"

//----------------------------------------------------------------------------//
@implementation MKUString

@synthesize string = _string;

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithOffset:(mk_vm_offset_t)offset fromParent:(MKBackedNode *)parent error:(NSError **)error
{
    self = [super initWithOffset:offset fromParent:parent error:error];
    if (self == nil) return nil;
    
    // UStrings are NULL terminated and we are given no indication of the
    // string's length.
    
    mk_error_t err;
    mk_vm_address_t parentAddress = parent.nodeContextAddress;
    mk_vm_size_t parentSize = parent.nodeSize;
    
    // If the parent size is zero then the parent is initializing and is
    // dependent on knowing the size of this string to compute its own size.
    // In this case we hop up a level and use our parent's parent to compute
    // a rough max size which will be refixed once we know the string length.
    if (parentSize == 0)
    {
        _nodeSize = MK_VM_SIZE_MAX; // TODO - Implement this.
    }
    else
    {
        // The provided offset must be within the range of our parent node.
        mk_vm_range_t parentRange = mk_vm_range_make(parentAddress, parentSize);
        if ((err = mk_vm_range_contains_address(parentRange, offset, parentAddress))) {
            MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_ENOT_FOUND description:@"Provided offset [%" MK_VM_PRIuOFFSET "] is not within parent node: %@.", offset, parent.nodeDescription];
            [self release]; return nil;
        }
        
        _nodeSize = parent.nodeSize - offset;
    }
    
    // TODO - If the string falls outside of the parent node, we could still try to
    // parse it anyway.
    // <http://reverse.put.as/2012/01/31/anti-debug-trick-1-abusing-mach-o-to-crash-gdb/>
    
    __block NSError *memoryMapError = nil;
    
    [parent.memoryMap remapBytesAtOffset:offset fromAddress:parent.nodeContextAddress length:_nodeSize requireFull:NO withHandler:^(vm_address_t address, vm_size_t length, NSError *e) {
        if (address == 0x0) { memoryMapError = e; return; }
        
        size_t (^strnlen16)(const uint16_t*, size_t) = ^(const uint16_t* strarg, size_t len) {
            size_t count = 0;
            const uint16_t* str = strarg;
            while ((uintptr_t)str - (uintptr_t)strarg < len && *str)
            {
                count += 2;
                str++;
            }
            return count;
        };
        
        _nodeSize = strnlen16((const uint16_t*)address, length);
        _string = [[NSString alloc] initWithBytes:(const void*)address length:(NSUInteger)_nodeSize encoding:NSUTF16LittleEndianStringEncoding];
        
        if (_string == nil)
            MK_PUSH_WARNING(string, MK_EINVALID_DATA, @"Could not initialize NSString with bytes.");
        
        if (_nodeSize < length) {
            // Account for the NULL terminator.
            _nodeSize = MIN(_nodeSize + 2, length);
        } else {
            MK_PUSH_WARNING(sring, MK_EINVALID_DATA, @"String may not be properly terminated.");
        }
    }];
    
    if (memoryMapError) {
        MK_ERROR_OUT = memoryMapError;
        [self release]; return nil;
    }
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (void)dealloc
{
    [_string release];
    
    [super dealloc];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_size_t)nodeSize
{ return _nodeSize; }

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    MKNodeFieldBuilder *string = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(string)
        type:MKNodeFieldTypeString.sharedInstance
        offset:0
        size:_nodeSize
    ];
    string.description = @"String";
    string.options = MKNodeFieldOptionDisplayAsDetail | MKNodeFieldOptionMergeWithParent;
    
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        string.build
    ]];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - NSObject
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (NSString*)description
{ return self.string; }

//|++++++++++++++++++++++++++++++++++++|//
- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:MKUString.class])
        return [[object string] isEqualToString:self.string];
    else if ([object isKindOfClass:NSString.class])
        return [object isEqualToString:self.string];
    else
        return NO;
}

//|++++++++++++++++++++++++++++++++++++|//
- (NSUInteger)hash
{ return self.string.hash; }

@end
