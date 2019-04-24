//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       MKBindContext.h
//!
//! @author     D.V.
//! @copyright  Copyright (c) 2014-2015 D.V. All rights reserved.
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

@class MKBindingsInfo;
@class MKBindCommand;
@class MKSegment;

//----------------------------------------------------------------------------//
struct MKBindThreadedData
{
    int64_t libraryOrdinal;
    int64_t addend;
    uint8_t type;
    uint8_t symbolFlags;
#if __has_feature(objc_arc)
    void *symbolName;
#else
    NSString *symbolName;
#endif
};

//----------------------------------------------------------------------------//
struct MKBindContext
{
    mk_vm_offset_t actionStartOffset;
    mk_vm_size_t actionSize;
    unsigned segmentIndex;
    uint64_t segmentOffset;
    uint64_t derivedOffset;
    int64_t libraryOrdinal;
    int64_t addend;
    uint8_t type;
    uint8_t symbolFlags;
    bool useThreadedRebaseBind;
    uint64_t count;
    union {
        uint64_t raw; // already byte swapped
        // TODO - using a bitfield for this is not portable
        struct {
            // Rest of the bits differ between rebase/bind
            uint64_t value : 51;
            // Bits [51..61] is the delta to the next value
            unsigned delta : 11;
            // Bit 62 is to tell if this is a rebase (0) or bind (1)
            bool isBind : 1;
            // Bit 63 is unused
            bool unused63 : 1;
        };
    } threadedBindValue;
#if __has_feature(objc_arc)
    void *symbolName;
    void *segment;
    void *ordinalTable;
    void *command;
    void *info;
#else
    NSString *symbolName;
    MKSegment *segment;
    NSMutableArray<NSValue*> *ordinalTable;
    MKBindCommand *command;
    MKBindingsInfo *info;
#endif
};
