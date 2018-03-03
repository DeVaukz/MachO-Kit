//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKNodeFieldExportFlagsType.m
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

#import "MKNodeFieldExportFlagsType.h"
#import "MKInternal.h"
#import "MKNodeDescription.h"
#import "MKNodeFieldExportKindType.h"
#import "MKNodeFieldExportOptionsType.h"

//----------------------------------------------------------------------------//
@implementation MKNodeFieldExportFlagsType

static MKNodeFieldBitfieldMasks *s_Bits = nil;
static MKBitfieldFormatter *s_Formatter = nil;

MKMakeSingletonInitializer(MKNodeFieldExportFlagsType)

//|++++++++++++++++++++++++++++++++++++|//
+ (void)initialize
{
    if (s_Bits != nil)
        return;
    
    s_Bits = [[NSArray alloc] initWithObjects:
        _$((uint64_t)EXPORT_SYMBOL_FLAGS_KIND_MASK),
        _$(~(uint64_t)EXPORT_SYMBOL_FLAGS_KIND_MASK),
    nil];
    
    MKBitfieldFormatterMask *kind = [MKBitfieldFormatterMask new];
    kind.mask = _$((uint64_t)EXPORT_SYMBOL_FLAGS_KIND_MASK);
    kind.formatter = MKNodeFieldExportKindType.sharedInstance.formatter;
    
    MKBitfieldFormatterMask *options = [MKBitfieldFormatterMask new];
    options.mask = _$(~(uint64_t)EXPORT_SYMBOL_FLAGS_KIND_MASK);
    options.formatter = MKNodeFieldExportOptionsType.sharedInstance.formatter;
    options.ignoreZero = YES;
    
    NSArray *bits = [[NSArray alloc] initWithObjects:kind, options, nil];
    
    MKBitfieldFormatter *formatter = [MKBitfieldFormatter new];
    formatter.bits = bits;
    s_Formatter = formatter;
    
    [bits release];
    [options release];
    [kind release];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  MKNodeFieldBitfieldType
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeFieldBitfieldMasks*)bits
{ return s_Bits; }

//|++++++++++++++++++++++++++++++++++++|//
- (id<MKNodeFieldNumericType>)typeForMask:(NSNumber*)mask
{
    if ([mask isEqual:_$((uint64_t)EXPORT_SYMBOL_FLAGS_KIND_MASK)])
        return MKNodeFieldExportKindType.sharedInstance;
    else
        return MKNodeFieldExportOptionsType.sharedInstance;
}

//|++++++++++++++++++++++++++++++++++++|//
- (int)shiftForMask:(__unused NSNumber*)mask
{ return 0; }

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  MKNodeFieldType
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (NSString*)name
{ return @"Terminal Node Flags"; }

//|++++++++++++++++++++++++++++++++++++|//
- (NSFormatter*)formatter
{ return s_Formatter; }

@end
