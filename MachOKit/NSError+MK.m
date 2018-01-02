//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             NSError+MK.m
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

#import "NSError+MK.h"
#import "MKInternal.h"

NSString * const MKErrorDomain = @"MKErrorDomain";
NSString * const MKPropertyKey = @"MKPropertyKey";

//----------------------------------------------------------------------------//
@implementation NSError (MK)

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)mk_errorWithDomain:(NSString*)domain code:(NSInteger)code description:(NSString*)description, ...
{
    va_list ap;
    va_start(ap, description);
    CFStringRef str = CFStringCreateWithFormatAndArguments(NULL, NULL, (CFStringRef)description, ap);
    va_end(ap);
    
    NSError *error = [self _mk_errorWithDomain:domain code:code property:nil underlyingError:nil description:(NSString*)str reason:nil];
	
	CFRelease(str);
	return error;
}

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)mk_errorWithDomain:(NSString*)domain code:(NSInteger)code description:(nullable NSString*)description reason:(nullable NSString*)reason, ...
{
    va_list ap;
    va_start(ap, reason);
    CFStringRef str = CFStringCreateWithFormatAndArguments(NULL, NULL, (CFStringRef)reason, ap);
    va_end(ap);
    
    NSError *error = [self _mk_errorWithDomain:domain code:code property:nil underlyingError:nil description:description reason:(NSString*)str];
	
	CFRelease(str);
	return error;
}

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)mk_errorWithDomain:(NSString*)domain code:(NSInteger)code property:(NSString*)property description:(NSString*)description, ...
{
    va_list ap;
    va_start(ap, description);
    CFStringRef str = CFStringCreateWithFormatAndArguments(NULL, NULL, (CFStringRef)description, ap);
    va_end(ap);
    
    NSError *error = [self _mk_errorWithDomain:domain code:code property:property underlyingError:nil description:(NSString*)str reason:nil];
	
	CFRelease(str);
	return error;
}

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)mk_errorWithDomain:(NSString*)domain code:(NSInteger)code property:(NSString*)property description:(NSString*)description reason:(NSString*)reason, ...
{
	va_list ap;
	va_start(ap, reason);
	CFStringRef str = CFStringCreateWithFormatAndArguments(NULL, NULL, (CFStringRef)reason, ap);
	va_end(ap);
	
	NSError *error = [self _mk_errorWithDomain:domain code:code property:property underlyingError:nil description:description reason:(NSString*)str];
	
	CFRelease(str);
	return error;
}

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)mk_errorWithDomain:(NSString*)domain underlyingError:(NSError*)underlyingError description:(NSString*)description, ...
{
	NSParameterAssert(underlyingError);
	
	va_list ap;
	va_start(ap, description);
	CFStringRef str = CFStringCreateWithFormatAndArguments(NULL, NULL, (CFStringRef)description, ap);
	va_end(ap);
	
	NSError *error = [self _mk_errorWithDomain:domain code:underlyingError.code property:nil underlyingError:underlyingError description:(NSString*)str reason:nil];
	
	CFRelease(str);
	return error;
}

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)mk_errorWithDomain:(NSString*)domain code:(NSInteger)code underlyingError:(NSError*)underlyingError description:(NSString*)description, ...
{
    va_list ap;
    va_start(ap, description);
    CFStringRef str = CFStringCreateWithFormatAndArguments(NULL, NULL, (CFStringRef)description, ap);
    va_end(ap);
    
	NSError *error = [self _mk_errorWithDomain:domain code:code property:nil underlyingError:underlyingError description:(NSString*)str reason:nil];
	
	CFRelease(str);
	return error;
}

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)mk_errorWithDomain:(NSString*)domain code:(NSInteger)code property:(NSString*)property underlyingError:(NSError*)underlyingError description:(NSString*)description, ...
{
    va_list ap;
    va_start(ap, description);
    CFStringRef str = CFStringCreateWithFormatAndArguments(NULL, NULL, (CFStringRef)description, ap);
    va_end(ap);
    
	NSError *error = [self _mk_errorWithDomain:domain code:code property:property underlyingError:underlyingError description:(NSString*)str reason:nil];
	
	CFRelease(str);
	return error;
}

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)mk_errorWithDomain:(NSString*)domain code:(NSInteger)code property:(NSString*)property underlyingError:(NSError*)underlyingError description:(NSString*)description reason:(NSString*)reason, ...;
{
	va_list ap;
	va_start(ap, reason);
	CFStringRef str = CFStringCreateWithFormatAndArguments(NULL, NULL, (CFStringRef)reason, ap);
	va_end(ap);
	
	NSError *error = [self _mk_errorWithDomain:domain code:code property:property underlyingError:underlyingError description:description reason:(NSString*)str];
	
	CFRelease(str);
	return error;
}

//|++++++++++++++++++++++++++++++++++++|//
+ (instancetype)_mk_errorWithDomain:(NSString*)domain code:(NSInteger)code property:(NSString*)property underlyingError:(NSError*)underlyingError description:(NSString*)description reason:(NSString*)reason
{
	NSUInteger count = 0;
	NSString *keys[4];
	id values[4];
	
	if (property != nil) {
		keys[count] = MKPropertyKey;
		values[count] = property;
		count++;
	}
	
	if (underlyingError != nil) {
		keys[count] = NSUnderlyingErrorKey;
		values[count] = underlyingError;
		count++;
	}
	
	if (description != nil) {
		keys[count] = NSLocalizedDescriptionKey;
		values[count] = description;
		count++;
	}
	
	if (reason != nil) {
		keys[count] = NSLocalizedFailureReasonErrorKey;
		values[count] = reason;
		count++;
	}
	
	NSDictionary *userInfo = [[NSDictionary alloc] initWithObjects:values forKeys:keys count:count];
	
	NSError *error = [NSError errorWithDomain:domain code:code userInfo:userInfo];
	
	[userInfo release];
	
	return error;
}

//|++++++++++++++++++++++++++++++++++++|//
- (NSString*)mk_property
{ return self.userInfo[MKPropertyKey]; }

@end
