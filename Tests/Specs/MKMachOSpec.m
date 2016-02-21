//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKMachOSpec.m
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

#import <mach-o/dyld.h>

SpecBegin(MKMachOImage)
@autoreleasepool {
    NSArray *frameworks = [NSFileManager allExecutableURLs:MKFrameworkTypeAllFrameworks];
    
    for (NSURL *frameworkURL in frameworks)
    describe([frameworkURL lastPathComponent], ^{
        NSError *error = nil;
        
        Binary *otool = [Binary binaryAtURL:frameworkURL];
        if (otool == nil)
            return;
        
        MKMemoryMap *map = [MKMemoryMap memoryMapWithContentsOfFile:frameworkURL error:&error];
        it(@"should have a map", ^{
            expect(map).toNot.beNil();
            expect(error).to.beNil();
        });
        if (map == nil) return;
        
        //--------------------------------------------------------------------//
        //--------------------------------------------------------------------//
        for (Architecture *otoolArchitecture in otool.architectures)
        describe(otoolArchitecture.name, ^{
            NSError *error = nil;
            MKMachOImage *macho;
            
            macho = [[MKMachOImage alloc] initWithName:frameworkURL.lastPathComponent.UTF8String flags:0 atAddress:otoolArchitecture.offset inMapping:map error:&error];
            it(@"should initialize", ^{
                expect(macho).toNot.beNil();
                expect(error).to.beNil();
            });
            if (macho == nil) return;
            
            it(@"should have the correct name", ^{
                expect(macho.name).to.equal(frameworkURL.lastPathComponent.description);
            });
            
            //----------------------------------------------------------------//
            describe(@"header", ^{
                NSDictionary *otoolArchitectureHeader = otoolArchitecture.machHeader;
                MKMachHeader *machoHeader;
                
                machoHeader = macho.header;
                it(@"should exist", ^{
                    expect(machoHeader).toNot.beNil();
                });
                if (machoHeader == nil) return;
                
                it(@"should have the correct magic", ^{
                    uint32_t expected;
                    [[NSScanner scannerWithString:otoolArchitectureHeader[@"magic"]] scanHexInt:&expected];
                    expect(machoHeader.magic).to.equal(expected);
                });
                
                it(@"should have the correct CPU type", ^{
                    expect(machoHeader.cputype).to.equal([otoolArchitectureHeader[@"cputype"] integerValue]);
                });
                
                it(@"should have the correct CPU subtype", ^{
                    expect(machoHeader.cpusubtype).to.equal([otoolArchitectureHeader[@"cpusubtype"] integerValue]);
                });
                
                it(@"should have the correct number of load commands", ^{
                    expect(machoHeader.ncmds).to.equal([otoolArchitectureHeader[@"ncmds"] integerValue]);
                });
                
                it(@"should have the correct size of load commands", ^{
                    expect(machoHeader.sizeofcmds).to.equal([otoolArchitectureHeader[@"sizeofcmds"] integerValue]);
                });
                
                it(@"should have the correct flags", ^{
                    uint32_t expected;
                    [[NSScanner scannerWithString:otoolArchitectureHeader[@"flags"]] scanHexInt:&expected];
                    expect(machoHeader.flags).to.equal(expected);
                });
            });
            
            //----------------------------------------------------------------//
            describe(@"load commands", ^{
                NSArray *otoolArchitectureLoadCommands = otoolArchitecture.loadCommands;
                NSArray *machoLoadCommands = macho.loadCommands;
                
                it(@"should exist", ^{
                    expect(machoLoadCommands).toNot.beNil();
                });
                if (machoLoadCommands == nil) return;
                
                it(@"should have the correct number of load commands", ^{
                    expect(machoLoadCommands.count).to.equal(otoolArchitectureLoadCommands.count);
                });
                
                //------------------------------------------------------------//
                for (NSUInteger i=0; i<MIN(machoLoadCommands.count, otoolArchitectureLoadCommands.count); i++)
                describe([NSString stringWithFormat:@"%lu", (unsigned long)i], ^{
                    NSDictionary *otoolArchitectureLoadCommand = otoolArchitectureLoadCommands[i];
                    MKLoadCommand *machoLoadCommand = machoLoadCommands[i];
                    MKNodeDescription *layout = machoLoadCommand.layout;
                    
                    it(@"should be the correct type of load command", ^{
                        expect([machoLoadCommand.class name]).to.equal(otoolArchitectureLoadCommand[@"cmd"]);
                    });
                    if ([[machoLoadCommand.class name] isEqualToString:otoolArchitectureLoadCommand[@"cmd"]] == NO) return;
                    
                    it(@"should have the correct cmdsize", ^{
                        expect(machoLoadCommand.cmdSize).to.equal([otoolArchitectureLoadCommand[@"cmdsize"] integerValue]);
                    });
                    
                    for (NSString *key in otoolArchitectureLoadCommand)
                    {
                        if ([key isEqualToString:@"cmd"] || [key isEqualToString:@"cmdsize"] || [key isEqualToString:@"sections"])
                            continue;
                        
                        it([NSString stringWithFormat:@"%@.%@ should have the correct value", [machoLoadCommand.class name], key], ^{
                            NSString *machoLoadCommandValue = nil;
                            for (MKNodeField *field in layout.fields) {
                                if ([field.name isEqualToString:key]) {
                                    machoLoadCommandValue = [field formattedDescriptionForNode:machoLoadCommand];
                                    break;
                                }
                            }
                            expect(machoLoadCommandValue).to.equal(otoolArchitectureLoadCommand[key]);
                        });
                    }
                });
            });
        });
        
        
    });
}
SpecEnd
