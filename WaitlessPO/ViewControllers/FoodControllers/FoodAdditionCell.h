//
//  FoodAdditionCell.h
//  WaitlessPO
//
//  Created by SSASOFT on 9/25/14.
//  Copyright (c) 2014 Amad Khilji. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FoodAdditionAlertView;

@interface FoodAdditionCell : UITableViewCell

@property (nonatomic, strong) IBOutlet  UILabel     *name_lbl, *price_lbl;
@property (nonatomic, strong) IBOutlet  UIButton    *check_btn;
@property (nonatomic, weak) FoodAdditionAlertView   *parentController;

-(IBAction)checkButtonClick:(id)sender;

@end
