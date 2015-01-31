//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKBackedNode.m
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

#import "MKBackedNode.h"
#import "NSError+MK.h"

//----------------------------------------------------------------------------//
@implementation MKBackedNode

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithParent:(MKNode*)parent error:(NSError**)error
{
    if (parent && ![parent isKindOfClass:MKBackedNode.class]) {
        NSString *reason = [NSString stringWithFormat:@"The parent of an MKBackedNode must also be an MKBackedNode, not %@", parent.class];
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:nil];
    }
    
    return [super initWithParent:parent error:error];
}

//|++++++++++++++++++++++++++++++++++++|//
- (NSString*)debugDescription
{
    NSMutableString *retValue;
    
    retValue = [NSMutableString stringWithFormat:@"<%@ %p; address = 0x%" MK_VM_PRIxADDR "; size = %" MK_VM_PRIiSIZE ">",
                    self.class, self, self.nodeContextAddress, self.nodeSize];
    
    MKNodeDescription *layout = [self layout];
    NSArray *fields = layout.allFields;
    if (fields.count) {
        [retValue appendString:@" {\n"];
        if (self.warnings.count)
        {
            [retValue appendFormat:@"\twarnings = {\n"];
            for (NSError *warning in self.warnings) {
                if (warning.userInfo[NSUnderlyingErrorKey])
                    [retValue appendFormat:@"\t\t%@: %@ - %@\n", warning.mk_property, warning.localizedDescription, [warning.userInfo[NSUnderlyingErrorKey] localizedDescription]];
                else
                    [retValue appendFormat:@"\t\t%@: %@\n", warning.mk_property, warning.localizedDescription];
            }
            [retValue appendFormat:@"\t}\n"];
        }
        
        for (MKNodeField *field in fields) {
            [retValue appendFormat:@"\t%@ = %@\n", field.name, [[field formattedDescriptionForNode:self] stringByReplacingOccurrencesOfString:@"\n" withString:@"\n\t"]];
        }
        [retValue appendString:@"}"];
    }
    
    return retValue;
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Memory Layout
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_size_t)nodeSize
{ @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Subclasses must implement -nodeSize." userInfo:nil]; }

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_address_t)nodeContextAddress
{ return [self nodeAddress:MKNodeContextAddress]; }
//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_address_t)nodeVMAddress
{ return [self nodeAddress:MKNodeVMAddress]; }

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_address_t)nodeAddress:(MKNodeAddressType)type
{
#pragma unused (type)
    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Subclasses must implement -nodeAddress:." userInfo:nil];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Accessing the Underlying Data
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (NSData*)data
{ return [self.memoryMap dataAtOffset:0 fromAddress:self.nodeContextAddress length:self.nodeSize requireFull:YES error:NULL]; }

@end
