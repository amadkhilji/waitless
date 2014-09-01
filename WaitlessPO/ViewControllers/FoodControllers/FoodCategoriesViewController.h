//
//  FoodCategoriesViewController.h
//  WaitlessPO
//
//  Created by Amad Khilji on 05/12/2013.
//  Copyright (c) 2013 Amad Khilji. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FoodCategoriesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    
    IBOutlet UILabel *price_lbl, *quantity_lbl;
    IBOutlet UIView *price_quantity_view;
    IBOutlet UITableView *foodCategoriesTable;
    
    NSMutableArray *foodCategoriesList;
}

@property (nonatomic, assign) BOOL isParkedOrder;
@property (nonatomic, assign) int quantity;
@property (nonatomic, assign) float price;

-(void)setFoodCategories:(NSArray*)categories;

-(IBAction)backAction:(id)sender;

@end
