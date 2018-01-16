//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKNodeFieldTypeByte.m
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

#import "MKNodeFieldTypeByte.h"
#import "MKInternal.h"
#import "MKNode.h"

//----------------------------------------------------------------------------//
@implementation MKNodeFieldTypeByte

MKMakeSingletonInitializer(MKNodeFieldTypeByte)

//|++++++++++++++++++++++++++++++++++++|//
- (NSString*)name
{ return @"Byte"; }

//|++++++++++++++++++++++++++++++++++++|//
- (NSFormatter*)formatter
{ return NSFormatter.mk_decimalNumberFormatter; }

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeFieldNumericTypeTraits)traitsForNode:(__unused MKNode*)input
{ return 0; }

//|++++++++++++++++++++++++++++++++++++|//
- (size_t)sizeForNode:(__unused MKNode*)input
{ return 1; }

//|++++++++++++++++++++++++++++++++++++|//
- (size_t)alignmentForNode:(__unused MKNode*)input
{ return 1; }

@end



//----------------------------------------------------------------------------//
@implementation MKNodeFieldTypeUnsignedByte

MKMakeSingletonInitializer(MKNodeFieldTypeUnsignedByte)

//|++++++++++++++++++++++++++++++++++++|//
- (NSString*)name
{ return @"Unsigned Byte"; }

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeFieldNumericTypeTraits)traitsForNode:(MKNode*)input
{ return MKNodeFieldNumericTypeTraitUnsigned | [super traitsForNode:input]; }

@end
