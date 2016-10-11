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

@end
