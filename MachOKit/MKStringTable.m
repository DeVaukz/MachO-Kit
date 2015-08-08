//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKStringTable.m
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

#import "MKStringTable.h"
#import "NSError+MK.h"
#import "MKMachO.h"
#import "MKMachO+Segments.h"
#import "MKLCSymtab.h"
#import "MKSegment.h"
#import "MKCString.h"

//----------------------------------------------------------------------------//
@implementation MKStringTable

@synthesize strings = _strings;

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithSize:(mk_vm_size_t)size offset:(mk_vm_offset_t)offset inImage:(MKMachOImage*)image error:(NSError**)error
{
    self = [super initWithSize:size offset:offset inImage:image error:error];
    if (self == nil) return nil;
    
    // A size of 0 is valid; but we don't need to do anything else.
    // TODO - What if the address/offset is 0?  Is that an error?  Does it
    // occur in valid Mach-O images?
    if (self.nodeSize == 0)
        return self;
    
    NSMutableDictionary<NSNumber*, MKCString*> *strings = [[NSMutableDictionary alloc] init];
    
    offset = 0;
    
    // Cast to mk_vm_size_t is safe; nodeSize can't be larger than UINT32_MAX.
    while ((mk_vm_size_t)offset < self.nodeSize)
    {
        NSError *e = nil;
        MKCString *string = [[MKCString alloc] initWithOffset:offset fromParent:self error:&e];
        if (string == nil) {
            MK_PUSH_UNDERLYING_WARNING(strings, e, @"Could not load CString at offset %" MK_VM_PRIiOFFSET ".", offset);
            break;
        }
        
        [strings setObject:string forKey:@(offset)];
        [string release];
        
        // Safe.  All string nodes must be within the size of this node.
        offset += string.nodeSize;
    }
    
    _strings = [strings copy];
    [strings release];
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithImage:(MKMachOImage*)image error:(NSError**)error;
{
    NSAssert([image isKindOfClass:MKMachOImage.class], @"The parent of this node must be an MKMachOImage.");
    
    // Find LC_SYMTAB
    MKLCSymtab *symtabLoadCommand = nil;
    {
        NSArray *commands = [image loadCommandsOfType:LC_SYMTAB];
        if (commands.count > 1)
            MK_PUSH_WARNING(nil, MK_EINVALID_DATA, @"Image contains multiple LC_SYMTAB.  Ignoring %@", commands.lastObject);
        
        if (commands.count == 0) {
            MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_ENOT_FOUND description:@"Image load commands does not contain LC_SYMTAB."];
            [self release]; return nil;
        }
        
        symtabLoadCommand = commands.firstObject;
    }
    
    return [self initWithSize:symtabLoadCommand.strsize offset:symtabLoadCommand.stroff inImage:image error:error];
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithParent:(MKNode*)parent error:(NSError**)error
{ return [self initWithImage:(id)parent error:error]; }

//|++++++++++++++++++++++++++++++++++++|//
- (void)dealloc
{
    [_strings release];
    [super dealloc];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        [MKNodeField nodeFieldWithProperty:MK_PROPERTY(strings.allValues) description:@"Strings"]
    ]];
}

@end
