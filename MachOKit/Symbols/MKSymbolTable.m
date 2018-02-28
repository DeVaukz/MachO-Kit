//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKSymbolTable.m
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

#import "MKSymbolTable.h"
#import "MKInternal.h"
#import "MKMachO.h"
#import "MKLCSymtab.h"
#import "MKLCDysymtab.h"
#import "MKSymbol.h"

#include <mach-o/nlist.h>
#include <mach-o/stab.h>

//----------------------------------------------------------------------------//
@implementation MKSymbolTable

@synthesize symbols = _symbols;
@synthesize localSymbols = _localSymbols;
@synthesize externalSymbols = _externalSymbols;
@synthesize undefinedSymbols = _undefinedSymbols;

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithSize:(mk_vm_size_t)size offset:(mk_vm_offset_t)offset inImage:(MKMachOImage*)image error:(NSError**)error
{
    self = [super initWithSize:size offset:offset inImage:image error:error];
    if (self == nil) return nil;
    
    // Find LC_DYSYMTAB
    {
        NSArray *commands = [image loadCommandsOfType:LC_DYSYMTAB];
        if (commands.count > 1)
            MK_PUSH_WARNING(nil, MK_EINVALID_DATA, @"Image contains multiple LC_DYSYMTAB.  Ignoring %@", commands.lastObject);
        
        if (commands.count ) {
            MKLCDysymtab *dysymtabLoadCommand = commands.firstObject;
            _localSymbols = NSMakeRange(dysymtabLoadCommand.ilocalsym, dysymtabLoadCommand.nlocalsym);
            _externalSymbols = NSMakeRange(dysymtabLoadCommand.iextdefsym, dysymtabLoadCommand.nextdefsym);
            _undefinedSymbols = NSMakeRange(dysymtabLoadCommand.iundefsym, dysymtabLoadCommand.nundefsym);
        } else {
            MK_PUSH_WARNING(localSymbols, MK_ENOT_FOUND, @"Image load commands does not contain LC_DYSYMTAB.");
            MK_PUSH_WARNING(externalSymbols, MK_ENOT_FOUND, @"Image load commands does not contain LC_DYSYMTAB.");
            MK_PUSH_WARNING(undefinedSymbols, MK_ENOT_FOUND, @"Image load commands does not contain LC_DYSYMTAB.");
        }
    }
    
    // A size of 0 is valid; but we don't need to do anything else.
    // TODO - What if the address/offset is 0?  Is that an error?  Does it
    // occur in valid Mach-O images?
    if (self.nodeSize == 0) {
        // Still need to assign a value to the symbols array.
        _symbols = [@[] retain];
        return self;
    }
    
    // Load Symbols
    @autoreleasepool
    {
        NSMutableArray<__kindof MKSymbol*> *symbols = [[NSMutableArray alloc] init];
        mk_vm_offset_t offset = 0;
        
        // Cast to mk_vm_size_t is safe; nodeSize can't be larger than UINT32_MAX.
        while ((mk_vm_size_t)offset < self.nodeSize)
        {
            NSError *symbolError = nil;
            
            MKSymbol *symbol = [MKSymbol symbolAtOffset:offset fromParent:self error:&symbolError];
            if (symbol == nil) {
                MK_PUSH_WARNING_WITH_ERROR(symbols, MK_EINTERNAL_ERROR, symbolError, @"Could not parse symbol at offset [%" MK_VM_PRIuOFFSET "].", offset);
                break;
            }
            
            [symbols addObject:symbol];
            
            // SAFE - All symbol nodes must be within the size of this node.
            offset += symbol.nodeSize;
        }
        
        _symbols = [symbols copy];
        [symbols release];
    }
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithImage:(MKMachOImage*)image error:(NSError**)error
{
    NSParameterAssert(image.dataModel != nil);
    
    // Find LC_SYMTAB
    MKLCSymtab *symtabLoadCommand = nil;
    {
        NSArray *commands = [image loadCommandsOfType:LC_SYMTAB];
        if (commands.count > 1)
            MK_PUSH_WARNING(nil, MK_EINVALID_DATA, @"Image contains multiple LC_SYMTAB load commands.  Ignoring %@.", commands.lastObject);
        
        if (commands.count == 0) {
            MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_ENOT_FOUND description:@"Image does not contain a LC_SYMTAB load command."];
            [self release]; return nil;
        }
        
        symtabLoadCommand = [[commands.firstObject retain] autorelease];
    }
    
    // Determine the symbol table entry size
    size_t nlistSize;
    {
        size_t pointerSize = image.dataModel.pointerSize;
        
        switch (pointerSize) {
            case 8:
                nlistSize = sizeof(struct nlist_64);
                break;
            case 4:
                nlistSize = sizeof(struct nlist);
                break;
            default:
            {
                NSString *reason = [NSString stringWithFormat:@"Unsupported pointer size [%zu].", pointerSize];
                @throw [NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:nil];
            }
        }
    }
    
    return [self initWithSize:(symtabLoadCommand.nsyms * nlistSize) offset:(mk_vm_offset_t)symtabLoadCommand.symoff inImage:image error:error];
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithParent:(MKNode*)parent error:(NSError**)error
{ return [self initWithImage:(id)parent error:error]; }

//|++++++++++++++++++++++++++++++++++++|//
- (void)dealloc
{
    [_symbols release];
    
    [super dealloc];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  MKPointer
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (MKOptional*)childNodeOccupyingVMAddress:(mk_vm_address_t)address targetClass:(Class)targetClass
{
    for (MKSymbol *symbol in self.symbols) {
        mk_vm_range_t range = mk_vm_range_make(symbol.nodeVMAddress, symbol.nodeSize);
        if (mk_vm_range_contains_address(range, 0, address) == MK_ESUCCESS) {
            MKOptional *child = [symbol childNodeOccupyingVMAddress:address targetClass:targetClass];
            if (child.value)
                return child;
            // else, fallthrough and call the super's implementation.
            // The caller may actually be looking for *this* node.
        }
    }
    
    return [super childNodeOccupyingVMAddress:address targetClass:targetClass];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    MKNodeFieldBuilder *symbols = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(symbols)
        type:[MKNodeFieldTypeCollection typeWithCollectionType:[MKNodeFieldTypeNode typeWithNodeType:MKSymbol.class]]
    ];
    symbols.description = @"Symbols";
    symbols.options = MKNodeFieldOptionDisplayAsDetail | MKNodeFieldOptionMergeContainerContents;
    
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        symbols.build
    ]];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  NSObject
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (NSString*)description
{ return @"Symbol Table"; }

@end
