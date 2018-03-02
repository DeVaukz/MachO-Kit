//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKNodeFieldBindOpcodeType.m
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

#import "MKNodeFieldBindOpcodeType.h"
#import "MKInternal.h"
#import "MKBindCommand.h"

//----------------------------------------------------------------------------//
@implementation MKNodeFieldBindOpcodeType

static NSDictionary *s_Elements = nil;
static MKEnumerationFormatter *s_Formatter = nil;

MKMakeSingletonInitializer(MKNodeFieldBindOpcodeType)

//|++++++++++++++++++++++++++++++++++++|//
+ (void)initialize
{
    if (s_Elements != nil && s_Formatter != nil)
        return;
    
    // TODO - Derive these from the MKBindCommand subclasses?
    s_Elements = [@{
        _$((uint8_t)BIND_OPCODE_DONE): @"BIND_OPCODE_DONE",
        _$((uint8_t)BIND_OPCODE_SET_DYLIB_ORDINAL_IMM): @"BIND_OPCODE_SET_DYLIB_ORDINAL_IMM",
        _$((uint8_t)BIND_OPCODE_SET_DYLIB_ORDINAL_ULEB): @"BIND_OPCODE_SET_DYLIB_ORDINAL_ULEB",
        _$((uint8_t)BIND_OPCODE_SET_DYLIB_SPECIAL_IMM): @"BIND_OPCODE_SET_DYLIB_SPECIAL_IMM",
        _$((uint8_t)BIND_OPCODE_SET_SYMBOL_TRAILING_FLAGS_IMM): @"BIND_OPCODE_SET_SYMBOL_TRAILING_FLAGS_IMM",
        _$((uint8_t)BIND_OPCODE_SET_TYPE_IMM): @"BIND_OPCODE_SET_TYPE_IMM",
        _$((uint8_t)BIND_OPCODE_SET_ADDEND_SLEB): @"BIND_OPCODE_SET_ADDEND_SLEB",
        _$((uint8_t)BIND_OPCODE_SET_SEGMENT_AND_OFFSET_ULEB): @"BIND_OPCODE_SET_SEGMENT_AND_OFFSET_ULEB",
        _$((uint8_t)BIND_OPCODE_ADD_ADDR_ULEB): @"BIND_OPCODE_ADD_ADDR_ULEB",
        _$((uint8_t)BIND_OPCODE_DO_BIND): @"BIND_OPCODE_DO_BIND",
        _$((uint8_t)BIND_OPCODE_DO_BIND_ADD_ADDR_ULEB): @"BIND_OPCODE_DO_BIND_ADD_ADDR_ULEB",
        _$((uint8_t)BIND_OPCODE_DO_BIND_ADD_ADDR_IMM_SCALED): @"BIND_OPCODE_DO_BIND_ADD_ADDR_IMM_SCALED",
        _$((uint8_t)BIND_OPCODE_DO_BIND_ULEB_TIMES_SKIPPING_ULEB): @"BIND_OPCODE_DO_BIND_ULEB_TIMES_SKIPPING_ULEB"
    } retain];
    
    MKEnumerationFormatter *formatter = [MKEnumerationFormatter new];
    formatter.name = @"BIND_OPCODE";
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
{ return @"Bind Opcode"; }

//|++++++++++++++++++++++++++++++++++++|//
- (NSFormatter*)formatter
{ return s_Formatter; }

@end
