//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             macho_image_spec.m
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

#include <dlfcn.h>
#include <mach-o/dyld.h>
#include <mach-o/dyld_images.h>

SpecBegin(macho_image)
{
    mk_memory_map_self_t *memory_map = malloc(sizeof(*memory_map));
    mk_error_t err = mk_memory_map_self_init(NULL, memory_map);
    it(@"should have a map", ^{
        expect(err).to.equal(MK_ESUCCESS);
    });
    if (err != MK_ESUCCESS) return;
    
    for (uint32_t i=0; i<_dyld_image_count(); i++)
    {
        mk_vm_address_t loadAddress = (mk_vm_address_t)_dyld_get_image_header(i);
        intptr_t slide = _dyld_get_image_vmaddr_slide(i);
        const char * name = _dyld_get_image_name(i);
        
        describe([[[NSString stringWithCString:name encoding:NSUTF8StringEncoding] componentsSeparatedByString:@"/"] lastObject], ^{
            mk_macho_t *image = malloc(sizeof(*image));
            mk_error_t err = mk_macho_init_with_slide(NULL, name, slide, loadAddress, memory_map, image);
            it(@"should initialize", ^{
                expect(err).to.equal(MK_ESUCCESS);
            });
            if (err != MK_ESUCCESS) return;
            
            it(@"should have the correct memory map", ^{
                expect(mk_type_equal(mk_macho_get_memory_map(image).memory_map, memory_map)).to.beTruthy();
            });
            
        #if TARGET_RT_64_BIT
            it(@"should have the correct data model", ^{
                expect(mk_type_equal(mk_macho_get_data_model(image).data_model, mk_data_model_lp64().data_model)).to.beTruthy();
            });
        #endif
            
            it(@"should have the correct slide", ^{
                expect(mk_macho_get_slide(image)).to.equal(slide);
            });
            
            it(@"should have the correct name", ^{
                expect(strcmp(mk_macho_get_name(image), name)).to.equal(0);
            });
            
        #if TARGET_RT_64_BIT
            it(@"should be 64-bit", ^{
                expect(mk_macho_is_64_bit(image)).to.beTruthy();
            });
        #endif
            
            //----------------------------------------------------------------//
            describe(@"header", ^{
                struct mach_header *mach_header = (struct mach_header*)loadAddress;
                
                it(@"should return the correct CPU type", ^{
                    expect(mk_macho_get_cpu_type(image)).to.equal(mach_header->cputype);
                });
                
                it(@"should return the correct CPU subtype", ^{
                    expect(mk_macho_get_cpu_subtype(image)).to.equal(mach_header->cpusubtype);
                });
                
                it(@"should return the correct filetype", ^{
                    expect(mk_macho_get_filetype(image)).to.equal(mach_header->filetype);
                });
                
                it(@"should return the correct ncmds", ^{
                    expect(mk_macho_get_ncmds(image)).to.equal(mach_header->ncmds);
                });
                
                it(@"should return the correct ncmds", ^{
                    expect(mk_macho_get_ncmds(image)).to.equal(mach_header->ncmds);
                });
                
                it(@"should return the correct sizeofcmds", ^{
                    expect(mk_macho_get_sizeofcmds(image)).to.equal(mach_header->sizeofcmds);
                });
                
                it(@"should return the correct flags", ^{
                    expect(mk_macho_get_flags(image)).to.equal(mach_header->flags);
                });
            });
            
            //----------------------------------------------------------------//
            it(@"should have the correct number of load commands", ^{
                uint32_t count = 0;
                struct load_command *previous = NULL;
                while ((previous = mk_macho_next_command(image, previous, NULL)))
                    count++;
                
                expect(count).to.equal(mk_macho_get_ncmds(image));
            });
            
            it(@"should find specific load commands", ^{
                uint32_t count = 0;
                struct load_command *previous = NULL;
                while ((previous = mk_macho_next_command_type(image, previous, LC_UUID, NULL)))
                    count++;
                
                expect(count).to.equal(1);
            });
            
            it(@"should find and return specific load commands", ^{
                struct load_command *uuid_load_command = mk_macho_find_command(image, LC_UUID, NULL);
                expect(uuid_load_command).toNot.beNull();
                if (uuid_load_command == NULL) return;
                expect(uuid_load_command->cmd).to.equal(LC_UUID);
            });
            
            describe(@"load command", ^{
                uint32_t count = 0;
                struct load_command *mach_load_command = NULL;
                while ((mach_load_command = mk_macho_next_command(image, mach_load_command, NULL)))
                describe([@(count++) description], ^{
                    mk_load_command_t *load_command = malloc(sizeof(*load_command));
                    mk_error_t err = mk_load_command_init(image, mach_load_command, load_command);
                    it(@"should initialize", ^{
                        expect(err).to.equal(MK_ESUCCESS);
                    });
                    if (err != MK_ESUCCESS) return;
                    
                    it(@"should correctly initialize a copy", ^{
                        __block mk_load_command_t copy;
                        mk_error_t err = mk_load_command_copy(load_command, &copy);
                        expect(err).to.equal(MK_ESUCCESS);
                        if (err == MK_ESUCCESS) return;
                        
                        expect(mk_type_equal(load_command, &copy)).to.beTruthy();
                    });
                    
                    it(@"should return the correct Mach-O object", ^{
                        expect(mk_type_equal(mk_load_command_get_macho(load_command).type, image)).to.beTruthy();
                    });
                    
                    it(@"should return the correct id", ^{
                        expect(mk_load_command_id(load_command)).to.equal(mach_load_command->cmd);
                    });
                    
                    it(@"should return the correct size", ^{
                        expect(mk_load_command_size(load_command)).to.equal(mach_load_command->cmdsize);
                    });
                    
                    // Specific load command tests.
                    switch (mk_load_command_id(load_command)) {
                        case LC_SEGMENT_64:
                        {
                            struct segment_command_64 *mach_segment64_load_command = (struct segment_command_64*)mach_load_command;
                            
                            it(@"should return the correct nsects", ^{
                                expect(mk_load_command_segment_64_get_nsects(load_command)).to.equal(mach_segment64_load_command->nsects);
                            });
                            
                            it(@"should have the correct number of sections", ^{
                                uint32_t count = 0;
                                struct section_64 *previous = NULL;
                                while ((previous = mk_load_command_segment_64_next_section(load_command, previous, NULL)))
                                    count++;
                                expect(count).to.equal(mk_load_command_segment_64_get_nsects(load_command));
                            });
                            
                            describe(@"section command", ^{
                                uint32_t count = 0;
                                struct section_64 *mach_segment64_section_command = NULL;
                                while ((mach_segment64_section_command = mk_load_command_segment_64_next_section(load_command, mach_segment64_section_command, NULL)))
                                describe([@(count++) description], ^{
                                    mk_load_command_section_64_t *section = malloc(sizeof(*section));
                                    mk_error_t err = mk_load_command_segment_64_section_init(load_command, mach_segment64_section_command, section);
                                    it(@"should initialize", ^{
                                        expect(err).to.equal(MK_ESUCCESS);
                                    });
                                    if (err != MK_ESUCCESS) return;
                                });
                            });
                            
                            break;
                        }
                        default:
                            break;
                    }
                });
            });
            
            //----------------------------------------------------------------//
            describe(@"segment", ^{
                struct load_command *mach_load_command = NULL;
                __block mk_vm_address_t host_address;
                while ((mach_load_command = mk_macho_next_command_type(image, mach_load_command, LC_SEGMENT_64, &host_address))) {
                    mk_load_command_t *load_command = malloc(sizeof(*load_command));
                    mk_error_t err = mk_load_command_init(image, mach_load_command, load_command);
                    if (err != MK_ESUCCESS) continue;
                    
                    char segname[16] = { 0 };
                    mk_load_command_segment_64_copy_name(load_command, segname);
                    boolean_t isPageZero = !strcmp(segname, SEG_PAGEZERO);
                    
                    describe([NSString stringWithCString:segname encoding:NSASCIIStringEncoding], ^{
                        mk_segment_t *segment = malloc(sizeof(*segment));
                        mk_error_t err = mk_segment_init(load_command, segment);
                        it(@"should initialize", ^{
                            if (isPageZero) {
                                expect(err).to.equal(MK_EUNAVAILABLE);
                            } else {
                                expect(err).to.equal(MK_ESUCCESS);
                            }
                        });
                        if (err != MK_ESUCCESS) return;
                        
                        it(@"should return the correct Mach-O object", ^{
                            expect(mk_type_equal(mk_segment_get_macho(segment).type, image)).to.beTruthy();
                        });
                        
                        it(@"should return the correct load command", ^{
                            expect(mk_type_equal(mk_segment_get_load_command(segment).type, load_command)).to.beTruthy();
                        });
                        
                        it(@"should return a mapping", ^{
                            expect(mk_segment_get_mapping(segment).memory_object).toNot.beNull();
                        });
                        
                        it(@"should return values that match the load command", ^{
                        #if TARGET_RT_64_BIT
                            expect(mk_segment_get_vmaddr(segment)).to.equal(mk_load_command_segment_64_get_vmaddr(load_command));
                            expect(mk_segment_get_vmsize(segment)).to.equal(mk_load_command_segment_64_get_vmsize(load_command));
                            expect(mk_segment_get_fileoff(segment)).to.equal(mk_load_command_segment_64_get_fileoff(load_command));
                            expect(mk_segment_get_filesize(segment)).to.equal(mk_load_command_segment_64_get_filesize(load_command));
                            expect(mk_segment_get_maxprot(segment)).to.equal(mk_load_command_segment_64_get_maxprot(load_command));
                            expect(mk_segment_get_initprot(segment)).to.equal(mk_load_command_segment_64_get_initprot(load_command));
                            expect(mk_segment_get_nsects(segment)).to.equal(mk_load_command_segment_64_get_nsects(load_command));
                            expect(mk_segment_get_flags(segment)).to.equal(mk_load_command_segment_64_get_flags(load_command));
                        #endif
                        });
                        
                        describe(@"sections", ^{
                            mk_macho_section_command_ptr mach_section_command = (mk_macho_section_command_ptr)NULL;
                            __block mk_vm_address_t host_address;
                            while ((mach_section_command = mk_segment_next_section(segment, mach_section_command, &host_address)).any)
                            describe([NSString stringWithCString:mach_section_command.section_64->sectname encoding:NSASCIIStringEncoding], ^{
                                mk_section_t *section = malloc(sizeof(*section));
                                mk_error_t err = mk_section_init_wih_mach_section_command(segment, mach_section_command, section);
                                it(@"should initialize", ^{
                                    expect(err).to.equal(MK_ESUCCESS);
                                });
                                if (err != MK_ESUCCESS) return;
                                
                                it(@"should return the correct Mach-O object", ^{
                                    expect(mk_type_equal(mk_section_get_macho(section).type, image)).to.beTruthy();
                                });
                                
                                it(@"should return the correct Segment object", ^{
                                    expect(mk_type_equal(mk_section_get_segment(section).type, segment)).to.beTruthy();
                                });
                                
                                it(@"should initialize a mapping", ^{
                                    mk_memory_object_t mapping;
                                    mk_error_t err = mk_section_init_mapping(section, &mapping);
                                    
                                    // Test this special case.
                                    if (mk_section_get_size(section) == 0) {
                                        expect(err).to.equal(MK_ENOT_FOUND);
                                        return;
                                    } else {
                                        expect(err).to.equal(MK_ESUCCESS);
                                        if (err != MK_ESUCCESS) return;
                                    }
                                    
                                    // Make sure this does not crash
                                    uint8_t *ptr = (uint8_t*)mk_memory_object_address(&mapping);
                                    __unused uint8_t byte = *ptr;
                                    
                                    mk_memory_object_free(&mapping);
                                });
                                
                                it(@"should return values that match the section command", ^{
                                #if TARGET_RT_64_BIT
                                    expect(mk_section_get_addr(section)).to.equal(mach_section_command.section_64->addr);
                                    expect(mk_section_get_size(section)).to.equal(mach_section_command.section_64->size);
                                    expect(mk_section_get_offset(section)).to.equal(mach_section_command.section_64->offset);
                                    expect(mk_section_get_align(section)).to.equal(mach_section_command.section_64->align);
                                    expect(mk_section_get_reloff(section)).to.equal(mach_section_command.section_64->reloff);
                                    expect(mk_section_get_nreloc(section)).to.equal(mach_section_command.section_64->nreloc);
                                    expect(mk_section_get_type(section)).to.equal(mach_section_command.section_64->flags & SECTION_TYPE);
                                    expect(mk_section_get_attributes(section)).to.equal(mach_section_command.section_64->flags & SECTION_ATTRIBUTES);
                                    expect(mk_section_get_reserved1(section)).to.equal(mach_section_command.section_64->reserved1);
                                    expect(mk_section_get_reserved2(section)).to.equal(mach_section_command.section_64->reserved2);
                                #endif
                                });
                            });
                        });
                    });
                }
            });
            
            //----------------------------------------------------------------//
            describe(@"string table", ^{
                mk_segment_t *linkedit = malloc(sizeof(*linkedit));
                
                // Find the __LINKEDIT
                struct load_command *mach_load_command = NULL;
                while ((mach_load_command = mk_macho_next_command_type(image, mach_load_command, LC_SEGMENT_64, NULL))) {
                    if (!strncmp(((struct segment_command_64*)mach_load_command)->segname, SEG_LINKEDIT, 16)) {
                        mk_error_t err = mk_segment_init_with_mach_load_command(image, mach_load_command, linkedit);
                        if (err != MK_ESUCCESS) return;
                    }
                }
                
                mk_string_table_t *string_table = malloc(sizeof(*string_table));
                mk_error_t err = mk_string_table_init_with_segment(linkedit, string_table);
                it(@"should initialize", ^{
                    expect(err).to.equal(MK_ESUCCESS);
                });
                if (err != MK_ESUCCESS) return;
                
                it(@"should return the correct Mach-O object", ^{
                    expect(mk_type_equal(mk_string_table_get_macho(string_table).type, image)).to.beTruthy();
                });
                
                it(@"should return the correct segment", ^{
                    expect(mk_type_equal(mk_string_table_get_segment(string_table).type, linkedit)).to.beTruthy();
                });
                
                it(@"should enumerate strings", ^{
                    const char *previous = NULL;
                    mk_vm_address_t target_address = 0;
                    uint32_t offset = 0;
                    while ((previous = mk_string_table_next_string(string_table, previous, &offset, &target_address))) {
                        expect(target_address).to.equal((uintptr_t)previous);
                        // Nothing else to do here except make sure it doesn't crash
                    }
                });
            });
            
            //----------------------------------------------------------------//
            describe(@"symbol table", ^{
                mk_segment_t *linkedit = malloc(sizeof(*linkedit));
                
                // Find the __LINKEDIT
                struct load_command *mach_load_command = NULL;
                while ((mach_load_command = mk_macho_next_command_type(image, mach_load_command, LC_SEGMENT_64, NULL))) {
                    if (!strncmp(((struct segment_command_64*)mach_load_command)->segname, SEG_LINKEDIT, 16)) {
                        mk_error_t err = mk_segment_init_with_mach_load_command(image, mach_load_command, linkedit);
                        if (err != MK_ESUCCESS) return;
                    }
                }
                
                mk_symbol_table_t *symbol_table = malloc(sizeof(*symbol_table));
                mk_error_t err = mk_symbol_table_init_with_segment(linkedit, symbol_table);
                it(@"should initialize", ^{
                    expect(err).to.equal(MK_ESUCCESS);
                });
                if (err != MK_ESUCCESS) return;
                
                it(@"should return the correct Mach-O object", ^{
                    expect(mk_type_equal(mk_symbol_table_get_macho(symbol_table).type, image)).to.beTruthy();
                });
                
                it(@"should return the correct segment", ^{
                    expect(mk_type_equal(mk_symbol_table_get_segment(symbol_table).type, linkedit)).to.beTruthy();
                });
                
                it(@"should have the correct number of symbols", ^{
                    uint32_t count = 0;
                    mk_macho_nlist_ptr previous = (mk_macho_nlist_ptr)NULL;
                    while ((previous = mk_symbol_table_next_mach_symbol(symbol_table, previous, NULL, NULL)).any)
                        count++;
                    
                    expect(count).to.equal(mk_symbol_table_get_symbol_count(symbol_table));
                });
                
                describe(@"symbols", ^{
                    uint32_t count = 0;
                    mk_macho_nlist_ptr mach_symbol = (mk_macho_nlist_ptr)NULL;
                    while ((mach_symbol = mk_symbol_table_next_mach_symbol(symbol_table, mach_symbol, NULL, NULL)).any)
                    describe([@(count++) description], ^{
                        mk_symbol_t *symbol = malloc(sizeof(*symbol));
                        mk_error_t err = mk_symbol_init(symbol_table, mach_symbol, symbol);
                        it(@"should initialize", ^{
                            expect(err).to.equal(MK_ESUCCESS);
                        });
                        if (err != MK_ESUCCESS) return;
                        
                        it(@"should return the correct Mach-O object", ^{
                            expect(mk_type_equal(mk_symbol_get_macho(symbol).type, image)).to.beTruthy();
                        });
                        
                        it(@"should return the correct symbol table", ^{
                            expect(mk_type_equal(mk_symbol_get_symbol_table(symbol).type, symbol_table)).to.beTruthy();
                        });
                        
                        it(@"should return values that match the nlist entry", ^{
                        #if TARGET_RT_64_BIT
                            expect(mk_symbol_get_strx(symbol)).to.equal(mach_symbol.nlist_64->n_un.n_strx);
                            expect(mk_symbol_get_type(symbol)).to.equal(mach_symbol.nlist_64->n_type);
                            expect(mk_symbol_get_sect(symbol)).to.equal(mach_symbol.nlist_64->n_sect);
                            expect(mk_symbol_get_desc(symbol)).to.equal(mach_symbol.nlist_64->n_desc);
                            expect(mk_symbol_get_value(symbol)).to.equal(mach_symbol.nlist_64->n_value);
                        #endif
                        });
                    });
                });
            });
            
            //----------------------------------------------------------------//
            describe(@"indirect symbol table", ^{
                mk_segment_t *linkedit = malloc(sizeof(*linkedit));
                
                // Find the __LINKEDIT
                struct load_command *mach_load_command = NULL;
                while ((mach_load_command = mk_macho_next_command_type(image, mach_load_command, LC_SEGMENT_64, NULL))) {
                    if (!strncmp(((struct segment_command_64*)mach_load_command)->segname, SEG_LINKEDIT, 16)) {
                        mk_error_t err = mk_segment_init_with_mach_load_command(image, mach_load_command, linkedit);
                        if (err != MK_ESUCCESS) return;
                    }
                }
                
                mk_indirect_symbol_table_t *indirect_symbol_table = malloc(sizeof(*indirect_symbol_table));
                mk_error_t err = mk_indirect_symbol_table_init_with_segment(linkedit, indirect_symbol_table);
                it(@"should initialize", ^{
                    expect(err).to.equal(MK_ESUCCESS);
                });
                if (err != MK_ESUCCESS) return;
                
                it(@"should return the correct Mach-O object", ^{
                    expect(mk_type_equal(mk_indirect_symbol_table_get_macho(indirect_symbol_table).type, image)).to.beTruthy();
                });
                
                it(@"should return the correct segment", ^{
                    expect(mk_type_equal(mk_indirect_symbol_table_get_segment(indirect_symbol_table).type, linkedit)).to.beTruthy();
                });
                
                it(@"should have the correct number of entires", ^{
                    __block uint32_t count = 0;
                    mk_indirect_symbol_table_enumerate_entries(indirect_symbol_table, 0, ^(__unused uint32_t value, __unused uint32_t index, __unused mk_vm_address_t target_address) {
                        count++;
                    });
                    
                    expect(count).to.equal(mk_indirect_symbol_table_get_entry_count(indirect_symbol_table));
                });
            });
        });
    }
    
}
SpecEnd
