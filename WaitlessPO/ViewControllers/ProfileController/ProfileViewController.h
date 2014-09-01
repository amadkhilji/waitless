//
//  ProfileViewController.h
//  WaitlessPO
//
//  Created by Amad Khilji on 08/12/2013.
//  Copyright (c) 2013 Amad Khilji. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    
    IBOutlet UILabel *title_lbl, *name_lbl, *address_lbl, *order_lbl_1, *order_lbl_2, *order_lbl_3, *order_lbl_4, *order_lbl_5;
    IBOutlet UIImageView *userImage;
    IBOutlet UIView *footerView;
    IBOutlet UITableView *profileTableView;
    NSMutableArray *upcomingParkedOrderList;
}

-(IBAction)menuAction:(id)sender;

@end
