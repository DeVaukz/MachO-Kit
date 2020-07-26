//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       MKObjCCategory.h
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

#include <MachOKit/macho.h>
#import <Foundation/Foundation.h>

#import <MachOKit/MKOffsetNode.h>
#import <MachOKit/MKPointer.h>
#import <MachOKit/MKPointerNode.h>
#import <MachOKit/MKCString.h>

@class MKObjCClass;
@class MKObjCClassMethodList;
@class MKObjCClassPropertyList;
@class MKObjCProtocolList;

NS_ASSUME_NONNULL_BEGIN

//----------------------------------------------------------------------------//
@interface MKObjCCategory : MKOffsetNode {
@package
    MKPointer *_name;
    MKPointerNode *_cls;
    MKPointer *_instanceMethods;
    MKPointer *_classMethods;
    MKPointer *_protocols;
    MKPointer *_instanceProperties;
    MKPointer *_classProperties;
}

@property (nonatomic, readonly) MKPointer<MKCString*> *name;

@property (nonatomic, readonly) MKPointerNode<MKObjCClass*> *cls;

@property (nonatomic, readonly) MKPointer<MKObjCClassMethodList*> *instanceMethods;

@property (nonatomic, readonly) MKPointer<MKObjCClassMethodList*> *classMethods;

@property (nonatomic, readonly) MKPointer<MKObjCProtocolList*> *protocols;

@property (nonatomic, readonly) MKPointer<MKObjCClassPropertyList*> *instanceProperties;

//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//
#pragma mark -  Extended Category Fields
//! @name       Extended Category Fields
//◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦◦//

@property (nonatomic, readonly, nullable) MKPointer<MKObjCClassPropertyList*> *classProperties;

@end

NS_ASSUME_NONNULL_END
