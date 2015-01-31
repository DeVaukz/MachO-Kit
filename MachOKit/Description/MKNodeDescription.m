//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKNodeDescription.m
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

#import "MKNodeDescription.h"

//----------------------------------------------------------------------------//
@implementation MKNodeDescription

@synthesize parent = _parent;

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)nodeDescriptionWithParentDescription:(MKNodeDescription*)parent fields:(NSArray*)fields
{ return [[[self alloc] initWithParentDescription:parent fields:fields] autorelease]; }

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithParentDescription:(MKNodeDescription*)parent fields:(NSArray*)fields
{
    self = [super init];
    if (self == nil) return nil;
    
    _parent = [parent retain];
    _fields = [fields retain];
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (void)dealloc
{
    [_parent release];
    [_fields release];
    [super dealloc];
}

//|++++++++++++++++++++++++++++++++++++|//
- (NSArray*)fields
{ return _fields ?: @[]; }

//|++++++++++++++++++++++++++++++++++++|//
- (NSArray*)allFields
{
    NSArray *retValue = self.fields;
    MKNodeDescription *parent = self.parent;
    
    while (parent) {
        retValue = [parent.fields arrayByAddingObjectsFromArray:retValue];
        parent = parent.parent;
    }
    
    return retValue;
}

@end
