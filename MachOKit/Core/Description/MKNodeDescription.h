//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       MKNodeDescription.h
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
#import <MachOKit/MKNodeFieldBuilder.h>

#import <MachOKit/MKNodeFieldDeprecated.h>

NS_ASSUME_NONNULL_BEGIN

//----------------------------------------------------------------------------//
@interface MKNodeDescription : NSObject {
@package
    MKNodeDescription *_parent;
    NSArray<MKNodeField*> *_fields;
}

+ (instancetype)nodeDescriptionWithParentDescription:(nullable MKNodeDescription*)parent fields:(nullable NSArray<MKNodeField*> *)fields;

- (instancetype)initWithParentDescription:(nullable MKNodeDescription*)parent fields:(nullable NSArray<MKNodeField*> *)fields NS_DESIGNATED_INITIALIZER;

@property (nonatomic, readonly, nullable) MKNodeDescription* parent;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Working with Fields
//! @name       Working with Fields
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@property (nonatomic, readonly) NSArray<MKNodeField*> *fields;
@property (nonatomic, readonly) NSArray<MKNodeField*> *allFields;

//! Returns the *first* fields with the provided \a name.
- (nullable MKNodeField*)fieldWithName:(NSString*)name searchAllFields:(BOOL)searchAllFields;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Obtaining a Description
//! @name       Obtaining a Description
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//! Returns a complete description of the node, containing all fields and their
//! values.  If \a traversalDepth is > 1, invokes \c -recursiveDescription: on
//! fields of class \ref MKNode, passing a value of \c traversalDepth-1 as the
//! argument.
- (NSString*)textualDescriptionForNode:(MKNode*)node traversalDepth:(NSUInteger)traversalDepth;

@end

NS_ASSUME_NONNULL_END
