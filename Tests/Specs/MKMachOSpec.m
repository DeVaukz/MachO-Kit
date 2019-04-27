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
    NSArray *frameworks = [NSFileManager allExecutableURLs:MKFrameworkTypeAll];
    
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
                    expect((machoHeader.cpusubtype & (cpu_subtype_t)~CPU_SUBTYPE_MASK)).to.equal([otoolArchitectureHeader[@"cpusubtype"] integerValue]);
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
                        if ([key isEqualToString:@"cmd"] || [key isEqualToString:@"cmdsize"] || [key isEqualToString:@"sections"] || [key isEqualToString:@"tools"])
                            continue;
                        
                        it([NSString stringWithFormat:@"%@.%@ should have the correct value", [machoLoadCommand.class name], key], ^{
                            NSString *machoLoadCommandValue = nil;
                            for (MKNodeField *field in layout.allFields) {
                                if ([field.name isEqualToString:key]) {
                                    machoLoadCommandValue = [field formattedDescriptionForNode:machoLoadCommand];
                                    break;
                                }
                            }
                            
                            // HACK HACK - otool renders a 0.0 in the LC_VERSION_MIN_* load command as 'n/a'.
                            // We don't want to match that behavior in MachOKit proper.  Just skip the unit
                            // test in this case.
                            if ([otoolArchitectureLoadCommand[key] isEqualToString:@"n/a"] && [machoLoadCommandValue isEqualToString:@"0.0"])
                                return;
                            
                            expect(machoLoadCommandValue).to.equal(otoolArchitectureLoadCommand[key]);
                        });
                    }
                });
            });
            
            //----------------------------------------------------------------//
            describe(@"dylibs", ^{
                NSArray<NSDictionary*> *dyldDependentLibraries = otoolArchitecture.dependentLibraries;
                NSArray<MKOptional<MKDependentLibrary*>*> *machoDependentLibraries = macho.dependentLibraries;
                
                it(@"should exist", ^{
                    expect(machoDependentLibraries).toNot.beNil();
                });
                
                it(@"should have the correct number of dependencies", ^{
                    expect(machoDependentLibraries.count).to.equal(dyldDependentLibraries.count);
                });
                
                //------------------------------------------------------------//
                for (NSUInteger i=0; i<MIN(machoDependentLibraries.count, dyldDependentLibraries.count); i++)
                describe([NSString stringWithFormat:@"%lu", (unsigned long)i], ^{
                    MKDependentLibrary *library = machoDependentLibraries[i].value;
                    
                    it(@"should not be nil", ^{
                        expect(library).toNot.beNil();
                    });
                    if (library == nil) return;
                    
                    it(@"should have the correct name", ^{
                        expect(library.name).to.equal(dyldDependentLibraries[i][@"name"]);
                    });
                    
                    it(@"should have the correct attributes", ^{
                        NSString *expectedAttribute = dyldDependentLibraries[i][@"attributes"];
                        BOOL expectedRequired = ![expectedAttribute isEqualToString:@"weak_import"];
                        BOOL expectedWeak = [expectedAttribute isEqualToString:@"weak_import"];
                        BOOL expectedUpward = [expectedAttribute isEqualToString:@"upward"];
                        BOOL expectedReexport = [expectedAttribute isEqualToString:@"re-export"];
                        
                        expect(library.required).to.equal(expectedRequired);
                        expect(library.weak).to.equal(expectedWeak);
                        expect(library.upward).to.equal(expectedUpward);
                        expect(library.rexported).to.equal(expectedReexport);
                    });
                });
            });
            
            //----------------------------------------------------------------//
            describe(@"rebase commands", ^{
                NSArray<NSString*> *dyldInfoRebaseCommands = otoolArchitecture.rebaseCommands;
                NSArray<NSDictionary*> *dyldInfoRebaseFixups = otoolArchitecture.fixupAddresses;
                MKRebaseInfo *machoRebaseInfo = macho.rebaseInfo.value;
                
                if (dyldInfoRebaseCommands.count != 0)
                {
                    NSArray *machoRebaseCommands = machoRebaseInfo.commands;
                    NSArray *machoRebaseFixups = machoRebaseInfo.fixups;
                    
                    it(@"should exist", ^{
                        expect(machoRebaseCommands).toNot.beNil();
                        expect(machoRebaseFixups).toNot.beNil();
                    });
                    
                    it(@"should not have any warnings", ^{
                        expect(machoRebaseInfo.warnings).to.equal(@[]);
                    });
                    
                    it(@"should have the correct number of rebase commands", ^{
                        expect(machoRebaseCommands.count).to.equal(dyldInfoRebaseCommands.count);
                    });
                    
                    it(@"should be parsed correctly", ^{
                        for (NSUInteger i=0; i<MIN(machoRebaseCommands.count, dyldInfoRebaseCommands.count); i++) {
                            MKRebaseCommand *command = machoRebaseCommands[i];
                            NSString *machoRebaseCommandDescription = [[NSString alloc] initWithFormat:@"0x%.4" MK_VM_PRIXOFFSET " %@", command.nodeOffset, command.description];
                            
                            expect(machoRebaseCommandDescription).to.equal(dyldInfoRebaseCommands[i]);
                        }
                    });
                    
                    it(@"should result in the correct number of fixups", ^{
                        expect(machoRebaseFixups.count).to.equal(dyldInfoRebaseFixups.count);
                    });
                    
                    it(@"should result in the correct fixups", ^{
                        for (NSUInteger i=0; i<MIN(machoRebaseFixups.count, dyldInfoRebaseFixups.count); i++) {
                            MKFixup *fixup = machoRebaseFixups[i];
                            
                            expect(fixup.segment.name).to.equal(dyldInfoRebaseFixups[i][@"segment"]);
                            expect(fixup.section.value.name).to.equal(dyldInfoRebaseFixups[i][@"section"]);
                            expect([NSString stringWithFormat:@"0x%.8" MK_VM_PRIXADDR "", fixup.address]).to.equal(dyldInfoRebaseFixups[i][@"address"]);
                        }
                    });
                }
                else if (dyldInfoRebaseCommands.count == 0 && dyldInfoRebaseFixups != 0)
                {
                    // Look for threaded rebase info
                    MKBindingsInfo *machoBindInfo = macho.bindingsInfo.value;
                    NSArray *machoThreadedRebaseFixups = [machoBindInfo.actions filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^(id evaluatedObject, __unused NSDictionary *bindings) {
                        return [evaluatedObject isKindOfClass:MKBindActionThreadedRebase.class];
                    }]];
                    
                    it(@"should result in the correct number of fixups", ^{
                        expect(machoThreadedRebaseFixups.count).to.equal(dyldInfoRebaseFixups.count);
                    });
                    
                    it(@"should result in the correct fixups", ^{
                        for (NSUInteger i=0; i<MIN(machoThreadedRebaseFixups.count, dyldInfoRebaseFixups.count); i++) {
                            MKBindActionThreadedRebase *fixup = machoThreadedRebaseFixups[i];
                            
                            expect(fixup.segment.name).to.equal(dyldInfoRebaseFixups[i][@"segment"]);
                            expect(fixup.section.value.name).to.equal(dyldInfoRebaseFixups[i][@"section"]);
                            expect([NSString stringWithFormat:@"0x%.8" MK_VM_PRIXADDR "", fixup.address]).to.equal(dyldInfoRebaseFixups[i][@"address"]);
                        }
                    });
                }
            });
            
            //----------------------------------------------------------------//
            describe(@"bind commands", ^{
                NSArray<NSString*> *dyldInfoBindCommands = otoolArchitecture.bindCommands;
                NSArray<NSDictionary*> *dyldInfoBindings = otoolArchitecture.bindings;
                MKBindingsInfo *machoBindInfo = macho.bindingsInfo.value;
                
                if (machoBindInfo == nil)
                    return; // TODO - Check if the image should have binding info.
                
                NSArray *machoBindCommands = machoBindInfo.commands;
                NSArray *machoBindings = [machoBindInfo.actions filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^(id evaluatedObject, __unused NSDictionary *bindings) {
                    return [evaluatedObject isKindOfClass:MKBindActionBind.class];
                }]];
                
                it(@"should exist", ^{
                    expect(machoBindCommands).toNot.beNil();
                    expect(machoBindings).toNot.beNil();
                });
                
                it(@"should not have any warnings", ^{
                    expect(machoBindInfo.warnings).to.equal(@[]);
                });
                
                it(@"should have the correct number of bind commands", ^{
                    expect(machoBindCommands.count).to.equal(dyldInfoBindCommands.count);
                });
                
                it(@"should be parsed correctly", ^{
                    for (NSUInteger i=0; i<MIN(machoBindCommands.count, dyldInfoBindCommands.count); i++) {
                        MKBindCommand *command = machoBindCommands[i];
                        NSString *machoBindCommandDescription = [[NSString alloc] initWithFormat:@"0x%.4" MK_VM_PRIXOFFSET " %@", command.nodeOffset, command.description];
                        
                        expect(machoBindCommandDescription).to.equal(dyldInfoBindCommands[i]);
                    }
                });
                
                it(@"should result in the correct number of bindings", ^{
                    expect(machoBindings.count).to.equal(dyldInfoBindings.count);
                });
                
                it(@"should result in the correct bindings", ^{
                    for (NSUInteger i=0; i<MIN(machoBindings.count, dyldInfoBindings.count); i++) {
                        MKBindActionBind *binding = machoBindings[i];
                        
                        expect(binding.segment.name).to.equal(dyldInfoBindings[i][@"segment"]);
                        expect(binding.section.value.name).to.equal(dyldInfoBindings[i][@"section"]);
                        expect([NSString stringWithFormat:@"0x%.8" MK_VM_PRIXADDR "", binding.address]).to.equal(dyldInfoBindings[i][@"address"]);
                        //expect(@(binding.type).description).to.equal(dyldInfoBindings[i][@"type"]);
                        expect(@(binding.addend).description).to.equal(dyldInfoBindings[i][@"addend"]);
                        expect(binding.symbolName).to.equal(dyldInfoBindings[i][@"symbol"]);
                        expect([binding.sourceLibrary.name rangeOfString:dyldInfoBindings[i][@"dylib"]].location).toNot.equal(NSNotFound);
                    }
                });
            });
            
            //----------------------------------------------------------------//
            describe(@"weak bind commands", ^{
                NSArray<NSString*> *dyldInfoWeakBindCommands = otoolArchitecture.weakBindCommands;
                NSArray<NSDictionary*> *dyldInfoWeakBindings = otoolArchitecture.weakBindings;
                MKWeakBindingsInfo *machoWeakBindInfo = macho.weakBindingsInfo.value;
                
                if (machoWeakBindInfo == nil)
                    return; // TODO - Check if the image should have weak bindings info.
                
                NSArray *machoWeakBindCommands = machoWeakBindInfo.commands;
                NSArray *machoWeakBindings = machoWeakBindInfo.actions;
                
                it(@"should exist", ^{
                    expect(machoWeakBindCommands).toNot.beNil();
                    expect(machoWeakBindings).toNot.beNil();
                });
                
                it(@"should not have any warnings", ^{
                    expect(machoWeakBindInfo.warnings).to.equal(@[]);
                });
                
                it(@"should have the correct number of commands", ^{
                    expect(machoWeakBindCommands.count).to.equal(dyldInfoWeakBindCommands.count);
                });
                
                it(@"should be parsed correctly", ^{
                    for (NSUInteger i=0; i<MIN(machoWeakBindCommands.count, dyldInfoWeakBindCommands.count); i++) {
                        MKBindCommand *command = machoWeakBindCommands[i];
                        NSString *machoBindCommandDescription = [[NSString alloc] initWithFormat:@"0x%.4" MK_VM_PRIXOFFSET " %@", command.nodeOffset, command.description];
                        
                        expect(machoBindCommandDescription).to.equal(dyldInfoWeakBindCommands[i]);
                    }
                });
                
                it(@"should result in the correct number of bindings", ^{
                    expect(machoWeakBindings.count).to.equal(dyldInfoWeakBindings.count);
                });
                
                it(@"should result in the correct bindings", ^{
                    for (NSUInteger i=0; i<MIN(machoWeakBindings.count, dyldInfoWeakBindings.count); i++) {
                        MKBindActionBind *binding = machoWeakBindings[i];
                        
                        expect(binding.segment.name).to.equal(dyldInfoWeakBindings[i][@"segment"]);
                        expect(binding.section.value.name).to.equal(dyldInfoWeakBindings[i][@"section"]);
                        expect([NSString stringWithFormat:@"0x%.8" MK_VM_PRIXADDR "", binding.address]).to.equal(dyldInfoWeakBindings[i][@"address"]);
                        //expect(@(binding.type).description).to.equal(dyldInfoWeakBindings[i][@"type"]);
                        expect(@(binding.addend).description).to.equal(dyldInfoWeakBindings[i][@"addend"]);
                        expect(binding.symbolName).to.equal(dyldInfoWeakBindings[i][@"symbol"]);
                    }
                });
            });
            
            //----------------------------------------------------------------//
            describe(@"lazy bind commands", ^{
                NSArray<NSString*> *dyldInfoLazyBindCommands = otoolArchitecture.lazybindCommands;
                NSArray<NSDictionary*> *dyldInfoLazyBindings = otoolArchitecture.lazyBindings;
                MKLazyBindingsInfo *machoLazyBindInfo = macho.lazyBindingsInfo.value;
                
                if (machoLazyBindInfo == nil)
                    return; // TODO - Check if the image should have lazy bindings info.
                
                NSArray *machoLazyBindCommands = machoLazyBindInfo.commands;
                NSArray *machoLazyBindings = machoLazyBindInfo.actions;
                
                it(@"should exist", ^{
                    expect(machoLazyBindCommands).toNot.beNil();
                    expect(machoLazyBindings).toNot.beNil();
                });
                
                it(@"should not have any warnings", ^{
                    expect(machoLazyBindInfo.warnings).to.equal(@[]);
                });
                
                it(@"should have the correct number of commands", ^{
                    expect(machoLazyBindCommands.count).to.equal(dyldInfoLazyBindCommands.count);
                });
                
                it(@"should be parsed correctly", ^{
                    for (NSUInteger i=0; i<MIN(machoLazyBindCommands.count, dyldInfoLazyBindCommands.count); i++) {
                        MKBindCommand *command = machoLazyBindCommands[i];
                        NSString *machoBindCommandDescription = [[NSString alloc] initWithFormat:@"0x%.4" MK_VM_PRIXOFFSET " %@", command.nodeOffset, command.description];
                        
                        expect(machoBindCommandDescription).to.equal(dyldInfoLazyBindCommands[i]);
                    }
                });
                
                it(@"should result in the correct number of bindings", ^{
                    expect(machoLazyBindings.count).to.equal(dyldInfoLazyBindings.count);
                });
                
                it(@"should result in the correct bindings", ^{
                    for (NSUInteger i=0; i<MIN(machoLazyBindings.count, dyldInfoLazyBindings.count); i++) {
                        MKBindActionBind *binding = machoLazyBindings[i];
                        
                        expect(binding.segment.name).to.equal(dyldInfoLazyBindings[i][@"segment"]);
                        expect(binding.section.value.name).to.equal(dyldInfoLazyBindings[i][@"section"]);
                        expect([NSString stringWithFormat:@"0x%.8" MK_VM_PRIXADDR "", binding.address]).to.equal(dyldInfoLazyBindings[i][@"address"]);
                        expect([NSString stringWithFormat:@"0x%.4" MK_VM_PRIXADDR "", binding.nodeVMAddress - machoLazyBindInfo.nodeVMAddress]).to.equal(dyldInfoLazyBindings[i][@"index"]);
                        expect(binding.symbolName).to.equal(dyldInfoLazyBindings[i][@"symbol"]);
                        expect([binding.sourceLibrary.name rangeOfString:dyldInfoLazyBindings[i][@"dylib"]].location).toNot.equal(NSNotFound);
                    }
                });
            });
            
            //----------------------------------------------------------------//
            describe(@"exports", ^{
                NSArray<NSDictionary*> *dyldInfoExports = otoolArchitecture.exports;
                MKExportsInfo *machoExportsInfo = macho.exportsInfo.value;
                
                if (machoExportsInfo == nil)
                    return; // TODO - Check if the image should have exports.
                
                NSArray *machoExports = machoExportsInfo.exports;
                
                it(@"should exist", ^{
                    expect(machoExports).toNot.beNil();
                });
                
                it(@"should have the correct number of exports", ^{
                    expect(machoExports.count).to.equal(dyldInfoExports.count);
                });
                
                it(@"should result in the correct exports", ^{
                    for (NSUInteger i=0; i<MIN(machoExports.count, dyldInfoExports.count); i++) {
                        MKExport *export = machoExports[i];
                        
                        expect(export.description).to.equal(dyldInfoExports[i]);
                    }
                });
            });
            
            //----------------------------------------------------------------//
            describe(@"function starts", ^{
                NSArray<NSDictionary*> *dyldFunctionStarts = otoolArchitecture.functionStarts;
                MKFunctionStarts *machoFunctionStarts = macho.functionStarts.value;
                
                if (machoFunctionStarts == nil)
                    return; // TODO - Check if the image should have function starts.
                
                NSArray *machoFunctions = machoFunctionStarts.functions;
                
                it(@"should exist", ^{
                    expect(machoFunctionStarts).toNot.beNil();
                });
                
                it(@"should have the correct number of functions", ^{
                    expect(machoFunctions.count).to.equal(dyldFunctionStarts.count);
                });
                
                it(@"should result in the correct functions", ^{
                    for (NSUInteger i=0; i<MIN(machoFunctions.count, dyldFunctionStarts.count); i++) {
                        MKFunction *function = machoFunctions[i];
                        
                        expect(function.description).to.equal(dyldFunctionStarts[i][@"address"]);
                        expect(function.thumb).to.equal(dyldFunctionStarts[i][@"thumb"]);
                    }
                });
            });
            
            //----------------------------------------------------------------//
            describe(@"data in code", ^{
                NSArray<NSDictionary*> *dyldDataInCodeEntries = otoolArchitecture.dataInCodeEntries;
                MKDataInCode *machoDataInCode = macho.dataInCode.value;
                
                if (machoDataInCode == nil)
                    return; // TODO - Check if the image should have DICE.
                
                NSArray *machoDataInCodeEntries = machoDataInCode.entries;
                
                it(@"should exist", ^{
                    expect(machoDataInCodeEntries).toNot.beNil();
                });
                
                it(@"should have the correct number of entries", ^{
                    expect(machoDataInCodeEntries.count).to.equal(dyldDataInCodeEntries.count);
                });
                
                it(@"should result in the correct entries", ^{
                    for (NSUInteger i=0; i<MIN(machoDataInCodeEntries.count, dyldDataInCodeEntries.count); i++) {
                        MKDataInCodeEntry *entry = machoDataInCodeEntries[i];
                        
                        expect([NSString stringWithFormat:@"0x%.8" PRIx32 "", entry.offset]).to.equal(dyldDataInCodeEntries[i][@"offset"]);
                        expect([NSString stringWithFormat:@"%" PRIi16 "", entry.length]).to.equal(dyldDataInCodeEntries[i][@"length"]);
                        expect([NSString stringWithFormat:@"0x%.4" PRIx16 "", entry.kind]).to.equal(dyldDataInCodeEntries[i][@"kind"]);
                    }
                });
            });

            //----------------------------------------------------------------//
            describe(@"Symbols", ^{
                NSArray<NSDictionary*> *nmDarwinSymbols = otoolArchitecture.darwinSymbols;
                NSArray<NSDictionary*> *nmBSDSymbols = otoolArchitecture.bsdSymbols;
                NSAssert(nmDarwinSymbols.count == nmBSDSymbols.count, @"NM produced mismatched symbol count between darwin and BSD formats");
                MKSymbolTable *machoSymbolTable = macho.symbolTable.value;
                
                if (machoSymbolTable == nil)
                    return; // TODO - Check if the image should have a symbol table.
                
                NSArray *machoSymbols = machoSymbolTable.symbols;
                
                it(@"should exist", ^{
                    expect(machoSymbols).toNot.beNil();
                });
                
                it(@"should have the correct number of symbols", ^{
                    expect(machoSymbols.count).to.equal(nmDarwinSymbols.count);
                });
                
                it(@"should result in the correct symbols", ^{
                    for (NSUInteger i=0; i<MIN(machoSymbols.count, nmDarwinSymbols.count); i++) {
                        // llvm-nm does not parse STABs when the output format
                        // is set to 'darwin' (see the comment in NMUtil.m).
                        // The solution is to run llvm-nm in 'bsd' format and
                        // 'darwin' format.  BSD format correctly parses and
                        // outputs STABs.  We use the BSD format output for
                        // STABs and the darwin format output for everything
                        // else.
                        NSDictionary *nmDarwinSymbol = nmDarwinSymbols[i];
                        NSDictionary *nmBSDSymbol = nmBSDSymbols[i];
                        MKSymbol *machoSymbol = machoSymbols[i];
                        
                        // If llvm-nm in BSD format recorded the type as '-',
                        // then it is a STAB.
                        if ([nmBSDSymbol[@"type"] isEqualToString:@"-"]) {
                            expect([machoSymbol isKindOfClass:MKDebugSymbol.class]).to.beTruthy();
                            if ([machoSymbol isKindOfClass:MKDebugSymbol.class] == NO)
                                continue;
                            
                            MKDebugSymbol *machoDebugSymbol = (MKDebugSymbol*)machoSymbol;
                            NSDictionary *nmSTABInfo = nmBSDSymbol[@"stabInfo"];
                            
                            expect(machoDebugSymbol.name.description).to.equal(nmBSDSymbol[@"name"]);
                            expect([[MKNodeFieldSTABType.sharedInstance.formatter stringForObjectValue:[machoDebugSymbol valueForKey:@"stabType"]] substringFromIndex:2]).to.equal(nmSTABInfo[@"type"]);
                        }
                        // Otherwise, it's a regular symbol.
                        else {
                            expect([machoSymbol isKindOfClass:MKRegularSymbol.class]).to.beTruthy();
                            if ([machoSymbol isKindOfClass:MKRegularSymbol.class] == NO)
                                continue;
                            
                            MKRegularSymbol *machoRegularSymbol = (MKRegularSymbol*)machoSymbol;
                            
                            expect([machoRegularSymbol.name.description stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]).to.equal(nmDarwinSymbol[@"name"]);
                            expect(machoRegularSymbol.section.description).to.equal(nmDarwinSymbol[@"section"]);
                            expect([MKNodeFieldSymbolType.sharedInstance.formatter stringForObjectValue:[machoRegularSymbol valueForKey:@"symbolType"]]).to.equal(nmDarwinSymbol[@"type"]);
                            expect(machoRegularSymbol.external).to.equal([nmDarwinSymbol[@"external"] boolValue]);
                            expect(machoRegularSymbol.privateExternal).to.equal([nmDarwinSymbol[@"privateExternal"] boolValue]);
                        }
                    }
                });
            });
            
            //----------------------------------------------------------------//
            describe(@"Indirect Symbols", ^{
                NSArray<NSDictionary*> *otoolIndirectSymbols = otoolArchitecture.indirectSymbols;
                MKIndirectSymbolTable *machoIndirectSymbolTable = macho.indirectSymbolTable.value;
                
                if (machoIndirectSymbolTable == nil)
                    return; // TODO - Check if the image should have a symbol table.
                
                NSArray *machoIndirectSymbols = machoIndirectSymbolTable.indirectSymbols;
                
                it(@"should exist", ^{
                    expect(machoIndirectSymbolTable).toNot.beNil();
                });
                
                it(@"should have the correct number of entries", ^{
                    expect(machoIndirectSymbolTable.indirectSymbols.count).to.equal(otoolIndirectSymbols.count);
                });
                
                it(@"should result in the correct entries", ^{
                    for (NSUInteger i=0; i<MIN(machoIndirectSymbolTable.indirectSymbols.count, otoolIndirectSymbols.count); i++) {
                        MKIndirectSymbol *machoIndirectSymbol = machoIndirectSymbols[i];
                        NSDictionary *otoolEntry = otoolIndirectSymbols[i];
                        
                        expect(machoIndirectSymbol.section.value.name).to.equal(otoolEntry[@"section"]);
                        expect(machoIndirectSymbol.local).to.equal([otoolEntry[@"local"] boolValue]);
                        expect(machoIndirectSymbol.absolute).to.equal([otoolEntry[@"absolute"] boolValue]);
                        expect(machoIndirectSymbol.index).to.equal([otoolEntry[@"index"] unsignedIntValue]);
                    }
                });
            });
            
            //----------------------------------------------------------------//
            describe(@"_objc", ^{
                // Skip images that use legacy OBJC ABI.
                // TODO - Better heuristic that does not skip 32-bit images
                //        for embedded targets.
                if (mk_architecture_uses_64bit_abi(macho.architecture) == false)
                    return;
                
                NSDictionary *objcInfo = otoolArchitecture.objcInfo;
                
                describe(@"imageinfo", ^{
                    NSDictionary *otoolImageInfo = objcInfo[@"__objc_imageinfo"];
                    if (otoolImageInfo == nil)
                        return;
                    
                    MKObjCImageInfoSection *section = [macho sectionsWithName:@"__objc_imageinfo" inSegment:nil].firstObject;
                    it(@"should exist", ^{
                        expect(section).toNot.beNil();
                        expect(section).beInstanceOf(MKObjCImageInfoSection.class);
                    });
                    if ([section isKindOfClass:MKObjCImageInfoSection.class] == NO) return;
                    
                    MKObjCImageInfo *info = section.imageInfo.value;
                    it(@"should contain the image info", ^{
                        expect(info).toNot.beNil();
                    });
                    if (info == nil) return;
                    
                    MKNodeDescription *layout = info.layout;
                    
                    for (NSString *key in otoolImageInfo)
                    {
                        it([NSString stringWithFormat:@"%@ should have the correct value", key], ^{
                            NSString *value = nil;
                            for (MKNodeField *field in layout.fields) {
                                if ([field.name isEqualToString:key]) {
                                    value = [field formattedDescriptionForNode:info];
                                    break;
                                }
                            }
                            expect(value).to.equal(otoolImageInfo[key]);
                        });
                    }
                });
                
                describe(@"classlist", ^{
                    NSDictionary *otoolClassList = objcInfo[@"__objc_classlist"];
                    if (otoolClassList == nil)
                        return;
                    
                    MKObjCClassListSection *section = [macho sectionsWithName:@"__objc_classlist" inSegment:nil].firstObject;
                    it(@"should exist", ^{
                        expect(section).toNot.beNil();
                        expect(section).beInstanceOf(MKObjCClassListSection.class);
                    });
                    if ([section isKindOfClass:MKObjCClassListSection.class] == NO) return;
                    
                    it(@"should contain the expected number of classes", ^{
                        expect(section.elements.count).to.equal(otoolClassList.count);
                    });
                    
                    for (MKPointerNode *ptr in section.elements)
                    {
                        describe([NSString stringWithFormat:@"%.16" MK_VM_PRIxADDR "", ptr.nodeVMAddress], ^{
                            NSDictionary *otoolClass = otoolClassList[ [NSString stringWithFormat:@"%.16" MK_VM_PRIxADDR "", ptr.nodeVMAddress] ];
                            MKObjCClass *cls = ptr.pointee.value;
                            
                            it(@"should be a valid entry", ^{
                                expect(otoolClass).toNot.beNil();
                            });
                            it(@"should be a valid pointer", ^{
                                expect(cls).toNot.beNil();
                            });
                            
                            if (otoolClass == nil || cls == nil)
                                return;
                            
                            void (^checkClass)(MKObjCClass*, NSDictionary*);
                            __block void (^checkClassRecursive)(MKObjCClass*, NSDictionary*);
                            checkClass = ^(MKObjCClass *cls, NSDictionary *otoolClass) {
                                
                                it(@"should have the correct isa", ^{
                                    if ([otoolClass[@"isa"] isKindOfClass:NSDictionary.class]) {
                                        MKObjCClass *metaClass = cls.metaClass.pointee.value;
                                        expect(metaClass).toNot.beNil();
                                        
                                        if (metaClass)
                                            describe(@"metaclass", ^{
                                                checkClassRecursive(metaClass, otoolClass[@"isa"]);
                                            });
                                    } else if ([otoolClass[@"isa"] isKindOfClass:NSString.class]) {
                                        expect([NSString stringWithFormat:@"0x%" MK_VM_PRIxADDR "", cls.metaClass.address]).to.equal(otoolClass[@"isa"]);
                                    } else {
                                        // otool didn't parse the meta class
                                    }
                                });
                                
                                it(@"should have the correct superclass", ^{
                                    expect([NSString stringWithFormat:@"0x%" MK_VM_PRIxADDR "", cls.superClass.address]).to.equal(otoolClass[@"superclass"]);
                                });
                                
                                it(@"should have the correct cache", ^{
                                    expect([NSString stringWithFormat:@"0x%" MK_VM_PRIxADDR "", cls.cache.address]).to.equal(otoolClass[@"cache"]);
                                    expect(cls.mask).to.equal(0);
                                    expect(cls.occupied).to.equal(0);
                                });
                                
                                describe(@"data", ^{
                                    MKObjCClassData *clsData = cls.classData.pointee.value;
                                    NSDictionary *otoolClassData = otoolClass[@"data"];
                                    
                                    it(@"should exist", ^{
                                        expect(clsData).toNot.beNil();
                                    });
                                    
                                    it(@"should have the correct flags", ^{
                                        expect([NSString stringWithFormat:@"0x%" PRIx32 "", clsData.flags]).to.equal(otoolClassData[@"flags"]);
                                    });
                                    
                                    it(@"should have the correct instanceStart", ^{
                                        expect([NSString stringWithFormat:@"%" PRIu32 "", clsData.instanceStart]).to.equal(otoolClassData[@"instanceStart"]);
                                    });
                                    
                                    it(@"should have the correct instanceSize", ^{
                                        expect([NSString stringWithFormat:@"%" PRIu32 "", clsData.instanceSize]).to.equal(otoolClassData[@"instanceSize"]);
                                    });
                                    
                                    it(@"should have thecorrect ivarLayout", ^{
                                        expect([NSString stringWithFormat:@"0x%" MK_VM_PRIxADDR "", clsData.ivarLayout.address]).to.equal(otoolClassData[@"ivarLayout"]);
                                    });
                                    
                                    it(@"should have the correct name", ^{
                                        expect(clsData.name.pointee.value.string).to.equal(otoolClassData[@"name"]);
                                    });
                                    
                                    void (^checkElementList)(NSString*, NSDictionary*, MKObjCElementList*, void (^)(NSDictionary*, id))
                                    = ^(NSString *name, NSDictionary *otoolElementList, MKObjCElementList *elementList, void (^checker)(NSDictionary*, id)) {
                                        describe(name, ^{
                                            if ([otoolElementList isKindOfClass:NSDictionary.class]) {
                                                it(@"should exist", ^{
                                                    expect(elementList).toNot.beNil();
                                                });
                                            } else if (otoolElementList == nil) {
                                                it(@"should not be present", ^{
                                                    expect(elementList).to.beNil();
                                                });
                                                
                                                return;
                                            } else {
                                                return;
                                            }
                                            
                                            it(@"should have the correct entity size", ^{
                                                expect([NSString stringWithFormat:@"%" PRIu32 "", elementList.entsize]).to.equal(otoolElementList[@"entsize"]);
                                            });
                                            
                                            it(@"should have the correct count", ^{
                                                expect([NSString stringWithFormat:@"%" PRIu32 "", elementList.count]).to.equal(otoolElementList[@"count"]);
                                            });
                                            
                                            NSArray *otoolElements = otoolElementList[@"elements"];
                                            
                                            for (NSUInteger i = 0; i < MIN(elementList.elements.count, otoolElements.count); i++)
                                            describe([NSString stringWithFormat:@"%lu", i], ^{
                                                NSDictionary *otoolElement = otoolElements[i];
                                                id element = elementList.elements[i];
                                                
                                                checker(otoolElement, element);
                                            });
                                        });
                                    };
                                    
                                    checkElementList(@"baseMethods", otoolClassData[@"baseMethods"], clsData.methods.pointee.value, ^(NSDictionary *otoolElement, MKObjCClassMethod *element) {
                                        it(@"should have the correct name", ^{
                                            expect(element.name.pointee.value.string).to.equal(otoolElement[@"name"]);
                                        });
                                        
                                        it(@"should have the correct type", ^{
                                            expect(element.types.pointee.value.string).to.equal(otoolElement[@"type"]);
                                        });
                                    });
                                    
                                    checkElementList(@"ivars", otoolClassData[@"ivars"], clsData.ivars.pointee.value, ^(NSDictionary *otoolElement, MKObjCClassIVar *element) {
                                        it(@"should have the correct name", ^{
                                            expect(element.name.pointee.value.string).to.equal(otoolElement[@"name"]);
                                        });
                                        
                                        it(@"should have the correct type", ^{
                                            expect(element.type.pointee.value.string).to.equal(otoolElement[@"type"]);
                                        });
                                        
                                        it(@"should have the correct offset", ^{
                                            expect([NSString stringWithFormat:@"%" PRIu64 "", element.offset]).to.equal(otoolElement[@"offset"]);
                                        });
                                        
                                        it(@"should have the correct size", ^{
                                            expect([NSString stringWithFormat:@"%" PRIu32 "", element.size]).to.equal(otoolElement[@"offset"]);
                                        });
                                    });
                                    
                                    checkElementList(@"baseProperties", otoolClassData[@"baseProperties"], clsData.properties.pointee.value, ^(NSDictionary *otoolElement, MKObjCClassProperty *element) {
                                        it(@"should have the correct name", ^{
                                            expect(element.name.pointee.value.string).to.equal(otoolElement[@"name"]);
                                        });
                                        
                                        it(@"should have the correct attributes", ^{
                                            expect(element.attributes.pointee.value.string).to.equal(otoolElement[@"attributes"]);
                                        });
                                    });
                                    
                                    describe(@"baseProtocols", ^{
                                        NSDictionary *otoolProtocolList = otoolClassData[@"baseProtocols"];
                                        MKObjCProtocolList *clsProtocolList = clsData.protocols.pointee.value;
                                        
                                        if ([otoolProtocolList isKindOfClass:NSDictionary.class] == NO) {
                                            it(@"should not be present", ^{
                                                expect(clsProtocolList).to.beNil();
                                            });
                                            
                                            return;
                                        } else {
                                            it(@"should exist", ^{
                                                expect(clsProtocolList).toNot.beNil();
                                            });
                                        }
                                        
                                        it(@"should have the correct count", ^{
                                            expect([NSString stringWithFormat:@"%" PRIu64 "", clsProtocolList.count]).to.equal(otoolProtocolList[@"count"]);
                                        });
                                        
                                        NSArray *otoolProtocols = otoolProtocolList[@"elements"];
                                        
                                        for (NSUInteger i = 0; i < MIN(clsProtocolList.elements.count, otoolProtocols.count); i++)
                                        describe([NSString stringWithFormat:@"%lu", i], ^{
                                            NSDictionary *otoolProtocol = otoolProtocols[i];
                                            MKObjCProtocol *protocol = clsProtocolList.elements[i].pointee.value;
                                        
                                            it(@"should have the correct name", ^{
                                                expect(protocol.mangledName.pointee.value.string).to.equal(otoolProtocol[@"name"]);
                                            });
                                            
                                            checkElementList(@"instanceMethods", otoolProtocol[@"instanceMethods"], protocol.instanceMethods.pointee.value, ^(NSDictionary *otoolElement, MKObjCClassMethod *element) {
                                                it(@"should have the correct name", ^{
                                                    expect(element.name.pointee.value.string).to.equal(otoolElement[@"name"]);
                                                });
                                                
                                                it(@"should have the correct type", ^{
                                                    expect(element.types.pointee.value.string).to.equal(otoolElement[@"type"]);
                                                });
                                            });
                                            
                                            checkElementList(@"classMethods", otoolProtocol[@"classMethods"], protocol.classMethods.pointee.value, ^(NSDictionary *otoolElement, MKObjCClassMethod *element) {
                                                it(@"should have the correct name", ^{
                                                    expect(element.name.pointee.value.string).to.equal(otoolElement[@"name"]);
                                                });
                                                
                                                it(@"should have the correct type", ^{
                                                    expect(element.types.pointee.value.string).to.equal(otoolElement[@"type"]);
                                                });
                                            });
                                            
                                            checkElementList(@"optionalInstanceMethods", otoolProtocol[@"optionalInstanceMethods"], protocol.optionalInstanceMethods.pointee.value, ^(NSDictionary *otoolElement, MKObjCClassMethod *element) {
                                                it(@"should have the correct name", ^{
                                                    expect(element.name.pointee.value.string).to.equal(otoolElement[@"name"]);
                                                });
                                                
                                                it(@"should have the correct type", ^{
                                                    expect(element.types.pointee.value.string).to.equal(otoolElement[@"type"]);
                                                });
                                            });
                                            
                                            checkElementList(@"optionalClassMethods", otoolProtocol[@"optionalClassMethods"], protocol.optionalClassMethods.pointee.value, ^(NSDictionary *otoolElement, MKObjCClassMethod *element) {
                                                it(@"should have the correct name", ^{
                                                    expect(element.name.pointee.value.string).to.equal(otoolElement[@"name"]);
                                                });
                                                
                                                it(@"should have the correct type", ^{
                                                    expect(element.types.pointee.value.string).to.equal(otoolElement[@"type"]);
                                                });
                                            });
                                            
                                            checkElementList(@"instanceProperties", otoolProtocol[@"instanceProperties"], protocol.instanceProperties.pointee.value, ^(NSDictionary *otoolElement, MKObjCClassProperty *element) {
                                                it(@"should have the correct name", ^{
                                                    expect(element.name.pointee.value.string).to.equal(otoolElement[@"name"]);
                                                });
                                                
                                                it(@"should have the correct attributes", ^{
                                                    expect(element.attributes.pointee.value.string).to.equal(otoolElement[@"attributes"]);
                                                });
                                            });
                                        });
                                    });
                                });
                                
                            };
                            checkClassRecursive = checkClass;
                            
                            describe(@"class", ^{
                                checkClass(cls, otoolClass);
                            });
                        });
                    }
                });
                
            });
        });
        
        
    });
}
SpecEnd
