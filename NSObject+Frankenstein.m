/*
 
 Erica Sadun, http://ericasadun.com
 
 */


#import "NSObject+Frankenstein.h"
@import ObjectiveC;

// add category on NSObject to performBlockAfterDelay:block: ??

@implementation NSObject (Frankenstein)

#pragma mark - Superclasses

+ (NSArray *) superclasses
{
    Class theClass = self;
    NSMutableArray *results = [NSMutableArray arrayWithObject:theClass];
    
    do
    {
        theClass = [theClass superclass];
        [results addObject:theClass];
    }
    while (![theClass isEqual:[NSObject class]]) ;
    
    return results;
}

// Return an array of an object's superclasses
- (NSArray *) superclasses
{
    return [[self class] superclasses];
}

#pragma mark - Selectors

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
		else if (strcmp(argtype, @encode(CGRect)) == 0)
        {
            CGRect arg = va_arg(arguments, CGRect);
            [inv setArgument:&arg atIndex:argcount++];
        }
		else if (strcmp(argtype, @encode(CGPoint)) == 0)
        {
            CGPoint arg = va_arg(arguments, CGPoint);
            [inv setArgument:&arg atIndex:argcount++];
        }
		else if (strcmp(argtype, @encode(CGSize)) == 0)
        {
            CGSize arg = va_arg(arguments, CGSize);
            [inv setArgument:&arg atIndex:argcount++];
        }
		else if (strcmp(argtype, @encode(CGAffineTransform)) == 0)
        {
            CGAffineTransform arg = va_arg(arguments, CGAffineTransform);
            [inv setArgument:&arg atIndex:argcount++];
        }
		else if (strcmp(argtype, @encode(NSRange)) == 0)
        {
            NSRange arg = va_arg(arguments, NSRange);
            [inv setArgument:&arg atIndex:argcount++];
        }
		else if (strcmp(argtype, @encode(UIOffset)) == 0)
        {
            UIOffset arg = va_arg(arguments, UIOffset);
            [inv setArgument:&arg atIndex:argcount++];
        }
		else if (strcmp(argtype, @encode(UIEdgeInsets)) == 0)
        {
            UIEdgeInsets arg = va_arg(arguments, UIEdgeInsets);
            [inv setArgument:&arg atIndex:argcount++];
        }
        else
        {
            // assume its a pointer and punt
            NSLog(@"Punting... %s", argtype);
            void *ptr = va_arg(arguments, void *);
            [inv setArgument:ptr atIndex:argcount++];
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
	if (result)
        [inv getReturnValue:result];
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
	return result;
}

- (__autoreleasing id) objectByPerformingSelector:(SEL)selector withObject:(id) object1 withObject: (id) object2
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
		id __autoreleasing object = nil;
		[inv getReturnValue:&object];
		return object;
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
		char *s = NULL;
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

#pragma mark - Delayed Selectors

// Delayed selectors
- (void) performSelector: (SEL) selector withCPointer: (void *) cPointer afterDelay: (NSTimeInterval) delay
{
	NSMethodSignature *ms = [self methodSignatureForSelector:selector];
	NSInvocation *inv = [NSInvocation invocationWithMethodSignature:ms];

	[inv setTarget:self];
	[inv setSelector:selector];
	[inv setArgument:cPointer atIndex:2];
	[inv performSelector:@selector(invoke) withObject:self afterDelay:delay];
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

#pragma mark - Delayed Block

// Thanks August

void _PerformBlockAfterDelay(BasicBlockType block, NSTimeInterval delay)
{
    if (!block) return;
    dispatch_time_t targetTime = dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC);
    dispatch_after(targetTime, dispatch_get_main_queue(), ^(void){
        block();
    });
}

+ (void) performBlock:(void (^)(void)) block afterDelay: (NSTimeInterval) delay
{
    _PerformBlockAfterDelay(block, delay);
}

- (void) performBlock:(void (^)(void)) block afterDelay: (NSTimeInterval) delay
{
    _PerformBlockAfterDelay(block, delay);
}

#pragma mark - values

- (NSValue *) valueByPerformingSelector:(SEL)selector withObject:(id) object1 withObject: (id) object2
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
    NSUInteger length = [ms methodReturnLength];
	void *bytes = malloc(length);
	[inv getReturnValue:bytes];
	NSValue *returnValue = [NSValue valueWithBytes: bytes objCType: returnType];
	free(bytes);
	return returnValue;
}

- (NSValue *) valueByPerformingSelector:(SEL)selector withObject:(id) object1
{
	return [self valueByPerformingSelector:selector withObject:object1 withObject:nil];
}

- (NSValue *) valueByPerformingSelector:(SEL)selector
{
	return [self valueByPerformingSelector:selector withObject:nil withObject:nil];
}

#pragma mark - Class Bits


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
	Protocol *const *protocols = class_copyProtocolList(self, &num);
	for (int i = 0; i < num; i++)
		[protocolNames addObject:[NSString stringWithCString:protocol_getName(protocols[i]) encoding:NSUTF8StringEncoding]];
	free((void *)protocols);
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

// Tests whether ivar exists
- (BOOL) hasIvar: (NSString *) ivarName
{
	NSMutableSet *set = [NSMutableSet set];
	NSDictionary *dict = self.ivars;
	for (NSArray *ivars in [dict allValues])
		[set addObjectsFromArray:ivars];
	return [set containsObject:ivarName];
}

// Tests class
+ (BOOL) classExists: (NSString *) className
{
	return (NSClassFromString(className) != nil);
}

// Return instance from class
+ (id) instanceOfClassNamed: (NSString *) className
{
	if (NSClassFromString(className) != nil)
		return [[NSClassFromString(className) alloc] init];
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

/*
 
 Notes:
 
 objc_property_t prop = class_getProperty(self.class, "foo");
 char *setterName = property_copyAttributeValue(prop, "S");
 printf("%s\n", setterName);
 char *getterName = property_copyAttributeValue(prop, "G");
 printf("%s\n", getterName);
 
 see http://svn.gna.org/svn/gnustep/libs/libobjc2/trunk/properties.m
 T == property_getTypeEncoding(property)
 D == dynamic/synthesized
 V = property_getIVar(property)
 S = property->setter_name
 G = property->getter_name
 R - readonly, W - weak, C - copy, &, retain/strong, N - Nonatomic
 
 */

// A work in progress
+ (NSString *) typeForString: (const char *) typeName
{
    NSString *typeNameString = @(typeName);
    if ([typeNameString hasPrefix:@"@\""])
    {
        NSRange r = NSMakeRange(2, typeNameString.length - 3);
        NSString *format = [NSString stringWithFormat:@"(%@ *)", [typeNameString substringWithRange:r]];
        return format;
    }
    
    if ([typeNameString isEqualToString:@"v"])
        return @"(void)";
    
    if ([typeNameString isEqualToString:@"@"])
        return @"(id)";

    if ([typeNameString isEqualToString:@"^v"])
        return @"(void *)";
    
    if ([typeNameString isEqualToString:@"c"])
        return @"(BOOL)";

    if ([typeNameString isEqualToString:@"i"])
        return @"(int)";

    if ([typeNameString isEqualToString:@"s"])
        return @"(short)";

    if ([typeNameString isEqualToString:@"l"])
        return @"(long)";

    if ([typeNameString isEqualToString:@"q"])
        return @"(long long)";

    if ([typeNameString isEqualToString:@"I"])
        return @"(unsigned int)";

    if ([typeNameString isEqualToString:@"L"])
        return @"(unsigned long)";
    
    if ([typeNameString isEqualToString:@"Q"])
        return @"(unsigned long long)";

    if ([typeNameString isEqualToString:@"f"])
        return @"(float)";

    if ([typeNameString isEqualToString:@"d"])
        return @"(double)";

    if ([typeNameString isEqualToString:@"B"])
        return @"(bool)";

    if ([typeNameString isEqualToString:@"*"])
        return @"(char *)";

    if ([typeNameString isEqualToString:@"#"])
        return @"(Class)";

    if ([typeNameString isEqualToString:@":"])
        return @"(SEL)";
    /*
     [array type]     An array
     {name=type...}     A structure
     (name=type...)     A union
     bnum     A bit field of num bits
     ^type     A pointer to type
     ?     An unknown type (among other things, this code is used for function pointers)
     */
    
    return [NSString stringWithFormat:@"(%@)", typeNameString];
}

+ (NSString *) dump
{
    NSMutableString *dump = [NSMutableString string];
    
    [dump appendFormat:@"%@ ", [[self.superclasses valueForKey:@"description"] componentsJoinedByString:@" : "]];
    
    NSDictionary *protocols = [self protocols];
    NSMutableSet *protocolSet = [NSMutableSet set];
    for (NSString *key in protocols.allKeys)
        [protocolSet addObjectsFromArray:protocols[key]];
    [dump appendFormat:@"<%@>\n", [protocolSet.allObjects componentsJoinedByString:@", "]];
    
    [dump appendString:@"{\n"];
	unsigned int num;
	Ivar *ivars = class_copyIvarList(self, &num);
	for (int i = 0; i < num; i++)
    {
        const char *ivname = ivar_getName(ivars[i]);
        const char *typename = ivar_getTypeEncoding(ivars[i]);
        [dump appendFormat:@"    %@ %s\n", [self typeForString:typename], ivname];
    }
	free(ivars);
    [dump appendString:@"}\n\n"];

    BOOL hasProperty = NO;
    NSArray *properties = [self getPropertyListForClass];
    for (NSString *property in properties)
    {
        hasProperty = YES;
        objc_property_t prop = class_getProperty(self, property.UTF8String);

        [dump appendString:@"    @property "];
        
        char *nonatomic = property_copyAttributeValue(prop, "N");
        char *readonly = property_copyAttributeValue(prop, "R");
        char *copyAt = property_copyAttributeValue(prop, "C");
        char *strong = property_copyAttributeValue(prop, "&");
        NSMutableArray *attributes = [NSMutableArray array];
        if (nonatomic) [attributes addObject:@"nonatomic"];
        [attributes addObject:strong ? @"strong" : @"assign"];
        [attributes addObject:readonly ? @"readonly" : @"readwrite"];
        if (copyAt) [attributes addObject:@"copy"];
        [dump appendFormat:@"(%@) ", [attributes componentsJoinedByString:@", "]];
        free(nonatomic);
        free(readonly);
        free(copyAt);
        free(strong);
        
        char *typeName = property_copyAttributeValue(prop, "T");
        [dump appendFormat:@"%@ ", [self typeForString:typeName]];
        free(typeName);

        char *setterName = property_copyAttributeValue(prop, "S");
        char *getterName = property_copyAttributeValue(prop, "G");
        if (setterName || getterName)
            [dump appendFormat:@"(setter=%s, getter=%s)", setterName, getterName];
        [dump appendFormat:@" %@\n", property];
        free(setterName);
        free(getterName);
    }
    if (hasProperty) [dump appendString:@"\n"];
    
	Method *clMethods = class_copyMethodList(objc_getMetaClass(self.description.UTF8String), &num);
	for (int i = 0; i < num; i++)
    {
        char returnType[1024];
        method_getReturnType(clMethods[i], returnType, 1024);
        NSString *rType = [self typeForString:returnType];
        [dump appendFormat:@"+ %@ ", rType];

        NSString *selectorString = NSStringFromSelector(method_getName(clMethods[i]));
        NSArray *components = [selectorString componentsSeparatedByString:@":"];
        int argCount = method_getNumberOfArguments(clMethods[i]) - 2;
        if (argCount > 0)
        {
            for (unsigned int j = 0; j < argCount; j++)
            {
                NSString *arg = @"argument";
                char argType[1024];
                method_getArgumentType(clMethods[i], j, argType, 1024);
                NSString *typeStr = [self typeForString:argType];
                [dump appendFormat:@"%@:%@%@ ", components[j], typeStr, arg];
            }
            [dump appendString:@"\n"];
        }
        else
        {
            [dump appendFormat:@"%@\n", selectorString];
        }
    }
	free(clMethods);

    [dump appendString:@"\n"];
	Method *methods = class_copyMethodList(self, &num);
	for (int i = 0; i < num; i++)
    {
        char returnType[1024];
        method_getReturnType(methods[i], returnType, 1024);
        NSString *rType = [self typeForString:returnType];
        [dump appendFormat:@"- %@ ", rType];
        
        NSString *selectorString = NSStringFromSelector(method_getName(methods[i]));
        NSArray *components = [selectorString componentsSeparatedByString:@":"];
        int argCount = method_getNumberOfArguments(methods[i]) - 2;
        if (argCount > 0)
        {
            for (unsigned int j = 0; j < argCount; j++)
            {
                NSString *arg = @"argument";
                char argType[1024];
                method_getArgumentType(methods[i], j, argType, 1024);
                NSString *typeStr = [self typeForString:argType];
                [dump appendFormat:@"%@:%@%@ ", components[j], typeStr, arg];
            }
            [dump appendString:@"\n"];
        }
        else
        {
            [dump appendFormat:@"%@\n", selectorString];
        }
    }
	free(methods);
    
    return dump;
}

- (NSString *) dump
{
    return [[self class] dump];
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

#pragma mark - Safe Perform

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
- (id) safePerformSelector: (SEL) selector withObject: (NSObject *) object1 withObject: (NSObject *) object2
{
    if ([self respondsToSelector:selector])
        return [self performSelector:selector withObject:object1 withObject:object2];
    return nil;
}

- (id) safePerformSelector: (SEL) selector withObject: (NSObject *) object1
{
    return [self safePerformSelector:selector withObject:object1 withObject:nil];
}

- (id) safePerformSelector: (SEL) selector
{
    return [self safePerformSelector:selector withObject:nil withObject:nil];
}
#pragma clang diagnostic pop
@end