//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKNodeFieldDataOperationExtractDynamicSubrange.m
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

#import "MKNodeFieldDataOperationExtractDynamicSubrange.h"
#import "MKInternal.h"
#import "MKBackedNode.h"

#include <objc/message.h>

//----------------------------------------------------------------------------//
@implementation MKBackedNode (DynamicSubrange)

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_offset_t)offsetOfField:(MKNodeField*)field
{
    NSString *reason = [NSString stringWithFormat:@"Requesting offset for unhandled field: %@.", field.name];
    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:nil];
}

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_size_t)sizeOfField:(MKNodeField*)field
{
    NSString *reason = [NSString stringWithFormat:@"Requesting size for unhandled field: %@.", field.name];
    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:nil];
}

@end



//----------------------------------------------------------------------------//
@implementation MKNodeFieldDataOperationExtractDynamicSubrange

MKMakeSingletonInitializer(MKNodeFieldDataOperationExtractDynamicSubrange)

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  MKNodeFieldDataRecipe
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_offset_t)_offsetOfField:(MKNodeField*)field ofNode:(MKBackedNode*)input
{
    NSString *getterMethod = [[NSString alloc] initWithFormat:@"%@FieldOffset", field.name];
    SEL getterSEL = NSSelectorFromString(getterMethod);
    [getterMethod release];
    
    if ([input respondsToSelector:getterSEL]) {
        return ((mk_vm_offset_t (*)(id, SEL))objc_msgSend)(input, getterSEL);
    } else {
        return [input offsetOfField:field];
    }
}

//|++++++++++++++++++++++++++++++++++++|//
- (NSNumber*)address:(NSUInteger)type ofField:(MKNodeField*)field ofNode:(MKBackedNode*)input
{
    mk_error_t err;
    mk_vm_address_t address;
    mk_vm_offset_t offset = [self _offsetOfField:field ofNode:input];
    
    // Calculate the address.
    if ((err = mk_vm_address_apply_offset([input nodeAddress:type], offset, &address))) {
        return nil;
    }
    
    return @(address);
}

//|++++++++++++++++++++++++++++++++++++|//
- (NSNumber*)sizeOfField:(MKNodeField*)field ofNode:(MKBackedNode*)input
{
    NSString *getterMethod = [[NSString alloc] initWithFormat:@"%@FieldSize", field.name];
    SEL getterSEL = NSSelectorFromString(getterMethod);
    [getterMethod release];
    
    if ([input respondsToSelector:getterSEL]) {
        return @( ((mk_vm_size_t (*)(id, SEL))objc_msgSend)(input, getterSEL) );
    } else {
        return @( [input sizeOfField:field] );
    }
}

//|++++++++++++++++++++++++++++++++++++|//
- (NSData*)dataForField:(MKNodeField*)field ofNode:(MKBackedNode*)input
{
    NSRange fieldDataRange = NSMakeRange(
        (NSUInteger)[self _offsetOfField:field ofNode:input],
        [[self sizeOfField:field ofNode:input] unsignedIntegerValue]
    );
    
    // If offset or size are invalid, -subdataWithRange: will throw.  Don't
    // let that bring down the program.  Catch it and return nil.
    @try {
        return [input.data subdataWithRange:fieldDataRange];
    } @catch (NSException *exception) {
        return nil;
    }
}

@end
