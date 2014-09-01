//
//  ReviewOrderVC.m
//  WaitlessPO
//
//  Created by Amad Khilji on 03/02/2014.
//  Copyright (c) 2014 Amad Khilji. All rights reserved.
//

#import "ReviewOrderVC.h"
#import "SVProgressHUD.h"
#import "PODetailsViewController.h"
#import "UserModel.h"

@interface ReviewOrderVC ()

-(void)dismissReviewOrderAlert;
-(void)loadOrderDetails;
-(void)requestReviewParkedOrder;
-(void)dismissReviewOrderAlertWithMessage:(NSString*)message;

@end

@implementation ReviewOrderVC

@synthesize parkedOrderId, parkedOrderTitle, restaurantId;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self loadOrderDetails];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark
#pragma mark Private Methods

-(void)loadOrderDetails {
    
    CGPoint center = self.view.center;
    if ([[UIDevice currentDevice].systemVersion floatValue] < 7.0) {
        center.y-=20.0;
    }
    title_lbl.text = parkedOrderTitle;
    review_view.center = center;
    comments_TV.text = @"Comments";
    comments_TV.textColor = [UIColor grayColor];
    isPlaceHolder = YES;
    customReview.delegate = self;
    [customReview setRatingValue:0];
    rate_lbl.text = @"UnRated";
}

-(void)dismissReviewOrderAlert {
    
    [self dismissReviewOrderAlertWithMessage:Nil];
}

-(void)dismissReviewOrderAlertWithMessage:(NSString*)message {
    
    [UIView animateWithDuration:0.3 animations:^{
        self.view.alpha = 0.0;
    }completion:^(BOOL finished){
        
        if (finished) {
            [self.view removeFromSuperview];
            if (message) {
                [parentController showSuccessMessage:message];
            }
        }
    }];
}

-(void)requestReviewParkedOrder {
    
    [SVProgressHUD showWithStatus:@"Updating parked order review..." maskType:SVProgressHUDMaskTypeGradient];
    UserModel *user = [AppInfo sharedInfo].user;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:user.tokenID forKey:@"TokenId"];
    [params setObject:user.userID forKey:@"UserId"];
    [params setObject:parkedOrderId forKey:@"ParkedOrderId"];
    [params setObject:restaurantId forKey:@"RestaurantId"];
    [params setObject:[NSNumber numberWithInt:customReview.rating] forKey:@"Rate"];
    [params setObject:(isPlaceHolder)?@"":comments_TV.text forKey:@"Comment"];
    [HTTPRequest requestPostWithMethod:@"RestaurantService/ParkedOrder/Review" Params:params andDelegate:self];
}

#pragma mark
#pragma mark Public Methods

-(void)setParentController:(PODetailsViewController*)viewController {
    
    parentController = viewController;
}

-(void)showReviewOrderAlert {
    
    CGRect frame = self.view.frame;
    frame.origin = CGPointZero;
    self.view.frame = frame;
    self.view.alpha = 0.0;
    [parentController.view addSubview:self.view];
    
    [self loadOrderDetails];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.view.alpha = 1.0;
    }completion:^(BOOL finished){
        
        if (finished) {
            //            [self.view removeFromSuperview];
        }
    }];
}

#pragma mark
#pragma mark IBAction Methods

-(IBAction)doneToolbarAction:(id)sender {
    
    [self.view setUserInteractionEnabled:NO];
    [comments_TV resignFirstResponder];
    if (isPlaceHolder) {
        comments_TV.text = @"Comments";
        comments_TV.textColor = [UIColor grayColor];
    }
    else {
        comments_TV.textColor = [UIColor blackColor];
    }
    CGPoint center = self.view.center;
    if ([[UIDevice currentDevice].systemVersion floatValue] < 7.0) {
        center.y-=20.0;
    }
    [UIView animateWithDuration:0.3 animations:^{
        review_view.center = center;
    }completion:^(BOOL finished){
        if (finished) {
            [self.view setUserInteractionEnabled:YES];
        }
    }];
}

-(IBAction)reviewAction:(id)sender {
    
    NSString *errorMessage = Nil;
    if (customReview.rating == 0) {
        errorMessage = @"Please provide review of your order.";
    }
    if (errorMessage) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Waitless" message:errorMessage delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
        [alertView show];
    }
    else {
        [self requestReviewParkedOrder];
    }
}

-(IBAction)cancelAction:(id)sender {
    
    [self dismissReviewOrderAlert];
}

#pragma mark
#pragma mark RateDelegate Methods

-(void)didChangeRateValue:(int)rateValue {
    
    if (rateValue == 0) {
        rate_lbl.text = @"UnRated";
    }
    else if (rateValue == 1) {
        rate_lbl.text = @"Poor";
    }
    else if (rateValue == 2) {
        rate_lbl.text = @"Below Average";
    }
    else if (rateValue == 3) {
        rate_lbl.text = @"Average";
    }
    else if (rateValue == 4) {
        rate_lbl.text = @"Above Average";
    }
    else if (rateValue == 5) {
        rate_lbl.text = @"Excellent";
    }
}

#pragma mark
#pragma mark UITextViewDelegate Methods

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    
    [self.view setUserInteractionEnabled:NO];
    textView.inputAccessoryView = toolbar;
    if (isPlaceHolder) {
        textView.text = @"";
    }
    textView.textColor = [UIColor blackColor];
    CGPoint center = self.view.center;
    if ([[UIDevice currentDevice].systemVersion floatValue] < 7.0) {
        center.y-=20.0;
    }
    float yOffset = 0.0;
    if ([UIScreen mainScreen].bounds.size.height <= 480.0) {
        yOffset+=textView.frame.size.height;
    }
    else {
        yOffset+=(textView.frame.size.height/2.0);
    }
    center.y -= yOffset;
    [UIView animateWithDuration:0.3 delay:0.1 options:UIViewAnimationOptionCurveEaseIn animations:^{
        review_view.center = center;
    }completion:^(BOOL finished){
        if (finished) {
            [self.view setUserInteractionEnabled:YES];
        }
    }];
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    NSInteger length = [textView.text length];
    length += text.length;
    if (text.length == 0) {
        length--;
    }
    if (length > 0) {
        isPlaceHolder = NO;
    }
    else {
        isPlaceHolder = YES;
    }
    return YES;
}

#pragma mark
#pragma mark HTTPRequestDelegate Methods

-(void)didFinishRequest:(HTTPRequest*)httpRequest withData:(id)data {
    
    [SVProgressHUD dismiss];
    if (data && [data isKindOfClass:[NSDictionary class]] && [data objectForKey:@"IsSuccessful"] && [[data objectForKey:@"IsSuccessful"] boolValue]) {
        [self dismissReviewOrderAlertWithMessage:[data objectForKey:@"Message"]];
    }
}

-(void)didFailRequest:(HTTPRequest*)httpRequest withError:(NSString*)errorMessage {
    
    [SVProgressHUD dismiss];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

@end
