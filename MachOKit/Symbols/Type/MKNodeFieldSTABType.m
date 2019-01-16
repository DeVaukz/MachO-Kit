//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKNodeFieldSTABType.m
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

#import "MKInternal.h"
#import "MKNodeFieldSTABType.h"
#import "MKNodeDescription.h"

//----------------------------------------------------------------------------//
@implementation MKNodeFieldSTABType

static NSDictionary *s_Elements = nil;
static MKEnumerationFormatter *s_Formatter = nil;

MKMakeSingletonInitializer(MKNodeFieldSTABType)

//|++++++++++++++++++++++++++++++++++++|//
+ (void)initialize
{
    if (s_Elements != nil && s_Formatter != nil)
        return;
    
    s_Elements = [@{
        _$((uint8_t)N_GSYM): @"N_GSYM",
        _$((uint8_t)N_FNAME): @"N_FNAME",
        _$((uint8_t)N_FUN): @"N_FUN",
        _$((uint8_t)N_STSYM): @"N_STSYM",
        _$((uint8_t)N_LCSYM): @"N_LCSYM",
        _$((uint8_t)N_BNSYM): @"N_BNSYM",
        _$((uint8_t)N_AST): @"N_AST",
        _$((uint8_t)N_OPT): @"N_OPT",
        _$((uint8_t)N_RSYM): @"N_RSYM",
        _$((uint8_t)N_SLINE): @"N_SLINE",
        _$((uint8_t)N_ENSYM): @"N_ENSYM",
        _$((uint8_t)N_SSYM): @"N_SSYM",
        _$((uint8_t)N_SO): @"N_SO",
        _$((uint8_t)N_OSO): @"N_OSO",
        _$((uint8_t)N_LSYM): @"N_LSYM",
        _$((uint8_t)N_BINCL): @"N_BINCL",
        _$((uint8_t)N_SOL): @"N_SOL",
        _$((uint8_t)N_PARAMS): @"N_PARAMS",
        _$((uint8_t)N_VERSION): @"N_VERSION",
        _$((uint8_t)N_OLEVEL): @"N_OLEVEL",
        _$((uint8_t)N_PSYM): @"N_PSYM",
        _$((uint8_t)N_EINCL): @"N_EINCL",
        _$((uint8_t)N_ENTRY): @"N_ENTRY",
        _$((uint8_t)N_LBRAC): @"N_LBRAC",
        _$((uint8_t)N_EXCL): @"N_EXCL",
        _$((uint8_t)N_RBRAC): @"N_RBRAC",
        _$((uint8_t)N_BCOMM): @"N_BCOMM",
        _$((uint8_t)N_ECOMM): @"N_ECOMM",
        _$((uint8_t)N_ECOML): @"N_ECOML",
        _$((uint8_t)N_LENG): @"N_LENG"
    } retain];
    
    MKEnumerationFormatter *formatter = [MKEnumerationFormatter new];
    formatter.name = @"STAB Type";
    formatter.elements = s_Elements;
    formatter.fallbackFormatter = NSFormatter.mk_hexCompactFormatter;
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
{ return @"STAB Type"; }

//|++++++++++++++++++++++++++++++++++++|//
- (NSFormatter*)formatter
{ return s_Formatter; }

@end
