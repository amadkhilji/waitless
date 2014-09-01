//
//  RestaurantCell.m
//  WaitlessPO
//
//  Created by Amad Khilji on 01/11/2013.
//  Copyright (c) 2013 Amad Khilji. All rights reserved.
//

#import "RestaurantCell.h"
#import "RestaurantViewController.h"

@implementation RestaurantCell

@synthesize restaurantName_lbl, restaurantCategory_lbl, address_lbl, distance_lbl, review_lbl;
@synthesize star_1, star_2, star_3, star_4, star_5, star_half_1, star_half_2, star_half_3, star_half_4, star_half_5, restaurantImage;
@synthesize parentController;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:NO animated:animated];

    // Configure the view for the selected state
}

-(void)setRatings:(float)ratings {
    
    [star_1 setHidden:NO];
    [star_2 setHidden:NO];
    [star_3 setHidden:NO];
    [star_4 setHidden:NO];
    [star_5 setHidden:NO];
    [star_1 setHighlighted:NO];
    [star_2 setHighlighted:NO];
    [star_3 setHighlighted:NO];
    [star_4 setHighlighted:NO];
    [star_5 setHighlighted:NO];
    [star_half_1 setHidden:YES];
    [star_half_2 setHidden:YES];
    [star_half_3 setHidden:YES];
    [star_half_4 setHidden:YES];
    [star_half_5 setHidden:YES];
    
    int rate = (int)floorf(ratings);
    if (rate >= 1) {
        [star_1 setHighlighted:YES];
    }
    if (rate >= 2) {
        [star_2 setHighlighted:YES];
    }
    if (rate >= 3) {
        [star_3 setHighlighted:YES];
    }
    if (rate >= 4) {
        [star_4 setHighlighted:YES];
    }
    if (rate >= 5) {
        [star_5 setHighlighted:YES];
    }
    int half_rate = (int)ceilf(ratings);
    if (half_rate > rate) {
        UIImageView *star_image = (UIImageView*)[self viewWithTag:half_rate+10];
        [star_image setHidden:NO];
    }
}

-(IBAction)clickCellButton:(id)sender {
 
    if (parentController && [parentController respondsToSelector:@selector(selectedRestaurantIndex:)]) {
        [parentController selectedRestaurantIndex:(int)self.tag];
    }
}

-(IBAction)mapButtonClick:(id)sender {
    
    if (parentController && [parentController respondsToSelector:@selector(openMapWithRestaurantAtIndex:)]) {
        [parentController openMapWithRestaurantAtIndex:(int)self.tag];
    }
}

@end
