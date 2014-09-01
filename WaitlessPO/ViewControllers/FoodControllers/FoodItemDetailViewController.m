//
//  FoodItemDetailViewController.m
//  WaitlessPO
//
//  Created by Amad Khilji on 08/12/2013.
//  Copyright (c) 2013 Amad Khilji. All rights reserved.
//

#import "FoodItemDetailViewController.h"
#import "UIImageView+WebCache.h"
#import "PODetailsViewController.h"

@interface FoodItemDetailViewController ()

@end

@implementation FoodItemDetailViewController

@synthesize canOrderFood;
@synthesize quantity;
@synthesize price;
@synthesize foodData;

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

    price_quantity_view.hidden = !canOrderFood;
    quantity_lbl.text = [NSString stringWithFormat:@"%i", quantity];
    price_lbl.text = [NSString stringWithFormat:@"$%.2f", price];
    
    title_lbl.text = [foodData objectForKey:@"Name"];
    food_name_lbl.text = [foodData objectForKey:@"Name"];
    if ([foodData objectForKey:@"Description"] && (NSNull*)[foodData objectForKey:@"Description"] != [NSNull null]) {
        food_description_lbl.text = [foodData objectForKey:@"Description"];
    }
    else {
        food_description_lbl.text = @"Description not available.";
    }
    food_price_lbl.text = [NSString stringWithFormat:@"$%.2f", [[foodData objectForKey:@"Price"] floatValue]];
    NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", ASSET_URL, [foodData objectForKey:@"AssetUrl"]]];
    [food_image setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"no_image_available.png"]];
    
    CGSize size = [food_description_lbl.text sizeWithFont:food_description_lbl.font constrainedToSize:CGSizeMake(food_description_lbl.frame.size.width, 200)];
    CGRect frame = food_description_lbl.frame;
    frame.size.height = size.height;
    food_description_lbl.frame = frame;

    CGFloat height = frame.origin.y+frame.size.height+10;
    frame = tableHeaderView.frame;
    frame.size.height = height;
    tableHeaderView.frame = frame;
    
    foodOptionTable.tableHeaderView = tableHeaderView;
    foodOptionTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
    
    selectedFoodOptions = [[NSMutableArray alloc] init];
    if (foodData && [foodData objectForKey:@"FoodOptionChoiceId"] && (NSNull*)[foodData objectForKey:@"FoodOptionChoiceId"] != [NSNull null]) {
        NSArray *options = [[foodData objectForKey:@"FoodOptionChoiceId"] componentsSeparatedByString:@","];
        if (options && [options isKindOfClass:[NSArray class]]) {
            for (int i=0; i<[options count]; i++) {
                NSString *optionId = [options objectAtIndex:i];
                if (optionId && (NSNull*)optionId != [NSNull null] && optionId.length > 0) {
                    [selectedFoodOptions addObject:optionId];
                }
            }
        }
    }
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    order_btn.hidden = !canOrderFood;
    order_btn_lbl.hidden = !canOrderFood;
    
//    if (canOrderFood) {
//        order_btn.enabled = YES;
//        order_btn.userInteractionEnabled = YES;
//        order_btn_lbl.alpha = 1.0;
//    }
//    else {
//        order_btn.enabled = NO;
//        order_btn.userInteractionEnabled = NO;
//        order_btn_lbl.alpha = 0.5;
//    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark
#pragma mark IBAction Methods

-(IBAction)backAction:(id)sender {

    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)orderAction:(id)sender {
    
    PODetailsViewController *viewController = Nil;
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:[PODetailsViewController class]]) {
            viewController = (PODetailsViewController*)vc;
            break;
        }
    }
    if (viewController) {
        [viewController setFoodItem:foodData];
        [self.navigationController popToViewController:viewController animated:YES];
    }
}

#pragma mark
#pragma mark UITableViewDelegate/UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if ([foodData objectForKey:@"FoodOptionList"] && [[foodData objectForKey:@"FoodOptionList"] isKindOfClass:[NSDictionary class]] && [[foodData objectForKey:@"FoodOptionList"] objectForKey:@"List"] && [[[foodData objectForKey:@"FoodOptionList"] objectForKey:@"List"] isKindOfClass:[NSArray class]]) {
        return [[[foodData objectForKey:@"FoodOptionList"] objectForKey:@"List"] count];
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSArray *list = [[foodData objectForKey:@"FoodOptionList"] objectForKey:@"List"];
    if (list && [list isKindOfClass:[NSArray class]] && [list count] > 0) {
        list = [[[list objectAtIndex:section] objectForKey:@"FoodChoiceList"] objectForKey:@"List"];
        if (list && [list isKindOfClass:[NSArray class]]) {
            if (canOrderFood && [selectedFoodOptions count] < tableView.numberOfSections && [list count] > 0) {
                NSDictionary *foodItem = [list objectAtIndex:0];
                NSString *optionId = [foodItem objectForKey:@"Id"];
                if (optionId && (NSNull*)optionId != [NSNull null]) {
                    [selectedFoodOptions addObject:optionId];
                }
                if ((section+1) == tableView.numberOfSections) {
                    NSMutableString *foodOptions = [NSMutableString string];
                    for (int i=0; i<[selectedFoodOptions count]; i++) {
                        if (i>0) {
                            [foodOptions appendString:@","];
                        }
                        [foodOptions appendString:[selectedFoodOptions objectAtIndex:i]];
                    }
                    [foodData setObject:foodOptions forKey:@"FoodOptionChoiceId"];
                }
            }
            return [list count];
        }
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSDictionary *foodItem = [[[foodData objectForKey:@"FoodOptionList"] objectForKey:@"List"] objectAtIndex:section];
    return [foodItem objectForKey:@"Name"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"FoodItemDetailCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, 260, 26)];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor blackColor];
        label.textAlignment = NSTextAlignmentLeft;
        label.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
        label.tag = 9;
        [cell addSubview:label];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 16, 16)];
        imageView.image = [UIImage imageNamed:@"radio_btn_unchecked.png"];
        imageView.highlightedImage = [UIImage imageNamed:@"radio_btn_checked.png"];
        imageView.backgroundColor = [UIColor clearColor];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [imageView setHighlighted:NO];
        imageView.tag = 10;
        [cell addSubview:imageView];
        
        cell.backgroundColor = [UIColor clearColor];//[UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0];
    }
    
    NSDictionary *foodItem = [[[[[[foodData objectForKey:@"FoodOptionList"] objectForKey:@"List"] objectAtIndex:indexPath.section] objectForKey:@"FoodChoiceList"] objectForKey:@"List"] objectAtIndex:indexPath.row];
    UILabel *nameLabel = (UILabel*)[cell viewWithTag:9];
    UIImageView *imageView = (UIImageView*)[cell viewWithTag:10];
    
    nameLabel.text = [foodItem objectForKey:@"Name"];
    
    if (!canOrderFood) {
        imageView.hidden = YES;
        CGRect frame = nameLabel.frame;
        frame.origin.x = 20;
        frame.size.width = 280;
        nameLabel.frame = frame;
    }
    else {
        if ([selectedFoodOptions count] > 0) {
            
            NSString *optionId = [foodItem objectForKey:@"Id"];
            if (optionId && (NSNull*)optionId != [NSNull null]) {
                int index = (int)[selectedFoodOptions indexOfObject:optionId];
                if (index >= 0 && index < [selectedFoodOptions count]) {
                    [imageView setHighlighted:YES];
                }
                else {
                    [imageView setHighlighted:NO];
                }
            }
            else {
                [imageView setHighlighted:NO];
            }
        }
        else {
            [imageView setHighlighted:NO];
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (canOrderFood) {

        NSArray *optionsList = [[[[[foodData objectForKey:@"FoodOptionList"] objectForKey:@"List"] objectAtIndex:indexPath.section] objectForKey:@"FoodChoiceList"] objectForKey:@"List"];
        NSDictionary *foodItem = [optionsList objectAtIndex:indexPath.row];
        
        NSString *optionId = [foodItem objectForKey:@"Id"];
        if (optionId && (NSNull*)optionId != [NSNull null]) {
            NSInteger index = [selectedFoodOptions indexOfObject:optionId];
            if (index < 0 || index >= [selectedFoodOptions count]) {
                [selectedFoodOptions addObject:optionId];
            }
        }
        NSMutableArray *deletedObjects = [NSMutableArray array];
        for (int i=0; i<[optionsList count]; i++) {
            NSString *choiceId = [[optionsList objectAtIndex:i] objectForKey:@"Id"];
            if (optionId && (NSNull*)optionId != [NSNull null] && choiceId && (NSNull*)choiceId != [NSNull null] && ![choiceId isEqualToString:optionId]) {
                NSInteger index = [selectedFoodOptions indexOfObject:choiceId];
                if (index >= 0 && index < [selectedFoodOptions count]) {
                    [deletedObjects addObject:[selectedFoodOptions objectAtIndex:index]];
                }
            }
        }
        [selectedFoodOptions removeObjectsInArray:deletedObjects];
        [deletedObjects removeAllObjects];
        NSMutableString *foodOptions = [NSMutableString string];
        for (int i=0; i<[selectedFoodOptions count]; i++) {
            if (i>0) {
                [foodOptions appendString:@","];
            }
            [foodOptions appendString:[selectedFoodOptions objectAtIndex:i]];
        }
        [foodData setObject:foodOptions forKey:@"FoodOptionChoiceId"];
        [foodOptionTable reloadData];
    }
}

@end
