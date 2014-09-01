//
//  FoodItemViewController.m
//  WaitlessPO
//
//  Created by Amad Khilji on 05/12/2013.
//  Copyright (c) 2013 Amad Khilji. All rights reserved.
//

#import "FoodItemViewController.h"
#import "FoodItemDetailViewController.h"

@interface FoodItemViewController ()

@end

@implementation FoodItemViewController

@synthesize isParkedOrder;
@synthesize quantity;
@synthesize price;

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
    price_quantity_view.hidden = !isParkedOrder;
    quantity_lbl.text = [NSString stringWithFormat:@"%i", quantity];
    price_lbl.text = [NSString stringWithFormat:@"$%.2f", price];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark
#pragma mark Logical Methods

-(void)setFoodItems:(NSArray *)items {
    
    foodItemsList = [NSMutableArray arrayWithArray:items];
}

#pragma mark
#pragma mark IBAction Methods

-(IBAction)backAction:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark
#pragma mark UITableViewDelegate/UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [foodItemsList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"FoodItemsCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 210, 30)];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor blackColor];
        label.textAlignment = NSTextAlignmentLeft;
        label.font = [UIFont fontWithName:@"HelveticaNeue" size:16];
        label.tag = 9;
        [cell addSubview:label];
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(230, 10, 80, 30)];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor colorWithRed:204.0/255.0 green:0.0 blue:0.0 alpha:1.0];
        label.textAlignment = NSTextAlignmentRight;
        label.font = [UIFont fontWithName:@"HelveticaNeue" size:16];
        label.tag = 10;
        [cell addSubview:label];
        
        cell.backgroundColor = [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0];
        
        UIView *bgColorView = [[UIView alloc] init];
        bgColorView.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:0 blue:0 alpha:0.2];
        [cell setSelectedBackgroundView:bgColorView];
    }
    
    NSDictionary *category = [foodItemsList objectAtIndex:indexPath.row];

    UILabel *nameLabel = (UILabel*)[cell viewWithTag:9];
    UILabel *priceLabel = (UILabel*)[cell viewWithTag:10];
    
    nameLabel.text = [category objectForKey:@"Name"];
    priceLabel.text = [NSString stringWithFormat:@"$%.2f", [[category objectForKey:@"Price"] floatValue]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *category = [foodItemsList objectAtIndex:indexPath.row];
    FoodItemDetailViewController *foodItemVC = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"FoodItemDetailViewController"];
    foodItemVC.canOrderFood = isParkedOrder;
    foodItemVC.quantity = quantity;
    foodItemVC.price = price;
    foodItemVC.foodData = [NSMutableDictionary dictionaryWithDictionary:category];
    [self.navigationController pushViewController:foodItemVC animated:YES];
}

@end
