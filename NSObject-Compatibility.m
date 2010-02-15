//
//  NSObject-Compatibility.m
//  HelloWorld
//
//  Created by Erica Sadun on 2/14/10.
//  Copyright 2010 Up To No Good, Inc. All rights reserved.
//

#import "NSObject-Compatibility.h"


@implementation NSObject (Compatibility)

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
