//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKDSCEntriesTable.m
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

#import "MKDSCEntriesTable.h"
#import "NSError+MK.h"
#import "MKDSCSymbolsEntry.h"

//----------------------------------------------------------------------------//
@implementation MKDSCEntriesTable

@synthesize entries = _entries;

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithCount:(uint32_t)count atOffset:(mk_vm_offset_t)offset fromParent:(MKBackedNode*)parent error:(NSError**)error
{
    self = [super initWithOffset:offset fromParent:parent error:error];
    if (self == nil) return nil;
    
    // A count of 0 is valid; but we don't need to do anything else.
    if (count == 0) {
        // If we return early, 'entries' must be initialized in order to
        // fufill our non-null promise for the property.
        _entries = [[NSArray array] retain];
        
        return self;
    }
    
    // Load Entries
    @autoreleasepool
    {
        NSMutableArray<MKDSCSymbolsEntry*> *entries = [[NSMutableArray alloc] initWithCapacity:count];
        mk_vm_offset_t offset = 0;
        
        for (uint32_t i = 0; i < count; i++)
        {
            mk_error_t err;
            NSError *e = nil;
            
            MKDSCSymbolsEntry *entry = [[MKDSCSymbolsEntry alloc] initWithOffset:offset fromParent:self error:&e];
            if (entry == nil) {
                MK_PUSH_UNDERLYING_WARNING(symbols, e, @"Could not load entry at offset %" MK_VM_PRIiOFFSET ".", offset);
                break;
            }
            
            [entries addObject:entry];
            [entry release];
            
            if ((err = mk_vm_offset_add(offset, entry.nodeSize, &offset))) {
                MK_PUSH_UNDERLYING_WARNING(symbols, MK_MAKE_VM_ARITHMETIC_ERROR(err, offset, entry.nodeSize), @"Aborted entry parsing after index " PRIi32 ".", i);
                break;
            }
        }
        
        _entries = [entries copy];
        [entries release];
        
        _nodeSize = offset;
    }
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithOffset:(mk_vm_offset_t)offset fromParent:(MKBackedNode*)parent error:(NSError**)error
{ return [self initWithCount:0 atOffset:offset fromParent:parent error:error]; }

//|++++++++++++++++++++++++++++++++++++|//
- (void)dealloc
{
    [_entries release];
    
    [super dealloc];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@synthesize nodeSize = _nodeSize;

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        [MKNodeField nodeFieldWithProperty:MK_PROPERTY(entries) description:@"Entries"]
    ]];
}

@end
