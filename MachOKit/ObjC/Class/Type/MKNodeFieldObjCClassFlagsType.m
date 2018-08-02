//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKNodeFieldObjCClassFlagsType.m
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

#import "MKNodeFieldObjCClassFlagsType.h"
#import "MKInternal.h"
#import "MKNodeDescription.h"

//----------------------------------------------------------------------------//
@implementation MKNodeFieldObjCClassFlagsType

static NSDictionary *s_Flags = nil;
static MKOptionSetFormatter *s_Formatterr = nil;

MKMakeSingletonInitializer(MKNodeFieldObjCClassFlagsType)

//|++++++++++++++++++++++++++++++++++++|//
+ (void)initialize
{
    if (s_Flags != nil && s_Formatterr != nil)
        return;
    
    s_Flags = [@{
        _$((uint32_t)MKObjCClassMeta): @"RO_META",
        _$((uint32_t)MKObjCClassRoot): @"RO_ROOT",
        _$((uint32_t)MKObjCClassHasCXXStructors): @"RO_HAS_CXX_STRUCTORS",
        _$((uint32_t)MKObjCClassHidden): @"RO_HIDDEN",
        _$((uint32_t)MKObjCClassException): @"RO_EXCEPTION",
        _$((uint32_t)MKObjCClassIsARR): @"RO_IS_ARC",
        _$((uint32_t)MKObjCClassHasCXXDestructorOnly): @"RO_HAS_CXX_DTOR_ONLY",
        _$((uint32_t)MKObjCClassHasWeakiVarWithoutARR): @"RO_HAS_WEAK_WITHOUT_ARC"
    } retain];
    
    MKOptionSetFormatter *formatter = [MKOptionSetFormatter new];
    formatter.options = s_Flags;
    s_Formatterr = formatter;
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
{ return @"ObjC Class Flags"; }

//|++++++++++++++++++++++++++++++++++++|//
- (NSFormatter*)formatter
{ return s_Formatterr; }

@end
