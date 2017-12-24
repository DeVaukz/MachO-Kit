//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             _mach_trie.c
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

#include "macho_abi_internal.h"

//|++++++++++++++++++++++++++++++++++++|//
mk_error_t
_mk_mach_trie_copy_uleb128(const uint8_t* p, const uint8_t* end, uint64_t *output, size_t *output_len)
{
    uint64_t result = 0;
    unsigned i = 0;
    int		 bit = 0;
    
    do {
        if (&p[i] == end)
            return MK_EOUT_OF_RANGE;
        
        uint64_t slice = p[i] & 0x7f;
        
        if (bit > 63)
            return MK_ESIZE;
        
        result |= (slice << bit);
        bit += 7;
    } while(p[i++] & 0x80);
    
    if (output) *output = result;
    if (output_len) *output_len = i;
    
    return MK_ESUCCESS;
}

//|++++++++++++++++++++++++++++++++++++|//
mk_error_t
_mk_mach_trie_copy_sleb128(const uint8_t* p, const uint8_t* end, int64_t *output, size_t *output_len)
{
    int64_t result = 0;
    unsigned i = 0;
    int		 bit = 0;
    uint8_t byte;
    
    do {
        if (&p[i] == end)
            return MK_EOUT_OF_RANGE;
        
        byte = p[i++];
        result |= (((int64_t)(byte & 0x7f)) << bit);
        bit += 7;
    } while (byte & 0x80);
    
    // sign extend negative numbers
    if ((byte & 0x40) != 0)
        result |= (-1LL) << bit;
    
    if (output) *output = result;
    if (output_len) *output_len = i;
    
    return MK_ESUCCESS;
}
