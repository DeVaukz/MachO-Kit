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

#define OPAQUE_RESERVED_MASK            (uintptr_t)(7U)
	#define OPAQUE_FLAGS_MASK   		(uintptr_t)(1U)
	#define OPAQUE_DISCRIMINATOR_MASK   (uintptr_t)(6U)

#define OPAQUE_GET_VALUE(o)            	(id)(o & ~OPAQUE_RESERVED_MASK)
#define OPAQUE_GET_FLAGS(o)				(unsigned)(o & OPAQUE_FLAGS_MASK)
#define OPAQUE_GET_DISCRIMINATOR(o)		(unsigned)((o & OPAQUE_DISCRIMINATOR_MASK) >> OPAQUE_FLAGS_MASK)

#define OPAQUE_WITH_VALUE(o, val, dsc)  	(uintptr_t)( \
	((uintptr_t)(val) & ~OPAQUE_RESERVED_MASK) | \
	(((uintptr_t)dsc << OPAQUE_FLAGS_MASK) & OPAQUE_DISCRIMINATOR_MASK) | \
	(o & OPAQUE_FLAGS_MASK) \
)
#define OPAQUE_WITH_FLAGS(o, flags)			(uintptr_t)( \
	((uintptr_t)flags & OPAQUE_FLAGS_MASK) | \
	(o & ~OPAQUE_FLAGS_MASK) \
)

/* FLAGS */
#define HAS_ATTEMPTED_RESOLUTION        (1U<<0)
/* DISCRIMINATORS */
#define DISCRIMINATOR_NONE				(0U)
#define DISCRIMINATOR_CONTEXT      		(1U)
#define DISCRIMINATOR_CLASS      		(2U)
#define DISCRIMINATOR_POINTEE           (3U)

NSString * const MKInitializationContextTargetClass = @"MKInitializationContextTargetClass";
NSString * const MKInitializationContextDeferredProvider = @"MKInitializationContextDeferredProvider";

NSString * const MKInitializationContextErrorKey = @"MKInitializationContextErrorKey";

//|++++++++++++++++++++++++++++++++++++|//
bool
MKPtrInitialize(struct MKPtr *ptr, MKBackedNode *node, mk_vm_address_t addr, NSDictionary *ctx, __unused NSError **error)
{
    NSCParameterAssert([node isKindOfClass:MKBackedNode.class]);
    
    ptr->parent = node;
    ptr->address = addr;
    if (ctx)
		ptr->__opaque = OPAQUE_WITH_VALUE(0, [ctx retain], DISCRIMINATOR_CONTEXT);
    
    return true;
}

//|++++++++++++++++++++++++++++++++++++|//
void
MKPtrDestory(struct MKPtr *ptr)
{
    if (OPAQUE_GET_DISCRIMINATOR(ptr->__opaque) == DISCRIMINATOR_CONTEXT ||
		OPAQUE_GET_DISCRIMINATOR(ptr->__opaque) == DISCRIMINATOR_POINTEE)
        [OPAQUE_GET_VALUE(ptr->__opaque) release];
}

//|++++++++++++++++++++++++++++++++++++|//
Class
MKPtrTargetClass(struct MKPtr *ptr)
{
	switch (OPAQUE_GET_DISCRIMINATOR(ptr->__opaque)) {
		case DISCRIMINATOR_CONTEXT:
			return [OPAQUE_GET_VALUE(ptr->__opaque) objectForKey:MKInitializationContextTargetClass];
		case DISCRIMINATOR_CLASS:
			return OPAQUE_GET_VALUE(ptr->__opaque);
		case DISCRIMINATOR_POINTEE: {
			MKOptional *pointee = OPAQUE_GET_VALUE(ptr->__opaque);
			if (pointee.value)
				return [pointee.value class];
			else if (pointee.error)
				return pointee.error.userInfo[MKInitializationContextErrorKey][MKInitializationContextTargetClass];
			else
				return NULL;
		}
		default:
			return NULL;
	}
}

//|++++++++++++++++++++++++++++++++++++|//
MKOptional*
MKPtrPointee(struct MKPtr *ptr)
{
// Silence the analyzer - the analyzer gets confused because it doesn't see
// ptr->__opaque as holding a strong reference.  So it incorrectly reports leaks.
#ifndef __clang_analyzer__
    if (ptr->address != 0x0 && (OPAQUE_GET_FLAGS(ptr->__opaque) & HAS_ATTEMPTED_RESOLUTION) == 0) {
		MKOptional<MKBackedNode*> *boundingNode;
		MKOptional<MKBackedNode*> *pointee;
        NSDictionary *context = nil;
        
		if (OPAQUE_GET_DISCRIMINATOR(ptr->__opaque) == DISCRIMINATOR_CONTEXT) {
            // Do not retain context here.  We are assuming ownership of the existing
			// strong reference.
            context = OPAQUE_GET_VALUE(ptr->__opaque);
		}
		
		// Retrieve the deferred context.
		MKDeferredContextProvider deferredContextProvider = context[MKInitializationContextDeferredProvider];
		if (deferredContextProvider) {
			MKOptional<NSDictionary*> *deferredContext = deferredContextProvider();
			if (deferredContext.value) {
				NSMutableDictionary *newContext = [context mutableCopy];
				[newContext addEntriesFromDictionary:deferredContext.value];
				[context release];
				context = newContext;
			} else if (deferredContext.error) {
				NSString *description = @"Deferred context provider returned an error.";
				NSError *underlyingError = deferredContext.error;
				
				NSString *keys[3]; id values[3]; NSUInteger count = 0;
				if (description) keys[count] = NSLocalizedDescriptionKey; values[count] = description; count++;
				if (underlyingError) keys[count] = NSUnderlyingErrorKey; values[count] = underlyingError; count++;
				if (context) keys[count] = MKInitializationContextErrorKey; values[count] = context; count++;
				NSDictionary *userInfo = [[NSDictionary alloc] initWithObjects:values forKeys:keys count:count];
				
				NSError *error = [[NSError alloc] initWithDomain:MKErrorDomain code:MK_EINTERNAL_ERROR userInfo:userInfo];
				
				pointee = [[MKOptional optionalWithError:error] retain];
				
				[error release];
				[userInfo release];
				
				goto done;
			} else {
				// Use the original context
			}
		}
		
		// Walk up the parent chain until we find a node containing the address.
		boundingNode = [ptr->parent ancestorNodeOccupyingAddress:ptr->address type:MKNodeVMAddress targetClass:NULL includeReceiver:YES];
		// Failing to find a bounding node is *NOT* an error.  Only raise an error if
		// an error was encountered during the search.
		if (boundingNode.error) {
			NSString *description = [[NSString alloc] initWithFormat:@"Error locating an ancestor of %@ that contains the target address [%" MK_VM_PRIxADDR "].", ptr->parent, ptr->address];
			NSError *underlyingError = boundingNode.error;
			
			NSString *keys[3]; id values[3]; NSUInteger count = 0;
			if (description) keys[count] = NSLocalizedDescriptionKey; values[count] = description; count++;
			if (underlyingError) keys[count] = NSUnderlyingErrorKey; values[count] = underlyingError; count++;
			if (context) keys[count] = MKInitializationContextErrorKey; values[count] = context; count++;
			NSDictionary *userInfo = [[NSDictionary alloc] initWithObjects:values forKeys:keys count:count];
			
			NSError *error = [[NSError alloc] initWithDomain:MKErrorDomain code:MK_ENOT_FOUND userInfo:userInfo];
			
			pointee = [[MKOptional optionalWithError:error] retain];
			
			[error release];
			[userInfo release];
			[description release];
			
			goto done;
		}
        
        NSMutableDictionary *previousContext = [[NSMutableDictionary alloc] init];
        [context enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, __unused BOOL *stop) {
            NSMutableDictionary *threadDict = NSThread.currentThread.threadDictionary;
            [previousContext setValue:threadDict[key] forKey:key];
            threadDict[key] = obj;
        }];
        
        Class targetClass = context[MKInitializationContextTargetClass];
        NSCAssert(targetClass == nil || [targetClass isSubclassOfClass:MKNode.class], @"The target class of a pointer must be an MKNode, not %@.", NSStringFromClass(targetClass));
        pointee = [[boundingNode.value childNodeAtVMAddress:ptr->address targetClass:targetClass] retain];
        
        [context enumerateKeysAndObjectsUsingBlock:^(NSString *key, __unused id obj, __unused BOOL *stop) {
            NSMutableDictionary *threadDict = NSThread.currentThread.threadDictionary;
            threadDict[key] = previousContext[key];
        }];
		
    done:
		if (pointee == nil || pointee.none) {
			// If we did not find a pointee or encounter an error, save away the target
			// class (if there is one) for any further calls to MKPtrTargetClass().
			ptr->__opaque = OPAQUE_WITH_VALUE(HAS_ATTEMPTED_RESOLUTION, context[MKInitializationContextTargetClass], DISCRIMINATOR_CLASS);
			// Need to release 'pointee' because it may be an empty MKOptional.
			[pointee release];
        } else {
			ptr->__opaque = OPAQUE_WITH_VALUE(HAS_ATTEMPTED_RESOLUTION, pointee, DISCRIMINATOR_POINTEE);
        }
		
		[context release];
    }
#endif // silence analyzer
	
    if (OPAQUE_GET_DISCRIMINATOR(ptr->__opaque) == DISCRIMINATOR_POINTEE)
        return OPAQUE_GET_VALUE(ptr->__opaque);
    else
        return MKOptional.optional;
}
