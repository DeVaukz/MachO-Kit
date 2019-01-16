//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKRegularSymbol.m
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

#import "MKRegularSymbol.h"
#import "MKInternal.h"
#import "MKCString.h"
#import "MKSection.h"

//----------------------------------------------------------------------------//
@implementation MKRegularSymbol

//|++++++++++++++++++++++++++++++++++++|//
+ (uint32_t)canInstantiateWithEntry:(struct nlist_64)nlist
{
    if (self != MKRegularSymbol.class)
        return 0;
    
    // If it's not a stab, it's a regular symbol
    return (nlist.n_type & N_STAB) == 0 ? 20 : 0;
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Values
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (MKOptional*)name
{ return _name; }

//|++++++++++++++++++++++++++++++++++++|//
- (MKOptional*)section
{ return _section; }

//|++++++++++++++++++++++++++++++++++++|//
- (MKSymbolType)symbolType
{ return self.type & N_TYPE; }

//|++++++++++++++++++++++++++++++++++++|//
- (BOOL)isPrivateExternal
{ return !!(self.type & N_PEXT); }

//|++++++++++++++++++++++++++++++++++++|//
- (BOOL)isExternal
{ return !!(self.type & N_EXT); }

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
+ (MKNodeFieldBuilder*)_typeFieldBuilder
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-method-access"
    MKNodeFieldBuilder *type = [super _typeFieldBuilder];
#pragma clang diagnostic pop
    
    MKNodeFieldTypeOptionSet *externalType = [MKNodeFieldTypeOptionSet optionSetWithUnderlyingType:MKNodeFieldTypeUnsignedByte.sharedInstance name:nil options:@{
        _$((uint8_t)N_EXT): @"N_EXT"
    }];
    
    MKNodeFieldTypeOptionSet *privateExternalType = [MKNodeFieldTypeOptionSet optionSetWithUnderlyingType:MKNodeFieldTypeUnsignedByte.sharedInstance name:nil options:@{
        _$((uint8_t)N_PEXT): @"N_PEXT"
    }];
    
    MKNodeFieldTypeBitfieldMask *externalTypeMask = [MKNodeFieldTypeBitfieldMask new];
    externalTypeMask.type = externalType;
    externalTypeMask.mask = _$((uint8_t)N_EXT);
    
    MKNodeFieldTypeBitfieldMask *privateExternalTypeMask = [MKNodeFieldTypeBitfieldMask new];
    privateExternalTypeMask.type = privateExternalType;
    privateExternalTypeMask.mask = _$((uint8_t)N_PEXT);
    
    MKNodeFieldTypeBitfieldMask *typeMask = [MKNodeFieldTypeBitfieldMask new];
    typeMask.type = MKNodeFieldSymbolType.sharedInstance;
    typeMask.mask = _$((uint8_t)N_TYPE);
    
    type.type = [MKNodeFieldTypeBitfield bitfieldWithType:(id)type.type bits:@[externalTypeMask, privateExternalTypeMask, typeMask] name:nil];
    
    [typeMask release];
    [privateExternalTypeMask release];
    [externalTypeMask release];
    
    return type;
}

//|++++++++++++++++++++++++++++++++++++|//
+ (MKNodeFieldBuilder*)_nameFieldBuilder
{
    MKNodeFieldBuilder *name = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(name)
        type:[MKNodeFieldTypeNode typeWithNodeType:MKCString.class]
    ];
    name.description = @"Name";
    name.options = MKNodeFieldOptionHidden | MKNodeFieldOptionIgnoreContainerContents | MKNodeFieldOptionHideAddressAndData;
    
    return name;
}

//|++++++++++++++++++++++++++++++++++++|//
+ (MKNodeFieldBuilder*)_sectionFieldBuilder
{
    MKNodeFieldBuilder *section = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(section)
        type:[MKNodeFieldTypeNode typeWithNodeType:MKSection.class]
    ];
    section.description = @"Section";
    section.options = MKNodeFieldOptionHidden | MKNodeFieldOptionIgnoreContainerContents | MKNodeFieldOptionHideAddressAndData;
    
    return section;
}

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        self.class._nameFieldBuilder.build,
        self.class._sectionFieldBuilder.build
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
