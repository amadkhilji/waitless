//
//  PaymentCell.h
//  WaitlessPO
//
//  Created by SSASOFT on 3/4/14.
//  Copyright (c) 2014 Amad Khilji. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PaymentsViewController;

@interface PaymentCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *title_lbl;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIButton *cell_btn;
@property (copy, nonatomic) NSIndexPath *indexPath;
@property (assign, nonatomic) PaymentType paymentType;
@property (weak, nonatomic) PaymentsViewController *parentController;

-(void)resetLayout;
-(IBAction)clickPaymentAction:(id)sender;

@end
