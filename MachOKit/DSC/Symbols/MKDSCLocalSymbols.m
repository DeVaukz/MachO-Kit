//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKDSCLocalSymbols.m
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

#import "MKDSCLocalSymbols.h"
#import "NSError+MK.h"
#import "MKNode+SharedCache.h"
#import "MKSharedCache.h"
#import "MKDSCSymbolsInfo.h"
#import "MKDSCSymbolTable.h"
#import "MKDSCStringTable.h"
#import "MKDSCEntriesTable.h"

//----------------------------------------------------------------------------//
@implementation MKDSCLocalSymbols

//|++++++++++++++++++++++++++++++++++++|//
- (nullable instancetype)initWithSize:(mk_vm_size_t)size atAddress:(mk_vm_address_t)contextAddress parent:(MKNode*)parent error:(NSError**)error 
{
    self = [super initWithParent:parent error:error];
    if (self == nil) return nil;
 
    NSError *localError;
    
    _contextAddress = contextAddress;
    
    // Don't need to correct for the slide.
    _vmAddress = (self.sharedCache.isSourceFile == NO) ? _contextAddress : MK_VM_ADDRESS_INVALID;
    
    _size = [self.memoryMap mappingSizeAtOffset:0 fromAddress:contextAddress length:size];
    // This is not an error...
    if (_size < size) {
        MK_PUSH_WARNING(nodeSize, MK_EINVALID_DATA, @"Mappable memory at address %" MK_VM_PRIxADDR " for %@ is less than the expected size %" MK_VM_PRIxSIZE ".", contextAddress, NSStringFromClass(self.class), size);
    }
    
    // ...but it will be if we can't map the symbols info header.
    _header = [[MKDSCSymbolsInfo alloc] initWithOffset:0 fromParent:self error:&localError];
    if (_header == nil) {
        MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:localError.code underlyingError:localError description:@"Failed to load symbols info."];
        [self release]; return nil;
    }
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithParent:(MKNode*)parent error:(NSError**)error
{ return [self initWithSize:0 atAddress:0 parent:parent error:error]; }

//|++++++++++++++++++++++++++++++++++++|//
- (void)dealloc
{
    [_entriesTable release];
    [_stringTable release];
    [_symbolTable release];
    [_header release];
    
    [super dealloc];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@synthesize header = _header;

//|++++++++++++++++++++++++++++++++++++|//
- (MKDSCSymbolTable*)symbolTable
{
    if (_symbolTable == nil)
    @autoreleasepool {
        NSError *e = nil;
            
        _symbolTable = [[MKDSCSymbolTable alloc] initWithCount:self.header.nlistCount atOffset:self.header.nlistOffset fromParent:self error:&e];
        if (_symbolTable == nil)
            MK_PUSH_UNDERLYING_WARNING(symbolTable, e, @"Could not load symbol table.");
    }
    
    return _symbolTable;
}

//|++++++++++++++++++++++++++++++++++++|//
- (MKDSCStringTable*)stringTable
{
    if (_stringTable == nil)
    @autoreleasepool {
        NSError *e = nil;
        
        _stringTable = [[MKDSCStringTable alloc] initWithSize:self.header.stringsSize offset:self.header.stringsOffset fromParent:self error:&e];
        if (_stringTable == nil)
            MK_PUSH_UNDERLYING_WARNING(stringTable, e, @"Could not load string table.");
    }
    
    return _stringTable;
}

//|++++++++++++++++++++++++++++++++++++|//
- (MKDSCEntriesTable*)entriesTable
{
    if (_entriesTable == nil)
    @autoreleasepool {
        NSError *e = nil;
        
        _entriesTable = [[MKDSCEntriesTable alloc] initWithCount:self.header.entriesCount atOffset:self.header.entriesOffset fromParent:self error:&e];
        if (_entriesTable == nil)
            MK_PUSH_UNDERLYING_WARNING(stringTable, e, @"Could not load entries table.");
    }
    
    return _entriesTable;
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_size_t)nodeSize
{ return _size; }

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_address_t)nodeAddress:(MKNodeAddressType)type
{
    switch (type) {
        case MKNodeContextAddress:
            return _contextAddress;
        case MKNodeVMAddress:
            if (_vmAddress != MK_VM_ADDRESS_INVALID)
                return _vmAddress;
            else
                @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"VM address of local symbols is indeterminate for a  dyld_shared_cache source file." userInfo:nil];
        default:
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Unsupported node address type." userInfo:nil];
    }
}

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        [MKNodeField nodeFieldWithProperty:MK_PROPERTY(header) description:@"Header"],
        //[MKNodeField nodeFieldWithProperty:MK_PROPERTY(symbolTable) description:@"Symbol Table"],
        //[MKNodeField nodeFieldWithProperty:MK_PROPERTY(stringTable) description:@"String Table"],
        [MKNodeField nodeFieldWithProperty:MK_PROPERTY(entriesTable) description:@"Entries Table"],
    ]];
}

@end
