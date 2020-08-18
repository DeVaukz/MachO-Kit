//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             macho_load_command_spec.m
//|
//|             D.V.
//|             Copyright (c) 2014-2015 D.V. All rights reserved.
//|             Copyright (c) 2020-2020 Milen Dzhumerov. All rights reserved.
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

    #define FRAMEWORK_PARAM_STRING "-framework"
    #define CORE_FOUNDATION_STRING "CoreFoundation"
    
    describe(@"LC_LINKER_OPTION", ^{
        describe(@"with valid command", ^{
            struct _dummy {
                struct mach_header_64 header;
                struct {
                    struct __attribute__((packed)) {
                        struct linker_option_command cmd;
                        char framework_param[sizeof(FRAMEWORK_PARAM_STRING)];
                        char cf_param[sizeof(CORE_FOUNDATION_STRING)];
                    } lc_linker_option;
                } commands;
            };
            struct _dummy *dummy = malloc(sizeof(*dummy));
            
            struct mach_header_64 *header = &dummy->header;
            header->magic = MH_MAGIC_64;
            header->filetype = MH_EXECUTE;
            header->sizeofcmds = sizeof(dummy->commands);
            
            struct linker_option_command *lc_linker_option = &dummy->commands.lc_linker_option.cmd;
            lc_linker_option->cmd = LC_LINKER_OPTION;
            lc_linker_option->cmdsize = sizeof(dummy->commands.lc_linker_option);
            lc_linker_option->count = 2;
            snprintf(dummy->commands.lc_linker_option.framework_param, sizeof(dummy->commands.lc_linker_option.framework_param), FRAMEWORK_PARAM_STRING);
            snprintf(dummy->commands.lc_linker_option.cf_param, sizeof(dummy->commands.lc_linker_option.cf_param), CORE_FOUNDATION_STRING);
            
            mk_macho_t *macho = malloc(sizeof(*macho));
            NSParameterAssert(mk_macho_init_with_slide(NULL, "Test", 0, (mk_vm_address_t)dummy, memory_map, macho) == MK_ESUCCESS);
            mk_load_command_t *load_command = malloc(sizeof(*load_command));
            NSParameterAssert(mk_load_command_init(macho, (struct load_command*)&dummy->commands.lc_linker_option, load_command) == MK_ESUCCESS);
            
            it(@"gets number of strings", ^{
                uint32_t nstrings = mk_load_command_linker_option_get_nstrings(load_command);
                expect(nstrings).to.equal(2);
            });
            
            it(@"copies strings", ^{
                char buffer[512];
                bzero(buffer, sizeof(buffer));
                size_t copy_result = mk_load_command_linker_option_copy_string(load_command, 0, buffer, sizeof(buffer));
                expect(copy_result).to.equal(strlen(FRAMEWORK_PARAM_STRING));
                copy_result = mk_load_command_linker_option_copy_string(load_command, 1, buffer, sizeof(buffer));
                expect(copy_result).to.equal(strlen(CORE_FOUNDATION_STRING));
                // request out of bounds of index
                copy_result = mk_load_command_linker_option_copy_string(load_command, 2, buffer, sizeof(buffer));
                expect(copy_result).to.equal(0);
            });
            
            it(@"partial copy to small buffer", ^{
                char buffer[7];
                size_t copy_result = mk_load_command_linker_option_copy_string(load_command, 0, buffer, sizeof(buffer));
                expect(copy_result).to.equal(6 /* # chars without NULL char */);
                int cmp_result = strncmp(buffer, "-frame", MIN(sizeof(buffer), strlen("-frame") + 1));
                expect(cmp_result).to.equal(0);
            });
            
            it(@"copies description", ^{
                char description_buffer[512];
                bzero(description_buffer, sizeof(description_buffer));
                size_t copy_result = mk_type_copy_description(load_command, description_buffer, sizeof(description_buffer));
                expect(copy_result).notTo.equal(0);
                
                char expected_buffer[512];
                snprintf(expected_buffer, sizeof(expected_buffer), "<LC_LINKER_OPTION %p> {\n\t-framework\n\tCoreFoundation\n}", load_command);
                
                int cmp = strcmp(description_buffer, expected_buffer);
                expect(cmp).to.equal(0);
            });
            
            it(@"enumerates using block", ^{
                __block uint32_t count = 0;
                mk_load_command_linker_option_enumerate_strings(load_command, ^(const char *string, uint32_t index, bool *__unused stop) {
                    const char *expected_string = (index == 0 ? "-framework" : "CoreFoundation");
                    int cmp = strcmp(string, expected_string);
                    expect(cmp).to.equal(0);
                    ++count;
                });
                
                expect(count).to.equal(2);
            });
            
            it(@"enumerates using block with stop", ^{
                __block uint32_t count = 0;
                mk_load_command_linker_option_enumerate_strings(load_command, ^(const char *string, uint32_t index, bool *__unused stop) {
                    int cmp = strcmp(string, "-framework");
                    expect(cmp).to.equal(0);
                    expect(index).to.equal(0);
                    ++count;
                    *stop = true;
                });
                
                expect(count).to.equal(1);
            });
            
            it(@"returns required buffer size", ^{
                size_t string_length = mk_load_command_linker_option_copy_string(load_command, 0, NULL, 0);
                expect(string_length).notTo.equal(0);
                size_t buffer_size = string_length + 1 /* NULL char */;
                char *buffer = malloc(buffer_size);
                size_t actual_string_length = mk_load_command_linker_option_copy_string(load_command, 0, buffer, buffer_size);
                expect(actual_string_length).to.equal(string_length);
                expect(strncmp(buffer, "-framework", buffer_size)).to.equal(0);
                free(buffer);
            });
        });
        
        describe(@"with invalid string count", ^{
            struct _dummy {
                struct mach_header_64 header;
                struct {
                    struct __attribute__((packed)) {
                        struct linker_option_command cmd;
                        char framework_param[sizeof(FRAMEWORK_PARAM_STRING)];
                        char cf_param[sizeof(CORE_FOUNDATION_STRING)];
                    } lc_linker_option;
                } commands;
            };
            struct _dummy *dummy = malloc(sizeof(*dummy));
            
            struct mach_header_64 *header = &dummy->header;
            header->magic = MH_MAGIC_64;
            header->filetype = MH_EXECUTE;
            header->sizeofcmds = sizeof(dummy->commands);
            
            struct linker_option_command *lc_linker_option = &dummy->commands.lc_linker_option.cmd;
            lc_linker_option->cmd = LC_LINKER_OPTION;
            lc_linker_option->cmdsize = sizeof(dummy->commands.lc_linker_option);
            // Declared string count larger than actual number of strings (2)
            lc_linker_option->count = 3;
            snprintf(dummy->commands.lc_linker_option.framework_param, sizeof(dummy->commands.lc_linker_option.framework_param), FRAMEWORK_PARAM_STRING);
            snprintf(dummy->commands.lc_linker_option.cf_param, sizeof(dummy->commands.lc_linker_option.cf_param), CORE_FOUNDATION_STRING);
            
            mk_macho_t *macho = malloc(sizeof(*macho));
            NSParameterAssert(mk_macho_init_with_slide(NULL, "Test", 0, (mk_vm_address_t)dummy, memory_map, macho) == MK_ESUCCESS);
            mk_load_command_t *load_command = malloc(sizeof(*load_command));
            NSParameterAssert(mk_load_command_init(macho, (struct load_command*)&dummy->commands.lc_linker_option, load_command) == MK_ESUCCESS);
            
            it(@"handles out of bounds string", ^{
                char buffer[512];
                size_t copy_result = mk_load_command_linker_option_copy_string(load_command, 2, buffer, sizeof(buffer));
                expect(copy_result).to.equal(0);
            });
        });
        
        describe(@"with non-null terminated string", ^{
            struct _dummy {
                struct mach_header_64 header;
                struct {
                    struct __attribute__((packed)) {
                        struct linker_option_command cmd;
                        char string[16];
                    } lc_linker_option;
                } commands;
            };
            struct _dummy *dummy = malloc(sizeof(*dummy));
            
            struct mach_header_64 *header = &dummy->header;
            header->magic = MH_MAGIC_64;
            header->filetype = MH_EXECUTE;
            header->sizeofcmds = sizeof(dummy->commands);
            
            struct linker_option_command *lc_linker_option = &dummy->commands.lc_linker_option.cmd;
            // Fill whole command with 'a' chars _without_ a terminating NULL char
            memset(&dummy->commands.lc_linker_option, 'a', sizeof(struct linker_option_command));
            
            lc_linker_option->cmd = LC_LINKER_OPTION;
            lc_linker_option->cmdsize = sizeof(dummy->commands.lc_linker_option);
            lc_linker_option->count = 1;
            
            mk_macho_t *macho = malloc(sizeof(*macho));
            NSParameterAssert(mk_macho_init_with_slide(NULL, "Test", 0, (mk_vm_address_t)dummy, memory_map, macho) == MK_ESUCCESS);
            mk_load_command_t *load_command = malloc(sizeof(*load_command));
            NSParameterAssert(mk_load_command_init(macho, (struct load_command*)&dummy->commands.lc_linker_option, load_command) == MK_ESUCCESS);
            
            it(@"correctly fails to copy string", ^{
                char buffer[512];
                size_t copy_result = mk_load_command_linker_option_copy_string(load_command, 0, buffer, sizeof(buffer));
                expect(copy_result).to.equal(0);
            });
        });
    });
    
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
            NSParameterAssert(mk_macho_init_with_slide(NULL, "Test", 0, (mk_vm_address_t)dummy, memory_map, macho) == MK_ESUCCESS);
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
            NSParameterAssert(mk_macho_init_with_slide(NULL, "Test", 0, (mk_vm_address_t)dummy, memory_map, macho) == MK_ESUCCESS);
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
            NSParameterAssert(mk_macho_init_with_slide(NULL, "Test", 0, (mk_vm_address_t)dummy, memory_map, macho) == MK_ESUCCESS);
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
            NSParameterAssert(mk_macho_init_with_slide(NULL, "Test", 0, (mk_vm_address_t)dummy, memory_map, macho) == MK_ESUCCESS);
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
