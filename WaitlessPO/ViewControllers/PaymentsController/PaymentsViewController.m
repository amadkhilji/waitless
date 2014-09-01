//
//  PaymentsViewController.m
//  WaitlessPO
//
//  Created by Amad Khilji on 08/12/2013.
//  Copyright (c) 2013 Amad Khilji. All rights reserved.
//

#import "PaymentsViewController.h"
#import "MFSideMenu.h"
#import "UserModel.h"
#import "DwollaViewController.h"
#import "PaymentCell.h"
#import "PaymentSection.h"
#import "BrainTreeViewController.h"

@interface PaymentsViewController ()

-(void)reloadPaymentMethods;
-(void)showRenewPaymentAlert;
-(void)hideRenewPaymentAlertWithAccountInfo:(BOOL)showAccountInfo;
-(void)goToDwollaPaymentAccount;
-(void)goToBrainTreePayment;

@end

@implementation PaymentsViewController

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
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    myPaymentMethods = [NSMutableArray array];
    otherPaymentMethods = [NSMutableArray array];
    creditCardPaymentMethods = [NSMutableArray array];
    
    paymentsTable.backgroundColor = [UIColor clearColor];
    paymentsTable.backgroundView = Nil;
    paymentsTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, paymentsTable.frame.size.width, 20.0)];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self reloadPaymentMethods];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [AppInfo sharedInfo].isPaymentMethodVisible = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [AppInfo sharedInfo].isPaymentMethodVisible = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark
#pragma mark Private Methods

-(void)reloadPaymentMethods {
    
    UserModel *user = [AppInfo sharedInfo].user;
    
    [myPaymentMethods removeAllObjects];
    [otherPaymentMethods removeAllObjects];
    [creditCardPaymentMethods removeAllObjects];
    
    BOOL hasFoundDwolla = NO;
    BOOL hasFoundPaypal = NO;
    BOOL hasFoundVisa = NO;
    BOOL hasFoundMasterCard = NO;
    BOOL hasFoundAmericanExpress = NO;
    BOOL hasFoundDiscover = NO;
    for (int i=0; i<[user.authenticationList count]; i++) {
        NSDictionary *paymentMethod = [user.authenticationList objectAtIndex:i];
        if (paymentMethod && [paymentMethod objectForKey:@"Provider"] && (NSNull*)[paymentMethod objectForKey:@"Provider"] != [NSNull null]) {
            NSMutableDictionary *paymentData = [NSMutableDictionary dictionary];
            if ([[paymentMethod objectForKey:@"Provider"] isEqualToString:DWOLLA_PAYMENT]) {
                hasFoundDwolla = YES;
                [paymentData setObject:DWOLLA_PAYMENT forKey:@"CardType"];
                [paymentData setObject:DWOLLA_PAYMENT forKey:@"Title"];
                [myPaymentMethods addObject:paymentData];
            }
            else if ([[paymentMethod objectForKey:@"Provider"] isEqualToString:PAYPAL_PAYMENT]) {
//                hasFoundPaypal = YES;
//                [paymentData setObject:PAYPAL_PAYMENT forKey:@"CardType"];
//                [paymentData setObject:PAYPAL_PAYMENT forKey:@"Title"];
//                [myPaymentMethods addObject:paymentData];
            }
            else if ([[paymentMethod objectForKey:@"Provider"] isEqualToString:BRAINTREE_PAYMENT] && [paymentMethod objectForKey:@"CardType"] && (NSNull*)[paymentMethod objectForKey:@"CardType"] != [NSNull null]) {
                NSString *cardType = [[paymentMethod objectForKey:@"CardType"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                if ([cardType isEqualToString:VISA_PAYMENT]) {
                    hasFoundVisa = YES;
                    [paymentData setObject:VISA_PAYMENT forKey:@"CardType"];
                    [paymentData setObject:[paymentMethod objectForKey:@"OAuthToken"] forKey:@"Title"];
                    [myPaymentMethods addObject:paymentData];
                }
                else if ([cardType isEqualToString:MASTER_CARD_PAYMENT] || [cardType isEqualToString:MASTER_CARD_PAYMENT_]) {
                    hasFoundMasterCard = YES;
                    [paymentData setObject:MASTER_CARD_PAYMENT forKey:@"CardType"];
                    [paymentData setObject:[paymentMethod objectForKey:@"OAuthToken"] forKey:@"Title"];
                    [myPaymentMethods addObject:paymentData];
                }
                else if ([cardType isEqualToString:AMERICAN_EXPRESS_PAYMENT] || [cardType isEqualToString:AMERICAN_EXPRESS_PAYMENT_]) {
                    hasFoundAmericanExpress = YES;
                    [paymentData setObject:AMERICAN_EXPRESS_PAYMENT forKey:@"CardType"];
                    [paymentData setObject:[paymentMethod objectForKey:@"OAuthToken"] forKey:@"Title"];
                    [myPaymentMethods addObject:paymentData];
                }
                else if ([cardType isEqualToString:DISCOVER_PAYMENT]) {
                    hasFoundDiscover = YES;
                    [paymentData setObject:DISCOVER_PAYMENT forKey:@"CardType"];
                    [paymentData setObject:[paymentMethod objectForKey:@"OAuthToken"] forKey:@"Title"];
                    [myPaymentMethods addObject:paymentData];
                }
            }
        }
    }
    
    if (!hasFoundDwolla) {
        NSMutableDictionary *paymentData = [NSMutableDictionary dictionary];
        [paymentData setObject:DWOLLA_PAYMENT forKey:@"CardType"];
        [paymentData setObject:DWOLLA_PAYMENT forKey:@"Title"];
        [otherPaymentMethods addObject:paymentData];
    }
    if (!hasFoundPaypal) {
//        NSMutableDictionary *paymentData = [NSMutableDictionary dictionary];
//        [paymentData setObject:PAYPAL_PAYMENT forKey:@"CardType"];
//        [paymentData setObject:PAYPAL_PAYMENT forKey:@"Title"];
//        [otherPaymentMethods addObject:paymentData];
    }
    if (!hasFoundVisa) {
        NSMutableDictionary *paymentData = [NSMutableDictionary dictionary];
        [paymentData setObject:VISA_PAYMENT forKey:@"CardType"];
        [paymentData setObject:VISA_PAYMENT forKey:@"Title"];
        [creditCardPaymentMethods addObject:paymentData];
    }
    if (!hasFoundMasterCard) {
        NSMutableDictionary *paymentData = [NSMutableDictionary dictionary];
        [paymentData setObject:MASTER_CARD_PAYMENT forKey:@"CardType"];
        [paymentData setObject:MASTER_CARD_PAYMENT_ forKey:@"Title"];
        [creditCardPaymentMethods addObject:paymentData];
    }
    if (!hasFoundAmericanExpress) {
        NSMutableDictionary *paymentData = [NSMutableDictionary dictionary];
        [paymentData setObject:AMERICAN_EXPRESS_PAYMENT forKey:@"CardType"];
        [paymentData setObject:AMERICAN_EXPRESS_PAYMENT_ forKey:@"Title"];
        [creditCardPaymentMethods addObject:paymentData];
    }
    if (!hasFoundDiscover) {
        NSMutableDictionary *paymentData = [NSMutableDictionary dictionary];
        [paymentData setObject:DISCOVER_PAYMENT forKey:@"CardType"];
        [paymentData setObject:DISCOVER_PAYMENT forKey:@"Title"];
        [creditCardPaymentMethods addObject:paymentData];
    }
    
    [paymentsTable reloadData];
}

-(void)showRenewPaymentAlert {

    [self.view setUserInteractionEnabled:NO];
    if (renewPaymentType == PaymentTypeDwolla) {
        renew_title_lbl.text = @"Renew Dwolla Details";
        renew_description_lbl.text = @"Do you want to renew your Dwolla account details?";
    }
    else if (renewPaymentType == PaymentTypeAmericanExpress || renewPaymentType == PaymentTypeDiscover || renewPaymentType == PaymentTypeMasterCard || renewPaymentType == PaymentTypeVisa) {
        renew_title_lbl.text = @"Renew Credit Card Details";
        renew_description_lbl.text = @"Do you want to renew your Credit Card details?";
    }
    CGRect frame = renew_payment_alert.frame;
    frame.origin = CGPointZero;
    renew_payment_alert.frame = frame;
    renew_payment_alert.alpha = 0.0;
    [self.view addSubview:renew_payment_alert];
    [UIView animateWithDuration:0.3 animations:^{
        renew_payment_alert.alpha = 1.0;
    }completion:^(BOOL finished){
        if (finished) {
            [self.view setUserInteractionEnabled:YES];
        }
    }];
}

-(void)hideRenewPaymentAlertWithAccountInfo:(BOOL)showAccountInfo {
    
    [self.view setUserInteractionEnabled:NO];
    [UIView animateWithDuration:0.3 animations:^{
        renew_payment_alert.alpha = 0.0;
    }completion:^(BOOL finished){
        if (finished) {
            [renew_payment_alert removeFromSuperview];
            [self.view setUserInteractionEnabled:YES];
            if (showAccountInfo) {
                if (renewPaymentType == PaymentTypeDwolla) {
                    [self goToDwollaPaymentAccount];
                }
                else if (renewPaymentType == PaymentTypeAmericanExpress || renewPaymentType == PaymentTypeDiscover || renewPaymentType == PaymentTypeMasterCard || renewPaymentType == PaymentTypeVisa) {
                    [self goToBrainTreePayment];
                }
            }
        }
    }];
}

-(void)goToDwollaPaymentAccount {
    
    DwollaViewController *dwollaVC = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"DwollaViewController"];
    dwollaVC.isModalPresentationStyle = NO;
    [self.navigationController pushViewController:dwollaVC animated:YES];
}

-(void)goToBrainTreePayment {
    
    BrainTreeViewController *brainTreeVC = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"BrainTreeViewController"];
    [self.navigationController pushViewController:brainTreeVC animated:YES];
}

#pragma mark
#pragma mark Logical Methods

-(void)selectPaymentMethodAtIndexPath:(NSIndexPath*)indexPath withPaymentType:(PaymentType)paymentType {
    
    if (indexPath.section == 0) {
        renewPaymentType = paymentType;
        [self showRenewPaymentAlert];
    }
    else {
        if (paymentType == PaymentTypeDwolla) {
            [self goToDwollaPaymentAccount];
        }
        else if (paymentType == PaymentTypeAmericanExpress || paymentType == PaymentTypeDiscover || paymentType == PaymentTypeMasterCard || paymentType == PaymentTypeVisa) {
            [self goToBrainTreePayment];
        }
    }
}

#pragma mark
#pragma mark IBAction Methods

-(IBAction)menuAction:(id)sender {
    
    [self.menuContainerViewController setMenuState:MFSideMenuStateLeftMenuOpen];
}

-(IBAction)myPaymentsAction:(id)sender {
    
//    if (dwolla_payment_view.hidden) {
//        [self goToDwollaPaymentAccount];
//    }
//    else {
//        [self showRenewPaymentAlert];
//    }
}

-(IBAction)okRenewPaymentAction:(id)sender {
    
    [self hideRenewPaymentAlertWithAccountInfo:YES];
}

-(IBAction)cancelRenewPaymentAction:(id)sender {
    
    [self hideRenewPaymentAlertWithAccountInfo:NO];
}

#pragma mark
#pragma mark UITableViewDelegate/UITableViewDataSource Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    return 50.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {

    return 44.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    if (section == 0) {
        return footerView.frame.size.height;
    }
    else {
        return 20.0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    PaymentSection *paymentSection = [[[NSBundle mainBundle] loadNibNamed:@"PaymentSection" owner:self options:Nil] lastObject];
    if (section == 0) {
        paymentSection.title_lbl.text = @"My Payment Sources";
    }
    else if (section == 1) {
        if ([creditCardPaymentMethods count] > 0) {
            paymentSection.title_lbl.text = @"Credit and Debit Cards";
        }
        else {
            paymentSection.title_lbl.text = @"Other Payment Methods";
        }
    }
    else if (section == 2) {
        paymentSection.title_lbl.text = @"Other Payment Methods";
    }
    
    return paymentSection;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    if (section == 0) {
        return footerView;
    }
    else {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, paymentsTable.frame.size.width, 20.0)];
        view.backgroundColor = [UIColor clearColor];
        return view;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    int count = 1;
    if ([creditCardPaymentMethods count] > 0) {
        count++;
    }
    if ([otherPaymentMethods count] > 0) {
        count++;
    }
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        if ([myPaymentMethods count] == 0) {
            return 1;
        }
        else {
            return [myPaymentMethods count];
        }
    }
    else if (section == 1) {
        if ([creditCardPaymentMethods count] > 0) {
            return [creditCardPaymentMethods count];
        }
        else {
            return [otherPaymentMethods count];
        }
    }
    else {
        return [otherPaymentMethods count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"PaymentCellIdentifier";
    PaymentCell *cell = (PaymentCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"PaymentCell" owner:self options:Nil] lastObject];
    }
    
    NSDictionary *paymentMethod = Nil;
    if (indexPath.section == 0) {
        if ([myPaymentMethods count] == 0) {
            cell.title_lbl.text = @"No Payment Source Selected";
            cell.imageView.image = nil;
            cell.paymentType = PaymentTypeNone;
        }
        else {
            paymentMethod = [myPaymentMethods objectAtIndex:indexPath.row];
        }
    }
    else if (indexPath.section == 1) {
        if ([creditCardPaymentMethods count] > 0) {
            paymentMethod = [creditCardPaymentMethods objectAtIndex:indexPath.row];
        }
        else {
            paymentMethod = [otherPaymentMethods objectAtIndex:indexPath.row];
        }
    }
    else if (indexPath.section == 2) {
        paymentMethod = [otherPaymentMethods objectAtIndex:indexPath.row];
    }
    
    if (paymentMethod) {
        cell.title_lbl.text = [paymentMethod objectForKey:@"Title"];
        if ([[paymentMethod objectForKey:@"CardType"] isEqualToString:DWOLLA_PAYMENT]) {
            cell.paymentType = PaymentTypeDwolla;
            cell.imageView.image = [UIImage imageNamed:@"dwolla_icon.png"];
        }
        else if ([[paymentMethod objectForKey:@"CardType"] isEqualToString:PAYPAL_PAYMENT]) {
            cell.paymentType = PaymentTypePaypal;
            cell.imageView.image = [UIImage imageNamed:@"paypal_icon.png"];
        }
        else if ([[paymentMethod objectForKey:@"CardType"] isEqualToString:VISA_PAYMENT]) {
            cell.paymentType = PaymentTypeVisa;
            cell.imageView.image = [UIImage imageNamed:@"visa_icon.png"];
        }
        else if ([[paymentMethod objectForKey:@"CardType"] isEqualToString:MASTER_CARD_PAYMENT]) {
            cell.paymentType = PaymentTypeMasterCard;
            cell.imageView.image = [UIImage imageNamed:@"mc_icon.png"];
        }
        else if ([[paymentMethod objectForKey:@"CardType"] isEqualToString:AMERICAN_EXPRESS_PAYMENT]) {
            cell.paymentType = PaymentTypeAmericanExpress;
            cell.imageView.image = [UIImage imageNamed:@"amex_icon.png"];
        }
        else if ([[paymentMethod objectForKey:@"CardType"] isEqualToString:DISCOVER_PAYMENT]) {
            cell.paymentType = PaymentTypeDiscover;
            cell.imageView.image = [UIImage imageNamed:@"discover_icon.png"];
        }
    }
    
    cell.indexPath = indexPath;
    cell.parentController = self;
    [cell resetLayout];
    
    return cell;
}

@end
