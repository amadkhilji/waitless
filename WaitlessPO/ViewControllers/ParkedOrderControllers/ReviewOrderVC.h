//
//  ReviewOrderVC.h
//  WaitlessPO
//
//  Created by Amad Khilji on 03/02/2014.
//  Copyright (c) 2014 Amad Khilji. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTTPRequest.h"
#import "CustomReview.h"

@class PODetailsViewController;

@interface ReviewOrderVC : UIViewController <UITextViewDelegate, RateDelegate, HTTPRequestDelegate> {
    
    IBOutlet UITextView  *comments_TV;
    IBOutlet UIView *header_view, *review_view;
    IBOutlet UILabel *title_lbl, *rate_lbl;
    IBOutlet UIToolbar *toolbar;
    
    IBOutlet CustomReview *customReview;
    
    BOOL isPlaceHolder;
    PODetailsViewController *parentController;
}

@property (atomic, strong) NSString *parkedOrderId, *parkedOrderTitle, *restaurantId;

-(void)showReviewOrderAlert;
-(void)setParentController:(PODetailsViewController*)viewController;

-(IBAction)doneToolbarAction:(id)sender;
-(IBAction)cancelAction:(id)sender;
-(IBAction)reviewAction:(id)sender;

@end
