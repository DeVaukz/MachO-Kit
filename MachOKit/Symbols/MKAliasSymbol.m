//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKAliasSymbol.m
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

#import "MKAliasSymbol.h"
#import "MKInternal.h"
#import "MKCString.h"
#import "MKMachO+Symbols.h"
#import "MKStringTable.h"

//----------------------------------------------------------------------------//
@implementation MKAliasSymbol

//|++++++++++++++++++++++++++++++++++++|//
+ (uint32_t)canInstantiateWithEntry:(struct nlist_64)nlist
{
    if (self != MKAliasSymbol.class)
        return 0;
    
    return (nlist.n_type & N_TYPE) == N_INDR ? 50 : 0;
}


//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithOffset:(mk_vm_offset_t)offset fromParent:(MKBackedNode*)parent error:(NSError**)error
{
    self = [super initWithOffset:offset fromParent:parent error:error];
    if (self == nil) return nil;
    
    MKMachOImage *image = self.macho;
    
    // Lookup the original symbol name in the string table.
    _targetName = [[MKOptional optional] retain];
    while (_value != 0)
    {
        MKOptional<MKStringTable*> *stringTable = image.stringTable;
        if (stringTable.value == nil) {
            NSError *error = [NSError mk_errorWithDomain:MKErrorDomain code:MK_ENOT_FOUND underlyingError:stringTable.error description:@"Could not load the string table."];
            [_targetName release];
            _targetName = [[MKOptional alloc] initWithError:error];
            break;
        }
        
        MKCString *string = stringTable.value.strings[@(_value)];
        if (string == nil) {
            NSError *error = [NSError mk_errorWithDomain:MKErrorDomain code:MK_ENOT_FOUND description:@"String table does not contain an entry for index [%" PRIu32 "].", _value];
            [_targetName release];
            _targetName = [[MKOptional alloc] initWithError:error];
            break;
        }
        
        [_targetName release];
        _targetName = [[MKOptional alloc] initWithValue:string];
        break;
    }
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (void)dealloc
{
    [_targetName release];
    
    [super dealloc];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - Values
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@synthesize targetName = _targetName;

//|++++++++++++++++++++++++++++++++++++|//
- (MKDefinedSymbolFlagsType)symbolFlags
{ return self.desc; }

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
    desc.type = MKNodeFieldDefinedSymbolFlagsType.sharedInstance;
    
    return desc;
}

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeFieldBuilder*)_valueFieldBuilder
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Weverything"
    MKNodeFieldBuilder *value = [super _valueFieldBuilder];
#pragma clang diagnostic pop
    value.alternateFieldName = MK_PROPERTY(targetName);
    value.options |= MKNodeFieldOptionShowAlternateFieldDescription;
    
    return value;
}

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    MKNodeFieldBuilder *targetName = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(targetName)
        type:[MKNodeFieldTypeNode typeWithNodeType:MKCString.class]
    ];
    targetName.description = @"Target Symbol Name";
    targetName.options = MKNodeFieldOptionHidden | MKNodeFieldOptionIgnoreContainerContents | MKNodeFieldOptionHideAddressAndData;
    
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        targetName.build
    ]];
}

@end
