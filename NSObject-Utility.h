/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <Foundation/Foundation.h>

@interface NSObject (UtilityExtension)
- (NSArray *) superclasses;

- (const char *) returnTypeForSelector:(SEL)selector;

- (SEL) chooseSelector: (SEL) aSelector, ...;

- (NSInvocation *) invocationWithSelectorAndArguments: (SEL) selector,...;
- (BOOL) performSelector: (SEL) selector withReturnValueAndArguments: (void *) result, ...;
- (void) performSelector: (SEL) selector withDelay: (NSTimeInterval) ti withReturnValueAndArguments: (void *) result, ...;

- (id) objectByPerformingSelectorWithArguments: (SEL) selector, ...;
- (id) objectByPerformingSelector:(SEL)selector withObject:(id) object1 withObject: (id) object2;
- (id) objectByPerformingSelector:(SEL)selector withObject:(id) object1;
- (id) objectByPerformingSelector:(SEL)selector;

- (id) valueByPerformingSelectorWithArguments: (SEL) selector, ...;
- (id) valueByPerformingSelector:(SEL)selector withObject:(id) object1 withObject: (id) object2;
- (id) valueByPerformingSelector:(SEL)selector withObject:(id) object1;
- (id) valueByPerformingSelector:(SEL)selector;

- (void) performSelector: (SEL) selector withCPointer: (void *) cPointer afterDelay: (NSTimeInterval) delay;
- (void) performSelector: (SEL) selector withInt: (int) intValue afterDelay: (NSTimeInterval) delay;
- (void) performSelector: (SEL) selector withFloat: (float) floatValue afterDelay: (NSTimeInterval) delay;
- (void) performSelector: (SEL) selector withBool: (BOOL) boolValue afterDelay: (NSTimeInterval) delay;
- (void) performSelector: (SEL) selector afterDelay: (NSTimeInterval) ti;
@end
