//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKMachO+Libraries.m
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

#import "MKMachO+Libraries.h"
#import "MKInternal.h"
#import "MKDylibLoadCommand.h"
#import "MKDependentLibrary.h"

//----------------------------------------------------------------------------//
@implementation MKMachOImage (Libraries)

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Dependent Libraries
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (NSArray*)dependentLibraries
{
    if (_dependentLibraries == nil)
    @autoreleasepool {
        NSMutableArray<MKOptional<MKDependentLibrary*>*> *libraries = [[NSMutableArray alloc] init];
        
        for (MKDylibLoadCommand *lc in self.loadCommands) {
            NSError *libraryError = nil;
            
            if ([lc isKindOfClass:MKDylibLoadCommand.class] == NO || lc.cmd == LC_ID_DYLIB)
                continue;
            
            MKDependentLibrary *library = [[MKDependentLibrary alloc] initWithLoadCommand:lc error:&libraryError];
            if (library)
                [libraries addObject:[MKOptional optionalWithValue:library]];
            else
                [libraries addObject:[MKOptional optionalWithError:libraryError]];
            
            [library release];
        }
        
        _dependentLibraries = [libraries copy];
        [libraries release];
    }
    
    return _dependentLibraries;
}

@end
