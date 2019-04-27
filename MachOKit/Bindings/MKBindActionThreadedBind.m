//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKBindActionThreadedBind.m
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

#import "MKBindActionThreadedBind.h"
#import "MKInternal.h"

//----------------------------------------------------------------------------//
@implementation MKBindActionThreadedBind

//|++++++++++++++++++++++++++++++++++++|//
+ (uint32_t)canInstantiateWithContext:(struct MKBindContext*)bindContext
{
    if (self != MKBindActionThreadedBind.class)
        return 0;
    
    return bindContext->type == BIND_TYPE_THREADED_BIND ? 50 : 0;
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithContext:(struct MKBindContext*)bindContext error:(NSError**)error
{
    // the ordinal is bits [0..15]
    uint16_t ordinal = bindContext->threadedBindValue.raw & 0xFFFF;
    
    if (ordinal >= bindContext->ordinalTable.count) {
        MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_EOUT_OF_RANGE description:@"No entry in ordinalTable for index [% " PRIu16 "].", ordinal];
        [self release]; return nil;
    }
    
    struct MKBindThreadedData threadedBindData;
    NSValue *threadedBindDataValue = bindContext->ordinalTable[ordinal];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability-new"
    if ([threadedBindDataValue respondsToSelector:@selector(getValue:size:)])
        [threadedBindDataValue getValue:&threadedBindData size:sizeof(threadedBindData)];
    else
        [threadedBindDataValue getValue:&threadedBindData];
#pragma clang diagnostic pop
    
    int64_t previousLibraryOrdinal = bindContext->libraryOrdinal;
    bindContext->libraryOrdinal = threadedBindData.libraryOrdinal;
    
    int64_t previousAddend = bindContext->addend;
    bindContext->addend = threadedBindData.addend;
    
    // 'type' is already correctly set
    
    uint8_t previousSymbolFlags = bindContext->symbolFlags;
    bindContext->symbolFlags = threadedBindData.symbolFlags;
    
    NSString *previousSymbolName = bindContext->symbolName;
    bindContext->symbolName = threadedBindData.symbolName;
    
    self = [super initWithContext:bindContext error:error];
    if (self) {
        
    }
    
    bindContext->symbolName = previousSymbolName;
    bindContext->symbolFlags = previousSymbolFlags;
    bindContext->addend = previousAddend;
    bindContext->libraryOrdinal = previousLibraryOrdinal;
    
    return self;
}

@end
