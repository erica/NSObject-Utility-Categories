/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import "NSObject-Value.h"

// possibly someday write: performSelectorWithValue:(NSValue *)aValue
// and if it is an int, for example, would call foo:(int)realvalue

@implementation NSObject (ValueExtension)
- (id) objectByPerformingSelector:(SEL)selector withObject:(id) object1 withObject: (id) object2
{
	if (![self respondsToSelector:selector]) return nil;
		
	// Retrieve method signature and return type
	NSMethodSignature *ms = [self methodSignatureForSelector:selector];
	const char *returnType = [ms methodReturnType];
	
	// Create invocation using method signature and invoke it
	NSInvocation *inv = [NSInvocation invocationWithMethodSignature:ms];
	[inv setTarget:self];
	[inv setSelector:selector];
	if (object1) [inv setArgument:&object1 atIndex:2];
	if (object2) [inv setArgument:&object2 atIndex:3];
	[inv invoke];
	
	// return object
	if (strcmp(returnType, @encode(id)) == 0)
	{
		id riz = nil;
		[inv getReturnValue:&riz];
		return riz;
	}
	
	// return double
	if ((strcmp(returnType, @encode(float)) == 0) ||
		(strcmp(returnType, @encode(double)) == 0))
	{
		double f;
		[inv getReturnValue:&f];
		return [NSNumber numberWithDouble:f];
	}
	
	// return NSNumber version of byte. Use valueBy version for recovering chars
	if ((strcmp(returnType, @encode(char)) == 0) ||
		(strcmp(returnType, @encode(unsigned char)) == 0))
	{
		unsigned char c;
		[inv getReturnValue:&c];
		return [NSNumber numberWithInt:(unsigned int)c];
	}
	
	// return c-string
	if (strcmp(returnType, @encode (char*)) == 0)
	{
		char *s;
		[inv getReturnValue:s];
		return [NSString stringWithCString:s];
	}
	
	// return integer
	long l;
	[inv getReturnValue:&l];
	return [NSNumber numberWithLong:l];
}

- (id) objectByPerformingSelector:(SEL)selector withObject:(id) object1
{
	return [self objectByPerformingSelector:selector withObject:object1 withObject:nil];
}

- (id) objectByPerformingSelector:(SEL)selector
{
	return [self objectByPerformingSelector:selector withObject:nil withObject:nil];
}


- (id) valueByPerformingSelector:(SEL)selector withObject:(id) object1 withObject: (id) object2
{
	if (![self respondsToSelector:selector]) return nil;
	
	// Retrieve method signature and return type
	NSMethodSignature *ms = [self methodSignatureForSelector:selector];
	const char *returnType = [ms methodReturnType];
	
	// Create invocation using method signature and invoke it
	NSInvocation *inv = [NSInvocation invocationWithMethodSignature:ms];
	[inv setTarget:self];
	[inv setSelector:selector];
	if (object1) [inv setArgument:&object1 atIndex:2];
	if (object2) [inv setArgument:&object2 atIndex:3];
	[inv invoke];
	
	
	// Place results into value
	 void *bytes = malloc(16);
	 [inv getReturnValue:bytes];
	 NSValue *returnValue = [NSValue valueWithBytes: bytes objCType: returnType];
	 free(bytes);
	 return returnValue;
}

- (id) valueByPerformingSelector:(SEL)selector withObject:(id) object1
{
	return [self valueByPerformingSelector:selector withObject:object1 withObject:nil];
}

- (id) valueByPerformingSelector:(SEL)selector
{
	return [self valueByPerformingSelector:selector withObject:nil withObject:nil];
}
@end
