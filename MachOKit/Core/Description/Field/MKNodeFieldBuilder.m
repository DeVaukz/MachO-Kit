//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKNodeFieldBuilder.m
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

#import "MKNodeFieldBuilder.h"
#import "MKInternal.h"
#import "MKOffsetNode.h"

//----------------------------------------------------------------------------//
@implementation MKNodeFieldBuilder

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)builderWithProperty:(NSString*)propertyName type:(id<MKNodeFieldType>)type offset:(mk_vm_offset_t)offset size:(mk_vm_size_t)size
{
    MKNodeFieldBuilder *builder = [self new];
    
    id<MKNodeFieldValueRecipe> valueRecipe = [[MKNodeFieldOperationReadKeyPath alloc] initWithKeyPath:propertyName];
    id<MKNodeFieldDataRecipe> dataRecipe = [[MKNodeFieldDataOperationExtractSubrange alloc] initWithOffset:offset size:size];
    
    builder.name = propertyName;
    builder.description = propertyName;
    builder.type = type;
    builder.valueRecipe = valueRecipe;
    builder.dataRecipe = dataRecipe;
    
    if ([type conformsToProtocol:@protocol(MKNodeFieldCollectionType)]) {
        builder.formatter = [[(id<MKNodeFieldCollectionType>)type elementType] formatter];
        builder.options = MKNodeFieldOptionFormatCollectionValues;
    } else {
        builder.formatter = [type formatter];
    }
    
    [valueRecipe release];
    [dataRecipe release];
    
    return [builder autorelease];
}

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)builderWithProperty:(NSString*)propertyName type:(id<MKNodeFieldNumericType>)type offset:(mk_vm_offset_t)offset;
{
    MKNodeFieldBuilder *builder = [self new];
    
    id<MKNodeFieldValueRecipe> valueRecipe = [[MKNodeFieldOperationReadKeyPath alloc] initWithKeyPath:propertyName];
    id<MKNodeFieldDataRecipe> dataRecipe = [[MKNodeFieldDataOperationExtractSubrange alloc] initWithOffset:offset type:type];
    
    builder.name = propertyName;
    builder.description = propertyName;
    builder.type = type;
    builder.valueRecipe = valueRecipe;
    builder.dataRecipe = dataRecipe;
    
    if ([type conformsToProtocol:@protocol(MKNodeFieldCollectionType)]) {
        builder.formatter = [[(id<MKNodeFieldCollectionType>)type elementType] formatter];
        builder.options = MKNodeFieldOptionFormatCollectionValues;
    } else {
        builder.formatter = [type formatter];
    }
    
    [valueRecipe release];
    [dataRecipe release];
    
    return [builder autorelease];
}

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)builderWithProperty:(NSString*)propertyName type:(id<MKNodeFieldType>)type
{
    MKNodeFieldBuilder *builder = [self new];
    
    id<MKNodeFieldValueRecipe> valueRecipe = [[MKNodeFieldOperationReadKeyPath alloc] initWithKeyPath:propertyName];
    id<MKNodeFieldDataRecipe> dataRecipe = nil;
    
    if ([type conformsToProtocol:@protocol(MKNodeFieldNodeType)] && [[(id<MKNodeFieldNodeType>)type nodeClass] isSubclassOfClass:MKBackedNode.class]) {
        dataRecipe = [MKNodeFieldDataOperationExtractChildNodeData.sharedInstance retain];
    }
    
    builder.name = propertyName;
    builder.description = propertyName;
    builder.type = type;
    builder.valueRecipe = valueRecipe;
    builder.dataRecipe = dataRecipe;
    
    if ([type conformsToProtocol:@protocol(MKNodeFieldCollectionType)]) {
        builder.formatter = [[(id<MKNodeFieldCollectionType>)type elementType] formatter];
        builder.options = MKNodeFieldOptionFormatCollectionValues;
    } else {
        builder.formatter = [type formatter];
    }
    
    [valueRecipe release];
    [dataRecipe release];
    
    return [builder autorelease];
}

//|++++++++++++++++++++++++++++++++++++|//
- (void)dealloc
{
    [_name release];
    [_description release];
    [_valueRecipe release];
    [_dataRecipe release];
    [_type release];
    [_formatter release];
    [_alternateFieldName release];
    
    [super dealloc];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Field Configuration
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@synthesize name = _name;
@synthesize description = _description;
@synthesize type = _type;
@synthesize valueRecipe = _valueRecipe;
@synthesize dataRecipe = _dataRecipe;
@synthesize options = _options;
@synthesize formatter = _formatter;
@synthesize alternateFieldName = _alternateFieldName;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Creating Fields
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeField*)build
{
    return [[[MKNodeField alloc] initWithName:self.name
                                  description:self.description
                                         type:self.type
                                        value:self.valueRecipe
                                         data:self.dataRecipe
                                    formatter:self.formatter
                                      options:self.options
                           alternateFieldName:self.alternateFieldName] autorelease];
}

@end
