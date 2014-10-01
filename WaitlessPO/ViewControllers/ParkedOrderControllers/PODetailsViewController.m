//
//  PODetailsViewController.m
//  WaitlessPO
//
//  Created by Amad Khilji on 14/12/2013.
//  Copyright (c) 2013 Amad Khilji. All rights reserved.
//

#import "PODetailsViewController.h"
#import "RestaurantModel.h"
#import "PODetailsCell.h"
#import "UIImageView+WebCache.h"
#import "MFSideMenu.h"
#import "FoodCategoriesViewController.h"
#import "SVProgressHUD.h"
#import "POEditViewController.h"
#import "UserModel.h"
#import "ShareOrderVC.h"
#import "PaymentMethodsAlertView.h"
#import "ReviewOrderVC.h"
#import "POTransactionVC.h"
#import "BTTransactionVC.h"
#import <MapKit/MapKit.h>

@interface PODetailsViewController ()

-(void)setParkedOrderDetails;
-(void)setOrderCost;
-(void)requestForUpdateParkedOrder;
-(void)requestForUpdateParkedOrderInBackground;
-(void)requestForUpdateParkedOrderPaymentInfo;
-(void)requestForDeleteParkedOrder;
-(void)requestForGettingParkedOrder;
-(void)showBrainTreePaymentAlert;
-(void)showPayNowAlert;

@end

@implementation PODetailsViewController

@synthesize gratuity_rate;
@synthesize foodItemsList;
@synthesize orderDetails;

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
    
    isParkedOrderUpdated = NO;
    isPaymentUpdateRequest = NO;
    isForegroundUpdate = NO;
    isBackButtonUpdate = NO;
    self.menuContainerViewController.panMode = MFSideMenuPanModeNone;
    orderTable.tableFooterView = footerView;
    [self reloadParkedOrderData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setOrderCost];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark
#pragma mark Private Methods

-(void)setParkedOrderDetails {
    
    if (orderDetails) {
        RestaurantModel *restaurantModel = [orderDetails objectForKey:@"restaurantModel"];
        title_lbl.text = [orderDetails objectForKey:@"CustomId"];
        restaurant_name_lbl.text = restaurantModel.restaurantName;
        address_lbl.text = restaurantModel.addressLine1;
        city_state_lbl.text = [NSString stringWithFormat:@"%@, %@. %@", restaurantModel.city, restaurantModel.stateCode, restaurantModel.zipCode];
        if (restaurantModel.primaryPhone.length >= 10 && [restaurantModel.primaryPhone rangeOfCharacterFromSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]].location == NSNotFound) {
            NSMutableString *phoneNumber = [NSMutableString stringWithString:restaurantModel.primaryPhone];
            [phoneNumber insertString:@"(" atIndex:0];
            [phoneNumber insertString:@") " atIndex:4];
            [phoneNumber insertString:@"-" atIndex:9];
            [phone_btn setTitle:phoneNumber forState:UIControlStateNormal];
        }
        if ([[orderDetails objectForKey:@"Status"] intValue] == ParkedOrderStatusOpened) {
            opened_order_bar.hidden = NO;
            closed_order_bar.hidden = YES;
            fulfilled_order_bar.hidden = YES;
        }
        else if ([[orderDetails objectForKey:@"Status"] intValue] == ParkedOrderStatusClosed || [[orderDetails objectForKey:@"Status"] intValue] == ParkedOrderStatusRefunded || [[orderDetails objectForKey:@"Status"] intValue] == ParkedOrderStatusVoided) {
            opened_order_bar.hidden = YES;
            closed_order_bar.hidden = NO;
            fulfilled_order_bar.hidden = YES;
        }
        else if ([[orderDetails objectForKey:@"Status"] intValue] == ParkedOrderStatusFulfilled) {
            opened_order_bar.hidden = YES;
            closed_order_bar.hidden = YES;
            fulfilled_order_bar.hidden = NO;
            BOOL hasDwollaFound = NO, hasBraintreeFound = NO;
            for (int i=0; i<[restaurantModel.paymentList count]; i++) {
                NSDictionary *paymentMethod = [restaurantModel.paymentList objectAtIndex:i];
                if ([[paymentMethod objectForKey:@"Name"] isEqualToString:DWOLLA_PAYMENT]) {
                    hasDwollaFound = YES;
                }
                else if ([[paymentMethod objectForKey:@"Name"] isEqualToString:BRAINTREE_PAYMENT]) {
                    UserModel *user = [AppInfo sharedInfo].user;
                    hasBraintreeFound = YES;
                    credit_card_lbl.text = [NSString stringWithFormat:@"Do you want to complete your order with your %@ %@?", [user getBrainTreeCardType], [user getBrainTreeMaskedNumber]];
                }
            }
        }
        isFavorite_btn1.selected = [[orderDetails objectForKey:@"IsFavorite"] boolValue];
        isFavorite_btn2.selected = isFavorite_btn1.selected;
//        isFavorite_btn3.selected = isFavorite_btn1.selected;
        NSDate *date = [orderDetails objectForKey:@"parkedOrderDate"];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"h:mm a"];
        time_lbl.text = [formatter stringFromDate:date];
        [formatter setDateFormat:@"EEE, MMMM dd"];
        date_lbl.text = [formatter stringFromDate:date];
        party_size_lbl.text = [NSString stringWithFormat:@"%i", [[orderDetails objectForKey:@"PartySize"] intValue]];
        NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", ASSET_URL, restaurantModel.assetUrl]];
        [restaurant_image setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"restaurant_place_holder.png"]];
        [foodItemsList addObjectsFromArray:[[orderDetails objectForKey:@"FoodItemList"] objectForKey:@"List"]];
        if ([orderDetails objectForKey:@"Notes"] && (NSNull*)[orderDetails objectForKey:@"Notes"] != [NSNull null]) {
            notesTV.text = [orderDetails objectForKey:@"Notes"];
        }
        if (restaurantModel.isPayNow) {
            update_order_btn.hidden = YES;
            credit_card_btn.hidden = NO;
        }
        else {
            update_order_btn.hidden = NO;
            credit_card_btn.hidden = YES;
        }
        [orderTable reloadData];
    }
}

-(void)setOrderCost {
    
    if (orderDetails) {
        RestaurantModel *restaurantModel = [orderDetails objectForKey:@"restaurantModel"];
        UserModel *user = [AppInfo sharedInfo].user;
        float total_price = 0.0;
        for (int i=0; i<[foodItemsList count]; i++) {
            NSDictionary *foodItem = [foodItemsList objectAtIndex:i];
            int quantity = [[foodItem objectForKey:@"Quantity"] intValue];
            CGFloat price = [[foodItem objectForKey:@"Price"] floatValue];
            total_price += price*quantity;
        }
        float tax_rate = (total_price*restaurantModel.taxRate)/100.0;
        float sub_total_price = total_price+tax_rate;
        float gratuity = [[orderDetails objectForKey:@"Gratuity"] floatValue];
        if (sub_total_price > 0.0 && [[orderDetails objectForKey:@"IsCustomGratuity"] intValue] == 0) {
            gratuity = (sub_total_price*user.gratuity_rate)/100.0;
        }
        float total_cost = sub_total_price+gratuity;
        price_lbl.text = [NSString stringWithFormat:@"$%.2f", total_price];
        tax_rate_lbl.text = [NSString stringWithFormat:@"$%.2f", tax_rate];
        sub_total_lbl.text = [NSString stringWithFormat:@"$%.2f", sub_total_price];
        gratuity_rate_lbl.text = [NSString stringWithFormat:@"$%.2f", gratuity];
        total_cost_lbl.text = [NSString stringWithFormat:@"$%.2f", total_cost];
        if (sub_total_price > 0) {
            gratuity_rate = (gratuity*100.0)/sub_total_price;
        }
        else {
            if (gratuity > 0.0) {
                gratuity_rate = 100.0;
            }
            else {
                gratuity_rate = 0.0;
            }
        }
        if (total_cost > 0.0) {
            credit_card_btn.enabled = YES;
        }
        else {
            credit_card_btn.enabled = NO;
        }
        gratuity_title_lbl.text = [NSString stringWithFormat:@"Gratuity (%.1f%%)", gratuity_rate];
        CGRect frame = footerView.frame;
        frame.size.height = pickUpTime_footer_view.frame.origin.y;
        footerView.frame = frame;
        pickUpTime_footer_view.hidden = YES;
        convenience_footer_view.hidden = YES;
        if ([[orderDetails objectForKey:@"Status"] intValue] == ParkedOrderStatusClosed) {
            if (restaurantModel.isPayNow) {
                NSDate *date = [orderDetails objectForKey:@"parkedOrderDate"];
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"EEE, MMMM dd h:mm a"];
                pickUpTime_lbl.text = [formatter stringFromDate:date];
                order_number_lbl.text = [[orderDetails objectForKey:@"CustomId"] stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@-", user.emailAddress] withString:@""];
                frame.size.height = pickUpTime_footer_view.frame.origin.y+pickUpTime_footer_view.frame.size.height;
                footerView.frame = frame;
                pickUpTime_footer_view.hidden = NO;
                convenience_footer_view.hidden = YES;
            }
            else if (restaurantModel.isConvenienceFee) {
                BOOL hasFoundDwolla = NO, hasFoundBraintree = NO;
                for (int i=0; i<[user.authenticationList count]; i++) {
                    NSDictionary *dictionary = [user.authenticationList objectAtIndex:i];
                    if ([[dictionary objectForKey:@"Provider"] isEqualToString:BRAINTREE_PAYMENT]) {
                        hasFoundBraintree = YES;
                        break;
                    }
                    else if ([[dictionary objectForKey:@"Provider"] isEqualToString:DWOLLA_PAYMENT]) {
                        hasFoundDwolla = YES;
                        break;
                    }
                }
                if (hasFoundDwolla) {
                    float convenienceFee = 0.38;
                    convenience_lbl.text = [NSString stringWithFormat:@"Please note the Total Cost does not reflect the convenience fee amount of %.2f.", convenienceFee];
                    frame.size.height = convenience_footer_view.frame.origin.y+convenience_footer_view.frame.size.height;
                    footerView.frame = frame;
                    pickUpTime_footer_view.hidden = YES;
                    convenience_footer_view.hidden = NO;
                }
                if (hasFoundBraintree) {
                    float total = total_price+tax_rate+gratuity;
                    float convenienceFee = ((total*0.029+0.3)+0.5)/2;
                    convenience_lbl.text = [NSString stringWithFormat:@"Please note the Total Cost does not reflect the convenience fee amount of %.2f.", convenienceFee];
                    frame.size.height = convenience_footer_view.frame.origin.y+convenience_footer_view.frame.size.height;
                    footerView.frame = frame;
                    pickUpTime_footer_view.hidden = YES;
                    convenience_footer_view.hidden = NO;
                }
            }
        }
        orderTable.tableFooterView = footerView;
        [orderTable reloadData];
    }
}

-(void)requestForUpdateParkedOrderPaymentInfo {
 
    [SVProgressHUD showWithStatus:@"Loading payment info..." maskType:SVProgressHUDMaskTypeGradient];
    isUpdateRequest = YES;
    isPaymentUpdateRequest = YES;
    isGetRequest = NO;
    isBackgroundUpdate = NO;
    isForegroundUpdate = YES;
//    RestaurantModel *restaurantModel = [orderDetails objectForKey:@"restaurantModel"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    NSDate *date = [orderDetails objectForKey:@"parkedOrderDate"];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:[AppInfo sharedInfo].user.tokenID forKey:@"TokenId"];
    [params setObject:[AppInfo sharedInfo].user.loginID forKey:@"LoginId"];
    [params setObject:[orderDetails objectForKey:@"Id"] forKey:@"ParkedOrderId"];
    double gratuity = [[gratuity_rate_lbl.text stringByReplacingOccurrencesOfString:@"$" withString:@""] floatValue];
    int isCustomGratuity = [[orderDetails objectForKey:@"IsCustomGratuity"] intValue];
    [params setObject:[NSNumber numberWithDouble:gratuity] forKey:@"Gratuity"];
    [params setObject:[NSNumber numberWithInt:isCustomGratuity] forKey:@"IsCustomGratuity"];
    [params setObject:[NSNumber numberWithInt:isFavorite_btn1.selected] forKey:@"IsFavorite"];
    [params setObject:[NSNumber numberWithDouble:[[total_cost_lbl.text stringByReplacingOccurrencesOfString:@"$" withString:@""] doubleValue]] forKey:@"TotalCost"];
    [params setObject:[NSNumber numberWithInt:[[orderDetails objectForKey:@"Status"] intValue]] forKey:@"Status"];
    [params setObject:[NSNumber numberWithInt:[party_size_lbl.text intValue]] forKey:@"PartySize"];
    [params setObject:[formatter stringFromDate:date] forKey:@"FulfillmentDate"];
    [params setObject:notesTV.text forKey:@"Notes"];
    NSMutableArray *list = [NSMutableArray array];
    for (int i=0; i<[foodItemsList count]; i++) {
        NSDictionary *food = [foodItemsList objectAtIndex:i];
        NSMutableDictionary *foodItem = [NSMutableDictionary dictionary];
        if ([food objectForKey:@"Id"]) {
            [foodItem setObject:[food objectForKey:@"Id"] forKey:@"FoodItemId"];
        }
        if ([food objectForKey:@"FoodOptionChoiceId"] && (NSNull*)[food objectForKey:@"FoodOptionChoiceId"] != [NSNull null] && [[food objectForKey:@"FoodOptionChoiceId"] length] > 0) {
            [foodItem setObject:[food objectForKey:@"FoodOptionChoiceId"] forKey:@"FoodOptionChoiceId"];
        }
        if ([food objectForKey:@"Price"]) {
            [foodItem setObject:[food objectForKey:@"Price"] forKey:@"Price"];
        }
        if ([food objectForKey:@"Quantity"]) {
            [foodItem setObject:[food objectForKey:@"Quantity"] forKey:@"Quantity"];
        }
        if ([food objectForKey:@"FoodItemAdditionId"] && (NSNull*)[food objectForKey:@"FoodItemAdditionId"] != [NSNull null] && [[food objectForKey:@"FoodItemAdditionId"] length] > 0) {
            [foodItem setObject:[food objectForKey:@"FoodItemAdditionId"] forKey:@"FoodItemAdditionId"];
        }
        [list addObject:foodItem];
    }
    [params setObject:list forKey:@"ParkedOrderItems"];
    [HTTPRequest requestPostWithMethod:@"RestaurantService/ParkedOrder/Update" Params:params andDelegate:self andRequestType:HTTPRequestTypeUpdateParkedOrder];
}

-(void)requestForUpdateParkedOrder {
    
    if (!isBackgroundUpdate) {
        [SVProgressHUD showWithStatus:@"Updating parked order..." maskType:SVProgressHUDMaskTypeGradient];
    }
    isUpdateRequest = YES;
    isGetRequest = NO;
    isBackgroundUpdate = NO;
//    RestaurantModel *restaurantModel = [orderDetails objectForKey:@"restaurantModel"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    NSDate *date = [orderDetails objectForKey:@"parkedOrderDate"];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:[AppInfo sharedInfo].user.tokenID forKey:@"TokenId"];
    [params setObject:[AppInfo sharedInfo].user.loginID forKey:@"LoginId"];
    [params setObject:[orderDetails objectForKey:@"Id"] forKey:@"ParkedOrderId"];
    double gratuity = [[gratuity_rate_lbl.text stringByReplacingOccurrencesOfString:@"$" withString:@""] floatValue];
    int isCustomGratuity = [[orderDetails objectForKey:@"IsCustomGratuity"] intValue];
    [params setObject:[NSNumber numberWithDouble:gratuity] forKey:@"Gratuity"];
    [params setObject:[NSNumber numberWithInt:isCustomGratuity] forKey:@"IsCustomGratuity"];
    [params setObject:[NSNumber numberWithInt:isFavorite_btn1.selected] forKey:@"IsFavorite"];
    [params setObject:[NSNumber numberWithDouble:[[total_cost_lbl.text stringByReplacingOccurrencesOfString:@"$" withString:@""] doubleValue]] forKey:@"TotalCost"];
    [params setObject:[NSNumber numberWithInt:[[orderDetails objectForKey:@"Status"] intValue]] forKey:@"Status"];
    [params setObject:[NSNumber numberWithInt:[party_size_lbl.text intValue]] forKey:@"PartySize"];
    [params setObject:[formatter stringFromDate:date] forKey:@"FulfillmentDate"];
    [params setObject:notesTV.text forKey:@"Notes"];
    NSMutableArray *list = [NSMutableArray array];
    for (int i=0; i<[foodItemsList count]; i++) {
        NSDictionary *food = [foodItemsList objectAtIndex:i];
        NSMutableDictionary *foodItem = [NSMutableDictionary dictionary];
        if ([food objectForKey:@"Id"]) {
            [foodItem setObject:[food objectForKey:@"Id"] forKey:@"FoodItemId"];
        }
        if ([food objectForKey:@"FoodOptionChoiceId"] && (NSNull*)[food objectForKey:@"FoodOptionChoiceId"] != [NSNull null] && [[food objectForKey:@"FoodOptionChoiceId"] length] > 0) {
            [foodItem setObject:[food objectForKey:@"FoodOptionChoiceId"] forKey:@"FoodOptionChoiceId"];
        }
        if ([food objectForKey:@"Price"]) {
            [foodItem setObject:[food objectForKey:@"Price"] forKey:@"Price"];
        }
        if ([food objectForKey:@"Quantity"]) {
            [foodItem setObject:[food objectForKey:@"Quantity"] forKey:@"Quantity"];
        }
        if ([food objectForKey:@"FoodItemAdditionId"] && (NSNull*)[food objectForKey:@"FoodItemAdditionId"] != [NSNull null] && [[food objectForKey:@"FoodItemAdditionId"] length] > 0) {
            [foodItem setObject:[food objectForKey:@"FoodItemAdditionId"] forKey:@"FoodItemAdditionId"];
        }
        [list addObject:foodItem];
    }
    [params setObject:list forKey:@"ParkedOrderItems"];
    [HTTPRequest requestPostWithMethod:@"RestaurantService/ParkedOrder/Update" Params:params andDelegate:self andRequestType:HTTPRequestTypeParkedOrder];
}

-(void)requestForUpdateParkedOrderInBackground {
    
    [self requestForUpdateParkedOrder];
    isBackgroundUpdate = YES;
    [SVProgressHUD dismiss];
}

-(void)requestForDeleteParkedOrder {
    
    [SVProgressHUD showWithStatus:@"Deleting parked order..." maskType:SVProgressHUDMaskTypeGradient];
    isUpdateRequest = NO;
    isGetRequest = NO;
    isBackgroundUpdate = NO;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:[AppInfo sharedInfo].user.tokenID forKey:@"TokenId"];
    [params setObject:[AppInfo sharedInfo].user.loginID forKey:@"LoginId"];
    [params setObject:[orderDetails objectForKey:@"Id"] forKey:@"ParkedOrderId"];
    [params setObject:[NSNumber numberWithInt:1] forKey:@"IsDeprecated"];
//    [params setObject:[NSNumber numberWithInt:7] forKey:@"Status"];
    [HTTPRequest requestPostWithMethod:@"RestaurantService/ParkedOrder/Update" Params:params andDelegate:self andRequestType:HTTPRequestTypeParkedOrder];
}

-(void)requestForGettingParkedOrder {
    
    if (isBackgroundUpdate) {
        [SVProgressHUD dismiss];
    }
    else {
        [SVProgressHUD showWithStatus:@"Updating parked order..." maskType:SVProgressHUDMaskTypeGradient];
    }
    isGetRequest = YES;
    NSDictionary *params = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[AppInfo sharedInfo].user.tokenID, [orderDetails objectForKey:@"Id"], nil] forKeys:[NSArray arrayWithObjects:@"tokenid", @"id", nil]];
    [HTTPRequest requestGetWithMethod:@"RestaurantService/ParkedOrder" Params:params andDelegate:self andRequestType:HTTPRequestTypeParkedOrder];
}

-(void)showSuccessMessage:(NSString*)message {

    [SVProgressHUD showSuccessWithStatus:message];
}

-(void)showErrorMessage:(NSString*)message {
    
    [SVProgressHUD showErrorWithStatus:message];
}

-(void)showBrainTreePaymentAlert {
    
    UserModel *user = [AppInfo sharedInfo].user;
    RestaurantModel *restaurantModel = [orderDetails objectForKey:@"restaurantModel"];
    float subtotal = [[price_lbl.text stringByReplacingOccurrencesOfString:@"$" withString:@""] floatValue];
    float tax = [[tax_rate_lbl.text stringByReplacingOccurrencesOfString:@"$" withString:@""] floatValue];
    float gratuity = [[gratuity_rate_lbl.text stringByReplacingOccurrencesOfString:@"$" withString:@""] floatValue];
    if (!bt_TransactionVC) {
        bt_TransactionVC = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"BTTransactionVC"];
    }
    bt_TransactionVC.parkedOrderId = [orderDetails objectForKey:@"Id"];
    bt_TransactionVC.paymentTitle = [NSString stringWithFormat:@"Do you want to complete your order with your %@ %@?", [user getBrainTreeCardType], [user getBrainTreeMaskedNumber]];
    bt_TransactionVC.subTotal = subtotal;
    bt_TransactionVC.tax = tax;
    bt_TransactionVC.gratuity = gratuity;
    bt_TransactionVC.isConvenienceFee = restaurantModel.isConvenienceFee;
    bt_TransactionVC.delegate = self;
    [bt_TransactionVC showPaymentAlert];
}

-(void)showPayNowAlert {
    
    [self.view setUserInteractionEnabled:NO];
    payNow_alert_view.alpha = 0.0;
    payNow_alert_view.center = self.view.center;
    [UIView animateWithDuration:0.3 animations:^{
        payNow_alert_view.alpha = 1.0;
    }completion:^(BOOL finished) {
        if (finished) {
            [self.view setUserInteractionEnabled:YES];
        }
    }];
}

#pragma mark
#pragma mark Logical Methods

-(void)reloadParkedOrderData {
    
    shouldGoBack = YES;
    gratuity_rate = 0.0;
    foodItemsList = [NSMutableArray array];
    
    [self setParkedOrderDetails];
    [self setOrderCost];
}

-(void)setFoodItem:(NSDictionary*)foodItem {
    
    BOOL found = NO;
    for (int i=0; i<[foodItemsList count] && !found; i++) {
        
        NSDictionary *item = [foodItemsList objectAtIndex:i];
        if ([[item objectForKey:@"Id"] isEqualToString:[foodItem objectForKey:@"Id"]]) {
            id optionID1 = [item objectForKey:@"FoodOptionChoiceId"];
            id optionID2 = [foodItem objectForKey:@"FoodOptionChoiceId"];
            id additionID1 = [item objectForKey:@"FoodItemAdditionId"];
            id additionID2 = [foodItem objectForKey:@"FoodItemAdditionId"];
            if (optionID1 == [NSNull null]) {
                optionID1 = [NSString string];
            }
            if (optionID2 == [NSNull null]) {
                optionID2 = [NSString string];
            }
            if (additionID1 == [NSNull null]) {
                additionID1 = [NSString string];
            }
            if (additionID2 == [NSNull null]) {
                additionID2 = [NSString string];
            }
            if ([optionID1 isEqualToString:optionID2] && [additionID1 isEqualToString:additionID2]) {
                NSMutableDictionary *foodData = [NSMutableDictionary dictionaryWithDictionary:item];
                int quantity = [[item objectForKey:@"Quantity"] intValue];
                [foodData setObject:[NSNumber numberWithInt:quantity+1] forKey:@"Quantity"];
                [foodItemsList replaceObjectAtIndex:i withObject:foodData];
                found = YES;
            }
        }
    }
    if (!found) {
        NSMutableDictionary *item = [NSMutableDictionary dictionary];
        [item setObject:[foodItem objectForKey:@"Id"] forKey:@"Id"];
        [item setObject:[NSNumber numberWithDouble:[[foodItem objectForKey:@"Price"] doubleValue]] forKey:@"Price"];
        [item setObject:[foodItem objectForKey:@"FoodOptionChoiceId"] forKey:@"FoodOptionChoiceId"];
        [item setObject:[foodItem objectForKey:@"FoodItemAdditionId"] forKey:@"FoodItemAdditionId"];
        [item setObject:[NSNumber numberWithInt:1] forKey:@"Quantity"];
        [item setObject:[foodItem objectForKey:@"Name"] forKey:@"Name"];
        [foodItemsList addObject:item];
    }
    
    [orderTable reloadData];
    [self setOrderCost];
    [self requestForUpdateParkedOrderInBackground];
}

-(void)updateFoodItems:(NSArray*)foodItems andParkedOrderDetails:(NSDictionary*)details {
    
    if (details) {
        self.orderDetails = details;
        [self setParkedOrderDetails];
    }
    if (foodItems) {
        [foodItemsList removeAllObjects];
        [foodItemsList addObjectsFromArray:foodItems];

        [orderTable reloadData];
    }
    
    [SVProgressHUD showSuccessWithStatus:@"Order updated successfully."];
}

#pragma mark
#pragma mark IBAction Methods

-(IBAction)backAction:(id)sender {

    RestaurantModel *restaurantModel = [orderDetails objectForKey:@"restaurantModel"];
    if (restaurantModel.isPayNow && [[orderDetails objectForKey:@"Status"] intValue] == ParkedOrderStatusOpened) {
        isForegroundUpdate = NO;
        isBackButtonUpdate = YES;
        [self requestForUpdateParkedOrder];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(IBAction)cancelDeleteAction:(id)sender {
    
    [self.view setUserInteractionEnabled:NO];
    CGRect frame = delete_order_view.frame;
    frame.origin = CGPointMake(0, self.view.frame.size.height);
    [UIView animateWithDuration:0.3 animations:^{
        delete_order_view.alpha = 0.0;
    }completion:^(BOOL finished) {
        if (finished) {
            delete_order_view.frame = frame;
            [self.view setUserInteractionEnabled:YES];
        }
    }];
}

-(IBAction)deleteOrderAction:(id)sender {
    
    [self cancelDeleteAction:Nil];
    [self requestForDeleteParkedOrder];
}

-(IBAction)phoneButtonClick:(id)sender {
    
    RestaurantModel *restaurant = [orderDetails objectForKey:@"restaurantModel"];
    NSString *phoneNumber = [@"tel://" stringByAppendingString:restaurant.primaryPhone];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
}

-(IBAction)listButtonClick:(id)sender {
    
    if ([[orderDetails objectForKey:@"Status"] intValue] == ParkedOrderStatusOpened) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Share Parked Order", @"Get Directions", nil];
        actionSheet.tag = 1;
        [actionSheet showInView:self.view];
    }
    else {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Get Directions", nil];
        actionSheet.tag = 2;
        [actionSheet showInView:self.view];
    }
}

-(IBAction)menuButtonClick:(id)sender {
    
    [self.menuContainerViewController setMenuState:MFSideMenuStateLeftMenuOpen];
}

-(IBAction)plusButtonClick:(id)sender {
    
    RestaurantModel *restaurantModel = [orderDetails objectForKey:@"restaurantModel"];
    FoodCategoriesViewController *foodCategoriesVC = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"FoodCategoriesViewController"];
    [foodCategoriesVC setFoodCategories:restaurantModel.foodCategoryList];
    foodCategoriesVC.isParkedOrder = YES;
    foodCategoriesVC.quantity = (int)[foodItemsList count];
    foodCategoriesVC.price = [[total_cost_lbl.text stringByReplacingOccurrencesOfString:@"$" withString:@""] floatValue];
    [self.navigationController pushViewController:foodCategoriesVC animated:YES];
}

-(IBAction)pencilButtonClick:(id)sender {
    
    POEditViewController *poEditVC = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"POEditViewController"];
    [poEditVC setFoodItemsList:foodItemsList];
    [poEditVC setOrderDetails:orderDetails];
    poEditVC.gratuity_rate = gratuity_rate;
    poEditVC.parentController = self;
    
    [self.navigationController pushViewController:poEditVC animated:YES];
}

-(IBAction)tickButtonClick:(id)sender {
    
    [self requestForUpdateParkedOrder];
}

-(IBAction)trashButtonClick:(id)sender {
    
    [self.view setUserInteractionEnabled:NO];
    delete_order_view.alpha = 0.0;
    delete_order_view.center = self.view.center;
    [UIView animateWithDuration:0.3 animations:^{
        delete_order_view.alpha = 1.0;
    }completion:^(BOOL finished) {
        if (finished) {
            [self.view setUserInteractionEnabled:YES];
        }
    }];
}

-(IBAction)favoriteButtonClick:(id)sender {
 
    BOOL isFavorite = !isFavorite_btn1.selected;
    isFavorite_btn1.selected = isFavorite;
    isFavorite_btn2.selected = isFavorite;
//    isFavorite_btn3.selected = isFavorite;
    shouldGoBack = NO;
    [self requestForUpdateParkedOrder];
}

-(IBAction)creditCardButtonClick:(id)sender {
    
    if (isParkedOrderUpdated) {
        UserModel *user = [AppInfo sharedInfo].user;
        BOOL hasFoundPaymentMethod = NO;
        for (int i=0; i<[user.authenticationList count]; i++) {
            NSDictionary *dictionary = [user.authenticationList objectAtIndex:i];
            if ([[dictionary objectForKey:@"Provider"] isEqualToString:BRAINTREE_PAYMENT] || [[dictionary objectForKey:@"Provider"] isEqualToString:DWOLLA_PAYMENT] || [[dictionary objectForKey:@"Provider"] isEqualToString:PAYPAL_PAYMENT]) {
                hasFoundPaymentMethod = YES;
                break;
            }
        }
        if (hasFoundPaymentMethod) {
            PaymentMethodsAlertView *paymentAlert = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"PaymentMethodsAlertView"];
            paymentAlert.delegate = self;
            paymentAlert.parentController = self;
            [paymentAlert show];
        }
        else {
            [self.view setUserInteractionEnabled:NO];
            no_payment_view.alpha = 0.0;
            no_payment_view.center = self.view.center;
            [UIView animateWithDuration:0.3 animations:^{
                no_payment_view.alpha = 1.0;
            }completion:^(BOOL finished) {
                if (finished) {
                    [self.view setUserInteractionEnabled:YES];
                }
            }];
        }
    }
    else {
        [self requestForUpdateParkedOrderPaymentInfo];
    }
}

-(IBAction)dwollaButtonClick:(id)sender {
    
    UserModel *user = [AppInfo sharedInfo].user;
    RestaurantModel *restaurantModel = [orderDetails objectForKey:@"restaurantModel"];
    BOOL hasFoundDwolla = NO;
    for (int i=0; i<[user.authenticationList count]; i++) {
        NSDictionary *dictionary = [user.authenticationList objectAtIndex:i];
        if ([[dictionary objectForKey:@"Provider"] isEqualToString:DWOLLA_PAYMENT]) {
            hasFoundDwolla = YES;
            break;
        }
    }
    if (hasFoundDwolla) {
        float subtotal = [[price_lbl.text stringByReplacingOccurrencesOfString:@"$" withString:@""] floatValue];
        float tax = [[tax_rate_lbl.text stringByReplacingOccurrencesOfString:@"$" withString:@""] floatValue];
        float gratuity = [[gratuity_rate_lbl.text stringByReplacingOccurrencesOfString:@"$" withString:@""] floatValue];
        float total = subtotal+tax+gratuity;
        float change = ceilf(total)-total;
        if (!transactionVC) {
            transactionVC = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"POTransactionVC"];
        }
        transactionVC.parkedOrderId = [orderDetails objectForKey:@"Id"];
        transactionVC.parkedOrderTitle = [orderDetails objectForKey:@"CustomId"];
        transactionVC.subTotal = subtotal;
        transactionVC.tax = tax;
        transactionVC.gratuity = gratuity;
        transactionVC.change = change;
        transactionVC.convenience_fee = 0.38;
        transactionVC.isConvenienceFee = restaurantModel.isConvenienceFee;
        transactionVC.delegate = self;
        [transactionVC showPaymentAlert];
    }
    else {
        [self.view setUserInteractionEnabled:NO];
        no_payment_view.alpha = 0.0;
        no_payment_view.center = self.view.center;
        [UIView animateWithDuration:0.3 animations:^{
            no_payment_view.alpha = 1.0;
        }completion:^(BOOL finished) {
            if (finished) {
                [self.view setUserInteractionEnabled:YES];
            }
        }];
    }
}

-(IBAction)noPaymentOKAction:(id)sender {
    
    [self.view setUserInteractionEnabled:NO];
    CGRect frame = no_payment_view.frame;
    frame.origin = CGPointMake(0, self.view.frame.size.height);
    [UIView animateWithDuration:0.3 animations:^{
        no_payment_view.alpha = 0.0;
    }completion:^(BOOL finished) {
        if (finished) {
            no_payment_view.frame = frame;
            [self.view setUserInteractionEnabled:YES];
        }
    }];
}

-(IBAction)paymentOKAction:(id)sender {
    
    [self.view setUserInteractionEnabled:NO];
    CGRect frame = available_payment_view.frame;
    frame.origin = CGPointMake(0, self.view.frame.size.height);
    [UIView animateWithDuration:0.3 animations:^{
        available_payment_view.alpha = 0.0;
    }completion:^(BOOL finished) {
        if (finished) {
            available_payment_view.frame = frame;
            [self.view setUserInteractionEnabled:YES];
        }
    }];
}

-(IBAction)paymentCancelAction:(id)sender {

    [self.view setUserInteractionEnabled:NO];
    CGRect frame = available_payment_view.frame;
    frame.origin = CGPointMake(0, self.view.frame.size.height);
    [UIView animateWithDuration:0.3 animations:^{
        available_payment_view.alpha = 0.0;
    }completion:^(BOOL finished) {
        if (finished) {
            available_payment_view.frame = frame;
            [self.view setUserInteractionEnabled:YES];
        }
    }];
}

-(IBAction)shareButtonClick:(id)sender {
    
    RestaurantModel *restaurantModel = [orderDetails objectForKey:@"restaurantModel"];
    if (!shareOrderVC) {
        shareOrderVC = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ShareOrderVC"];
    }
    shareOrderVC.parkedOrderId = [orderDetails objectForKey:@"Id"];
    shareOrderVC.parkedOrderTitle = [orderDetails objectForKey:@"CustomId"];
    shareOrderVC.restaurantTitle = restaurantModel.restaurantName;
    [shareOrderVC setParentController:self];
    [shareOrderVC showShareOrderAlert];
}

-(IBAction)mapButtonClick:(id)sender {
    
    @synchronized(self) {
        RestaurantModel *restaurantModel = [orderDetails objectForKey:@"restaurantModel"];
        NSMutableString *address_string = [NSMutableString string];
        [address_string appendFormat:@"%@ %@ %@ %@ %@", restaurantModel.restaurantName, restaurantModel.addressLine1, restaurantModel.city, restaurantModel.stateCode, restaurantModel.zipCode];
        // Check for iOS 6
        Class mapItemClass = [MKMapItem class];
        if (mapItemClass && [mapItemClass respondsToSelector:@selector(openMapsWithItems:launchOptions:)])
        {
            CLGeocoder *geocoder = [[CLGeocoder alloc] init];
            [geocoder geocodeAddressString:address_string
                         completionHandler:^(NSArray *placemarks, NSError *error) {
                             
                             // Convert the CLPlacemark to an MKPlacemark
                             // Note: There's no error checking for a failed geocode
                             CLPlacemark *geocodedPlacemark = [placemarks objectAtIndex:0];
                             MKPlacemark *placemark = [[MKPlacemark alloc]
                                                       initWithCoordinate:geocodedPlacemark.location.coordinate
                                                       addressDictionary:geocodedPlacemark.addressDictionary];
                             
                             // Create a map item for the geocoded address to pass to Maps app
                             MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
                             [mapItem setName:geocodedPlacemark.name];
                             
                             // Set the directions mode to "Driving"
                             // Can use MKLaunchOptionsDirectionsModeWalking instead
                             NSDictionary *launchOptions = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving};
                             
                             //                             [mapItem openInMapsWithLaunchOptions:Nil];
                             // Get the "Current User Location" MKMapItem
                             MKMapItem *currentLocationMapItem = [MKMapItem mapItemForCurrentLocation];
                             
                             // Pass the current location and destination map items to the Maps app
                             // Set the direction mode in the launchOptions dictionary
                             [MKMapItem openMapsWithItems:@[currentLocationMapItem, mapItem] launchOptions:launchOptions];
                             
                             
                         }];
        }
        else
        {
            NSString *mapsURL = [NSString stringWithFormat:@"https://maps.google.com/maps?q=%@", [address_string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mapsURL]];
        }
    }
}

-(IBAction)reviewButtonClick:(id)sender {
    
    RestaurantModel *restaurantModel = [orderDetails objectForKey:@"restaurantModel"];
    if (!reviewOrderVC) {
        reviewOrderVC = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ReviewOrderVC"];
    }
    reviewOrderVC.parkedOrderId = [orderDetails objectForKey:@"Id"];
    reviewOrderVC.parkedOrderTitle = [orderDetails objectForKey:@"CustomId"];
    reviewOrderVC.restaurantId = restaurantModel.restaurantID;
    [reviewOrderVC setParentController:self];
    [reviewOrderVC showReviewOrderAlert];
}

-(IBAction)doneToolbarAction:(id)sender {
    
    [notesTV resignFirstResponder];
}

-(IBAction)notesButtonClick:(id)sender {
    
    [self.view setUserInteractionEnabled:NO];
    CGRect frame = notes_view.frame;
    frame.origin = CGPointZero;
    if ([UIScreen mainScreen].bounds.size.height <= 480) {
        frame.origin.y = -45.0;
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0) {
            frame.origin.y += 20.0;
        }
    }
    notes_view.frame = frame;
    notes_view.alpha = 0.0;
    if ([orderDetails objectForKey:@"Notes"] && (NSNull*)[orderDetails objectForKey:@"Notes"] != [NSNull null]) {
        notesTV.text = [orderDetails objectForKey:@"Notes"];
    }
    if ([[orderDetails objectForKey:@"Status"] intValue] == ParkedOrderStatusOpened) {
        [notesTV setEditable:YES];
        [notesTV setUserInteractionEnabled:YES];
        send_btn_view.hidden = NO;
        ok_btn_view.hidden = YES;
    }
    else {
        [notesTV setEditable:NO];
        [notesTV setUserInteractionEnabled:NO];
        send_btn_view.hidden = YES;
        ok_btn_view.hidden = NO;
    }
    [self.view addSubview:notes_view];
    
    [UIView animateWithDuration:0.3 animations:^{
        notes_view.alpha = 1.0;
    }completion:^(BOOL finished){
        if (finished) {
            [self.view setUserInteractionEnabled:YES];
        }
    }];
}

-(IBAction)cancelNotesAction:(id)sender {
    
    [self.view setUserInteractionEnabled:NO];
    [notesTV resignFirstResponder];
    [UIView animateWithDuration:0.3 animations:^{
        notes_view.alpha = 0.0;
    }completion:^(BOOL finished){
        if (finished) {
            if ([orderDetails objectForKey:@"Notes"] && (NSNull*)[orderDetails objectForKey:@"Notes"] != [NSNull null]) {
                notesTV.text = [orderDetails objectForKey:@"Notes"];
            }
            else {
                notesTV.text = @"";
            }
            [notes_view removeFromSuperview];
            [self.view setUserInteractionEnabled:YES];
        }
    }];
}

-(IBAction)sendNotesAction:(id)sender {
    
    [self.view setUserInteractionEnabled:NO];
    [notesTV resignFirstResponder];
    [UIView animateWithDuration:0.3 animations:^{
        notes_view.alpha = 0.0;
    }completion:^(BOOL finished){
        if (finished) {
            [notes_view removeFromSuperview];
            [self.view setUserInteractionEnabled:YES];
            isForegroundUpdate = YES;
            [self requestForUpdateParkedOrder];
        }
    }];
}

-(IBAction)okNotesAction:(id)sender {
    
    [self cancelNotesAction:Nil];
}

-(IBAction)okCreditCardAction:(id)sender {
    
    [SVProgressHUD showWithStatus:@"Processing your payment..." maskType:SVProgressHUDMaskTypeBlack];
    UserModel *user = [AppInfo sharedInfo].user;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:user.tokenID forKey:@"tokenId"];
    [params setObject:[orderDetails objectForKey:@"Id"] forKey:@"parkedOrderId"];
    [HTTPRequest requestGetWithMethod:@"BrainTreeService/BTPay" Params:params andDelegate:self andRequestType:HTTPRequestTypeBrainTreePayment];
}

-(IBAction)cancelCreditCardAction:(id)sender {
    
    [self.view setUserInteractionEnabled:NO];
    CGRect frame = credit_card_alert.frame;
    frame.origin = CGPointMake(0, self.view.frame.size.height);
    [UIView animateWithDuration:0.3 animations:^{
        credit_card_alert.alpha = 0.0;
    }completion:^(BOOL finished) {
        if (finished) {
            credit_card_alert.frame = frame;
            [self.view setUserInteractionEnabled:YES];
        }
    }];
}

-(IBAction)payNowOrderAction:(id)sender {
    
    [self editPayNowOrderAction:nil];
    [self creditCardButtonClick:nil];
}

-(IBAction)cancelPayNowOrderAction:(id)sender {
    
    [self editPayNowOrderAction:nil];
    [self requestForDeleteParkedOrder];
}

-(IBAction)editPayNowOrderAction:(id)sender {
    
    [self.view setUserInteractionEnabled:NO];
    CGRect frame = payNow_alert_view.frame;
    frame.origin.y = self.view.frame.size.height;
    [UIView animateWithDuration:0.3 animations:^{
        payNow_alert_view.alpha = 0.0;
    }completion:^(BOOL finished) {
        if (finished) {
            payNow_alert_view.frame = frame;
            [self.view setUserInteractionEnabled:YES];
        }
    }];
}

-(IBAction)longPressGesture:(UILongPressGestureRecognizer*)sender {
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        UIButton *button = (UIButton*)[sender view];
        ButtonType type = (ButtonType)button.tag;
        NSString *title = [AppInfo getButtonTitleOfType:type];
        CGSize size = [title sizeWithFont:button_title_lbl.font constrainedToSize:CGSizeMake(160.0, 25)];
        CGRect frame = CGRectMake(button.frame.origin.x, closed_order_bar.frame.origin.y-30.0, size.width+20.0, 25.0);
        if ((frame.origin.x+frame.size.width) > (self.view.frame.size.width-5.0)) {
            frame.origin.x = self.view.frame.size.width-(frame.size.width+5.0);
        }
        button_title_lbl.hidden = YES;
        button_title_lbl.frame = frame;
        button_title_lbl.alpha = 1.0;
        button_title_lbl.text = title;
        button_title_lbl.hidden = NO;
        [UIView animateWithDuration:0.5 delay:1.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            button_title_lbl.alpha = 0.0;
        }completion:^(BOOL finished){
            if (finished) {
                button_title_lbl.hidden = YES;
                button_title_lbl.alpha = 1.0;
            }
        }];
    }
}

#pragma mark
#pragma mark UITextViewDelegate Methods

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    
    textView.inputAccessoryView = toolbar;
    return YES;
}

#pragma mark
#pragma mark UITableViewDataSource/UITableViewDelegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    return 55.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if ([foodItemsList count] == 0) {
        return 1;
    }
    return [foodItemsList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"PODetailsCellIdentifier";
    
    PODetailsCell *cell = (PODetailsCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"PODetailsCell" owner:self options:nil] objectAtIndex:0];
    }
    
    if ([foodItemsList count] == 0) {
        cell.quantity_lbl.text = @"";
        cell.price_lbl.text = @"";
        cell.title_lbl.text = @"Please add food to your order.";
    }
    else {
        NSDictionary *foodItem = [foodItemsList objectAtIndex:indexPath.row];
        cell.quantity_lbl.text = [NSString stringWithFormat:@"%i", [[foodItem objectForKey:@"Quantity"] intValue]];
        cell.price_lbl.text = [NSString stringWithFormat:@"$%.2f", [[foodItem objectForKey:@"Price"] doubleValue]];
        cell.title_lbl.text = [foodItem objectForKey:@"Name"];
        NSMutableString *foodOptionNames = [NSMutableString string];
        BOOL hasFoundNames = NO;
        if ([foodItem objectForKey:@"FoodOptionChoiceId"] && (NSNull*)[foodItem objectForKey:@"FoodOptionChoiceId"] != [NSNull null]) {
            NSArray *foodChoiceIDs = [[foodItem objectForKey:@"FoodOptionChoiceId"] componentsSeparatedByString:@","];
            if (foodChoiceIDs && [foodChoiceIDs isKindOfClass:[NSArray class]] && [foodChoiceIDs count] > 0) {
                RestaurantModel *restaurant = [orderDetails objectForKey:@"restaurantModel"];
                for (int i=0; i<[restaurant.foodCategoryList count] && !hasFoundNames; i++) {
                    NSDictionary *category = [restaurant.foodCategoryList objectAtIndex:i];
                    NSArray *foodItems = [[category objectForKey:@"FoodItemList"] objectForKey:@"List"];
                    for (int j=0; j<[foodItems count] && !hasFoundNames; j++) {
                        NSDictionary *food = [foodItems objectAtIndex:j];
                        if ([[foodItem objectForKey:@"Id"] isEqualToString:[food objectForKey:@"Id"]]) {
                            if ([food objectForKey:@"FoodOptionList"] && (NSNull*)[food objectForKey:@"FoodOptionList"] != [NSNull null]) {
                                NSArray *foodOptionList = [[food objectForKey:@"FoodOptionList"] objectForKey:@"List"];
                                for (int k=0; k<[foodOptionList count]; k++) {
                                    NSArray *foodChoiceList = [[[foodOptionList objectAtIndex:k] objectForKey:@"FoodChoiceList"] objectForKey:@"List"];
                                    for (int n=0; n<[foodChoiceList count]; n++) {
                                        for (int m=0; m<[foodChoiceIDs count]; m++) {
                                            if ([[[foodChoiceList objectAtIndex:n] objectForKey:@"Id"] isEqualToString:[foodChoiceIDs objectAtIndex:m]]) {
                                                if (foodOptionNames.length == 0) {
                                                    [foodOptionNames appendString:@"("];
                                                }
                                                else {
                                                    [foodOptionNames appendString:@", "];
                                                }
                                                [foodOptionNames appendString:[[foodChoiceList objectAtIndex:n] objectForKey:@"Name"]];
                                                hasFoundNames = YES;
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        hasFoundNames = NO;
        if ([foodItem objectForKey:@"FoodItemAdditionId"] && (NSNull*)[foodItem objectForKey:@"FoodItemAdditionId"] != [NSNull null]) {
            NSArray *foodAdditionIDs = [[foodItem objectForKey:@"FoodItemAdditionId"] componentsSeparatedByString:@","];
            if (foodAdditionIDs && [foodAdditionIDs isKindOfClass:[NSArray class]] && [foodAdditionIDs count] > 0) {
                RestaurantModel *restaurant = [orderDetails objectForKey:@"restaurantModel"];
                for (int i=0; i<[restaurant.foodCategoryList count] && !hasFoundNames; i++) {
                    NSDictionary *category = [restaurant.foodCategoryList objectAtIndex:i];
                    NSArray *foodItems = [[category objectForKey:@"FoodItemList"] objectForKey:@"List"];
                    for (int j=0; j<[foodItems count] && !hasFoundNames; j++) {
                        NSDictionary *food = [foodItems objectAtIndex:j];
                        if ([[foodItem objectForKey:@"Id"] isEqualToString:[food objectForKey:@"Id"]]) {
                            if ([food objectForKey:@"FoodAdditionList"] && (NSNull*)[food objectForKey:@"FoodAdditionList"] != [NSNull null]) {
                                NSArray *foodAdditionList = [[food objectForKey:@"FoodAdditionList"] objectForKey:@"List"];
                                for (int k=0; k<[foodAdditionList count]; k++) {
                                    NSDictionary *foodAdditionItem = [foodAdditionList objectAtIndex:k];
                                    for (int n=0; n<[foodAdditionIDs count]; n++) {
                                        if ([[foodAdditionIDs objectAtIndex:n] isEqualToString:[foodAdditionItem objectForKey:@"Id"]]) {
                                            if (foodOptionNames.length == 0) {
                                                [foodOptionNames appendString:@"("];
                                            }
                                            else {
                                                [foodOptionNames appendString:@", "];
                                            }
                                            [foodOptionNames appendString:[foodAdditionItem objectForKey:@"Name"]];
                                            hasFoundNames = YES;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        if (foodOptionNames.length > 0) {
            [foodOptionNames appendString:@")"];
        }
        cell.options_lbl.text = foodOptionNames;
    }
    
    return cell;
}

#pragma mark
#pragma mark HTTPRequestDelegate Methods

-(void)didFinishRequest:(HTTPRequest*)httpRequest withData:(id)data {
    
    if (data && [data isKindOfClass:[NSDictionary class]] && [data objectForKey:@"IsSuccessful"] && [[data objectForKey:@"IsSuccessful"] boolValue]) {
        if (httpRequest.requestType == HTTPRequestTypeParkedOrder || httpRequest.requestType == HTTPRequestTypeUpdateParkedOrder) {
            if (isGetRequest) {
                RestaurantModel *restaurant = [orderDetails objectForKey:@"restaurantModel"];
                NSMutableDictionary *parkedOrder = [NSMutableDictionary dictionaryWithDictionary:[[data objectForKey:@"List"] firstObject]];
                [[AppInfo sharedInfo].user updateParkedOrder:parkedOrder];
                [parkedOrder setObject:[AppInfo getDateFromDateIntervalString:[parkedOrder objectForKey:@"FulfillmentDate"]] forKey:@"parkedOrderDate"];
                [parkedOrder setObject:restaurant forKey:@"restaurantModel"];
                self.orderDetails = parkedOrder;
                if (shouldGoBack) {
//                [self.navigationController popViewControllerAnimated:YES];
                }
                else {
                    shouldGoBack = YES;
                }
                [self reloadParkedOrderData];
                isParkedOrderUpdated = YES;
                if (isBackgroundUpdate) {
                    isBackgroundUpdate = NO;
                    [SVProgressHUD dismiss];
                }
                else {
                    if (isPaymentUpdateRequest) {
                        isPaymentUpdateRequest = NO;
                        [SVProgressHUD dismiss];
                        [self creditCardButtonClick:nil];
                    }
                    else if (restaurant.isPayNow && [[orderDetails objectForKey:@"Status"] intValue] == ParkedOrderStatusOpened && !isForegroundUpdate && isBackButtonUpdate) {
                        [SVProgressHUD dismiss];
                        isBackButtonUpdate = NO;
                        [self showPayNowAlert];
                    }
                    else {
                        isForegroundUpdate = NO;
                        [SVProgressHUD showSuccessWithStatus:@"Order updated successfully."];
                    }
                }
            }
            else {
                if (isUpdateRequest) {
                    [self requestForGettingParkedOrder];
                    if (!isBackgroundUpdate) {
                        if (httpRequest.requestType == HTTPRequestTypeUpdateParkedOrder) {
                            [SVProgressHUD showWithStatus:@"Loading payment info..." maskType:SVProgressHUDMaskTypeGradient];
                        }
                    }
                }
                else {
                    [SVProgressHUD showSuccessWithStatus:@"Order deleted successfully."];
                    [[AppInfo sharedInfo].user deleteParkedOrderWithID:[orderDetails objectForKey:@"Id"]];
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }
        }
        else if (httpRequest.requestType == HTTPRequestTypeBrainTreePayment) {
            UserModel *user = [AppInfo sharedInfo].user;
            NSMutableDictionary *updatedDetails = [NSMutableDictionary dictionaryWithDictionary:orderDetails];
            [updatedDetails setObject:[NSNumber numberWithInt:ParkedOrderStatusClosed] forKey:@"Status"];
            self.orderDetails = updatedDetails;
            [user closeParkedOrderWithID:[orderDetails objectForKey:@"Id"]];
            [self reloadParkedOrderData];
            [self cancelCreditCardAction:Nil];
            [SVProgressHUD showSuccessWithStatus:@"Payment processed successfully."];
        }
    }
    else {
        isForegroundUpdate = NO;
        isBackButtonUpdate = NO;
        [SVProgressHUD dismiss];
    }
}

-(void)didFailRequest:(HTTPRequest*)httpRequest withError:(NSString*)errorMessage {
    
    [SVProgressHUD dismiss];
    shouldGoBack = YES;
    isForegroundUpdate = NO;
    isBackButtonUpdate = NO;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark
#pragma mark UIActionSheetDelegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (actionSheet.tag == 1) {
        if (buttonIndex == 0) {
            [self shareButtonClick:Nil];
        }
        else if (buttonIndex == 1) {
            [self mapButtonClick:Nil];
        }
    }
    else if (actionSheet.tag == 2) {
        if (buttonIndex == 0) {
            [self mapButtonClick:Nil];
        }
    }
}

#pragma mark
#pragma mark PaymentDelegate Methods

-(void)paymentSuccessful {
    
    [self performSelector:@selector(showSuccessMessage:) withObject:@"Your payment has been processed successfully." afterDelay:0.3];
    NSMutableDictionary *closedOrder = [NSMutableDictionary dictionaryWithDictionary:orderDetails];
    [closedOrder setObject:[NSNumber numberWithInt:ParkedOrderStatusClosed] forKey:@"Status"];
    orderDetails = Nil;
    orderDetails = closedOrder;
    opened_order_bar.hidden = YES;
    closed_order_bar.hidden = NO;
    fulfilled_order_bar.hidden = YES;
    [[AppInfo sharedInfo].user closeParkedOrderWithID:[orderDetails objectForKey:@"Id"]];
    [self reloadParkedOrderData];
    isForegroundUpdate = YES;
    [self performSelector:@selector(requestForGettingParkedOrder) withObject:nil afterDelay:1.0];
}

-(void)paymentFailed {
    
    [self performSelector:@selector(showErrorMessage:) withObject:@"Error! couldn't process your payment." afterDelay:0.3];
}

#pragma mark
#pragma mark CustomeAlertViewDelegate Methods

- (void) customAlertView:(id)alertView dismissedWithValue:(id)value {
    
    if ([value isEqualToString:DWOLLA_PAYMENT]) {
        [self dwollaButtonClick:nil];
    }
    else if ([value isEqualToString:PAYPAL_PAYMENT]) {
        
    }
    else if ([value isEqualToString:VISA_PAYMENT] || [value isEqualToString:MASTER_CARD_PAYMENT] || [value isEqualToString:AMERICAN_EXPRESS_PAYMENT] || [value isEqualToString:DISCOVER_PAYMENT] || [value isEqualToString:BRAINTREE_PAYMENT]) {
        [self showBrainTreePaymentAlert];
    }
}

@end
