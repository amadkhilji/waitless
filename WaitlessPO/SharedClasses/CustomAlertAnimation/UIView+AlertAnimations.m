//
//  UIView+AlertAnimations.m
//  DrawSomething
//
//  Created by Amad Khilji on 9/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIView+AlertAnimations.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIView (AlertAnimations)

- (void)doPopInAnimation
{
    [self doPopInAnimationWithDelegate:nil];
}

- (void)doPopInAnimationWithDelegate:(id)animationDelegate
{
    CALayer *viewLayer = self.layer;
    CAKeyframeAnimation* popInAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    // 0.6 1.1 0.85 1.0
    popInAnimation.duration = kPopAnimationDuration;
    popInAnimation.values = [NSArray arrayWithObjects:
                             [NSNumber numberWithFloat:0.0],
                             [NSNumber numberWithFloat:0.3],
                             [NSNumber numberWithFloat:0.8],
                             [NSNumber numberWithFloat:1.1],
                             [NSNumber numberWithFloat:1.0],
                             nil];
    popInAnimation.keyTimes = [NSArray arrayWithObjects:
                               [NSNumber numberWithFloat:0.0],
                               [NSNumber numberWithFloat:0.25],
                               [NSNumber numberWithFloat:0.5],
                               [NSNumber numberWithFloat:0.75],
                               [NSNumber numberWithFloat:1.0], 
                               nil];    
    popInAnimation.delegate = animationDelegate;
    
    [viewLayer addAnimation:popInAnimation forKey:@"transform.scale"];  
}

- (void)doPopOutAnimation
{
    [self doPopOutAnimationWithDelegate:nil];
}

- (void)doPopOutAnimationWithDelegate:(id)animationDelegate
{
    CALayer *viewLayer = self.layer;
    CAKeyframeAnimation* popOutAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    
    popOutAnimation.duration = kPopAnimationDuration;
    popOutAnimation.values = [NSArray arrayWithObjects:
                              [NSNumber numberWithFloat:1.0],
                              [NSNumber numberWithFloat:0.75],
                              [NSNumber numberWithFloat:0.5],
                              [NSNumber numberWithFloat:0.25],
                              [NSNumber numberWithFloat:0.0],
                              nil];
    popOutAnimation.keyTimes = [NSArray arrayWithObjects:
                                [NSNumber numberWithFloat:0.0],
                                [NSNumber numberWithFloat:0.25],
                                [NSNumber numberWithFloat:0.5],
                                [NSNumber numberWithFloat:0.75],
                                [NSNumber numberWithFloat:1.0], 
                                nil];    
    popOutAnimation.delegate = animationDelegate;
    
    [viewLayer addAnimation:popOutAnimation forKey:@"transform.scale"];  
}

- (void)doFadeInAnimation
{
    [self doFadeInAnimationWithDelegate:nil];
}

- (void)doFadeInAnimationWithDelegate:(id)animationDelegate
{
    CALayer *viewLayer = self.layer;
    CABasicAnimation *fadeInAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeInAnimation.fromValue = [NSNumber numberWithFloat:0.0];
    fadeInAnimation.toValue = [NSNumber numberWithFloat:0.58];
    fadeInAnimation.duration = kFadeAnimationDuration;
    fadeInAnimation.delegate = animationDelegate;
    [viewLayer addAnimation:fadeInAnimation forKey:@"opacity"];
}

- (void)doFadeOutAnimation
{
    [self doFadeOutAnimationWithDelegate:nil];
}

- (void)doFadeOutAnimationWithDelegate:(id)animationDelegate
{
    CALayer *viewLayer = self.layer;
    CABasicAnimation *fadeOutAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeOutAnimation.fromValue = [NSNumber numberWithFloat:0.58];
    fadeOutAnimation.toValue = [NSNumber numberWithFloat:0.0];
    fadeOutAnimation.duration = kFadeAnimationDuration;
    fadeOutAnimation.delegate = animationDelegate;
    [viewLayer addAnimation:fadeOutAnimation forKey:@"opacity"];
}

@end
