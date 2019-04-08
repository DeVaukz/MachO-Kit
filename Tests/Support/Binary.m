//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             Binary.m
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

#import "Binary.h"

//----------------------------------------------------------------------------//
@implementation Architecture {
    NSArray* (^makeArgs)(NSString*, NSArray*);
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithURL:(NSURL*)url offset:(uint32_t)offset name:(NSString*)name
{
    self = [super init];
    
    NSParameterAssert(url);
    NSParameterAssert(name);
    _name = name = [name lowercaseString];
    _offset = offset;
    
    makeArgs = ^(NSString *tool, NSArray *input) {
        NSMutableArray *args = [NSMutableArray array];
        [args addObject:tool];
        [args addObject:@"-arch"];
        [args addObject:name];
        [args addObjectsFromArray:input];
        [args addObject:url.path];
        return args;
    };
    
    // Mach Header
    @autoreleasepool {
        NSString *machHeader = [NSTask outputForLaunchedTaskWithLaunchPath:@XCRUN_PATH arguments:makeArgs(@"otool", @[@"-h"])];
        _machHeader = [OtoolUtil parseMachHeader:machHeader];
    }
    
    // Load Commands
    @autoreleasepool {
        NSString *loadCommands = [NSTask outputForLaunchedTaskWithLaunchPath:@XCRUN_PATH arguments:makeArgs(@"otool", @[@"-l"])];
        _loadCommands = [OtoolUtil parseLoadCommands:loadCommands];
    }
    
    // Libraries
    @autoreleasepool {
        NSString *loadCommands = [NSTask outputForLaunchedTaskWithLaunchPath:@XCRUN_PATH arguments:makeArgs(@"dyldinfo", @[@"-dylibs"])];
        _dependentLibraries = [DyldInfoUtil parseDylibs:loadCommands];
    }
    
    // Rebase & bind Commands
    @autoreleasepool {
        NSString *opcodes = [NSTask outputForLaunchedTaskWithLaunchPath:@XCRUN_PATH arguments:makeArgs(@"dyldinfo", @[@"-opcodes"])];
        _rebaseCommands = [DyldInfoUtil parseRebaseCommands:opcodes];
        _bindCommands = [DyldInfoUtil parseBindCommands:opcodes];
        _weakBindCommands = [DyldInfoUtil parseWeakBindCommands:opcodes];
        _lazybindCommands = [DyldInfoUtil parseLazyBindCommands:opcodes];
    }
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (NSArray*)fixupAddresses
{
    NSArray *fixupAddresses;
    @autoreleasepool {
        NSString *fixups = [NSTask outputForLaunchedTaskWithLaunchPath:@XCRUN_PATH arguments:makeArgs(@"dyldinfo", @[@"-rebase"])];
        fixupAddresses = [DyldInfoUtil parseFixups:fixups];
    }
    return fixupAddresses;
}

//|++++++++++++++++++++++++++++++++++++|//
- (NSArray*)bindings
{
    NSArray *bindingAddresses;
    @autoreleasepool {
        NSString *bindings = [NSTask outputForLaunchedTaskWithLaunchPath:@XCRUN_PATH arguments:makeArgs(@"dyldinfo", @[@"-bind"])];
        bindingAddresses = [DyldInfoUtil parseBindings:bindings];
    }
    return bindingAddresses;
}

//|++++++++++++++++++++++++++++++++++++|//
- (NSArray*)weakBindings
{
    NSArray *bindingAddresses;
    @autoreleasepool {
        NSString *bindings = [NSTask outputForLaunchedTaskWithLaunchPath:@XCRUN_PATH arguments:makeArgs(@"dyldinfo", @[@"-weak_bind"])];
        bindingAddresses = [DyldInfoUtil parseWeakBindings:bindings];
    }
    return bindingAddresses;
}

//|++++++++++++++++++++++++++++++++++++|//
- (NSArray*)lazyBindings
{
    NSArray *bindingAddresses;
    @autoreleasepool {
        NSString *bindings = [NSTask outputForLaunchedTaskWithLaunchPath:@XCRUN_PATH arguments:makeArgs(@"dyldinfo", @[@"-lazy_bind"])];
        bindingAddresses = [DyldInfoUtil parseLazyBindings:bindings];
    }
    return bindingAddresses;
}

//|++++++++++++++++++++++++++++++++++++|//
- (NSArray*)exports
{
	NSArray *exportsList;
	@autoreleasepool {
		NSString *exports = [NSTask outputForLaunchedTaskWithLaunchPath:@XCRUN_PATH arguments:makeArgs(@"dyldinfo", @[@"-export"])];
		exportsList = [DyldInfoUtil parseExports:exports];
	}
	return exportsList;
}

//|++++++++++++++++++++++++++++++++++++|//
- (NSArray*)functionStarts
{
    NSArray *functionStartsList;
    @autoreleasepool {
        NSString *functionStarts = [NSTask outputForLaunchedTaskWithLaunchPath:@XCRUN_PATH arguments:makeArgs(@"dyldinfo", @[@"-function_starts"])];
        functionStartsList = [DyldInfoUtil parseFunctionStarts:functionStarts];
    }
    return functionStartsList;
}

//|++++++++++++++++++++++++++++++++++++|//
- (NSArray*)dataInCodeEntries
{
    NSArray *dataInCodeEntriesList;
    @autoreleasepool {
        NSString *dataInCodeEntries = [NSTask outputForLaunchedTaskWithLaunchPath:@XCRUN_PATH arguments:makeArgs(@"otool", @[@"-G"])];
        dataInCodeEntriesList = [OtoolUtil parseDataInCodeEntries:dataInCodeEntries];
    }
    return dataInCodeEntriesList;
}

//|++++++++++++++++++++++++++++++++++++|//
- (NSArray*)bsdSymbols
{
    NSArray *symbolsList;
    @autoreleasepool {
        NSString *symbols = [NSTask outputForLaunchedTaskWithLaunchPath:@XCRUN_PATH arguments:makeArgs(@"nm", @[@"-ap", @"-no-dyldinfo", @"-f", @"bsd"])];
        symbolsList = [NMUtil parseBSDSymbols:symbols];
    }
    return symbolsList;
}

//|++++++++++++++++++++++++++++++++++++|//
- (NSArray*)darwinSymbols
{
    NSArray *symbolsList;
    @autoreleasepool {
        NSString *symbols = [NSTask outputForLaunchedTaskWithLaunchPath:@XCRUN_PATH arguments:makeArgs(@"nm", @[@"-ap", @"-no-dyldinfo", @"-f", @"darwin"])];
        symbolsList = [NMUtil parseDarwinSymbols:symbols];
    }
    return symbolsList;
}

//|++++++++++++++++++++++++++++++++++++|//
- (NSArray*)indirectSymbols
{
    NSArray *symbolsList;
    @autoreleasepool {
        NSString *symbols = [NSTask outputForLaunchedTaskWithLaunchPath:@XCRUN_PATH arguments:makeArgs(@"otool", @[@"-I"])];
        symbolsList = [OtoolUtil parseIndirectSymbols:symbols];
    }
    return symbolsList;
}

//|++++++++++++++++++++++++++++++++++++|//
- (NSDictionary*)objcInfo
{
    NSDictionary *objcInfo;
    @autoreleasepool {
        NSString *info = [NSTask outputForLaunchedTaskWithLaunchPath:@XCRUN_PATH arguments:makeArgs(@"otool", @[@"-ov"])];
        objcInfo = [OtoolUtil parseObjCImageInfo:info];
    }
    return objcInfo;
}

@end



//----------------------------------------------------------------------------//
@implementation Binary

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)binaryAtURL:(NSURL*)url
{
    static NSMutableDictionary *memo;
    if (memo == nil)
        memo = [[NSMutableDictionary alloc] init];
    
    if (memo[url] == nil)
        @autoreleasepool { memo[url] = [[self alloc] initWithURL:url]; }
    
    return memo[url];
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithURL:(NSURL*)url
{
    self = [super init];
    
    _url = url;
    
    // Fat header
    {
        NSString *otoolFatHeader = [NSTask outputForLaunchedTaskWithLaunchPath:@OTOOL_PATH arguments:@[@"-f", url.path]];
        if ([otoolFatHeader rangeOfString:@"No such file or directory"].location != NSNotFound)
            return nil;
        
        _fatHeader = [OtoolUtil parseFatHeader:otoolFatHeader];
        
        NSString *otoolVerboseFatHeader = [NSTask outputForLaunchedTaskWithLaunchPath:@OTOOL_PATH arguments:@[@"-f", @"-v", url.path]];
        if ([otoolVerboseFatHeader rangeOfString:@"No such file or directory"].location != NSNotFound)
            return nil;
        
        _fatHeader_verbose = [OtoolUtil parseFatHeader:otoolVerboseFatHeader];
    }
    
    if (_fatHeader_verbose)
    {
        NSMutableArray *architectures = [[NSMutableArray alloc] init];
        
        NSDictionary *arches = _fatHeader_verbose[@"architecture"];
        for (NSString *arch in arches) {
            [architectures addObject:[[Architecture alloc] initWithURL:_url offset:(uint32_t)[[arches[arch] objectForKey:@"offset"] integerValue] name:arch]];
        }
        
        _architectures = architectures;
    }
    else
    {
        // Get the arch name
        NSString *args = [NSString stringWithFormat:@"%@ -h -v %@ | tail -n 1 | awk '{print $2}' | tr -d '\n'", @OTOOL_PATH, url.path];
        NSString *archName = [NSTask outputForLaunchedTaskWithLaunchPath:@SHELL_PATH arguments:@[@"-c", args]];
        Architecture *arch = [[Architecture alloc] initWithURL:_url offset:0 name:archName];
        _architectures = @[arch];
    }
    
    return self;
}

@end
