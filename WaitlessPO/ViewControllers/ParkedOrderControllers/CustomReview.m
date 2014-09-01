//
//  CustomReview.m
//  WaitlessPO
//
//  Created by Amad Khilji on 04/02/2014.
//  Copyright (c) 2014 Amad Khilji. All rights reserved.
//

#import "CustomReview.h"

@implementation CustomReview

@synthesize rating;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void)setRatingValue:(int)_rating {
    
    rating = _rating;
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[UIImageView class]]) {
            UIImageView *star = (UIImageView*)view;
            if (star.tag <= rating) {
                star.highlighted = YES;
            }
            else {
                star.highlighted = NO;
            }
        }
    }
    
    if (delegate && [delegate respondsToSelector:@selector(didChangeRateValue:)]) {
        [delegate didChangeRateValue:rating];
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:self];
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[UIImageView class]]) {
            UIImageView *star = (UIImageView*)view;
            CGRect frame = star.frame;
            if (CGRectContainsPoint(frame, location)) {
                rating = (int)star.tag;
                break;
            }
        }
    }
    [self setRatingValue:rating];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:self];
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[UIImageView class]]) {
            UIImageView *star = (UIImageView*)view;
            CGRect frame = star.frame;
            if (CGRectContainsPoint(frame, location)) {
                rating = (int)star.tag;
                break;
            }
        }
    }
    [self setRatingValue:rating];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {

    [self touchesEnded:touches withEvent:event];
}

@end
