//
//  FoodAdditionCell.m
//  WaitlessPO
//
//  Created by SSASOFT on 9/25/14.
//  Copyright (c) 2014 Amad Khilji. All rights reserved.
//

#import "FoodAdditionCell.h"
#import "FoodAdditionAlertView.h"

@implementation FoodAdditionCell

@synthesize name_lbl, price_lbl;
@synthesize check_btn;
@synthesize parentController;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:NO animated:NO];

    // Configure the view for the selected state
}

#pragma mark 
#pragma mark IBAction Methods

-(IBAction)checkButtonClick:(id)sender {
    
    check_btn.selected = !check_btn.selected;
    if (parentController && [parentController respondsToSelector:@selector(foodItemAtIndex:selected:)]) {
        [parentController foodItemAtIndex:self.tag selected:check_btn.selected];
    }
}

@end
