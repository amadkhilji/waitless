//
//  POEditCell.m
//  WaitlessPO
//
//  Created by Amad Khilji on 15/12/2013.
//  Copyright (c) 2013 Amad Khilji. All rights reserved.
//

#import "POEditCell.h"
#import "POEditViewController.h"

@implementation POEditCell

@synthesize quantity_lbl, title_lbl, options_lbl, price_lbl;
@synthesize check_btn;
@synthesize parentViewController;

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
    [super setSelected:NO animated:NO];

    // Configure the view for the selected state
}

#pragma mark
#pragma mark IBAction Methods

-(IBAction)selectButtonAction:(id)sender {
    
    check_btn.selected = !check_btn.selected;
    if (parentViewController && [parentViewController respondsToSelector:@selector(selectFoodItemAtIndex:Selected:)]) {
        [parentViewController selectFoodItemAtIndex:check_btn.tag Selected:check_btn.selected];
    }
}

@end
