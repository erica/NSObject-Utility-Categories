/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <Foundation/Foundation.h>

 // thanks Landon Fuller
#define VERIFIED_CLASS(className) ((className *) NSClassFromString(@"" # className))

@interface NSObject (Utilities)

// Return all superclasses of object
- (NSArray *) superclasses;

// Selector Utilities
- (NSInvocation *) invocationWithSelectorAndArguments: (SEL) selector,...;
- (BOOL) performSelector: (SEL) selector withReturnValueAndArguments: (void *) result, ...;
- (const char *) returnTypeForSelector:(SEL)selector;

// Request return value from performing selector
- (id) objectByPerformingSelectorWithArguments: (SEL) selector, ...;
- (id) objectByPerformingSelector:(SEL)selector withObject:(id) object1 withObject: (id) object2;
- (id) objectByPerformingSelector:(SEL)selector withObject:(id) object1;
- (id) objectByPerformingSelector:(SEL)selector;

// Delay Utilities
- (void) performSelector: (SEL) selector withCPointer: (void *) cPointer afterDelay: (NSTimeInterval) delay;
- (void) performSelector: (SEL) selector withInt: (int) intValue afterDelay: (NSTimeInterval) delay;
- (void) performSelector: (SEL) selector withFloat: (float) floatValue afterDelay: (NSTimeInterval) delay;
- (void) performSelector: (SEL) selector withBool: (BOOL) boolValue afterDelay: (NSTimeInterval) delay;
- (void) performSelector: (SEL) selector afterDelay: (NSTimeInterval) delay;
- (void) performSelector: (SEL) selector withDelayAndArguments: (NSTimeInterval) delay,...;

// Return Values, allowing non-object returns
- (id) valueByPerformingSelector:(SEL)selector withObject:(id) object1 withObject: (id) object2;
- (id) valueByPerformingSelector:(SEL)selector withObject:(id) object1;
- (id) valueByPerformingSelector:(SEL)selector;

// Access to object essentials for run-time checks. Stored by class in dictionary.
@property (readonly) NSDictionary *selectors;
@property (readonly) NSDictionary *properties;
@property (readonly) NSDictionary *ivars;
@property (readonly) NSDictionary *protocols;

// Check for properties, ivar. Use respondsToSelector: and conformsToProtocol: as well
- (BOOL) hasProperty: (NSString *) propertyName;
- (BOOL) hasIvar: (NSString *) ivarName;
+ (BOOL) classExists: (NSString *) className;
+ (id) instanceOfClassNamed: (NSString *) className;

// Attempt selector if possible
- (id) tryPerformSelector: (SEL) aSelector withObject: (id) object1 withObject: (id) object2;
- (id) tryPerformSelector: (SEL) aSelector withObject: (id) object1;
- (id) tryPerformSelector: (SEL) aSelector;

// Choose the first selector that the object responds to
- (SEL) chooseSelector: (SEL) aSelector, ...;
@end

#pragma mark Useful Compatibility Tips
// Tip #1 Compile-time checks for OS
/*
#ifdef _USE_OS_3_OR_LATER
// 3.0 or later defs
#endif
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 30000 
// Pre-3.0 Code
#else 
// 3.0 Code
#endif

 Built in sys versions include:
 #define __IPHONE_2_0 20000
 #define __IPHONE_2_1 20100
 #define __IPHONE_2_2 20200
 #define __IPHONE_3_0 30000
 #define __IPHONE_3_1 30100
 #define __IPHONE_3_2 30200
 #define __IPHONE_NA 99999
 */ 

// Tip #2 Run-time checks
/* 
 // Sys prefix
 if ([[[UIDevice currentDevice] systemVersion] hasPrefix:@"2."]) 
 [cell setText:celltext];
 else if ([[[UIDevice currentDevice] systemVersion] hasPrefix:@"3."]) 
 [[cell textLabel] setText:celltext];
 
 // key/value coding
 UILabel *label = (UILabel *)[cell valueForKey:@"textLabel"]; 
 if (label) [label setText:celltext];
 
 // Class existence
 Class c = NSClassFromString(classname);
 if (c) {...}
 */

// Tip 3 Extract constants
/*
 Add these to OTHER_CFLAGS in the Build tab: -save-temps
 */

