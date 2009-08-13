/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import "NSObject-Utility.h"

@implementation NSObject (UtilityExtension)
- (const char *) returnTypeForSelector:(SEL)selector
{
	NSMethodSignature *ms = [self methodSignatureForSelector:selector];
	return [ms methodReturnType];
}

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


// Thanks to Kevin Ballard for assist!
- (BOOL) performSelector: (SEL) selector withReturnValueAndArguments: (void *) result, ...
{
	if (![self respondsToSelector:selector]) return NO;
	
	NSMethodSignature *ms = [self methodSignatureForSelector:selector];
	if (!ms) return NO;
	
	NSInvocation *inv = [NSInvocation invocationWithMethodSignature:ms];
	if (!inv) return NO;
	
	[inv setTarget:self];
	[inv setSelector:selector];
	
	int argcount = 2;
	
	va_list arguments;
	va_start(arguments, result);

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
		return NO;
	}
	
	[inv invoke];
	if (result) [inv getReturnValue:result];	
	return YES;	
}

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
@end
