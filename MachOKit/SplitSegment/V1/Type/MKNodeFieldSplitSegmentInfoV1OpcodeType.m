//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKNodeFieldSplitSegmentInfoV1OpcodeType.m
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

#import "MKNodeFieldSplitSegmentInfoV1OpcodeType.h"
#import "MKInternal.h"
#import "MKNodeDescription.h"
#import "MKNodeFieldSplitSegmentInfoV1FixupType.h"

//----------------------------------------------------------------------------//
@implementation MKNodeFieldSplitSegmentInfoV1OpcodeType

static NSDictionary *s_Elements = nil;
static MKEnumerationFormatter *s_Formatter = nil;

MKMakeSingletonInitializer(MKNodeFieldSplitSegmentInfoV1OpcodeType)

//|++++++++++++++++++++++++++++++++++++|//
+ (void)initialize
{
    if (s_Elements != nil && s_Formatter != nil)
        return;
    
    s_Elements = [@{
        _$((uint8_t)DYLD_CACHE_ADJ_V1_POINTER_32): @"DYLD_CACHE_ADJ_V1_POINTER_32",
        _$((uint8_t)DYLD_CACHE_ADJ_V1_POINTER_64): @"DYLD_CACHE_ADJ_V1_POINTER_64",
        _$((uint8_t)DYLD_CACHE_ADJ_V1_ADRP): @"DYLD_CACHE_ADJ_V1_ADRP",
        _$((uint8_t)DYLD_CACHE_ADJ_V1_ARM_THUMB_MOVT): @"DYLD_CACHE_ADJ_V1_ARM_THUMB_MOVT",
            // 0x10 - 0x1f are ARM_THUMB_MOVT plus extra data
            _$((uint8_t)(DYLD_CACHE_ADJ_V1_ARM_THUMB_MOVT + 0x1)): @"DYLD_CACHE_ADJ_V1_ARM_THUMB_MOVT + 1",
            _$((uint8_t)(DYLD_CACHE_ADJ_V1_ARM_THUMB_MOVT + 0x2)): @"DYLD_CACHE_ADJ_V1_ARM_THUMB_MOVT + 2",
            _$((uint8_t)(DYLD_CACHE_ADJ_V1_ARM_THUMB_MOVT + 0x3)): @"DYLD_CACHE_ADJ_V1_ARM_THUMB_MOVT + 3",
            _$((uint8_t)(DYLD_CACHE_ADJ_V1_ARM_THUMB_MOVT + 0x4)): @"DYLD_CACHE_ADJ_V1_ARM_THUMB_MOVT + 4",
            _$((uint8_t)(DYLD_CACHE_ADJ_V1_ARM_THUMB_MOVT + 0x5)): @"DYLD_CACHE_ADJ_V1_ARM_THUMB_MOVT + 5",
            _$((uint8_t)(DYLD_CACHE_ADJ_V1_ARM_THUMB_MOVT + 0x6)): @"DYLD_CACHE_ADJ_V1_ARM_THUMB_MOVT + 6",
            _$((uint8_t)(DYLD_CACHE_ADJ_V1_ARM_THUMB_MOVT + 0x7)): @"DYLD_CACHE_ADJ_V1_ARM_THUMB_MOVT + 7",
            _$((uint8_t)(DYLD_CACHE_ADJ_V1_ARM_THUMB_MOVT + 0x8)): @"DYLD_CACHE_ADJ_V1_ARM_THUMB_MOVT + 8",
            _$((uint8_t)(DYLD_CACHE_ADJ_V1_ARM_THUMB_MOVT + 0x9)): @"DYLD_CACHE_ADJ_V1_ARM_THUMB_MOVT + 9",
            _$((uint8_t)(DYLD_CACHE_ADJ_V1_ARM_THUMB_MOVT + 0xa)): @"DYLD_CACHE_ADJ_V1_ARM_THUMB_MOVT + 10",
            _$((uint8_t)(DYLD_CACHE_ADJ_V1_ARM_THUMB_MOVT + 0xb)): @"DYLD_CACHE_ADJ_V1_ARM_THUMB_MOVT + 11",
            _$((uint8_t)(DYLD_CACHE_ADJ_V1_ARM_THUMB_MOVT + 0xc)): @"DYLD_CACHE_ADJ_V1_ARM_THUMB_MOVT + 12",
            _$((uint8_t)(DYLD_CACHE_ADJ_V1_ARM_THUMB_MOVT + 0xd)): @"DYLD_CACHE_ADJ_V1_ARM_THUMB_MOVT + 13",
            _$((uint8_t)(DYLD_CACHE_ADJ_V1_ARM_THUMB_MOVT + 0xe)): @"DYLD_CACHE_ADJ_V1_ARM_THUMB_MOVT + 14",
            _$((uint8_t)(DYLD_CACHE_ADJ_V1_ARM_THUMB_MOVT + 0xf)): @"DYLD_CACHE_ADJ_V1_ARM_THUMB_MOVT + 15",
        _$((uint8_t)DYLD_CACHE_ADJ_V1_ARM_MOVT): @"DYLD_CACHE_ADJ_V1_ARM_MOVT",
            // 0x20 - 0x2f are ARM_MOVT plus extra data
            _$((uint8_t)(DYLD_CACHE_ADJ_V1_ARM_MOVT + 0x1)): @"DYLD_CACHE_ADJ_V1_ARM_MOVT + 1",
            _$((uint8_t)(DYLD_CACHE_ADJ_V1_ARM_MOVT + 0x2)): @"DYLD_CACHE_ADJ_V1_ARM_MOVT + 2",
            _$((uint8_t)(DYLD_CACHE_ADJ_V1_ARM_MOVT + 0x3)): @"DYLD_CACHE_ADJ_V1_ARM_MOVT + 3",
            _$((uint8_t)(DYLD_CACHE_ADJ_V1_ARM_MOVT + 0x4)): @"DYLD_CACHE_ADJ_V1_ARM_MOVT + 4",
            _$((uint8_t)(DYLD_CACHE_ADJ_V1_ARM_MOVT + 0x5)): @"DYLD_CACHE_ADJ_V1_ARM_MOVT + 5",
            _$((uint8_t)(DYLD_CACHE_ADJ_V1_ARM_MOVT + 0x6)): @"DYLD_CACHE_ADJ_V1_ARM_MOVT + 6",
            _$((uint8_t)(DYLD_CACHE_ADJ_V1_ARM_MOVT + 0x7)): @"DYLD_CACHE_ADJ_V1_ARM_MOVT + 7",
            _$((uint8_t)(DYLD_CACHE_ADJ_V1_ARM_MOVT + 0x8)): @"DYLD_CACHE_ADJ_V1_ARM_MOVT + 8",
            _$((uint8_t)(DYLD_CACHE_ADJ_V1_ARM_MOVT + 0x9)): @"DYLD_CACHE_ADJ_V1_ARM_MOVT + 9",
            _$((uint8_t)(DYLD_CACHE_ADJ_V1_ARM_MOVT + 0xa)): @"DYLD_CACHE_ADJ_V1_ARM_MOVT + 10",
            _$((uint8_t)(DYLD_CACHE_ADJ_V1_ARM_MOVT + 0xb)): @"DYLD_CACHE_ADJ_V1_ARM_MOVT + 11",
            _$((uint8_t)(DYLD_CACHE_ADJ_V1_ARM_MOVT + 0xc)): @"DYLD_CACHE_ADJ_V1_ARM_MOVT + 12",
            _$((uint8_t)(DYLD_CACHE_ADJ_V1_ARM_MOVT + 0xd)): @"DYLD_CACHE_ADJ_V1_ARM_MOVT + 13",
            _$((uint8_t)(DYLD_CACHE_ADJ_V1_ARM_MOVT + 0xe)): @"DYLD_CACHE_ADJ_V1_ARM_MOVT + 14",
            _$((uint8_t)(DYLD_CACHE_ADJ_V1_ARM_MOVT + 0xf)): @"DYLD_CACHE_ADJ_V1_ARM_MOVT + 15",
    } retain];
    
    MKEnumerationFormatter *formatter = [MKEnumerationFormatter new];
    formatter.name = @"DYLD_CACHE_ADJ_V1";
    formatter.elements = s_Elements;
    formatter.fallbackFormatter = NSFormatter.mk_decimalNumberFormatter;
    s_Formatter = formatter;
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  MKNodeFieldEnumerationType
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeFieldEnumerationElements*)elements
{ return s_Elements; }

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  MKNodeFieldType
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (NSString*)name
{ return @"Opcode"; }

//|++++++++++++++++++++++++++++++++++++|//
- (NSFormatter*)formatter
{ return s_Formatter; }

@end
