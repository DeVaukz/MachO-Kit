//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKDarwinDataModels.m
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
@implementation MKDarwinARM64DataModel

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)sharedDataModel
{
    static MKDarwinARM64DataModel *Shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Shared = [MKDarwinARM64DataModel new];
    });
    return Shared;
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithDataSource:(MKDataModel *)dataSource
{
    MKLP64DataModel *lp64 = [[MKLP64DataModel alloc] initWithDataSource:dataSource endianness:MKDataEndiannessLittle];
    MKAARCH64DataModel *aarch64 = [[MKAARCH64DataModel alloc] initWithDataSource:lp64 endianness:MKDataEndiannessLittle];
    
    self = [super initWithDataSource:aarch64];
    
    [aarch64 release];
    [lp64 release];
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)init
{ return [self initWithDataSource:self]; }

//|++++++++++++++++++++++++++++++++++++|//
- (MKDataEndianness)endianness
{ return MKDataEndiannessLittle; }

//|++++++++++++++++++++++++++++++++++++|//
- (uint64_t)pointerMask
{
    // MACH_VM_MAX_ADDRESS for arm64 used to be 0x0000001000000000ULL until
    // it was reduced to its current 0x0000000FC0000000ULL sometime in the
    // iOS 11 timeframe.  It does not matter here, because both values require
    // the lower 36-bits of the pointer are used to store the target address.
    return 0x0000000FFFFFFFFF;
}

@end



//----------------------------------------------------------------------------//
@implementation MKDarwinARMDataModel

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)sharedDataModel
{
    static MKDarwinARMDataModel *Shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Shared = [MKDarwinARMDataModel new];
    });
    return Shared;
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithDataSource:(MKDataModel *)dataSource
{
    MKILP32DataModel *ilp32 = [[MKILP32DataModel alloc] initWithDataSource:dataSource endianness:MKDataEndiannessLittle];
    MKARMDataModel *arm = [[MKARMDataModel alloc] initWithDataSource:ilp32 endianness:MKDataEndiannessLittle];
    
    self = [super initWithDataSource:arm];
    
    [arm release];
    [ilp32 release];
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)init
{ return [self initWithDataSource:self]; }

//|++++++++++++++++++++++++++++++++++++|//
- (uint64_t)pointerMask
{
    // MACH_VM_MAX_ADDRESS for arm is 0x80000000.  The lower 31-bits of the
    // pointer store the address.
    return 0x7FFFFFFF;
}

@end



//----------------------------------------------------------------------------//
@implementation MKDarwinIntel64DataModel

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)sharedDataModel
{
    static MKDarwinIntel64DataModel *Shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Shared = [MKDarwinIntel64DataModel new];
    });
    return Shared;
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithDataSource:(MKDataModel *)dataSource
{
    MKLP64DataModel *lp64 = [[MKLP64DataModel alloc] initWithDataSource:dataSource endianness:MKDataEndiannessLittle];
    MKAMD64DataModel *amd64 = [[MKAMD64DataModel alloc] initWithDataSource:lp64];
    
    self = [super initWithDataSource:amd64];
    
    [amd64 release];
    [lp64 release];
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)init
{ return [self initWithDataSource:self]; }

//|++++++++++++++++++++++++++++++++++++|//
- (MKDataEndianness)endianness
{ return MKDataEndiannessLittle; }

//|++++++++++++++++++++++++++++++++++++|//
- (uint64_t)pointerMask
{
    // MACH_VM_MAX_ADDRESS for x86_64 is 0x00007FFFFFE00000ULL.  The lower 47
    // bits of the pointer store the address.
    return 0x00007FFFFFFFFFFF;
}

@end



//----------------------------------------------------------------------------//
@implementation MKDarwinIntel32DataModel

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)sharedDataModel
{
    static MKDarwinIntel32DataModel *Shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Shared = [MKDarwinIntel32DataModel new];
    });
    return Shared;
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithDataSource:(MKDataModel *)dataSource
{
    MKILP32DataModel *ilp32 = [[MKILP32DataModel alloc] initWithDataSource:dataSource endianness:MKDataEndiannessLittle];
    MKX86DataModel *x86 = [[MKX86DataModel alloc] initWithDataSource:ilp32];
    
    self = [super initWithDataSource:x86];
    
    [x86 release];
    [ilp32 release];
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)init
{ return [self initWithDataSource:self]; }

@end



//----------------------------------------------------------------------------//
@implementation MKDarwinPPC32DataModel

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)sharedDataModel
{
    static MKDarwinPPC32DataModel *Shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Shared = [MKDarwinPPC32DataModel new];
    });
    return Shared;
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithDataSource:(MKDataModel *)dataSource
{
    MKILP32DataModel *lp64 = [[MKILP32DataModel alloc] initWithDataSource:dataSource endianness:MKDataEndiannessBig];
    
    self = [super initWithDataSource:lp64];
    
    [lp64 release];
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)init
{ return [self initWithDataSource:self]; }

@end
