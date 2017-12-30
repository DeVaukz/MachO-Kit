//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKNodeDescription.m
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

#import "MKNodeDescription.h"
#import "MKInternal.h"
#import "MKNode.h"
#import "MKBackedNode.h"
#import "MKPointer.h"

//----------------------------------------------------------------------------//
@implementation MKNodeDescription

@synthesize parent = _parent;

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)nodeDescriptionWithParentDescription:(MKNodeDescription*)parent fields:(NSArray*)fields
{ return [[[self alloc] initWithParentDescription:parent fields:fields] autorelease]; }

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)initWithParentDescription:(MKNodeDescription*)parent fields:(NSArray*)fields
{
    self = [super init];
    if (self == nil) return nil;
    
    _parent = [parent retain];
    _fields = [fields copy];
    
    return self;
}

//|++++++++++++++++++++++++++++++++++++|//
- (instancetype)init
{ return [self initWithParentDescription:nil fields:nil]; }

//|++++++++++++++++++++++++++++++++++++|//
- (void)dealloc
{
    [_parent release];
    [_fields release];
    
    [super dealloc];
}

//|++++++++++++++++++++++++++++++++++++|//
- (NSArray*)fields
{ return _fields ?: @[]; }

//|++++++++++++++++++++++++++++++++++++|//
- (NSArray*)allFields
{
    NSArray *retValue = self.fields;
    MKNodeDescription *parent = self.parent;
    
    while (parent) {
        retValue = [parent.fields arrayByAddingObjectsFromArray:retValue];
        parent = parent.parent;
    }
    
    return retValue;
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Obtaining a Description
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (NSString*)textualDescriptionForNode:(MKNode*)node traversalDepth:(NSUInteger)traversalDepth
{
    NSMutableString *retValue = nil;
    
    // HACK HACK - Special case for MKBackedNode
    if ([node respondsToSelector:@selector(nodeContextAddress)] && [node respondsToSelector:@selector(nodeSize)])
        retValue = [NSMutableString stringWithFormat:@"<%@ %p; contextAddress = 0x%" MK_VM_PRIxADDR "; size = %" MK_VM_PRIiSIZE ">",
                    node.class, self, [(MKBackedNode*)node nodeContextAddress], [(MKBackedNode*)node nodeSize]];
    else
        retValue = [NSMutableString stringWithFormat:@"<%@ %p>", node.class, self];
    
    NSArray *fields = self.allFields;
    if (fields.count)
    {
        [retValue appendString:@" {\n"];
        
        __block NSString* (^describeValue)(id) = ^(id value) {
            if ([value isKindOfClass:MKNode.class])
                return [[value layout] textualDescriptionForNode:value traversalDepth:traversalDepth-1];
            else if ([value isKindOfClass:NSDictionary.class]) {
                NSMutableString *collectionDescription = [NSMutableString string];
                
                [collectionDescription appendString:@"("];
                for (id item in value) {
                    [collectionDescription appendFormat:@"\n\t%@", [describeValue([value objectForKey:item]) stringByReplacingOccurrencesOfString:@"\n" withString:@"\n\t"]];
                }
                [collectionDescription appendString:@"\n)"];
                
                return (NSString*)collectionDescription;
            }
            else if ([value conformsToProtocol:@protocol(NSFastEnumeration)]) {
                NSMutableString *collectionDescription = [NSMutableString string];
                
                [collectionDescription appendString:@"("];
                for (id item in value) {
                    [collectionDescription appendFormat:@"\n\t%@", [describeValue(item) stringByReplacingOccurrencesOfString:@"\n" withString:@"\n\t"]];
                }
                [collectionDescription appendString:@"\n)"];
                
                return (NSString*)collectionDescription;
            } else
                return [value description];
        };
        
        for (MKNodeField *field in self.fields)
        @autoreleasepool {
            NSString *fieldDescription = nil;
            
            // Only the base MKNodeField could describe a collection or a
            // child MKNode.
            if (traversalDepth && [field class] == [MKNodeField class])
                fieldDescription = describeValue([field.valueRecipe valueForField:field ofNode:node]);
            else
                fieldDescription = [field formattedDescriptionForNode:node];
            
            [retValue appendFormat:@"\t%@ = %@\n", field.name, [fieldDescription stringByReplacingOccurrencesOfString:@"\n" withString:@"\n\t"]];
        }
        
        if (node.warnings.count)
        {
            [retValue appendFormat:@"\twarnings = {\n"];
            for (NSError *warning in node.warnings)
            @autoreleasepool {
				[retValue appendFormat:@"\t\t%@: %@", warning.mk_property, warning.localizedDescription];
				
				for (NSError *w = warning.userInfo[NSUnderlyingErrorKey]; w != nil; w = w.userInfo[NSUnderlyingErrorKey])
					[retValue appendFormat:@" -> %@", w.localizedDescription];
				
				[retValue appendFormat:@"\n"];
            }
            [retValue appendFormat:@"\t}\n"];
        }
        
        [retValue appendString:@"}"];
    }
    
    return retValue;
}

@end
