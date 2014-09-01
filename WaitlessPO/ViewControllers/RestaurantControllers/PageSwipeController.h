//
//  PageSwipeController.h
//  WaitlessPO
//
//  Created by SSASOFT on 1/6/14.
//  Copyright (c) 2014 Amad Khilji. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RestaurantDetailsViewController;

@interface PageSwipeController : UIViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate> {
    
    NSMutableArray *restaurantList;
    UIPageViewController *pageController;
    
    IBOutlet UIView *topbarView;
    IBOutlet UILabel *title_lbl;
}

@property (strong, nonatomic) UIPageViewController *pageController;
@property (atomic, assign) int selectedIndex;

-(void)reloadPromotions;
-(IBAction)backAction:(id)sender;

@end
