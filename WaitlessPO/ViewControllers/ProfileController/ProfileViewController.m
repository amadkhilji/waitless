//
//  ProfileViewController.m
//  WaitlessPO
//
//  Created by Amad Khilji on 08/12/2013.
//  Copyright (c) 2013 Amad Khilji. All rights reserved.
//

#import "ProfileViewController.h"
#import "MFSideMenu.h"
#import "UserModel.h"
#import "ProfileCell.h"
#import "UIImageView+WebCache.h"
#import <QuartzCore/QuartzCore.h>
//#import <GooglePlus/GooglePlus.h>
//#import <GoogleOpenSource/GoogleOpenSource.h>

@interface ProfileViewController ()

-(NSString*)getFormattedDateStringFromString:(NSString*)dateString;

@end

@implementation ProfileViewController

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
    
    upcomingParkedOrderList = [NSMutableArray array];
    UserModel *user = [AppInfo sharedInfo].user;
    title_lbl.text = [NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName];
    name_lbl.text = [NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName];
    NSMutableString *address = [NSMutableString stringWithString:user.city];
    if (address.length > 0) {
        [address appendString:@", "];
    }
    [address appendString:user.state];
    if (user.state.length > 0) {
        [address appendString:@", "];
    }
    [address appendString:user.zipCode];
    address_lbl.text = address;
    
    int openedOrderCount = 0;
    int fulfilledOrderCount = 0;
    int closedOrderCount = 0;
    int refundedOrderCount = 0;
    int voidedOrderCount = 0;
    NSDate *currentDate = [NSDate date];
    for (int i=0; i<[user.parkedOrderList count]; i++) {
        NSDictionary *parkedOrder = [user.parkedOrderList objectAtIndex:i];
        if ([[parkedOrder objectForKey:@"Status"] intValue] == ParkedOrderStatusOpened || [[parkedOrder objectForKey:@"Status"] intValue] == ParkedOrderStatusClosed) {
            
            if ([[parkedOrder objectForKey:@"Status"] intValue] == ParkedOrderStatusClosed) {
                closedOrderCount++;
            }
            else {
                openedOrderCount++;
            }
            NSDate *date = [AppInfo getDateFromDateIntervalString:[parkedOrder objectForKey:@"FulfillmentDate"]];
            NSTimeInterval currentInterval = [currentDate timeIntervalSince1970];
            NSTimeInterval orderInterval = [date timeIntervalSince1970];
            if (orderInterval >= currentInterval) {
                [upcomingParkedOrderList addObject:parkedOrder];
            }
        }
        else if ([[parkedOrder objectForKey:@"Status"] intValue] == ParkedOrderStatusFulfilled) {
            fulfilledOrderCount++;
        }
//        else if ([[parkedOrder objectForKey:@"Status"] intValue] == ParkedOrderStatusClosed) {
//            closedOrderCount++;
//        }
        else if ([[parkedOrder objectForKey:@"Status"] intValue] == ParkedOrderStatusRefunded) {
            refundedOrderCount++;
        }
        else if ([[parkedOrder objectForKey:@"Status"] intValue] == ParkedOrderStatusVoided) {
            voidedOrderCount++;
        }
    }
    order_lbl_1.tag = 1;
    order_lbl_2.tag = 2;
    order_lbl_3.tag = 3;
    order_lbl_4.tag = 4;
    order_lbl_5.tag = 5;
    int tag = 1;
    CGRect frame = footerView.frame;
    UILabel *label = (UILabel*)[footerView viewWithTag:tag];
    label.text = [NSString stringWithFormat:@"%i Open Parked Orders", openedOrderCount];
    tag++;
    if (fulfilledOrderCount > 0) {
        label = (UILabel*)[footerView viewWithTag:tag];
        label.text = [NSString stringWithFormat:@"%i Fulfilled Parked Orders", fulfilledOrderCount];
        tag++;
    }
    label = (UILabel*)[footerView viewWithTag:tag];
    label.text = [NSString stringWithFormat:@"%i Closed Parked Orders", closedOrderCount];
    tag++;
    if (refundedOrderCount > 0) {
        label = (UILabel*)[footerView viewWithTag:tag];
        label.text = [NSString stringWithFormat:@"%i Refunded Parked Orders", refundedOrderCount];
        tag++;
    }
    if (voidedOrderCount > 0) {
        label = (UILabel*)[footerView viewWithTag:tag];
        label.text = [NSString stringWithFormat:@"%i Voided Parked Orders", voidedOrderCount];
        tag++;
    }
    if (tag < 6) {
        CGFloat height = order_lbl_1.frame.size.height*(6-tag);
        frame.size.height -= height;
    }
    footerView.frame = frame;
    
    if ([AppInfo sharedInfo].sessionType == SessionTypeFacebook) {
        [userImage setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?height=200&width=200", [[AppInfo sharedInfo].fbUserData objectForKey:@"id"]]]];
    }
    else if ([AppInfo sharedInfo].sessionType == SessionTypeGooglePlus) {
//        [userImage setImageWithURL:[NSURL URLWithString:[GPPSignIn sharedInstance].googlePlusUser.image.url]];
    }
    userImage.layer.cornerRadius = userImage.frame.size.width/2.0;
    userImage.layer.masksToBounds = YES;
    
    profileTableView.tableFooterView = footerView;
    [profileTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark
#pragma mark Private Methods

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

#pragma mark
#pragma mark IBAction Methods

-(IBAction)menuAction:(id)sender {
    
    [self.menuContainerViewController setMenuState:MFSideMenuStateLeftMenuOpen];
}

#pragma mark
#pragma mark UITableViewDelegate/UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if ([upcomingParkedOrderList count] > 0) {
        return [upcomingParkedOrderList count];
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"ProfileCellIdentifier";
    
    ProfileCell *cell = (ProfileCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"ProfileCell" owner:self options:nil] objectAtIndex:0];
    }
    
    if ([upcomingParkedOrderList count] == 0) {
        cell.time_lbl.text = @"No upcoming parked orders.";
    }
    else {
        NSDictionary *parkedOrder = [upcomingParkedOrderList objectAtIndex:indexPath.row];
        cell.title_lbl.text = [[AppInfo sharedInfo] getRestaurantNameFromID:[parkedOrder objectForKey:@"RestaurantId"]];
        cell.name_lbl.text = [parkedOrder objectForKey:@"CustomId"];
        cell.price_lbl.text = [NSString stringWithFormat:@"$%.2f", [[parkedOrder objectForKey:@"TotalCost"] floatValue]];
        cell.time_lbl.text = [self getFormattedDateStringFromString:[parkedOrder objectForKey:@"FulfillmentDate"]];
        if ([[parkedOrder objectForKey:@"Status"] intValue] == ParkedOrderStatusOpened) {
            cell.status_lbl.text = @"Opened";
        }
        else if ([[parkedOrder objectForKey:@"Status"] intValue] == ParkedOrderStatusClosed) {
            cell.status_lbl.text = @"Closed";
        }
    }
    
    return cell;
}

@end
