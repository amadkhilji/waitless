//
//  FoodAdditionAlertView.m
//  WaitlessPO
//
//  Created by SSASOFT on 9/25/14.
//  Copyright (c) 2014 Amad Khilji. All rights reserved.
//

#import "FoodAdditionAlertView.h"
#import "UIView+AlertAnimations.h"
#import <QuartzCore/QuartzCore.h>
#import "FoodAdditionCell.h"

@interface FoodAdditionAlertView ()

-(void)dismiss;
-(void)alertDidFadeOut;
-(NSString*)getSelectedFoodAdditionIDs;
-(NSArray*)getSelectedFoodAdditionItems;

@end

@implementation FoodAdditionAlertView

@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc {
    
    delegate = nil;
    [foodAdditionsList release];
    
    [super dealloc];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark
#pragma mark Private Methods

-(void)dismiss {
    
    [alertView doPopOutAnimation];
    [backgroundView doFadeOutAnimationWithDelegate:self];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:kPopAnimationDuration];
    self.view.alpha = 0.0;
    [UIView commitAnimations];
}

-(void)alertDidFadeOut {
    
    [self.view removeFromSuperview];
    [self autorelease];
}

-(NSString*)getSelectedFoodAdditionIDs {
    
    NSMutableString *selectedIDs = [NSMutableString string];
    for (int i=0; i<[foodAdditionsList count]; i++) {
        NSDictionary *foodAddition = [foodAdditionsList objectAtIndex:i];
        if ([[foodAddition objectForKey:@"IsSelected"] boolValue]) {
            if (i>0 && selectedIDs.length > 0) {
                [selectedIDs appendString:@","];
            }
            [selectedIDs appendString:[foodAddition objectForKey:@"Id"]];
        }
    }
    return selectedIDs;
}

-(NSArray*)getSelectedFoodAdditionItems {
    
    NSMutableArray *selectedFoodAdditions = [NSMutableArray array];
    for (int i=0; i<[foodAdditionsList count]; i++) {
        NSDictionary *foodAddition = [foodAdditionsList objectAtIndex:i];
        if ([[foodAddition objectForKey:@"IsSelected"] boolValue]) {
            [selectedFoodAdditions addObject:foodAddition];
        }
    }
    return selectedFoodAdditions;
}

#pragma mark
#pragma mark Logical Methods

-(void)show {
    
    // Retaining self is odd, but we do it to make this "fire and forget"
    [self retain];
    
    // We need to add it to the window, which we can get from the delegate
    id appDelegate = [[UIApplication sharedApplication] delegate];
    UIWindow *window = [appDelegate window];
    [window addSubview:self.view];
    
    // Make sure the alert covers the whole window
    self.view.frame = CGRectMake(0, 0, window.frame.size.width, window.frame.size.height);
    self.view.center = window.center;
    alertView.center = self.view.center;
    
    // "Pop in" animation for alert
    [alertView doPopInAnimation];
    
    // "Fade in" animation for background
    [backgroundView doFadeInAnimation];
    
    [foodAdditionTable reloadData];
}

-(void)loadFoodAdditionsList:(NSArray *)list {
    
    if (list) {
        if (!foodAdditionsList) {
            foodAdditionsList = [[NSMutableArray alloc] init];
        }
        if ([foodAdditionsList count] > 0) {
            [foodAdditionsList removeAllObjects];
        }
        for (int i=0; i<[list count]; i++) {
            NSMutableDictionary *foodAddition = [NSMutableDictionary dictionaryWithDictionary:[list objectAtIndex:i]];
            [foodAddition setObject:[NSNumber numberWithBool:NO] forKey:@"IsSelected"];
            [foodAdditionsList addObject:foodAddition];
        }
    }
}

-(void)foodItemAtIndex:(NSInteger)index selected:(BOOL)isSelected {
    
    if (index >=0 && index < [foodAdditionsList count]) {
        NSMutableDictionary *foodAddition = [foodAdditionsList objectAtIndex:index];
        [foodAddition setObject:[NSNumber numberWithBool:isSelected] forKey:@"IsSelected"];
    }
}

#pragma mark
#pragma mark IBAction Methods

-(IBAction)cancelAction:(id)sender {

    [self dismiss];
    if (delegate && [delegate respondsToSelector:@selector(customAlertView:dismissedWithValue:)]) {
        [delegate customAlertView:self dismissedWithValue:nil];
    }
}

-(IBAction)doneAction:(id)sender {
    
    [self dismiss];
    if (delegate && [delegate respondsToSelector:@selector(customAlertView:dismissedWithValue:)]) {
        [delegate customAlertView:self dismissedWithValue:[self getSelectedFoodAdditionItems]];
    }
}

#pragma mark
#pragma mark UITableViewDelegate/UITableViewDataSource Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    return 50.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [foodAdditionsList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"FoodAdditionCellIdentifier";
    
    FoodAdditionCell *cell = (FoodAdditionCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = (FoodAdditionCell*)[[[[NSBundle mainBundle] loadNibNamed:@"FoodAdditionCell" owner:self options:nil] lastObject] autorelease];
        cell.parentController = self;
    }
    
    NSDictionary *foodAddition = [foodAdditionsList objectAtIndex:indexPath.row];
    cell.name_lbl.text = [foodAddition objectForKey:@"Name"];
    cell.price_lbl.text = [NSString stringWithFormat:@"$%.2f", [[foodAddition objectForKey:@"Price"] doubleValue]];
    cell.check_btn.selected = [[foodAddition objectForKey:@"IsSelected"] boolValue];
    cell.tag = indexPath.row;
    
    return cell;
}

#pragma mark
#pragma mark CAAnimation Delegate Methods

-(void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {
    
    [self alertDidFadeOut];
}

@end
