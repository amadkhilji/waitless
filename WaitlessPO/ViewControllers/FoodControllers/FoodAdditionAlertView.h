//
//  FoodAdditionAlertView.h
//  WaitlessPO
//
//  Created by SSASOFT on 9/25/14.
//  Copyright (c) 2014 Amad Khilji. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomAlertViewDelegate.h"

@interface FoodAdditionAlertView : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    
    IBOutlet  UIView        *alertView, *backgroundView;
    IBOutlet  UITableView   *foodAdditionTable;
    NSMutableArray          *foodAdditionsList;
}

@property (nonatomic, assign) id<CustomAlertViewDelegate, NSObject> delegate;

-(void)show;
-(void)loadFoodAdditionsList:(NSArray*)list;
-(void)foodItemAtIndex:(NSInteger)index selected:(BOOL)isSelected;

-(IBAction)cancelAction:(id)sender;
-(IBAction)doneAction:(id)sender;

@end
