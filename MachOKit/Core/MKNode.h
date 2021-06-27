//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       MKNode.h
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

#import <MachOKit/MKBase.h>

#import <MachOKit/MKNodeDescription.h>
#import <MachOKit/MKResult.h>
#import <MachOKit/MKMemoryMap.h>
#import <MachOKit/MKDataModel.h>

@class MKNode;

NS_ASSUME_NONNULL_BEGIN

//----------------------------------------------------------------------------//
@protocol MKNodeDelegate <NSObject>
- (void)logMessageFromNode:(MKNode*)node atLevel:(mk_logging_level_t)level inFile:(const char*)file line:(int)line function:(const char*)function message:(NSString*)message;
@end



//----------------------------------------------------------------------------//
//! An instance of \c MKNode parses a portion of the Mach-O.
//!
//! Mach-O Kit represents a parsed Mach-O as a tree of nodes.
//!
@interface MKNode : NSObject {
@package
    /*__weak*/ MKNode *_parent;
}

//! Initializes the receiver with the provided \a parent node.  Subclasses
//! are expected to override this method and may place restrictions on
//! the type(s) of nodes that can be provided as a parent.
- (nullable instancetype)initWithParent:(null_unspecified MKNode*)parent error:(NSError**)error NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Retreiving The Layout and Description
//! @name       Retreiving The Layout and Description
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//! Returns the layout of this node.
//!
//! A layout describes the fields parsed from the range of the data represented
//! by this node.
@property (nonatomic, readonly) MKNodeDescription *layout;

//! A description that captures node specific information such as class,
//! address, and size (for backed nodes).  Useful when forming error messages
//! where knowng this information is important, even when the node class
//! may have reimplemented -description.
//!
//!	@note
//!	Never call \c -compactDescription from within your subclass \c -description
//!	method.
@property (nonatomic, readonly) NSString *compactDescription;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Accessing Related Objects
//! @name       Accessing Related Objects
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//! The delegate for the node.  If no delegate has been set for the node,
//! the delegate of the node's parent.
@property (nonatomic, assign, nullable) id<MKNodeDelegate> delegate;

//! The memory map for the node.  By default this is the memory map of the
//! node's parent.  Subclasses should override the getter for this property
//! to provide the \ref MKMemoryMap that is to be used by their child nodes.
@property (nonatomic, readonly) MKMemoryMap *memoryMap;

//! The data model used for accessing memory in this node.  By default this is
//! the data model of this node's parent.  Subclasses should override the
//! getter for this property to provide the \ref MKDataModel that is to be used
//! by their child nodes.
@property (nonatomic, readonly) MKDataModel* dataModel;

//! An array of warnings raised while initiaizing the node.  Each warning
//! is represented by an instance of \c NSError.
@property (nonatomic, copy) NSArray<NSError*> *warnings;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Navigating the Node Tree
//! @name       Navigating the Node Tree
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//! The parent node, or \c nil if the node has no parent.
@property (nonatomic, readonly, nullable) MKNode *parent;

//! Returns the nearest ancestor node of type \a cls.
- (nullable __kindof MKNode*)nearestAncestorOfType:(Class)cls;

//! Returns the nearest ancestor node conforming to \a protocol.
- (nullable __kindof MKNode*)nearestAncestorConformingToProtocol:(Protocol*)protocol;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Discovering Subclasses
//! @name       Discovering Subclasses
//!
//! @brief      These methods are for subclasses that want to offer pluggable
//!             extensibility.
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

//! Returns a set containing all of the known subclasses of the receiver.
+ (NSSet*)subclasses;

//! Returns the subclass with the highest ranking, as determined by the
//! provided block.
+ (Class)bestSubclassWithRanking:(uint32_t (^)(Class cls))rank;

@end

NS_ASSUME_NONNULL_END
