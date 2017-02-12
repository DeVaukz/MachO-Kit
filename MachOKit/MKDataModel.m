//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKDataModel.m
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
#include <TargetConditionals.h>

//----------------------------------------------------------------------------//
@implementation MKILP32DataModel

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)sharedDataModel
{
    static MKILP32DataModel *Shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Shared = [[MKILP32DataModel alloc] init];
    });
    return Shared;
}

//|++++++++++++++++++++++++++++++++++++|//
- (const mk_byteorder_t*)byteOrder
{
#if TARGET_RT_BIG_ENDIAN
    return &mk_byteorder_swapped;
#else
    return &mk_byteorder_direct;
#endif
}

//|++++++++++++++++++++++++++++++++++++|//
- (size_t)intSize
{ return 4; }

//|++++++++++++++++++++++++++++++++++++|//
- (size_t)intAlignment
{ return 4; }

//|++++++++++++++++++++++++++++++++++++|//
- (size_t)longSize
{ return 4; }

//|++++++++++++++++++++++++++++++++++++|//
- (size_t)longAlignment
{ return 4; }

//|++++++++++++++++++++++++++++++++++++|//
- (size_t)pointerSize
{ return 4; }

//|++++++++++++++++++++++++++++++++++++|//
- (size_t)pointerAlignment
{ return 4; }

//|++++++++++++++++++++++++++++++++++++|//
- (size_t)objcIVarOffsetSize
{ return self.longSize; }

//|++++++++++++++++++++++++++++++++++++|//
- (size_t)objcIVarOffsetAlignment
{ return self.longAlignment; }

@end



//----------------------------------------------------------------------------//
@implementation MKLP64DataModel

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)sharedDataModel
{
    static MKLP64DataModel *Shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Shared = [[MKLP64DataModel alloc] init];
    });
    return Shared;
}

//|++++++++++++++++++++++++++++++++++++|//
- (const mk_byteorder_t*)byteOrder
{
#if TARGET_RT_BIG_ENDIAN
    return &mk_byteorder_swapped;
#else
    return &mk_byteorder_direct;
#endif
}

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
- (size_t)pointerSize
{ return 8; }

//|++++++++++++++++++++++++++++++++++++|//
- (size_t)pointerAlignment
{ return 8; }

//|++++++++++++++++++++++++++++++++++++|//
- (size_t)objcIVarOffsetSize
{ return self.longSize; }

//|++++++++++++++++++++++++++++++++++++|//
- (size_t)objcIVarOffsetAlignment
{ return self.longAlignment; }

@end



//----------------------------------------------------------------------------//
@implementation MKAARCH64DataModel

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)sharedDataModel
{
    static MKAARCH64DataModel *Shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Shared = [[MKAARCH64DataModel alloc] init];
    });
    return Shared;
}

/* The AARCH64 architecutre uses 32-bit ivar offsets.  See
 * <https://github.com/apple/swift-clang/blob/stable/lib/CodeGen/CGObjCMac.cpp#L5467> */

//|++++++++++++++++++++++++++++++++++++|//
- (size_t)objcIVarOffsetSize
{ return self.intSize; }

//|++++++++++++++++++++++++++++++++++++|//
- (size_t)objcIVarOffsetAlignment
{ return self.intAlignment; }

@end



//----------------------------------------------------------------------------//
@implementation MKPPC32DataModel

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)sharedDataModel
{
    static MKPPC32DataModel *Shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Shared = [[MKPPC32DataModel alloc] init];
    });
    return Shared;
}

//|++++++++++++++++++++++++++++++++++++|//
- (const mk_byteorder_t*)byteOrder
{
#if TARGET_RT_BIG_ENDIAN
    return &mk_byteorder_direct;
#else
    return &mk_byteorder_swapped;
#endif
}

//|++++++++++++++++++++++++++++++++++++|//
- (size_t)intSize
{ return 4; }

//|++++++++++++++++++++++++++++++++++++|//
- (size_t)intAlignment
{ return 4; }

//|++++++++++++++++++++++++++++++++++++|//
- (size_t)longSize
{ return 4; }

//|++++++++++++++++++++++++++++++++++++|//
- (size_t)longAlignment
{ return 4; }

//|++++++++++++++++++++++++++++++++++++|//
- (size_t)pointerSize
{ return 4; }

//|++++++++++++++++++++++++++++++++++++|//
- (size_t)pointerAlignment
{ return 4; }

//|++++++++++++++++++++++++++++++++++++|//
- (size_t)objcIVarOffsetSize
{ return self.longSize; }

//|++++++++++++++++++++++++++++++++++++|//
- (size_t)objcIVarOffsetAlignment
{ return self.longAlignment; }

@end
