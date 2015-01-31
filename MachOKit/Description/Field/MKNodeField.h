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

@class MKNode;
#import <MachOKit/MKNodeFieldRecipe.h>

//----------------------------------------------------------------------------//
@interface MKNodeField : NSObject {
@package
    NSString *_name;
    NSString *_description;
    id<MKNodeFieldRecipe> _valueRecipe;
}

+ (instancetype)nodeFieldWithName:(NSString*)name keyPath:(NSString*)keyPath description:(NSString*)description;
+ (instancetype)nodeFieldWithProperty:(NSString*)property description:(NSString*)description;

- (instancetype)initWithName:(NSString*)name description:(NSString*)description value:(id<MKNodeFieldRecipe>)valueRecipe;

//! The name of this field.  This usually matches the name of the property
//! used to retreive the data for this field from the node.
@property (nonatomic, readonly) NSString *name;
//! A short description of this field.
@property (nonatomic, readonly) NSString *description;
//! A sequence of steps to retreive the value for this field from a node.
@property (nonatomic, readonly) id<MKNodeFieldRecipe> valueRecipe;

- (NSString*)formattedDescriptionForNode:(MKNode*)node;

@end
