//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKNodeFieldRebaseOpcodeType.m
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

#import "MKNodeFieldRebaseOpcodeType.h"
#import "MKInternal.h"
#import "MKRebaseCommand.h"

//----------------------------------------------------------------------------//
@implementation MKNodeFieldRebaseOpcodeType

static NSDictionary *s_Elements = nil;
static MKEnumerationFormatter *s_Formatter = nil;

MKMakeSingletonInitializer(MKNodeFieldRebaseOpcodeType)

//|++++++++++++++++++++++++++++++++++++|//
+ (void)initialize
{
    if (s_Elements != nil && s_Formatter != nil)
        return;
    
    // TODO - Derive these from the MKRebaseCommand subclasses?
    s_Elements = [@{
        _$((uint8_t)REBASE_OPCODE_DONE): @"REBASE_OPCODE_DONE",
        _$((uint8_t)REBASE_OPCODE_SET_TYPE_IMM): @"REBASE_OPCODE_SET_TYPE_IMM",
        _$((uint8_t)REBASE_OPCODE_SET_SEGMENT_AND_OFFSET_ULEB): @"REBASE_OPCODE_SET_SEGMENT_AND_OFFSET_ULEB",
        _$((uint8_t)REBASE_OPCODE_ADD_ADDR_ULEB): @"REBASE_OPCODE_ADD_ADDR_ULEB",
        _$((uint8_t)REBASE_OPCODE_ADD_ADDR_IMM_SCALED): @"REBASE_OPCODE_ADD_ADDR_IMM_SCALED",
        _$((uint8_t)REBASE_OPCODE_DO_REBASE_IMM_TIMES): @"REBASE_OPCODE_DO_REBASE_IMM_TIMES",
        _$((uint8_t)REBASE_OPCODE_DO_REBASE_ULEB_TIMES): @"REBASE_OPCODE_DO_REBASE_ULEB_TIMES",
        _$((uint8_t)REBASE_OPCODE_DO_REBASE_ADD_ADDR_ULEB): @"REBASE_OPCODE_DO_REBASE_ADD_ADDR_ULEB",
        _$((uint8_t)REBASE_OPCODE_DO_REBASE_ULEB_TIMES_SKIPPING_ULEB): @"REBASE_OPCODE_DO_REBASE_ULEB_TIMES_SKIPPING_ULEB"
    } retain];
    
    MKEnumerationFormatter *formatter = [MKEnumerationFormatter new];
    formatter.name = @"REBASE_OPCODE";
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
{ return @"Rebase Opcode"; }

//|++++++++++++++++++++++++++++++++++++|//
- (NSFormatter*)formatter
{ return s_Formatter; }

@end
