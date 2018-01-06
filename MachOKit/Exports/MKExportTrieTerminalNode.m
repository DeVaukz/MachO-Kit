//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKExportTrieTerminalNode.m
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

#import "MKExportTrieTerminalNode.h"
#import "NSError+MK.h"
#import "MKLEB.h"
#import "MKCString.h"
#import "MKExport.h"

//----------------------------------------------------------------------------//
@implementation MKExportTrieTerminalNode

//|++++++++++++++++++++++++++++++++++++|//
+ (uint32_t)canInstantiateWithTerimalSize:(uint64_t)terminalSize contents:(uint8_t*)contents
{
#pragma unused(contents)
	return (self == MKExportTrieTerminalNode.class && terminalSize > 0) ? 20 : 0;
}

//|++++++++++++++++++++++++++++++++++++|//
- (BOOL)_parseTerminalInformationAtOffset:(mk_vm_offset_t)offset error:(NSError**)error
{
    // Read the flags
    {
        NSError *ULEBError = nil;
        size_t flagsULEBSize = 0;
        
        if (!MKULEBRead(self, offset, &_flags, &flagsULEBSize, &ULEBError)) {
            MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_EINTERNAL_ERROR underlyingError:ULEBError description:@"Could not read flags."];
            return NO;
        }
        
        offset += flagsULEBSize;
    }
    
	if (_flags & EXPORT_SYMBOL_FLAGS_REEXPORT)
	{
		// Re-exported symbols do not contain a symbol offset.  Instead, the ordinal of
		// the library where the symbol is originally defined follows the export flags.
		
		// Read the library ordinal
        {
            NSError *ULEBError = nil;
            size_t ordinalULEBSize = 0;
            
            if (!MKULEBRead(self, offset, &_offset, &ordinalULEBSize, &ULEBError)) {
                MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_EINTERNAL_ERROR underlyingError:ULEBError description:@"Could not read ordinal."];
                return NO;
            }
            
            offset += ordinalULEBSize;
        }
		
		// Re-exported symbols may be exported with a different name than the original
		// symbol.  In this case, a string containing the original symbol name follows
		// the library ordinal.  Otherwise, there is a NULL terminator indicating that
		// the symbol will be re-exported with its original name.
		
        uint8_t character;
        
        // Read the first byte
        {
            NSError *memoryMapError = nil;
            
            if ([self.memoryMap copyBytesAtOffset:offset fromAddress:self.nodeContextAddress into:&character length:sizeof(uint8_t) requireFull:YES error:&memoryMapError] < sizeof(uint8_t)) {
                MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_EINTERNAL_ERROR underlyingError:memoryMapError description:@"Could not read imported name."];
                return NO;
            }
        }
        
		if ((char)character != '\0') {
            NSError *importedNameError = nil;
            
			_importedName = [[MKCString alloc] initWithOffset:offset fromParent:self error:&importedNameError];
			if (_importedName == nil) {
				MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_EINTERNAL_ERROR underlyingError:importedNameError description:@"Could not read  imported name"];
				return NO;
			}
			
            offset += _importedName.nodeSize;
        } else {
            offset += sizeof(uint8_t);
        }
	}
	else
	{
		switch (_flags & EXPORT_SYMBOL_FLAGS_KIND_MASK) {
			case EXPORT_SYMBOL_FLAGS_KIND_REGULAR:
			case EXPORT_SYMBOL_FLAGS_KIND_THREAD_LOCAL:
			case EXPORT_SYMBOL_FLAGS_KIND_ABSOLUTE:
			{
                NSError *ULEBError = nil;
                size_t offsetULEBSize = 0;
                
                if (!MKULEBRead(self, offset, &_offset, &offsetULEBSize, &ULEBError)) {
                    MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_EINTERNAL_ERROR underlyingError:ULEBError description:@"Could not read offset."];
                    return NO;
                }
                
                offset += offsetULEBSize;
				break;
			}
			default:
				MK_PUSH_WARNING(flags, MK_EINVALID_DATA, @"Unknown export symbol kind (flags=0x%" PRIx64 ").", _flags);
				break;
		}
		
		if (_flags & EXPORT_SYMBOL_FLAGS_STUB_AND_RESOLVER)
		{
			// dyld only accepts the EXPORT_SYMBOL_FLAGS_STUB_AND_RESOLVER flag if the
			// export kind is EXPORT_SYMBOL_FLAGS_KIND_REGULAR
			if ((_flags & EXPORT_SYMBOL_FLAGS_KIND_MASK) == EXPORT_SYMBOL_FLAGS_KIND_REGULAR) {
				NSError *ULEBError = nil;
				size_t resolverULEBSize = 0;
				
				if (!MKULEBRead(self, offset, &_resolver, &resolverULEBSize, &ULEBError)) {
					MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_EINTERNAL_ERROR underlyingError:ULEBError description:@"Could not read resolver offset."];
					return NO;
				}
				
				offset += resolverULEBSize;
			} else {
				MK_PUSH_WARNING(resolver, MK_EINVALID_DATA, @"Only an export with kind EXPORT_SYMBOL_FLAGS_KIND_REGULAR may include the EXPORT_SYMBOL_FLAGS_STUB_AND_RESOLVER flag (flags=0x%" PRIx64 ").");
			}
		}
	}
	
	return YES;
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Trie Node Values
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@synthesize flags = _flags;
@synthesize resolver = _resolver;
@synthesize importedName = _importedName;

//|++++++++++++++++++++++++++++++++++++|//
- (uint64_t)offset
{
	if ((self.flags & EXPORT_SYMBOL_FLAGS_REEXPORT) == 0)
		return _offset;
	else
		return 0;
}

//|++++++++++++++++++++++++++++++++++++|//
- (int64_t)ordinal
{
	if ((self.flags & EXPORT_SYMBOL_FLAGS_REEXPORT) != 0)
		return (int64_t)_offset;
	else
		return 0;
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
	MKNodeFieldBuilder *flags = [MKNodeFieldBuilder
		builderWithProperty:MK_PROPERTY(flags)
		type:MKNodeFieldTypeUnsignedQuadWord.sharedInstance
	];
	flags.description = @"Flags";
	flags.options = MKNodeFieldOptionDisplayAsDetail;
	
	MKNodeFieldBuilder *offset = [MKNodeFieldBuilder
		builderWithProperty:MK_PROPERTY(offset)
		type:MKNodeFieldTypeUnsignedQuadWord.sharedInstance
	];
	offset.description = @"Symbol Offset";
	offset.options = MKNodeFieldOptionDisplayAsDetail;
	
	MKNodeFieldBuilder *resolver = [MKNodeFieldBuilder
		builderWithProperty:MK_PROPERTY(resolver)
		type:MKNodeFieldTypeUnsignedQuadWord.sharedInstance
	];
	resolver.description = @"Resolver Offset";
	resolver.options = MKNodeFieldOptionDisplayAsDetail;
	
	MKNodeFieldBuilder *ordinal = [MKNodeFieldBuilder
		builderWithProperty:MK_PROPERTY(ordinal)
		type:MKNodeFieldTypeUnsignedQuadWord.sharedInstance
	];
	ordinal.description = @"Ordinal";
	ordinal.options = MKNodeFieldOptionDisplayAsDetail;
	
	MKNodeFieldBuilder *importedName = [MKNodeFieldBuilder
		builderWithProperty:MK_PROPERTY(importedName)
		type:nil /* TODO ? */
	];
	importedName.description = @"Imported Name";
	importedName.options = MKNodeFieldOptionDisplayAsDetail;
	
	return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
		flags.build,
		offset.build,
		resolver.build,
		ordinal.build,
		importedName.build
	]];
}

@end
