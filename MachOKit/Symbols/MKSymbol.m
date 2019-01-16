//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKSymbol.m
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

#import "MKSymbol.h"
#import "MKInternal.h"
#import "MKCString.h"
#import "MKMachO+Segments.h"
#import "MKSection.h"
#import "MKMachO+Symbols.h"
#import "MKStringTable.h"
#import "MKSymbolTable.h"

//----------------------------------------------------------------------------//
@implementation MKSymbol

//|++++++++++++++++++++++++++++++++++++|//
+ (id*)_subclassesCache
{ static NSSet *subclasses; return &subclasses; }

//|++++++++++++++++++++++++++++++++++++|//
+ (uint32_t)canInstantiateWithEntry:(struct nlist_64)nlist
{
#pragma unused (nlist)
    return (self == MKSymbol.class) ? 10 : 0;
}

//|++++++++++++++++++++++++++++++++++++|//
+ (Class)classForEntry:(struct nlist_64)nlist
{
    return [self bestSubclassWithRanking:^(Class cls) {
        return [cls canInstantiateWithEntry:nlist];
    }];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - Creating a Symbol
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
bool ReadNList(struct nlist_64 *result, mk_vm_offset_t offset, MKBackedNode *node, NSError **error)
{
    NSCParameterAssert(node.dataModel != nil);
    
    id<MKDataModel> dataModel = node.dataModel;
    size_t pointerSize = dataModel.pointerSize;
    
    if (pointerSize == 8)
    {
        struct nlist_64 entry;
        if ([node.memoryMap copyBytesAtOffset:offset fromAddress:node.nodeContextAddress into:&entry length:sizeof(entry) requireFull:YES error:error] < sizeof(entry))
            return false;
        
        result->n_un.n_strx = MKSwapLValue32(entry.n_un.n_strx, dataModel);
        result->n_type = entry.n_type;
        result->n_sect = entry.n_sect;
        result->n_desc = MKSwapLValue16(entry.n_desc, dataModel);
        result->n_value = MKSwapLValue64(entry.n_value, dataModel);
    }
    else if (pointerSize == 4)
    {
        struct nlist entry;
        if ([node.memoryMap copyBytesAtOffset:offset fromAddress:node.nodeContextAddress into:&entry length:sizeof(entry) requireFull:YES error:error] < sizeof(entry))
            return false;
        
        result->n_un.n_strx = MKSwapLValue32(entry.n_un.n_strx, dataModel);
        result->n_type = entry.n_type;
        result->n_sect = entry.n_sect;
        result->n_desc = (uint16_t)MKSwapLValue16s(entry.n_desc, dataModel);
        result->n_value = (uint64_t)MKSwapLValue32(entry.n_value, dataModel);
    }
    else
    {
        NSString *reason = [NSString stringWithFormat:@"Unsupported pointer size [%zu].", pointerSize];
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:nil];
    }
    
    return true;
}

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)symbolAtOffset:(mk_vm_offset_t)offset fromParent:(MKSymbolTable*)parent error:(NSError**)error
{
    NSError *memoryMapError = nil;
    struct nlist_64 nlist;
    
    if (ReadNList(&nlist, offset, parent, &memoryMapError) == false) {
        MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_EINTERNAL_ERROR underlyingError:memoryMapError description:@"Could not read nlist at offset [%" MK_VM_PRIuOFFSET "] from %@.", offset, parent.nodeDescription];
        return nil;
    }
    
    Class symbolClass = [self classForEntry:nlist];
    if (symbolClass == NULL) {
        NSString *reason = [NSString stringWithFormat:@"No class for symbol table entry."];
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:reason userInfo:nil];
    }
    
    return [[[symbolClass alloc] initWithOffset:offset fromParent:parent error:error] autorelease];
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithOffset:(mk_vm_offset_t)offset fromParent:(MKBackedNode*)parent error:(NSError**)error
{
    self = [super initWithOffset:offset fromParent:parent error:error];
    if (self == nil) return nil;
    
    // Read the nlist
    {
        NSError *nlistError = nil;
        struct nlist_64 entry;
        
        if (!ReadNList(&entry, offset, parent, &nlistError)) {
            MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_EINTERNAL_ERROR underlyingError:nlistError description:@"Could not read nlist."];
            [self release]; return nil;
        }
        
        // These have already been byte-swapped
        _strx = entry.n_un.n_strx;
        _type = entry.n_type;
        _sect = entry.n_sect;
        _desc = entry.n_desc;
        _value = entry.n_value;
    }
    
    // The base MKSymbol class does not expose name and section properties, but
    // enough of the subclasses do that it makes sense to perform the lookup here.
    
    MKMachOImage *image = self.macho;
    
    // Lookup the symbol name in the string table.  Symbols with a index into
    // the string table of zero (n_un.n_strx == 0) are defined to have a
    // null, "", name.  Therefore all string indexes to non null names must not
    // have a zero string index.
    while (_strx != 0)
    {
        MKOptional<MKStringTable*> *stringTable = image.stringTable;
        if (stringTable.value == nil) {
            NSError *error = [NSError mk_errorWithDomain:MKErrorDomain code:MK_ENOT_FOUND underlyingError:stringTable.error description:@"Could not load the string table."];
            _name = [[MKOptional alloc] initWithError:error];
            break;
        }
        
        MKCString *string = stringTable.value.strings[@(_strx)];
        if (string == nil) {
            NSError *error = [NSError mk_errorWithDomain:MKErrorDomain code:MK_ENOT_FOUND description:@"String table does not contain an entry for index [%" PRIu32 "].", _strx];
            _name = [[MKOptional alloc] initWithError:error];
            break;
        }
        
        _name = [[MKOptional alloc] initWithValue:string];
        break;
    }
    
    // Lookup the section.
    if (_sect != NO_SECT)
    {
        MKSection *section = image.sections[@(_sect - 1)];
        if (section) {
            _section = [[MKOptional alloc] initWithValue:section];
        } else {
            NSError *error = [NSError mk_errorWithDomain:MKErrorDomain code:MK_ENOT_FOUND description:@"No section at index [%" PRIu8 "].", _sect];
            _section = [[MKOptional alloc] initWithError:error];
        }
    }
    else
    {
        _section = [MKOptional new];
    }
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (void)dealloc
{
    [_section release];
    [_name release];
    
    [super dealloc];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  nlist Values
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@synthesize strx = _strx;
@synthesize type = _type;
@synthesize sect = _sect;
@synthesize desc = _desc;
@synthesize value = _value;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_size_t)nodeSize
{ return self.dataModel.pointerSize == 8 ? sizeof(struct nlist_64) : sizeof(struct nlist); }

//|++++++++++++++++++++++++++++++++++++|//
+ (MKNodeFieldBuilder*)_strxFieldBuilder
{
    MKNodeFieldBuilder *strx = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(strx)
        type:MKNodeFieldTypeUnsignedDoubleWord.sharedInstance
        offset:offsetof(struct nlist, n_un.n_strx)
        size:sizeof(uint32_t)
    ];
    strx.description = @"String Table Index";
    strx.options = MKNodeFieldOptionDisplayAsDetail;
    
    return strx;
}

//|++++++++++++++++++++++++++++++++++++|//
+ (MKNodeFieldBuilder*)_typeFieldBuilder
{
    MKNodeFieldBuilder *type = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(type)
        type:MKNodeFieldTypeUnsignedByte.sharedInstance
        offset:offsetof(struct nlist, n_type)
        size:sizeof(uint8_t)
    ];
    type.description = @"Type";
    type.options = MKNodeFieldOptionDisplayAsDetail;
    
    return type;
}

//|++++++++++++++++++++++++++++++++++++|//
+ (MKNodeFieldBuilder*)_sectFieldBuilder
{
    MKNodeFieldBuilder *sect = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(sect)
        type:MKNodeFieldTypeUnsignedByte.sharedInstance
        offset:offsetof(struct nlist, n_sect)
        size:sizeof(uint8_t)
    ];
    sect.description = @"Section Index";
    sect.options = MKNodeFieldOptionDisplayAsDetail;
    
    return sect;
}

//|++++++++++++++++++++++++++++++++++++|//
+ (MKNodeFieldBuilder*)_descFieldBuilder
{
    MKNodeFieldBuilder *desc = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(desc)
        type:MKNodeFieldTypeUnsignedWord.sharedInstance
        offset:offsetof(struct nlist, n_desc)
        size:sizeof(uint16_t)
    ];
    desc.description = @"Description";
    desc.options = MKNodeFieldOptionDisplayAsDetail;
    
    return desc;
}

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeFieldBuilder*)_valueFieldBuilder
{
    MKNodeFieldBuilder *value = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(value)
        type:MKNodeFieldTypeUnsignedQuadWord.sharedInstance
        offset:offsetof(struct nlist, n_value)
        size:self.dataModel.pointerSize
    ];
    value.description = @"Value";
    value.options = MKNodeFieldOptionDisplayAsDetail;
    
    return value;
}

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        self.class._strxFieldBuilder.build,
        self.class._typeFieldBuilder.build,
        self.class._sectFieldBuilder.build,
        self.class._descFieldBuilder.build,
        self._valueFieldBuilder.build
    ]];
}

@end
