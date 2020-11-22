//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKDataModel+ObjC.m
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

#import "MKDataModel+ObjC.h"
#import "MKInternal.h"

//----------------------------------------------------------------------------//
@implementation MKDataModel (ObjC)

//|++++++++++++++++++++++++++++++++++++|//
- (size_t)objcIVarOffsetSize
{ return self.longSize; }

//|++++++++++++++++++++++++++++++++++++|//
- (size_t)objcIVarOffsetAlignment
{ return self.longAlignment; }

@end




//----------------------------------------------------------------------------//
@interface MKDarwinARM64DataModel (ObjC)
@end
@implementation MKDarwinARM64DataModel (ObjC)

/* The AARCH64 architecture uses 32-bit ivar offsets.  See
 * <https://github.com/apple/swift-clang/blob/stable/lib/CodeGen/CGObjCMac.cpp#L5467> */

//|++++++++++++++++++++++++++++++++++++|//
- (size_t)objcIVarOffsetSize
{ return self.intSize; }

//|++++++++++++++++++++++++++++++++++++|//
- (size_t)objcIVarOffsetAlignment
{ return self.intAlignment; }

@end
