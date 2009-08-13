/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <Foundation/Foundation.h>

@interface NSObject (UtilityExtension)
- (const char *) returnTypeForSelector:(SEL)selector;
- (NSArray *) superclasses;
- (SEL) chooseSelector: (SEL) aSelector, ...;
- (BOOL) performSelector: (SEL) selector withReturnValueAndArguments: (void *) result, ...;
@end

