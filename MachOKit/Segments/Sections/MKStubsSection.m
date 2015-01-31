//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKStubsSection.m
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

#import "MKStubsSection.h"
#import "NSError+MK.h"
#import "MKMachO.h"
#import "MKDataModel.h"
#import "MKSegment.h"

//----------------------------------------------------------------------------//
@implementation MKStub

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithOffset:(mk_vm_offset_t)offset fromParent:(MKStubsSection*)parent error:(NSError **)error
{
    if ([parent isKindOfClass:MKStubsSection.class] == NO)
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"The parent node of MKStubPointer must be an MKSection" userInfo:nil];
    
    self = [super initWithOffset:offset fromParent:parent error:error];
    if (self == nil) return nil;
    
    // Each stub is a jmp instruction which we do not parse in this Framework.
    
    return self;
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_size_t)nodeSize
{ return [(MKStubsSection*)self.parent stubSize]; }

@end



//----------------------------------------------------------------------------//
@implementation MKStubsSection

@synthesize stubs = _stubs;
@synthesize indirectSymbolIndex = _indirectSymbolIndex;
@synthesize stubSize = _stubSize;

//|++++++++++++++++++++++++++++++++++++|//
+ (uint32_t)canInstantiateWithSectionLoadCommand:(id<MKLCSection>)sectionLoadCommand inSegment:(MKSegment*)segment
{
#pragma unused (segment)
    
    MKSectionType type = [sectionLoadCommand flags] & SECTION_TYPE;
    return (type == MKSectionTypeSymbolStubs) ? 50 : 0;
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithLoadCommand:(id<MKLCSection>)sectionLoadCommand inSegment:(MKSegment*)segment error:(NSError**)error
{
    self = [super initWithLoadCommand:sectionLoadCommand inSegment:segment error:error];
    if (self == nil) return nil;
    
    _indirectSymbolIndex = [sectionLoadCommand reserved1];
    _stubSize = [sectionLoadCommand reserved2];
    
    // Verify that a stub size was specified in the load command.
    if (_stubSize == 0) {
        MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_EINVALID_DATA description:@"No stub size specified."];
        [self release]; return nil;
    }
    
    NSMutableArray *stubs = [[NSMutableArray alloc] init];
    
    mk_vm_offset_t offset = 0;
    
    // Cast to mk_vm_size_t is safe; nodeSize can't be larger than UINT32_MAX.
    while ((mk_vm_size_t)offset < self.nodeSize)
    {
        NSError *e = nil;
        MKStub *stub = [[MKStub alloc] initWithOffset:offset fromParent:self error:&e];
        if (stub == nil) {
            MK_PUSH_UNDERLYING_WARNING(MK_PROPERTY(pointers), e, @"Could not load stub pointer at offset %" MK_VM_PRIiOFFSET ".", offset);
            break;
        }
        
        [stubs addObject:stub];
        [stub release];
        
        // Safe.  All string nodes must be within the size of this node.
        offset += stub.nodeSize;
    }
    
    _stubs = [stubs copy];
    [stubs release];
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (void)dealloc
{
    [_stubs release];
    [super dealloc];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        [MKNodeField nodeFieldWithProperty:MK_PROPERTY(stubs) description:@"Stubs"]
    ]];
}

@end
