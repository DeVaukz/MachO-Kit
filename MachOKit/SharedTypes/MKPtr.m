//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKPtr.m
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

#import "MKPtr.h"
#import "MKInternal.h"
#import "MKPointer.h"
#import "MKBackedNode+Pointer.h"

#define POINTEE_FLAGS_MASK              (uintptr_t)(7U)
#define POINTEE_VALUE(in)               (id)(in & ~POINTEE_FLAGS_MASK)

#define HAS_ATTEMPTED_RESOLUTION        (1U<<0)
#define HAS_INIT_CONTEXT                (1U<<1)
#define HAS_TARGET                      (1U<<2)

NSString * const MKInitializationContextTargetClass = @"MKInitializationContextTargetClass";
NSString * const MKInitializationContextDeferredProvider = @"MKInitializationContextDeferredProvider";

//|++++++++++++++++++++++++++++++++++++|//
bool
MKPtrInitialize(struct MKPtr *ptr, MKBackedNode *node, mk_vm_address_t addr, NSDictionary *ctx, __unused NSError **error)
{
    NSCParameterAssert(node && [node isKindOfClass:MKBackedNode.class]);
    
    ptr->parent = node;
    ptr->address = addr;
    
    if (ctx) {
        ptr->__opaque = (uintptr_t)[ctx retain];
        ptr->__opaque |= HAS_INIT_CONTEXT;
    }
    
    return true;
}

//|++++++++++++++++++++++++++++++++++++|//
void
MKPtrDestory(struct MKPtr *ptr)
{
    if (ptr->__opaque & (HAS_TARGET | HAS_INIT_CONTEXT))
        [POINTEE_VALUE(ptr->__opaque) release];
}

//|++++++++++++++++++++++++++++++++++++|//
Class
MKPtrTargetClass(struct MKPtr *ptr)
{
    if (ptr->__opaque & HAS_TARGET)
        return [[POINTEE_VALUE(ptr->__opaque) value] class];
    else if (ptr->__opaque & HAS_INIT_CONTEXT)
        return [POINTEE_VALUE(ptr->__opaque) objectForKey:MKInitializationContextTargetClass];
    else
        return NULL;
}

//|++++++++++++++++++++++++++++++++++++|//
MKOptional*
MKPtrPointee(struct MKPtr *ptr)
{
    if (ptr->address != 0x0 && (ptr->__opaque & HAS_ATTEMPTED_RESOLUTION) == 0x0) {
        MKOptional<__kindof MKBackedNode*> *pointee;
        MKBackedNode *parent = ptr->parent;
        NSDictionary *context = nil;
        
        if (ptr->__opaque & HAS_INIT_CONTEXT)
            // No need to release opaque here, we will release context after
            // initializing the pointee.
            context = POINTEE_VALUE(ptr->__opaque);
        
        // Walk up the parent chain until we find a node containing the address.
        while (parent && [parent.parent isKindOfClass:MKBackedNode.class]) {
            if (parent.nodeSize == 0)
                break;
            
            mk_vm_range_t parent_range = mk_vm_range_make(parent.nodeVMAddress, parent.nodeSize);
            if (mk_vm_range_contains_address(parent_range, 0, ptr->address) == MK_ESUCCESS)
                break;
            
            parent = (MKBackedNode*)parent.parent;
        }
        
        MKDeferredContextProvider deferredContextProvider = context[MKInitializationContextDeferredProvider];
        if (deferredContextProvider) {
            MKOptional<NSDictionary*> *deferredContext = deferredContextProvider();
            if (deferredContext.value) {
                NSMutableDictionary *newContext = [context mutableCopy];
                [newContext addEntriesFromDictionary:deferredContext.value];
                [context release];
                context = newContext;
            } else if (deferredContext.error) {
                pointee = [MKOptional optionalWithError:deferredContext.error];
                goto done;
            }
        }
        
        NSMutableDictionary *previousContext = [[NSMutableDictionary alloc] init];
        [context enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, __unused BOOL *stop) {
            NSMutableDictionary *threadDict = NSThread.currentThread.threadDictionary;
            [previousContext setValue:threadDict[key] forKey:key];
            threadDict[key] = obj;
        }];
        
        Class targetClass = context[MKInitializationContextTargetClass];
        pointee = [parent childNodeAtVMAddress:ptr->address targetClass:targetClass];
        if (pointee.value) {
            ptr->__opaque = (uintptr_t)[pointee retain];
            ptr->__opaque |= HAS_TARGET;
        }
        
        [context enumerateKeysAndObjectsUsingBlock:^(NSString *key, __unused id obj, __unused BOOL *stop) {
            NSMutableDictionary *threadDict = NSThread.currentThread.threadDictionary;
            threadDict[key] = previousContext[key];
        }];
        
    done:
        ptr->__opaque |= HAS_ATTEMPTED_RESOLUTION;
        [context release];
    }
    
    // TODO - If there was an error during resolution, we should always
    // return an MKOptional wrapping the error.
    if (ptr->__opaque & HAS_TARGET)
        return POINTEE_VALUE(ptr->__opaque);
    else
        return MKOptional.optional;
}
