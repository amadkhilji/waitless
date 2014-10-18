//
//  SideMenuViewController.m
//  MFSideMenuDemo
//
//  Created by Michael Frederick on 3/19/12.

#import "SideMenuViewController.h"
#import "MFSideMenu.h"
#import "UserModel.h"
#import "ProfileViewController.h"
#import "ParkedOrderViewController.h"
#import "RestaurantViewController.h"
#import "PaymentsViewController.h"
#import "SettingsViewController.h"
#import "PromotionsViewController.h"
#import "UIImageView+WebCache.h"
#import "JSONKit.h"
#import "SVProgressHUD.h"
#import "PODetailsViewController.h"
#import "DwollaViewController.h"
#import "RestaurantDetailsViewController.h"
#import "PageSwipeController.h"
#import "WebViewController.h"
//#import <GooglePlus/GooglePlus.h>
//#import <GoogleOpenSource/GoogleOpenSource.h>
#import <FacebookSDK/FacebookSDK.h>

@interface SideMenuViewController ()

-(void)postSocialStatusUpdate;
-(void)goToHelp;
-(void)showLogoutAlert;
-(void)updateParkedOrder;
-(void)closeParkedOrderWithID:(NSString *)parkedOrderID;
-(void)parkedOrderUpdatedNotification:(NSNotification*)notification;
-(void)promotionAddNotification:(NSNotification*)notification;
-(void)promotionDeleteNotification:(NSNotification*)notification;
-(void)promotionUpdateNotification:(NSNotification*)notification;
-(void)requestForGettingParkedOrderWithID:(NSString*)parkedOrderId;
-(void)showPaymentAlertNotification:(NSNotification*)notification;

@end

@implementation SideMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    shouldShowPaymentAlert = YES;
    itemLabels = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%@ %@", [AppInfo sharedInfo].user.firstName, [AppInfo sharedInfo].user.lastName], @"Parked Orders", @"What's Near Me?", @"Promotions", @"Payments", @"Settings", @"Help", @"Logout", nil];
    itemIcons = [NSArray arrayWithObjects:@"user_icon.png", @"list_icon.png", @"near_me_icon.png", @"gift_icon.png", @"payment_icon.png", @"settings_icon.png", @"help_icon.png", @"logout_icon.png", nil];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showPaymentAlertNotification:) name:SHOW_PAYMENT_ALERT_NOTIFICATION object:Nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(parkedOrderUpdatedNotification:) name:PARKED_ORDER_UPDATE_NOTIFICATION object:Nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(promotionAddNotification:) name:PROMOTION_ADD_NOTIFICATION object:Nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(promotionDeleteNotification:) name:PROMOTION_DELETE_NOTIFICATION object:Nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(promotionUpdateNotification:) name:PROMOTION_UPDATE_NOTIFICATION object:Nil];
    
    if (![[AppInfo sharedInfo] hasPostedToSocial]) {
        [self postSocialStatusUpdate];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SHOW_PAYMENT_ALERT_NOTIFICATION object:Nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PARKED_ORDER_UPDATE_NOTIFICATION object:Nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PROMOTION_UPDATE_NOTIFICATION object:Nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PROMOTION_DELETE_NOTIFICATION object:Nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PROMOTION_ADD_NOTIFICATION object:Nil];
}

#pragma mark
#pragma mark Private Methods

-(void)postSocialStatusUpdate {
   
//    @synchronized (self) {
//        if ([AppInfo sharedInfo].sessionType == SessionTypeFacebook) {
//            [FBSession openActiveSessionWithPublishPermissions:[NSArray arrayWithObjects:@"publish_actions", @"publish_stream", nil] defaultAudience:FBSessionDefaultAudienceEveryone allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState status, NSError *error){
//                if (!error && status == FBSessionStateOpen) {
////                    NSString *link = @"{\"saves time at restaurants using \":{\"href\":\"https://www.iwaitless.com/\",\"text\":\"Waitless\"}}";
//                    NSString *name = [NSString stringWithFormat:@"%@ %@", [[AppInfo sharedInfo].fbUserData objectForKey:@"first_name"], [[AppInfo sharedInfo].fbUserData objectForKey:@"last_name"]];
//                    NSString *postMessage = [NSString stringWithFormat:@"%@ saves time at restaurants using Waitless.", name];
//                    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                                   postMessage, @"message",
//                                                   [AppInfo getAppName], @"name",
//                                                   @"https://www.iwaitless.com/", @"link",
//                                                   @"https://pbs.twimg.com/profile_images/3759823209/a03789f7c277297778294e697a8a3052.jpeg", @"picture",
//                                                   nil];
//                    [FBRequestConnection startWithGraphPath:@"me/feed" parameters:params HTTPMethod:@"POST" completionHandler:^(FBRequestConnection *connection, id result, NSError *error){
//                        if (!error) {
//                            [[AppInfo sharedInfo] setSocialPost:YES];
//                        }
//                    }];
//                }
//            }];
//        }
//    }
}

-(void)goToHelp {
    
//    @synchronized (self) {
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:HELP_URL]];
//    }
    WebViewController *contentController = nil;
    WebViewController *centerViewController = nil;
    UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
    for (UIViewController *vc in navigationController.viewControllers) {
        if ([vc isKindOfClass:[WebViewController class]] && [[(WebViewController*)vc url_str] isEqualToString:HELP_URL]) {
            centerViewController = (WebViewController*)vc;
            break;
        }
    }
    if (!centerViewController) {
        contentController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"WebViewController"];
        contentController.url_str = HELP_URL;
        contentController.title_str = @"Waitless Help";
    }
    if (!centerViewController && contentController) {
        NSArray *controllers = [NSArray arrayWithObject:contentController];
        navigationController.viewControllers = controllers;
    }
    else if (centerViewController && ![navigationController.topViewController isKindOfClass:[centerViewController class]]) {
        [navigationController popToViewController:centerViewController animated:YES];
    }
    
//    [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
}

-(void)showLogoutAlert {

    if (!logoutVC) {
        logoutVC = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"LogoutViewController"];
        logoutVC.delegate = self;
    }
    [logoutVC showLogoutAlert];
}

-(void)showPaymentAlertNotification:(NSNotification *)notification {
    
    if (notification.object || shouldShowPaymentAlert) {
        shouldShowPaymentAlert = NO;
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Waitless" message:@"Add a payment source now." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Not Now", nil];
        [alertView show];
    }
}

-(void)parkedOrderUpdatedNotification:(NSNotification *)notification {
    
    [self updateParkedOrder];
}

-(void)promotionAddNotification:(NSNotification*)_notification {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *userInfo = [defaults objectForKey:PUSH_NOTIFICATION];
    NSString *response = [[userInfo objectForKey:@"message"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *notification = [response objectFromJSONString];
    if (notification && [notification isKindOfClass:[NSDictionary class]]) {
        [SVProgressHUD showWithStatus:@"Adding new promotion..." maskType:SVProgressHUDMaskTypeGradient];
        NSString *promotionId = [notification objectForKey:@"Id"];
        NSDictionary *params = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[AppInfo sharedInfo].user.tokenID, promotionId, nil] forKeys:[NSArray arrayWithObjects:@"tokenid", @"id", nil]];
        [HTTPRequest requestGetWithMethod:@"RestaurantService/Promotion" Params:params andDelegate:self andRequestType:HTTPRequestTypeGetAddPromotion];
    }
}

-(void)promotionUpdateNotification:(NSNotification*)_notification {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *userInfo = [defaults objectForKey:PUSH_NOTIFICATION];
    NSString *response = [[userInfo objectForKey:@"message"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *notification = [response objectFromJSONString];
    if (notification && [notification isKindOfClass:[NSDictionary class]]) {
        NSString *promotionId = [notification objectForKey:@"Id"];
        NSDictionary *params = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[AppInfo sharedInfo].user.tokenID, promotionId, nil] forKeys:[NSArray arrayWithObjects:@"tokenid", @"id", nil]];
        [HTTPRequest requestGetWithMethod:@"RestaurantService/Promotion" Params:params andDelegate:self andRequestType:HTTPRequestTypeGetUpdatePromotion];
    }
}

-(void)promotionDeleteNotification:(NSNotification*)_notification {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *userInfo = [defaults objectForKey:PUSH_NOTIFICATION];
    NSString *response = [[userInfo objectForKey:@"message"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *notification = [response objectFromJSONString];
    if (notification && [notification isKindOfClass:[NSDictionary class]]) {
        [[AppInfo sharedInfo].user deletePromotionWithID:[notification objectForKey:@"Id"]];
        UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
        for (UIViewController *vc in navigationController.viewControllers) {
            if ([vc isKindOfClass:[PromotionsViewController class]]) {
                PromotionsViewController *promotionsVC = (PromotionsViewController*)vc;
                [promotionsVC reloadPromotions];
                break;
            }
            else if ([vc isKindOfClass:[PageSwipeController class]]) {
                PageSwipeController *pageVC = (PageSwipeController*)vc;
                [pageVC reloadPromotions];
                break;
            }
        }
        [defaults removeObjectForKey:PUSH_NOTIFICATION];
        [defaults synchronize];
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    }
}

-(void)updateParkedOrder {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *userInfo = [defaults objectForKey:PUSH_NOTIFICATION];
    NSString *response = [[userInfo objectForKey:@"message"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *notification = [response objectFromJSONString];
    if (notification && [notification isKindOfClass:[NSDictionary class]] && [notification objectForKey:@"UserId"] && [[notification objectForKey:@"UserId"] isEqualToString:[AppInfo sharedInfo].user.userID]) {
        if ([notification objectForKey:@"UpdateType"] && ([[notification objectForKey:@"UpdateType"] intValue] == ParkedOrderStatusFulfilled || [[notification objectForKey:@"UpdateType"] intValue] == ParkedOrderStatusClosed)) {
            NSString *parkedOrderId = [notification objectForKey:@"ParkedOrderId"];
            if (parkedOrderId && (NSNull*)parkedOrderId != [NSNull null]) {
                if ([[notification objectForKey:@"UpdateType"] intValue] == ParkedOrderStatusFulfilled) {
                    [self requestForGettingParkedOrderWithID:parkedOrderId];
                }
                else {
                    [self requestForGettingParkedOrderWithID:parkedOrderId];
//                    [self closeParkedOrderWithID:parkedOrderId];
                }
            }
        }
    }
}

-(void)closeParkedOrderWithID:(NSString *)parkedOrderID {
    
    [[AppInfo sharedInfo].user closeParkedOrderWithID:parkedOrderID];
    NSMutableDictionary *parkedOrder = [[AppInfo sharedInfo].user getParkedOrderWithID:parkedOrderID];
    UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
    RestaurantModel *restaurantModel = [[AppInfo sharedInfo] getRestaurantModelFromID:[parkedOrder objectForKey:@"RestaurantId"]];
    if (!restaurantModel) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Warning! Restaurant not available." message:@"Please go to Nearby screen and see available restaurants." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
        [alertView show];
    }
    else {
        [parkedOrder setObject:[AppInfo getDateFromDateIntervalString:[parkedOrder objectForKey:@"FulfillmentDate"]] forKey:@"parkedOrderDate"];
        [parkedOrder setObject:restaurantModel forKey:@"restaurantModel"];
        PODetailsViewController *po_DetailsVC = Nil;
        for (UIViewController *vc in navigationController.viewControllers) {
            if ([vc isKindOfClass:[PODetailsViewController class]]) {
                po_DetailsVC = (PODetailsViewController*)vc;
                break;
            }
        }
        if (po_DetailsVC) {
            po_DetailsVC.orderDetails = parkedOrder;
            [po_DetailsVC reloadParkedOrderData];
            [navigationController popToViewController:po_DetailsVC animated:NO];
        }
        else {
            po_DetailsVC = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"PODetailsViewController"];
            po_DetailsVC.orderDetails = parkedOrder;
            [navigationController pushViewController:po_DetailsVC animated:NO];
        }
    }
    [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *userInfo = [defaults objectForKey:PUSH_NOTIFICATION];
    NSString *message = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
    if (message) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Waitless" message:message delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }
    [defaults removeObjectForKey:PUSH_NOTIFICATION];
    [defaults synchronize];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

-(void)requestForGettingParkedOrderWithID:(NSString*)parkedOrderId {
    
    NSDictionary *params = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[AppInfo sharedInfo].user.tokenID, parkedOrderId, nil] forKeys:[NSArray arrayWithObjects:@"tokenid", @"id", nil]];
    [HTTPRequest requestGetWithMethod:@"RestaurantService/ParkedOrder" Params:params andDelegate:self andRequestType:HTTPRequestTypeGetParkedOrder];
}

#pragma mark
#pragma mark LogoutDelegate Methods

-(void)logoutUser {
    
    [[AppInfo sharedInfo] logoutUser];
    [self.menuContainerViewController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [itemLabels count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"SideMenu_CellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16];
        cell.textLabel.textColor = [UIColor grayColor];
        UIView *bgColorView = [[UIView alloc] init];
        bgColorView.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:0 blue:0 alpha:0.2];
        [cell setSelectedBackgroundView:bgColorView];
    }
    
    cell.textLabel.text = [itemLabels objectAtIndex:indexPath.row];
    
    UIImage *placeholderImage = [UIImage imageNamed:[itemIcons objectAtIndex:indexPath.row]];
    
//    if (indexPath.row == 0 && [AppInfo sharedInfo].sessionType == SessionTypeFacebook) {
//        [cell.imageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture", [[AppInfo sharedInfo].fbUserData objectForKey:@"id"]]] placeholderImage:placeholderImage];
//    }
//    else if (indexPath.row == 0 && [AppInfo sharedInfo].sessionType == SessionTypeGooglePlus) {
//        [cell.imageView setImageWithURL:[NSURL URLWithString:[GPPSignIn sharedInstance].googlePlusUser.image.url] placeholderImage:placeholderImage];
//    }
//    else {
//        cell.imageView.image = placeholderImage;
//    }
    cell.imageView.image = placeholderImage;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UIViewController *contentController = nil;
    UIViewController *centerViewController = nil;
    UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
    
    switch (indexPath.row) {
        case 0:
            for (UIViewController *vc in navigationController.viewControllers) {
                if ([vc isKindOfClass:[ProfileViewController class]]) {
                    centerViewController = vc;
                    break;
                }
            }
            if (!centerViewController) {
                contentController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ProfileViewController"];
            }
            break;
        case 1:
            for (UIViewController *vc in navigationController.viewControllers) {
                if ([vc isKindOfClass:[ParkedOrderViewController class]]) {
                    centerViewController = vc;
                    break;
                }
            }
            if (!centerViewController) {
                contentController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ParkedOrderViewController"];
            }
            break;
        case 2:
            for (UIViewController *vc in navigationController.viewControllers) {
                if ([vc isKindOfClass:[RestaurantViewController class]]) {
                    centerViewController = vc;
                    break;
                }
            }
            if (!centerViewController) {
                contentController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"RestaurantViewController"];
            }
            break;
        case 3:
            for (UIViewController *vc in navigationController.viewControllers) {
                if ([vc isKindOfClass:[PromotionsViewController class]]) {
                    centerViewController = vc;
                    break;
                }
            }
            if (!centerViewController) {
                contentController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"PromotionsViewController"];
            }
            break;
        case 4:
            for (UIViewController *vc in navigationController.viewControllers) {
                if ([vc isKindOfClass:[PaymentsViewController class]]) {
                    centerViewController = vc;
                    break;
                }
            }
            if (!centerViewController) {
                contentController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"PaymentsViewController"];
            }
            break;
        case 5:
            for (UIViewController *vc in navigationController.viewControllers) {
                if ([vc isKindOfClass:[SettingsViewController class]]) {
                    centerViewController = vc;
                    break;
                }
            }
            if (!centerViewController) {
                contentController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"SettingsViewController"];
            }
            break;
        case 6:
            [self goToHelp];
            break;
        case 7:
            [self showLogoutAlert];
            break;
        default:
            break;
    }
    
    if (!centerViewController && contentController) {
        NSArray *controllers = [NSArray arrayWithObject:contentController];
        navigationController.viewControllers = controllers;
    }
    else if (centerViewController && ![navigationController.topViewController isKindOfClass:[centerViewController class]]) {
        [navigationController popToViewController:centerViewController animated:YES];
    }
    
    [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
}

#pragma mark
#pragma mark HTTPRequestDelegate Methods

-(void)didFinishRequest:(HTTPRequest*)httpRequest withData:(id)data {
    
    if (data && [data isKindOfClass:[NSDictionary class]] && [[data objectForKey:@"IsSuccessful"] boolValue]) {
        if (httpRequest.requestType == HTTPRequestTypeGetParkedOrder) {
            NSMutableDictionary *parkedOrder = [NSMutableDictionary dictionaryWithDictionary:[[data objectForKey:@"List"] firstObject]];
            [[AppInfo sharedInfo].user updateParkedOrder:parkedOrder];
            UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
            RestaurantModel *restaurantModel = [[AppInfo sharedInfo] getRestaurantModelFromID:[parkedOrder objectForKey:@"RestaurantId"]];
            if (!restaurantModel) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Warning! Restaurant not available." message:@"Please go to Nearby screen and see available restaurants." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
                [alertView show];
            }
            else {
                [parkedOrder setObject:[AppInfo getDateFromDateIntervalString:[parkedOrder objectForKey:@"FulfillmentDate"]] forKey:@"parkedOrderDate"];
                [parkedOrder setObject:restaurantModel forKey:@"restaurantModel"];
                PODetailsViewController *po_DetailsVC = Nil;
                for (UIViewController *vc in navigationController.viewControllers) {
                    if ([vc isKindOfClass:[PODetailsViewController class]]) {
                        po_DetailsVC = (PODetailsViewController*)vc;
                        break;
                    }
                }
                if (po_DetailsVC) {
                    po_DetailsVC.orderDetails = parkedOrder;
                    [po_DetailsVC reloadParkedOrderData];
                    [navigationController popToViewController:po_DetailsVC animated:NO];
                }
                else {
                    po_DetailsVC = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"PODetailsViewController"];
                    po_DetailsVC.orderDetails = parkedOrder;
                    [navigationController pushViewController:po_DetailsVC animated:NO];
                }
            }
            [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSDictionary *userInfo = [defaults objectForKey:PUSH_NOTIFICATION];
            NSString *message = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
            if (message) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Waitless" message:message delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertView show];
            }
            [defaults removeObjectForKey:PUSH_NOTIFICATION];
            [defaults synchronize];
            [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        }
        else if (httpRequest.requestType == HTTPRequestTypeGetAddPromotion) {
            NSMutableDictionary *promotion = [NSMutableDictionary dictionaryWithDictionary:[[data objectForKey:@"List"] firstObject]];
            [[AppInfo sharedInfo].user addPromotion:promotion];
            BOOL flag = NO;
            UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
            for (UIViewController *vc in navigationController.viewControllers) {
                if ([vc isKindOfClass:[PromotionsViewController class]]) {
                    PromotionsViewController *promotionsVC = (PromotionsViewController*)vc;
                    [promotionsVC reloadPromotions];
                    [navigationController popToViewController:promotionsVC animated:NO];
                    flag = YES;
                    break;
                }
                else if ([vc isKindOfClass:[PageSwipeController class]]) {
                    PageSwipeController *pageVC = (PageSwipeController*)vc;
                    [pageVC reloadPromotions];
                    [navigationController popToViewController:pageVC animated:NO];
                    flag = YES;
                    break;
                }
            }
            if (!flag) {
                PromotionsViewController *promotionsVC = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"PromotionsViewController"];
                [navigationController pushViewController:promotionsVC animated:NO];
            }
            [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSDictionary *userInfo = [defaults objectForKey:PUSH_NOTIFICATION];
            NSString *message = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
            if (message) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Waitless" message:message delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertView show];
            }
            [defaults removeObjectForKey:PUSH_NOTIFICATION];
            [defaults synchronize];
            [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        }
        else if (httpRequest.requestType == HTTPRequestTypeGetUpdatePromotion) {
            NSMutableDictionary *promotion = [NSMutableDictionary dictionaryWithDictionary:[[data objectForKey:@"List"] firstObject]];
            [[AppInfo sharedInfo].user updatePromotion:promotion];
            UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
            for (UIViewController *vc in navigationController.viewControllers) {
                if ([vc isKindOfClass:[PromotionsViewController class]]) {
                    PromotionsViewController *promotionsVC = (PromotionsViewController*)vc;
                    [promotionsVC reloadPromotions];
                    break;
                }
                else if ([vc isKindOfClass:[PageSwipeController class]]) {
                    PageSwipeController *pageVC = (PageSwipeController*)vc;
                    [pageVC reloadPromotions];
                    break;
                }
            }
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults removeObjectForKey:PUSH_NOTIFICATION];
            [defaults synchronize];
            [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        }
    }
    [SVProgressHUD dismiss];
}

-(void)didFailRequest:(HTTPRequest*)httpRequest withError:(NSString*)errorMessage {
    
    [SVProgressHUD dismiss];
}

#pragma mark
#pragma mark UIAlertViewDelegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        BOOL hasFound = NO;
        UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
        for (UIViewController *vc in navigationController.viewControllers) {
            if ([vc isKindOfClass:[PaymentsViewController class]]) {
                PaymentsViewController *paymentVC = (PaymentsViewController*)vc;
                [navigationController popToViewController:paymentVC animated:NO];
                hasFound = YES;
                break;
            }
        }
        if (!hasFound) {
            PaymentsViewController *paymentVC = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"PaymentsViewController"];
            [navigationController pushViewController:paymentVC animated:YES];
        }
    }
}

@end
