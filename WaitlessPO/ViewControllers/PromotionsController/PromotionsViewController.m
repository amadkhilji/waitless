//
//  PromotionsViewController.m
//  WaitlessPO
//
//  Created by Amad Khilji on 08/12/2013.
//  Copyright (c) 2013 Amad Khilji. All rights reserved.
//

#import "PromotionsViewController.h"
#import "MFSideMenu.h"
#import "UserModel.h"
#import "PromotionCell.h"
#import "UIImageView+WebCache.h"

@interface PromotionsViewController ()

-(NSString*)getFormattedDateStringFromString:(NSString*)dateString;

@end

@implementation PromotionsViewController

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

-(NSString*)getFormattedDateStringFromString:(NSString*)dateString {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/yyyy"];
    NSDate *date = [formatter dateFromString:dateString];
    [formatter setDateFormat:@"EEE, MMM dd"];
    return [formatter stringFromDate:date];
}

-(void)reloadPromotions {
    
    [promotionTableView reloadData];
}

#pragma mark
#pragma mark IBAction Methods

-(IBAction)menuAction:(id)sender {
    
    [self.menuContainerViewController setMenuState:MFSideMenuStateLeftMenuOpen];
}

#pragma mark
#pragma mark UITableViewDelegate/UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [[AppInfo sharedInfo].user.promotionList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"PromotionCellIdentifier";
    
    PromotionCell *cell = (PromotionCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"PromotionCell" owner:self options:nil] objectAtIndex:0];
    }
    
    NSDictionary *promotion = [[AppInfo sharedInfo].user.promotionList objectAtIndex:indexPath.row];
    cell.title_lbl.text = [promotion objectForKey:@"Name"];
    cell.restaurant_lbl.text = [[AppInfo sharedInfo] getRestaurantNameFromID:[promotion objectForKey:@"RestaurantId"]];
    cell.description_TV.text = [promotion objectForKey:@"Description"];
    cell.date_lbl.text = [NSString stringWithFormat:@"Expires: %@", [self getFormattedDateStringFromString:[promotion objectForKey:@"EndDate"]]];
    if ([promotion objectForKey:@"Code"] && (NSNull*)[promotion objectForKey:@"Code"] != [NSNull null] && [[promotion objectForKey:@"Code"] isKindOfClass:[NSString class]] && [[promotion objectForKey:@"Code"] length] > 0) {
        cell.code_lbl.text = [NSString stringWithFormat:@"Promo Code: %@", [promotion objectForKey:@"Code"]];
        [cell.promoImage setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", ASSET_URL, [promotion objectForKey:@"AssetUrl"]]] placeholderImage:[UIImage imageNamed:@"restaurant_place_holder.png"]];
        cell.code_lbl.hidden = NO;
    }
    else {
        cell.code_lbl.hidden = YES;
    }
    
    return cell;
}

@end
