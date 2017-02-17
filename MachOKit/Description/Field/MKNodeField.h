//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       MKNodeField.h
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

#include <MachOKit/macho.h>
@import Foundation;

#import <MachOKit/MKNodeFieldValueRecipe.h>
#import <MachOKit/MKNodeFieldDataRecipe.h>

@class MKNode;

NS_ASSUME_NONNULL_BEGIN

//----------------------------------------------------------------------------//
//! @name       Node Field Options
//! @relates    MKFormattedNodeField
//!
typedef NS_ENUM(NSUInteger, MKNodeFieldOptions) {
    MKNodeFieldOptionsNone                                      = 0,
    //! Hint to display the contents of the collection as children of the
    //! node, rather than as children of the field.
    //! Only applicable to collections.
    MKNodeFieldOptionDisplayCollectionContentsAsChildren        = (1U<<10),
};



//----------------------------------------------------------------------------//
@interface MKNodeField : NSObject {
@package
    NSString *_name;
    NSString *_description;
    id<MKNodeFieldValueRecipe> _valueRecipe;
    id<MKNodeFieldDataRecipe> _dataRecipe;
    NSFormatter *_valueFormatter;
    MKNodeFieldOptions _options;
}

- (instancetype)initWithName:(NSString*)name description:(nullable NSString*)description value:(id<MKNodeFieldValueRecipe>)valueRecipe data:(nullable id<MKNodeFieldDataRecipe>)dataRecipe formatter:(nullable NSFormatter*)valueFormatter options:(MKNodeFieldOptions)options;

- (instancetype)init NS_UNAVAILABLE;

//! The name of this field.  This usually matches the name of the property
//! used to retreive the data for this field from the node.
@property (nonatomic, readonly) NSString *name;
//! A short description of this field.
@property (nonatomic, readonly, nullable) NSString *description;
//! A sequence of steps to retrieve the value for this field from a node.
@property (nonatomic, readonly) id<MKNodeFieldValueRecipe> valueRecipe;
//! A sequence of steps to retreive the data for this field from a node.
@property (nonatomic, readonly, nullable) id<MKNodeFieldDataRecipe> dataRecipe;
//! The formatter used to format the value of this field.
@property (nonatomic, readonly, nullable) NSFormatter *valueFormatter;
//! The field options.
@property (nonatomic, readonly) MKNodeFieldOptions options;

- (NSString*)formattedDescriptionForNode:(MKNode*)node;

@end

NS_ASSUME_NONNULL_END
