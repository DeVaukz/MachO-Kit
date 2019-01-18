//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKUStringSection.m
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

#import "MKUStringSection.h"
#import "MKInternal.h"
#import "MKSegment.h"

//----------------------------------------------------------------------------//
@implementation MKUStringSection

//|++++++++++++++++++++++++++++++++++++|//
+ (uint32_t)canInstantiateWithSectionLoadCommand:(id<MKLCSection>)sectionLoadCommand inSegment:(MKSegment*)segment
{
#pragma unused (segment)
    if (self != MKUStringSection.class)
        return 0;
    
    if ([sectionLoadCommand.segname rangeOfString:@SEG_TEXT].location == 0 &&
        [sectionLoadCommand.sectname isEqualToString:@"__ustring"])
        return 50;
    
    return 0;
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithLoadCommand:(id<MKLCSection>)sectionLoadCommand inSegment:(MKSegment*)segment error:(NSError**)error
{
    self = [super initWithLoadCommand:sectionLoadCommand inSegment:segment error:error];
    if (self == nil) return nil;
    
    // Load Strings
    {
        NSMutableArray<MKUString*> *strings = [[NSMutableArray alloc] init];
        mk_vm_offset_t offset = 0;
        
        // Cast to mk_vm_size_t is safe; nodeSize can't be larger than UINT32_MAX.
        while ((mk_vm_size_t)offset < self.nodeSize)
        {
            NSError *stringError = nil;
            
            MKUString *string = [[MKUString alloc] initWithOffset:offset fromParent:self error:&stringError];
            if (string == nil) {
                MK_PUSH_WARNING_WITH_ERROR(strings, MK_EINTERNAL_ERROR, stringError, @"Could not parse string at offset [%" MK_VM_PRIuOFFSET "].", offset);
                break;
            }
            
            [strings addObject:string];
            [string release];
            
            // SAFE - All string nodes must be within the size of this node.
            offset += string.nodeSize;
        }
        
        _strings = [strings copy];
        [strings release];
    }
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (void)dealloc
{
    [_strings release];
    
    [super dealloc];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Section Values
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@synthesize strings = _strings;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  MKPointer
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (MKOptional*)childNodeOccupyingVMAddress:(mk_vm_address_t)address targetClass:(Class)targetClass
{
    for (MKUString *string in self.strings) {
        mk_vm_range_t range = mk_vm_range_make(string.nodeVMAddress, string.nodeSize);
        if (mk_vm_range_contains_address(range, 0, address) == MK_ESUCCESS) {
            MKOptional *child = [string childNodeOccupyingVMAddress:address targetClass:targetClass];
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
    MKNodeFieldBuilder *strings = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(strings)
        type:[MKNodeFieldTypeCollection typeWithCollectionType:[MKNodeFieldTypeNode typeWithNodeType:MKUString.class]]
    ];
    strings.description = @"Strings";
    strings.options = MKNodeFieldOptionDisplayAsDetail | MKNodeFieldOptionMergeWithParent;
    
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        strings.build
    ]];
}

@end
