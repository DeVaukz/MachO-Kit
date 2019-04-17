//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKBindSetSymbolAndFlags.m
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

#import "MKBindSetSymbolAndFlags.h"
#import "MKInternal.h"
#import "MKCString.h"

//----------------------------------------------------------------------------//
@implementation MKBindSetSymbolAndFlags

//|++++++++++++++++++++++++++++++++++++|//
+ (uint8_t)opcode
{ return BIND_OPCODE_SET_SYMBOL_TRAILING_FLAGS_IMM; }

//|++++++++++++++++++++++++++++++++++++|//
+ (NSString*)name
{ return @"BIND_OPCODE_SET_SYMBOL_TRAILING_FLAGS_IMM"; }

//|++++++++++++++++++++++++++++++++++++|//
+ (uint32_t)canInstantiateWithOpcode:(uint8_t)opcode immediate:(uint8_t)immediate
{
#pragma unused (immediate)
    if (self != MKBindSetSymbolAndFlags.class)
        return 0;
    
    return opcode == [self opcode] ? 10 : 0;
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithOffset:(mk_vm_offset_t)offset fromParent:(MKBackedNode*)parent error:(NSError**)error
{
    self = [super initWithOffset:offset fromParent:parent error:error];
    if (self == nil) return nil;
    
    // Read the Symbol name
    {
        NSError *symbolNameError = nil;
        
        _symbolName = [[MKCString alloc] initWithOffset:(offset + 1) fromParent:parent error:&symbolNameError];
        if (_symbolName == nil) {
            MK_ERROR_OUT = [NSError mk_errorWithDomain:MKErrorDomain code:MK_EINTERNAL_ERROR underlyingError:symbolNameError description:@"Could not read symbol name."];
            [self release]; return nil;
        }
    }
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (void)dealloc
{
    [_symbolName release];
    
    [super dealloc];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Performing Binding
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (BOOL)bind:(void (^)(void))binder withContext:(struct MKBindContext*)bindContext error:(NSError**)error
{
#pragma unused(binder)
#pragma unused(error)
    bindContext->symbolName = self.symbolName.string;
    bindContext->symbolFlags = self.symbolFlags;
    
    return YES;
}

//|++++++++++++++++++++++++++++++++++++|//
- (BOOL)weakBind:(void (^)(void))binder withContext:(struct MKBindContext*)bindContext error:(NSError**)error
{ return [self bind:binder withContext:bindContext error:error]; }

//|++++++++++++++++++++++++++++++++++++|//
- (BOOL)lazyBind:(void (^)(void))binder withContext:(struct MKBindContext*)bindContext error:(NSError**)error
{ return [self bind:binder withContext:bindContext error:error]; }

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Bind Command Values
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@synthesize symbolName = _symbolName;

//|++++++++++++++++++++++++++++++++++++|//
- (uint8_t)symbolFlags
{ return _data & BIND_IMMEDIATE_MASK; }

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_size_t)nodeSize
{ return 1 + _symbolName.nodeSize; }

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_size_t)symbolNameFieldSize
{ return self.symbolName.nodeSize; }
- (mk_vm_offset_t)symbolNameFieldOffset
{
    return 1;
}

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    MKNodeFieldBuilder *symbolFlags = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(symbolFlags)
        type:[MKNodeFieldTypeBitfield bitfieldWithType:MKNodeFieldBindSymbolFlagsType.sharedInstance mask:@((uint8_t)BIND_IMMEDIATE_MASK) name:nil]
        offset:0
        size:sizeof(uint8_t)
    ];
    symbolFlags.description = @"Symbol Flags";
    symbolFlags.options = MKNodeFieldOptionDisplayAsDetail;
    symbolFlags.formatter = [MKComboFormatter comboFormatterWithStyle:MKComboFormatterStyleRawAndRefinedValue2
                                                    rawValueFormatter:MKNodeFieldTypeUnsignedByte.sharedInstance.formatter
                                                refinedValueFormatter:MKNodeFieldBindSymbolFlagsType.sharedInstance.formatter];
    [(MKOptionSetFormatter*)[(MKComboFormatter*)symbolFlags.formatter refinedValueFormatter] setZeroBehavior:MKOptionSetFormatterZeroBehaviorNil];
    
    MKNodeFieldBuilder *symbolName = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(symbolName)
        type:[MKNodeFieldTypeNode typeWithNodeType:MKCString.class]
    ];
    symbolName.description = @"Symbol Name";
    symbolName.dataRecipe = MKNodeFieldDataOperationExtractDynamicSubrange.sharedInstance;
    symbolName.options = MKNodeFieldOptionDisplayAsDetail | MKNodeFieldOptionIgnoreContainerContents;
    
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        symbolFlags.build,
        symbolName.build
    ]];
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  NSObject
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (NSString*)description
{ return [NSString stringWithFormat:@"%@(0x%.2" PRIx8 ", %@)", self.class.name, self.symbolFlags, self.symbolName]; }

@end
