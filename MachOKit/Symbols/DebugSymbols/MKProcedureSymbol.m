//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKProcedureSymbol.m
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

#import "MKProcedureSymbol.h"
#import "MKInternal.h"

//----------------------------------------------------------------------------//
@implementation MKProcedureSymbol

//|++++++++++++++++++++++++++++++++++++|//
+ (uint32_t)canInstantiateWithEntry:(struct nlist_64)nlist
{
    if (self != MKProcedureSymbol.class)
        return 0;
    
    return (nlist.n_type & N_STAB) != 0 && nlist.n_type == N_FUN ? 75 : 0;
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Values
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

// The comments in <mach-o/loader.h> mentions that the 'n_desc' field stores
// the 'linenumber'.  But I could not find any correlated discussion in the
// STABS docs.  They imply that the line number is found in another STAB:
//
//   "There is no need to try to get the line number of the start of the
//    function from the stab for the function; it is in the next N_SLINE
//    symbol."
//
// https://www.sourceware.org/gdb/onlinedocs/stabs.html#Global-Variables
//
//   - clang does not produce STABS as far as I can tell.
//   - ld64 always sets this field to 0 when synthesizing STABS
//     [see OutputFile::synthesizeDebugNotes()]
//     https://opensource.apple.com/source/ld64/ld64-409.12/src/ld/OutputFile.cpp.auto.html

//|++++++++++++++++++++++++++++++++++++|//
- (uint64_t)address
{ return self.value; }

// The comments in <mach-o/loader.h> imply that the 'n_sect' field should be
// set to a valid section.  But when ld64 synthesizes a pair of N_FUN entires,
// it sets the n_sect field to 1 for the beginning entry and 0 for the ending
// entry.  This happens to work because the (__TEXT,__text) section will be
// section #1 in almost every binary (and 0 == NO_SECT).

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
    // TODO - Should we change the label to say "Procedure Length" when the
    //        value stores a procedure length (see the note in the header).
    //        Can we always correctly detect these cases?
    MKNodeFieldBuilder *address = [MKNodeFieldBuilder
        builderWithProperty:MK_PROPERTY(address)
        type:MKNodeFieldTypeAddress.sharedInstance
    ];
    address.description = @"Procedure Address";
    address.options = MKNodeFieldOptionHidden;
    
    return [MKNodeDescription nodeDescriptionWithParentDescription:super.layout fields:@[
        address.build
    ]];
}

@end
