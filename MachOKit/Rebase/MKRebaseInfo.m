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
    
    // An offset of zero indicates that the image does not require rebasing.
    if (offset == 0) {
        // Not an error.
        [self release]; return nil;
    }
    
    // A size of 0 is strange but valid.
    if (self.nodeSize == 0) {
        // Still need to assign a value to the commands and fixups array.
        _commands = [@[] retain];
		_fixups = [@[] retain];
        return self;
    }
    
    // Load Rebase Commands
    @autoreleasepool
    {
        NSMutableArray<__kindof MKRebaseCommand*> *commands = [[NSMutableArray alloc] initWithCapacity:(NSUInteger)size/3];
        mk_vm_offset_t offset = 0;
        
        // Cast to mk_vm_size_t is safe; nodeSize can't be larger than UINT32_MAX.
        while (offset < self.nodeSize)
        {
            NSError *rebaseCommandError = nil;
            
            MKRebaseCommand *command = [MKRebaseCommand commandAtOffset:offset fromParent:self error:&rebaseCommandError];
            if (command == nil) {
				MK_PUSH_WARNING_WITH_ERROR(commands, MK_EINTERNAL_ERROR, rebaseCommandError, @"Could not parse rebase command at offset [%" MK_VM_PRIuOFFSET "].", offset);
                break;
            }
            
            [commands addObject:command];
            
            // There may be additional padding at the end of the rebase info.
            // Stop parsing once we hit a DONE opcode.
            if (command.opcode == REBASE_OPCODE_DONE)
                break;
            
            // SAFE - All command nodes must be within the size of this node.
            offset += command.nodeSize;
        }
        
        _commands = [commands copy];
        [commands release];
    }
    
    // Determine the Fixup addresses
    @autoreleasepool
    {
        NSMutableArray<MKFixup*> *fixups = [[NSMutableArray alloc] initWithCapacity:(NSUInteger)size/3];
        
        __block BOOL keepGoing = YES;
        __block NSError *rebaseError = nil;
		// Initialize the rebase context to zero in order to match dyld's behavior.
		__block struct MKRebaseContext context = { 0, .info = self };
		
        void (^doRebase)(void) = ^{
			MKFixup *fixup = [[MKFixup alloc] initWithContext:&context error:&rebaseError];
            
            if (fixup)
                [fixups addObject:fixup];
            else
                keepGoing = NO;
            
            [fixup release];
        };
        
        for (MKRebaseCommand *command in _commands) {
			if (context.command == nil) {
				context.actionStartOffset = command.nodeOffset;
				context.actionSize = 0;
			}
			context.actionSize += command.nodeSize;
			context.command = command;
			
			keepGoing &= [command rebase:doRebase withContext:&context error:&rebaseError];
            
            if (keepGoing == NO) {
				if (rebaseError) {
					MK_PUSH_WARNING_WITH_ERROR(fixups, MK_EINTERNAL_ERROR, rebaseError, @"Fixup list generation failed at command: %@.", context.command.nodeDescription);
				}
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
    NSParameterAssert(image != nil);
    
    // Find LC_DYLD_INFO
    MKLCDyldInfo *dyldInfoLoadCommand = nil;
    {
        NSMutableArray<MKLCDyldInfo*> *commands = [[NSMutableArray alloc] initWithCapacity:1];
        
        NSArray *dyldInfoCommands = [image loadCommandsOfType:LC_DYLD_INFO];
        if (dyldInfoCommands) [commands addObjectsFromArray:dyldInfoCommands];
        
        NSArray *dyldInfoOnlyCommands = [image loadCommandsOfType:LC_DYLD_INFO_ONLY];
        if (dyldInfoOnlyCommands) [commands addObjectsFromArray:dyldInfoOnlyCommands];
        
        if (commands.count > 1)
            MK_PUSH_WARNING(nil, MK_EINVALID_DATA, @"Image contains multiple LC_DYLD_INFO load commands.  Ignoring %@.", commands.lastObject);
        
        if (commands.count == 0) {
            MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_ENOT_FOUND description:@"Image does not contain a LC_DYLD_INFO load command."];
			[commands release];
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
#pragma mark -  MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    MKNodeFieldBuilder *commands = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(commands)
        type:[MKNodeFieldTypeCollection typeWithCollectionType:[MKNodeFieldTypeNode typeWithNodeType:MKRebaseCommand.class]]
    ];
    commands.description = @"Commands";
    commands.options = MKNodeFieldOptionDisplayAsChild | MKNodeFieldOptionDisplayContainerContentsAsDetail;
    
    MKNodeFieldBuilder *fixups = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(fixups)
        type:[MKNodeFieldTypeCollection typeWithCollectionType:[MKNodeFieldTypeNode typeWithNodeType:MKFixup.class]]
    ];
    fixups.description = @"Fixups";
    fixups.options = MKNodeFieldOptionDisplayAsChild | MKNodeFieldOptionDisplayContainerContentsAsDetail;
    
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
