//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKDataInCodeEntry.m
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

#import "MKDataInCodeEntry.h"
#import "MKInternal.h"
#import "MKMachO.h"

//----------------------------------------------------------------------------//
@implementation MKDataInCodeEntry

@synthesize address = _address;
@synthesize offset = _offset;
@synthesize length = _length;
@synthesize kind = _kind;

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithOffset:(mk_vm_offset_t)offset fromParent:(MKBackedNode*)parent error:(NSError**)error
{
    self = [super initWithOffset:offset fromParent:parent error:error];
    if (self == nil) return nil;
    
    // Read the data_in_code_entry structure
    {
        NSError *memoryMapError = nil;
        struct data_in_code_entry entry;
        
        if ([self.memoryMap copyBytesAtOffset:offset fromAddress:parent.nodeContextAddress into:&entry length:sizeof(entry) requireFull:YES error:&memoryMapError] < sizeof(entry)) {
            MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_EINTERNAL_ERROR underlyingError:memoryMapError description:@"Could not read data_in_code_entry."];
            [self release]; return nil;
        }
        
        _offset = MKSwapLValue32(entry.offset, self.dataModel);
        _length = MKSwapLValue16(entry.length, self.dataModel);
        _kind = MKSwapLValue16(entry.kind, self.dataModel);
    }
    
    // Compute the VM address
    {
        NSError *arithmeticError = nil;
        mk_error_t err;
        
        mk_vm_address_t machoHeaderAddress = self.macho.nodeVMAddress;
        
        if ((err = mk_vm_address_apply_offset(machoHeaderAddress, _offset, &_address))) {
            arithmeticError = MK_MAKE_VM_ADDRESS_APPLY_OFFSET_ARITHMETIC_ERROR(err, machoHeaderAddress, _offset);
            MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_EINTERNAL_ERROR underlyingError:arithmeticError description:@"Could not determine the VM address."];
            [self release]; return nil;
        }
    }
    
    return self;
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_size_t)nodeSize
{ return sizeof(struct data_in_code_entry); }

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    MKNodeFieldBuilder *offset = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(offset)
        type:MKNodeFieldTypeUnsignedDoubleWord.sharedInstance
        offset:offsetof(struct data_in_code_entry, offset)
        size:sizeof(uint32_t)
    ];
    offset.description = @"Offset";
    offset.formatter = NSFormatter.mk_hexCompactFormatter;
    offset.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *length = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(length)
        type:MKNodeFieldTypeUnsignedWord.sharedInstance
        offset:offsetof(struct data_in_code_entry, length)
        size:sizeof(uint16_t)
    ];
    length.description = @"Length";
    length.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *kind = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(kind)
        type:MKNodeFieldDataInCodeEntryType.sharedInstance
        offset:offsetof(struct data_in_code_entry, kind)
        size:sizeof(uint16_t)
    ];
    kind.description = @"Kind";
    kind.options = MKNodeFieldOptionDisplayAsDetail;
    
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        offset.build,
        length.build,
        kind.build
    ]];
}

@end
