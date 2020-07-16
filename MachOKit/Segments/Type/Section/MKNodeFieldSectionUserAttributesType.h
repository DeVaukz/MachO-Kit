//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       MKNodeFieldSectionUserAttributesType.h
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
#import <Foundation/Foundation.h>

#include <mach-o/loader.h>

#import <MachOKit/MKNodeFieldTypeDoubleWord.h>
#import <MachOKit/MKNodeFieldOptionSetType.h>

NS_ASSUME_NONNULL_BEGIN

//----------------------------------------------------------------------------//
//! @name       Section User Attributes
//! @relates    MKNodeFieldSectionUserAttributesType
//!
//
typedef NS_OPTIONS(uint32_t, MKSectionUserAttributes) {
    //! Section contains only true machine instructions
    MKSectionAttributePureInstructions          = S_ATTR_PURE_INSTRUCTIONS,
    //! Section contains coalesced symbols that are not to be in a ranlib table
    //! of contents
    MKSectionAttributeNoTOC                     = S_ATTR_NO_TOC,
    //! ok to strip static symbols in this section in files with the
    //! \c MH_DYLDLINK flag
    MKSectionAttributeStripStaticSymbols        = S_ATTR_STRIP_STATIC_SYMS,
    //! No dead stripping
    MKSectionAttributeNoDeadStripping           = S_ATTR_NO_DEAD_STRIP,
    //! Blocks are live if they reference live blocks
    MKSectionAttributeLiveSupport               = S_ATTR_LIVE_SUPPORT,
    //! Used with i386 code stubs written on by dyld
    MKSectionAttributeSelfModifyingCode         = S_ATTR_SELF_MODIFYING_CODE,
    //! A debug section
    MKSectionAttributeDebug                     = S_ATTR_DEBUG
};



//----------------------------------------------------------------------------//
@interface MKNodeFieldSectionUserAttributesType : MKNodeFieldTypeUnsignedDoubleWord <MKNodeFieldOptionSetType>

+ (instancetype)sharedInstance;

@end

NS_ASSUME_NONNULL_END
