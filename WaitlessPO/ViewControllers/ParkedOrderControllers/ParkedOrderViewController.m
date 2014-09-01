//
//  ParkedOrderViewController.m
//  WaitlessPO
//
//  Created by Amad Khilji on 08/12/2013.
//  Copyright (c) 2013 Amad Khilji. All rights reserved.
//

#import "ParkedOrderViewController.h"
#import "MFSideMenu.h"
#import "UserModel.h"
#import "RestaurantModel.h"
#import "ParkedOrderCell.h"
#import "SVProgressHUD.h"
#import "PODetailsViewController.h"
#import "JSONKit.h"

@interface ParkedOrderViewController ()

-(void)showPaymentAlert;
-(void)requestForLoadingParkedOrders;
-(void)updateAvailableParkedOrders;
-(void)requestForGettingParkedOrderWithID:(NSString*)parkedOrderId;
-(float)getTotalCostFromParkedOrder:(NSDictionary*)parkedOrder;

@end

@implementation ParkedOrderViewController

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
//    [SVProgressHUD showWithStatus:@"Loading parked orders..." maskType:SVProgressHUDMaskTypeGradient];
    CGPoint center = self.view.center;
    if ([[UIDevice currentDevice].systemVersion floatValue] < 7.0) {
        center.y -= 10;
    }
    create_parked_order_view.center = center;
    [self requestForLoadingParkedOrders];
    
    if ([[AppInfo sharedInfo] shouldShowPaymentSignUp]) {
        [self performSelector:@selector(showPaymentAlert) withObject:Nil afterDelay:3.0];
    }
}

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    self.menuContainerViewController.panMode = MFSideMenuPanModeDefault;
    
    [self updateAvailableParkedOrders];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark
#pragma mark Private Methods

-(void)showPaymentAlert {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SHOW_PAYMENT_ALERT_NOTIFICATION object:Nil];
}

-(void)updateAvailableParkedOrders {
    
    if (!availableParkedOrders) {
        availableParkedOrders = [NSMutableArray array];
    }
    if ([availableParkedOrders count] > 0) {
        [availableParkedOrders removeAllObjects];
    }
    NSArray *parkedOrderList = [AppInfo sharedInfo].user.parkedOrderList;
    NSMutableArray *openedParkedOrders = [NSMutableArray array];
    NSMutableArray *fulfilledParkedOrders = [NSMutableArray array];
    NSMutableArray *closedParkedOrders = [NSMutableArray array];
    NSMutableArray *refundedParkedOrders = [NSMutableArray array];
    NSMutableArray *voidedParkedOrders = [NSMutableArray array];
    for (int i=0; i<[parkedOrderList count]; i++) {
        NSDictionary *parkedOrder = [parkedOrderList objectAtIndex:i];
        if ([[parkedOrder objectForKey:@"Status"] intValue] == ParkedOrderStatusOpened) {
            [openedParkedOrders addObject:parkedOrder];
        }
        else if ([[parkedOrder objectForKey:@"Status"] intValue] == ParkedOrderStatusFulfilled) {
            [fulfilledParkedOrders addObject:parkedOrder];
        }
        else if ([[parkedOrder objectForKey:@"Status"] intValue] == ParkedOrderStatusClosed) {
            [closedParkedOrders addObject:parkedOrder];
        }
        else if ([[parkedOrder objectForKey:@"Status"] intValue] == ParkedOrderStatusRefunded) {
            [refundedParkedOrders addObject:parkedOrder];
        }
        else if ([[parkedOrder objectForKey:@"Status"] intValue] == ParkedOrderStatusVoided) {
            [voidedParkedOrders addObject:parkedOrder];
        }
    }
    [openedParkedOrders sortUsingComparator:^NSComparisonResult(id obj1, id obj2){
        NSDictionary *parkedOrder1 = (NSDictionary*)obj1;
        NSDictionary *parkedOrder2 = (NSDictionary*)obj2;
        NSDate *date1 = [AppInfo getDateFromDateIntervalString:[parkedOrder1 objectForKey:@"FulfillmentDate"]];
        NSDate *date2 = [AppInfo getDateFromDateIntervalString:[parkedOrder2 objectForKey:@"FulfillmentDate"]];
        if ([date1 timeIntervalSince1970] > [date2 timeIntervalSince1970]) {
            return NSOrderedDescending;
        }
        else if ([date1 timeIntervalSince1970] < [date2 timeIntervalSince1970]) {
            return NSOrderedAscending;
        }
        else {
            return NSOrderedSame;
        }
    }];
    [fulfilledParkedOrders sortUsingComparator:^NSComparisonResult(id obj1, id obj2){
        NSDictionary *parkedOrder1 = (NSDictionary*)obj1;
        NSDictionary *parkedOrder2 = (NSDictionary*)obj2;
        NSDate *date1 = [AppInfo getDateFromDateIntervalString:[parkedOrder1 objectForKey:@"FulfillmentDate"]];
        NSDate *date2 = [AppInfo getDateFromDateIntervalString:[parkedOrder2 objectForKey:@"FulfillmentDate"]];
        if ([date1 timeIntervalSince1970] > [date2 timeIntervalSince1970]) {
            return NSOrderedDescending;
        }
        else if ([date1 timeIntervalSince1970] < [date2 timeIntervalSince1970]) {
            return NSOrderedAscending;
        }
        else {
            return NSOrderedSame;
        }
    }];
    [closedParkedOrders sortUsingComparator:^NSComparisonResult(id obj1, id obj2){
        NSDictionary *parkedOrder1 = (NSDictionary*)obj1;
        NSDictionary *parkedOrder2 = (NSDictionary*)obj2;
        NSDate *date1 = [AppInfo getDateFromDateIntervalString:[parkedOrder1 objectForKey:@"FulfillmentDate"]];
        NSDate *date2 = [AppInfo getDateFromDateIntervalString:[parkedOrder2 objectForKey:@"FulfillmentDate"]];
        if ([date1 timeIntervalSince1970] > [date2 timeIntervalSince1970]) {
            return NSOrderedDescending;
        }
        else if ([date1 timeIntervalSince1970] < [date2 timeIntervalSince1970]) {
            return NSOrderedAscending;
        }
        else {
            return NSOrderedSame;
        }
    }];
    [refundedParkedOrders sortUsingComparator:^NSComparisonResult(id obj1, id obj2){
        NSDictionary *parkedOrder1 = (NSDictionary*)obj1;
        NSDictionary *parkedOrder2 = (NSDictionary*)obj2;
        NSDate *date1 = [AppInfo getDateFromDateIntervalString:[parkedOrder1 objectForKey:@"FulfillmentDate"]];
        NSDate *date2 = [AppInfo getDateFromDateIntervalString:[parkedOrder2 objectForKey:@"FulfillmentDate"]];
        if ([date1 timeIntervalSince1970] > [date2 timeIntervalSince1970]) {
            return NSOrderedDescending;
        }
        else if ([date1 timeIntervalSince1970] < [date2 timeIntervalSince1970]) {
            return NSOrderedAscending;
        }
        else {
            return NSOrderedSame;
        }
    }];
    [voidedParkedOrders sortUsingComparator:^NSComparisonResult(id obj1, id obj2){
        NSDictionary *parkedOrder1 = (NSDictionary*)obj1;
        NSDictionary *parkedOrder2 = (NSDictionary*)obj2;
        NSDate *date1 = [AppInfo getDateFromDateIntervalString:[parkedOrder1 objectForKey:@"FulfillmentDate"]];
        NSDate *date2 = [AppInfo getDateFromDateIntervalString:[parkedOrder2 objectForKey:@"FulfillmentDate"]];
        if ([date1 timeIntervalSince1970] > [date2 timeIntervalSince1970]) {
            return NSOrderedDescending;
        }
        else if ([date1 timeIntervalSince1970] < [date2 timeIntervalSince1970]) {
            return NSOrderedAscending;
        }
        else {
            return NSOrderedSame;
        }
    }];
    [availableParkedOrders addObjectsFromArray:openedParkedOrders];
    [availableParkedOrders addObjectsFromArray:fulfilledParkedOrders];
    [availableParkedOrders addObjectsFromArray:closedParkedOrders];
    [availableParkedOrders addObjectsFromArray:refundedParkedOrders];
    [availableParkedOrders addObjectsFromArray:voidedParkedOrders];
    
    [orderTableView reloadData];
}

-(void)requestForLoadingParkedOrders {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *userInfo = [defaults objectForKey:PUSH_NOTIFICATION];
    NSString *response = [[userInfo objectForKey:@"message"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *notification = [response objectFromJSONString];
    UserModel *user = [AppInfo sharedInfo].user;
    if ([[AppInfo sharedInfo].user.parkedOrderList count] == 0) {
        [SVProgressHUD showWithStatus:@"Loading parked orders..." maskType:SVProgressHUDMaskTypeGradient];
    }
    else if ([UIApplication sharedApplication].applicationIconBadgeNumber > 0 && notification && [notification isKindOfClass:[NSDictionary class]] && [notification objectForKey:@"UserId"]) {
        [SVProgressHUD showWithStatus:@"Updating parked order..." maskType:SVProgressHUDMaskTypeGradient];
    }
    isUpdateRequest = NO;
    [HTTPRequest requestGetWithMethod:@"RestaurantService/ParkedOrder/Get" Params:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:user.userID, user.tokenID, nil] forKeys:[NSArray arrayWithObjects:@"userid", @"tokenid", nil]] andDelegate:self];
}

-(void)requestForGettingParkedOrderWithID:(NSString*)parkedOrderId {
    
    [SVProgressHUD showWithStatus:@"Updating parked order..." maskType:SVProgressHUDMaskTypeGradient];
    isUpdateRequest = YES;
    NSDictionary *params = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[AppInfo sharedInfo].user.tokenID, parkedOrderId, nil] forKeys:[NSArray arrayWithObjects:@"tokenid", @"id", nil]];
    [HTTPRequest requestGetWithMethod:@"RestaurantService/ParkedOrder" Params:params andDelegate:self];
}

#pragma mark
#pragma mark Private Methods

-(NSString*)getRestaurantNameFromID:(NSString*)rest_id {
    
    NSString *name = @"";
    if (rest_id && rest_id.length > 0) {
        for (int i=0; i<[[AppInfo sharedInfo].user.restaurantList count]; i++) {
            RestaurantModel *restaurant = [[AppInfo sharedInfo].user.restaurantList objectAtIndex:i];
            if ([rest_id isEqualToString:restaurant.restaurantID]) {
                name = [NSString stringWithFormat:@"%@", restaurant.restaurantName];
                break;
            }
        }
        if (name.length == 0) {
            for (int i=0; i<[[AppInfo sharedInfo].restaurantsList count]; i++) {
                RestaurantModel *restaurant = [[AppInfo sharedInfo].restaurantsList objectAtIndex:i];
                if ([rest_id isEqualToString:restaurant.restaurantID]) {
                    name = [NSString stringWithFormat:@"%@", restaurant.restaurantName];
                    break;
                }
            }
        }
    }
    
    return name;
}

-(NSString*)getFormattedDateStringFromString:(NSString*)dateString {

    NSDate *date = [AppInfo getDateFromDateIntervalString:dateString];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEE, MMMM d_h:mm a"];

    NSString *tmpStr = [formatter stringFromDate:date];
    tmpStr = [tmpStr stringByReplacingOccurrencesOfString:@"_" withString:@" at "];
    if ([tmpStr hasSuffix:@" AM"]) {
        tmpStr = [tmpStr stringByReplacingOccurrencesOfString:@" AM" withString:@"am"];
    }
    else if ([tmpStr hasSuffix:@" PM"]) {
        tmpStr = [tmpStr stringByReplacingOccurrencesOfString:@" PM" withString:@"pm"];
    }
    
    return tmpStr;
}

-(void)updateParkedOrders {

    [self updateAvailableParkedOrders];
}

-(float)getTotalCostFromParkedOrder:(NSDictionary*)parkedOrder {
    
    float total_cost = 0.0;
    if (parkedOrder) {
        RestaurantModel *restaurantModel = [[AppInfo sharedInfo] getRestaurantModelFromID:[parkedOrder objectForKey:@"RestaurantId"]];
        if (restaurantModel) {
            UserModel *user = [AppInfo sharedInfo].user;
            NSArray *foodItemsList = [[parkedOrder objectForKey:@"FoodItemList"] objectForKey:@"List"];
            float total_price = 0.0;
            for (int i=0; i<[foodItemsList count]; i++) {
                NSDictionary *foodItem = [foodItemsList objectAtIndex:i];
                int quantity = [[foodItem objectForKey:@"Quantity"] intValue];
                CGFloat price = [[foodItem objectForKey:@"Price"] floatValue];
                total_price += price*quantity;
            }
            float tax_rate = (total_price*restaurantModel.taxRate)/100.0;
            float sub_total_price = total_price+tax_rate;
            float gratuity = [[parkedOrder objectForKey:@"Gratuity"] floatValue];
            if (sub_total_price > 0.0 && [[parkedOrder objectForKey:@"IsCustomGratuity"] intValue] == 0) {
                gratuity = (sub_total_price*user.gratuity_rate)/100.0;
            }
            total_cost = sub_total_price+gratuity;
        }
        else {
            total_cost = [[parkedOrder objectForKey:@"TotalCost"] floatValue];
        }
    }
    return total_cost;
}

#pragma mark
#pragma mark IBAction Methods

-(IBAction)menuAction:(id)sender {
    
    [self.menuContainerViewController setMenuState:MFSideMenuStateLeftMenuOpen];
}

-(IBAction)createParkedOrderAction:(id)sender {
    
    UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
    UIViewController *contentController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"RestaurantViewController"];
    NSArray *controllers = [NSArray arrayWithObject:contentController];
    navigationController.viewControllers = controllers;
    [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
}

#pragma mark
#pragma mark UITableViewDelegate/UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    int count = [availableParkedOrders count];
    if (count == 0) {
        create_parked_order_view.hidden = NO;
    }
    else {
        create_parked_order_view.hidden = YES;
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"ParkedOrderCellIdentifier";
    
    ParkedOrderCell *cell = (ParkedOrderCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"ParkedOrderCell" owner:self options:nil] objectAtIndex:0];
        UIView *bgColorView = [[UIView alloc] init];
        bgColorView.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:0 blue:0 alpha:0.2];
        [cell setSelectedBackgroundView:bgColorView];
    }
    
    NSDictionary *parkedOrder = [availableParkedOrders objectAtIndex:indexPath.row];
    cell.title_lbl.text = [self getRestaurantNameFromID:[parkedOrder objectForKey:@"RestaurantId"]];
    cell.name_lbl.text = [parkedOrder objectForKey:@"CustomId"];
    cell.price_lbl.text = [NSString stringWithFormat:@"$%.2f", [self getTotalCostFromParkedOrder:parkedOrder]];
    cell.time_lbl.text = [self getFormattedDateStringFromString:[parkedOrder objectForKey:@"FulfillmentDate"]];
    if ([[parkedOrder objectForKey:@"Status"] intValue] == ParkedOrderStatusOpened) {
        cell.status_lbl.text = @"Opened";
    }
    else if ([[parkedOrder objectForKey:@"Status"] intValue] == ParkedOrderStatusFulfilled) {
        cell.status_lbl.text = @"Fulfilled";
    }
    else if ([[parkedOrder objectForKey:@"Status"] intValue] == ParkedOrderStatusClosed) {
        cell.status_lbl.text = @"Closed";
    }
    else if ([[parkedOrder objectForKey:@"Status"] intValue] == ParkedOrderStatusRefunded) {
        cell.status_lbl.text = @"Refunded";
    }
    else if ([[parkedOrder objectForKey:@"Status"] intValue] == ParkedOrderStatusVoided) {
        cell.status_lbl.text = @"Voided";
    }
    else {
        cell.status_lbl.text = @"";
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *parkedOrder = [availableParkedOrders objectAtIndex:indexPath.row];
    RestaurantModel *restaurantModel = [[AppInfo sharedInfo] getRestaurantModelFromID:[parkedOrder objectForKey:@"RestaurantId"]];
    if (!restaurantModel) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Warning! Restaurant not available." message:@"Please go to Nearby screen and see available restaurants." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
        [alertView show];
    }
    else {
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        [dictionary addEntriesFromDictionary:parkedOrder];
        [dictionary setObject:[AppInfo getDateFromDateIntervalString:[parkedOrder objectForKey:@"FulfillmentDate"]] forKey:@"parkedOrderDate"];
        if (restaurantModel) {
            [dictionary setObject:restaurantModel forKey:@"restaurantModel"];
        }
        PODetailsViewController *po_DetailsVC = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"PODetailsViewController"];
        po_DetailsVC.orderDetails = dictionary;
//        po_DetailsVC.gratuity_rate = [AppInfo sharedInfo].user.gratuity_rate;
        [self.navigationController pushViewController:po_DetailsVC animated:YES];
    }
}

#pragma mark
#pragma mark HTTPRequestDelegate Methods

-(void)didFinishRequest:(HTTPRequest*)httpRequest withData:(id)data {

    if (data && [data isKindOfClass:[NSDictionary class]] && [[data objectForKey:@"IsSuccessful"] boolValue]) {
        if (isUpdateRequest) {
            NSDictionary *parkedOrder = [[data objectForKey:@"List"] firstObject];
            [[AppInfo sharedInfo].user updateParkedOrder:parkedOrder];
        }
        else {
            UserModel *user = [AppInfo sharedInfo].user;
            [user.parkedOrderList removeAllObjects];
            user.parkedOrderList = [NSMutableArray arrayWithArray:[data objectForKey:@"List"]];
        }
        [self updateAvailableParkedOrders];
        NSMutableDictionary *fulfilledParkedOrder = Nil;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([UIApplication sharedApplication].applicationIconBadgeNumber > 0 && [defaults objectForKey:PUSH_NOTIFICATION]) {
            NSDictionary *userInfo = [defaults objectForKey:PUSH_NOTIFICATION];
            NSString *response = [[userInfo objectForKey:@"message"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *notification = [response objectFromJSONString];
            if (notification && [notification isKindOfClass:[NSDictionary class]] && [notification objectForKey:@"UpdateType"]) {
                int updateType = [[notification objectForKey:@"UpdateType"] intValue];
                if ([notification objectForKey:@"UserId"] && [[notification objectForKey:@"UserId"] isEqualToString:[AppInfo sharedInfo].user.userID] && (updateType == ParkedOrderStatusFulfilled || updateType == ParkedOrderStatusClosed)) {
                    NSString *parkedOrderId = [notification objectForKey:@"ParkedOrderId"];
                    if (parkedOrderId && (NSNull*)parkedOrderId != [NSNull null]) {
                        for (int i=0; i<[[AppInfo sharedInfo].user.parkedOrderList count]; i++) {
                            NSDictionary *parkedOrder = [[AppInfo sharedInfo].user.parkedOrderList objectAtIndex:i];
                            RestaurantModel *restaurantModel = [[AppInfo sharedInfo] getRestaurantModelFromID:[parkedOrder objectForKey:@"RestaurantId"]];
                            if ([[parkedOrder objectForKey:@"Id"] isEqualToString:parkedOrderId] && restaurantModel) {
                                fulfilledParkedOrder = [NSMutableDictionary dictionaryWithDictionary:parkedOrder];
                                [fulfilledParkedOrder setObject:[AppInfo getDateFromDateIntervalString:[parkedOrder objectForKey:@"FulfillmentDate"]] forKey:@"parkedOrderDate"];
                                [fulfilledParkedOrder setObject:restaurantModel forKey:@"restaurantModel"];
                                PODetailsViewController *po_DetailsVC = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"PODetailsViewController"];
                                po_DetailsVC.orderDetails = fulfilledParkedOrder;
                                //        po_DetailsVC.gratuity_rate = [AppInfo sharedInfo].user.gratuity_rate;
                                [self.navigationController pushViewController:po_DetailsVC animated:NO];
                                break;
                            }
                        }
                        if (fulfilledParkedOrder) {
                            [defaults removeObjectForKey:PUSH_NOTIFICATION];
                            [defaults synchronize];
                            [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
                        }
                    }
                }
                else if (updateType == PromotionTypeAdd) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:PROMOTION_ADD_NOTIFICATION object:Nil];
                }
                else if (updateType == PromotionTypeUpdate) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:PROMOTION_UPDATE_NOTIFICATION object:Nil];
                }
                else if (updateType == PromotionTypeDelete) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:PROMOTION_DELETE_NOTIFICATION object:Nil];
                }
            }
        }
    }
    [SVProgressHUD dismiss];
}

-(void)didFailRequest:(HTTPRequest*)httpRequest withError:(NSString*)errorMessage {
    
    [SVProgressHUD dismiss];
}

@end
