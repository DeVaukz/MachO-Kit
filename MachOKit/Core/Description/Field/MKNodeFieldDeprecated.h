//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       MKNodeFieldDeprecated.h
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

#import <MachOKit/MKNodeFieldBuilder.h>

NS_ASSUME_NONNULL_BEGIN

//----------------------------------------------------------------------------//
//! @name       Node Field Format
//! @relates    NSNumberFormatter (MKNodeField)
//!
typedef NS_ENUM(NSUInteger, MKNodeFieldFormat) {
    MKNodeFieldFormatDefault  = 0,
    //! Format the value of this field as a decimal number.
    MKNodeFieldFormatDecimal,
    //! Format the value of this field as a hexadecimal number.
    MKNodeFieldFormatHex,
    //! Format the value of this field as a hexadecimal number, without any
    //! leading zeros.
    MKNodeFieldFormatHexCompact,
    
    //! Alias for formatting addresses.
    MKNodeFieldFormatAddress        = MKNodeFieldFormatHex,
    //! Alias for formatting sizes
    MKNodeFieldFormatSize           = MKNodeFieldFormatDecimal,
    //! Alias for formatting offsets
    MKNodeFieldFormatOffset         = MKNodeFieldFormatHexCompact
};



//----------------------------------------------------------------------------//
@interface MKNodeField (Deprecated)

+ (instancetype)nodeFieldWithName:(NSString*)name keyPath:(NSString*)keyPath description:(nullable NSString*)description;
+ (instancetype)nodeFieldWithProperty:(NSString*)property description:(nullable NSString*)description;

@end



//----------------------------------------------------------------------------//
@interface MKFormattedNodeField : MKNodeField

+ (instancetype)fieldWithName:(NSString*)name keyPath:(NSString*)keyPath description:(nullable NSString*)description format:(MKNodeFieldFormat)format;
+ (instancetype)fieldWithProperty:(NSString*)property description:(nullable NSString*)description format:(MKNodeFieldFormat)format;

@end



//----------------------------------------------------------------------------//
@interface MKPrimativeNodeField : MKNodeField

+ (instancetype)fieldWithName:(NSString*)name keyPath:(NSString*)keyPath description:(nullable NSString*)description offset:(mk_vm_offset_t)offset size:(mk_vm_size_t)size format:(MKNodeFieldFormat)format;
+ (instancetype)fieldWithProperty:(NSString*)property description:(nullable NSString*)description offset:(mk_vm_offset_t)offset size:(mk_vm_size_t)size format:(MKNodeFieldFormat)format;

+ (instancetype)fieldWithName:(NSString*)name keyPath:(NSString*)keyPath description:(nullable NSString*)description offset:(mk_vm_offset_t)offset size:(mk_vm_size_t)size;
+ (instancetype)fieldWithProperty:(NSString*)property description:(nullable NSString*)description offset:(mk_vm_offset_t)offset size:(mk_vm_size_t)size;

@end



//----------------------------------------------------------------------------//
@interface MKFlagsNodeField : MKNodeField

+ (instancetype)fieldWithName:(NSString*)name keyPath:(NSString*)keyPath description:(nullable NSString*)description offset:(mk_vm_offset_t)offset size:(mk_vm_size_t)size flags:(NSDictionary*)flags;
+ (instancetype)fieldWithProperty:(NSString*)property description:(nullable NSString*)description offset:(mk_vm_offset_t)offset size:(mk_vm_size_t)size flags:(NSDictionary*)flags;

@end

NS_ASSUME_NONNULL_END
