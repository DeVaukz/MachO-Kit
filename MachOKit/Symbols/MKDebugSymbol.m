//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKDebugSymbol.m
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

#import "MKDebugSymbol.h"
#import "MKInternal.h"
#import "MKCString.h"
#import "MKSection.h"

//----------------------------------------------------------------------------//
@implementation MKDebugSymbol

//|++++++++++++++++++++++++++++++++++++|//
+ (uint32_t)canInstantiateWithEntry:(struct nlist_64)nlist
{
    if (self != MKDebugSymbol.class)
        return 0;
    
    // If any of the N_STAB bits are set, this is a debugging entry.
    //
    // Debugger symbols use the entire 'type' field to indicate their type.
    // Some of these bits may overlap with the bits in the N_TYPE mask used
    // by regular symbols, so we need to return a larger score if this is
    // actually a debugger symbol.
    return (nlist.n_type & N_STAB) != 0 ? 60 : 0;
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Values
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (MKSTABType)stabType
{ return _type; }

//|++++++++++++++++++++++++++++++++++++|//
- (MKOptional*)name
{ return _name; }

//|++++++++++++++++++++++++++++++++++++|//
- (MKOptional*)section
{ return _section; }

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
+ (MKNodeFieldBuilder*)_strxFieldBuilder
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-method-access"
    MKNodeFieldBuilder *strx = [super _strxFieldBuilder];
#pragma clang diagnostic pop
    strx.alternateFieldName = MK_PROPERTY(name);
    strx.options |= MKNodeFieldOptionSubstituteAlternateFieldValue;
    
    return strx;
}

//|++++++++++++++++++++++++++++++++++++|//
+ (MKNodeFieldBuilder*)_typeFieldBuilder
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-method-access"
    MKNodeFieldBuilder *type = [super _typeFieldBuilder];
#pragma clang diagnostic pop
    
    MKNodeFieldTypeOptionSet *symbolType = [MKNodeFieldTypeOptionSet optionSetWithUnderlyingType:MKNodeFieldTypeUnsignedByte.sharedInstance name:nil traits:MKNodeFieldOptionSetTraitPartialMatchingAllowed options:@{
        _$((uint8_t)N_STAB): @"N_STAB"
    }];
    
    MKNodeFieldTypeBitfieldMask *symbolTypeMask = [MKNodeFieldTypeBitfieldMask new];
    symbolTypeMask.type = symbolType;
    symbolTypeMask.mask = _$((uint8_t)N_STAB);
    
    MKNodeFieldTypeBitfieldMask *STABTypeMask = [MKNodeFieldTypeBitfieldMask new];
    STABTypeMask.type = MKNodeFieldSTABType.sharedInstance;
    STABTypeMask.mask = _$((uint8_t)0xFF);
    
    type.type = [MKNodeFieldTypeBitfield bitfieldWithType:(id)type.type bits:@[symbolTypeMask, STABTypeMask] name:nil];
    
    [STABTypeMask release];
    [symbolTypeMask release];
    
    return type;
}

//|++++++++++++++++++++++++++++++++++++|//
+ (MKNodeFieldBuilder*)_sectFieldBuilder
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-method-access"
    MKNodeFieldBuilder *sect = [super _sectFieldBuilder];
#pragma clang diagnostic pop
    sect.alternateFieldName = MK_PROPERTY(section);
    sect.type = [MKNodeFieldTypeEnumeration enumerationWithUnderlyingType:(id)sect.type name:nil elements:@{
        _$((uint8_t)NO_SECT): @"NO_SECT"
    }];
    sect.formatter = sect.type.formatter;
    
    return sect;
}

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    MKNodeFieldBuilder *name = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(name)
        type:[MKNodeFieldTypeNode typeWithNodeType:MKCString.class]
    ];
    name.description = @"Name";
    name.options = MKNodeFieldOptionHidden | MKNodeFieldOptionIgnoreContainerContents | MKNodeFieldOptionHideAddressAndData;
    
    MKNodeFieldBuilder *section = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(section)
        type:[MKNodeFieldTypeNode typeWithNodeType:MKSection.class]
    ];
    section.description = @"Section";
    section.options = MKNodeFieldOptionHidden | MKNodeFieldOptionIgnoreContainerContents | MKNodeFieldOptionHideAddressAndData;
    
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        name.build,
        section.build
    ]];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  NSObject
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (NSString*)description
{
    return self.name.value.string ?: [super description];
}

@end
