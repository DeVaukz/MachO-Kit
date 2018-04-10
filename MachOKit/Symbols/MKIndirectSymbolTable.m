//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKIndirectSymbolTable.m
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

#import "MKIndirectSymbolTable.h"
#import "MKInternal.h"
#import "MKMachO.h"
#import "MKLCDysymtab.h"
#import "MKIndirectSymbol.h"

//----------------------------------------------------------------------------//
@implementation MKIndirectSymbolTable

@synthesize indirectSymbols = _indirectSymbols;

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithSize:(mk_vm_size_t)size offset:(mk_vm_offset_t)offset inImage:(MKMachOImage*)image error:(NSError**)error
{
    self = [super initWithSize:size offset:offset inImage:image error:error];
    if (self == nil) return nil;
    
    // A size of 0 is valid; but we don't need to do anything else.
    // TODO - What if the address/offset is 0?  Is that an error?  Does it
    // occur in valid Mach-O images?
    if (self.nodeSize == 0) {
        // Still need to assign a value to the symbols array.
        _indirectSymbols = [@[] retain];
        return self;
    }
 
    // Load Indirect Symbols
    @autoreleasepool
    {
        NSMutableArray<MKIndirectSymbol*> *indirectSymbols = [[NSMutableArray alloc] init];
        mk_vm_offset_t offset = 0;
        
        // Cast to mk_vm_size_t is safe; nodeSize can't be larger than UINT32_MAX.
        while ((mk_vm_size_t)offset < self.nodeSize)
        {
            NSError *symbolError = nil;
            
            MKIndirectSymbol *indirectSymbol = [[MKIndirectSymbol alloc] initWithOffset:offset fromParent:self error:&symbolError];
            if (indirectSymbol == nil) {
                MK_PUSH_WARNING_WITH_ERROR(symbols, MK_EINTERNAL_ERROR, symbolError, @"Could not parse indirect symbol at offset [%" MK_VM_PRIuOFFSET "].", offset);
                break;
            }
            
            [indirectSymbols addObject:indirectSymbol];
            [indirectSymbol release];
            
            // SAFE - All indirect symbol nodes must be within the size of this node.
            offset += indirectSymbol.nodeSize;
        }
        
        _indirectSymbols = [indirectSymbols copy];
        [indirectSymbols release];
    }
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithImage:(MKMachOImage*)image error:(NSError**)error
{
    NSParameterAssert(image != nil);
    
    // Find LC_DYSYMTAB
    MKLCDysymtab *dysymtabLoadCommand = nil;
    {
        NSArray *commands = [image loadCommandsOfType:LC_DYSYMTAB];
        if (commands.count > 1)
            MK_PUSH_WARNING(nil, MK_EINVALID_DATA, @"Image contains multiple LC_DYSYMTAB load commands.  Ignoring %@.", commands.lastObject);
        
        if (commands.count == 0) {
            // TODO - Is this really an error?
            MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_ENOT_FOUND description:@"Image does not contain a LC_DYSYMTAB load command."];
            [self release]; return nil;
        }
        
        dysymtabLoadCommand = [[commands.firstObject retain] autorelease];
    }
    
    mk_vm_size_t size = sizeof(uint32_t) * dysymtabLoadCommand.nindirectsyms;
    
    return [self initWithSize:size offset:(mk_vm_offset_t)dysymtabLoadCommand.indirectsymoff inImage:image error:error];
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithParent:(MKNode*)parent error:(NSError**)error
{ return [self initWithImage:(id)parent error:error]; }

//|++++++++++++++++++++++++++++++++++++|//
- (void)dealloc
{
    [_indirectSymbols release];
    
    [super dealloc];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  MKPointer
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (MKOptional*)childNodeOccupyingVMAddress:(mk_vm_address_t)address targetClass:(Class)targetClass
{
    for (MKIndirectSymbol *indirectSymbol in self.indirectSymbols) {
        mk_vm_range_t range = mk_vm_range_make(indirectSymbol.nodeVMAddress, indirectSymbol.nodeSize);
        if (mk_vm_range_contains_address(range, 0, address) == MK_ESUCCESS) {
            MKOptional *child = [indirectSymbol childNodeOccupyingVMAddress:address targetClass:targetClass];
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
    MKNodeFieldBuilder *indirectSymbols = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(indirectSymbols)
        type:[MKNodeFieldTypeCollection typeWithCollectionType:[MKNodeFieldTypeNode typeWithNodeType:MKIndirectSymbol.class]]
    ];
    indirectSymbols.description = @"Indirect Symbols";
    indirectSymbols.options = MKNodeFieldOptionDisplayAsDetail | MKNodeFieldOptionMergeContainerContents;
    
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        indirectSymbols.build
    ]];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  NSObject
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (NSString*)description
{ return @"Indirect Symbol Table"; }

@end
