//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKDSCSymbol.m
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

#import "MKDSCSymbol.h"
#import "NSError+MK.h"
#import "MKDSCLocalSymbols.h"
#import "MKDSCStringTable.h"
#import "MKDSCDylibInfos.h"
#import "MKDSCDylibSymbolInfo.h"

//----------------------------------------------------------------------------//
@implementation MKDSCSymbol

//|++++++++++++++++++++++++++++++++++++|//
static bool ReadNList(struct nlist_64 *result, mk_vm_offset_t offset, MKBackedNode *parent, NSError **error)
{
    if (parent.dataModel.pointerSize == 8)
    {
        struct nlist_64 entry;
        if ([parent.memoryMap copyBytesAtOffset:offset fromAddress:parent.nodeContextAddress into:&entry length:sizeof(entry) requireFull:YES error:error] < sizeof(entry))
        { return false; }
        
        result->n_un.n_strx = MKSwapLValue32(entry.n_un.n_strx, parent.dataModel);
        result->n_type = entry.n_type;
        result->n_sect = entry.n_sect;
        result->n_desc = MKSwapLValue16(entry.n_desc, parent.dataModel);
        result->n_value = MKSwapLValue64(entry.n_value, parent.dataModel);
    }
    else if (parent.dataModel.pointerSize == 4)
    {
        struct nlist entry;
        if ([parent.memoryMap copyBytesAtOffset:offset fromAddress:parent.nodeContextAddress into:&entry length:sizeof(entry) requireFull:YES error:error] < sizeof(entry))
        { return false; }
        
        result->n_un.n_strx = MKSwapLValue32(entry.n_un.n_strx, parent.dataModel);
        result->n_type = entry.n_type;
        result->n_sect = entry.n_sect;
        result->n_desc = (uint16_t)MKSwapLValue16s(entry.n_desc, parent.dataModel);
        result->n_value = (uint64_t)MKSwapLValue32(entry.n_value, parent.dataModel);
    }
    else
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Unsupported data model." userInfo:nil];
    
    return true;
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithOffset:(mk_vm_offset_t)offset fromParent:(MKBackedNode*)parent error:(NSError**)error
{
    self = [super initWithOffset:offset fromParent:parent error:error];
    if (self == nil) return nil;
    
    struct nlist_64 entry;
    if (!ReadNList(&entry, offset, parent, error))
    { [self release]; return nil; }
    
    _strx = entry.n_un.n_strx;
    _type = entry.n_type;
    _sect = entry.n_sect;
    _desc = entry.n_desc;
    _value = entry.n_value;
    
    MKDSCLocalSymbols *localSymbolsRegion = [self nearestAncestorOfType:MKDSCLocalSymbols.class];
    
    // Lookup the symbol name in the string table.  Symbols with a index into
    // the string table of zero (n_un.n_strx == 0) are defined to have a
    // null, "", name.  Therefore all string indexes to non null names must not
    // have a zero string index.
    while (_strx != 0)
    {
        MKDSCStringTable *stringTable = localSymbolsRegion.stringTable;
        if (stringTable == nil) {
            MK_PUSH_WARNING(name, MK_ENOT_FOUND, @"Local Symbols region %@ does not have a string table.", localSymbolsRegion);
            break;
        }
        
        MKCString *string = stringTable.strings[@(_strx)];
        if (string == nil) {
            MK_PUSH_WARNING(name, MK_ENOT_FOUND, @"String table does not have an entry for index %" PRIi32 "", _strx);
            break;
        }
        
        _name = [string retain];
        break;
    }
    
    // Lookup the dylib that this symbol belongs to.
    {
        MKDSCDylibInfos *entries = localSymbolsRegion.entriesTable;
        
        if (entries == nil) {
            MK_PUSH_WARNING(dylib, MK_ENOT_FOUND, @"Local Symbols region %@ does not have a dylib infos table.", localSymbolsRegion);
            return nil;
        }
        
        uint32_t index = self.index;
        
        for (MKDSCDylibSymbolInfo *dylib in entries.entries) {
            if (index >= dylib.nlistStartIndex && index < dylib.nlistStartIndex + dylib.nlistCount) {
                _dylib = [dylib retain];
                break;
            }
        }
        
        if (_dylib == nil)
            MK_PUSH_WARNING(dylib, MK_ENOT_FOUND, @"Dylib infos does not have an entry for symbol at index %" PRIu32 "", index);
    }
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (void)dealloc
{
    [_name release];
    [_dylib release];
    
    [super dealloc];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - Acessing Symbol Metadata
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@synthesize dylib = _dylib;
@synthesize name = _name;

//|++++++++++++++++++++++++++++++++++++|//
- (uint32_t)index
{
    return (uint32_t)(_nodeOffset / self.nodeSize);
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - nlist Values
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@synthesize strx = _strx;
@synthesize type = _type;
@synthesize sect = _sect;
@synthesize desc = _desc;
@synthesize value = _value;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_size_t)nodeSize
{ return self.dataModel.pointerSize == 8 ? sizeof(struct nlist_64) : sizeof(struct nlist); }

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        [MKNodeField nodeFieldWithProperty:MK_PROPERTY(dylib) description:@"Dylib"],
        [MKNodeField nodeFieldWithProperty:MK_PROPERTY(name) description:@"Symbol Name"],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(strx) description:@"String Table Index" offset:offsetof(struct nlist, n_un.n_strx) size:sizeof(uint32_t)],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(type) description:@"Type" offset:offsetof(struct nlist, n_type) size:sizeof(uint8_t)],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(sect) description:@"Section Index" offset:offsetof(struct nlist, n_sect) size:sizeof(uint8_t)],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(desc) description:@"Description" offset:offsetof(struct nlist, n_desc) size:sizeof(uint16_t)],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(value) description:@"Value" offset:offsetof(struct nlist, n_value) size:self.dataModel.pointerSize]
    ]];
}

@end
