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
#import "MKMachO.h"
#import "MKMachO+Symbols.h"
#import "MKDataModel.h"
#import "MKStringTable.h"

//----------------------------------------------------------------------------//
@implementation MKSymbol

//|++++++++++++++++++++++++++++++++++++|//
+ (id*)_subclassesCache
{ static NSSet *subclasses; return &subclasses; }

//|++++++++++++++++++++++++++++++++++++|//
+ (uint32_t)canInstantiateWithNList:(struct nlist_64)nlist parent:(MKBackedNode*)parent
{
#pragma unused (nlist)
#pragma unused (parent)
    
    return (self == MKSymbol.class) ? 10 : 0;
}

//|++++++++++++++++++++++++++++++++++++|//
+ (Class)classForSymbolWithOffset:(mk_vm_offset_t)offset fromParent:(MKBackedNode*)parent error:(NSError**)error
{
    struct nlist_64 entry;
    if (!ReadNList(&entry, offset, parent, error))
    { return nil; }
    
    return [self bestSubclassWithRanking:^(Class cls) {
        return [cls canInstantiateWithNList:entry parent:parent];
    }];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - Creating a Symbol
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
bool ReadNList(struct nlist_64 *result, mk_vm_offset_t offset, MKBackedNode *parent, NSError **error)
{
    MKMachOImage *image = parent.macho;
    
    if (image.dataModel.pointerSize == 8)
    {
        struct nlist_64 entry;
        if ([parent.memoryMap copyBytesAtOffset:offset fromAddress:parent.nodeContextAddress into:&entry length:sizeof(entry) requireFull:YES error:error] < sizeof(entry))
        { return false; }
        
        result->n_un.n_strx = MKSwapLValue32(entry.n_un.n_strx, image.dataModel);
        result->n_type = entry.n_type;
        result->n_sect = entry.n_sect;
        result->n_desc = MKSwapLValue16(entry.n_desc, image.dataModel);
        result->n_value = MKSwapLValue64(entry.n_value, image.dataModel);
    }
    else if (image.dataModel.pointerSize == 4)
    {
        struct nlist entry;
        if ([parent.memoryMap copyBytesAtOffset:offset fromAddress:parent.nodeContextAddress into:&entry length:sizeof(entry) requireFull:YES error:error] < sizeof(entry))
        { return false; }
        
        result->n_un.n_strx = MKSwapLValue32(entry.n_un.n_strx, image.dataModel);
        result->n_type = entry.n_type;
        result->n_sect = entry.n_sect;
        result->n_desc = (uint16_t)MKSwapLValue16s(entry.n_desc, image.dataModel);
        result->n_value = (uint64_t)MKSwapLValue32(entry.n_value, image.dataModel);
    }
    else
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Unsupported data model." userInfo:nil];
    
    return true;
}

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)symbolWithOffset:(mk_vm_offset_t)offset fromParent:(MKBackedNode*)parent error:(NSError**)error
{
    Class symbolClass = [self classForSymbolWithOffset:offset fromParent:parent error:error];
    NSAssert(symbolClass, @"");
    
    return [[[symbolClass alloc] initWithOffset:offset fromParent:parent error:error] autorelease];
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
    
    MKMachOImage *image = self.macho;
    
    // Lookup the symbol name in the string table.  Symbols with a index into
    // the string table of zero (n_un.n_strx == 0) are defined to have a
    // null, "", name.  Therefore all string indexes to non null names must not
    // have a zero string index.
    while (_strx != 0)
    {
        MKStringTable *stringTable = image.stringTable;
        if (stringTable == nil) {
            MK_PUSH_WARNING(name, MK_ENOT_FOUND, @"Mach-O image %@ does not have a string table.", image);
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
    
    return self;
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - Acessing Symbol Metadata
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@synthesize name = _name;

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
{ return self.macho.dataModel.pointerSize == 8 ? sizeof(struct nlist_64) : sizeof(struct nlist); }

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        [MKNodeField nodeFieldWithProperty:MK_PROPERTY(name) description:@"Symbol Name"],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(strx) description:@"String Table Index" offset:offsetof(struct nlist, n_un.n_strx) size:sizeof(uint32_t)],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(type) description:@"Type" offset:offsetof(struct nlist, n_type) size:sizeof(uint8_t)],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(sect) description:@"Section Index" offset:offsetof(struct nlist, n_sect) size:sizeof(uint8_t)],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(desc) description:@"Description" offset:offsetof(struct nlist, n_desc) size:sizeof(uint16_t)],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(value) description:@"Value" offset:offsetof(struct nlist, n_value) size:self.dataModel.pointerSize]
    ]];
}

@end
