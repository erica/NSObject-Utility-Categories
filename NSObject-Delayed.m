/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import "NSObject-Value.h"

/*
 Maybe extend to allow alarms to be stored and loaded on launch?
 */

@implementation NSObject (DelayExtension)
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

// Delay without argument

- (void) performSelector: (SEL) selector afterDelay: (NSTimeInterval) ti
{
	[self performSelector:selector withObject:nil afterDelay: ti];
}
@end
