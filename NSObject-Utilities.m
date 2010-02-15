//
//  Created by Erica Sadun on 2/14/10.
//  Copyright 2010 Up To No Good, Inc. All rights reserved.
//

#import "NSObject-Utilities.h"

@implementation NSObject (Utilities)

// Return an array of an object's superclasses
- (NSArray *) superclasses
{
	Class cl = [self class];
	NSMutableArray *results = [NSMutableArray arrayWithObject:cl];
	
	do 
	{
		cl = [cl superclass];
		[results addObject:cl];
	}
	while (![cl isEqual:[NSObject class]]) ;
	
	return results;
}

@end