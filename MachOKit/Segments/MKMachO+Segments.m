//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKMachO+Segments.m
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

#import "MKMachO+Segments.h"
#import "MKInternal.h"

#import "MKBackedNode+Pointer.h"
#import "MKLCSegment.h"
#import "MKLCSegment64.h"
#import "MKLCSymtab.h"
#import "MKSegment.h"
#import "MKSection.h"

_mk_internal NSString * const MKAllSegments = @"MKAllSegments";
_mk_internal NSString * const MKIndexedSegments = @"MKIndexedSegments";
_mk_internal NSString * const MKSegmentsByLoadCommand = @"MKSegmentsByLoadCommand";
_mk_internal NSString * const MKAllSections = @"MKAllSections";
_mk_internal NSString * const MKIndexedSections = @"MKIndexedSections";

//----------------------------------------------------------------------------//
@implementation MKMachOImage (Segments)

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - Segments and Sections
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (NSDictionary*)_segments
{
    if (_segments == nil)
    @autoreleasepool {
        NSMutableArray<MKSegment*> *segments = [[NSMutableArray alloc] initWithCapacity:4];
        NSMutableDictionary<NSNumber*, MKSegment*> *segmentsByIndex = [[NSMutableDictionary alloc] init];
        NSMapTable *segmentsByLoadCommand = [[NSMapTable alloc] initWithKeyOptions:NSMapTableObjectPointerPersonality valueOptions:NSMapTableStrongMemory capacity:4];
        NSInteger segmentIndex = -1;
        
        NSMutableArray<MKSection*> *sections = [[NSMutableArray alloc] init];
        NSMutableDictionary<NSNumber*, MKSection*> *sectionsByIndex = [[NSMutableDictionary alloc] init];
        // Use a uint64_t to avoid overflow issues if we have bad data.
        uint64_t sectionBaseIndex = 0;
        
        for (id lc in self.loadCommands)
        {
            NSError *localError = nil;
            
            if ([lc conformsToProtocol:@protocol(MKLCSegment)] == NO)
                continue;
            
            segmentIndex++;
            
            MKSegment *segment = [MKSegment segmentWithLoadCommand:lc error:&localError];
            if (segment == nil) {
                MK_PUSH_UNDERLYING_WARNING(segments, localError, @"Failed to load segment for load command %@", lc);
                continue;
            }
            
            [segments addObject:segment];
            [segmentsByIndex setObject:segment forKey:@(segmentIndex)];
            [segmentsByLoadCommand setObject:segment forKey:lc];
            
            // Copy all sections from the segment into the sections dictionary
            // for the image.  The index of the section is derived from
            // the position of the segment's load command in the list of
            // load commands as well as the position of the section's load
            // command within its parent segment load command.
            {
                NSArray *sectionLoadCommands = segment.loadCommand.sections;
                
                for (uint32_t i=0; i<sectionLoadCommands.count; i++) {
                    id section = [segment sectionForLoadCommand:sectionLoadCommands[i]];
                    [sections addObject:section];
                    sectionsByIndex[@(sectionBaseIndex + i)] = section;
                }
                
                sectionBaseIndex += segment.loadCommand.nsects;
            }
        }
        
        _segments = [@{
            MKAllSegments: segments,
            MKIndexedSegments: segmentsByIndex,
            MKSegmentsByLoadCommand: segmentsByLoadCommand,
            MKAllSections: sections,
            MKIndexedSections: [NSDictionary dictionaryWithDictionary:sectionsByIndex]
        } retain];
        
        [segments release];
        [segmentsByIndex release];
        [segmentsByLoadCommand release];
        [sections release];
        [sectionsByIndex release];
    }
    
    return _segments;
}

//|++++++++++++++++++++++++++++++++++++|//
- (NSDictionary*)segments
{ return self._segments[MKIndexedSegments]; }

//|++++++++++++++++++++++++++++++++++++|//
- (NSArray*)segmentsWithName:(NSString*)name
{
    // TODO - Check what DYLD would do with duplicate segments.
    return [self._segments[MKAllSegments] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name MATCHES %@", name]];
}

//|++++++++++++++++++++++++++++++++++++|//
- (NSDictionary*)sections
{ return self._segments[MKIndexedSections]; }

//|++++++++++++++++++++++++++++++++++++|//
- (NSArray*)sectionsWithName:(NSString*)sectName inSegment:(MKSegment*)segment
{
    // TODO - Check what DYLD would do with duplicate sections.
    NSMutableArray *sections = [NSMutableArray arrayWithCapacity:1];
    
    for (MKSection *section in self._segments[MKAllSections]) {
        if ((segment == nil || section.parent == segment) && [section.name isEqualToString:sectName])
            [sections addObject:section];
    }
    
    return sections;
}

//|++++++++++++++++++++++++++++++++++++|//
- (NSArray*)sectionsWithName:(NSString*)sectName inSegmentWithName:(NSString*)segName
{ return [self sectionsWithName:sectName inSegment:[self segmentsWithName:segName].firstObject]; }

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark - MKPointer
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (MKOptional*)childNodeOccupyingVMAddress:(mk_vm_address_t)address targetClass:(Class)targetClass
{
    for (MKSegment *segment in self._segments[MKAllSegments]) {
        mk_vm_range_t range = mk_vm_range_make(segment.nodeVMAddress, segment.nodeSize);
        if (mk_vm_range_contains_address(range, 0, address) == MK_ESUCCESS) {
            return [segment childNodeOccupyingVMAddress:address targetClass:targetClass];
        }
    }
    
    return [super childNodeOccupyingVMAddress:address targetClass:targetClass];
}

@end
