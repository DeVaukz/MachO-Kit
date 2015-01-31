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
#import "NSError+MK.h"

#import "MKLoadCommand.h"
#import "MKLCSymtab.h"
#import "MKStringTable.h"
#import "MKSymbolTable.h"
#import "MKIndirectSymbolTable.h"

//----------------------------------------------------------------------------//
@implementation MKMachOImage (Symbols)

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - Symbols
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (MKStringTable*)stringTable
{
    if (_stringTable == nil)
    {
        NSError *localError = nil;
        
        _stringTable = [[MKStringTable alloc] initWithImage:self error:&localError];
        if (_stringTable == nil)
            MK_PUSH_UNDERLYING_WARNING(stringTable, localError, @"Failed to load string table.");
    }
    
    return _stringTable;
}

//|++++++++++++++++++++++++++++++++++++|//
- (MKSymbolTable*)symbolTable
{
    if (_symbolTable == nil)
    {
        NSError *localError = nil;
        
        _symbolTable = [[MKSymbolTable alloc] initWithImage:self error:&localError];
        if (_symbolTable == nil)
            MK_PUSH_UNDERLYING_WARNING(symbolTable, localError, @"Failed to load symbol table.");
    }
    
    return _symbolTable;
}

//|++++++++++++++++++++++++++++++++++++|//
- (MKIndirectSymbolTable*)indirectSymbolTable
{
    if (_indirectSymbolTable == nil)
    {
        NSError *localError = nil;
        
        _indirectSymbolTable = [[MKIndirectSymbolTable alloc] initWithImage:self error:&localError];
        if (_indirectSymbolTable == nil)
            MK_PUSH_UNDERLYING_WARNING(symbolTable, localError, @"Failed to load indirect symbol table.");
    }
    
    return _indirectSymbolTable;
}

@end
