//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKMachO.m
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

#import "MKMachO.h"
#import "MKInternal.h"
#import "MKMachHeader.h"
#import "MKMachHeader64.h"
#import "MKLoadCommand.h"
#import "MKLCSegment.h"

#include "core_internal.h"

#include <objc/runtime.h>

//----------------------------------------------------------------------------//
@implementation MKMachOImage

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithName:(const char*)name flags:(MKMachOImageFlags)flags atAddress:(mk_vm_address_t)contextAddress inMapping:(MKMemoryMap*)mapping error:(NSError**)error
{
    NSParameterAssert(mapping);
    NSError *localError = nil;
    
    self = [super initWithParent:nil error:error];
    if (self == nil) return nil;
    
    // TODO - Remove this eventually
    _context.user_data = (void*)self;
    _context.logger = (mk_logger_c)method_getImplementation(class_getInstanceMethod(self.class, @selector(_logMessageAtLevel:inFile:line:function:message:)));
    
    _mapping = [mapping retain];
    _contextAddress = contextAddress;
    _flags = flags;
    
    // Convert the name to an NSString
    if (name)
        _name = [[NSString alloc] initWithCString:name encoding:NSUTF8StringEncoding];
    
    // Read the Magic
    uint32_t magic = [mapping readDoubleWordAtOffset:0 fromAddress:contextAddress withDataModel:nil error:error];
    if (magic == 0) {
        [self release]; return nil;
    }
    
    // Load the appropriate data model for the Mach-O
    switch (magic) {
        case MH_CIGAM:
        case MH_MAGIC:
            _dataModel = [[MKILP32DataModel sharedDataModel] retain];
            _header = [[MKMachHeader alloc] initWithOffset:0 fromParent:self error:&localError];
            break;
        case MH_CIGAM_64:
        case MH_MAGIC_64:
            _dataModel = [[MKLP64DataModel sharedDataModel] retain];
            _header = [[MKMachHeader64 alloc] initWithOffset:0 fromParent:self error:&localError];
            break;
        default:
            MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_EINVAL description:@"Bad Mach-O magic: 0x%" PRIx32 ".", magic];
            [self release]; return nil;
    }
    
    if (_header == nil) {
        MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:localError.code underlyingError:localError description:@"Failed to load Mach header"];
        [self release]; return nil;
    }
    
    // Now that the header is loaded, further specialize the data model based
    // on the architecutre if needed.
    switch (self.header.cputype) {
        case CPU_TYPE_ARM64:
            [_dataModel release];
            _dataModel = [[MKAARCH64DataModel sharedDataModel] retain];
            break;
        default:
            break;
    }
    
    // Only support a subset of the Mach-O types at this time
    switch (_header.filetype) {
        case MH_OBJECT:
        case MH_EXECUTE:
        case MH_DYLIB:
            break;
        default:
            MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_EINVALID_DATA description:@"Unsupported file type: %" PRIx32 ".", _header.filetype];
            [self release]; return nil;
    }
    
    // Parse load commands
    {
        uint32_t loadCommandLength = _header.sizeofcmds;
        uint32_t loadCommandCount = _header.ncmds;
        
        // The kernel will refuse to load a Mach-O image in which the
        // mach_header_size + header->sizeofcmds is greater than the size of the
        // Mach-O image.  However, we can not know the size of the Mach-O here.
        
        // TODO - Premap the load commands once MKMemoryMap has support for that.
        
        NSMutableArray<MKLoadCommand*> *loadCommands = [[NSMutableArray alloc] initWithCapacity:loadCommandCount];
        mach_vm_offset_t offset = _header.nodeSize;
        mach_vm_offset_t oldOffset;
        
        while (loadCommandCount--)
        @autoreleasepool {
                
            NSError *e = nil;
                
            // It is safe to pass the mach_vm_offset_t offset as the offset
            // parameter because the offset can not grow beyond the header size,
            // which is capped at UINT32_MAX.  Any uint32_t can be acurately
            // represented by an mk_vm_offset_t.
                
            MKLoadCommand *lc = [MKLoadCommand loadCommandAtOffset:offset fromParent:self error:&e];
            if (lc == nil) {
                // If we fail to instantiate an instance of the MKLoadCommand it
                // means we've walked off the end of memory that can be mapped by
                // our MKMemoryMap.
                MK_PUSH_UNDERLYING_WARNING(loadCommands, e, @"Failed to instantiate load command at index %" PRIi32 ".", _header.ncmds - loadCommandCount);
                break;
            }
                
            oldOffset = offset;
            offset += lc.cmdSize;
            
            [loadCommands addObject:lc];
            
            // The kernel will refuse to load a Mach-O image if it detects that the
            // kernel's offset into the load commands (when parsing the load
            // commands) has exceeded the total mach header size (mach_header_size
            // + mach_header->sizeofcmds).  However, we don't care as long as there
            // was not an overflow...
            if (oldOffset > offset) {
                MK_PUSH_WARNING(loadCommands, MK_EOVERFLOW, @"Encountered an overflow while advancing the parser to the load command following index %" PRIu32 ".", _header.ncmds - loadCommandCount);
                break;
            }
            // ...but we will add a warning.
            if (offset > _header.nodeSize + (mach_vm_size_t)loadCommandLength)
                MK_PUSH_WARNING(loadCommands, MK_EINVALID_DATA, @"Part of load command at index %" PRIi32 " is beyond sizeofcmds.  This is invalid.", _header.ncmds - loadCommandCount);
        }
        
        _loadCommands = [loadCommands copy];
        [loadCommands release];
    }
    
    // Determine the VM address and slide
    {
        mk_error_t err;
        
        NSArray *segmentLoadCommands = [self loadCommandsOfType:(self.dataModel.pointerSize == 8) ? LC_SEGMENT_64 : LC_SEGMENT];
        for (id<MKLCSegment> segmentLC in segmentLoadCommands) {
            // The VM address of the image is defined as the vmaddr of the
            // *last* segment load command with a 0 fileoff and non-zero
            // filesize.
            if (segmentLC.mk_fileoff == 0 && segmentLC.mk_filesize != 0)
                _vmAddress = segmentLC.mk_vmaddr;
        }
        
        // Only need to compute the slide if this Mach-O is loaded from
        // memory.
        if (self.isFromMemory) {
            // The slide can now be computed by subtracting the preferred load
            // address of the image from the address it was actually loaded at.
            if ((err = mk_vm_address_difference(contextAddress, _vmAddress, &_slide))) {
                MK_ERROR_OUT = MK_MAKE_VM_ADDRESS_DEFFERENCE_ARITHMETIC_ERROR(err, contextAddress, _vmAddress);
                [self release]; return nil;
            }
        }
    }
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithParent:(MKBackedNode*)parent error:(NSError**)error
{
    MKMemoryMap *mapping = parent.memoryMap;
    NSParameterAssert(mapping != nil);
    
    self = [self initWithName:NULL flags:0 atAddress:0 inMapping:mapping error:error];
    if (!self) return nil;
    
    objc_storeWeak(&_parent, parent);
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (void)dealloc
{
    [_indirectSymbolTable release];
    [_symbolTable release];
    [_stringTable release];
    
    [_exportsInfo release];
    
    [_lazyBindingsInfo release];
    [_weakBindingsInfo release];
    [_bindingsInfo release];
    
    [_functionStarts release];
    
    [_splitSegment release];
    
    [_dataInCode release];
    
    [_rebaseInfo release];
    
    [_segments release];
    
    [_dependentLibraries release];
    
    [_loadCommands release];
    [_header release];
    
    [_name release];
    [_dataModel release];
    
    [super dealloc];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Retrieving the Initialization Context
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@synthesize dataModel = _dataModel;
@synthesize flags = _flags;

//|++++++++++++++++++++++++++++++++++++|//
- (mk_context_t*)context
{ return &_context; }

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Getting Image Metadata
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@synthesize name = _name;
@synthesize slide = _slide;

//|++++++++++++++++++++++++++++++++++++|//
- (BOOL)isFromSharedCache
{
    // 0x80000000 is the private in-shared-cache bit
    return !!(self.header.flags & 0x80000000);
}

//|++++++++++++++++++++++++++++++++++++|//
- (BOOL)isFromMemory
{
    return !!(_flags & MKMachOImageProcessedByDYLD);
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Header
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@synthesize header = _header;

//|++++++++++++++++++++++++++++++++++++|//
- (mk_architecture_t)architecture
{ return mk_architecture_create(self.header.cputype, self.header.cpusubtype); }

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Load Commands
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@synthesize loadCommands = _loadCommands;

//|++++++++++++++++++++++++++++++++++++|//
- (NSArray*)loadCommandsOfType:(uint32_t)type
{ return [self.loadCommands filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"class.ID == %@", @(type)]]; }

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (MKMemoryMap*)memoryMap
{ return _mapping; }

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_size_t)nodeSize
{ return 0; }

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_address_t)nodeAddress:(MKNodeAddressType)type
{
    switch (type) {
        case MKNodeContextAddress:
            return _contextAddress;
        case MKNodeVMAddress:
            return _vmAddress;
        default:
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Unsupported node address type." userInfo:nil];
    }
}

//|++++++++++++++++++++++++++++++++++++|//
- (NSData*)data
{ return nil; }

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    MKNodeFieldBuilder *header = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(header)
        type:[MKNodeFieldTypeNode typeWithNodeType:MKMachHeader.class]
    ];
    header.description = @"Mach Header";
    header.options = MKNodeFieldOptionDisplayAsChild | MKNodeFieldOptionDisplayAsDetail | MKNodeFieldOptionMergeContainerContents;
    
    MKNodeFieldBuilder *loadCommands = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(loadCommands)
        type:[MKNodeFieldTypeCollection typeWithCollectionType:[MKNodeFieldTypeNode typeWithNodeType:MKLoadCommand.class]]
    ];
    loadCommands.description = @"Load Commands";
    loadCommands.options = MKNodeFieldOptionDisplayAsChild | MKNodeFieldOptionDisplayContainerContentsAsChild;
    
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        //[MKNodeField nodeFieldWithProperty:MK_PROPERTY(name) description:@"Image Path"],
        //[MKNodeField nodeFieldWithProperty:MK_PROPERTY(slide) description:@"Slide"],
        header.build,
        loadCommands.build,
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wobjc-method-access"
        [[self.class _sectionsFieldBuilder] build],
        [[self.class _functionStartsFieldBuilder] build],
        [[self.class _rebaseInfoFieldBuilder] build],
        [[self.class _dataInCodeFieldBuilder] build],
        [[self.class _splitSegmentInfoFieldBuilder] build],
        [[self.class _bindingsInfoFieldBuilder] build],
        [[self.class _weakBindingsInfoFieldBuilder] build],
        [[self.class _lazyBindingsInfoFieldBuilder] build],
		[[self.class _exportsInfoFieldBuilder] build],
        [[self.class _stringTableFieldBuilder] build],
        [[self.class _symbolTableFieldBuilder] build],
        [[self.class _indirectSymbolTableFieldBuilder] build],
    #pragma clang diagnostic pop
    ]];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  NSObject
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (NSString*)description
{
    NSString *kind;
    switch (self.header.filetype)
    {
        case MH_OBJECT:
            kind = @"Relocatable Object File";
            break;
        case MH_EXECUTE:
            kind = @"Executable";
            break;
        case MH_DYLIB:
            kind = @"Shared Library";
            break;
        default:
            kind = @"Mach-O Image";
            break;
    }
    
    char architecture[50];
    size_t descriptionLen = mk_architecture_copy_description(self.architecture, architecture, sizeof(architecture));
    NSString *arch = [[[NSString alloc] initWithBytes:(void*)architecture length:descriptionLen encoding:NSASCIIStringEncoding] autorelease];
    
    return [NSString stringWithFormat:@"%@ (%@)", kind, arch];
}

//|++++++++++++++++++++++++++++++++++++|//
- (NSString*)debugDescription
{ return [self.layout textualDescriptionForNode:self traversalDepth:0]; }

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  mk_context_t
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (void)_logMessageAtLevel:(mk_logging_level_t)level inFile:(const char*)file line:(int)line function:(const char*)function message:(const char*)message, ...
{
    va_list ap;
    va_start(ap, message);
    CFStringRef str = CFStringCreateWithCString(NULL, message, kCFStringEncodingUTF8);
    CFStringRef messageString = CFStringCreateWithFormatAndArguments(NULL, NULL, str, ap);
    va_end(ap);
    
    id<MKNodeDelegate> delegate = self.delegate;
    if (delegate && [delegate respondsToSelector:@selector(logMessageFromNode:atLevel:inFile:line:function:message:)])
        [delegate logMessageFromNode:self atLevel:level inFile:file line:line function:function message:(NSString*)messageString];
    else
        NSLog(@"MachOKit - [%s][%s:%d]: %@", mk_string_for_logging_level(level), file, line, messageString);
    
    CFRelease(messageString);
    CFRelease(str);
}

@end
