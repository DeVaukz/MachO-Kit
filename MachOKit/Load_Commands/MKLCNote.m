//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKLCNote.m
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

#import "MKLCNote.h"
#import "MKInternal.h"
#import "MKMachO.h"

//----------------------------------------------------------------------------//
@implementation MKLCNote

@synthesize data_owner = _data_owner;
@synthesize offset = _offset;
@synthesize size = _size;

//|++++++++++++++++++++++++++++++++++++|//
+ (uint32_t)ID
{ return LC_NOTE; }

//|++++++++++++++++++++++++++++++++++++|//
+ (uint32_t)canInstantiateWithLoadCommandID:(uint32_t)commandID
{
    if (self != MKLCNote.class)
        return 0;
    
    return commandID == [self ID] ? 10 : 0;
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithOffset:(mk_vm_offset_t)offset fromParent:(MKBackedNode*)parent error:(NSError**)error
{
    self = [super initWithOffset:offset fromParent:parent error:error];
    if (self == nil) return nil;
    
    struct note_command lc;
    if ([self.memoryMap copyBytesAtOffset:offset fromAddress:parent.nodeContextAddress into:&lc length:sizeof(lc) requireFull:YES error:error] < sizeof(lc))
    { [self release]; return nil; }
    
    _offset = MKSwapLValue64(lc.offset, self.macho.dataModel);
    _size = MKSwapLValue64(lc.size, self.macho.dataModel);
    
    // Load data_owner
    {
        const char *bytes = lc.data_owner;
        NSUInteger length = strnlen(bytes, sizeof(lc.data_owner));
        
        _data_owner = [[NSString alloc] initWithBytes:bytes length:length encoding:NSUTF8StringEncoding];
        
        if (_data_owner == nil)
            MK_PUSH_WARNING(data_owner, MK_EINVALID_DATA, @"Could not form a string with data.");
        else if (length >= sizeof(lc.data_owner))
            MK_PUSH_WARNING(data_owner, MK_EINVALID_DATA, @"String is not properly terminated.");
    }
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (void)dealloc
{
    [_data_owner release];
    
    [super dealloc];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    __unused struct note_command lc;
    
    MKNodeFieldBuilder *data_owner = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(data_owner)
        type:nil /* TODO ? */
        offset:offsetof(typeof(lc), data_owner)
        size:sizeof(lc.data_owner)
    ];
    data_owner.description = @"Data Owner";
    data_owner.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *offset = [MKNodeFieldBuilder
         builderWithProperty:MK_PROPERTY(offset)
         type:MKNodeFieldTypeUnsignedDoubleWord.sharedInstance
         offset:offsetof(typeof(lc), offset)
         size:sizeof(lc.offset)
    ];
    offset.description = @"File Offset";
    offset.options = MKNodeFieldOptionDisplayAsDetail;
    
    MKNodeFieldBuilder *size = [MKNodeFieldBuilder
         builderWithProperty:MK_PROPERTY(size)
         type:MKNodeFieldTypeUnsignedDoubleWord.sharedInstance
         offset:offsetof(typeof(lc), size)
         size:sizeof(lc.size)
    ];
    size.description = @"Size";
    size.options = MKNodeFieldOptionDisplayAsDetail;
    
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        data_owner.build,
        offset.build,
        size.build
    ]];
}

@end
