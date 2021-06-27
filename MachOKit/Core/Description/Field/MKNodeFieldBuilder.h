//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       MKNodeFieldBuilder.h
//!
//! @author     D.V.
//! @copyright  Copyright (c) 2014-2015 D.V. All rights reserved.
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

#import <MachOKit/MKBase.h>

#import <MachOKit/MKNodeField.h>
#import <MachOKit/MKFieldType.h>
#import <MachOKit/NSFormatter+MKNodeField.h>
#import <MachOKit/MKNodeFieldRecipe.h>

NS_ASSUME_NONNULL_BEGIN

//----------------------------------------------------------------------------//
@interface MKNodeFieldBuilder : NSObject {
@package
    NSString *_name;
    NSString *_description;
    id<MKNodeFieldValueRecipe> _valueRecipe;
    id<MKNodeFieldDataRecipe> _dataRecipe;
    id<MKNodeFieldType> _type;
    NSFormatter *_formatter;
    MKNodeFieldOptions _options;
    NSString *_alternateFieldName;
}

+ (instancetype)builderWithProperty:(NSString*)propertyName type:(nullable id<MKNodeFieldType>)type offset:(mk_vm_offset_t)offset size:(mk_vm_size_t)size;
+ (instancetype)builderWithProperty:(NSString*)propertyName type:(id<MKNodeFieldNumericType>)type offset:(mk_vm_offset_t)offset;
+ (instancetype)builderWithProperty:(NSString*)propertyName type:(nullable id<MKNodeFieldType>)type;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Field Configuration
//! @name       Field Configuration
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@property (nonatomic, strong, nullable) NSString *name;

@property (nonatomic, strong, nullable) NSString *description;

@property (nonatomic, strong, nullable) id<MKNodeFieldType> type;

@property (nonatomic, strong, nullable) id<MKNodeFieldValueRecipe> valueRecipe;

@property (nonatomic, strong, nullable) id<MKNodeFieldDataRecipe> dataRecipe;

@property (nonatomic, readwrite) MKNodeFieldOptions options;

@property (nonatomic, strong, nullable) NSFormatter *formatter;

@property (nonatomic, strong, nullable) NSString *alternateFieldName;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Creating Fields
//! @name       Creating Fields
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

- (MKNodeField*)build;

@end

NS_ASSUME_NONNULL_END
