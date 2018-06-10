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
+ (uint32_t)canInstantiateWithLoadCommandID:(uint32_t)commandID
{
    if (self != MKLCDysymtab.class)
        return 0;
    
    return commandID == [self ID] ? 10 : 0;
}

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
    __unused struct dysymtab_command lc;
    
    MKNodeFieldBuilder *ilocalsym = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(ilocalsym)
        type:MKNodeFieldTypeUnsignedDoubleWord.sharedInstance
        offset:offsetof(typeof(lc), ilocalsym)
        size:sizeof(lc.ilocalsym)
    ];
    ilocalsym.description = @"Local Symbol Index";
    ilocalsym.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *nlocalsym = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(nlocalsym)
        type:MKNodeFieldTypeUnsignedDoubleWord.sharedInstance
        offset:offsetof(typeof(lc), nlocalsym)
        size:sizeof(lc.nlocalsym)
    ];
    nlocalsym.description = @"Number of Local Symbols";
    nlocalsym.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *iextdefsym = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(iextdefsym)
        type:MKNodeFieldTypeUnsignedDoubleWord.sharedInstance
        offset:offsetof(typeof(lc), iextdefsym)
        size:sizeof(lc.iextdefsym)
    ];
    iextdefsym.description = @"Defined External Symbol Index";
    iextdefsym.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *nextdefsym = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(nextdefsym)
        type:MKNodeFieldTypeUnsignedDoubleWord.sharedInstance
        offset:offsetof(typeof(lc), nextdefsym)
        size:sizeof(lc.nextdefsym)
    ];
    nextdefsym.description = @"Number of Defined External Symbols";
    nextdefsym.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *iundefsym = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(iundefsym)
        type:MKNodeFieldTypeUnsignedDoubleWord.sharedInstance
        offset:offsetof(typeof(lc), iundefsym)
        size:sizeof(lc.iundefsym)
    ];
    iundefsym.description = @"Undefined External Symbol Index";
    iundefsym.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *nundefsym = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(nundefsym)
        type:MKNodeFieldTypeUnsignedDoubleWord.sharedInstance
        offset:offsetof(typeof(lc), nundefsym)
        size:sizeof(lc.nundefsym)
    ];
    nundefsym.description = @"Number of Undefined External Symbols";
    nundefsym.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *tocoff = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(tocoff)
        type:MKNodeFieldTypeUnsignedDoubleWord.sharedInstance
        offset:offsetof(typeof(lc), tocoff)
        size:sizeof(lc.tocoff)
    ];
    tocoff.description = @"TOC Offset";
    tocoff.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *ntoc = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(ntoc)
        type:MKNodeFieldTypeUnsignedDoubleWord.sharedInstance
        offset:offsetof(typeof(lc), ntoc)
        size:sizeof(lc.ntoc)
    ];
    ntoc.description = @"TOC Entries";
    ntoc.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *modtaboff = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(modtaboff)
        type:MKNodeFieldTypeUnsignedDoubleWord.sharedInstance
        offset:offsetof(typeof(lc), modtaboff)
        size:sizeof(lc.modtaboff)
    ];
    modtaboff.description = @"Module Table Offset";
    modtaboff.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *nmodtab = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(nmodtab)
        type:MKNodeFieldTypeUnsignedDoubleWord.sharedInstance
        offset:offsetof(typeof(lc), nmodtab)
        size:sizeof(lc.nmodtab)
    ];
    nmodtab.description = @"Module Table Entries";
    nmodtab.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *extrefsymoff = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(extrefsymoff)
        type:MKNodeFieldTypeUnsignedDoubleWord.sharedInstance
        offset:offsetof(typeof(lc), extrefsymoff)
        size:sizeof(lc.extrefsymoff)
    ];
    extrefsymoff.description = @"External Symbol Table Offset";
    extrefsymoff.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *nextrefsyms = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(nextrefsyms)
        type:MKNodeFieldTypeUnsignedDoubleWord.sharedInstance
        offset:offsetof(typeof(lc), nextrefsyms)
        size:sizeof(lc.nextrefsyms)
    ];
    nextrefsyms.description = @"External Symbol Table Entries";
    nextrefsyms.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *indirectsymoff = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(indirectsymoff)
        type:MKNodeFieldTypeUnsignedDoubleWord.sharedInstance
        offset:offsetof(typeof(lc), indirectsymoff)
        size:sizeof(lc.indirectsymoff)
    ];
    indirectsymoff.description = @"Indirect Symbol Table Offset";
    indirectsymoff.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *nindirectsyms = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(nindirectsyms)
        type:MKNodeFieldTypeUnsignedDoubleWord.sharedInstance
        offset:offsetof(typeof(lc), nindirectsyms)
        size:sizeof(lc.nindirectsyms)
    ];
    nindirectsyms.description = @"Indirect Symbol Table Entries";
    nindirectsyms.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *extreloff = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(extreloff)
        type:MKNodeFieldTypeUnsignedDoubleWord.sharedInstance
        offset:offsetof(typeof(lc), extreloff)
        size:sizeof(lc.extreloff)
    ];
    extreloff.description = @"External Relocations Table Offset";
    extreloff.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *nextrel = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(nextrel)
        type:MKNodeFieldTypeUnsignedDoubleWord.sharedInstance
        offset:offsetof(typeof(lc), nextrel)
        size:sizeof(lc.nextrel)
    ];
    nextrel.description = @"External Relocations Table Entries";
    nextrel.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *locreloff = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(locreloff)
        type:MKNodeFieldTypeUnsignedDoubleWord.sharedInstance
        offset:offsetof(typeof(lc), locreloff)
        size:sizeof(lc.locreloff)
    ];
    locreloff.description = @"Local Relocations Table Offset";
    locreloff.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *nlocrel = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(nlocrel)
        type:MKNodeFieldTypeUnsignedDoubleWord.sharedInstance
        offset:offsetof(typeof(lc), nlocrel)
        size:sizeof(lc.nlocrel)
    ];
    nlocrel.description = @"Local Relocations Table Entries";
    nlocrel.options = MKNodeFieldOptionDisplayAsDetail;
    
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        ilocalsym.build,
        nlocalsym.build,
        iextdefsym.build,
        nextdefsym.build,
        iundefsym.build,
        nundefsym.build,
        tocoff.build,
        ntoc.build,
        modtaboff.build,
        nmodtab.build,
        extrefsymoff.build,
        nextrefsyms.build,
        indirectsymoff.build,
        nindirectsyms.build,
        extreloff.build,
        nextrel.build,
        locreloff.build,
        nlocrel.build,
    ]];
}

@end
