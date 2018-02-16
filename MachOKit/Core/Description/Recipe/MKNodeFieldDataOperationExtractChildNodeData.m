//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKNodeFieldDataOperationExtractChildNodeData.m
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

#import "MKNodeFieldDataOperationExtractChildNodeData.h"
#import "MKInternal.h"
#import "MKBackedNode.h"

//----------------------------------------------------------------------------//
@implementation MKNodeFieldDataOperationExtractChildNodeData

MKMakeSingletonInitializer(MKNodeFieldDataOperationExtractChildNodeData)

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  MKNodeFieldDataRecipe
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (NSNumber*)address:(NSUInteger)type ofField:(MKNodeField*)field ofNode:(MKBackedNode*)input
{
    MKBackedNode *childNode = [field.valueRecipe valueForField:field ofNode:input].value;
    if (childNode == nil)
        return nil;
    
    NSAssert([childNode isKindOfClass:MKBackedNode.class], @"Value of field [%@] must be an MKBackedNode.", field.name);
    
    @try {
        return @([childNode nodeAddress:type]);
    } @catch (NSException *exception) {
        return nil;
    }
}

//|++++++++++++++++++++++++++++++++++++|//
- (NSNumber*)sizeOfField:(MKNodeField*)field ofNode:(MKBackedNode*)input
{
    MKBackedNode *childNode = [field.valueRecipe valueForField:field ofNode:input].value;
    if (childNode == nil)
        return nil;
    
    NSAssert([childNode isKindOfClass:MKBackedNode.class], @"Value of field [%@] must be an MKBackedNode.", field.name);
    
    return @([childNode nodeSize]);
}

//|++++++++++++++++++++++++++++++++++++|//
- (NSData*)dataForField:(MKNodeField*)field ofNode:(MKBackedNode*)input
{
    MKBackedNode *childNode = [field.valueRecipe valueForField:field ofNode:input].value;
    if (childNode == nil)
        return nil;
    
    NSAssert([childNode isKindOfClass:MKBackedNode.class], @"Value of field [%@] must be an MKBackedNode.", field.name);
    
    return childNode.data;
}

@end
