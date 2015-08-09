//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKDSCSymbolTable.m
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

#import "MKDSCSymbolTable.h"
#import "NSError+MK.h"
#import "MKDSCSymbol.h"

//----------------------------------------------------------------------------//
@implementation MKDSCSymbolTable

@synthesize symbols = _symbols;

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithCount:(uint32_t)count atOffset:(mk_vm_offset_t)offset fromParent:(MKBackedNode*)parent error:(NSError**)error
{
    self = [super initWithOffset:offset fromParent:parent error:error];
    if (self == nil) return nil;
    
    // A count of 0 is valid; but we don't need to do anything else.
    if (count == 0) {
        // If we return early, 'symbols' must be initialized in order to
        // fufill our non-null promise for the property.
        _symbols = [[NSArray array] retain];
        
        return self;
    }
    
    // Load Symbols
    @autoreleasepool
    {
        NSMutableArray<MKDSCSymbol*> *symbols = [[NSMutableArray alloc] initWithCapacity:count];
        mk_vm_offset_t offset = 0;
        
        for (uint32_t i = 0; i < count; i++)
        {
            mk_error_t err;
            NSError *e = nil;
            
            MKDSCSymbol *symbol = [[MKDSCSymbol alloc] initWithOffset:offset fromParent:self error:&e];
            if (symbol == nil) {
                MK_PUSH_UNDERLYING_WARNING(symbols, e, @"Could not load symbol at offset %" MK_VM_PRIiOFFSET ".", offset);
                break;
            }
            
            [symbols addObject:symbol];
            [symbol release];
            
            if ((err = mk_vm_offset_add(offset, symbol.nodeSize, &offset))) {
                MK_PUSH_UNDERLYING_WARNING(symbols, MK_MAKE_VM_ARITHMETIC_ERROR(err, offset, symbol.nodeSize), @"Aborted symbol parsing after index " PRIi32 ".", i);
                break;
            }
        }
        
        _symbols = [symbols copy];
        [symbols release];
        
        _nodeSize = offset;
    }
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithOffset:(mk_vm_offset_t)offset fromParent:(MKBackedNode*)parent error:(NSError**)error
{ return [self initWithCount:0 atOffset:offset fromParent:parent error:error]; }

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@synthesize nodeSize = _nodeSize;

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_address_t)nodeAddress:(MKNodeAddressType)type
{
    mk_error_t err;
    mk_vm_address_t retValue;
    
    MKNode *parent = self.parent;
    mk_vm_address_t parentAddress = [(MKBackedNode*)parent nodeAddress:type];
    
    // If there is an error here, it should have been caught during
    // initialization.
    if ((err = mk_vm_address_apply_offset(parentAddress, _nodeOffset, &retValue))) {
        NSString *reason = [NSString stringWithFormat:@"Arithmetic error %s while applying offset 0x%" MK_VM_PRIiOFFSET " of node %@ to address (type %lu) 0x%" MK_VM_PRIxADDR " of parent node %@.", mk_error_string(err), _nodeOffset, self, (unsigned long)type, parentAddress, parent];
        @throw [NSException exceptionWithName:NSRangeException reason:reason userInfo:nil];
    }
    
    return retValue;
}

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        [MKNodeField nodeFieldWithProperty:MK_PROPERTY(symbols) description:@"Symbols"]
    ]];
}

@end
