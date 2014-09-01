//
//  CustomAlertViewDelegate.h
//  DrawSomething
//
//  Created by Amad Khilji on 9/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CustomAlertViewDelegate <NSObject>
@required
- (void) customAlertView:(id)alertView dismissedWithValue:(NSString *)value;

@optional
- (void) customAlertViewCancelled:(id)alertView;
@end
