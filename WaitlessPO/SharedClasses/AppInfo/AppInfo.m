//
//  AppInfo.m
//  WaitlessPO
//
//  Created by Amad Khilji on 01/11/2013.
//  Copyright (c) 2013 Amad Khilji. All rights reserved.
//

#import "AppInfo.h"
#import "UserModel.h"
#import "RestaurantModel.h"
#import "HTTPRequest.h"
#import <FacebookSDK/FacebookSDK.h>
//#import <GooglePlus/GooglePlus.h>

@implementation AppInfo

@synthesize sessionType;
@synthesize isPaymentMethodVisible;
@synthesize user;
@synthesize fbUserData;
@synthesize restaurantsList, yelpRestaurantsList;

static AppInfo *singletonInstance;
+(AppInfo*)sharedInfo {
    
    @synchronized ([AppInfo class]) {
        
        if (!singletonInstance) {
            singletonInstance = [[AppInfo alloc] init];
        }
    }
    
    return singletonInstance;
}

+(id)alloc {
    
    @synchronized ([AppInfo class]) {
        
        NSAssert(singletonInstance == nil, @"Error, trying to allocate another instance of singleton class.");
        return [super alloc];
    }
}

-(id)init {
    
    if (self = [super init]) {
        
        user = nil;
        sessionType = SessionTypeNone;
        isPaymentMethodVisible = NO;
        restaurantsList = [NSMutableArray array];
        yelpRestaurantsList = [NSMutableArray array];
    }
    
    return self;
}

-(void)setUserModel:(UserModel*)_user {

    user = _user;
}

-(void)setRestaurantList:(NSArray*)list {
    
    if ([restaurantsList count] > 0) {
        [restaurantsList removeAllObjects];
    }
    [restaurantsList addObjectsFromArray:list];
    if ([restaurantsList count] > 0) {
        [restaurantsList sortUsingComparator:^NSComparisonResult(id obj1, id obj2){
            RestaurantModel *restaurant1 = (RestaurantModel*)obj1;
            RestaurantModel *restaurant2 = (RestaurantModel*)obj2;
            if (restaurant1.distance > restaurant2.distance) {
                return NSOrderedDescending;
            }
            else if (restaurant1.distance < restaurant2.distance) {
                return NSOrderedAscending;
            }
            else {
                return NSOrderedSame;
            }
        }];
    }
}

-(void)setYelpRestaurantList:(NSArray*)list {
 
    if ([yelpRestaurantsList count] > 0) {
        [yelpRestaurantsList removeAllObjects];
    }
    [yelpRestaurantsList addObjectsFromArray:list];
    if ([yelpRestaurantsList count] > 0) {
        [yelpRestaurantsList sortUsingComparator:^NSComparisonResult(id obj1, id obj2){
            NSDictionary *restaurant1 = (NSDictionary*)obj1;
            NSDictionary *restaurant2 = (NSDictionary*)obj2;
            float distance1 = [[restaurant1 objectForKey:@"distance"] floatValue];
            float distance2 = [[restaurant2 objectForKey:@"distance"] floatValue];
            if (distance1 > distance2) {
                return NSOrderedDescending;
            }
            else if (distance1 < distance2) {
                return NSOrderedAscending;
            }
            else {
                return NSOrderedSame;
            }
        }];
    }
}

-(NSString*)getRestaurantNameFromID:(NSString*)rest_id {
    
    NSString *name = @"";
    if (rest_id && rest_id.length > 0) {
        for (int i=0; i<[restaurantsList count]; i++) {
            RestaurantModel *restaurant = [restaurantsList objectAtIndex:i];
            if ([restaurant.restaurantID isEqualToString:rest_id]) {
                name = [NSString stringWithString:restaurant.restaurantName];
                break;
            }
        }
        if (name.length == 0) {
            for (int j=0; j<[user.restaurantList count]; j++) {
                RestaurantModel *restaurant = [user.restaurantList objectAtIndex:j];
                if ([restaurant.restaurantID isEqualToString:rest_id]) {
                    name = [NSString stringWithString:restaurant.restaurantName];
                    break;
                }
            }
        }
    }
    
    return name;
}

-(RestaurantModel*)getRestaurantModelFromID:(NSString*)rest_id {
    
    RestaurantModel *restaurantModel = Nil;
    if (rest_id && rest_id.length > 0) {
        for (int i=0; i<[restaurantsList count]; i++) {
            RestaurantModel *restaurant = [restaurantsList objectAtIndex:i];
            if ([restaurant.restaurantID isEqualToString:rest_id]) {
                restaurantModel = restaurant;
                break;
            }
        }
        if (!restaurantModel) {
            for (int j=0; j<[user.restaurantList count]; j++) {
                RestaurantModel *restaurant = [user.restaurantList objectAtIndex:j];
                if ([restaurant.restaurantID isEqualToString:rest_id]) {
                    restaurantModel = restaurant;
                    break;
                }
            }
        }
    }
    
    return restaurantModel;
}

-(NSArray*)getPromotionListWithRestaurantID:(NSString*)rest_id {
    
    NSMutableArray *list = [NSMutableArray array];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/yyyy"];
    if (rest_id && user && user.promotionList) {
        for (int i=0; i<[user.promotionList count]; i++) {
            NSDictionary *promotion = [user.promotionList objectAtIndex:i];
            if ([[promotion objectForKey:@"RestaurantId"] isEqualToString:rest_id]) {
                [list addObject:promotion];
            }
        }
    }
    [list sortUsingComparator:^NSComparisonResult(id obj1, id obj2){
        NSDictionary *promotion1 = obj1;
        NSDictionary *promotion2 = obj2;
        NSDate *date1 = [formatter dateFromString:[promotion1 objectForKey:@"EndDate"]];
        NSDate *date2 = [formatter dateFromString:[promotion2 objectForKey:@"EndDate"]];
        NSDate *date3 = [NSDate date];
        NSTimeInterval timeInterval1 = [date1 timeIntervalSinceDate:date3];
        NSTimeInterval timeInterval2 = [date2 timeIntervalSinceDate:date3];
        if (timeInterval1 > timeInterval2) {
            return NSOrderedDescending;
        }
        else if (timeInterval1 < timeInterval2) {
            return NSOrderedAscending;
        }
        else {
            return NSOrderedSame;
        }
    }];
    return list;
}

-(BOOL)isLogin {
    
    if (self.sessionType == SessionTypeNone || !user) {
        return NO;
    }
    return YES;
}

-(void)loadUserSession {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger active_session = [defaults integerForKey:ACTIVE_SESSION_TYPE];
    if (active_session == SessionTypeFacebook || active_session == SessionTypeGooglePlus || active_session == SessionTypeNone || active_session == SessionTypeWaitless) {
        sessionType = (SessionType)active_session;
    }
}

-(void)saveUserSession {
    
    if (user) {
        [user saveUser];
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:sessionType forKey:ACTIVE_SESSION_TYPE];
    [defaults synchronize];
}

-(void)logoutUser {
    
    if (sessionType == SessionTypeFacebook) {
        [[FBSession activeSession] close];
    }
    else if (sessionType == SessionTypeGooglePlus) {
//        [[GPPSignIn sharedInstance] signOut];
    }
    [user deleteUser];
    sessionType = SessionTypeNone;
    user = Nil;
    fbUserData = Nil;
    [restaurantsList removeAllObjects];
    [yelpRestaurantsList removeAllObjects];
    [self saveUserSession];
    [self setSocialPost:NO];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setFloat:18.0 forKey:GRATUITY_RATE];
    [defaults setBool:NO forKey:PASSCODE];
    [defaults setBool:NO forKey:NOTIFY_ME];
    [defaults removeObjectForKey:PASSCODE_VALUE];
    [defaults removeObjectForKey:EMAIL];
    [defaults removeObjectForKey:PASSWORD];
    [defaults synchronize];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [[UIApplication sharedApplication] unregisterForRemoteNotifications];
}

-(BOOL)shouldShowPaymentSignUp {
    
    BOOL shouldShow = NO, hasFound = NO;
    if ([self isLogin]) {
        for (int i=0; i<[user.authenticationList count]; i++) {
            NSDictionary *paymentMethod = [user.authenticationList objectAtIndex:i];
            NSString *provider = [[paymentMethod objectForKey:@"Provider"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            if (provider && (NSNull*)provider != [NSNull null] && ([provider isEqualToString:DWOLLA_PAYMENT] || [provider isEqualToString:PAYPAL_PAYMENT] || [provider isEqualToString:MASTER_CARD_PAYMENT] || [provider isEqualToString:VISA_PAYMENT] || [provider isEqualToString:AMERICAN_EXPRESS_PAYMENT] || [provider isEqualToString:AMERICAN_EXPRESS_PAYMENT_] || [provider isEqualToString:DISCOVER_PAYMENT] || [provider isEqualToString:BRAINTREE_PAYMENT])) {
                hasFound = YES;
                shouldShow = NO;
                break;
            }
        }
        if (!hasFound) {
            shouldShow = !isPaymentMethodVisible;
        }
    }
    return shouldShow;
}

-(BOOL)isPaymentMethodAvailable {
    
    BOOL isAvailable = NO;
    if ([self isLogin]) {
        for (int i=0; i<[user.authenticationList count]; i++) {
            NSDictionary *paymentMethod = [user.authenticationList objectAtIndex:i];
            NSString *provider = [[paymentMethod objectForKey:@"Provider"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            if (provider && (NSNull*)provider != [NSNull null] && ([provider isEqualToString:DWOLLA_PAYMENT] || [provider isEqualToString:PAYPAL_PAYMENT] || [provider isEqualToString:MASTER_CARD_PAYMENT] || [provider isEqualToString:VISA_PAYMENT] || [provider isEqualToString:AMERICAN_EXPRESS_PAYMENT] || [provider isEqualToString:AMERICAN_EXPRESS_PAYMENT_] || [provider isEqualToString:DISCOVER_PAYMENT] || [provider isEqualToString:BRAINTREE_PAYMENT])) {
                isAvailable = YES;
                break;
            }
        }
    }
    return isAvailable;
}

-(void)requestForDeviceRegistration {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *device_token = [NSString stringWithFormat:@"%@", [defaults objectForKey:DEVICE_TOKEN]];
    NSDictionary *params = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:user.userID, user.tokenID, device_token, [NSNumber numberWithInt:2], nil] forKeys:[NSArray arrayWithObjects:@"userId", @"tokenId", @"registrationId", @"deviceType", nil]];
    [HTTPRequest requestPostWithMethod:@"MembershipService/UserRegistration/Insert" Params:params andDelegate:nil];
}

-(void)setSocialPost:(BOOL)isPosted {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:isPosted forKey:SOCIAL_STATUS_POST];
    [defaults synchronize];
}
    
-(BOOL)hasPostedToSocial {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:SOCIAL_STATUS_POST];
}

#pragma mark
#pragma mark Static Methods

+(BOOL)isValidEmail:(NSString*)emailString {
    
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:emailString];
}

+(BOOL)isValidPassword:(NSString*)passwordString {
    
    NSString *passwordRegex = @"^(?=.*\\d)(?=.*[a-z])(?=.*[A-Z]).{8,15}";
    NSPredicate *passwordTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", passwordRegex];
    if (passwordString.length < 8) {
        return NO;
    }
    else {
        return [passwordTest evaluateWithObject:passwordString];
    }
//    if ([passwordString rangeOfCharacterFromSet:[NSCharacterSet uppercaseLetterCharacterSet]].location == NSNotFound) {
//        return NO;
//    }
//    if ([passwordString rangeOfCharacterFromSet:[NSCharacterSet alphanumericCharacterSet]].location == NSNotFound) {
//        return NO;
//    }

//    return YES;
}

+(NSInteger)age:(NSDate *)dateOfBirth {
    
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponentsNow = [calendar components:unitFlags fromDate:[NSDate date]];
    NSDateComponents *dateComponentsBirth = [calendar components:unitFlags fromDate:dateOfBirth];
    
    if (([dateComponentsNow month] < [dateComponentsBirth month]) || (([dateComponentsNow month] == [dateComponentsBirth month]) && ([dateComponentsNow day] < [dateComponentsBirth day])))
    {
        return [dateComponentsNow year] - [dateComponentsBirth year] - 1;
        
    } else {
        
        return [dateComponentsNow year] - [dateComponentsBirth year];
    }
}

+(NSDate*)getDateFromDateIntervalString:(NSString*)dateString {
    
    int sign = 0;
    int hours = 0;
    NSTimeInterval timeInterval = 0.0;
    NSString *tmpStr = Nil;
    if (dateString) {
        NSArray *list = [dateString componentsSeparatedByString:@"("];
        if (list && [list count] > 1) {
            if ([[list objectAtIndex:1] rangeOfString:@"-"].location != NSNotFound) {
                sign = -1;
                list = [[list objectAtIndex:1] componentsSeparatedByString:@"-"];
            }
            else if ([[list objectAtIndex:1] rangeOfString:@"+"].location != NSNotFound) {
                sign = 1;
                list = [[list objectAtIndex:1] componentsSeparatedByString:@"+"];
            }
            else {
                list = [[list objectAtIndex:1] componentsSeparatedByString:@")"];
            }
            if (list && [list count] > 0) {
                tmpStr = [list objectAtIndex:0];
                if (sign != 0) {
                    hours = [[[list objectAtIndex:1] substringToIndex:2] intValue];
                }
            }
        }
    }
    if (tmpStr) {
        timeInterval = [tmpStr doubleValue]/1000;
    }
    
    NSInteger timeOffset = (sign*hours*3600);
    NSTimeZone* localTimeZone = [NSTimeZone localTimeZone];
    NSInteger secondsOffset = [localTimeZone secondsFromGMTForDate:[NSDate date]];
    secondsOffset *= -1;
    secondsOffset += timeOffset;
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    date = [date dateByAddingTimeInterval:secondsOffset];
    
    return date;
}

+(NSString*)getAppName {
    
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
}

+(NSString*)getButtonTitleOfType:(ButtonType)type {
    
    NSMutableString *title = [NSMutableString string];
    if (type == ButtonTypeReviewOrder) {
        [title appendString:@"Review"];
    }
    else if (type == ButtonTypeDeleteOrder) {
        [title appendString:@"Delete Order"];
    }
    else if (type == ButtonTypeDeleteItem) {
        [title appendString:@"Delete Item"];
    }
    else if (type == ButtonTypeFavorite) {
        [title appendString:@"Favorite"];
    }
    else if (type == ButtonTypeAddItems) {
        [title appendString:@"Add Food Items"];
    }
    else if (type == ButtonTypeEditOrder) {
        [title appendString:@"Edit Order"];
    }
    else if (type == ButtonTypeUpdateOrder) {
        [title appendString:@"Update Order"];
    }
    else if (type == ButtonTypePayNow) {
        [title appendString:@"Pay Now"];
    }
    else if (type == ButtonTypeDirections) {
        [title appendString:@"Directions"];
    }
    else if (type == ButtonTypeShare) {
        [title appendString:@"Share"];
    }
    return title;
}

@end
