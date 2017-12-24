//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKBindingsInfo.m
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

#import "MKBindingsInfo.h"
#import "NSError+MK.h"
#import "MKMachO.h"
#import "MKLCDyldInfo.h"
#import "MKBindCommand.h"
#import "MKBindAction.h"

//----------------------------------------------------------------------------//
@implementation MKBindingsInfo

@synthesize commands = _commands;
@synthesize actions = _actions;

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithSize:(mk_vm_size_t)size offset:(mk_vm_offset_t)offset inImage:(MKMachOImage*)image error:(NSError**)error
{
    self = [super initWithSize:size offset:offset inImage:image error:error];
    if (self == nil) return nil;
    
    // An offset of zero indicates that the images does not have any bindings.
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
    
    // Load Bind Commands
    [self _parseCommands];
    
    // Determine the Bind Actions
    [self _parseActions];
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)_initWithDyldInfo:(MKLCDyldInfo*)dyldInfo inImage:(MKMachOImage*)image error:(NSError**)error
{ return [self initWithSize:dyldInfo.bind_size offset:dyldInfo.bind_off inImage:image error:error]; }

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
    
    return [self _initWithDyldInfo:dyldInfoLoadCommand inImage:image error:error];
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithParent:(MKNode*)parent error:(NSError**)error
{ return [self initWithImage:parent.macho error:error]; }

//|++++++++++++++++++++++++++++++++++++|//
- (void)dealloc
{
    [_actions release];
    [_commands release];
    
    [super dealloc];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - Parsing
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (BOOL)_parseCommandsStopAtDone
{ return YES; }

//|++++++++++++++++++++++++++++++++++++|//
- (Class)_parseActionClass
{ return MKBindAction.class; }

//|++++++++++++++++++++++++++++++++++++|//
- (void)_parseCommands
{
    @autoreleasepool
    {
        NSMutableArray<__kindof MKBindCommand*> *commands = [[NSMutableArray alloc] initWithCapacity:self.nodeSize/8];
        mk_vm_offset_t offset = 0;
        
        while (offset < self.nodeSize)
        {
            NSError *e;
            
            MKBindCommand *command = [MKBindCommand commandAtOffset:offset fromParent:self error:&e];
            if (command == nil) {
                MK_PUSH_UNDERLYING_WARNING(commands, e, @"Could not load bind command at offset %" MK_VM_PRIiOFFSET ".", offset);
                break;
            }
            
            [commands addObject:command];
            
            // There may be additional padding at the end of the bindings info.
            // Stop parsing once we hit a DONE opcode.
            if (command.opcode == BIND_OPCODE_DONE && self._parseCommandsStopAtDone)
                break;
            
            // Safe.  All command nodes must be within the size of this node.
            offset += command.nodeSize;
        }
        
        _commands = [commands copy];
        [commands release];
    }
}

//|++++++++++++++++++++++++++++++++++++|//
- (void)_parseActions
{
    @autoreleasepool
    {
        NSMutableArray<MKBindAction*> *actions = [[NSMutableArray alloc] initWithCapacity:self.nodeSize/3];
        
        __block BOOL keepGoing = YES;
        __block NSError *e = nil;
        __block struct MKBindContext context = { 0, .info = self };
        
        void (^doBind)(void) = ^{
            MKBindAction *action = [[self._parseActionClass alloc] initWithContext:&context error:&e];
            
            if (actions)
                [actions addObject:action];
            else {
                MK_PUSH_WARNING(fixups, MK_EINVALID_DATA, @"Binding failed at command: %@", context.command);
                keepGoing = NO;
            }
            
            [action release];
        };
        
        for (MKBindCommand *command in _commands) {
            if (context.command == nil) {
                context.actionStartOffset = command.nodeOffset;
                context.actionSize = 0;
            }
            context.actionSize += command.nodeSize;
            context.command = command;
            
            keepGoing &= [command bind:doBind withContext:&context error:&e];
            
            if (keepGoing)
                continue;
            else if (e) {
                MK_PUSH_UNDERLYING_WARNING(fixups, e, @"Binding failed at command: %@", context.command);
                break;
            } else
                break;
        }
        
        _actions = [actions copy];
        [actions release];
    }
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    MKNodeFieldBuilder *commands = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(commands)
        type:[MKNodeFieldTypeCollection typeWithCollectionType:[MKNodeFieldTypeNode typeWithNodeType:MKBindCommand.class]]
    ];
    commands.description = @"Commands";
    commands.options = MKNodeFieldOptionDisplayAsChild | MKNodeFieldOptionDisplayCollectionContentsAsDetail;
    
    MKNodeFieldBuilder *actions = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(actions)
        type:[MKNodeFieldTypeCollection typeWithCollectionType:[MKNodeFieldTypeNode typeWithNodeType:MKBindAction.class]]
    ];
    actions.description = @"Actions";
    actions.options = MKNodeFieldOptionDisplayAsChild | MKNodeFieldOptionDisplayCollectionContentsAsDetail;
    
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        commands.build,
        actions.build
    ]];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  NSObject
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (NSString*)description
{ return @"Binding Info"; }

@end
