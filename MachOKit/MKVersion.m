//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKVersion.m
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

#import "MKVersion.h"

//----------------------------------------------------------------------------//
@implementation MKVersion

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithMachVersion:(uint32_t)version
{
    self = [super init];
    if (self == nil) return nil;
    
    _data = version;
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)init
{ return [self initWithMachVersion:0]; }

//|++++++++++++++++++++++++++++++++++++|//
- (uint16_t)major
{ return (_data & 0xFFFF0000) >> 16; }

//|++++++++++++++++++++++++++++++++++++|//
- (uint8_t)minor
{ return (_data & 0x0000FF00) >> 8; }

//|++++++++++++++++++++++++++++++++++++|//
- (uint8_t)patch
{ return (_data & 0x000000FF) >> 0; }

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  NSObject
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (NSString*)description
{
    if (self.major && self.minor && self.patch)
        return [NSString stringWithFormat:@"%" PRIu16 ".%" PRIu8 ".%" PRIu8 "", self.major, self.minor, self.patch];
    else
        return [NSString stringWithFormat:@"%" PRIu16 ".%" PRIu8 "", self.major, self.minor];
}

//|++++++++++++++++++++++++++++++++++++|//
- (NSString*)debugDescription
{ return [NSString stringWithFormat:@"<%@ %p; %@>", self.class, self, self.description]; }

@end
