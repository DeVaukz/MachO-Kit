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
                
                if (machoRebaseInfo == nil)
                    return; // TODO - Check if the image should have rebase info.
                
                NSArray *machoRebaseCommands = machoRebaseInfo.commands;
                NSArray *machoRebaseFixups = machoRebaseInfo.fixups;
                
                it(@"should exist", ^{
                    expect(machoRebaseCommands).toNot.beNil();
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
                
                it(@"should result int the correct number of fixups", ^{
                    expect(machoRebaseFixups.count).to.equal(dyldInfoRebaseFixups.count);
                });
                
                it(@"should result in the correct fixups", ^{
                    for (NSUInteger i=0; i<MIN(machoRebaseFixups.count, dyldInfoRebaseFixups.count); i++) {
                        MKFixup *fixup = machoRebaseFixups[i];
                        
                        expect(fixup.segment.name).to.equal(dyldInfoRebaseFixups[i][@"segment"]);
                        expect(fixup.section.name).to.equal(dyldInfoRebaseFixups[i][@"section"]);
                        expect([NSString stringWithFormat:@"0x%.8" MK_VM_PRIXADDR "", fixup.address]).to.equal(dyldInfoRebaseFixups[i][@"address"]);
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
