//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             Binary.h
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

@import Foundation;

//----------------------------------------------------------------------------//
@interface Architecture : NSObject

- (instancetype)initWithURL:(NSURL*)url offset:(uint32_t)offset name:(NSString*)name;

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) uint32_t offset;

@property (nonatomic, readonly) NSDictionary *machHeader;
@property (nonatomic, readonly) NSArray *loadCommands;
@property (nonatomic, readonly) NSArray *dependentLibraries;
@property (nonatomic, readonly) NSArray *rebaseCommands;
@property (nonatomic, readonly) NSArray *bindCommands;
@property (nonatomic, readonly) NSArray *weakBindCommands;
@property (nonatomic, readonly) NSArray *lazybindCommands;
@property (nonatomic, readonly) NSArray *fixupAddresses;
@property (nonatomic, readonly) NSArray *bindings;
@property (nonatomic, readonly) NSArray *weakBindings;
@property (nonatomic, readonly) NSArray *lazyBindings;
@property (nonatomic, readonly) NSArray *exports;
@property (nonatomic, readonly) NSArray *functionStarts;
@property (nonatomic, readonly) NSArray *dataInCodeEntries;
@property (nonatomic, readonly) NSArray *bsdSymbols;
@property (nonatomic, readonly) NSArray *darwinSymbols;
@property (nonatomic, readonly) NSArray *indirectSymbols;
@property (nonatomic, readonly) NSDictionary *objcInfo;

@end



//----------------------------------------------------------------------------//
@interface Binary : NSObject

+ (instancetype)binaryAtURL:(NSURL*)url;

- (instancetype)initWithURL:(NSURL*)url;

@property (nonatomic, readonly) NSURL *url;

@property (nonatomic, readonly) NSDictionary<NSString*, id> *fatHeader;
@property (nonatomic, readonly) NSDictionary *fatHeader_verbose;
@property (nonatomic, readonly) NSArray /*Architecture*/ *architectures;

@end
