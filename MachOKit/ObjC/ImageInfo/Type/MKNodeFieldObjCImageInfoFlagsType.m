//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKNodeFieldObjCImageInfoFlagsType.m
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

#import "MKNodeFieldObjCImageInfoFlagsType.h"
#import "MKInternal.h"
#import "MKNodeDescription.h"
#import "MKNodeFieldObjCImageInfoImageFlagsType.h"
#import "MKNodeFieldObjCImageInfoSwiftVersionType.h"

#define SwiftVersionMaskShift   8
#define SwiftVersionMask        (uint32_t)(0xff << SwiftVersionMaskShift)

//----------------------------------------------------------------------------//
@implementation MKNodeFieldObjCImageInfoFlagsType

static MKNodeFieldBitfieldMasks *s_Bits = nil;
static MKBitfieldFormatter *s_Formatter = nil;

MKMakeSingletonInitializer(MKNodeFieldObjCImageInfoFlagsType)

//|++++++++++++++++++++++++++++++++++++|//
+ (void)initialize
{
    if (s_Bits != nil)
        return;
    
    s_Bits = [[NSArray alloc] initWithObjects:
        _$(SwiftVersionMask),
        _$(~SwiftVersionMask),
    nil];
    
    MKBitfieldFormatterMask *flags = [MKBitfieldFormatterMask new];
    flags.mask = _$(~SwiftVersionMask);
    flags.formatter = MKNodeFieldObjCImageInfoImageFlagsType.sharedInstance.formatter;
    flags.ignoreZero = YES;
    
    MKBitfieldFormatterMask *swiftVersion = [MKBitfieldFormatterMask new];
    swiftVersion.mask = _$(SwiftVersionMask);
    swiftVersion.formatter = MKNodeFieldObjCImageInfoSwiftVersionType.sharedInstance.formatter;
    
    NSArray *bits = [[NSArray alloc] initWithObjects:flags, swiftVersion, nil];
    
    MKBitfieldFormatter *formatter = [MKBitfieldFormatter new];
    formatter.bits = bits;
    s_Formatter = formatter;
    
    [bits release];
    [swiftVersion release];
    [flags release];
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
    if ([mask isEqual:_$(SwiftVersionMask)])
        return MKNodeFieldObjCImageInfoSwiftVersionType.sharedInstance;
    else
        return MKNodeFieldObjCImageInfoImageFlagsType.sharedInstance;
}

//|++++++++++++++++++++++++++++++++++++|//
- (int)shiftForMask:(NSNumber*)mask
{
    if ([mask isEqual:_$(SwiftVersionMask)])
        return -SwiftVersionMaskShift;
    else
        return 0;
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  MKNodeFieldType
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (NSString*)name
{ return @"ObjC Image Info Flags"; }

//|++++++++++++++++++++++++++++++++++++|//
- (NSFormatter*)formatter
{ return s_Formatter; }

@end
