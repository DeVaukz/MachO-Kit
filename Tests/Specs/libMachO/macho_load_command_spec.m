//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             macho_load_command_spec.m
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

SpecBegin(macho_load_command)
{
    mk_memory_map_self_t *memory_map = malloc(sizeof(*memory_map));
    mk_error_t err = mk_memory_map_self_init(NULL, memory_map);
    if (err != MK_ESUCCESS) return;
    
    //------------------------------------------------------------------------//
    describe(@"LC_ID_DYLINKER", ^{
        describe(@"with a valid NULL terminated string", ^{
        #define TEST_STRING "/usr/lib/dyld"
        #define TEST_STRING_LEN 13
            struct _dummy {
                struct mach_header_64 header;
                struct {
                    struct {
                        struct dylinker_command cmd;
                        char dylinker[TEST_STRING_LEN + 1];
                    } lc_id_dylinker;
                } commands;
            };
            struct _dummy *dummy = malloc(sizeof(*dummy));
            
            struct mach_header_64 *header = &dummy->header;
            header->magic = MH_MAGIC_64;
            header->filetype = MH_EXECUTE;
            header->sizeofcmds = sizeof(dummy->commands);
            
            struct dylinker_command *lc_id_dylinker = &dummy->commands.lc_id_dylinker.cmd;
            lc_id_dylinker->cmd = LC_ID_DYLINKER;
            lc_id_dylinker->cmdsize = sizeof(dummy->commands.lc_id_dylinker);
            lc_id_dylinker->name.offset = offsetof(typeof(dummy->commands.lc_id_dylinker), dylinker);
            snprintf(dummy->commands.lc_id_dylinker.dylinker, sizeof(dummy->commands.lc_id_dylinker.dylinker), TEST_STRING);
            
            mk_macho_t *macho = malloc(sizeof(*macho));
            NSParameterAssert(mk_macho_init(NULL, "Test", 0, (mk_vm_address_t)dummy, memory_map, macho) == MK_ESUCCESS);
            mk_load_command_t *load_command = malloc(sizeof(*load_command));
            NSParameterAssert(mk_load_command_init(macho, (struct load_command*)&dummy->commands.lc_id_dylinker, load_command) == MK_ESUCCESS);
            
            it(@"should copy native", ^{
                struct dylinker_command *copy = malloc(sizeof(dummy->commands.lc_id_dylinker));
                expect(mk_load_command_id_dylinker_copy_native(load_command, copy, sizeof(dummy->commands.lc_id_dylinker.dylinker))).to.equal(MK_ESUCCESS);
                //expect(memcmp(copy, lc_id_dylinker, sizeof(dummy->commands.lc_id_dylinker))).to.equal(0);
            });
            
            it(@"should copy the name (with null termination) into a matching sized buffer", ^{
                char *buffer = malloc(TEST_STRING_LEN + 1);
                expect(mk_load_command_id_dylinker_copy_name(load_command, buffer, TEST_STRING_LEN + 1)).to.equal(TEST_STRING_LEN);
                expect(strncmp(buffer, TEST_STRING, TEST_STRING_LEN + 1)).to.equal(0);
                // Should be NULL terminated
                expect(buffer[TEST_STRING_LEN]).to.equal(0);
            });
            
            it(@"should copy part of the name (with null termination) into a short buffer", ^{
                char *buffer = malloc(5);
                expect(mk_load_command_id_dylinker_copy_name(load_command, buffer, 5)).to.equal(4);
                expect(strncmp(buffer, TEST_STRING, 4)).to.equal(0);
                // Should be NULL terminated
                expect(buffer[4]).to.equal(0);
            });
            
            it(@"should copy part of the name (with null termination) into a large buffer", ^{
                char *buffer = malloc(TEST_STRING_LEN + TEST_STRING_LEN);
                expect(mk_load_command_id_dylinker_copy_name(load_command, buffer, TEST_STRING_LEN + TEST_STRING_LEN)).to.equal(TEST_STRING_LEN);
                expect(strncmp(buffer, TEST_STRING, TEST_STRING_LEN + TEST_STRING_LEN)).to.equal(0);
                // Should be NULL terminated
                expect(buffer[TEST_STRING_LEN]).to.equal(0);
            });
        #undef TEST_STRING_LEN
        #undef TEST_STRING
        });
        
        describe(@"with a non-NULL terminated string", ^{
        #define TEST_STRING "/usr/lib/dyld"
        #define TEST_STRING_LEN 13
            struct _dummy {
                struct mach_header_64 header;
                struct __attribute__((__packed__)) {
                    struct __attribute__((__packed__)) {
                        struct dylinker_command cmd;
                        char dylinker[TEST_STRING_LEN];
                    } lc_id_dylinker;
                    struct {
                        char guard[31];
                        char term;
                    } extra;
                } commands;
            };
            struct _dummy *dummy = malloc(sizeof(*dummy));
            
            struct mach_header_64 *header = &dummy->header;
            header->magic = MH_MAGIC_64;
            header->filetype = MH_EXECUTE;
            header->sizeofcmds = sizeof(dummy->commands);
            
            struct dylinker_command *lc_id_dylinker = &dummy->commands.lc_id_dylinker.cmd;
            lc_id_dylinker->cmd = LC_ID_DYLINKER;
            lc_id_dylinker->cmdsize = sizeof(dummy->commands.lc_id_dylinker);
            lc_id_dylinker->name.offset = offsetof(typeof(dummy->commands.lc_id_dylinker), dylinker);
            memcpy(dummy->commands.lc_id_dylinker.dylinker, TEST_STRING, TEST_STRING_LEN);
            memset(dummy->commands.extra.guard, 0xA, sizeof(dummy->commands.extra.guard));
            dummy->commands.extra.term = '\0';
            
            mk_macho_t *macho = malloc(sizeof(*macho));
            NSParameterAssert(mk_macho_init(NULL, "Test", 0, (mk_vm_address_t)dummy, memory_map, macho) == MK_ESUCCESS);
            mk_load_command_t *load_command = malloc(sizeof(*load_command));
            NSParameterAssert(mk_load_command_init(macho, (struct load_command*)&dummy->commands.lc_id_dylinker, load_command) == MK_ESUCCESS);
            
            /*it(@"should copy native", ^{
             
            });*/
            
            it(@"should copy the name (with null termination) into a matching sized buffer", ^{
                char *buffer = malloc(TEST_STRING_LEN);
                expect(mk_load_command_id_dylinker_copy_name(load_command, buffer, TEST_STRING_LEN)).to.equal(TEST_STRING_LEN - 1);
                expect(strncmp(buffer, TEST_STRING, TEST_STRING_LEN - 1)).to.equal(0);
                // Should be NULL terminated
                expect(buffer[TEST_STRING_LEN - 1]).to.equal(0);
            });
            
            it(@"should copy part of the name (with null termination) into a short buffer", ^{
                char *buffer = malloc(5);
                expect(mk_load_command_id_dylinker_copy_name(load_command, buffer, 5)).to.equal(4);
                expect(strncmp(buffer, TEST_STRING, 4)).to.equal(0);
                // Should be NULL terminated
                expect(buffer[4]).to.equal(0);
            });
            
            it(@"should copy part of the name (with null termination) into a large buffer", ^{
                char *buffer = malloc(TEST_STRING_LEN + TEST_STRING_LEN);
                expect(mk_load_command_id_dylinker_copy_name(load_command, buffer, TEST_STRING_LEN + TEST_STRING_LEN)).to.equal(TEST_STRING_LEN);
                expect(strncmp(buffer, TEST_STRING, TEST_STRING_LEN + TEST_STRING_LEN)).to.equal(0);
                // Should be NULL terminated
                expect(buffer[TEST_STRING_LEN]).to.equal(0);
            });
        #undef TEST_STRING_LEN
        #undef TEST_STRING
        });
        
        describe(@"with a string oofset that is outside the load command", ^{
        #define TEST_STRING "/usr/lib/dyld"
        #define TEST_STRING_LEN 13
            struct _dummy {
                struct mach_header_64 header;
                struct {
                    struct {
                        struct dylinker_command cmd;
                        char dylinker[TEST_STRING_LEN + 1];
                    } lc_id_dylinker;
                } commands;
            };
            struct _dummy *dummy = malloc(sizeof(*dummy));
            
            struct mach_header_64 *header = &dummy->header;
            header->magic = MH_MAGIC_64;
            header->filetype = MH_EXECUTE;
            header->sizeofcmds = sizeof(dummy->commands);
            
            struct dylinker_command *lc_id_dylinker = &dummy->commands.lc_id_dylinker.cmd;
            lc_id_dylinker->cmd = LC_ID_DYLINKER;
            lc_id_dylinker->cmdsize = sizeof(dummy->commands.lc_id_dylinker);
            lc_id_dylinker->name.offset = sizeof(dummy->commands.lc_id_dylinker);
            snprintf(dummy->commands.lc_id_dylinker.dylinker, sizeof(dummy->commands.lc_id_dylinker.dylinker), TEST_STRING);
            
            mk_macho_t *macho = malloc(sizeof(*macho));
            NSParameterAssert(mk_macho_init(NULL, "Test", 0, (mk_vm_address_t)dummy, memory_map, macho) == MK_ESUCCESS);
            mk_load_command_t *load_command = malloc(sizeof(*load_command));
            NSParameterAssert(mk_load_command_init(macho, (struct load_command*)&dummy->commands.lc_id_dylinker, load_command) == MK_ESUCCESS);
            
            /*it(@"should copy native", ^{
                
            });*/
            
            it(@"should refuse to copy the name", ^{
                char *buffer = malloc(TEST_STRING_LEN + 1);
                expect(mk_load_command_id_dylinker_copy_name(load_command, buffer, TEST_STRING_LEN + 1)).to.equal(0);
            });
        #undef TEST_STRING_LEN
        #undef TEST_STRING
        });
    });
    
    //------------------------------------------------------------------------//
    describe(@"LC_BUILD_VERSION", ^{
        describe(@"that is valid with two tools", ^{
            struct _dummy {
                struct mach_header_64 header;
                struct {
                    struct {
                        struct build_version_command cmd;
                        struct build_tool_version clang;
                        struct build_tool_version ld;
                    } lc_build_version;
                } commands;
            };
            struct _dummy *dummy = malloc(sizeof(*dummy));
            
            struct mach_header_64 *header = &dummy->header;
            header->magic = MH_MAGIC_64;
            header->filetype = MH_EXECUTE;
            header->sizeofcmds = sizeof(dummy->commands);
            
            struct build_version_command *lc_build_version = &dummy->commands.lc_build_version.cmd;
            lc_build_version->cmd = LC_BUILD_VERSION;
            lc_build_version->cmdsize = sizeof(dummy->commands.lc_build_version);
            lc_build_version->platform = PLATFORM_MACOS;
            lc_build_version->minos = 0xA0100;
            lc_build_version->sdk = 0xA0D00;
            lc_build_version->ntools = 2;
            
            struct build_tool_version *lc_build_version_clang = &dummy->commands.lc_build_version.clang;
            lc_build_version_clang->tool = TOOL_CLANG;
            lc_build_version_clang->version = 900;
            
            struct build_tool_version *lc_build_version_ld = &dummy->commands.lc_build_version.ld;
            lc_build_version_ld->tool = TOOL_LD;
            lc_build_version_ld->version = 64;
            
            mk_macho_t *macho = malloc(sizeof(*macho));
            NSParameterAssert(mk_macho_init(NULL, "Test", 0, (mk_vm_address_t)dummy, memory_map, macho) == MK_ESUCCESS);
            mk_load_command_t *load_command = malloc(sizeof(*load_command));
            NSParameterAssert(mk_load_command_init(macho, (struct load_command*)&dummy->commands.lc_build_version, load_command) == MK_ESUCCESS);
            
            it(@"should copy native", ^{
                __block struct build_version_command copy;
                expect(mk_load_command_build_version_copy_native(load_command, &copy)).to.equal(MK_ESUCCESS);
                expect(memcmp(&copy, lc_build_version, sizeof(*lc_build_version))).to.equal(0);
            });
            
            it(@"should return the correct platform", ^{
                expect(mk_load_command_build_version_get_platform(load_command)).to.equal(PLATFORM_MACOS);
            });
            
            it(@"should return the correct minos", ^{
                expect(mk_load_command_build_version_get_minos_primary(load_command)).to.equal(10);
                expect(mk_load_command_build_version_get_minos_major(load_command)).to.equal(1);
                expect(mk_load_command_build_version_get_minos_minor(load_command)).to.equal(0);
                
                char buffer[256] = { 0 };
                mk_load_command_build_version_copy_minos_string(load_command, buffer, sizeof(buffer));
                NSString *minos = [NSString stringWithCString:buffer encoding:NSASCIIStringEncoding];
                expect(minos).to.equal(@"10.1.0");
            });
            
            it(@"should return the correct sdk", ^{
                expect(mk_load_command_build_version_get_sdk_primary(load_command)).to.equal(10);
                expect(mk_load_command_build_version_get_sdk_major(load_command)).to.equal(13);
                expect(mk_load_command_build_version_get_sdk_minor(load_command)).to.equal(0);
                
                char buffer[256] = { 0 };
                mk_load_command_build_version_copy_sdk_string(load_command, buffer, sizeof(buffer));
                NSString *minos = [NSString stringWithCString:buffer encoding:NSASCIIStringEncoding];
                expect(minos).to.equal(@"10.13.0");
            });
            
            it(@"should return the correct number of tools", ^{
                expect(mk_load_command_build_version_get_ntools(load_command)).to.equal(2);
            });
            
            it(@"should iterate over all tools", ^{
                uint32_t count = 0;
                struct build_tool_version *previous = NULL;
                while ((previous = mk_load_command_build_version_get_next_tool(load_command, previous, NULL)))
                    count++;
                
                expect(count).to.equal(mk_load_command_build_version_get_ntools(load_command));
            });
            
            describe(@"the first tool", ^{
                mk_load_command_build_tool_version_t *tool = malloc(sizeof(*tool));
                struct build_tool_version *mach_tool = mk_load_command_build_version_get_next_tool(load_command, NULL, NULL);
                mk_error_t err = mk_load_command_build_version_build_tool_version_init(load_command, mach_tool, tool);
                it(@"should initialize", ^{
                    expect(err).to.equal(MK_ESUCCESS);
                });
                if (err != MK_ESUCCESS) return;
                
                it(@"should copy native", ^{
                    __block struct build_tool_version copy;
                    expect(mk_load_command_build_version_build_tool_version_copy_native(tool, &copy)).to.equal(MK_ESUCCESS);
                    expect(memcmp(&copy, lc_build_version_clang, sizeof(*lc_build_version_clang))).to.equal(0);
                });
                
                it(@"should return the correct tool", ^{
                    expect(mk_load_command_build_version_build_tool_version_get_tool(tool)).to.equal(TOOL_CLANG);
                });
                
                it(@"should return the correct version", ^{
                    expect(mk_load_command_build_version_build_tool_version_get_version(tool)).to.equal(900);
                });
            });
        });
            
        
    });
}
SpecEnd
