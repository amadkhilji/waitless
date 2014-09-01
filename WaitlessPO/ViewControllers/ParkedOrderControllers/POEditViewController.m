//
//  POEditViewController.m
//  WaitlessPO
//
//  Created by Amad Khilji on 15/12/2013.
//  Copyright (c) 2013 Amad Khilji. All rights reserved.
//

#import "POEditViewController.h"
#import "RestaurantModel.h"
#import "UIImageView+WebCache.h"
#import "POEditCell.h"
#import "PODetailsViewController.h"
#import "SVProgressHUD.h"
#import "UserModel.h"
#import "PageSwipeController.h"
#import "ParkedOrderViewController.h"
#import "MFSideMenu.h"

#define DATE_STRING         @"Select Date / Time"
#define PICKUP_TIME_STRING  @"Select Pick-up Time"
#define PARTY_SIZE_STRING   @"Select Party Size"
#define GRATUITY_STRING     @"Set Custom Gratuity"

@interface POEditViewController ()

-(void)setParkedOrderDetails;
-(void)setOrderCost;
-(void)updateGratuity;
-(void)requestForGettingParkedOrder;
-(void)requestForUpdateParkedOrder;
-(void)requestForDeleteParkedOrder;
-(void)showPickUpTimeAlertView;
-(void)hidePickUpTimeAlertView;

@end

@implementation POEditViewController

@synthesize gratuity_rate;
@synthesize parentController;

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
    orderTable.tableFooterView = footerView;
    shouldUpdate = NO;
    gratuity_rate = 0.0;
    pickUpTimeList = [[NSMutableArray alloc] initWithObjects:@"20 Minutes", @"40 Minutes", @"1 Hour", nil];
    [self setParkedOrderDetails];
    [self setOrderCost];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
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
        NSDate *date = [orderDetails objectForKey:@"parkedOrderDate"];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MM/dd/yyyy hh:mm a"];
        date_timeTF.text = [formatter stringFromDate:date];
        party_sizeTF.text = [NSString stringWithFormat:@"%i", [[orderDetails objectForKey:@"PartySize"] intValue]];
        
        NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", ASSET_URL, restaurantModel.assetUrl]];
        [restaurant_image setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"restaurant_place_holder.png"]];
//        [foodItemsList addObjectsFromArray:[orderDetails objectForKey:@"List"]];
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
        gratuity_rateTF.text = [NSString stringWithFormat:@"$%.2f", gratuity];
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
        gratuity_title_lbl.text = [NSString stringWithFormat:@"Gratuity (%.1f%%)", gratuity_rate];
    }
}

-(void)updateGratuity {
    
    shouldUpdate = YES;
    if (orderDetails) {
        UserModel *user = [AppInfo sharedInfo].user;
        float gratuity = [gratuity_rateTF.text floatValue];
        float sub_total = [[sub_total_lbl.text stringByReplacingOccurrencesOfString:@"$" withString:@""] floatValue];
        if (sub_total > 0) {
            gratuity_rate = (gratuity*100.0)/sub_total;
        }
        else {
            if (gratuity > 0.0) {
                gratuity_rate = 100.0;
            }
            else {
                gratuity_rate = 0.0;
            }
        }
        [orderDetails setObject:[NSNumber numberWithFloat:[gratuity_rateTF.text floatValue]] forKey:@"Gratuity"];
        if (gratuity_rate == user.gratuity_rate) {
            [orderDetails setObject:[NSNumber numberWithInt:0] forKey:@"IsCustomGratuity"];
        }
        else {
            [orderDetails setObject:[NSNumber numberWithInt:1] forKey:@"IsCustomGratuity"];
        }
        [self setOrderCost];
    }
}

-(void)requestForUpdateParkedOrder {
    
    [SVProgressHUD showWithStatus:@"Updating parked order..." maskType:SVProgressHUDMaskTypeGradient];
    isUpdateRequest = YES;
    isGetRequest = NO;
//    RestaurantModel *restaurantModel = [orderDetails objectForKey:@"restaurantModel"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    NSDate *date = [orderDetails objectForKey:@"parkedOrderDate"];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:[AppInfo sharedInfo].user.tokenID forKey:@"TokenId"];
    [params setObject:[AppInfo sharedInfo].user.loginID forKey:@"LoginId"];
    [params setObject:[orderDetails objectForKey:@"Id"] forKey:@"ParkedOrderId"];
    double gratuity = [[gratuity_rateTF.text stringByReplacingOccurrencesOfString:@"$" withString:@""] floatValue];
    int isCustomGratuity = [[orderDetails objectForKey:@"IsCustomGratuity"] intValue];
    [params setObject:[NSNumber numberWithDouble:gratuity] forKey:@"Gratuity"];
    [params setObject:[NSNumber numberWithInt:isCustomGratuity] forKey:@"IsCustomGratuity"];
    float totalCost = [[total_cost_lbl.text stringByReplacingOccurrencesOfString:@"$" withString:@""] floatValue];
    [params setObject:[NSNumber numberWithFloat:totalCost] forKey:@"TotalCost"];
    [params setObject:[NSNumber numberWithInt:2] forKey:@"Status"];
    [params setObject:[NSNumber numberWithInt:[party_sizeTF.text intValue]] forKey:@"PartySize"];
    if ([orderDetails objectForKey:@"Notes"] && (NSNull*)[orderDetails objectForKey:@"Notes"] != [NSNull null]) {
        [params setObject:[orderDetails objectForKey:@"Notes"] forKey:@"Notes"];
    }
    [params setObject:[formatter stringFromDate:date] forKey:@"FulfillmentDate"];
    NSMutableArray *list = [NSMutableArray array];
    for (int i=0; i<[foodItemsList count]; i++) {
        NSDictionary *food = [foodItemsList objectAtIndex:i];
        NSMutableDictionary *foodItem = [NSMutableDictionary dictionary];
        if ([food objectForKey:@"Id"]) {
            [foodItem setObject:[food objectForKey:@"Id"] forKey:@"FoodItemId"];
        }
        if ([food objectForKey:@"FoodOptionChoiceId"] && (NSNull*)[food objectForKey:@"FoodOptionChoiceId"] != [NSNull null]) {
            [foodItem setObject:[food objectForKey:@"FoodOptionChoiceId"] forKey:@"FoodOptionChoiceId"];
        }
        if ([food objectForKey:@"Price"]) {
            [foodItem setObject:[food objectForKey:@"Price"] forKey:@"Price"];
        }
        if ([food objectForKey:@"Quantity"]) {
            [foodItem setObject:[food objectForKey:@"Quantity"] forKey:@"Quantity"];
        }
        [list addObject:foodItem];
    }
    [params setObject:list forKey:@"ParkedOrderItems"];
    [HTTPRequest requestPostWithMethod:@"RestaurantService/ParkedOrder/Update" Params:params andDelegate:self];
}

-(void)requestForGettingParkedOrder {
    
    [SVProgressHUD showWithStatus:@"Updating parked order..." maskType:SVProgressHUDMaskTypeGradient];
    isGetRequest = YES;
    NSDictionary *params = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[AppInfo sharedInfo].user.tokenID, [orderDetails objectForKey:@"Id"], nil] forKeys:[NSArray arrayWithObjects:@"tokenid", @"id", nil]];
    [HTTPRequest requestGetWithMethod:@"RestaurantService/ParkedOrder" Params:params andDelegate:self];
}

-(void)requestForDeleteParkedOrder {
    
    [SVProgressHUD showWithStatus:@"Deleting parked order..." maskType:SVProgressHUDMaskTypeGradient];
    isUpdateRequest = NO;
    isGetRequest = NO;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:[AppInfo sharedInfo].user.tokenID forKey:@"TokenId"];
    [params setObject:[AppInfo sharedInfo].user.loginID forKey:@"LoginId"];
    [params setObject:[orderDetails objectForKey:@"Id"] forKey:@"ParkedOrderId"];
    [params setObject:[NSNumber numberWithInt:7] forKey:@"Status"];
    [HTTPRequest requestPostWithMethod:@"RestaurantService/ParkedOrder/Update" Params:params andDelegate:self];
}

-(void)showPickUpTimeAlertView {
    
    [self.view setUserInteractionEnabled:NO];
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEE, MMM dd"];
    order_date_lbl.text = [formatter stringFromDate:date];
    [pickUp_timePicker selectRow:0 inComponent:0 animated:NO];
    pickUp_timeTF.text = [pickUpTimeList objectAtIndex:0];
    
    pickup_time_alert_view.alpha = 0.0;
    pickup_time_alert_view.center = self.view.center;
    [UIView animateWithDuration:0.3 animations:^{
        pickup_time_alert_view.alpha = 1.0;
    }completion:^(BOOL finished) {
        if (finished) {
            [self.view setUserInteractionEnabled:YES];
        }
    }];
}

-(void)hidePickUpTimeAlertView {
    
    [self.view setUserInteractionEnabled:NO];
    CGRect frame = pickup_time_alert_view.frame;
    frame.origin.y = self.view.frame.size.height;
    [UIView animateWithDuration:0.3 animations:^{
        pickup_time_alert_view.alpha = 0.0;
    }completion:^(BOOL finished) {
        if (finished) {
            pickup_time_alert_view.frame = frame;
            [self.view setUserInteractionEnabled:YES];
        }
    }];
}

#pragma mark
#pragma mark Logical Methods

-(void)setFoodItemsList:(NSArray*)foodItems {
    
    if (!foodItemsList) {
        foodItemsList = [NSMutableArray array];
    }
    if (!selectedItems) {
        selectedItems = [NSMutableArray array];
    }
    if (foodItems) {
        [foodItemsList removeAllObjects];
        [selectedItems removeAllObjects];
        [foodItemsList addObjectsFromArray:foodItems];
        for (int i=0; i<[foodItemsList count]; i++) {
            [selectedItems addObject:[NSNumber numberWithBool:NO]];
        }
    }
}

-(void)setOrderDetails:(NSDictionary*)details {
    
    if (!orderDetails) {
        orderDetails = [NSMutableDictionary dictionary];
    }
    if (details) {
        [orderDetails removeAllObjects];
        [orderDetails addEntriesFromDictionary:details];
    }
}

-(void)selectFoodItemAtIndex:(NSInteger)index Selected:(BOOL)isSelected {
    
    if (index >= 0 && index < [selectedItems count]) {
        [selectedItems replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:isSelected]];
        [orderTable reloadData];
    }
}

#pragma mark
#pragma mark IBAction Methods

-(IBAction)updateOrderAction:(id)sender {
    
    [self requestForUpdateParkedOrder];
}

-(IBAction)deleteOrderAction:(id)sender {
    
    NSMutableArray *deletedObjects = [NSMutableArray array];
    for (int i=0; i<[selectedItems count]; i++) {
        if ([[selectedItems objectAtIndex:i] boolValue]) {
            [deletedObjects addObject:[foodItemsList objectAtIndex:i]];
        }
    }
    if ([deletedObjects count] > 0 && [deletedObjects count] == [foodItemsList count]) {
        
        delete_order_view.alpha = 0.0;
        [self.view addSubview:delete_order_view];
        delete_order_view.center = self.view.center;
        [UIView animateWithDuration:0.3 animations:^{
            delete_order_view.alpha = 1.0;
        }completion:^(BOOL finished){
            if (finished) {
                
            }
        }];
    }
    else {
        if ([deletedObjects count] > 0) {
            shouldUpdate = YES;
        }
        [foodItemsList removeObjectsInArray:deletedObjects];
        [selectedItems removeAllObjects];
        for (int i=0; i<[foodItemsList count]; i++) {
            [selectedItems addObject:[NSNumber numberWithBool:NO]];
        }
        
        [self setOrderCost];
        [orderTable reloadData];
//        if ([deletedObjects count] > 0) {
//            shouldGoBack = NO;
//            [self requestForUpdateParkedOrder];
//        }
    }
    [deletedObjects removeAllObjects];
}

-(IBAction)cancelDeleteOrderAction:(id)sender {

    [UIView animateWithDuration:0.3 animations:^{
        delete_order_view.alpha = 0.0;
    }completion:^(BOOL finished){
        if (finished) {
            [delete_order_view removeFromSuperview];
        }
    }];
}

-(IBAction)doneDeleteOrderAction:(id)sender {
    
    NSMutableArray *deletedObjects = [NSMutableArray array];
    for (int i=0; i<[selectedItems count]; i++) {
        if ([[selectedItems objectAtIndex:i] boolValue]) {
            [deletedObjects addObject:[foodItemsList objectAtIndex:i]];
        }
    }
    [foodItemsList removeObjectsInArray:deletedObjects];
    [deletedObjects removeAllObjects];
    [selectedItems removeAllObjects];
    for (int i=0; i<[foodItemsList count]; i++) {
        [selectedItems addObject:[NSNumber numberWithBool:NO]];
    }
    
    [self setOrderCost];
    [orderTable reloadData];
    [UIView animateWithDuration:0.3 animations:^{
        delete_order_view.alpha = 0.0;
    }completion:^(BOOL finished){
        if (finished) {
            [delete_order_view removeFromSuperview];
            [self requestForDeleteParkedOrder];
        }
    }];
}

-(IBAction)phoneButtonClick:(id)sender {
    
    RestaurantModel *restaurant = [orderDetails objectForKey:@"restaurantModel"];
    NSString *phoneNumber = [@"tel://" stringByAppendingString:restaurant.primaryPhone];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
}

-(IBAction)updateDateAction:(id)sender {
    
    shouldUpdate = YES;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/yyyy hh:mm a"];
    date_timeTF.text = [formatter stringFromDate:datePicker.date];
    if (orderDetails) {
        [orderDetails setObject:datePicker.date forKey:@"parkedOrderDate"];
    }
}

-(IBAction)doneToolbarAction:(id)sender {
    
    if ([toolBar_btn.title isEqualToString:DATE_STRING]) {
        [self updateDateAction:nil];
        [date_timeTF resignFirstResponder];
    }
    else if ([toolBar_btn.title isEqualToString:PARTY_SIZE_STRING]) {
        party_sizeTF.text = [NSString stringWithFormat:@"%i", (int)[partySizePicker selectedRowInComponent:0]+1];
        [party_sizeTF resignFirstResponder];
        if (orderDetails) {
            [orderDetails setObject:party_sizeTF.text forKey:@"PartySize"];
        }
    }
    else if ([toolBar_btn.title isEqualToString:PICKUP_TIME_STRING]) {
        [pickUp_timeTF resignFirstResponder];
    }
    else if ([toolBar_btn.title isEqualToString:GRATUITY_STRING]) {
        
        [self updateGratuity];
        [gratuity_rateTF resignFirstResponder];
        CGRect frame = orderTable.frame;
        frame.origin = CGPointMake(frame.origin.x, 44.0);
        [UIView animateWithDuration:0.3 animations:^{
            orderTable.frame = frame;
        }];
    }
}

-(IBAction)donePickUpTimeAction:(id)sender {

    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSInteger row = [pickUp_timePicker selectedRowInComponent:0]+1;
    NSTimeInterval interval = (row*15)*60;
    date = [date dateByAddingTimeInterval:interval];
    [formatter setDateFormat:@"MM/dd/yyyy hh:mm a"];
    date_timeTF.text = [formatter stringFromDate:date];
    if (orderDetails) {
        [orderDetails setObject:date forKey:@"parkedOrderDate"];
    }
    shouldUpdate = YES;
    [self hidePickUpTimeAlertView];
}

-(IBAction)cancelPickUpTimeAction:(id)sender {
    
    [self hidePickUpTimeAlertView];
}

-(IBAction)longPressGesture:(UILongPressGestureRecognizer*)sender {
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        UIButton *button = (UIButton*)[sender view];
        ButtonType type = button.tag;
        NSString *title = [AppInfo getButtonTitleOfType:type];
        CGSize size = [title sizeWithFont:button_title_lbl.font constrainedToSize:CGSizeMake(160.0, 25)];
        CGRect frame = CGRectMake(button.frame.origin.x, button.frame.origin.y+button.frame.size.height+15.0, size.width+20.0, 25.0);
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
#pragma mark UITableViewDataSource/UITableViewDelegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [foodItemsList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"POEditCellIdentifier";
    
    POEditCell *cell = (POEditCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"POEditCell" owner:self options:nil] objectAtIndex:0];
        cell.parentViewController = self;
    }
    
    NSDictionary *foodItem = [foodItemsList objectAtIndex:indexPath.row];
    cell.quantity_lbl.text = [NSString stringWithFormat:@"%i", [[foodItem objectForKey:@"Quantity"] intValue]];
    cell.price_lbl.text = [NSString stringWithFormat:@"$%.2f", [[foodItem objectForKey:@"Price"] doubleValue]];
    cell.title_lbl.text = [foodItem objectForKey:@"Name"];
    cell.check_btn.selected = [[selectedItems objectAtIndex:indexPath.row] boolValue];
    cell.check_btn.tag = indexPath.row;
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
    if (hasFoundNames && foodOptionNames.length > 0) {
        [foodOptionNames appendString:@")"];
    }
    cell.options_lbl.text = foodOptionNames;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *foodItem = [foodItemsList objectAtIndex:indexPath.row];
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:[foodItem objectForKey:@"Name"] message:@"Please enter quantity." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    quantityTF = [alertView textFieldAtIndex:0];
    quantityTF.keyboardType = UIKeyboardTypeNumberPad;
    quantityTF.tag = indexPath.row;
    quantityTF.text = [NSString stringWithFormat:@"%i", [[foodItem objectForKey:@"Quantity"] intValue]];
    alertView.tag = 1;
    [alertView show];
}

#pragma mark
#pragma mark UIPickerViewDelegate/UIPickerViewDataSource Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    if (pickerView == pickUp_timePicker) {
        return [pickUpTimeList count];
    }
    return 20;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    if (pickerView == pickUp_timePicker) {
        return [NSString stringWithFormat:@"%@", [pickUpTimeList objectAtIndex:row]];
    }
    return [NSString stringWithFormat:@"%i", row+1];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    shouldUpdate = YES;
    if (pickerView == pickUp_timePicker) {
        pickUp_timeTF.text = [NSString stringWithFormat:@"%@", [pickUpTimeList objectAtIndex:row]];
    }
    else {
        party_sizeTF.text = [NSString stringWithFormat:@"%i", row+1];
        if (orderDetails) {
            [orderDetails setObject:party_sizeTF.text forKey:@"PartySize"];
        }
    }
}

#pragma mark
#pragma mark UITextFieldDelegate Methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {

    shouldUpdate = YES;
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    if (textField == date_timeTF) {
        RestaurantModel *restaurant = [orderDetails objectForKey:@"restaurantModel"];
        if (restaurant.isPayNow) {
            [self showPickUpTimeAlertView];
            return NO;
        }
        else {
            [toolBar_btn setTitle:DATE_STRING];
            textField.inputView = datePicker;
            NSDate *date = [orderDetails objectForKey:@"parkedOrderDate"];
            [datePicker setDate:date animated:NO];
        }
    }
    else if (textField == pickUp_timeTF) {
        [toolBar_btn setTitle:PICKUP_TIME_STRING];
        textField.inputView = pickUp_timePicker;
    }
    else if (textField == party_sizeTF) {
        [toolBar_btn setTitle:PARTY_SIZE_STRING];
        textField.inputView = partySizePicker;
        [partySizePicker selectRow:[party_sizeTF.text integerValue]-1 inComponent:0 animated:NO];
    }
    else if (textField == gratuity_rateTF) {
        [toolBar_btn setTitle:GRATUITY_STRING];
        gratuity_rateTF.text = [gratuity_rateTF.text stringByReplacingOccurrencesOfString:@"$" withString:@""];
        CGRect frame = orderTable.frame;
        if ([UIScreen mainScreen].bounds.size.height > 480.0) {
            frame.origin = CGPointMake(frame.origin.x, -130.0);
        }
        else {
            frame.origin = CGPointMake(frame.origin.x, -200.0);
        }
        [UIView animateWithDuration:0.3 animations:^{
            orderTable.frame = frame;
        }];
    }
    textField.inputAccessoryView = toolBar;
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == party_sizeTF) {
        party_sizeTF.text = [NSString stringWithFormat:@"%i", (int)[partySizePicker selectedRowInComponent:0]+1];
        if (orderDetails) {
            [orderDetails setObject:party_sizeTF.text forKey:@"PartySize"];
        }
    }
    else if (textField == date_timeTF) {
        [self updateDateAction:nil];
    }
    else if (textField == pickUp_timeTF) {
        [textField resignFirstResponder];
    }
    else if (textField == gratuity_rateTF) {
        if (![gratuity_rateTF.text hasPrefix:@"$"]) {
            gratuity_rateTF.text = [NSString stringWithFormat:@"$%@", gratuity_rateTF.text];
        }
        CGRect frame = orderTable.frame;
        frame.origin = CGPointMake(frame.origin.x, 44.0);
        [UIView animateWithDuration:0.3 animations:^{
            orderTable.frame = frame;
        }];
    }
    
    return YES;
}

#pragma mark
#pragma mark HTTPRequestDelegate Methods

-(void)didFinishRequest:(HTTPRequest*)httpRequest withData:(id)data {
    
    [SVProgressHUD dismiss];
    if (data && [data isKindOfClass:[NSDictionary class]] && [data objectForKey:@"IsSuccessful"] && [[data objectForKey:@"IsSuccessful"] boolValue]) {
        
        if (isGetRequest) {
            NSDictionary *parkedOrder = [[data objectForKey:@"List"] firstObject];
            [[AppInfo sharedInfo].user updateParkedOrder:parkedOrder];
            if (parentController && [parentController respondsToSelector:@selector(updateFoodItems:andParkedOrderDetails:)]) {
                [parentController updateFoodItems:foodItemsList andParkedOrderDetails:orderDetails];
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
        else {
            if (isUpdateRequest) {
                [self requestForGettingParkedOrder];
            }
            else {
                [SVProgressHUD showSuccessWithStatus:@"Order deleted successfully."];
                [[AppInfo sharedInfo].user deleteParkedOrderWithID:[orderDetails objectForKey:@"Id"]];
                UIViewController *viewController = Nil;
                for (UIViewController *vc in self.navigationController.viewControllers) {
                    if ([vc isKindOfClass:[PageSwipeController class]] || [vc isKindOfClass:[ParkedOrderViewController class]]) {
                        viewController = vc;
                        break;
                    }
                }
                if (viewController) {
                    [self.navigationController popToViewController:viewController animated:YES];
                }
                else {
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }
        }
    }
}

-(void)didFailRequest:(HTTPRequest*)httpRequest withError:(NSString*)errorMessage {
    
    [SVProgressHUD dismiss];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark
#pragma mark UIALertViewDelegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == 1) {
        if (buttonIndex == 1) {
            NSMutableDictionary *foodItem = [NSMutableDictionary dictionaryWithDictionary:[foodItemsList objectAtIndex:quantityTF.tag]];
            if (quantityTF.text.length > 0) {
                [foodItem setObject:[NSNumber numberWithInt:quantityTF.text.intValue] forKey:@"Quantity"];
                [foodItemsList replaceObjectAtIndex:quantityTF.tag withObject:foodItem];
                [self setOrderCost];
                [orderTable reloadData];
            }
        }
    }
    else {
        [self requestForUpdateParkedOrder];
    }
}

@end
