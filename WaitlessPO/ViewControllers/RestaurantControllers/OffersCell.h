//
//  OffersCell.h
//  WaitlessPO
//
//  Created by Amad Khilji on 15/02/2014.
//  Copyright (c) 2014 Amad Khilji. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OffersCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *name_lbl, *value_lbl, *code_lbl, *date_lbl;
@property (strong, nonatomic) IBOutlet UITextView *description_TV;

@end
