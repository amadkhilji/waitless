//
//  PODetailsCell.m
//  WaitlessPO
//
//  Created by Amad Khilji on 14/12/2013.
//  Copyright (c) 2013 Amad Khilji. All rights reserved.
//

#import "PODetailsCell.h"

@implementation PODetailsCell

@synthesize quantity_lbl, title_lbl, options_lbl, price_lbl;

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

@end
