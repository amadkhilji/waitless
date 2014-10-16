//
//  CustomGratuityAlertView.h
//  WaitlessPO
//
//  Created by SSASOFT on 10/2/14.
//  Copyright (c) 2014 Amad Khilji. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomAlertViewDelegate.h"

@interface CustomGratuityAlertView : UIViewController <UITextFieldDelegate> {
    
    IBOutlet UIView         *alertView, *backgroundView, *cancel_btn_bar, *save_btn_bar;
    IBOutlet UITextField    *gratuity_TF;
    IBOutlet UIButton       *gratuity10_btn, *gratuity15_btn, *gratuity20_btn, *gratuityCustom_btn;
    IBOutlet UIToolbar      *toolbar;
}

@property (nonatomic, assign) BOOL  canUpdateGratuity;
@property (nonatomic, assign) float totalCost, gratuityAmount;
@property (nonatomic, assign) id<CustomAlertViewDelegate, NSObject> delegate;

-(void)show;
-(IBAction)gratuity10Action:(id)sender;
-(IBAction)gratuity15Action:(id)sender;
-(IBAction)gratuity20Action:(id)sender;
-(IBAction)gratuityCustomAction:(id)sender;
-(IBAction)cancelAction:(id)sender;
-(IBAction)saveAction:(id)sender;
-(IBAction)doneAction:(id)sender;

@end
