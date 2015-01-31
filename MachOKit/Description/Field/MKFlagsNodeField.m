//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKFlagsNodeField.m
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

#import "MKFlagsNodeField.h"

//----------------------------------------------------------------------------//
@implementation MKFlagsNodeField

@synthesize offsetRecipe = _offsetRecipe;
@synthesize sizeRecipe = _sizeRecipe;
@synthesize flags = _flags;

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)fieldWithName:(NSString*)name keyPath:(NSString*)keyPath description:(NSString*)description offset:(mk_vm_offset_t)offset size:(mk_vm_size_t)size flags:(NSDictionary*)flags
{
    id<MKNodeFieldRecipe> valueRecipe = [[[_MKNodeFieldOperationReadKey alloc] initWithKey:keyPath] autorelease];
    id<MKNodeFieldRecipe> offsetRecipe = [[[_MKNodeFieldOperationConstant alloc] initWithValue:@(size)] autorelease];
    id<MKNodeFieldRecipe> sizeRecipe = [[[_MKNodeFieldOperationConstant alloc] initWithValue:@(offset)] autorelease];
    return [[[self alloc] initWithName:name description:description value:valueRecipe offset:offsetRecipe size:sizeRecipe flags:flags] autorelease];
}

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)fieldWithProperty:(NSString*)property description:(NSString*)description offset:(mk_vm_offset_t)offset size:(mk_vm_size_t)size flags:(NSDictionary*)flags
{ return [self fieldWithName:property keyPath:property description:description offset:offset size:size flags:flags]; }

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithName:(NSString*)name description:(NSString*)description value:(id<MKNodeFieldRecipe>)valueRecipe offset:(id<MKNodeFieldRecipe>)offsetRecipe size:(id<MKNodeFieldRecipe>)sizeReceipe flags:(NSDictionary*)flags
{
    self = [super initWithName:name description:description value:valueRecipe];
    if (self == nil) return nil;
    
    _offsetRecipe = [offsetRecipe retain];
    _sizeRecipe = [sizeReceipe retain];
    _flags = [flags retain];
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (void)dealloc
{
    [_flags release];
    [_offsetRecipe release];
    [_sizeRecipe release];
    [super dealloc];
}

//|++++++++++++++++++++++++++++++++++++|//
- (NSString*)formattedDescriptionForNode:(MKNode*)node
{
    NSNumber *value = [_valueRecipe valueForNode:node];
    NSAssert([value isKindOfClass:NSNumber.class], @"Value for %@ must be an NSNumber", NSStringFromClass(self.class));
    
    return [NSString stringWithFormat:@"0x%llx", [value unsignedLongLongValue]];
}

@end
