/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import "NSObject-Utilities.h"
#import <objc/objc-runtime.h>

@implementation NSObject (Utilities)

// Return an array of an object's superclasses
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

// Return an invocation based on a selector and variadic arguments
- (NSInvocation *) invocationWithSelector: (SEL) selector andArguments:(va_list) arguments
{
	if (![self respondsToSelector:selector]) return NULL;
	
	NSMethodSignature *ms = [self methodSignatureForSelector:selector];
	if (!ms) return NULL;
	
	NSInvocation *inv = [NSInvocation invocationWithMethodSignature:ms];
	if (!inv) return NULL;
	
	[inv setTarget:self];
	[inv setSelector:selector];
	
	int argcount = 2;
	int totalArgs = [ms numberOfArguments];
	
	while (argcount < totalArgs)
	{
		char *argtype = (char *)[ms getArgumentTypeAtIndex:argcount];
		// printf("[%s] %d of %d\n", [NSStringFromSelector(selector) UTF8String], argcount, totalArgs); // debug
		if (strcmp(argtype, @encode(id)) == 0)
		{
			id argument = va_arg(arguments, id);
			[inv setArgument:&argument atIndex:argcount++];
		}
		else if (
				 (strcmp(argtype, @encode(char)) == 0) ||
				 (strcmp(argtype, @encode(unsigned char)) == 0) ||
				 (strcmp(argtype, @encode(short)) == 0) ||
				 (strcmp(argtype, @encode(unsigned short)) == 0) |
				 (strcmp(argtype, @encode(int)) == 0) ||
				 (strcmp(argtype, @encode(unsigned int)) == 0)
				 )
		{
			int i = va_arg(arguments, int);
			[inv setArgument:&i atIndex:argcount++];
		}
		else if (
				 (strcmp(argtype, @encode(long)) == 0) ||
				 (strcmp(argtype, @encode(unsigned long)) == 0)
				 )
		{
			long l = va_arg(arguments, long);
			[inv setArgument:&l atIndex:argcount++];
		}
		else if (
				 (strcmp(argtype, @encode(long long)) == 0) ||
				 (strcmp(argtype, @encode(unsigned long long)) == 0)
				 )
		{
			long long l = va_arg(arguments, long long);
			[inv setArgument:&l atIndex:argcount++];
		}
		else if (
				 (strcmp(argtype, @encode(float)) == 0) ||
				 (strcmp(argtype, @encode(double)) == 0)
				 )
		{
			double d = va_arg(arguments, double);
			[inv setArgument:&d atIndex:argcount++];
		}
		else if (strcmp(argtype, @encode(Class)) == 0)
		{
			Class c = va_arg(arguments, Class);
			[inv setArgument:&c atIndex:argcount++];
		}
		else if (strcmp(argtype, @encode(SEL)) == 0)
		{
			SEL s = va_arg(arguments, SEL);
			[inv setArgument:&s atIndex:argcount++];
		}
		else if (strcmp(argtype, @encode(char *)) == 0)
		{
			char *s = va_arg(arguments, char *);
			[inv setArgument:s atIndex:argcount++];
		}		
		else
		{
			NSString *type = [NSString stringWithCString:argtype encoding:NSUTF8StringEncoding];
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
	
	if (argcount != totalArgs) 
	{
		printf("Invocation argument count mismatch: %d expected, %d sent\n", [ms numberOfArguments], argcount);
		return NULL;
	}
	
	return inv;
}

// Return an invocation with the given arguments
- (NSInvocation *) invocationWithSelectorAndArguments: (SEL) selector, ...
{
	va_list arglist;
	va_start(arglist, selector);
	NSInvocation *inv = [self invocationWithSelector:selector andArguments:arglist];
	va_end(arglist);
	return inv;	
}

// Peform the selector using va_list arguments
- (BOOL) performSelector: (SEL) selector withReturnValue: (void *) result andArguments: (va_list) arglist
{
	NSInvocation *inv = [self invocationWithSelector:selector andArguments:arglist];
	if (!inv) return NO;
	[inv invoke];
	if (result) [inv getReturnValue:result];
	return YES;	
}

// Perform a selector with an arbitrary number of arguments
// Thanks to Kevin Ballard for assist!
- (BOOL) performSelector: (SEL) selector withReturnValueAndArguments: (void *) result, ...
{
	va_list arglist;
	va_start(arglist, result);
	NSInvocation *inv = [self invocationWithSelector:selector andArguments:arglist];
	if (!inv) return NO;
	[inv invoke];
	if (result) [inv getReturnValue:result];
	va_end(arglist);
	return YES;		
}

// Returning objects by performing selectors
- (id) objectByPerformingSelectorWithArguments: (SEL) selector, ...
{
	id result;
	va_list arglist;
	va_start(arglist, selector);
	[self performSelector:selector withReturnValue:&result andArguments:arglist];
	va_end(arglist);
	
	CFShow(result);
	return result;
}
/*
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
} */

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
		return [NSString stringWithCString:s encoding:NSUTF8StringEncoding];
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

// Delayed selectors
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

- (void) performSelector: (SEL) selector afterDelay: (NSTimeInterval) delay
{
	[self performSelector:selector withObject:nil afterDelay: delay];
}

// private. only sent to an invocation
- (void) getReturnValue: (void *) result
{
	NSInvocation *inv = (NSInvocation *) self;
	[inv invoke];
	if (result) [inv getReturnValue:result];
}

// Delayed selector
- (void) performSelector: (SEL) selector withDelayAndArguments: (NSTimeInterval) delay,...
{
	va_list arglist;
	va_start(arglist, delay);
	NSInvocation *inv = [self invocationWithSelector:selector andArguments:arglist];
	va_end(arglist);
	
	if (!inv) return;
	[inv performSelector:@selector(invoke) afterDelay:delay];
}

#pragma mark values
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


// Return an array of all an object's selectors
+ (NSArray *) getSelectorListForClass
{
	NSMutableArray *selectors = [NSMutableArray array];
	unsigned int num;
	Method *methods = class_copyMethodList(self, &num);
	for (int i = 0; i < num; i++)
		[selectors addObject:NSStringFromSelector(method_getName(methods[i]))];
	free(methods);
	return selectors;
}

// Return a dictionary with class/selectors entries, all the way up to NSObject
- (NSDictionary *) selectors
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	[dict setObject:[[self class] getSelectorListForClass] forKey:NSStringFromClass([self class])];
	for (Class cl in [self superclasses])
		[dict setObject:[cl getSelectorListForClass] forKey:NSStringFromClass(cl)];
	return dict;
}

// Return an array of all an object's properties
+ (NSArray *) getPropertyListForClass
{
	NSMutableArray *propertyNames = [NSMutableArray array];
	unsigned int num;
	objc_property_t *properties = class_copyPropertyList(self, &num);
	for (int i = 0; i < num; i++)
		[propertyNames addObject:[NSString stringWithCString:property_getName(properties[i]) encoding:NSUTF8StringEncoding]];
	free(properties);
	return propertyNames;
}

// Return a dictionary with class/selectors entries, all the way up to NSObject
- (NSDictionary *) properties
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	[dict setObject:[[self class] getPropertyListForClass] forKey:NSStringFromClass([self class])];
	for (Class cl in [self superclasses])
		[dict setObject:[cl getPropertyListForClass] forKey:NSStringFromClass(cl)];
	return dict;
}

// Return an array of all an object's properties
+ (NSArray *) getIvarListForClass
{
	NSMutableArray *ivarNames = [NSMutableArray array];
	unsigned int num;
	Ivar *ivars = class_copyIvarList(self, &num);
	for (int i = 0; i < num; i++)
		[ivarNames addObject:[NSString stringWithCString:ivar_getName(ivars[i]) encoding:NSUTF8StringEncoding]];
	free(ivars);
	return ivarNames;
}

// Return a dictionary with class/selectors entries, all the way up to NSObject
- (NSDictionary *) ivars
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	[dict setObject:[[self class] getIvarListForClass] forKey:NSStringFromClass([self class])];
	for (Class cl in [self superclasses])
		[dict setObject:[cl getIvarListForClass] forKey:NSStringFromClass(cl)];
	return dict;
}

// Return an array of all an object's properties
+ (NSArray *) getProtocolListForClass
{
	NSMutableArray *protocolNames = [NSMutableArray array];
	unsigned int num;
	Protocol **protocols = class_copyProtocolList(self, &num);
	for (int i = 0; i < num; i++)
		[protocolNames addObject:[NSString stringWithCString:protocol_getName(protocols[i]) encoding:NSUTF8StringEncoding]];
	free(protocols);
	return protocolNames;
}

// Return a dictionary with class/selectors entries, all the way up to NSObject
- (NSDictionary *) protocols
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	[dict setObject:[[self class] getProtocolListForClass] forKey:NSStringFromClass([self class])];
	for (Class cl in [self superclasses])
		[dict setObject:[cl getProtocolListForClass] forKey:NSStringFromClass(cl)];
	return dict;
}

// Runtime checks of properties, etc.
- (BOOL) hasProperty: (NSString *) propertyName
{
	NSMutableSet *set = [NSMutableSet set];
	NSDictionary *dict = self.properties;
	for (NSArray *properties in [dict allValues])
		[set addObjectsFromArray:properties];
	return [set containsObject:propertyName];
}

- (BOOL) hasIvar: (NSString *) ivarName
{
	NSMutableSet *set = [NSMutableSet set];
	NSDictionary *dict = self.ivars;
	for (NSArray *ivars in [dict allValues])
		[set addObjectsFromArray:ivars];
	return [set containsObject:ivarName];
}

+ (BOOL) classExists: (NSString *) className
{
	return (NSClassFromString(className) != nil);
}

+ (id) instanceOfClassNamed: (NSString *) className
{
	if (NSClassFromString(className) != nil)
		return [[[NSClassFromString(className) alloc] init] autorelease];
	else 
		return nil;
}

// Return a C-string with a selector's return type
// may extend this idea to return a class
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

// Perform the selector if possible, returning any return value. Otherwise return nil.
- (id) tryPerformSelector: (SEL) aSelector withObject: (id) object1 withObject: (id) object2
{
	return ([self respondsToSelector:aSelector]) ? [self performSelector:aSelector withObject: object1 withObject: object2] : nil;
}
- (id) tryPerformSelector: (SEL) aSelector withObject: (id) object1
{
	return [self tryPerformSelector:aSelector withObject:object1 withObject:nil];
}
- (id) tryPerformSelector: (SEL) aSelector
{
	return [self tryPerformSelector:aSelector withObject:nil withObject:nil];
}


@end


