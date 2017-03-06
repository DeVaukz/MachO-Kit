//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKRebaseInfo.m
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

#import "MKRebaseInfo.h"
#import "MKInternal.h"
#import "MKMachO.h"
#import "MKLCDyldInfo.h"
#import "MKRebaseCommand.h"
#import "MKFixup.h"

//----------------------------------------------------------------------------//
@implementation MKRebaseInfo

@synthesize commands = _commands;
@synthesize fixups = _fixups;

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithSize:(mk_vm_size_t)size offset:(mk_vm_offset_t)offset inImage:(MKMachOImage*)image error:(NSError**)error
{
    self = [super initWithSize:size offset:offset inImage:image error:error];
    if (self == nil) return nil;
    
    // An offset of zero indicates that the images does not require rebasing.
    if (offset == 0) {
        // Not an error.
        [self release]; return nil;
    }
    
    // A size of 0 is strange but valid.
    if (self.nodeSize == 0) {
        // Still need to assign a value to the commands array.
        _commands = [@[] retain];
        return self;
    }
    
    // Load Rebase Commands
    @autoreleasepool
    {
        NSMutableArray<__kindof MKRebaseCommand*> *commands = [[NSMutableArray alloc] initWithCapacity:size/3];
        mk_vm_offset_t offset = 0;
        
        while (offset < self.nodeSize)
        {
            NSError *e;
            
            MKRebaseCommand *command = [MKRebaseCommand commandAtOffset:offset fromParent:self error:&e];
            if (command == nil) {
                MK_PUSH_UNDERLYING_WARNING(commands, e, @"Could not load rebase command at offset %" MK_VM_PRIiOFFSET ".", offset);
                break;
            }
            
            [commands addObject:command];
            
            // There may be additional padding at the end of the rebase info.
            // Stop parsing once we hit a DONE opcode.
            if (command.opcode == REBASE_OPCODE_DONE)
                break;
            
            // Safe.  All command nodes must be within the size of this node.
            offset += command.nodeSize;
        }
        
        _commands = [commands copy];
        [commands release];
    }
    
    // Determine the Fixup addresses
    @autoreleasepool
    {
        NSMutableArray<MKFixup*> *fixups = [[NSMutableArray alloc] initWithCapacity:size/3];
        
        __block BOOL keepGoing = YES;
        __block NSError *e = nil;
        __block MKRebaseCommand *currentCommand = nil;
        __block uint8_t type = UINT8_MAX;
        __block unsigned segmentIndex = UINT_MAX;
        __block mk_vm_offset_t offset = MK_VM_OFFSET_INVALID;
        
        void (^doRebase)(void) = ^{
            MKFixup *fixup = [[MKFixup alloc] initWithType:type offset:offset segment:segmentIndex atCommand:currentCommand error:&e];
            
            if (fixup)
                [fixups addObject:fixup];
            else
                keepGoing = NO;
            
            [fixup release];
        };
        
        for (MKRebaseCommand *command in _commands) {
            currentCommand = command;
            keepGoing &= [command rebase:doRebase type:&type segment:&segmentIndex offset:&offset error:&e];
            
            if (keepGoing)
                continue;
            else if (e) {
                MK_PUSH_UNDERLYING_WARNING(fixups, e, @"Rebasing failed at command: %@", currentCommand);
                break;
            } else {
                MK_PUSH_WARNING(fixups, MK_EINVALID_DATA, @"Rebasing failed at command: %@", currentCommand);
                break;
            }
        }
        
        _fixups = [fixups copy];
        [fixups release];
    }
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithImage:(MKMachOImage*)image error:(NSError**)error
{
    NSParameterAssert(image);
    
    // Find LC_DYLD_INFO
    MKLCDyldInfo *dyldInfoLoadCommand = nil;
    {
        NSMutableArray *commands = [[NSMutableArray alloc] initWithCapacity:1];
        
        NSArray *dyldInfoCommands = [image loadCommandsOfType:LC_DYLD_INFO];
        if (dyldInfoCommands) [commands addObjectsFromArray:dyldInfoCommands];
        
        NSArray *dyldInfoOnlyCommands = [image loadCommandsOfType:LC_DYLD_INFO_ONLY];
        if (dyldInfoOnlyCommands) [commands addObjectsFromArray:dyldInfoOnlyCommands];
        
        if (commands.count > 1)
            MK_PUSH_WARNING(nil, MK_EINVALID_DATA, @"Image contains multiple LC_DYLD_INFO load commands.  Ignoring %@", commands.lastObject);
        
        if (commands.count == 0) {
            MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_ENOT_FOUND description:@"Image load commands does not contain LC_DYLD_INFO."];
            [self release]; return nil;
        }
        
        dyldInfoLoadCommand = [[commands.firstObject retain] autorelease];
        [commands release];
    }
    
    return [self initWithSize:dyldInfoLoadCommand.rebase_size offset:dyldInfoLoadCommand.rebase_off inImage:image error:error];
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithParent:(MKNode*)parent error:(NSError**)error
{ return [self initWithImage:parent.macho error:error]; }

//|++++++++++++++++++++++++++++++++++++|//
- (void)dealloc
{
    [_fixups release];
    [_commands release];
    
    [super dealloc];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    MKNodeFieldBuilder *commands = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(commands)
        type:[MKNodeFieldTypeCollection typeWithCollectionType:[MKNodeFieldTypeNode typeWithNodeType:MKRebaseCommand.class]]
    ];
    commands.description = @"Commands";
    commands.options = MKNodeFieldOptionDisplayAsChild | MKNodeFieldOptionDisplayCollectionContentsAsDetail;
    
    MKNodeFieldBuilder *fixups = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(fixups)
        type:[MKNodeFieldTypeCollection typeWithCollectionType:[MKNodeFieldTypeNode typeWithNodeType:MKFixup.class]]
    ];
    fixups.description = @"Fixups";
    fixups.options = MKNodeFieldOptionDisplayAsChild | MKNodeFieldOptionDisplayCollectionContentsAsDetail;
    
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        commands.build,
        fixups.build
    ]];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  NSObject
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (NSString*)description
{ return @"Rebase Info"; }

@end
