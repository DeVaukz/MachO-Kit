//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             NMUtil.m
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

#import "NMUtil.h"

//----------------------------------------------------------------------------//
@implementation NMUtil

//|++++++++++++++++++++++++++++++++++++|//
+ (NSArray*)parseBSDSymbols:(NSString*)input
{
    NSMutableArray *result = [NSMutableArray array];
    NSArray *lines = [input componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    NSRegularExpression *addressRegex = [NSRegularExpression regularExpressionWithPattern:@"[0-f]{8,}" options:0 error:NULL];
    
    for (NSString *line in lines) {
        NSArray *components = [line componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        components = [components filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^(NSString* evaluatedObject, __unused id bindings) {
            return (BOOL)([evaluatedObject stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0);
        }]];
        
        NSMutableArray<NSString*> *tokens = [components mutableCopy];
        NSMutableDictionary *output = [NSMutableDictionary new];
        
        // Address
        void (^parseAddress)(void) = ^{
            NSString *current = tokens.firstObject;
            if (current == nil)
                return;
            
            if ([addressRegex rangeOfFirstMatchInString:current options:0 range:NSMakeRange(0, current.length)].location == 0) {
                [output setObject:current forKey:@"address"];
                [tokens removeObjectAtIndex:0];
            }
        };
        
        // Type
        NSString* (^parseType)(void) = ^{
            NSString *current = tokens.firstObject;
            if (current.length != 1)
                return (NSString*)nil;
            
            [output setObject:current forKey:@"type"];
            [tokens removeObjectAtIndex:0];
            
            return current;
        };
        
        // STAB Info
        void (^parseSTABInfo)(void) = ^{
            NSMutableDictionary *stabInfo = [NSMutableDictionary new];
            
            // Sect
            NSString *current = tokens.firstObject;
            [stabInfo setObject:current forKey:@"sect"];
            [tokens removeObjectAtIndex:0];
            
            // Desc
            current = tokens.firstObject;
            [stabInfo setObject:current forKey:@"desc"];
            [tokens removeObjectAtIndex:0];
            
            // Type
            current = tokens.firstObject;
            [stabInfo setObject:current forKey:@"type"];
            [tokens removeObjectAtIndex:0];
            
            [output setObject:stabInfo forKey:@"stabInfo"];
        };
        
        // Name
        void (^parseName)(void) = ^{
            NSMutableString *symbolname = [NSMutableString new];
            NSString *current;
            
            while ((current = tokens.firstObject) && [current characterAtIndex:0] != '(')
            {
                if (symbolname.length > 0)
                    [symbolname appendString:@" "];
                [symbolname appendString:current];
                [tokens removeObjectAtIndex:0];
            }
            
            if (symbolname.length > 0)
                [output setObject:symbolname forKey:@"name"];
        };
        
        // Indirect
        void (^parseIndirect)(void) = ^{
            NSString *current = tokens.firstObject;
            
            if (![current isEqualToString:@"(indirect"])
                return;
            [tokens removeObjectAtIndex:0];
            
            // Consume the 'for'
            [tokens removeObjectAtIndex:0];
            
            current = tokens.firstObject;
            current = [current stringByReplacingOccurrencesOfString:@")" withString:@""];
            
            [output setObject:current forKey:@"indirect"];
            [tokens removeObjectAtIndex:0];
        };
        
        parseAddress();
        if ([parseType() isEqualToString:@"-"])
            parseSTABInfo();
        parseName();
        parseIndirect();
        
        if (output.count > 0)
            [result addObject:output];
    }
    
    return result;
}

//|++++++++++++++++++++++++++++++++++++|//
+ (NSArray*)parseDarwinSymbols:(NSString*)input
{
    NSMutableArray *result = [NSMutableArray array];
    NSArray *lines = [input componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    NSRegularExpression *addressRegex = [NSRegularExpression regularExpressionWithPattern:@"[0-f]{8,}" options:0 error:NULL];
    NSRegularExpression *sectionRegex = [NSRegularExpression regularExpressionWithPattern:@"\\([A-Za-z0-9_]+,[A-Za-z0-9_]+\\)" options:0 error:NULL];
    
    for (NSString *line in lines) {
        NSArray *components = [line componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        components = [components filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^(NSString* evaluatedObject, __unused id bindings) {
            return (BOOL)([evaluatedObject stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0);
        }]];
        
        NSMutableArray<NSString*> *tokens = [components mutableCopy];
        NSMutableDictionary *output = [NSMutableDictionary new];
        
        // Address
        void (^parseAddress)(void) = ^{
            NSString *current = tokens.firstObject;
            if (current == nil)
                return;
            
            if ([addressRegex rangeOfFirstMatchInString:current options:0 range:NSMakeRange(0, current.length)].location == 0) {
                [output setObject:current forKey:@"address"];
                [tokens removeObjectAtIndex:0];
            }
        };
        
        // Section
        void (^parseTypeAndSection)(void) = ^{
            NSString *current = tokens.firstObject;
            if (current == nil)
                return;
            
            if ([sectionRegex rangeOfFirstMatchInString:current options:0 range:NSMakeRange(0, current.length)].location == 0) {
                [output setObject:@"N_SECT" forKey:@"type"];
                [output setObject:[current substringWithRange:NSMakeRange(1, current.length-2)] forKey:@"section"];
                [tokens removeObjectAtIndex:0];
            } else if ([current isEqualToString:@"(common)"]) {
                [output setObject:@"N_UNDF" forKey:@"type"];
                // Consume the '(alignment 2^_)', if it is present.
                if ([tokens.firstObject rangeOfString:@"alignment"].length > 0) {
                    // TODO - Parse it?
                    [tokens removeObjectAtIndex:0];
                }
            }
            // TODO - Need to support 'prebound' here
            else if ([current rangeOfString:@"undefined"].length > 0) {
                [output setObject:@"N_UNDF" forKey:@"type"];
                [tokens removeObjectAtIndex:0];
                
                if ([tokens.firstObject containsString:@"["]) {
                    [tokens removeObjectAtIndex:0];
                    while (tokens.firstObject && [tokens.firstObject containsString:@"]"] == NO) {
                        // TODO - parse these?
                        [tokens removeObjectAtIndex:0];
                    }
                    [tokens removeObjectAtIndex:0];
                }
            } else if ([current isEqualToString:@"(absolute)"]) {
                [output setObject:@"N_ABS" forKey:@"type"];
                [tokens removeObjectAtIndex:0];
            } else if ([current isEqualToString:@"(indirect)"]) {
                [output setObject:@"N_INDR" forKey:@"type"];
                [tokens removeObjectAtIndex:0];
            }
            // llvm-nm does not handle stabs when printing symbols in darwin
            // format (it does not check if any of the N_STAB bits are set and
            // instead proceeds to look at the N_TYPE bits). Certain stabs are
            // marked by a bit pattern that also gives them a valid N_TYPE
            // after masking. Example:
            //          N_BNSYM & N_TYPE == N_SECT
            // llvm-nm in darwin format will parse these entries incorrectly.
            // The best we can do is assume that if llvm-nm prints the type
            // of a symbol as '?' - meaning a type that it did not recognize -
            // then it must be a stab.
            else if ([current isEqualToString:@"(?)"]) {
                [output setObject:@"N_STAB" forKey:@"type"];
                [tokens removeObjectAtIndex:0];
            }
        };
        
        // External
        void (^parseExternal)(void) = ^{
            NSString *current = tokens.firstObject;
            if (current == nil)
                return;
            
            if ([current isEqualToString:@"[referenced"]) {
                [output setObject:@(YES) forKey:@"referencedDynamically"];
                [tokens removeObjectAtIndex:0];
                
                // Consume the 'dynamically]'
                [tokens removeObjectAtIndex:0];
            }
            
            current = tokens.firstObject;
            if (current == nil)
                return;
            
            if ([current isEqualToString:@"weak"]) {
                [output setObject:@(YES) forKey:@"weak"];
                [tokens removeObjectAtIndex:0];
            }
            
            current = tokens.firstObject;
            if (current == nil)
                return;
            
            if ([current isEqualToString:@"private"]) {
                [output setObject:@(YES) forKey:@"privateExternal"];
                [tokens removeObjectAtIndex:0];
            }
            
            current = tokens.firstObject;
            if (current == nil)
                return;
            
            if ([current isEqualToString:@"external"]) {
                [output setObject:@(YES) forKey:@"external"];
                [tokens removeObjectAtIndex:0];
            } else if ([current isEqualToString:@"non-external"]) {
                // Do not set anything
                [tokens removeObjectAtIndex:0];
            }
            
            current = tokens.firstObject;
            if (current == nil)
                return;
            
            if ([current isEqualToString:@"automatically"]) {
                // TODO - Surface this?
                [tokens removeObjectAtIndex:0];
                // Consume the 'hidden'
                [tokens removeObjectAtIndex:0];
            }
            
            current = tokens.firstObject;
            if (current == nil)
                return;
            
            if ([current isEqualToString:@"(was"]) {
                do {
                    [tokens removeObjectAtIndex:0];
                    current = tokens.firstObject;
                    if (current == nil)
                        return;
                } while ([current containsString:@")"] == NO);
                [tokens removeObjectAtIndex:0];
                
                [output setObject:@(YES) forKey:@"privateExternal"];
            }
        };
        
        // Attributes
        void (^parseAttributes)(void) = ^{
            NSString *current = tokens.firstObject;
            if (current == nil)
                return;
            
            if ([current isEqualToString:@"[Thumb]"]) {
                [output setObject:@(YES) forKey:@"thumb"];
                [tokens removeObjectAtIndex:0];
            }
        };
        
        // Name
        void (^parseName)(void) = ^{
            NSMutableString *symbolname = [NSMutableString new];
            NSString *current;
            
            while ((current = tokens.firstObject) && [current characterAtIndex:0] != '(')
            {
                if (symbolname.length > 0)
                    [symbolname appendString:@" "];
                [symbolname appendString:current];
                [tokens removeObjectAtIndex:0];
            }
            
            if (symbolname.length > 0)
                [output setObject:symbolname forKey:@"name"];
        };
        
        // Source Library
        void (^parseSourceLibrary)(void) = ^{
            NSString *current = tokens.firstObject;
            if (current == nil)
                return;
            
            if ([current isEqualToString:@"(from"]) {
                [tokens removeObjectAtIndex:0];
                current = tokens.firstObject;
                if (current == nil)
                    return;
                
                [output setObject:[current substringWithRange:NSMakeRange(0, current.length-1)] forKey:@"sourceLibrary"];
                [tokens removeObjectAtIndex:0];
            }
        };
        
        parseAddress();
        parseTypeAndSection();
        parseExternal();
        parseAttributes();
        parseName();
        parseSourceLibrary();
        
        if (output.count > 0)
            [result addObject:output];
    }
    
    return result;
}

@end
