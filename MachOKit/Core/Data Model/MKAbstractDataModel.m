//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKAbstractDataModel.m
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

#import "MKDataModel.h"
#import "MKInternal.h"

//----------------------------------------------------------------------------//
@implementation MKDataModel

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithDataSource:(MKDataModel*)dataSource
{
    NSParameterAssert(dataSource != nil);
    
    self = [super init];
    
    if (dataSource == self) {
        _dataSource = dataSource; // do not retain
    } else {
        _dataSource = [dataSource retain];
    }
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

//|++++++++++++++++++++++++++++++++++++|//
- (void)dealloc
{
    if (_dataSource != self)
        [_dataSource release];
    
    [super dealloc];
}

#define MAKE_GETTER_FORWARDER(return_type, name) \
- (return_type)name \
{ \
    if (_dataSource == nil || _dataSource == self) \
        [self doesNotRecognizeSelector:_cmd]; \
    return [_dataSource name]; \
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Byte Order
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

MAKE_GETTER_FORWARDER(MKDataEndianness, endianness)

//|++++++++++++++++++++++++++++++++++++|//
- (const mk_byteorder_t *)byteOrder
{
    MKDataEndianness endianness = self.endianness;
    
    switch (endianness) {
        case MKDataEndiannessBig:
#if TARGET_RT_BIG_ENDIAN
            return &mk_byteorder_direct;
#else
            return &mk_byteorder_swapped;
#endif
        case MKDataEndiannessLittle:
#if TARGET_RT_BIG_ENDIAN
            return &mk_byteorder_swapped;
#else
            return &mk_byteorder_direct;
#endif
        default:
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Unknown endianness." userInfo:nil];
    }
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Pointers
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

MAKE_GETTER_FORWARDER(size_t, pointerSize)
MAKE_GETTER_FORWARDER(size_t, pointerAlignment)
MAKE_GETTER_FORWARDER(uint64_t, pointerMask)

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Fundamental (C) Types
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

MAKE_GETTER_FORWARDER(size_t, shortSize)
MAKE_GETTER_FORWARDER(size_t, shortAlignment)
MAKE_GETTER_FORWARDER(size_t, intSize)
MAKE_GETTER_FORWARDER(size_t, intAlignment)
MAKE_GETTER_FORWARDER(size_t, longSize)
MAKE_GETTER_FORWARDER(size_t, longAlignment)
MAKE_GETTER_FORWARDER(size_t, longlongSize)
MAKE_GETTER_FORWARDER(size_t, longlongAlignment)

@end
