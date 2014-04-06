/*
 
 Erica Sadun, http://ericasadun.com
 
 */


@import Foundation;

#define VALUE(struct) ({ __typeof__(struct) __struct = struct; [NSValue valueWithBytes:&__struct objCType:@encode(__typeof__(__struct))]; })

#define MAKELIVE(_CLASSNAME_)	Class _CLASSNAME_ = NSClassFromString((NSString *)CFSTR(#_CLASSNAME_));

// thanks Landon Fuller
#define VERIFIED_CLASS(_CLASSNAME_) ((_CLASSNAME_ *) NSClassFromString(@"" # _CLASSNAME_))

typedef void(^BasicBlockType)();

@interface NSObject (Frankenstein)
// Return all superclasses of class or object
+ (NSArray *) superclasses;
- (NSArray *) superclasses;

// Examine
+ (NSString *) dump;
- (NSString *) dump;

// Selector Utilities
- (NSInvocation *) invocationWithSelectorAndArguments: (SEL) selector,...;
- (BOOL) performSelector: (SEL) selector withReturnValueAndArguments: (void *) result, ...;
- (const char *) returnTypeForSelector:(SEL)selector;

// Request return value from performing selector
- (id) objectByPerformingSelectorWithArguments: (SEL) selector, ...;
- (__autoreleasing id) objectByPerformingSelector:(SEL)selector withObject:(id) object1 withObject: (id) object2;
- (id) objectByPerformingSelector:(SEL)selector withObject:(id) object1;
- (id) objectByPerformingSelector:(SEL)selector;

// Delay Utilities
void _PerformBlockAfterDelay(BasicBlockType block, NSTimeInterval delay);
+ (void) performBlock:(void (^)(void)) block afterDelay: (NSTimeInterval) delay;
- (void) performBlock:(void (^)(void)) block afterDelay: (NSTimeInterval) delay;
- (void) performSelector: (SEL) selector withCPointer: (void *) cPointer afterDelay: (NSTimeInterval) delay;
- (void) performSelector: (SEL) selector afterDelay: (NSTimeInterval) delay;
- (void) performSelector: (SEL) selector withDelayAndArguments: (NSTimeInterval) delay,...;

// Return Values, allowing non-object returns
- (NSValue *) valueByPerformingSelector:(SEL)selector withObject:(id) object1 withObject: (id) object2;
- (NSValue *) valueByPerformingSelector:(SEL)selector withObject:(id) object1;
- (NSValue *) valueByPerformingSelector:(SEL)selector;

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
- (id) safePerformSelector: (SEL) selector withObject: (NSObject *) object1 withObject: (NSObject *) object2;
- (id) safePerformSelector: (SEL) selector withObject: (NSObject *) object1;
- (id) safePerformSelector: (SEL) selector;

// Choose the first selector that the object responds to
// - (SEL) chooseSelector: (SEL) aSelector, ...;
@end