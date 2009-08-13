/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "NSObject-Value.h"
#import "NSObject-Delayed.h"
#import "NSObject-Utility.h"

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]

@interface TestBedController : UIViewController
@end

@implementation TestBedController
/*
- (void) showBool: (BOOL) someBOOL
{
	printf("The BOOL was %d\n", someBOOL);
}

- (void) showChar: (char) aChar
{
	printf("The char was %c\n", aChar);
}

- (void) showFloat: (float) someFloat
{
	printf("The float was %f\n", someFloat);
}

- (void) showInt: (int) someInt
{
	printf("The int was %d\n", someInt);
}

- (void) showCGPoint: (CGPoint) aPoint
{
	printf("%s\n", [NSStringFromCGPoint(aPoint) UTF8String]);
}

- (void) performAction
{
	NSString *string = @"Hello World";
	NSLog(@"%@", [string objectByPerformingSelector:@selector(length)]);
	
	printf("Classes:\n");
	CFShow([string superclasses]);
	CFShow([[NSMutableArray array] superclasses]);

	CGPoint aPoint = CGPointMake(1.0f, 3.0f);
	[self performSelector:@selector(showCGPoint:) withCPointer:&aPoint afterDelay:1.0f];
	
} */

// Testing out selector extensions
- (void) performAction
{
	CGRect aFrame;
	[self.view performSelector:@selector(frame) withReturnValueAndArguments:&aFrame, nil];
	CFShow(NSStringFromCGRect(aFrame));
	
	[self.view performSelector:@selector(setFrame:) withReturnValueAndArguments:nil, CGRectMake(0.0f, 0.0f, 160.0f, 100.0f)];
	[self.view performSelector:@selector(setCenter:) withReturnValueAndArguments:nil, CGPointMake(160.0f, 200.0f)];
	
	NSNumber *foo;
	[NSNumber performSelector:@selector(numberWithInt:) withReturnValueAndArguments:&foo, 23];
	CFShow(foo);
	
	NSString *outstring;
	if ([@"foobar" performSelector:@selector(stringByAppendingString:) withReturnValueAndArguments:&outstring, @"blort"])
		CFShow(outstring);
	
	UIBarButtonItem *bbi = [UIBarButtonItem alloc];
	[bbi performSelector:@selector(initWithTitle:style:target:action:) withReturnValueAndArguments:&bbi, @"Hello!", 
		UIBarButtonItemStylePlain, self, @selector(performAction)];
	self.navigationItem.rightBarButtonItem = bbi;
	
	UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
	SEL selector = [ipc chooseSelector:@selector(setAllowsEditing:), @selector(setAllowsImageEditing:)];
	[ipc performSelector:selector withReturnValueAndArguments:nil, YES];
	printf("First test: (%s)\n", [NSStringFromSelector(selector) UTF8String]);
	
	selector = [ipc chooseSelector:@selector(allowsEditing), @selector(allowsImageEditing)];
	BOOL result;
	[ipc performSelector:selector withReturnValueAndArguments:&result];
	printf("Second test: %d (%s)\n", result, [NSStringFromSelector(selector) UTF8String]);

	[ipc release];
}

- (void) loadView
{
	UIView *contentView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	self.view = contentView;
	contentView.backgroundColor = [UIColor whiteColor];
    [contentView release];
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Action", @selector(performAction));
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
}
@end

@interface TestBedAppDelegate : NSObject <UIApplicationDelegate>
@end

@implementation TestBedAppDelegate
- (void)applicationDidFinishLaunching:(UIApplication *)application {
	UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[[TestBedController alloc] init]];
	[window addSubview:nav.view];
	[window makeKeyAndVisible];
}
@end

int main(int argc, char *argv[])
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	int retVal = UIApplicationMain(argc, argv, nil, @"TestBedAppDelegate");
	[pool release];
	return retVal;
}
