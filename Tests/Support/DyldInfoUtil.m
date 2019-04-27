//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             DyldInfoUtil.m
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

#import "DyldInfoUtil.h"

//----------------------------------------------------------------------------//
@implementation DyldInfoUtil

//|++++++++++++++++++++++++++++++++++++|//
+ (NSArray*)parseDylibs:(NSString*)input
{
    NSMutableArray *result = [NSMutableArray array];
    NSArray *lines = [input componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    for (NSString *line in lines) {
        if ([line rangeOfString:@"/"].location == NSNotFound) {
            if (result.count > 0) break;
            else continue;
        }
        
        NSArray *components = [line componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        components = [components filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^(NSString* evaluatedObject, __unused id bindings) {
            return (BOOL)([evaluatedObject stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0);
        }]];
        
        if (components.count > 1)
            [result addObject:@{
                @"name": components[1],
                @"attributes": components[0]
            }];
        else
            [result addObject:@{
                @"name": components[0]
            }];
    }
    
    return result;
}

//|++++++++++++++++++++++++++++++++++++|//
+ (NSArray*)parseRebaseCommands:(NSString*)input
{
    NSMutableArray *result = nil;
    NSArray *lines = [input componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    for (NSString *line in lines) {
        if ([line rangeOfString:@"rebase opcodes"].location == 0) {
            result = [NSMutableArray array];
            continue;
        } else if ([line rangeOfString:@"REBASE_"].location != NSNotFound)
            [result addObject:line];
        else if (result.count > 0)
            // dyldinfo -arch x86_64 ... prints the rebase commands for both
            // x86_64_all and x86_64h.  Fortunately, it prints the x86_64_all
            // slice first so we stop parsing when we hit then end of the first
            // set of rebase opcodes.
            break;
    }
    
    return result;
}

//|++++++++++++++++++++++++++++++++++++|//
+ (NSArray*)parseBindCommands:(NSString*)input
{
    NSMutableArray *result = nil;
    NSArray *lines = [input componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    for (NSString *line in lines) {
        if ([line rangeOfString:@"binding opcodes"].location == 0) {
            result = [NSMutableArray array];
        } else if ([line rangeOfString:@"BIND_"].location != NSNotFound)
            [result addObject:line];
        else if (result.count > 0)
            break;
    }
    
    return result;
}

//|++++++++++++++++++++++++++++++++++++|//
+ (NSArray*)parseWeakBindCommands:(NSString*)input
{
    NSMutableArray *result = nil;
    NSArray *lines = [input componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    for (NSString *line in lines) {
        if ([line rangeOfString:@"weak binding opcodes"].location == 0) {
            result = [NSMutableArray array];
            continue;
        } else if ([line rangeOfString:@"BIND_"].location != NSNotFound)
            [result addObject:line];
        else if (result.count > 0)
            break;
    }
    
    return result;
}

//|++++++++++++++++++++++++++++++++++++|//
+ (NSArray*)parseLazyBindCommands:(NSString*)input
{
    NSMutableArray *result = nil;
    NSArray *lines = [input componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    for (NSString *line in lines) {
        if ([line rangeOfString:@"lazy binding opcodes"].location == 0) {
            result = [NSMutableArray array];
            continue;
        } else if ([line rangeOfString:@"BIND_"].location != NSNotFound)
            [result addObject:line];
        else if (result.count > 0)
            break;
    }
    
    return result;
}

//|++++++++++++++++++++++++++++++++++++|//
+ (NSArray*)parseFixups:(NSString*)input
{
    NSMutableArray *result = [NSMutableArray array];
    NSArray *lines = [input componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    for (NSString *line in lines) {
        NSArray *components = [line componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (components.count > 1 && [components[0] rangeOfString:@"__"].location == 0) {
            components = [components filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^(NSString* evaluatedObject, __unused id bindings) {
                return (BOOL)([evaluatedObject stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0);
            }]];
            
            [result addObject:@{
                @"segment": components[0],
                @"section": components[1],
                @"address": components[2],
                @"type": [[components subarrayWithRange:NSMakeRange(3, components.count - 3)] componentsJoinedByString:@" "]
            }];
        } else if (result.count > 0)
            // dyldinfo -arch x86_64 ... prints the fixups for both
            // x86_64_all and x86_64h.  Fortunately, it prints the x86_64_all
            // slice first so we stop parsing when we hit then end of the first
            // set of fixups.
            break;
    }
    
    return result;
}

//|++++++++++++++++++++++++++++++++++++|//
+ (NSArray*)parseBindings:(NSString*)input
{
    NSMutableArray *result = [NSMutableArray array];
    NSArray *lines = [input componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    for (NSString *line in lines) {
        NSArray *components = [line componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (components.count > 1 && [components[0] rangeOfString:@"__"].location == 0) {
            components = [components filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^(NSString* evaluatedObject, __unused id bindings) {
                return (BOOL)([evaluatedObject stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0);
            }]];
            
            [result addObject:@{
                @"segment": components[0],
                @"section": components[1],
                @"address": components[2],
                @"type": components[3],
                @"addend": components[4],
                @"dylib": components[5],
                @"symbol": components[6]
            }];
        } else if (result.count > 0)
            // dyldinfo -arch x86_64 ... prints the bindings for both
            // x86_64_all and x86_64h.  Fortunately, it prints the x86_64_all
            // slice first so we stop parsing when we hit then end of the first
            // set of bindings.
            break;
    }
    
    return result;
}

//|++++++++++++++++++++++++++++++++++++|//
+ (NSArray*)parseWeakBindings:(NSString*)input
{
    NSMutableArray *result = [NSMutableArray array];
    NSArray *lines = [input componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    for (NSString *line in lines) {
        NSArray *components = [line componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (components.count > 1 && [components[0] rangeOfString:@"__"].location == 0) {
            components = [components filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^(NSString* evaluatedObject, __unused id bindings) {
                return (BOOL)([evaluatedObject stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0);
            }]];
            
            [result addObject:@{
                @"segment": components[0],
                @"section": components[1],
                @"address": components[2],
                @"type": components[3],
                @"addend": components[4],
                @"symbol": components[5]
            }];
        } else if (result.count > 0)
            // dyldinfo -arch x86_64 ... prints the bindings for both
            // x86_64_all and x86_64h.  Fortunately, it prints the x86_64_all
            // slice first so we stop parsing when we hit then end of the first
            // set of bindings.
            break;
    }
    
    return result;
}

//|++++++++++++++++++++++++++++++++++++|//
+ (NSArray*)parseLazyBindings:(NSString*)input
{
    NSMutableArray *result = [NSMutableArray array];
    NSArray *lines = [input componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    for (NSString *line in lines) {
        NSArray *components = [line componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (components.count > 1 && [components[0] rangeOfString:@"__"].location == 0) {
            components = [components filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^(NSString* evaluatedObject, __unused id bindings) {
                return (BOOL)([evaluatedObject stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0);
            }]];
            
            [result addObject:@{
                @"segment": components[0],
                @"section": components[1],
                @"address": components[2],
                @"index": components[3],
                @"dylib": components[4],
                @"symbol": components[5]
            }];
        } else if (result.count > 0)
            // dyldinfo -arch x86_64 ... prints the bindings for both
            // x86_64_all and x86_64h.  Fortunately, it prints the x86_64_all
            // slice first so we stop parsing when we hit then end of the first
            // set of bindings.
            break;
    }
    
    return result;
}

//|++++++++++++++++++++++++++++++++++++|//
+ (NSArray*)parseExports:(NSString*)input
{
	NSMutableArray *result = nil;
	NSArray *lines = [input componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
	
	for (NSString *line in lines) {
		if (result == nil && [line rangeOfString:@"export information"].location == 0) {
			result = [NSMutableArray array];
			continue;
		} else if ([line rangeOfString:@"0x"].location != NSNotFound ||
				   [line rangeOfString:@"[re-export]"].location != NSNotFound)
			[result addObject:line];
		else if (result.count > 0)
			break;
	}
	
	return result;
}

//|++++++++++++++++++++++++++++++++++++|//
+ (NSArray*)parseFunctionStarts:(NSString*)input
{
    unsigned long long previous = 0;
    NSMutableArray *result = [NSMutableArray array];
    NSArray *lines = [input componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    for (NSString *line in lines) {
        NSArray *components = [line componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (components.count > 0 && [components[0] rangeOfString:@"0x"].location == 0) {
            
            NSScanner *scanner = [[NSScanner alloc] initWithString:components[0]];
            unsigned long long address;
            if ([scanner scanHexLongLong:&address] == NO || address < previous)
                break;
            else
                previous = address;
            
            components = [components filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^(NSString* evaluatedObject, __unused id bindings) {
                return (BOOL)([evaluatedObject stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0);
            }]];
            
            BOOL isThumb = [components[1] isEqualToString:@"[thumb]"];
            NSString *symbolName = components.count > 2 ? components[2] : components[1];
            if ([symbolName isEqualToString:@"?"])
                symbolName = nil;
            
            if (symbolName) {
                [result addObject:@{
                    @"address": components[0],
                    @"thumb" : [NSNumber numberWithBool:isThumb],
                    @"symbol": symbolName
                }];
            } else {
                [result addObject:@{
                    @"address": components[0],
                    @"thumb" : [NSNumber numberWithBool:isThumb]
                }];
            }
        }
    }
    
    return result;
}

@end
