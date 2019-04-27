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
#import "MKBackedNode.h"

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

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Working with Fields
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

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

//|++++++++++++++++++++++++++++++++++++|//
- (MKNodeField*)fieldWithName:(NSString*)name searchAllFields:(BOOL)searchAllFields
{
    for (MKNodeField *field in searchAllFields ? self.allFields : self.fields)
    {
        if ([field.name isEqualToString:name])
            return field;
    }
    
    return nil;
}

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Obtaining a Description
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//|++++++++++++++++++++++++++++++++++++|//
- (NSString*)textualDescriptionForNode:(MKNode*)node traversalDepth:(NSUInteger)traversalDepth
{
    NSMutableString *retValue = nil;
    
    // HACK HACK - Special case for MKBackedNode and MKAddressedNode
    if ([node respondsToSelector:@selector(nodeContextAddress)] && [node respondsToSelector:@selector(nodeSize)])
        retValue = [NSMutableString stringWithFormat:@"<%@ %p; contextAddress = 0x%" MK_VM_PRIxADDR "; size = %" MK_VM_PRIiSIZE ">",
                    node.class, self, [(MKBackedNode*)node nodeContextAddress], [(MKBackedNode*)node nodeSize]];
    else if ([node respondsToSelector:@selector(nodeContextAddress)])
        retValue = [NSMutableString stringWithFormat:@"<%@ %p; contextAddress = 0x%" MK_VM_PRIxADDR ">",
                    node.class, self, [(MKAddressedNode*)node nodeContextAddress]];
    else
        retValue = [NSMutableString stringWithFormat:@"<%@ %p>", node.class, self];
    
    NSArray *fields = self.allFields;
    if (fields.count)
    {
        [retValue appendString:@" {\n"];
        
        __block NSString* (^describeValue)(id, MKNodeField*) = ^(id value, MKNodeField *field) {
            // We want to format nodes a specific way, regardless of what the field says.
            if ([value isKindOfClass:MKNode.class]) {
                // Only recurse on the node if we have not reached the traversal depth
                if (traversalDepth > 0 && (field.options & MKNodeFieldOptionIgnoreContainerContents) == 0) {
                    return [[value layout] textualDescriptionForNode:value traversalDepth:traversalDepth-1];
                }
                /* else, fallthrough */
            }
            // We want to format collections a specific way, regardless of what the field says.
            else if ([value isKindOfClass:NSDictionary.class]) {
                NSMutableString *collectionDescription = [NSMutableString string];
                MKNodeField *childField = nil;
                if (field.options & MKNodeFieldOptionFormatCollectionValues)
                    childField = field;
                
                [collectionDescription appendString:@"("];
                for (id item in value) {
                    [collectionDescription appendFormat:@"\n\t%@", [describeValue([value objectForKey:item], childField) stringByReplacingOccurrencesOfString:@"\n" withString:@"\n\t"]];
                }
                [collectionDescription appendString:@"\n)"];
                
                return (NSString*)collectionDescription;
            }
            else if ([value conformsToProtocol:@protocol(NSFastEnumeration)]) {
                NSMutableString *collectionDescription = [NSMutableString string];
                MKNodeField *childField = nil;
                if (field.options & MKNodeFieldOptionFormatCollectionValues)
                    childField = field;
                
                [collectionDescription appendString:@"("];
                for (id item in value) {
                    [collectionDescription appendFormat:@"\n\t%@", [describeValue(item, childField) stringByReplacingOccurrencesOfString:@"\n" withString:@"\n\t"]];
                }
                [collectionDescription appendString:@"\n)"];
                
                return (NSString*)collectionDescription;
            }
            
            NSFormatter *formatter = field.valueFormatter;
            if (formatter)
                return [formatter stringForObjectValue:value];
            else
                return [value description];
        };
        
        for (MKNodeField *field in fields)
        @autoreleasepool {
            id value = [field.valueRecipe valueForField:field ofNode:node].value;
            
            [retValue appendFormat:@"\t%@ = %@\n", field.name, [describeValue(value, field) stringByReplacingOccurrencesOfString:@"\n" withString:@"\n\t"]];
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
