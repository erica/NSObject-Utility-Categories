/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import "NSObject-Utility.h"

@implementation NSObject (UtilityExtension)
- (NSArray *) superclasses
{
	Class cl = [self class];
	NSMutableArray *results = [NSMutableArray arrayWithObject:cl];
	
	do 
	{
		cl = [cl superclass];
		[results addObject:cl];
	}
	while (![cl isEqual:[NSObject class]]) ;
	
	return results;
}

- (const char *) returnTypeForSelector:(SEL)selector
{
	NSMethodSignature *ms = [self methodSignatureForSelector:selector];
	return [ms methodReturnType];
}

// Choose the first selector that an object can respond to
// Thank Kevin Ballard for assist!
- (SEL) chooseSelector: (SEL) aSelector, ...
{
	if ([self respondsToSelector:aSelector]) return aSelector;
	
	va_list selectors;
	va_start(selectors, aSelector);
	SEL selector = va_arg(selectors, SEL);
	while (selector)
	{
		if ([self respondsToSelector:selector]) return selector;
		selector = va_arg(selectors, SEL);
	}
	
	return NULL;
}

// Return an invocation based on a selector and variadic arguments
- (NSInvocation *) invocationWithSelectorAndArguments: (SEL) selector,...
{
	if (![self respondsToSelector:selector]) return NULL;
	
	NSMethodSignature *ms = [self methodSignatureForSelector:selector];
	if (!ms) return NULL;
	
	NSInvocation *inv = [NSInvocation invocationWithMethodSignature:ms];
	if (!inv) return NULL;
	
	[inv setTarget:self];
	[inv setSelector:selector];
	
	int argcount = 2;
	
	va_list arguments;
	va_start(arguments, selector);
	
	while (argcount < [ms numberOfArguments])
	{
		char *argType = (char *)[ms getArgumentTypeAtIndex:argcount];
		if (strcmp(argType, @encode(id)) == 0)
		{
			id argument = va_arg(arguments, id);
			[inv setArgument:&argument atIndex:argcount++];
		}
		else if (
				 (strcmp(argType, @encode(char)) == 0) ||
				 (strcmp(argType, @encode(unsigned char)) == 0) ||
				 (strcmp(argType, @encode(short)) == 0) ||
				 (strcmp(argType, @encode(unsigned short)) == 0) |
				 (strcmp(argType, @encode(int)) == 0) ||
				 (strcmp(argType, @encode(unsigned int)) == 0)
				 )
		{
			int i = va_arg(arguments, int);
			[inv setArgument:&i atIndex:argcount++];
		}
		else if (
				 (strcmp(argType, @encode(long)) == 0) ||
				 (strcmp(argType, @encode(unsigned long)) == 0)
				 )
		{
			long l = va_arg(arguments, long);
			[inv setArgument:&l atIndex:argcount++];
		}
		else if (
				 (strcmp(argType, @encode(long long)) == 0) ||
				 (strcmp(argType, @encode(unsigned long long)) == 0)
				 )
		{
			long long l = va_arg(arguments, long long);
			[inv setArgument:&l atIndex:argcount++];
		}
		else if (
				 (strcmp(argType, @encode(float)) == 0) ||
				 (strcmp(argType, @encode(double)) == 0)
				 )
		{
			double d = va_arg(arguments, double);
			[inv setArgument:&d atIndex:argcount++];
		}
		else if (strcmp(argType, @encode(Class)) == 0)
		{
			Class c = va_arg(arguments, Class);
			[inv setArgument:&c atIndex:argcount++];
		}
		else if (strcmp(argType, @encode(SEL)) == 0)
		{
			SEL s = va_arg(arguments, SEL);
			[inv setArgument:&s atIndex:argcount++];
		}
		else if (strcmp(argType, @encode(char *)) == 0)
		{
			char *s = va_arg(arguments, char *);
			[inv setArgument:s atIndex:argcount++];
		}		
		else
		{
			NSString *type = [NSString stringWithCString:argType];
			if ([type isEqualToString:@"{CGRect={CGPoint=ff}{CGSize=ff}}"])
			{
				CGRect arect = va_arg(arguments, CGRect);
				[inv setArgument:&arect atIndex:argcount++];
			}
			else if ([type isEqualToString:@"{CGPoint=ff}"])
			{
				CGPoint apoint = va_arg(arguments, CGPoint);
				[inv setArgument:&apoint atIndex:argcount++];
			}
			else if ([type isEqualToString:@"{CGSize=ff}"])
			{
				CGSize asize = va_arg(arguments, CGSize);
				[inv setArgument:&asize atIndex:argcount++];
			}
			else
			{
				// assume its a pointer and punt
				NSLog(@"%@", type);
				void *ptr = va_arg(arguments, void *);
				[inv setArgument:ptr atIndex:argcount++];
			}
		}
	}
	va_end(arguments);
	
	if (argcount != [ms numberOfArguments]) 
	{
		printf("Argument count mismatch: %d expected, %d sent\n", [ms numberOfArguments], argcount);
		return NULL;
	}	
	
	return inv;
}

// Perform a selector with an arbitrary number of arguments
// Thanks to Kevin Ballard for assist!
- (BOOL) performSelector: (SEL) selector withReturnValueAndArguments: (void *) result, ...
{
	va_list arglist;
	va_start(arglist, result);
	NSInvocation *inv = [self invocationWithSelectorAndArguments:selector, arglist];
	va_end(arglist);
	
	if (!inv) return NO;

	[inv invoke];
	if (result) [inv getReturnValue:result];	
	return YES;	
}

- (void) delayedInvocationWithReturnValue: (id) result
{
	// private. only sent to an invocation
	NSInvocation *inv = (NSInvocation *) self;
	[inv invoke];
	if (result) [inv getReturnValue:&result];
}

- (void) performSelector: (SEL) selector withDelay: (NSTimeInterval) ti withReturnValueAndArguments: (void *) result, ...
{
	va_list arglist;
	va_start(arglist, result);
	NSInvocation *inv = [self invocationWithSelectorAndArguments:selector, arglist];
	va_end(arglist);
	
	if (!inv) return;
	[inv performSelector:@selector(delayedInvocationWithReturnValue:) withObject:(id) result afterDelay: ti];
}

- (id) objectByPerformingSelectorWithArguments: (SEL) selector, ...
{
	id result;
	va_list arglist;
	va_start(arglist, selector);
	[self performSelector:selector withReturnValueAndArguments:&result, arglist];
	va_end(arglist);
	
	return result;
}

- (id) objectByPerformingSelector:(SEL)selector withObject:(id) object1 withObject: (id) object2
{
	return [self objectByPerformingSelectorWithArguments:selector, object1, object2];
}

- (id) objectByPerformingSelector:(SEL)selector withObject:(id) object1
{
	return [self objectByPerformingSelectorWithArguments:selector, object1];
}

- (id) objectByPerformingSelector:(SEL)selector
{
	return [self objectByPerformingSelectorWithArguments:selector];
}

- (id) valueByPerformingSelectorWithArguments: (SEL) selector, ...
{
	va_list arglist;
	va_start(arglist, selector);
	NSInvocation *inv = [self invocationWithSelectorAndArguments:selector, arglist];
	va_end(arglist);
	
	if (!inv) return nil;
	
	// Place results into value
	void *bytes = malloc(64);
	[inv getReturnValue:bytes];
	const char *returnType = [[inv methodSignature] methodReturnType];
	NSValue *returnValue = [NSValue valueWithBytes: bytes objCType: returnType];
	free(bytes);
	return returnValue;
}

- (id) valueByPerformingSelector:(SEL)selector withObject:(id) object1 withObject: (id) object2
{
	return [self valueByPerformingSelectorWithArguments:selector, object1, object2];
}

- (id) valueByPerformingSelector:(SEL)selector withObject:(id) object1
{
	return [self valueByPerformingSelectorWithArguments:selector, object1];
}

- (id) valueByPerformingSelector:(SEL)selector
{
	return [self valueByPerformingSelectorWithArguments:selector];
}

- (void) performSelector: (SEL) selector withCPointer: (void *) cPointer afterDelay: (NSTimeInterval) delay
{
	NSMethodSignature *ms = [self methodSignatureForSelector:selector];
	NSInvocation *inv = [NSInvocation invocationWithMethodSignature:ms];
	[inv setTarget:self];
	[inv setSelector:selector];
	[inv setArgument:cPointer atIndex:2];
	[inv performSelector:@selector(invoke) withObject:nil afterDelay:delay];
}

- (void) performSelector: (SEL) selector withBool: (BOOL) boolValue afterDelay: (NSTimeInterval) delay
{
	[self performSelector:selector withCPointer:&boolValue afterDelay:delay];
}

- (void) performSelector: (SEL) selector withInt: (int) intValue afterDelay: (NSTimeInterval) delay
{
	[self performSelector:selector withCPointer:&intValue afterDelay:delay];
}

- (void) performSelector: (SEL) selector withFloat: (float) floatValue afterDelay: (NSTimeInterval) delay
{
	[self performSelector:selector withCPointer:&floatValue afterDelay:delay];
}

- (void) performSelector: (SEL) selector afterDelay: (NSTimeInterval) ti
{
	[self performSelector:selector withObject:nil afterDelay: ti];
}
@end


