//
//  UIView+AlertAnimations.h
//  DrawSomething
//
//  Created by Amad Khilji on 9/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#define kPopAnimationDuration  0.25
#define kFadeAnimationDuration  0.30

@interface UIView (AlertAnimations)

- (void)doPopInAnimation;
- (void)doPopInAnimationWithDelegate:(id)animationDelegate;
- (void)doPopOutAnimation;
- (void)doPopOutAnimationWithDelegate:(id)animationDelegate;
- (void)doFadeInAnimation;
- (void)doFadeInAnimationWithDelegate:(id)animationDelegate;
- (void)doFadeOutAnimation;
- (void)doFadeOutAnimationWithDelegate:(id)animationDelegate;

@end
