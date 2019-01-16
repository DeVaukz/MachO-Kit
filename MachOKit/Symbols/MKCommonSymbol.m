//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKCommonSymbol.m
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

#import "MKCommonSymbol.h"
#import "MKInternal.h"
#import "MKNodeFieldSymbolFlagsType.h"

//----------------------------------------------------------------------------//
@implementation MKCommonSymbol

//|++++++++++++++++++++++++++++++++++++|//
+ (uint32_t)canInstantiateWithEntry:(struct nlist_64)nlist
{
    if (self != MKCommonSymbol.class)
        return 0;
    
    return ((nlist.n_type & N_TYPE) == N_UNDF) && (nlist.n_type & N_EXT) && (nlist.n_value != 0) ? 50 : 0;
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - Values
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (size_t)alignment
{ return (size_t)powerof2( GET_COMM_ALIGN(self.desc) ); }

//|++++++++++++++++++++++++++++++++++++|//
- (size_t)size
{ return self.value; }

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
+ (MKNodeFieldBuilder*)_descFieldBuilder
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-method-access"
    MKNodeFieldBuilder *desc = [super _descFieldBuilder];
#pragma clang diagnostic pop
    
    // TODO - Can flags be present in a common symbol?
    MKNodeFieldTypeBitfieldMask *symbolFlagsMask = [MKNodeFieldTypeBitfieldMask new];
    symbolFlagsMask.type = MKNodeFieldUndefinedSymbolFlagsType.sharedInstance;
    symbolFlagsMask.mask = _$((uint16_t)0x00F8);
    
    MKNodeFieldTypeBitfieldMask *commAlign = [MKNodeFieldTypeBitfieldMask new];
    commAlign.type = MKNodeFieldTypeUnsignedByte.sharedInstance;
    commAlign.mask = _$((uint16_t)0xFF00);
    commAlign.shift = -8;
    
    desc.type = [MKNodeFieldTypeBitfield bitfieldWithType:(id)desc.type bits:@[symbolFlagsMask, commAlign] name:nil];
    desc.formatter = desc.type.formatter;
    
    [commAlign release];
    [symbolFlagsMask release];
    
    return desc;
}

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeFieldBuilder*)_valueFieldBuilder
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Weverything"
    MKNodeFieldBuilder *value = [super _valueFieldBuilder];
#pragma clang diagnostic pop
    value.alternateFieldName = MK_PROPERTY(size);
    value.options |= MKNodeFieldOptionShowAlternateFieldDescription | MKNodeFieldOptionSubstituteAlternateFieldValue;
    
    return value;
}

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    MKNodeFieldBuilder *size = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(size)
        type:MKNodeFieldTypeSize.sharedInstance
    ];
    size.description = @"Size";
    size.options = MKNodeFieldOptionHidden;
    
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        size.build
    ]];
}

@end
