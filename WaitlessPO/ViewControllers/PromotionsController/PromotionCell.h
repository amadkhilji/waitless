//
//  PromotionCell.h
//  WaitlessPO
//
//  Created by Amad Khilji on 08/12/2013.
//  Copyright (c) 2013 Amad Khilji. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PromotionCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *title_lbl, *restaurant_lbl, *date_lbl, *code_lbl;
@property (nonatomic, retain) IBOutlet UITextView *description_TV;
@property (nonatomic, retain) IBOutlet UIImageView *promoImage;

@end
