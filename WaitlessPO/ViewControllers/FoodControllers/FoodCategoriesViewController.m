//
//  FoodCategoriesViewController.m
//  WaitlessPO
//
//  Created by Amad Khilji on 05/12/2013.
//  Copyright (c) 2013 Amad Khilji. All rights reserved.
//

#import "FoodCategoriesViewController.h"
#import "FoodItemViewController.h"

@interface FoodCategoriesViewController ()

@end

@implementation FoodCategoriesViewController

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

-(void)setFoodCategories:(NSArray*)categories {
    
    foodCategoriesList = [NSMutableArray array];
    for (int i=0; i<[categories count]; i++) {
        NSDictionary *category = [categories objectAtIndex:i];
        if ([[category objectForKey:@"VisibleToMerchantOnly"] intValue] == 0) {
            [foodCategoriesList addObject:category];
        }
    }
}

#pragma mark
#pragma mark IBAction Methods

-(IBAction)backAction:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark
#pragma mark UITableViewDelegate/UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [foodCategoriesList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"FoodCategoriesCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16];
        cell.textLabel.textColor = [UIColor blackColor];
        cell.backgroundColor = [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0];
        UIView *bgColorView = [[UIView alloc] init];
        bgColorView.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:0 blue:0 alpha:0.2];
        [cell setSelectedBackgroundView:bgColorView];
    }
    
    NSDictionary *category = [foodCategoriesList objectAtIndex:indexPath.row];
    cell.textLabel.text = [category objectForKey:@"Name"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *category = [foodCategoriesList objectAtIndex:indexPath.row];
    FoodItemViewController *foodItemVC = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"FoodItemViewController"];
    [foodItemVC setFoodItems:[[category objectForKey:@"FoodItemList"] objectForKey:@"List"]];
    foodItemVC.isParkedOrder = isParkedOrder;
    foodItemVC.quantity = quantity;
    foodItemVC.price = price;
    [self.navigationController pushViewController:foodItemVC animated:YES];
}

@end
