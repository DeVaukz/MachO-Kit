//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKARMDataModel.m
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
@implementation MKARMDataModel

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithDataSource:(MKDataModel*)dataSource endianness:(MKDataEndianness)endianness;
{
    self = [self initWithDataSource:dataSource];
    
    _endianness = endianness;
    
    return self;
}

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
// TODO: Does ARM always use the full pointer width for the address?
- (uint64_t)pointerMask
{ return 0xFFFFFFFF; }

// Defer to data source for everything else.

@end



//----------------------------------------------------------------------------//
@implementation MKAARCH64DataModel

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithDataSource:(MKDataModel*)dataSource endianness:(MKDataEndianness)endianness;
{
    self = [self initWithDataSource:dataSource];
    
    _endianness = endianness;
    
    return self;
}

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
// TODO: Unclear if the AARCH64 architecture enforces a maximum VM address size.  The linux & darwin ABIs do, but they are not this class's concern.
- (uint64_t)pointerMask
{ return 0xFFFFFFFFFFFFFFFF; }

// Defer to data source for everything else.

@end
