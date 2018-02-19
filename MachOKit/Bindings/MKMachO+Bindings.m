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
#import "MKInternal.h"

#import "MKBindingsInfo.h"
#import "MKWeakBindingsInfo.h"
#import "MKLazyBindingsInfo.h"

//----------------------------------------------------------------------------//
@implementation MKMachOImage (Bindings)

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Bindings Information
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (MKOptional*)bindingsInfo
{
    if (_bindingsInfo == nil)
    {
        NSError *bindingsInfoError = nil;
        
        MKBindingsInfo *bindingsInfo = [[MKBindingsInfo alloc] initWithParent:self error:&bindingsInfoError];
        if (bindingsInfo)
            _bindingsInfo = [[MKOptional alloc] initWithValue:bindingsInfo];
        else if (bindingsInfoError /* Only failed if we have an error */)
            _bindingsInfo = [[MKOptional alloc] initWithError:bindingsInfoError];
        else
            _bindingsInfo = [MKOptional new];
        
        [bindingsInfo release];
    }
    
    return _bindingsInfo;
}

//|++++++++++++++++++++++++++++++++++++|//
- (MKOptional*)weakBindingsInfo
{
    if (_weakBindingsInfo == nil)
    {
        NSError *bindingsInfoError = nil;
        
        MKWeakBindingsInfo *bindingsInfo = [[MKWeakBindingsInfo alloc] initWithParent:self error:&bindingsInfoError];
        if (bindingsInfo)
            _weakBindingsInfo = [[MKOptional alloc] initWithValue:bindingsInfo];
        else if (bindingsInfoError /* Only failed if we have an error */)
            _weakBindingsInfo = [[MKOptional alloc] initWithError:bindingsInfoError];
        else
            _weakBindingsInfo = [MKOptional new];
        
        [bindingsInfo release];
    }
    
    return _weakBindingsInfo;
}

//|++++++++++++++++++++++++++++++++++++|//
- (MKOptional*)lazyBindingsInfo
{
    if (_lazyBindingsInfo == nil)
    {
        NSError *bindingsInfoError = nil;
        
        MKLazyBindingsInfo *bindingsInfo = [[MKLazyBindingsInfo alloc] initWithParent:self error:&bindingsInfoError];
        if (bindingsInfo)
            _lazyBindingsInfo = [[MKOptional alloc] initWithValue:bindingsInfo];
        else if (bindingsInfoError /* Only failed if we have an error */)
            _lazyBindingsInfo = [[MKOptional alloc] initWithError:bindingsInfoError];
        else
            _lazyBindingsInfo = [MKOptional new];
        
        [bindingsInfo release];
    }
    
    return _lazyBindingsInfo;
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
+ (MKNodeFieldBuilder*)_bindingsInfoFieldBuilder
{
    MKNodeFieldBuilder *bindingsInfo = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(bindingsInfo)
        type:[MKNodeFieldTypeNode typeWithNodeType:MKBindingsInfo.class]
    ];
    bindingsInfo.description = @"Binding Info";
    bindingsInfo.options = MKNodeFieldOptionDisplayAsChild;
    
    return bindingsInfo;
}

//|++++++++++++++++++++++++++++++++++++|//
+ (MKNodeFieldBuilder*)_weakBindingsInfoFieldBuilder
{
    MKNodeFieldBuilder *weakBindingsInfo = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(weakBindingsInfo)
        type:[MKNodeFieldTypeNode typeWithNodeType:MKWeakBindingsInfo.class]
    ];
    weakBindingsInfo.description = @"Weak Binding Info";
    weakBindingsInfo.options = MKNodeFieldOptionDisplayAsChild;
    
    return weakBindingsInfo;
}

//|++++++++++++++++++++++++++++++++++++|//
+ (MKNodeFieldBuilder*)_lazyBindingsInfoFieldBuilder
{
    MKNodeFieldBuilder *lazyBindingsInfo = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(lazyBindingsInfo)
        type:[MKNodeFieldTypeNode typeWithNodeType:MKLazyBindingsInfo.class]
    ];
    lazyBindingsInfo.description = @"Lazy Binding Info";
    lazyBindingsInfo.options = MKNodeFieldOptionDisplayAsChild;
    
    return lazyBindingsInfo;
}

@end
