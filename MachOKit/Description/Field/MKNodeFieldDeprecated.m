//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKNodeFieldDeprecated.m
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

#import "MKNodeFieldDeprecated.h"

#import "MKNodeFieldOperationReadKeyPath.h"
#import "MKNodeFieldOperationReturnConstant.h"

//----------------------------------------------------------------------------//
@implementation MKNodeField (Deprecated)

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)nodeFieldWithName:(NSString*)name keyPath:(NSString*)keyPath description:(NSString*)description
{
    id<MKNodeFieldValueRecipe> valueRecipe = [[[MKNodeFieldOperationReadKeyPath alloc] initWithKeyPath:keyPath] autorelease];
    return [[[MKNodeField alloc] initWithName:name description:description type:nil value:valueRecipe data:nil formatter:nil options:0] autorelease];
}

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)nodeFieldWithProperty:(NSString*)property description:(NSString*)description
{ return [self nodeFieldWithName:property keyPath:property description:description]; }

@end



//----------------------------------------------------------------------------//
@implementation MKFormattedNodeField

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)fieldWithName:(NSString*)name keyPath:(NSString*)keyPath description:(NSString*)description format:(MKNodeFieldFormat)format
{
    id<MKNodeFieldValueRecipe> valueRecipe = [[MKNodeFieldOperationReadKeyPath alloc] initWithKeyPath:keyPath];
    
    NSFormatter *formatter = nil;
    switch (format) {
        case MKNodeFieldFormatHex:
            formatter = [MKHexNumberFormatter hexNumberFormatterWithDigits:SIZE_T_MAX];
            break;
        case MKNodeFieldFormatHexCompact:
            formatter = [MKHexNumberFormatter hexNumberFormatterWithDigits:0];
            break;
        default:
            break;
    }
    
    MKFormattedNodeField *field = [[[MKFormattedNodeField alloc] initWithName:name description:description type:nil value:valueRecipe data:nil formatter:formatter options:0] autorelease];
    
    [valueRecipe release];
    
    return field;
}

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)fieldWithProperty:(NSString*)property description:(NSString*)description format:(MKNodeFieldFormat)format
{ return [self fieldWithName:property keyPath:property description:description format:format]; }

@end



//----------------------------------------------------------------------------//
@implementation MKPrimativeNodeField

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)fieldWithName:(NSString*)name keyPath:(NSString*)keyPath description:(NSString*)description offset:(mk_vm_offset_t)offset size:(mk_vm_size_t)size format:(MKNodeFieldFormat)format
{
    MKNodeFieldBuilder *builder = [MKNodeFieldBuilder new];
    
    builder.name = name;
    builder.description = description;
    
    id<MKNodeFieldValueRecipe> valueRecipe = [[MKNodeFieldOperationReadKeyPath alloc] initWithKeyPath:keyPath];
    id<MKNodeFieldDataRecipe> dataRecipe = [[MKNodeFieldDataOperationExtractSubrange alloc] initWithOffset:offset size:size];
    
    builder.valueRecipe = valueRecipe;
    builder.dataRecipe = dataRecipe;
    
    NSFormatter *formatter = nil;
    switch (format) {
        case MKNodeFieldFormatHex:
            formatter = [MKHexNumberFormatter hexNumberFormatterWithDigits:(size_t)(size*2)];
            break;
        case MKNodeFieldFormatHexCompact:
            formatter = [MKHexNumberFormatter hexNumberFormatterWithDigits:0];
            break;
        default:
            break;
    }
    
    builder.formatter = formatter;
    
    MKPrimativeNodeField *field = (id)[builder build];
    
    [valueRecipe release];
    [dataRecipe release];
    [builder release];
    
    return field;
}

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)fieldWithProperty:(NSString*)property description:(NSString*)description offset:(mk_vm_offset_t)offset size:(mk_vm_size_t)size format:(MKNodeFieldFormat)format
{ return [self fieldWithName:property keyPath:property description:description offset:offset size:size format:format]; }

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)fieldWithName:(NSString*)name keyPath:(NSString*)keyPath description:(NSString*)description offset:(mk_vm_offset_t)offset size:(mk_vm_size_t)size
{ return [self fieldWithName:name keyPath:keyPath description:description offset:offset size:size format:MKNodeFieldFormatDecimal]; }

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)fieldWithProperty:(NSString*)property description:(NSString*)description offset:(mk_vm_offset_t)offset size:(mk_vm_size_t)size
{ return [self fieldWithName:property keyPath:property description:description offset:offset size:size]; }

@end



//----------------------------------------------------------------------------//
@implementation MKFlagsNodeField

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)fieldWithName:(NSString*)name keyPath:(NSString*)keyPath description:(NSString*)description offset:(mk_vm_offset_t)offset size:(mk_vm_size_t)size flags:(__unused NSDictionary*)flags
{
    id<MKNodeFieldValueRecipe> valueRecipe = [[[MKNodeFieldOperationReadKeyPath alloc] initWithKeyPath:keyPath] autorelease];
    id<MKNodeFieldDataRecipe> dataRecipe = [[[MKNodeFieldDataOperationExtractSubrange alloc] initWithOffset:offset size:size] autorelease];
    
    return [[[MKFlagsNodeField alloc] initWithName:name description:description type:nil value:valueRecipe data:dataRecipe formatter:[MKHexNumberFormatter hexNumberFormatterWithDigits:0] options:0] autorelease];
}

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)fieldWithProperty:(NSString*)property description:(NSString*)description offset:(mk_vm_offset_t)offset size:(mk_vm_size_t)size flags:(NSDictionary*)flags
{ return [self fieldWithName:property keyPath:property description:description offset:offset size:size flags:flags]; }

@end
