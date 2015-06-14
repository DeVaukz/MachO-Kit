//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       MKPrimativeNodeField.h
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

#import <MachOKit/MKNodeField.h>

NS_ASSUME_NONNULL_BEGIN

//----------------------------------------------------------------------------//
@interface MKPrimativeNodeField : MKNodeField {
@package
    NSFormatter *_valueFormatter;
    id<MKNodeFieldRecipe> _offsetRecipe;
    id<MKNodeFieldRecipe> _sizeRecipe;
}

+ (instancetype)fieldWithName:(NSString*)name keyPath:(NSString*)keyPath description:(nullable NSString*)description offset:(mk_vm_offset_t)offset size:(mk_vm_size_t)size;
+ (instancetype)fieldWithProperty:(NSString*)property description:(nullable NSString*)description offset:(mk_vm_offset_t)offset size:(mk_vm_size_t)size;

+ (instancetype)hexFormattedFieldWithName:(NSString*)name keyPath:(NSString*)keyPath description:(nullable NSString*)description offset:(mk_vm_offset_t)offset size:(mk_vm_size_t)size;
+ (instancetype)hexFormattedFieldWithProperty:(NSString*)property description:(nullable NSString*)description offset:(mk_vm_offset_t)offset size:(mk_vm_size_t)size;

@property (nonatomic, readonly, nullable) NSFormatter *valueFormatter;

@property (nonatomic, readonly) id<MKNodeFieldRecipe> offsetRecipe;
@property (nonatomic, readonly) id<MKNodeFieldRecipe> sizeRecipe;

- (instancetype)initWithName:(NSString*)name description:(nullable NSString*)description value:(id<MKNodeFieldRecipe>)valueRecipe formatter:(nullable NSFormatter*)valueFormatter offset:(id<MKNodeFieldRecipe>)offsetRecipe size:(id<MKNodeFieldRecipe>)sizeReceipe;

@end

NS_ASSUME_NONNULL_END
