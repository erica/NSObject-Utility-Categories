/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <Foundation/Foundation.h>

@interface NSObject (DelayExtension)
- (void) performSelector: (SEL) selector withCPointer: (void *) cPointer afterDelay: (NSTimeInterval) delay;

// Optional typed versions (strictly speaking not needed)
- (void) performSelector: (SEL) selector withInt: (int) intValue afterDelay: (NSTimeInterval) delay;
- (void) performSelector: (SEL) selector withFloat: (float) floatValue afterDelay: (NSTimeInterval) delay;
- (void) performSelector: (SEL) selector withBool: (BOOL) boolValue afterDelay: (NSTimeInterval) delay;

// Selector without argument
- (void) performSelector: (SEL) selector afterDelay: (NSTimeInterval) ti;
@end
