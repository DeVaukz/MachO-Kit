//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKDSCDylibInfos.m
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

#import "MKDSCDylibInfos.h"
#import "NSError+MK.h"
#import "MKDSCLocalSymbols.h"
#import "MKDSCLocalSymbolsHeader.h"
#import "MKDSCDylibSymbolInfo.h"

#include "dyld_cache_format.h"

//----------------------------------------------------------------------------//
@implementation MKDSCDylibInfos

@synthesize entries = _entries;

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithCount:(uint32_t)count atOffset:(mk_vm_offset_t)offset fromParent:(MKBackedNode*)parent error:(NSError**)error
{
    self = [super initWithOffset:offset fromParent:parent error:error];
    if (self == nil) return nil;
    
    // A count of 0 is valid; but we don't need to do anything else.
    if (count == 0) {
        // If we return early, 'entries' must be initialized in order to
        // fufill our non-null promise for the property.
        _entries = [[NSArray array] retain];
        
        return self;
    }
    
    // Load Entries
    @autoreleasepool
    {
        NSMutableArray<MKDSCDylibSymbolInfo*> *entries = [[NSMutableArray alloc] initWithCapacity:count];
        mk_vm_offset_t offset = 0;
        
        for (uint32_t i = 0; i < count; i++)
        {
            mk_error_t err;
            NSError *e = nil;
            
            MKDSCDylibSymbolInfo *entry = [[MKDSCDylibSymbolInfo alloc] initWithOffset:offset fromParent:self error:&e];
            if (entry == nil) {
                MK_PUSH_UNDERLYING_WARNING(entries, e, @"Could not load entry at offset %" MK_VM_PRIiOFFSET ".", offset);
                break;
            }
            
            [entries addObject:entry];
            [entry release];
            
            if ((err = mk_vm_offset_add(offset, entry.nodeSize, &offset))) {
                MK_PUSH_UNDERLYING_WARNING(entries, MK_MAKE_VM_OFFSET_ADD_ARITHMETIC_ERROR(err, offset, entry.nodeSize), @"Aborted entry parsing after index " PRIi32 ".", i);
                break;
            }
        }
        
        _entries = [entries copy];
        [entries release];
        
        _nodeSize = offset;
    }
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithOffset:(mk_vm_offset_t)offset fromParent:(MKBackedNode*)parent error:(NSError**)error
{
    MKDSCLocalSymbols *symbols = [parent nearestAncestorOfType:MKDSCLocalSymbols.class];
    NSParameterAssert(symbols);
    
    MKDSCLocalSymbolsHeader *symbolsInfo = symbols.header;
    NSParameterAssert(symbolsInfo);
    
    mk_vm_offset_t entiresOffset = symbolsInfo.stringsOffset;
    uint32_t entriesCount = symbolsInfo.entriesCount;
    
    // Verify that offset is in range of the entries table.
    if (offset < entiresOffset || offset > entiresOffset + entriesCount * sizeof(struct dyld_cache_local_symbols_entry)) {
        MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_EOUT_OF_RANGE description:@"Offset (%" MK_VM_PRIiOFFSET ") not in range of the entries table for %@.", offset, symbols];
        [self release]; return nil;
    }
    
    return [self initWithCount:entriesCount atOffset:entiresOffset fromParent:symbols error:error];
    
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithParent:(MKNode*)parent error:(NSError**)error
{
    MKDSCLocalSymbols *symbols = [parent nearestAncestorOfType:MKDSCLocalSymbols.class];
    NSParameterAssert(symbols);
    
    MKDSCLocalSymbolsHeader *symbolsInfo = symbols.header;
    NSParameterAssert(symbolsInfo);
    
    return [self initWithOffset:symbolsInfo.entriesOffset fromParent:symbols error:error];
}

//|++++++++++++++++++++++++++++++++++++|//
- (void)dealloc
{
    [_entries release];
    
    [super dealloc];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@synthesize nodeSize = _nodeSize;

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        [MKNodeField nodeFieldWithProperty:MK_PROPERTY(entries) description:@"Entries"]
    ]];
}

@end
