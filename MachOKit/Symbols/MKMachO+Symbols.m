//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKMachO+Symbols.m
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

#import "MKMachO+Symbols.h"
#import "MKInternal.h"

#import "MKStringTable.h"
#import "MKSymbolTable.h"
#import "MKIndirectSymbolTable.h"

//----------------------------------------------------------------------------//
@implementation MKMachOImage (Symbols)

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Symbols
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (MKOptional*)stringTable
{
    if (_stringTable == nil)
    {
        NSError *stringTableError = nil;
        
        MKStringTable *stringTable = [[MKStringTable alloc] initWithParent:self error:&stringTableError];
        if (stringTable)
            _stringTable = [[MKOptional alloc] initWithValue:stringTable];
        else if (stringTableError /* Only failed if we have an error */)
            _stringTable = [[MKOptional alloc] initWithError:stringTableError];
        else
            _stringTable = [MKOptional new];
        
        [stringTable release];
    }
    
    return _stringTable;
}

//|++++++++++++++++++++++++++++++++++++|//
- (MKOptional*)symbolTable
{
    if (_symbolTable == nil)
    {
        NSError *symbolTableError = nil;
        
        MKSymbolTable *symbolTable = [[MKSymbolTable alloc] initWithParent:self error:&symbolTableError];
        if (symbolTable)
            _symbolTable = [[MKOptional alloc] initWithValue:symbolTable];
        else if (symbolTableError /* Only failed if we have an error */)
            _symbolTable = [[MKOptional alloc] initWithError:symbolTableError];
        else
            _symbolTable = [MKOptional new];
        
        [symbolTable release];
    }
    
    return _symbolTable;
}

//|++++++++++++++++++++++++++++++++++++|//
- (MKOptional*)indirectSymbolTable
{
    if (_indirectSymbolTable == nil)
    {
        NSError *indirectSymbolTableError = nil;
        
        MKIndirectSymbolTable *indirectSymbolTable = [[MKIndirectSymbolTable alloc] initWithParent:self error:&indirectSymbolTableError];
        if (indirectSymbolTable)
            _indirectSymbolTable = [[MKOptional alloc] initWithValue:indirectSymbolTable];
        else if (indirectSymbolTableError /* Only failed if we have an error */)
            _indirectSymbolTable = [[MKOptional alloc] initWithError:indirectSymbolTableError];
        else
            _indirectSymbolTable = [MKOptional new];
        
        [indirectSymbolTable release];
    }
    
    return _indirectSymbolTable;
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
+ (MKNodeFieldBuilder*)_stringTableFieldBuilder
{
    MKNodeFieldBuilder *stringTable = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(stringTable)
        type:[MKNodeFieldTypeNode typeWithNodeType:MKStringTable.class]
    ];
    stringTable.description = @"String Table";
    stringTable.options = MKNodeFieldOptionDisplayAsChild;
    
    return stringTable;
}

//|++++++++++++++++++++++++++++++++++++|//
+ (MKNodeFieldBuilder*)_symbolTableFieldBuilder
{
    MKNodeFieldBuilder *symbolTable = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(symbolTable)
        type:[MKNodeFieldTypeNode typeWithNodeType:MKSymbolTable.class]
    ];
    symbolTable.description = @"Symbol Table";
    symbolTable.options = MKNodeFieldOptionDisplayAsChild;
    
    return symbolTable;
}

//|++++++++++++++++++++++++++++++++++++|//
+ (MKNodeFieldBuilder*)_indirectSymbolTableFieldBuilder
{
    MKNodeFieldBuilder *indirectSymbolTable = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(indirectSymbolTable)
        type:[MKNodeFieldTypeNode typeWithNodeType:MKIndirectSymbolTable.class]
    ];
    indirectSymbolTable.description = @"Dynamic Symbol Table";
    indirectSymbolTable.options = MKNodeFieldOptionDisplayAsChild;
    
    return indirectSymbolTable;
}

@end
