//
//  FoodItemDetailViewController.h
//  WaitlessPO
//
//  Created by Amad Khilji on 08/12/2013.
//  Copyright (c) 2013 Amad Khilji. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FoodItemDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    
    IBOutlet UILabel *title_lbl, *food_name_lbl, *food_price_lbl, *food_description_lbl, *order_btn_lbl, *price_lbl, *quantity_lbl;
    IBOutlet UIView *price_quantity_view;
    IBOutlet UIButton *order_btn;
    IBOutlet UIImageView *food_image;
    IBOutlet UIView *tableHeaderView;
    IBOutlet UITableView *foodOptionTable;
    NSMutableArray *selectedFoodOptions;
}

@property (atomic, assign) BOOL canOrderFood;
@property (nonatomic, assign) int quantity;
@property (nonatomic, assign) float price;
@property (atomic, retain) NSMutableDictionary *foodData;

-(IBAction)backAction:(id)sender;
-(IBAction)orderAction:(id)sender;

@end
