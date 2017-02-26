//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKLCDysymtab.m
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

#import "MKLCDysymtab.h"
#import "MKInternal.h"
#import "MKMachO.h"

//----------------------------------------------------------------------------//
@implementation MKLCDysymtab

@synthesize ilocalsym = _ilocalsym;
@synthesize nlocalsym = _nlocalsym;
@synthesize iextdefsym = _iextdefsym;
@synthesize nextdefsym = _nextdefsym;
@synthesize iundefsym = _iundefsym;
@synthesize nundefsym = _nundefsym;
@synthesize tocoff = _tocoff;
@synthesize ntoc = _ntoc;
@synthesize modtaboff = _modtaboff;
@synthesize nmodtab = _nmodtab;
@synthesize extrefsymoff = _extrefsymoff;
@synthesize nextrefsyms = _nextrefsyms;
@synthesize indirectsymoff = _indirectsymoff;
@synthesize nindirectsyms = _nindirectsyms;
@synthesize extreloff = _extreloff;
@synthesize nextrel = _nextrel;
@synthesize locreloff = _locreloff;
@synthesize nlocrel = _nlocrel;

//|++++++++++++++++++++++++++++++++++++|//
+ (uint32_t)ID
{ return LC_DYSYMTAB; }

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithOffset:(mk_vm_offset_t)offset fromParent:(MKBackedNode*)parent error:(NSError**)error
{
    self = [super initWithOffset:offset fromParent:parent error:error];
    if (self == nil) return nil;
    
    struct dysymtab_command lc;
    if ([self.memoryMap copyBytesAtOffset:offset fromAddress:parent.nodeContextAddress into:&lc length:sizeof(lc) requireFull:YES error:error] < sizeof(lc))
    { [self release]; return nil; }
    
    _ilocalsym = MKSwapLValue32(lc.ilocalsym, self.macho.dataModel);
    _nlocalsym = MKSwapLValue32(lc.nlocalsym, self.macho.dataModel);
    
    _iextdefsym = MKSwapLValue32(lc.iextdefsym, self.macho.dataModel);
    _nextdefsym = MKSwapLValue32(lc.nextdefsym, self.macho.dataModel);
    
    _iundefsym = MKSwapLValue32(lc.iundefsym, self.macho.dataModel);
    _nundefsym = MKSwapLValue32(lc.nundefsym, self.macho.dataModel);
    
    _tocoff = MKSwapLValue32(lc.tocoff, self.macho.dataModel);
    _ntoc = MKSwapLValue32(lc.ntoc, self.macho.dataModel);
    
    _modtaboff = MKSwapLValue32(lc.modtaboff, self.macho.dataModel);
    _nmodtab = MKSwapLValue32(lc.nmodtab, self.macho.dataModel);
    
    _extrefsymoff = MKSwapLValue32(lc.extrefsymoff, self.macho.dataModel);
    _nextrefsyms = MKSwapLValue32(lc.nextrefsyms, self.macho.dataModel);
    
    _indirectsymoff = MKSwapLValue32(lc.indirectsymoff, self.macho.dataModel);
    _nindirectsyms = MKSwapLValue32(lc.nindirectsyms, self.macho.dataModel);
    
    _extreloff = MKSwapLValue32(lc.extreloff, self.macho.dataModel);
    _nextrel = MKSwapLValue32(lc.nextrel, self.macho.dataModel);
    
    _locreloff = MKSwapLValue32(lc.locreloff, self.macho.dataModel);
    _nlocrel = MKSwapLValue32(lc.nlocrel, self.macho.dataModel);
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(ilocalsym) description:@"Local Symbol Index" offset:offsetof(struct dysymtab_command, ilocalsym) size:sizeof(uint32_t)],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(nlocalsym) description:@"Number of Local Symbols" offset:offsetof(struct dysymtab_command, nlocalsym) size:sizeof(uint32_t)],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(iextdefsym) description:@"Defined External Symbol Index" offset:offsetof(struct dysymtab_command, iextdefsym) size:sizeof(uint32_t)],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(nextdefsym) description:@"Number of Defined External Symbols" offset:offsetof(struct dysymtab_command, nextdefsym) size:sizeof(uint32_t)],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(iundefsym) description:@"Undefined External Symbol Index" offset:offsetof(struct dysymtab_command, iundefsym) size:sizeof(uint32_t)],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(nundefsym) description:@"Number of Unefinedd External Symbols" offset:offsetof(struct dysymtab_command, nundefsym) size:sizeof(uint32_t)],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(tocoff) description:@"TOC Offset" offset:offsetof(struct dysymtab_command, tocoff) size:sizeof(uint32_t)],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(ntoc) description:@"TOC Entries" offset:offsetof(struct dysymtab_command, ntoc) size:sizeof(uint32_t)],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(modtaboff) description:@"Module Table Offset" offset:offsetof(struct dysymtab_command, modtaboff) size:sizeof(uint32_t)],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(nmodtab) description:@"Module Table Entries" offset:offsetof(struct dysymtab_command, nmodtab) size:sizeof(uint32_t)],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(extrefsymoff) description:@"External Symbol Table Offset" offset:offsetof(struct dysymtab_command, extrefsymoff) size:sizeof(uint32_t)],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(nextrefsyms) description:@"External Symbol Table Entries" offset:offsetof(struct dysymtab_command, nextrefsyms) size:sizeof(uint32_t)],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(indirectsymoff) description:@"Indirect Symbol Table Offset" offset:offsetof(struct dysymtab_command, indirectsymoff) size:sizeof(uint32_t)],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(nindirectsyms) description:@"Indirect Symbol Table Entries" offset:offsetof(struct dysymtab_command, nindirectsyms) size:sizeof(uint32_t)],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(extreloff) description:@"External Relocations Table Offset" offset:offsetof(struct dysymtab_command, extreloff) size:sizeof(uint32_t)],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(nextrel) description:@"External Relocations Table Entries" offset:offsetof(struct dysymtab_command, nextrel) size:sizeof(uint32_t)],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(locreloff) description:@"Local Relocations Table Offset" offset:offsetof(struct dysymtab_command, locreloff) size:sizeof(uint32_t)],
        [MKPrimativeNodeField fieldWithProperty:MK_PROPERTY(nlocrel) description:@"Local Relocations Table Entries" offset:offsetof(struct dysymtab_command, nlocrel) size:sizeof(uint32_t)],
    ]];
}

@end
