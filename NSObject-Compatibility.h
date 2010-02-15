//
//  Created by Erica Sadun on 2/14/10.
//  Copyright 2010 Up To No Good, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSObject (Compatibility)
- (SEL) chooseSelector: (SEL) aSelector, ...;
- (id) tryPerformSelector: (SEL) aSelector withObject: (id) object1 withObject: (id) object2;
- (id) tryPerformSelector: (SEL) aSelector withObject: (id) object1;
- (id) tryPerformSelector: (SEL) aSelector;
@end
