//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKDSCStringTable.m
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

#import "MKDSCStringTable.h"
#import "NSError+MK.h"
#import "MKCString.h"
#import "MKDSCLocalSymbols.h"
#import "MKDSCSymbolsInfo.h"

//----------------------------------------------------------------------------//
@implementation MKDSCStringTable

@synthesize strings = _strings;

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithSize:(mk_vm_size_t)size offset:(mk_vm_offset_t)offset fromParent:(MKBackedNode*)parent error:(NSError**)error
{
    self = [super initWithParent:parent error:error];
    if (self == nil) return nil;
    
    NSParameterAssert(parent.memoryMap);
    mk_error_t err;
    
    // Verify that calculating our context address will not overflow.
    if ((err = mk_vm_address_apply_offset(parent.nodeContextAddress, offset, NULL))) {
        MK_ERROR_OUT = MK_MAKE_VM_ARITHMETIC_ERROR(err, parent.nodeContextAddress, offset);
        [self release]; return nil;
    }
    
    _nodeOffset = offset;
    
    // A size of 0 is valid; but we don't need to do anything else.
    if (size == 0) {
        // If we return early, 'strings' must be initialized in order to
        // fufill our non-null promise for the property.
        _strings = [[NSDictionary dictionary] retain];
        
        return self;
    }
    
    _nodeSize = [self.memoryMap mappingSizeAtOffset:0 fromAddress:self.nodeContextAddress length:size error:error];
    // This is not an error - we may still be able to read some strings.
    if (_nodeSize < size) {
        MK_PUSH_WARNING(nodeSize, MK_EINVALID_DATA, @"Mappable memory at address 0x%" MK_VM_PRIxADDR " for %@ is less than the expected size %" MK_VM_PRIiSIZE ".", self.nodeContextAddress, NSStringFromClass(self.class), size);
    }
    
    // Read strings
    @autoreleasepool
    {
        NSMutableDictionary<NSNumber*, MKCString*> *strings = [[NSMutableDictionary alloc] init];
        mk_vm_offset_t stringTableOffset = 0;
        
        while (stringTableOffset < _nodeSize)
        {
            NSError *e = nil;
            MKCString *string = [[MKCString alloc] initWithOffset:stringTableOffset fromParent:self error:&e];
            if (string == nil) {
                MK_PUSH_UNDERLYING_WARNING(strings, e, @"Could not load CString at offset %" MK_VM_PRIiOFFSET ".", offset);
                break;
            }
            
            [strings setObject:string forKey:@(stringTableOffset)];
            [string release];
            
            // Safe.  All string nodes must be within the size of this node.
            stringTableOffset += string.nodeSize;
        }
        
        _strings = [strings copy];
        [strings release];
    }
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithParent:(MKNode*)parent error:(NSError**)error
{
    MKDSCLocalSymbols *localSymbolsRegion = (MKDSCLocalSymbols*)parent;
    NSAssert([localSymbolsRegion isKindOfClass:MKDSCLocalSymbols.class], @"Parent must be an MKDSCLocalSymbols.");
    
    return [self initWithSize:localSymbolsRegion.header.stringsSize offset:localSymbolsRegion.header.stringsOffset fromParent:localSymbolsRegion error:error];
}

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
        [MKNodeField nodeFieldWithProperty:MK_PROPERTY(strings) description:@"Strings"]
    ]];
}

@end
