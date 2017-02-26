//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKLibrary.m
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

#import "MKDependentLibrary.h"
#import "MKInternal.h"
#import "MKNode+MachO.h"
#import "MKMachO.h"
#import "MKDylibLoadCommand.h"

//----------------------------------------------------------------------------//
@implementation MKDependentLibrary

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithLoadCommand:(MKDylibLoadCommand*)loadCommand error:(NSError**)error;
{
    NSParameterAssert(loadCommand);
    NSAssert(loadCommand.macho, @"");
    
    self = [super initWithParent:loadCommand.macho error:error];
    if (self == nil) return nil;
    
    _loadCommand = [loadCommand retain];
    
    return self;
}


//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithParent:(MKNode*)parent error:(NSError**)error
{ return [self initWithLoadCommand:[parent nearestAncestorOfType:MKDylibLoadCommand.class] error:error]; }

//|++++++++++++++++++++++++++++++++++++|//
- (void)dealloc
{
    [_loadCommand release];
    
    [super dealloc];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - Values
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (NSString*)name
{ return _loadCommand.name.string; }

//|++++++++++++++++++++++++++++++++++++|//
- (NSDate*)timestamp
{ return _loadCommand.timestamp; }

//|++++++++++++++++++++++++++++++++++++|//
- (MKDylibVersion*)currentVersion
{ return _loadCommand.current_version; }

//|++++++++++++++++++++++++++++++++++++|//
- (MKDylibVersion*)compatibilityVersion
{ return _loadCommand.compatibility_version; }

//|++++++++++++++++++++++++++++++++++++|//
- (BOOL)required
{ return _loadCommand.cmd != LC_LOAD_WEAK_DYLIB; }

//|++++++++++++++++++++++++++++++++++++|//
- (BOOL)weak
{ return _loadCommand.cmd == LC_LOAD_WEAK_DYLIB; }

//|++++++++++++++++++++++++++++++++++++|//
- (BOOL)upward
{ return _loadCommand.cmd == LC_LOAD_UPWARD_DYLIB; }

//|++++++++++++++++++++++++++++++++++++|//
- (BOOL)rexported
{ return _loadCommand.cmd == LC_REEXPORT_DYLIB; }

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - MKBackedNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_address_t)nodeAddress:(MKNodeAddressType)type
{ return [_loadCommand nodeAddress:type]; }

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_size_t)nodeSize
{ return [_loadCommand nodeSize]; }

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        [MKNodeField nodeFieldWithProperty:MK_PROPERTY(name) description:@"Name"],
        [MKNodeField nodeFieldWithProperty:MK_PROPERTY(timestamp) description:@"Timestamp"],
        [MKNodeField nodeFieldWithProperty:MK_PROPERTY(currentVersion) description:@"Current Version"],
        [MKNodeField nodeFieldWithProperty:MK_PROPERTY(compatibilityVersion) description:@"Compatibility Version"],
        [MKNodeField nodeFieldWithProperty:MK_PROPERTY(required) description:@"Required"],
        [MKNodeField nodeFieldWithProperty:MK_PROPERTY(weak) description:@"Weak"],
        [MKNodeField nodeFieldWithProperty:MK_PROPERTY(upward) description:@"Upward"],
        [MKNodeField nodeFieldWithProperty:MK_PROPERTY(rexported) description:@"Reexported"]
    ]];
}

@end
