//
//  CustomReview.h
//  WaitlessPO
//
//  Created by Amad Khilji on 04/02/2014.
//  Copyright (c) 2014 Amad Khilji. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RateDelegate <NSObject>

-(void)didChangeRateValue:(int)rateValue;

@end

@interface CustomReview : UIView {
    
    IBOutlet UIImageView *star1, *star2, *star3, *star4, *star5;
}

@property (atomic, readonly) int rating;
@property (atomic, weak) id<RateDelegate> delegate;

-(void)setRatingValue:(int)_rating;

@end
