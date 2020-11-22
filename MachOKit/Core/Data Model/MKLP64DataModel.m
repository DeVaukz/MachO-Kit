//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKLP64DataModel.m
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
@implementation MKLP64DataModel

//|++++++++++++++++++++++++++++++++++++|//
+ (MKLP64DataModel*)dataModelWithHostEndianness
{
    static MKLP64DataModel *Shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
#if TARGET_RT_BIG_ENDIAN
        Shared = [[MKLP64DataModel alloc] initWithEndianness:MKDataEndiannessBig];
#else
        Shared = [[MKLP64DataModel alloc] initWithEndianness:MKDataEndiannessLittle];
#endif
    });
    return Shared;
}

//|++++++++++++++++++++++++++++++++++++|//
+ (MKLP64DataModel*)dataModelWithByteSwappedEndianness
{
    static MKLP64DataModel *Shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
#if TARGET_RT_BIG_ENDIAN
        Shared = [[MKLP64DataModel alloc] initWithEndianness:MKDataEndiannessLittle];
#else
        Shared = [[MKLP64DataModel alloc] initWithEndianness:MKDataEndiannessBig];
#endif
    });
    return Shared;
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithDataSource:(MKDataModel*)dataSource endianness:(MKDataEndianness)endianness;
{
    self = [self initWithDataSource:dataSource];
    
    _endianness = endianness;
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithEndianness:(MKDataEndianness)endianness
{ return [self initWithDataSource:self endianness:endianness]; }

//|++++++++++++++++++++++++++++++++++++|//
- (MKDataEndianness)endianness
{
    if (_endianness != MKDataEndiannessUnknown)
        return _endianness;
    else
        // Defer to the data source.
        return [super endianness];
}

//|++++++++++++++++++++++++++++++++++++|//
- (size_t)pointerSize
{ return 8; }

//|++++++++++++++++++++++++++++++++++++|//
- (size_t)pointerAlignment
{ return 8; }

//|++++++++++++++++++++++++++++++++++++|//
- (uint64_t)pointerMask
{ return 0xFFFFFFFFFFFFFFFF; }

//|++++++++++++++++++++++++++++++++++++|//
- (size_t)shortSize
{ return 2; }

//|++++++++++++++++++++++++++++++++++++|//
- (size_t)shortAlignment
{ return 2; }

//|++++++++++++++++++++++++++++++++++++|//
- (size_t)intSize
{ return 4; }

//|++++++++++++++++++++++++++++++++++++|//
- (size_t)intAlignment
{ return 4; }

//|++++++++++++++++++++++++++++++++++++|//
- (size_t)longSize
{ return 8; }

//|++++++++++++++++++++++++++++++++++++|//
- (size_t)longAlignment
{ return 8; }

//|++++++++++++++++++++++++++++++++++++|//
- (size_t)longlongSize
{ return 8; }

//|++++++++++++++++++++++++++++++++++++|//
- (size_t)longlongAlignment
{ return 8; }

@end
