//
//  RestaurantCell.h
//  WaitlessPO
//
//  Created by Amad Khilji on 01/11/2013.
//  Copyright (c) 2013 Amad Khilji. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RestaurantViewController;

@interface RestaurantCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel  *restaurantName_lbl, *restaurantCategory_lbl, *address_lbl, *distance_lbl, *review_lbl;
@property (atomic, retain) IBOutlet UIImageView *star_1, *star_2, *star_3, *star_4, *star_5, *star_half_1, *star_half_2, *star_half_3, *star_half_4, *star_half_5, *restaurantImage;

@property (nonatomic, weak) RestaurantViewController *parentController;

-(void)setRatings:(float)ratings;

-(IBAction)clickCellButton:(id)sender;
-(IBAction)mapButtonClick:(id)sender;

@end
