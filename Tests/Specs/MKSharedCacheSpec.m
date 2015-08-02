//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKSharedCacheSpec.m
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

SpecBegin(MKSharedCache)
{
    const char* path = getenv("MK_SC_TEST_PATH");
    if (path == NULL)
        return;
    
    NSString *sharedCachesPath = [[NSString alloc] initWithCString:path encoding:NSUTF8StringEncoding];
    NSURL *sharedCachesURL = [NSURL fileURLWithPath:sharedCachesPath];
    if (sharedCachesURL == nil)
        return;
    
    NSArray *sharedCaches = [NSFileManager sharedCachesInDirectoryAtURL:sharedCachesURL];
    
    for (NSURL *sharedCacheURL in sharedCaches)
    describe([sharedCachesURL lastPathComponent], ^{
        NSError *error = nil;
        __block MKSharedCache *sharedCache = nil;
        
        MKMemoryMap *map = [MKMemoryMap memoryMapWithContentsOfFile:sharedCacheURL error:&error];
        beforeAll(^{
            expect(map).toNot.beNil();
            expect(error).to.beNil();
        });
        if (map == nil) return;
        
        sharedCache = [[MKSharedCache alloc] initWithFlags:0 atAddress:0 inMapping:map error:&error];
        beforeAll(^{
            expect(sharedCache).toNot.beNil();
            expect(error).to.beNil();
        });
        if (sharedCache == nil) return;
        
        NSLog(@"%@", sharedCache.debugDescription);
    });
}
SpecEnd
