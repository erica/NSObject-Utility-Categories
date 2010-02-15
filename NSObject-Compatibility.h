//
//  NSObject-Compatibility.h
//  HelloWorld
//
//  Created by Erica Sadun on 2/14/10.
//  Copyright 2010 Up To No Good, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSObject (Compatibility)
- (SEL) chooseSelector: (SEL) aSelector, ...;
@end
