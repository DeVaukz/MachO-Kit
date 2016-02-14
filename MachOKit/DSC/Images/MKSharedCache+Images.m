//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKSharedCache+Images.m
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

#import "MKSharedCache+Images.h"
#import "NSError+MK.h"
#import "MKDSCImagesInfo.h"

//----------------------------------------------------------------------------//
@implementation MKSharedCache (Images)

//|++++++++++++++++++++++++++++++++++++|//
- (MKDSCImagesInfo*)imagesInfo
{
    if (_imagesInfo == nil) {
        NSError *e = nil;
        
        _imagesInfo = [[MKDSCImagesInfo alloc] initWithSharedCache:self error:&e];
        if (_imagesInfo == nil)
            MK_PUSH_UNDERLYING_WARNING(imagesInfo, e, @"Failed to load images info.");
    }
    
    return _imagesInfo;
}

@end
