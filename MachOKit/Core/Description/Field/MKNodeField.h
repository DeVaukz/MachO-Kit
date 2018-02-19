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

#import <MachOKit/MKNodeFieldType.h>
#import <MachOKit/MKNodeFieldValueRecipe.h>
#import <MachOKit/MKNodeFieldDataRecipe.h>

@class MKNode;

NS_ASSUME_NONNULL_BEGIN

//----------------------------------------------------------------------------//
//! @name       Node Field Options
//! @relates    MKNodeField
//!
typedef NS_OPTIONS(NSUInteger, MKNodeFieldOptions) {
    MKNodeFieldOptionNone                                       = 0,
    //! Hint to treat the field as a if it were a leaf when building a
    //! recursive description.  If the type of the field is a container
    //! (e.g, a node or collection type), it will be formatted as if it
    //! were a non-container type (a value type), using the \c valueFormatter
    //! if available.  The container's contents will *not* be enumerated.
    //! Only applicable to container type fields.
    MKNodeFieldOptionIgnoreContainerContents                    = (1U << 1),
    MKNodeFieldOptionFormatCollectionValues                     = MKNodeFieldOptionIgnoreContainerContents,
    //! Hint to merge the contents of the field with the other fields of
    //! the node.  Wherever the field would have appeared, it's contents
    //! appear instead.
    //! Only applicable to container type fields.
    MKNodeFieldOptionMergeContainerContents                     = (1U << 2),
    MKNodeFieldOptionMergeWithParent                            = MKNodeFieldOptionMergeContainerContents,
/* Display Options */
    //! Hint to display the field as a child of the node, rather than as a
    //! detail of the node.
    MKNodeFieldOptionDisplayAsChild                             = (1U << 6),
    //! Hint to treat the field as a detail of the node, rather than as a
    //! child of the node.
    MKNodeFieldOptionDisplayAsDetail                            = (1U << 7),
    //! Hint to display the contents of a collection field as a child
    //! of the field.  Only applicable to container type fields.
    MKNodeFieldOptionDisplayContainerContentsAsChild            = (1U << 8),
    MKNodeFieldOptionDisplayCollectionContentsAsChild           = MKNodeFieldOptionDisplayContainerContentsAsChild,
    //! Hint to display the contents of a collection field as a detail
    //! of the field.  Only applicable to container type fields.
    MKNodeFieldOptionDisplayContainerContentsAsDetail           = (1U << 9),
    MKNodeFieldOptionDisplayCollectionContentsAsDetail          = MKNodeFieldOptionDisplayContainerContentsAsDetail
};



//----------------------------------------------------------------------------//
@interface MKNodeField : NSObject {
@package
    NSString *_name;
    NSString *_description;
    id<MKNodeFieldType> _type;
    id<MKNodeFieldValueRecipe> _valueRecipe;
    id<MKNodeFieldDataRecipe> _dataRecipe;
    NSFormatter *_valueFormatter;
    MKNodeFieldOptions _options;
}

- (instancetype)initWithName:(NSString*)name description:(nullable NSString*)description type:(nullable id<MKNodeFieldType>)type value:(id<MKNodeFieldValueRecipe>)valueRecipe data:(nullable id<MKNodeFieldDataRecipe>)dataRecipe formatter:(nullable NSFormatter*)valueFormatter options:(MKNodeFieldOptions)options;

- (instancetype)init NS_UNAVAILABLE;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Field Configuration
//! @name       Field Configuration
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//! The field options.
@property (nonatomic, readonly) MKNodeFieldOptions options;

//! The name of the field.
@property (nonatomic, readonly) NSString *name;

//! A short description of the field.
@property (nonatomic, readonly, nullable) NSString *description;

//! The type of the field.
@property (nonatomic, readonly, nullable) id<MKNodeFieldType> type;

//! The steps to retrieve the value for the field from a node.
@property (nonatomic, readonly) id<MKNodeFieldValueRecipe> valueRecipe;

//! The steps to retreive the data for the field from a node.
@property (nonatomic, readonly, nullable) id<MKNodeFieldDataRecipe> dataRecipe;

//! A formatter used to format the value of the field.
@property (nonatomic, readonly, nullable) NSFormatter *valueFormatter;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Obtaining a Formatted Description
//! @name       Obtaining a Formatted Description
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

- (NSString*)formattedDescriptionForNode:(MKNode*)node __attribute__((deprecated("To be removed.")));

@end

NS_ASSUME_NONNULL_END
