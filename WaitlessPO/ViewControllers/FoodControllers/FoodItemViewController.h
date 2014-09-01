//
//  FoodItemViewController.h
//  WaitlessPO
//
//  Created by Amad Khilji on 05/12/2013.
//  Copyright (c) 2013 Amad Khilji. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FoodItemViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    
    IBOutlet UILabel *price_lbl, *quantity_lbl;
    IBOutlet UIView *price_quantity_view;
    IBOutlet UITableView *foodItemTable;
    
    NSMutableArray *foodItemsList;
}

@property (nonatomic, assign) BOOL isParkedOrder;
@property (nonatomic, assign) int quantity;
@property (nonatomic, assign) float price;

-(void)setFoodItems:(NSArray*)items;

-(IBAction)backAction:(id)sender;

@end
