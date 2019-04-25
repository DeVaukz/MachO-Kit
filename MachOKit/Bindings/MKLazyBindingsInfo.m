//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKLazyBindingsInfo.m
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

#import "MKLazyBindingsInfo.h"
#import "MKInternal.h"
#import "MKMachO.h"
#import "MKLCDyldInfo.h"
#import "MKBindCommand.h"
#import "MKBindActionBind.h"

//----------------------------------------------------------------------------//
@implementation MKLazyBindingsInfo

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)_initWithDyldInfo:(MKLCDyldInfo*)dyldInfo inImage:(MKMachOImage*)image error:(NSError**)error
{ return [self initWithSize:dyldInfo.lazy_bind_size offset:dyldInfo.lazy_bind_off inImage:image error:error]; }

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Parsing
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (BOOL)_parseCommandsStopAtDone
{
    // There is a BIND_OPCODE_DONE at the end of each lazy bind; don't
    // stop until the end of the sequence.
    return NO;
}

//|++++++++++++++++++++++++++++++++++++|//
- (void)_parseActions
{
    @autoreleasepool
    {
        NSMutableArray<MKBindAction*> *actions = [[NSMutableArray alloc] initWithCapacity:(NSUInteger)self.nodeSize/3];
        
        __block BOOL keepGoing = YES;
        __block NSError *bindingError = nil;
        __block struct MKBindContext context = { 0, .type = BIND_TYPE_POINTER, .info = self };
        
        void (^doBind)(void) = ^{
            MKBindAction *action = [[MKBindActionLazyBind alloc] initWithContext:&context error:&bindingError];
            
            if (action)
                [actions addObject:action];
            else
                keepGoing = NO;
            
            // TODO - Should we reset the context?
            
            [action release];
        };
        
        for (MKBindCommand *command in _commands) {
            if (context.command == nil) {
                context.actionStartOffset = command.nodeOffset;
                context.actionSize = 0;
            }
            context.actionSize += command.nodeSize;
            context.command = command;
            
            keepGoing &= [command lazyBind:doBind withContext:&context error:&bindingError];
            
            if (keepGoing == NO) {
                if (bindingError) {
                    MK_PUSH_WARNING_WITH_ERROR(actions, MK_EINTERNAL_ERROR, bindingError, @"Lazy binding actions list generation failed at command: %@.", context.command.nodeDescription);
                }
                
                break;
            }
        }
        
        _actions = [actions copy];
        [actions release];
    }
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  NSObject
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (NSString*)description
{ return @"Lazy Binding Info"; }

@end
