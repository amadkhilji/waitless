//
//  PaymentCell.m
//  WaitlessPO
//
//  Created by SSASOFT on 3/4/14.
//  Copyright (c) 2014 Amad Khilji. All rights reserved.
//

#import "PaymentCell.h"
#import "PaymentsViewController.h"

@implementation PaymentCell

@synthesize title_lbl;
@synthesize imageView;
@synthesize cell_btn;
@synthesize indexPath;
@synthesize paymentType;
@synthesize parentController;

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

//-(void) drawRect: (CGRect) rect
//{
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    
//    UIColor *clearColor = [UIColor lightGrayColor];
//    
//    CGContextSetFillColorWithColor(context, clearColor.CGColor);
//    CGContextFillRect(context, self.bounds);
//}

-(void)resetLayout {
    
    if (paymentType == PaymentTypeNone) {
        cell_btn.hidden = YES;
        imageView.hidden = YES;
        title_lbl.center = self.center;
        title_lbl.textAlignment = NSTextAlignmentCenter;
        title_lbl.textColor = [UIColor lightGrayColor];
        title_lbl.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0];
    }
    else {
        CGRect frame = title_lbl.frame;
        frame.origin.x = imageView.frame.origin.x+imageView.frame.size.width+8.0;
        title_lbl.frame = frame;
        title_lbl.textAlignment = NSTextAlignmentLeft;
        cell_btn.hidden = NO;
        imageView.hidden = NO;
        if (indexPath.section == 0) {
            title_lbl.textColor = [UIColor blackColor];
            title_lbl.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0];
        }
        else {
            title_lbl.textColor = [UIColor darkGrayColor];
            title_lbl.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0];
        }
    }
}

-(IBAction)clickPaymentAction:(id)sender {

    if (parentController) {
        [parentController selectPaymentMethodAtIndexPath:indexPath withPaymentType:paymentType];
    }
}

@end
