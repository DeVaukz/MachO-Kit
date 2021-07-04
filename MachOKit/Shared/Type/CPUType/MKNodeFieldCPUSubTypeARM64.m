//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKNodeFieldCPUSubTypeARM64.m
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

#import "MKNodeFieldCPUSubTypeARM64.h"
#import "MKInternal.h"
#import "MKNodeDescription.h"

extern void OBJC_CLASS_$_MKNodeFieldCPUSubTypeARM64;

//----------------------------------------------------------------------------//
@implementation MKNodeFieldCPUSubTypeARM64

static NSFormatter *s_BitfieldFormatter = nil;

MKMakeSingletonInitializer(MKNodeFieldCPUSubTypeARM64)

//|++++++++++++++++++++++++++++++++++++|//
+ (void)initialize
{
    if (self != &OBJC_CLASS_$_MKNodeFieldCPUSubTypeARM64)
        return;
    
    MKBitfieldFormatterMask *subtypeMask = [MKBitfieldFormatterMask new];
    subtypeMask.mask = _$(~(uint32_t)CPU_SUBTYPE_MASK);
    subtypeMask.formatter = MKNodeFieldCPUSubTypeARM64SubType.sharedInstance.formatter;
    
    MKBitfieldFormatterMask *capabilitiesMask = [MKBitfieldFormatterMask new];
    capabilitiesMask.mask = _$((uint32_t)CPU_SUBTYPE_MASK);
    capabilitiesMask.formatter = MKNodeFieldCPUSubTypeARM64Features.sharedInstance.formatter;
    capabilitiesMask.ignoreZero = YES;
    
    NSArray *bits = [[NSArray alloc] initWithObjects:capabilitiesMask, subtypeMask, nil];
    
    MKBitfieldFormatter *formatter = [MKBitfieldFormatter new];
    formatter.bits = bits;
    s_BitfieldFormatter = formatter;
    
    [bits release];
    [capabilitiesMask release];
    [subtypeMask release];
}

//|++++++++++++++++++++++++++++++++++++|//
- (id<MKNodeFieldNumericType>)typeForMask:(NSNumber*)mask
{
    if ([mask isEqual:_$((uint32_t)CPU_SUBTYPE_MASK)])
        return MKNodeFieldCPUSubTypeARM64Features.sharedInstance;
    else
        return MKNodeFieldCPUSubTypeARM64SubType.sharedInstance;
}

//|++++++++++++++++++++++++++++++++++++|//
- (NSFormatter*)formatter
{ return s_BitfieldFormatter; }

@end



//----------------------------------------------------------------------------//
@implementation MKNodeFieldCPUSubTypeARM64SubType

static NSDictionary *s_Types = nil;
static MKEnumerationFormatter *s_Formatter = nil;

MKMakeSingletonInitializer(MKNodeFieldCPUSubTypeARM64SubType)

//|++++++++++++++++++++++++++++++++++++|//
+ (void)initialize
{
    if (s_Types != nil && s_Formatter != nil)
        return;
    
    s_Types = [@{
         _$(CPU_SUBTYPE_ARM64_ALL): @"CPU_SUBTYPE_ARM64_ALL",
         _$(CPU_SUBTYPE_ARM64_V8): @"CPU_SUBTYPE_ARM64_V8",
         _$(CPU_SUBTYPE_ARM64E): @"CPU_SUBTYPE_ARM64E"
    } retain];
    
    MKEnumerationFormatter *formatter = [MKEnumerationFormatter new];
    formatter.name = @"CPU_SUBTYPE_ARM64";
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
{ return @"ARM64 CPU Subtype"; }

//|++++++++++++++++++++++++++++++++++++|//
- (NSFormatter*)formatter
{ return s_Formatter; }

@end



//----------------------------------------------------------------------------//
@implementation MKNodeFieldCPUSubTypeARM64Features

static NSDictionary *s_Capability = nil;
static MKOptionSetFormatter *s_CapabilityFormatter = nil;

MKMakeSingletonInitializer(MKNodeFieldCPUSubTypeARM64Features)

//|++++++++++++++++++++++++++++++++++++|//
+ (void)initialize
{
    if (s_Capability != nil && s_CapabilityFormatter != nil)
        return;
    
    s_Capability = [@{
        _$((uint32_t)CPU_SUBTYPE_PTRAUTH_ABI): @"CPU_SUBTYPE_PTRAUTH_ABI",
    } retain];
    
    MKOptionSetFormatter *formatter = [MKOptionSetFormatter new];
    formatter.options = s_Capability;
    s_CapabilityFormatter = formatter;
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  MKNodeFieldOptionSetType
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeFieldOptionSetOptions*)options
{ return s_Capability; }

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeFieldOptionSetTraits)optionSetTraits
{ return 0; }

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  MKNodeFieldType
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (NSString*)name
{ return @"ARM64 CPU Subtype Features"; }

//|++++++++++++++++++++++++++++++++++++|//
- (NSFormatter*)formatter
{ return s_CapabilityFormatter; }

@end
