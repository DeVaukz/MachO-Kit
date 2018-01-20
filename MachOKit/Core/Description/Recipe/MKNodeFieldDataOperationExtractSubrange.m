//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKNodeFieldDataOperationExtractSubrange.m
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

#import "MKNodeFieldDataOperationExtractSubrange.h"
#import "MKInternal.h"
#import "MKBackedNode.h"

//----------------------------------------------------------------------------//
@implementation MKNodeFieldDataOperationExtractSubrange

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithOffset:(mk_vm_offset_t)offset size:(mk_vm_size_t)size
{
    self = [super init];
    if (self == nil) return nil;
    
    _offset = offset;
    _size = size;
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithOffset:(mk_vm_offset_t)offset type:(id<MKNodeFieldNumericType>)type
{
    NSParameterAssert(type != nil);
    
    self = [super init];
    if (self == nil) return nil;
    
    _offset = offset;
    _type = [type retain];
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)init
{ return [self initWithOffset:0 size:0]; }

//|++++++++++++++++++++++++++++++++++++|//
- (void)dealloc
{
    [_type release];
    
    [super dealloc];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  MKNodeFieldDataRecipe
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (NSNumber*)address:(NSUInteger)type ofField:(__unused MKNodeField*)field ofNode:(MKBackedNode*)input
{
    NSParameterAssert([input isKindOfClass:MKBackedNode.class]);
    
    mk_error_t err;
    mk_vm_address_t address;
    
    // Calculate the address.
    if ((err = mk_vm_address_apply_offset([input nodeAddress:type], _offset, &address))) {
        return nil;
    }
    
    return @(address);
}

//|++++++++++++++++++++++++++++++++++++|//
- (NSNumber*)sizeOfField:(__unused MKNodeField*)field ofNode:(MKBackedNode*)input
{
    if (_type)
        return @([_type sizeForNode:input]);
    else
        return @(_size);
}

//|++++++++++++++++++++++++++++++++++++|//
- (NSData*)dataForField:(MKNodeField*)field ofNode:(MKBackedNode*)input
{
    NSParameterAssert([input isKindOfClass:MKBackedNode.class]);
    
    // If offset or size are invalid, -subdataWithRange: will throw.  Don't
    // let that bring down the program.  Catch it and return nil.
    @try {
        return [input.data subdataWithRange:NSMakeRange(_offset, [[self sizeOfField:field ofNode:input] unsignedIntegerValue])];
    } @catch (NSException *exception) {
        return nil;
    }
}

@end
