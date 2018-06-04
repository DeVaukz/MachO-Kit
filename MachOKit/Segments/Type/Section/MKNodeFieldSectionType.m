//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKNodeFieldSectionType.m
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

#import "MKNodeFieldSectionType.h"
#import "MKInternal.h"
#import "MKNodeDescription.h"

//----------------------------------------------------------------------------//
@implementation MKNodeFieldSectionType

static NSDictionary *s_Types = nil;
static MKEnumerationFormatter *s_Formatter = nil;

MKMakeSingletonInitializer(MKNodeFieldSectionType)

//|++++++++++++++++++++++++++++++++++++|//
+ (void)initialize
{
    if (s_Types != nil && s_Formatter != nil)
        return;
    
    s_Types = [@{
        _$((uint8_t)S_REGULAR): @"S_REGULAR",
        _$((uint8_t)S_ZEROFILL): @"S_ZEROFILL",
        _$((uint8_t)S_CSTRING_LITERALS): @"S_CSTRING_LITERALS",
        _$((uint8_t)S_4BYTE_LITERALS): @"S_4BYTE_LITERALS",
        _$((uint8_t)S_8BYTE_LITERALS): @"S_8BYTE_LITERALS",
        _$((uint8_t)S_LITERAL_POINTERS): @"S_LITERAL_POINTERS",
        _$((uint8_t)S_NON_LAZY_SYMBOL_POINTERS): @"S_NON_LAZY_SYMBOL_POINTERS",
        _$((uint8_t)S_LAZY_SYMBOL_POINTERS): @"S_LAZY_SYMBOL_POINTERS",
        _$((uint8_t)S_SYMBOL_STUBS): @"S_SYMBOL_STUBS",
        _$((uint8_t)S_MOD_INIT_FUNC_POINTERS): @"S_MOD_INIT_FUNC_POINTERS",
        _$((uint8_t)S_MOD_TERM_FUNC_POINTERS): @"S_MOD_TERM_FUNC_POINTERS",
        _$((uint8_t)S_COALESCED): @"S_COALESCED",
        _$((uint8_t)S_GB_ZEROFILL): @"S_GB_ZEROFILL",
        _$((uint8_t)S_INTERPOSING): @"S_INTERPOSING",
        _$((uint8_t)S_16BYTE_LITERALS): @"S_16BYTE_LITERALS",
        _$((uint8_t)S_DTRACE_DOF): @"S_DTRACE_DOF",
        _$((uint8_t)S_LAZY_DYLIB_SYMBOL_POINTERS): @"S_LAZY_DYLIB_SYMBOL_POINTERS",
        _$((uint8_t)S_THREAD_LOCAL_REGULAR): @"S_THREAD_LOCAL_REGULAR",
        _$((uint8_t)S_THREAD_LOCAL_ZEROFILL): @"S_THREAD_LOCAL_ZEROFILL",
        _$((uint8_t)S_THREAD_LOCAL_VARIABLES): @"S_THREAD_LOCAL_VARIABLES",
        _$((uint8_t)S_THREAD_LOCAL_VARIABLE_POINTERS): @"S_THREAD_LOCAL_VARIABLE_POINTERS",
        _$((uint8_t)S_THREAD_LOCAL_INIT_FUNCTION_POINTERS): @"S_THREAD_LOCAL_INIT_FUNCTION_POINTERS"
    } retain];
    
    MKEnumerationFormatter *formatter = [MKEnumerationFormatter new];
    formatter.name = @"SECTION_TYPE";
    formatter.elements = s_Types;
    formatter.fallbackFormatter = NSFormatter.mk_decimalNumberFormatter;
    s_Formatter = formatter;
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  MKNodeFieldEnumerationType
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeFieldEnumerationElements*)elements
{ return s_Types; }

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  MKNodeFieldType
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (NSString*)name
{ return @"Section Type"; }

//|++++++++++++++++++++++++++++++++++++|//
- (NSFormatter*)formatter
{ return s_Formatter; }

@end
