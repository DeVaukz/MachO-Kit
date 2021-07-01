//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKFatSpec.m
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

SpecBegin(MKFat)
{
    NSArray *frameworks = [NSFileManager allExecutableURLs:MKFrameworkTypeAll];
    
    for (NSURL *frameworkURL in frameworks)
    describe([frameworkURL lastPathComponent], ^{
        NSError *error = nil;
        __block MKFatBinary *binary = nil;
        
        Binary *executable = [Binary binaryAtURL:frameworkURL];
        if (executable == nil || executable.fatHeader == nil)
            return;
        
        MKMemoryMap *map = [MKMemoryMap memoryMapWithContentsOfFile:frameworkURL error:&error];
        beforeAll(^{
            expect(map).toNot.beNil();
            expect(error).to.beNil();
        });
        if (map == nil) return;
        
        binary = [[MKFatBinary alloc] initWithMemoryMap:map error:&error];
        beforeAll(^{
            expect(binary).toNot.beNil();
            expect(error).to.beNil();
        });
        if (binary == nil) return;
        
        it(@"Should have the correct magic value", ^{
            uint32_t expectedValue;
            [[NSScanner scannerWithString:executable.fatHeader[@"fat_magic"]] scanHexInt:&expectedValue];
            expect(binary.magic).to.equal(expectedValue);
        });
        
        it(@"Should have the correct nfat_arch value", ^{
            expect(binary.nfat_arch).to.equal([executable.fatHeader[@"nfat_arch"] intValue]);
        });
        
        it(@"Should have the correct number of architectures", ^{
            expect(binary.architectures.count).to.equal([(NSDictionary*)executable.fatHeader[@"architecture"] count]);
        });
        
        for (MKFatArch *architecture in binary.architectures)
        describe(architecture.description, ^{
            // Find the corresponding architecture in fatHeader[@"architecture"].
            NSDictionary *otoolArchitecture;
            {
                // This is sort of hacky but its the only way find our control values.
                for (NSDictionary *arch in [executable.fatHeader[@"architecture"] allValues]) {
                    if ([arch[@"offset"] integerValue] == architecture.offset) {
                        otoolArchitecture = arch;
                        break;
                    }
                }
                
                expect(otoolArchitecture).toNot.beNil();
                if (otoolArchitecture == nil) return;
            }
            
            it(@"Should have the correct CPU type", ^{
                expect(mk_architecture_get_cpu_type(architecture.architecture)).to.equal([otoolArchitecture[@"cputype"] integerValue]);
            });
            
            it(@"Should have the correct CPU subtype", ^{
                expect(mk_architecture_get_cpu_subtype(architecture.architecture)).to.equal([otoolArchitecture[@"cpusubtype"] integerValue]);
            });
            
            // TODO - Feature flags / capabilities
            
            it(@"Should have the correct offset", ^{
                expect(architecture.offset).to.equal([otoolArchitecture[@"offset"] integerValue]);
            });
            
            it(@"Should have the correct size", ^{
                expect(architecture.size).to.equal([otoolArchitecture[@"size"] integerValue]);
            });
            
            it(@"Should have the correct alignment", ^{
                expect(architecture.align).to.equal([otoolArchitecture[@"align"] integerValue]);
            });
        });
    });
}
SpecEnd
