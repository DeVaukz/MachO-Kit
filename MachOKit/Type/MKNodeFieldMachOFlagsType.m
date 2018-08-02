//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKNodeFieldMachOFlagsType.m
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

#import "MKNodeFieldMachOFlagsType.h"
#import "MKInternal.h"
#import "MKNodeDescription.h"

//----------------------------------------------------------------------------//
@implementation MKNodeFieldMachOFlagsType

static MKNodeFieldOptionSetOptions *s_Flags = nil;
static MKOptionSetFormatter *s_Formatter = nil;

MKMakeSingletonInitializer(MKNodeFieldMachOFlagsType)

//|++++++++++++++++++++++++++++++++++++|//
+ (void)initialize
{
    if (s_Flags != nil && s_Formatter != nil)
        return;
    
    s_Flags = [@{
        _$((uint32_t)MH_NOUNDEFS): @"MH_NOUNDEFS",
        _$((uint32_t)MH_INCRLINK): @"MH_INCRLINK",
        _$((uint32_t)MH_DYLDLINK): @"MH_DYLDLINK",
        _$((uint32_t)MH_BINDATLOAD): @"MH_BINDATLOAD",
        _$((uint32_t)MH_SPLIT_SEGS): @"MH_SPLIT_SEGS",
        _$((uint32_t)MH_LAZY_INIT): @"MH_LAZY_INIT",
        _$((uint32_t)MH_TWOLEVEL): @"MH_TWOLEVEL",
        _$((uint32_t)MH_FORCE_FLAT): @"MH_FORCE_FLAT",
        _$((uint32_t)MH_NOMULTIDEFS): @"MH_NOMULTIDEFS",
        _$((uint32_t)MH_NOFIXPREBINDING): @"MH_NOFIXPREBINDING",
        _$((uint32_t)MH_PREBINDABLE): @"MH_PREBINDABLE",
        _$((uint32_t)MH_ALLMODSBOUND): @"MH_ALLMODSBOUND",
        _$((uint32_t)MH_SUBSECTIONS_VIA_SYMBOLS): @"MH_SUBSECTIONS_VIA_SYMBOLS",
        _$((uint32_t)MH_WEAK_DEFINES): @"MH_WEAK_DEFINES",
        _$((uint32_t)MH_BINDS_TO_WEAK): @"MH_BINDS_TO_WEAK",
        _$((uint32_t)MH_ALLOW_STACK_EXECUTION): @"MH_ALLOW_STACK_EXECUTION",
        _$((uint32_t)MH_ROOT_SAFE): @"MH_ROOT_SAFE",
        _$((uint32_t)MH_SETUID_SAFE): @"MH_SETUID_SAFE",
        _$((uint32_t)MH_NO_REEXPORTED_DYLIBS): @"MH_NO_REEXPORTED_DYLIBS",
        _$((uint32_t)MH_PIE): @"MH_PIE",
        _$((uint32_t)MH_DEAD_STRIPPABLE_DYLIB): @"MH_DEAD_STRIPPABLE_DYLIB",
        _$((uint32_t)MH_HAS_TLV_DESCRIPTORS): @"MH_HAS_TLV_DESCRIPTORS",
        _$((uint32_t)MH_NO_HEAP_EXECUTION): @"MH_NO_HEAP_EXECUTION",
        _$((uint32_t)MH_APP_EXTENSION_SAFE): @"MH_APP_EXTENSION_SAFE"
    } retain];
    
    MKOptionSetFormatter *formatter = [MKOptionSetFormatter new];
    formatter.options = s_Flags;
    s_Formatter = formatter;
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  MKNodeFieldOptionSetType
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeFieldOptionSetOptions*)options
{ return s_Flags; }

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeFieldOptionSetTraits)optionSetTraits
{ return 0; }

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  MKNodeFieldType
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (NSString*)name
{ return @"Mach-O Flags"; }

//|++++++++++++++++++++++++++++++++++++|//
- (NSFormatter*)formatter
{ return s_Formatter; }

@end
