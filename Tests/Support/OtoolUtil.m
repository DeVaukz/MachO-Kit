//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             OtoolUtil.m
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

#import "OtoolUtil.h"
#import "NSArray+MKTests.h"

typedef void (^ParserAction)(NSMutableDictionary*);
typedef BOOL (^OptionalParserAction)(NSMutableDictionary*);

//----------------------------------------------------------------------------//
@implementation OtoolUtil

//|++++++++++++++++++++++++++++++++++++|//
+ (NSDictionary*)parseMachHeader:(NSString*)input
{
    NSMutableArray *lines = [[input componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] mutableCopy];
    
    // Expect "Mach header"
    NSAssert([lines[0] isEqualToString:@"Mach header"], @"");
    [lines removeObjectAtIndex:0];
    
    NSMutableArray *keys;
    NSMutableArray *values;
    
    // Keys
    {
        keys = [[lines[0] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] mutableCopy];
        [keys removeObject:@""];
        [lines removeObjectAtIndex:0];
    }
    
    // Values
    {
        values = [[lines[0] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] mutableCopy];
        [values removeObject:@""];
        [lines removeObjectAtIndex:0];
    }
    
    NSAssert(keys.count == values.count, @"Expected same number of keys and values");
    return [NSDictionary dictionaryWithObjects:values forKeys:keys];
}


//|++++++++++++++++++++++++++++++++++++|//
+ (NSArray*)parseLoadCommands:(NSString*)input
{
    NSMutableArray *result = [NSMutableArray array];
    NSMutableArray *lines = [[input componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] mutableCopy];
    
    // Remove path
    [lines removeObjectAtIndex:0];
    
    ParserAction parseLoadCommand = ^(NSMutableDictionary *dest) {
        NSAssert([lines[0] rangeOfString:@"Load command"].location != NSNotFound, @"Unuexpected line: %@", lines[0]);
        [lines removeObjectAtIndex:0];

        OptionalParserAction parseSingleValueLine =  ^(NSMutableDictionary *dest) {
            NSMutableArray *tokens = [[lines[0] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] mutableCopy];
            [tokens removeObject:@""];
            //NSAssert(tokens.count == 2, @"Expected only two tokens: %@", tokens);
            [lines removeObjectAtIndex:0];
            if (tokens.count != 2) return NO;
            
            NSString *key = tokens[0];
            [tokens removeObjectAtIndex:0];
            NSString *value = tokens[0];
            [tokens removeObjectAtIndex:0];
            [dest setValue:value forKey:key];
            return YES;
        };
        
        OptionalParserAction parseName = ^(NSMutableDictionary *dest) {
            NSMutableArray *tokens = [[lines[0] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] mutableCopy];
            [tokens removeObject:@""];
            if (tokens.count == 0 || [tokens[0] isEqualToString:@"name"] == NO) return NO;
            [lines removeObjectAtIndex:0];
            
            // Consume "name"
            NSString *key = tokens[0];
            [tokens removeObjectAtIndex:0];
            
            NSMutableString *value = [NSMutableString string];
            while (tokens.count && [tokens[0] characterAtIndex:0] != '(') {
                [value appendString:tokens[0]];
                [tokens removeObjectAtIndex:0];
            }
            
            [dest setValue:value forKey:key];
            return YES;
        };
        
        OptionalParserAction parseVersion = ^(NSMutableDictionary *dest) {
            NSMutableArray *tokens = [[lines[0] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] mutableCopy];
            [tokens removeObject:@""];
            if (tokens.count != 3 || [tokens[1] isEqualToString:@"version"] == NO) return NO;
            [lines removeObjectAtIndex:0];
            
            NSString *key = [NSString stringWithFormat:@"%@ %@", tokens[0], tokens[1]];
            [dest setValue:tokens[2] forKey:key];
            return YES;
        };
        
        OptionalParserAction parsePlatform = ^(NSMutableDictionary *dest) {
            NSMutableArray *tokens = [[lines[0] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] mutableCopy];
            [tokens removeObject:@""];
            if (tokens.count == 0 || [tokens[0] isEqualToString:@"platform"] == NO) return NO;
            [lines removeObjectAtIndex:0];
            
            // Consume "platform"
            NSString *key = tokens[0];
            [tokens removeObjectAtIndex:0];
            // Consume the value
            NSString *value = tokens[0];
            [tokens removeObjectAtIndex:0];
            
            if ([value isEqualToString:@"macos"])
                [dest setValue:@"PLATFORM_MACOS" forKey:key];
            else if ([value isEqualToString:@"ios"])
                [dest setValue:@"PLATFORM_IOS" forKey:key];
            else if ([value isEqualToString:@"tvos"])
                [dest setValue:@"PLATFORM_TVOS" forKey:key];
            else if ([value isEqualToString:@"watchos"])
                [dest setValue:@"PLATFORM_WATCHOS" forKey:key];
            else if ([value isEqualToString:@"bridgeos"])
                [dest setValue:@"PLATFORM_BRIDGEOS" forKey:key];
            else if ([value isEqualToString:@"iosmac"])
                [dest setValue:@"PLATFORM_IOSMAC" forKey:key];
            else if ([value isEqualToString:@"iossimulator"])
                [dest setValue:@"PLATFORM_IOSSIMULATOR" forKey:key];
            else if ([value isEqualToString:@"tvossimulator"])
                [dest setValue:@"PLATFORM_TVOSSIMULATOR" forKey:key];
            else if ([value isEqualToString:@"watchossimulator"])
                [dest setValue:@"PLATFORM_WATCHOSSIMULATOR" forKey:key];
            else
                [dest setValue:value forKey:key];
            
            return YES;
        };
        
        OptionalParserAction parseTools = ^(NSMutableDictionary *dest) {
            NSMutableArray *tokens = [[lines[0] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] mutableCopy];
            [tokens removeObject:@""];
            if (tokens.count == 0 || [tokens[0] isEqualToString:@"ntools"] == NO) return NO;
            [lines removeObjectAtIndex:0];
            
            // Consume "ntools"
            NSString *key = tokens[0];
            [tokens removeObjectAtIndex:0];
            // Consume the value
            NSString *value = tokens[0];
            [tokens removeObjectAtIndex:0];
            
            [dest setValue:value forKey:key];
            
            NSMutableArray *tools = dest[@"tools"] = [[NSMutableArray alloc] init];
            
            NSMutableDictionary *tool = [[NSMutableDictionary alloc] init];
            while (lines.count &&
                   ([lines[0] rangeOfString:@"tool"].length > 0 || [lines[0] rangeOfString:@"version"].length > 0) &&
                   [lines[0] rangeOfString:@"Load command"].location == NSNotFound)
            {
                parseSingleValueLine(tool);
                
                // Once we have a tool name and version, add it to the list
                // and move on.
                if (tool[@"tool"] && tool[@"version"]) {
                    [tools addObject:[tool copy]];
                    [tool removeAllObjects];
                }
            }
            
            return YES;
        };
        
        OptionalParserAction parseSection = ^(NSMutableDictionary *dest) {
            if ([lines[0] rangeOfString:@"Section"].location == NSNotFound) return NO;
            [lines removeObjectAtIndex:0];
            
            NSMutableArray *sections = dest[@"sections"];
            if (sections == nil)
                dest[@"sections"] = sections = [[NSMutableArray alloc] init];
            
            NSArray *actions = @[
                parseSingleValueLine
            ];
            
            NSMutableDictionary *section = [[NSMutableDictionary alloc] init];
            while (lines.count && [lines[0] rangeOfString:@"Section"].location == NSNotFound && [lines[0] rangeOfString:@"Load command"].location == NSNotFound)
            {
                for (OptionalParserAction action in actions) {
                    if (action(section)) break;
                }
            }
            
            [sections addObject:section];
            return YES;
        };
        
        NSArray *actions = @[
            parseSection,
            parseTools,
            parsePlatform,
            parseName,
            parseVersion,
            parseSingleValueLine
        ];
        
        while (lines.count && [lines[0] rangeOfString:@"Load command"].location == NSNotFound) {
            for (OptionalParserAction action in actions) {
                if (action(dest)) break;
            }
        }
        
        return;
    };
    
    while (lines.count) {
        
        // Workaround: otool -l in Xcode 8 dumps the Mach header before the load commands.
        while ([lines[0] rangeOfString:@"Load command"].location == NSNotFound)
            [lines removeObjectAtIndex:0];
        
        NSMutableDictionary *loadCommand = [NSMutableDictionary dictionary];
        parseLoadCommand(loadCommand);
        [result addObject:loadCommand];
    }
    
    return result;
}


//|++++++++++++++++++++++++++++++++++++|//
+ (NSDictionary*)parseFatHeader:(NSString*)input
{
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    NSMutableArray *tokens = [[input componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] mutableCopy];
    [tokens removeObject:@""]; // TODO - Why are the indents not being caught by whitespaceAndNewlineCharacterSet?
    
    // Remove the "Fat" "headers"
    if (tokens.count <= 2) return nil;
    [tokens removeObjectAtIndex:0];
    [tokens removeObjectAtIndex:0];
    
    ParserAction parseSingleValue =  ^(NSMutableDictionary *dest) {
        NSString *key = tokens[0];
        [tokens removeObjectAtIndex:0];
        NSString *value = tokens[0];
        [tokens removeObjectAtIndex:0];
        [dest setValue:value forKey:key];
    };
    
    // For the alignment field
    ParserAction parseAlignValue =  ^(NSMutableDictionary *dest) {
        NSString *key = tokens[0];
        [tokens removeObjectAtIndex:0];
        [tokens removeObjectAtIndex:0];
        NSString *value = tokens[0];
        value = [value stringByReplacingOccurrencesOfString:@"(" withString:@""];
        value = [value stringByReplacingOccurrencesOfString:@")" withString:@""];
        [tokens removeObjectAtIndex:0];
        [dest setValue:value forKey:key];
    };
    
    ParserAction parseArchitecture = ^(NSMutableDictionary *dest) {
        NSMutableDictionary *architectures = dest[@"architecture"];
        if (architectures == nil)
            dest[@"architecture"] = architectures = [[NSMutableDictionary alloc] init];
        
        NSString *key = tokens[0];
        NSAssert([key isEqualToString:@"architecture"], @"Invalid token: %@", key);
        [tokens removeObjectAtIndex:0];
        NSString *architectureName = tokens[0];
        [tokens removeObjectAtIndex:0];
        
        NSDictionary *actions = @{
            @"cputype": parseSingleValue,
            @"cpusubtype": parseSingleValue,
            @"capabilities": parseSingleValue,
            @"offset": parseSingleValue,
            @"size": parseSingleValue,
            @"align": parseAlignValue,
        };
        
        NSMutableDictionary *arch = [[NSMutableDictionary alloc] init];
        while (tokens.count && [tokens[0] isEqualToString:key] == NO)
        {
            NSString *peek = tokens[0];
            ParserAction action = actions[peek];
            NSAssert(action, @"Invalid token: %@", peek);
            action(arch);
        }
        
        [architectures setValue:arch forKey:architectureName];
    };
    
    NSDictionary *actions = @{
        @"fat_magic": parseSingleValue,
        @"nfat_arch": parseSingleValue,
        @"architecture": parseArchitecture
    };
    
    while (tokens.count)
    {
        NSString *peek = tokens[0];
        ParserAction action = actions[peek];
        NSAssert(action, @"Invalid token: %@", peek);
        action(result);
    }
    
    return result;
}


//|++++++++++++++++++++++++++++++++++++|//
+ (NSArray*)parseDataInCodeEntries:(NSString*)input
{
    NSMutableArray *result = [NSMutableArray array];
    NSArray *lines = [input componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    for (NSString *line in lines) {
        NSArray *components = [line componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (components.count > 0 && [components[0] rangeOfString:@"0x"].location == 0) {
            
            components = [components filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^(NSString* evaluatedObject, __unused id bindings) {
                return (BOOL)([evaluatedObject stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0);
            }]];
            
            [result addObject:@{
                @"offset": components[0],
                @"length": components[1],
                @"kind": components[2]
            }];
        }
    }
    
    return result;
}


//|++++++++++++++++++++++++++++++++++++|//
+ (NSArray*)parseIndirectSymbols:(NSString*)input
{
    NSMutableArray *result = [NSMutableArray new];
    NSArray<NSString*> *lines = [input componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    NSString *currentSegment = nil;
    NSString *currentSection = nil;
    
    for (NSString *line in lines) {
        if ([line rangeOfString:@"Indirect symbols for"].location == 0) {
            NSUInteger afterOpeningParen = [line rangeOfString:@"("].location + 1;
            NSUInteger beforeClosingParen = [line rangeOfString:@")"].location;
            NSArray *components = [[line substringWithRange:NSMakeRange(afterOpeningParen, beforeClosingParen - afterOpeningParen)] componentsSeparatedByString:@","];
            currentSegment = components.firstObject;
            currentSection = components.lastObject;
            continue;
        } else if ([line rangeOfString:@"0x"].location == 0) {
            NSArray *components = [line componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            components = [components filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^(NSString* evaluatedObject, __unused id bindings) {
                return (BOOL)([evaluatedObject stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0);
            }]];
            
            NSString *address = components[0];
            NSString *index = components[1];
            
            NSMutableDictionary *entry = [NSMutableDictionary new];
            entry[@"segment"] = currentSegment;
            entry[@"section"] = currentSection;
            entry[@"indirectAddress"] = address;
            if ([index isEqualToString:@"LOCAL"]) {
                entry[@"local"] = @(YES);
                entry[@"index"] = @(INDIRECT_SYMBOL_LOCAL);
                // Handle 'LOCAL ABSOLUTE'
                if (components.count > 2 && [components[2] isEqualToString:@"ABSOLUTE"]) {
                    entry[@"absolute"] = @(YES);
                    entry[@"index"] = @(INDIRECT_SYMBOL_LOCAL | INDIRECT_SYMBOL_ABS);
                }
            } else if ([index isEqualToString:@"ABSOLUTE"]) {
                entry[@"absolute"] = @(YES);
                entry[@"index"] = @(INDIRECT_SYMBOL_ABS);
            } else
                entry[@"index"] = @([index intValue]);
            
            [result addObject:entry];
            continue;
        }
    }
    
    return result;
}


//|++++++++++++++++++++++++++++++++++++|//
+ (NSDictionary*)parseObjCImageInfo:(NSString*)input
{ @autoreleasepool {
    NSMutableDictionary *result = [NSMutableDictionary new];
    NSArray<NSString*> *lines = [input componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    // __objc_imageinfo
    NSDictionary* (^parseImageInfo)(NSArray*) = ^(NSArray *lines) {
        NSMutableDictionary *info = [NSMutableDictionary new];
        
        for (NSString *line in lines) {
            NSArray *tokens = [line componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            tokens = [tokens filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^(id token, __unused id bindings) {
                return (BOOL)([token length] > 0);
            }]];
            
            if (tokens.count >= 2)
                [info setObject:tokens[1] forKey:tokens[0]];
        }
        
        return info;
    };
    
    // __objc_classlist
    // <Dict>
    //      Pointer Address -> <Dict>
    //          "isa" -> <Dict> (Meta class)
    //              ...
    //          ...
    NSMutableDictionary* (^parseClassList)(NSArray*) = ^(NSArray *lines) {
        NSMutableDictionary *classes = [NSMutableDictionary new];
        
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[0-f]{16} 0x[0-f]+" options:0 error:NULL];
        [lines mk_sliceWithTest:^(NSString *line) {
            return (BOOL)([regex numberOfMatchesInString:line options:0 range:NSMakeRange(0, line.length)] > 0);
        } andEnumerate:^(NSString *seperator, NSArray *lines) {
            
            NSString *pointerAddress = [[seperator componentsSeparatedByString:@" "] firstObject];
            __block NSDictionary *class = nil;
            __block NSDictionary *metaClass = nil;
            
            NSDictionary* (^parseClass)(NSArray*) = ^(NSArray *lines) {
                NSMutableDictionary *classDict = [NSMutableDictionary new];
                
                [lines mk_sliceWithHeirarchyTest:^NSUInteger(NSString *line) {
                    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[0-9]+" options:0 error:NULL];
                    line = [line stringByReplacingOccurrencesOfString:@"\t" withString:@"    "];
                    NSUInteger loc = [regex rangeOfFirstMatchInString:line options:0 range:NSMakeRange(0, line.length)].location;
                    return loc;
                } andEnumerate:^(NSString *header, NSArray *children) {
                    NSArray *headerComponents = [[header componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"length > 0"]];
                    NSString *key = headerComponents.firstObject;
                    id value = headerComponents.count > 1 ? headerComponents[1] : nil;
                    
                    id (^parseISA)(NSString*, NSArray*) = ^(NSString *headerValue, __unused NSArray *lines) {
                        if (headerValue && metaClass)
                            return (id)metaClass;
                        else if (headerValue)
                            return (id)headerValue;
                        else
                            return (id)@"0x0";
                    };
                    
                    id (^parseData)(NSString*, NSArray*) = ^(__unused NSString *headerValue, NSArray *lines) {
                        NSMutableDictionary *dataDict = [NSMutableDictionary new];
                        
                        [lines mk_sliceWithHeirarchyTest:^(NSString *line) {
                            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[0-9]+" options:0 error:NULL];
                            line = [line stringByReplacingOccurrencesOfString:@"\t" withString:@"        "];
                            NSUInteger loc = [regex rangeOfFirstMatchInString:line options:0 range:NSMakeRange(0, line.length)].location;
                            return loc;
                        } andEnumerate:^(NSString *header, NSArray *children) {
                            NSArray *headerComponents = [[header componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"length > 0"]];
                            NSString *key = headerComponents.firstObject;
                            id value = headerComponents.count > 1 ? headerComponents[1] : nil;
                            
                            id (^parseName)(NSString*, NSArray*) = ^(__unused NSString *headerValue, __unused NSArray *lines) {
                                return headerComponents.lastObject;
                            };
                            
                            id (^parseBaseMethods)(NSString*, NSArray*) = ^(NSString *headerValue, NSArray *lines) {
                                if (lines.count == 0)
                                    return (id)headerValue;
                                
                                NSString *entsize, *count;
                                NSMutableArray *methods = [NSMutableArray new];
                                
                                for (NSString *line in lines) {
                                    NSArray *components = [[line componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"length > 0"]];
                                    if ([components.firstObject isEqualToString:@"entsize"])
                                        entsize = components.lastObject;
                                    else if ([components.firstObject isEqualToString:@"count"])
                                        count = components.lastObject;
                                    else if ([components.firstObject isEqualToString:@"name"])
                                        [methods addObject:[[NSMutableDictionary alloc] initWithObjectsAndKeys:components.lastObject, components.firstObject, nil]];
                                    else if ([components.firstObject isEqualToString:@"types"])
                                        [methods.lastObject setObject:components.lastObject forKey:components.firstObject];
                                    // Ignore IMP for now
                                }
                                
                                return (id)@{
                                    @"entsize": entsize,
                                    @"count": count,
                                    @"elemets": methods
                                };
                            };
                            
                            id (^parseIVars)(NSString*, NSArray*) = ^(NSString *headerValue, NSArray *lines) {
                                if (lines.count == 0)
                                    return (id)headerValue;
                                
                                NSString *entsize, *count;
                                NSMutableArray *methods = [NSMutableArray new];
                                
                                for (NSString *line in lines) {
                                    NSArray *components = [[line componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"length > 0"]];
                                    if ([components.firstObject isEqualToString:@"entsize"])
                                        entsize = components.lastObject;
                                    else if ([components.firstObject isEqualToString:@"count"])
                                        count = components.lastObject;
                                    else if ([components.firstObject isEqualToString:@"offset"])
                                        [methods addObject:[[NSMutableDictionary alloc] initWithObjectsAndKeys:components.lastObject, components.firstObject, nil]];
                                    else if ([components.firstObject isEqualToString:@"name"] ||
                                             [components.firstObject isEqualToString:@"type"] ||
                                             [components.firstObject isEqualToString:@"alignment"] ||
                                             [components.firstObject isEqualToString:@"size"])
                                        [methods.lastObject setObject:components.lastObject forKey:components.firstObject];
                                }
                                
                                return (id)@{
                                    @"entsize": entsize,
                                    @"count": count,
                                    @"elemets": methods
                                };
                            };
                            
                            id (^parseProperties)(NSString*, NSArray*) = ^(NSString *headerValue, NSArray *lines) {
                                if (lines.count == 0)
                                    return (id)headerValue;
                                
                                NSString *entsize, *count;
                                NSMutableArray *elements = [NSMutableArray new];
                                
                                for (NSString *line in lines) {
                                    NSArray *components = [[line componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"length > 0"]];
                                    if ([components.firstObject isEqualToString:@"entsize"])
                                        entsize = components.lastObject;
                                    else if ([components.firstObject isEqualToString:@"count"])
                                        count = components.lastObject;
                                    else if ([components.firstObject isEqualToString:@"name"])
                                        [elements addObject:[[NSMutableDictionary alloc] initWithObjectsAndKeys:components.lastObject, components.firstObject, nil]];
                                    else if ([components.firstObject isEqualToString:@"attributes"])
                                        [elements.lastObject setObject:components.lastObject forKey:components.firstObject];
                                }
                                
                                return (id)@{
                                    @"entsize": entsize,
                                    @"count": count,
                                    @"elemets": elements
                                };
                            };
                            
                            id (^parseProtocols)(NSString*, NSArray*) = ^(NSString *headerValue, NSArray *lines) {
                                if (lines.count == 0)
                                    return (id)headerValue;
                                
                                __block NSString *count;
                                NSMutableArray *elements = [NSMutableArray new];
                                
                                NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"list\\[[0-9]+\\]" options:0 error:NULL];
                                [lines mk_sliceWithTest:^(NSString *obj) {
                                    return (BOOL)([regex numberOfMatchesInString:obj options:0 range:NSMakeRange(0, obj.length)] > 0);
                                } andEnumerate:^(id seperator, NSArray *lines) {
                                    if (seperator == nil) {
                                        NSArray *components = [[lines.lastObject componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"length > 0"]];
                                        count = components.lastObject;
                                    } else {
                                        NSMutableDictionary *protoDict = [NSMutableDictionary new];
                                        
                                        [lines mk_sliceWithHeirarchyTest:^NSUInteger(NSString *line) {
                                            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[0-9]+" options:0 error:NULL];
                                            line = [line stringByReplacingOccurrencesOfString:@"\t" withString:@"        "];
                                            NSUInteger loc = [regex rangeOfFirstMatchInString:line options:0 range:NSMakeRange(0, line.length)].location;
                                            
                                            if ([pointerAddress isEqualToString:@"000000000027c318"]) {
                                                
                                            }
                                            
                                            return loc;
                                        } andEnumerate:^(NSString *header, NSArray *children) {
                                            NSArray *headerComponents = [[header componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"length > 0"]];
                                            NSString *key = headerComponents.firstObject;
                                            id value = headerComponents.count > 1 ? headerComponents[1] : nil;
                                            
                                            id (^parseName)(NSString*, NSArray*) = ^(__unused NSString *headerValue, __unused NSArray *lines) {
                                                return headerComponents.lastObject;
                                            };
                                            
                                            NSDictionary *actions = @{
                                                @"name": parseName,
                                                @"instanceMethods": parseBaseMethods,
                                                @"classMethods": parseBaseMethods,
                                                /* @"optionalInstanceMethods": parseBaseMethods, - otool doesn't parse these */
                                                @"optionalClassMethods": parseBaseMethods,
                                                /* @"instanceProperties": parseProperties, - ... or these */
                                            };
                                            
                                            for (NSString *action in actions) {
                                                if ([key isEqualToString:action]) {
                                                    id (^block)(NSString*, NSArray*) = actions[action];
                                                    value = block(value, children);
                                                }
                                            }
                                            
                                            if (value)
                                                [protoDict setObject:value forKey:key];
                                        }];
                                        
                                        [elements insertObject:protoDict atIndex:0];
                                    }
                                }];
                                
                                return (id)@{
                                    @"count": count,
                                    @"elements": elements
                                };
                            };
                            
                            NSDictionary *actions = @{
                                @"name": parseName,
                                @"baseMethods": parseBaseMethods,
                                @"ivars": parseIVars,
                                @"baseProperties": parseProperties,
                                @"baseProtocols": parseProtocols
                            };
                            
                            for (NSString *action in actions) {
                                if ([key isEqualToString:action]) {
                                    id (^block)(NSString*, NSArray*) = actions[action];
                                    value = block(value, children);
                                }
                            }
                            
                            if (value)
                                [dataDict setObject:value forKey:key];
                        }];
                        
                        return (NSDictionary*)dataDict;
                    };
                    
                    NSDictionary *actions = @{
                        @"isa": parseISA,
                        @"data": parseData
                    };
                    
                    for (NSString *action in actions) {
                        if ([key isEqualToString:action]) {
                            id (^block)(NSString*, NSArray*) = actions[action];
                            value = block(value, children);
                        }
                    }
                    
                    if (value)
                        [classDict setObject:value forKey:key];
                }];
                
                return (NSDictionary*)classDict;
            }; // parseClass
            
            [lines mk_sliceWithTest:^(NSString *line) {
                return (BOOL)([line rangeOfString:@"Meta Class"].length > 0);
            } andEnumerate:^(NSString *seperator, NSArray *slice) {
                if ([seperator rangeOfString:@"Meta Class"].length > 0)
                    metaClass = parseClass(slice);
                else
                    class = parseClass(slice);
            }];
            
            [classes setObject:class forKey:pointerAddress];
        }];
        
        return classes;
    };
    
    NSDictionary *actions = @{
        @"__objc_imageinfo": parseImageInfo,
        @"__objc_classlist": parseClassList
    };
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"Contents of \\([A-Za-z_,]+\\) section" options:0 error:NULL];
    [lines mk_sliceWithTest:^(NSString *line) {
        return (BOOL)([regex numberOfMatchesInString:line options:0 range:NSMakeRange(0, line.length)] > 0);
    } andEnumerate:^(NSString *seperator, NSArray *slice) {
        for (NSString *key in actions) {
            if (seperator == nil || [seperator rangeOfString:key].location == NSNotFound)
                continue;
            
            @autoreleasepool {
                NSDictionary* (^action)(NSArray*) = actions[key];
                [result setObject:action(slice) forKey:key];
            }
            break;
        }
    }];
    
    return result;
} }

@end
