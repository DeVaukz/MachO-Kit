//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKLoadCommand.m
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

#import "MKLoadCommand.h"
#import "MKInternal.h"
#import "MKMachO.h"

#import <objc/runtime.h>

extern const struct _mk_load_command_vtable* _mk_load_command_classes[];
extern const uint32_t _mk_load_command_classes_count;

//----------------------------------------------------------------------------//
@implementation MKLoadCommand

//|++++++++++++++++++++++++++++++++++++|//
+ (id*)_subclassesCache
{ static NSSet *subclasses; return &subclasses; }

//|++++++++++++++++++++++++++++++++++++|//
+ (uint32_t)canInstantiateWithLoadCommandID:(uint32_t)commandID
{
#pragma unused (commandID)
    return 0;
}

//|++++++++++++++++++++++++++++++++++++|//
+ (Class)classForCommandID:(uint32_t)commandID
{
    // If we have one or more compatible subclasses, return the best match.
    {
        Class subclass = [self bestSubclassWithRanking:^uint32_t(Class cls) {
            return [cls canInstantiateWithLoadCommandID:commandID];
        }];
        
        if (subclass != MKLoadCommand.class)
            return subclass;
    }
    
    // No existing subclass. Create a subclass.
    @synchronized (self)
    {
        static NSMutableDictionary *runtimeLCDict = nil;
        const struct _mk_load_command_vtable *libmacho_class = NULL;
        
        if (runtimeLCDict == nil)
            runtimeLCDict = [[NSMutableDictionary alloc] init];
        
        Class runtimeClass = runtimeLCDict[@(commandID)];
        if (runtimeClass)
            return runtimeClass;
        
        for (uint32_t i=0; i<_mk_load_command_classes_count; i++) {
            const struct _mk_load_command_vtable *cls = _mk_load_command_classes[i];
            // Dirty hack to avoid importing the class strcuture into this file.
            uint32_t cls_id = mk_load_command_id(&cls);
            if (cls && cls_id == commandID) {
                libmacho_class = cls;
                break;
            }
        }
        
        // Dynamically generate a subclass
        Class newClass = NULL;
        {
            NSString *className;
            const char * libmacho_class_name = libmacho_class ? mk_type_name(&libmacho_class) : NULL;
            
            if (libmacho_class && libmacho_class_name)
                className = [NSString stringWithFormat:@"MK%s", libmacho_class_name];
            else if (commandID & LC_REQ_DYLD)
                className = [NSString stringWithFormat:@"MKLC_%" PRIi32 "D", commandID & ~LC_REQ_DYLD];
            else
                className = [NSString stringWithFormat:@"MKLC_%" PRIi32 "", commandID];
            
            newClass = objc_allocateClassPair(MKLoadCommand.class, [className cStringUsingEncoding:NSASCIIStringEncoding], 0);
            if (newClass == nil)
            {
                NSString *reason = [NSString stringWithFormat:@"Failed to dynamically allocate Class %@ for unknown load command %" PRIx32 "", className, commandID];
                @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:reason userInfo:nil];
            }
            
            // Must provide an implementation for +ID
            class_addMethod(object_getClass(newClass), @selector(ID), imp_implementationWithBlock(^(Class __unused self, SEL __unused _cmd) {
                return commandID;
            }), "v@:");
            
            objc_registerClassPair(newClass);
        }
        
        runtimeLCDict[@(commandID)] = newClass;
        return newClass;
    }
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - Creating a Load Command
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)loadCommandAtOffset:(mk_vm_offset_t)offset fromParent:(MKBackedNode*)parent error:(NSError**)error
{
    NSParameterAssert(parent.memoryMap);
    uint32_t commandId;
    NSError *localError = nil;
    
    commandId = [parent.memoryMap readDoubleWordAtOffset:offset fromAddress:parent.nodeContextAddress withDataModel:parent.macho.dataModel error:&localError];
    if (localError) {
        MK_ERROR_OUT = localError;
        return nil;
    }
    
    Class commandClass = [MKLoadCommand classForCommandID:commandId];
    if (commandClass == NULL) {
        NSString *reason = [NSString stringWithFormat:@"No class for load command %" PRIi32 "", commandId];
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:reason userInfo:nil];
    }
    
    return [[[commandClass alloc] initWithOffset:offset fromParent:parent error:error] autorelease];
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithOffset:(mk_vm_offset_t)offset fromParent:(MKBackedNode*)parent error:(NSError**)error
{
    NSParameterAssert(parent.dataModel);
    
    self = [super initWithOffset:offset fromParent:parent error:error];
    if (self == nil) return nil;
    
    struct load_command lc;
    if ([self.memoryMap copyBytesAtOffset:offset fromAddress:parent.nodeContextAddress into:&lc length:sizeof(lc) requireFull:YES error:error] < sizeof(lc))
    { [self release]; return nil; }
    
    _cmdId = MKSwapLValue32(lc.cmd, self.dataModel);
    _cmdSize = MKSwapLValue32(lc.cmdsize, self.dataModel);
    
    if (![self.class isSubclassOfClass:[MKLoadCommand classForCommandID:_cmdId]]) {
        NSString *reason = [NSString stringWithFormat:@"Cannot initialize %@ with load command data for %@", NSStringFromClass(self.class), NSStringFromClass([MKLoadCommand classForCommandID:_cmdId])];
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:nil];
    }
    
    return self;
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - About This Load Command
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
+ (uint32_t)ID
{ @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"-commandID must be called on a concrete subclass of MKLoadCommand" userInfo:nil]; }

//|++++++++++++++++++++++++++++++++++++|//
+ (NSString*)name
{
    uint32_t commandID = self.ID;
    
    for (uint32_t i=0; i<_mk_load_command_classes_count; i++) {
        const struct _mk_load_command_vtable *cls = _mk_load_command_classes[i];
        // Dirty hack to avoid importing the class strcuture into this file.
        uint32_t cls_id = mk_load_command_id(&cls);
        const char * cls_name = mk_type_name(&cls);
        if (cls && cls_id == commandID && cls_name)
            return [NSString stringWithCString:cls_name encoding:NSASCIIStringEncoding];
    }
    
    return [NSString stringWithFormat:@"Unknown Load Command %" PRIi32 "", (commandID & ~LC_REQ_DYLD)];
}

//|++++++++++++++++++++++++++++++++++++|//
+ (BOOL)requiresDYLD
{ return !!(self.ID & LC_REQ_DYLD); }

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - Mach-O Load Command Values
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@synthesize cmd = _cmdId;
@synthesize cmdSize = _cmdSize;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_size_t)nodeSize
{ return _cmdSize; }

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    static NSMutableDictionary *s_loadCommandNames = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_loadCommandNames = [[NSMutableDictionary alloc] initWithCapacity:_mk_load_command_classes_count];
        
        for (uint32_t i=0; i<_mk_load_command_classes_count; i++) {
            const struct _mk_load_command_vtable *cls = _mk_load_command_classes[i];
            // Dirty hack to avoid importing the class strcuture into this file.
            uint32_t cls_id = mk_load_command_id(&cls);
            const char * cls_name = mk_type_name(&cls);
            [s_loadCommandNames setObject:@(cls_name) forKey:@(cls_id)];
        }
    });
    
    MKNodeFieldBuilder *cmd = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(cmd)
        type:[MKNodeFieldTypeEnumeration enumerationWithUnderlyingType:MKNodeFieldTypeUnsignedDoubleWord.sharedInstance name:@"LC" elements:s_loadCommandNames]
        offset:offsetof(struct load_command, cmd)
    ];
    cmd.description = @"Command";
    cmd.options = MKNodeFieldOptionDisplayAsDetail;
#ifdef TESTS
    cmd.formatter = [NSFormatter mk_hexCompactFormatter];
#endif
    
    MKNodeFieldBuilder *cmdsize = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(cmdSize)
        type:MKNodeFieldTypeUnsignedDoubleWord.sharedInstance
        offset:offsetof(struct load_command, cmdsize)
    ];
    cmdsize.description = @"Command Size";
    cmdsize.options = MKNodeFieldOptionDisplayAsDetail;
    
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        cmd.build,
        cmdsize.build
    ]];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  NSObject
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (NSString*)description
{ return self.class.name; }

@end
