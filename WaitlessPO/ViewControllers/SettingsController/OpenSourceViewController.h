//
//  OpenSourceViewController.h
//  WaitlessPO
//
//  Created by SSASOFT on 1/1/14.
//  Copyright (c) 2014 Amad Khilji. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OpenSourceViewController : UIViewController {
    
    IBOutlet UIScrollView *scrollView;
}

-(IBAction)backAction:(id)sender;
-(IBAction)facebookWebsiteAction:(id)sender;
-(IBAction)googlePlusWebsiteAction:(id)sender;
-(IBAction)apacheLicenseAction:(id)sender;
-(IBAction)OAuthConsumerWebsiteAction:(id)sender;
-(IBAction)MITLicenseAction:(id)sender;
-(IBAction)dwollaWebsiteAction:(id)sender;
-(IBAction)SDWebImageWebsiteAction:(id)sender;
-(IBAction)JSONKitWebsiteAction:(id)sender;

@end
