//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKSourceVersion.m
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

#import "MKSourceVersion.h"

//----------------------------------------------------------------------------//
@implementation MKSourceVersion

@synthesize components = _components;

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithMachVersion:(uint64_t)version
{
    self = [super init];
    if (self == nil) return nil;
    
    NSMutableArray<NSNumber*> *components = [[NSMutableArray alloc] initWithObjects:
        @( (version >> 40) & 0xFFFFFF ),
        @( (version >> 30) & 0x3FF ),
        @( (version >> 20) & 0x3FF ),
        @( (version >> 10) & 0x3FF ),
        @( (version >> 0) & 0x3FF ),
        nil
    ];
    
    // Remove all trailing zero components.
    for (NSUInteger i = components.count-1; i > 0; i--) {
        if ([components[i] integerValue] != 0)
            break;
        
        [components removeObjectAtIndex:i];
    }
    
    // If only the first component was non-zero, append a single zero
    // component to the end of the array, ensuring there are at least
    // two components.
    if (components.count < 2)
        [components addObject:@(0)];
    
    _components = [components copy];
    [components release];
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)init
{ return [self initWithMachVersion:0]; }

//|++++++++++++++++++++++++++++++++++++|//
- (void)dealloc
{
    [_components release];
    
    [super dealloc];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  NSObject
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (NSString*)description
{
    NSMutableString *description = [NSMutableString string];

    [_components enumerateObjectsUsingBlock:^(NSNumber *component, NSUInteger idx, BOOL __unused *stop) {
        if (idx == _components.count-1)
            [description appendFormat:@"%@", component];
        else
            [description appendFormat:@"%@.", component];
    }];
    
    return [[description copy] autorelease];
}

//|++++++++++++++++++++++++++++++++++++|//
- (NSString*)debugDescription
{ return [NSString stringWithFormat:@"<%@ %p; %@>", self.class, self, self.description]; }

@end
