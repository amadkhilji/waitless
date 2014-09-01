//
//  LegalPrivacyViewController.h
//  WaitlessPO
//
//  Created by SSASOFT on 12/16/13.
//  Copyright (c) 2013 Amad Khilji. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LegalPrivacyViewController : UIViewController {
    
    IBOutlet UIScrollView *scrollView;
}

-(IBAction)backAction:(id)sender;
-(IBAction)termsOfServiceAction:(id)sender;
-(IBAction)privacyPolicyAction:(id)sender;
-(IBAction)openSourceAttributionsAction:(id)sender;

@end
