//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKStaticSymbol.m
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

#import "MKStaticSymbol.h"
#import "MKInternal.h"

//----------------------------------------------------------------------------//
@implementation MKStaticSymbol

//|++++++++++++++++++++++++++++++++++++|//
+ (uint32_t)canInstantiateWithEntry:(struct nlist_64)nlist
{
    if (self != MKStaticSymbol.class)
        return 0;
    
    return (nlist.n_type & N_STAB) != 0 && nlist.n_type == N_STSYM ? 75 : 0;
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Values
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

// The comments in <mach-o/loader.h> mentions that the 'n_desc' field stores
// the 'type'.  But I could not find any correlated discussion in the STABS
// docs:
// https://www.sourceware.org/gdb/onlinedocs/stabs.html#Statics
//   - clang does not produce STABS as far as I can tell.
//   - ld64 always sets this field to 0 when synthesizing STABS
//     [see OutputFile::synthesizeDebugNotes()]
//     https://opensource.apple.com/source/ld64/ld64-409.12/src/ld/OutputFile.cpp.auto.html

//|++++++++++++++++++++++++++++++++++++|//
- (mk_vm_address_t)address
{ return self.value; }

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  MKNode
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeFieldBuilder*)_valueFieldBuilder
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Weverything"
    MKNodeFieldBuilder *value = [super _valueFieldBuilder];
#pragma clang diagnostic pop
    value.alternateFieldName = MK_PROPERTY(address);
    value.options |= MKNodeFieldOptionShowAlternateFieldDescription | MKNodeFieldOptionSubstituteAlternateFieldValue;
    
    return value;
}

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeDescription*)layout
{
    MKNodeFieldBuilder *address = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(address)
        type:MKNodeFieldTypeAddress.sharedInstance
    ];
    address.description = @"Address";
    address.options = MKNodeFieldOptionHidden;
    
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        address.build
    ]];
}

@end
