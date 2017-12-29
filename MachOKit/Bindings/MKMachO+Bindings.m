//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKMachO+Bindings.m
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

#import "MKMachO+Bindings.h"
#import "NSError+MK.h"

#import "MKBindingsInfo.h"
#import "MKWeakBindingsInfo.h"
#import "MKLazyBindingsInfo.h"

//----------------------------------------------------------------------------//
@implementation MKMachOImage (Bindings)

//|++++++++++++++++++++++++++++++++++++|//
- (MKBindingsInfo*)bindingsInfo
{
    if (_bindingsInfo == nil)
    {
        NSError *e = nil;
        
        _bindingsInfo = [[MKBindingsInfo alloc] initWithParent:self error:&e];
        if (_bindingsInfo == nil && e /* Only failed if we have an error */)
            MK_PUSH_UNDERLYING_WARNING(bindingsInfo, e, @"Failed to load bindings information.");
    }
    
    return _bindingsInfo;
}

//|++++++++++++++++++++++++++++++++++++|//
- (MKWeakBindingsInfo*)weakBindingsInfo
{
    if (_weakBindingsInfo == nil)
    {
        NSError *e = nil;
        
        _weakBindingsInfo = [[MKWeakBindingsInfo alloc] initWithParent:self error:&e];
        if (_weakBindingsInfo == nil && e /* Only failed if we have an error */)
            MK_PUSH_UNDERLYING_WARNING(weakBindingsInfo, e, @"Failed to load weak bindings information.");
    }
    
    return _weakBindingsInfo;
}

//|++++++++++++++++++++++++++++++++++++|//
- (MKLazyBindingsInfo*)lazyBindingsInfo
{
    if (_lazyBindingsInfo == nil)
    {
        NSError *e = nil;
        
        _lazyBindingsInfo = [[MKLazyBindingsInfo alloc] initWithParent:self error:&e];
        if (_lazyBindingsInfo == nil && e /* Only failed if we have an error */)
            MK_PUSH_UNDERLYING_WARNING(lazyBindingsInfo, e, @"Failed to load lazy bindings information.");
    }
    
    return _lazyBindingsInfo;
}

@end
