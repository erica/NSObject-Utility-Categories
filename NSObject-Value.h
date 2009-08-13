/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <Foundation/Foundation.h>

@interface NSObject (ValueExtension)
- (id) objectByPerformingSelector:(SEL)selector withObject:(id) object1 withObject: (id) object2;
- (id) objectByPerformingSelector:(SEL)selector withObject:(id) object1;
- (id) objectByPerformingSelector:(SEL)selector;

- (id) valueByPerformingSelector:(SEL)selector withObject:(id) object1 withObject: (id) object2;
- (id) valueByPerformingSelector:(SEL)selector withObject:(id) object1;
- (id) valueByPerformingSelector:(SEL)selector;
@end
