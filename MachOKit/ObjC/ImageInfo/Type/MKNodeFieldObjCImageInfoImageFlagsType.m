//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKNodeFieldObjCImageInfoImageFlagsType.m
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

#import "MKNodeFieldObjCImageInfoImageFlagsType.h"
#import "MKInternal.h"
#import "MKNodeDescription.h"

//----------------------------------------------------------------------------//
@implementation MKNodeFieldObjCImageInfoImageFlagsType

static NSDictionary *s_SystemAttributes = nil;
static MKOptionSetFormatter *s_SystemFormatter = nil;

MKMakeSingletonInitializer(MKNodeFieldObjCImageInfoImageFlagsType)

//|++++++++++++++++++++++++++++++++++++|//
+ (void)initialize
{
    if (s_SystemAttributes != nil && s_SystemFormatter != nil)
        return;
    
    s_SystemAttributes = [@{
        _$(MKObjCImageIsReplacement): @"IsReplacement",
        _$(MKObjCImageSupportsGC): @"SupportsGC",
        _$(MKObjCImageRequiresGC): @"RequiresGC",
        _$(MKObjCImageOptimizedByDyld): @"OptimizedByDyld",
        _$(MKObjCImageCorrectedSynthesize): @"CorrectedSynthesize",
        _$(MKObjCImageIsSimulated): @"IsSimulated",
        _$(MKObjCImageHasCategoryClassProperties): @"HasCategoryClassProperties",
    } retain];
    
    MKOptionSetFormatter *formatter = [MKOptionSetFormatter new];
    formatter.options = s_SystemAttributes;
    s_SystemFormatter = formatter;
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  MKNodeFieldOptionSetType
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeFieldOptionSetOptions*)options
{ return s_SystemAttributes; }

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeFieldOptionSetTraits)optionSetTraits
{ return 0; }

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  MKNodeFieldType
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (NSString*)name
{ return @"ObjC Image Flags"; }

//|++++++++++++++++++++++++++++++++++++|//
- (NSFormatter*)formatter
{ return s_SystemFormatter; }

@end
