//
//  PaymentMethodsAlertView.m
//  WaitlessPO
//
//  Created by Amad Khilji on 17/03/2014.
//  Copyright (c) 2014 Amad Khilji. All rights reserved.
//

#import "PaymentMethodsAlertView.h"
#import "PODetailsViewController.h"
#import "UIView+AlertAnimations.h"
#import "UserModel.h"
#import "RestaurantModel.h"

@interface PaymentMethodsAlertView ()

- (void)reloadPaymentMethods;
- (void)alertDidFadeOut;

@end

@implementation PaymentMethodsAlertView

@synthesize alertView, backgroundView;
@synthesize delegate;
@synthesize parentController;

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    
    delegate = nil;
    parentController = nil;
    
    [paymentMethods release];
    [alertView release];
    [backgroundView release];
    
    [super dealloc];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark
#pragma mark Private Methods

- (void)reloadPaymentMethods {
    
    RestaurantModel *restaurant = [parentController.orderDetails objectForKey:@"restaurantModel"];
    UserModel *user = [AppInfo sharedInfo].user;
    
    if (!paymentMethods) {
        paymentMethods = [[NSMutableArray alloc] init];
    }
    
    [paymentMethods removeAllObjects];
    
    for (int i=0; i<[user.authenticationList count]; i++) {
        NSDictionary *paymentMethod = [user.authenticationList objectAtIndex:i];
        if (paymentMethod && [paymentMethod objectForKey:@"Provider"] && (NSNull*)[paymentMethod objectForKey:@"Provider"] != [NSNull null]) {
            NSString *provider = [[paymentMethod objectForKey:@"Provider"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSMutableDictionary *paymentData = [NSMutableDictionary dictionary];
            if ([provider isEqualToString:DWOLLA_PAYMENT]) {
                BOOL isAvailable = NO;
                for (int j=0; j<[restaurant.paymentList count] && !isAvailable; j++) {
                    if ([[[restaurant.paymentList objectAtIndex:j] objectForKey:@"Name"] isEqualToString:DWOLLA_PAYMENT]) {
                        isAvailable = YES;
                    }
                }
                if (isAvailable) {
                    [paymentData setObject:DWOLLA_PAYMENT forKey:@"CardType"];
                    [paymentData setObject:DWOLLA_PAYMENT forKey:@"Title"];
                    [paymentMethods addObject:paymentData];
                }
            }
            else if ([provider isEqualToString:PAYPAL_PAYMENT]) {
                BOOL isAvailable = NO;
                for (int j=0; j<[restaurant.paymentList count] && !isAvailable; j++) {
                    if ([[[restaurant.paymentList objectAtIndex:j] objectForKey:@"Name"] isEqualToString:PAYPAL_PAYMENT]) {
                        isAvailable = YES;
                    }
                }
                if (isAvailable) {
                    [paymentData setObject:PAYPAL_PAYMENT forKey:@"CardType"];
                    [paymentData setObject:PAYPAL_PAYMENT forKey:@"Title"];
                    [paymentMethods addObject:paymentData];
                }
            }
            else if ([provider isEqualToString:BRAINTREE_PAYMENT] && [paymentMethod objectForKey:@"CardType"] && (NSNull*)[paymentMethod objectForKey:@"CardType"] != [NSNull null]) {
                NSString *cardType = [[paymentMethod objectForKey:@"CardType"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                BOOL isAvailable = NO;
                for (int j=0; j<[restaurant.paymentList count] && !isAvailable; j++) {
                    if ([[[restaurant.paymentList objectAtIndex:j] objectForKey:@"Name"] isEqualToString:BRAINTREE_PAYMENT]) {
                        isAvailable = YES;
                    }
                }
                if (isAvailable) {
                    if ([cardType isEqualToString:VISA_PAYMENT]) {
                        [paymentData setObject:VISA_PAYMENT forKey:@"CardType"];
                        [paymentData setObject:[paymentMethod objectForKey:@"OAuthToken"] forKey:@"Title"];
                        [paymentMethods addObject:paymentData];
                    }
                    else if ([cardType isEqualToString:MASTER_CARD_PAYMENT] || [cardType isEqualToString:MASTER_CARD_PAYMENT_]) {
                        [paymentData setObject:MASTER_CARD_PAYMENT forKey:@"CardType"];
                        [paymentData setObject:[paymentMethod objectForKey:@"OAuthToken"] forKey:@"Title"];
                        [paymentMethods addObject:paymentData];
                    }
                    else if ([cardType isEqualToString:AMERICAN_EXPRESS_PAYMENT] || [cardType isEqualToString:AMERICAN_EXPRESS_PAYMENT_]) {
                        [paymentData setObject:AMERICAN_EXPRESS_PAYMENT forKey:@"CardType"];
                        [paymentData setObject:[paymentMethod objectForKey:@"OAuthToken"] forKey:@"Title"];
                        [paymentMethods addObject:paymentData];
                    }
                    else if ([cardType isEqualToString:DISCOVER_PAYMENT]) {
                        [paymentData setObject:DISCOVER_PAYMENT forKey:@"CardType"];
                        [paymentData setObject:[paymentMethod objectForKey:@"OAuthToken"] forKey:@"Title"];
                        [paymentMethods addObject:paymentData];
                    }
                }
            }
        }
    }
    
    [paymentMethodTable reloadData];
}

- (void)alertDidFadeOut
{
    [self.view removeFromSuperview];
    [self autorelease];
}

#pragma mark
#pragma mark Logical Methods

/**
 Show this view with alert animation
 
 @param: nil
 @return: nil
 */

- (void)show
{
    // Retaining self is odd, but we do it to make this "fire and forget"
    [self retain];
    
    // We need to add it to the window, which we can get from the delegate
    //    id appDelegate = [[UIApplication sharedApplication] delegate];
    //    UIWindow *window = [appDelegate window];
    //    [window addSubview:self.view];
    
    [parentController.view addSubview:self.view];
    // Make sure the alert covers the whole window
    //    self.view.frame = CGRectMake(0, 0, window.frame.size.height, window.frame.size.width);
    //    self.view.center = window.center;
    
    [self reloadPaymentMethods];
    // "Pop in" animation for alert
//    [alertView doPopInAnimation];
    
    // "Fade in" animation for background
    [backgroundView doFadeInAnimation];
    
}

/**
 Hide this view with alert animation
 
 @param: nil
 @return: nil
 */

- (IBAction)dismiss
{
//    [alertView doPopOutAnimation];
    [backgroundView doFadeOutAnimationWithDelegate:self];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:kPopAnimationDuration];
    self.view.alpha = 0.0;
    [UIView commitAnimations];
    
}

#pragma mark
#pragma mark UITableViewDelegate/UITableViewDataSource Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 44.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger count = 0;
    if ([paymentMethods count] == 0) {
        count = 1;
    }
    else {
        count = [paymentMethods count];
    }
    float height = (count*44.0)+count;
    CGRect frame = paymentMethodTable.frame;
    frame.size.height = height;
    paymentMethodTable.frame = frame;
    frame = alertView.frame;
    frame.size.height = paymentMethodTable.frame.origin.y+paymentMethodTable.frame.size.height;
    alertView.frame = frame;
    alertView.center = self.view.center;
    frame = alertView.frame;
    frame.origin.y = frame.origin.y-paymentMethodTable.frame.origin.y;
    alertView.frame = frame;
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"PaymentMethodCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        cell.textLabel.textColor = [UIColor blackColor];
        cell.backgroundColor = [UIColor clearColor];//[UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0];
        UIView *bgColorView = [[[UIView alloc] init] autorelease];
        bgColorView.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:0 blue:0 alpha:0.2];
        [cell setSelectedBackgroundView:bgColorView];
    }
    
    if (indexPath.row < [paymentMethods count]) {
        NSDictionary *paymentMethod = [paymentMethods objectAtIndex:indexPath.row];
        if (paymentMethod) {
            cell.textLabel.text = [paymentMethod objectForKey:@"Title"];
            if ([[paymentMethod objectForKey:@"CardType"] isEqualToString:DWOLLA_PAYMENT]) {
                cell.imageView.image = [UIImage imageNamed:@"dwolla_icon.png"];
            }
            else if ([[paymentMethod objectForKey:@"CardType"] isEqualToString:PAYPAL_PAYMENT]) {
                cell.imageView.image = [UIImage imageNamed:@"paypal_icon.png"];
            }
            else if ([[paymentMethod objectForKey:@"CardType"] isEqualToString:VISA_PAYMENT]) {
                cell.imageView.image = [UIImage imageNamed:@"visa_icon.png"];
            }
            else if ([[paymentMethod objectForKey:@"CardType"] isEqualToString:MASTER_CARD_PAYMENT]) {
                cell.imageView.image = [UIImage imageNamed:@"mc_icon.png"];
            }
            else if ([[paymentMethod objectForKey:@"CardType"] isEqualToString:AMERICAN_EXPRESS_PAYMENT]) {
                cell.imageView.image = [UIImage imageNamed:@"amex_icon.png"];
            }
            else if ([[paymentMethod objectForKey:@"CardType"] isEqualToString:DISCOVER_PAYMENT]) {
                cell.imageView.image = [UIImage imageNamed:@"discover_icon.png"];
            }
        }
    }
    else {
        cell.imageView.image = nil;
        cell.textLabel.text = @"No payment source is available.";
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row < [paymentMethods count]) {
        NSDictionary *paymentMethod = [paymentMethods objectAtIndex:indexPath.row];
        if (delegate && [delegate respondsToSelector:@selector(customAlertView:dismissedWithValue:)]) {
            [delegate customAlertView:self dismissedWithValue:[paymentMethod objectForKey:@"CardType"]];
        }
    }
    else {
        if (delegate && [delegate respondsToSelector:@selector(customAlertView:dismissedWithValue:)]) {
            [delegate customAlertView:self dismissedWithValue:@"None"];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self dismiss];
}

#pragma mark CAAnimation Delegate Methods
- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
    [self alertDidFadeOut];
}

@end
