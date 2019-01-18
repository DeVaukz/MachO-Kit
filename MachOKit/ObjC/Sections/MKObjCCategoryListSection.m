//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKObjCCategoryListSection.m
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

#import "MKObjCCategoryListSection.h"
#import "MKInternal.h"
#import "MKSegment.h"
#import "MKObjCCategory.h"

//----------------------------------------------------------------------------//
@implementation MKObjCCategoryListSection

//|++++++++++++++++++++++++++++++++++++|//
+ (uint32_t)canInstantiateWithSectionLoadCommand:(id<MKLCSection>)sectionLoadCommand inSegment:(MKSegment*)segment
{
#pragma unused (segment)
    if (self != MKObjCCategoryListSection.class)
        return 0;
    
    if ([sectionLoadCommand.segname rangeOfString:@SEG_DATA].location == 0 &&
        ([sectionLoadCommand.sectname isEqualToString:@"__objc_catlist"] ||
         [sectionLoadCommand.sectname isEqualToString:@"__objc_nlcatlist"]))
        return 50;
    
    return 0;
}

//|++++++++++++++++++++++++++++++++++++|//
+ (Class)classForGenericArgumentAtIndex:(__unused NSUInteger)index
{ return MKObjCCategory.class; }

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
+ (MKNodeFieldBuilder*)_elementsFieldBuilder
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-method-access"
    MKNodeFieldBuilder *strx = [super _elementsFieldBuilder];
#pragma clang diagnostic pop
    strx.options |= MKNodeFieldOptionDisplayAsChild;
    
    return strx;
}

@end
