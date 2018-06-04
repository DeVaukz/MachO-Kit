//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKIndirectSymbol.m
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

#import "MKIndirectSymbol.h"
#import "MKInternal.h"
#import "MKMachO.h"
#import "MKMachO+Segments.h"
#import "MKSection.h"
#import "MKSectionIndirectSymbolTableIndexing.h"
#import "MKMachO+Symbols.h"
#import "MKSymbolTable.h"
#import "MKSymbol.h"

//----------------------------------------------------------------------------//
@implementation MKIndirectSymbol

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithOffset:(mk_vm_offset_t)offset fromParent:(MKBackedNode*)parent error:(NSError **)error
{
    self = [super initWithOffset:offset fromParent:parent error:error];
    if (self == nil) return nil;
    
    // Read the index
    {
        NSError *indexError = nil;
        
        _index = [self.memoryMap readDoubleWordAtOffset:offset fromAddress:parent.nodeContextAddress withDataModel:parent.dataModel error:&indexError];
        if (indexError) {
            MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_EINTERNAL_ERROR underlyingError:indexError description:@"Could not read index."];
            [self release]; return nil;
        }
    }
    
    MKMachOImage *image = self.macho;
    
    // Lookup the symbol referenced by the index.
    while (1) {
        MKOptional<MKSymbolTable*> *symbolTable = image.symbolTable;
        if (symbolTable.value == nil) {
            NSError *error = [NSError mk_errorWithDomain:MKErrorDomain code:MK_ENOT_FOUND underlyingError:symbolTable.error description:@"Could not load the symbol table."];
            _symbol = [[MKOptional alloc] initWithError:error];
            break;
        }
        
        MKSymbol *symbol = _index < symbolTable.value.symbols.count ? symbolTable.value.symbols[_index] : nil;
        if (symbol == nil) {
            NSError *error = [NSError mk_errorWithDomain:MKErrorDomain code:MK_ENOT_FOUND description:@"Symbol table does not have an entry for index [%" PRIu32 "].", _index];
            _symbol = [[MKOptional alloc] initWithError:error];
            break;
        }
            
        _symbol = [[MKOptional alloc] initWithValue:symbol];
        break;
    }
    
    // Find the section
    {
        // First need to determine the position of this entry in the indirect
        // symbol table.
        uint32_t position = (uint32_t)offset / sizeof(uint32_t);
        
        for (MKSection<MKSectionIndirectSymbolTableIndexing> *section in image.sections.allValues) {
            if ([section conformsToProtocol:@protocol(MKSectionIndirectSymbolTableIndexing)] == NO)
                continue;
            
            NSRange sectionIndirectSymbolTableRange = section.indirectSymbolTableRange;
            if (position >= sectionIndirectSymbolTableRange.location &&
                position < sectionIndirectSymbolTableRange.location + sectionIndirectSymbolTableRange.length)
            {
                _section = [[MKOptional alloc] initWithValue:section];
                break;
            }
        }
        
        if (_section == nil)
            _section = [MKOptional new];
    }
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (void)dealloc
{
    [_section release];
    [_symbol release];
    
    [super dealloc];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Entry Information
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@synthesize symbol = _symbol;
@synthesize section = _section;
@synthesize index = _index;

//|++++++++++++++++++++++++++++++++++++|//
- (BOOL)isLocal
{ return (self.index & ~(uint32_t)INDIRECT_SYMBOL_ABS) == INDIRECT_SYMBOL_LOCAL; }

//|++++++++++++++++++++++++++++++++++++|//
- (BOOL)isAbsolute
{ return !!(self.index & (uint32_t)INDIRECT_SYMBOL_ABS); }

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_size_t)nodeSize
{ return sizeof(uint32_t); }

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    MKNodeFieldBuilder *index;
    
    if (self.isLocal || self.isAbsolute)
    {
        index = [MKNodeFieldBuilder
            builderWithProperty:MK_PROPERTY(index)
            type:[MKNodeFieldTypeOptionSet optionSetWithUnderlyingType:MKNodeFieldTypeUnsignedDoubleWord.sharedInstance name:nil options:@{
                _$((uint32_t)INDIRECT_SYMBOL_LOCAL): @"INDIRECT_SYMBOL_LOCAL",
                _$((uint32_t)INDIRECT_SYMBOL_ABS): @"INDIRECT_SYMBOL_ABS"
            }]
            offset:0
            size:sizeof(uint32_t)
        ];
        index.description = @"Symbol Index";
        index.options = MKNodeFieldOptionDisplayAsDetail;
    }
    else
    {
        index = [MKNodeFieldBuilder
            builderWithProperty:MK_PROPERTY(index)
            type:MKNodeFieldTypeUnsignedDoubleWord.sharedInstance
            offset:0
            size:sizeof(uint32_t)
        ];
        index.description = @"Symbol Index";
        index.options = MKNodeFieldOptionDisplayAsDetail;
        index.alternateFieldName = MK_PROPERTY(symbol);
    }
    
    MKNodeFieldBuilder *symbol = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(symbol)
        type:[MKNodeFieldTypeNode typeWithNodeType:MKSymbol.class]
    ];
    symbol.description = @"Symbol";
    symbol.options = MKNodeFieldOptionHidden | MKNodeFieldOptionIgnoreContainerContents | MKNodeFieldOptionHideAddressAndData;
    
    MKNodeFieldBuilder *section = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(section)
        type:[MKNodeFieldTypeNode typeWithNodeType:MKSection.class]
    ];
    section.description = @"Section";
    section.options = MKNodeFieldOptionIgnoreContainerContents | MKNodeFieldOptionHideAddressAndData;
    
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        index.build,
        symbol.build,
        section.build
    ]];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  NSObject
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (NSString*)description
{ return [NSString stringWithFormat:@"0x%" PRIu32 " -> %@", self.index, self.symbol]; }

@end
