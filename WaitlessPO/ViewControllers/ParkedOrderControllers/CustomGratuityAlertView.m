//
//  CustomGratuityAlertView.m
//  WaitlessPO
//
//  Created by SSASOFT on 10/2/14.
//  Copyright (c) 2014 Amad Khilji. All rights reserved.
//

#import "CustomGratuityAlertView.h"
#import "UIView+AlertAnimations.h"
#import <QuartzCore/QuartzCore.h>

@interface CustomGratuityAlertView ()

-(void)dismiss;
-(void)alertDidFadeOut;

@end

@implementation CustomGratuityAlertView

@synthesize canUpdateGratuity;
@synthesize totalCost, gratuityAmount;
@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)dealloc {
    
    delegate = nil;
    
    [super dealloc];
}

#pragma mark
#pragma mark Private Methods

-(void)dismiss {
    
    [alertView doFadeOutAnimation];
    [backgroundView doFadeOutAnimationWithDelegate:self];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:kPopAnimationDuration];
    self.view.alpha = 0.0;
    [UIView commitAnimations];
}

-(void)alertDidFadeOut {
    
    [self.view removeFromSuperview];
    [self autorelease];
}

#pragma mark
#pragma mark Logical Methods

-(void)show {
    
    // Retaining self is odd, but we do it to make this "fire and forget"
    [self retain];
    
    // We need to add it to the window, which we can get from the delegate
    id appDelegate = [[UIApplication sharedApplication] delegate];
    UIWindow *window = [appDelegate window];
    [window addSubview:self.view];
    
    // Make sure the alert covers the whole window
    self.view.frame = CGRectMake(0, 0, window.frame.size.width, window.frame.size.height);
    self.view.center = window.center;
//    alertView.center = self.view.center;
    
    // "Pop in" animation for alert
//    [alertView doPopInAnimation];
    [alertView doFadeInAnimation];
    // "Fade in" animation for background
    [backgroundView doFadeInAnimation];
    
    gratuity10_btn.selected = YES;
    gratuity15_btn.selected = NO;
    gratuity20_btn.selected = NO;
    gratuityCustom_btn.selected = NO;
    gratuity_TF.text = [NSString stringWithFormat:@"%.2f", gratuityAmount];
    gratuity_TF.enabled = NO;
    gratuityAmount = (totalCost*10.0)/100.0;
    
    if (canUpdateGratuity) {
        cancel_btn_bar.hidden = YES;
        save_btn_bar.hidden = NO;
    }
    else {
        save_btn_bar.hidden = YES;
        cancel_btn_bar.hidden = NO;
    }
}

#pragma mark
#pragma mark - IBAction Methods

-(IBAction)gratuity10Action:(id)sender {
    
    gratuity10_btn.selected = YES;
    gratuity15_btn.selected = NO;
    gratuity20_btn.selected = NO;
    gratuityCustom_btn.selected = NO;
    gratuity_TF.enabled = NO;
    [gratuity_TF resignFirstResponder];
    
    gratuityAmount = (totalCost*10.0)/100.0;
}

-(IBAction)gratuity15Action:(id)sender {
    
    gratuity15_btn.selected = YES;
    gratuity10_btn.selected = NO;
    gratuity20_btn.selected = NO;
    gratuityCustom_btn.selected = NO;
    gratuity_TF.enabled = NO;
    [gratuity_TF resignFirstResponder];
    
    gratuityAmount = (totalCost*15.0)/100.0;
}

-(IBAction)gratuity20Action:(id)sender {
    
    gratuity20_btn.selected = YES;
    gratuity10_btn.selected = NO;
    gratuity15_btn.selected = NO;
    gratuityCustom_btn.selected = NO;
    gratuity_TF.enabled = NO;
    [gratuity_TF resignFirstResponder];
    
    gratuityAmount = (totalCost*20.0)/100.0;
}

-(IBAction)gratuityCustomAction:(id)sender {
    
    gratuity10_btn.selected = NO;
    gratuity15_btn.selected = NO;
    gratuity20_btn.selected = NO;
    gratuityCustom_btn.selected = YES;
    gratuity_TF.enabled = YES;
    
    if (gratuity_TF.text.length > 0) {
        gratuityAmount = [gratuity_TF.text floatValue];
    }
    else {
        gratuityAmount = 0.0;
    }
}

-(IBAction)cancelAction:(id)sender {
    
    [self dismiss];
}

-(IBAction)saveAction:(id)sender {
    
    [gratuity_TF resignFirstResponder];
    if (delegate && [delegate respondsToSelector:@selector(customAlertView:dismissedWithValue:)]) {
        [delegate customAlertView:self dismissedWithValue:[NSString stringWithFormat:@"%f", gratuityAmount]];
    }
    [self dismiss];
}

-(IBAction)doneAction:(id)sender {
    
    [gratuity_TF resignFirstResponder];
    if (gratuity_TF.text.length > 0) {
        gratuityAmount = [gratuity_TF.text floatValue];
    }
    else {
        gratuityAmount = 0.0;
    }
}

#pragma mark
#pragma mark UITextFieldDelegate Methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    textField.inputAccessoryView = toolbar;
    if ([UIScreen mainScreen].bounds.size.height <= 480.0) {
//        [self.view setUserInteractionEnabled:NO];
        CGRect frame = alertView.frame;
        frame.origin.y = 20.0;
        [UIView animateWithDuration:0.2 animations:^{
            alertView.frame = frame;
        }completion:^(BOOL finished){
            if (finished) {
//                [self.view setUserInteractionEnabled:YES];
            }
        }];
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    if ([UIScreen mainScreen].bounds.size.height <= 480.0) {
//        [self.view setUserInteractionEnabled:NO];
        CGRect frame = alertView.frame;
        frame.origin.y = 70.0;
        [UIView animateWithDuration:0.2 animations:^{
            alertView.frame = frame;
        }completion:^(BOOL finished){
            if (finished) {
//                [self.view setUserInteractionEnabled:YES];
            }
        }];
    }
}

@end
