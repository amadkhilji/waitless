//
//  POEditCell.h
//  WaitlessPO
//
//  Created by Amad Khilji on 15/12/2013.
//  Copyright (c) 2013 Amad Khilji. All rights reserved.
//

#import <UIKit/UIKit.h>

@class POEditViewController;

@interface POEditCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *quantity_lbl, *title_lbl, *options_lbl, *price_lbl;
@property (nonatomic, retain) IBOutlet UIButton *check_btn;
@property (atomic, weak) POEditViewController *parentViewController;

-(IBAction)selectButtonAction:(id)sender;

@end
