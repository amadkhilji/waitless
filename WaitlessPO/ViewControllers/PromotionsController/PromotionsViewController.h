//
//  PromotionsViewController.h
//  WaitlessPO
//
//  Created by Amad Khilji on 08/12/2013.
//  Copyright (c) 2013 Amad Khilji. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PromotionsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    
    IBOutlet UITableView *promotionTableView;
}

-(IBAction)menuAction:(id)sender;

-(void)reloadPromotions;

@end
