/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "NSObject-Utilities.h"

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]
#define BOOL_CHECK(TITLE, CHECK_ITEM)	printf("[%s]: %s\n", TITLE, (CHECK_ITEM) ? "Yes" : "No");

@interface TestBedViewController : UIViewController
{
	NSMutableString *log;
	IBOutlet UITextView *textView;
}
@property (retain) NSMutableString *log;
@property (retain) UITextView *textView;
@end

@implementation TestBedViewController
@synthesize log;
@synthesize textView;

- (void) doLog: (NSString *) formatstring, ...
{
	va_list arglist;
	if (!formatstring) return;
	va_start(arglist, formatstring);
		NSString *outstring = [[[NSString alloc] initWithFormat:formatstring arguments:arglist] autorelease];
	va_end(arglist);
	[self.log appendString:[outstring stringByAppendingString:@"\n"]];
	self.textView.text = self.log;
}

- (void) action: (UIBarButtonItem *) bbi
{
	self.log = [NSMutableString string];
}

- (void) viewDidLoad
{
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Action", @selector(action:));

	BOOL_CHECK("Property view", [self hasProperty:@"view"]);
	BOOL_CHECK("Property notaproperty", [self hasProperty:@"notaproperty"]);

	BOOL_CHECK("Ivar isa", [self hasIvar:@"isa"]);
	BOOL_CHECK("Ivar _view", [self hasIvar:@"_view"]);
	BOOL_CHECK("Ivar notanivar", [self hasIvar:@"notanivar"]);
}
@end

@interface TestBedAppDelegate : NSObject <UIApplicationDelegate>
@end

@implementation TestBedAppDelegate
- (void)applicationDidFinishLaunching:(UIApplication *)application {	
	UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[[TestBedViewController alloc] init]];
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
