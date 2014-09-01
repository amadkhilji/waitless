//
//  UserModel.m
//  WaitlessPO
//
//  Created by Amad Khilji on 01/11/2013.
//  Copyright (c) 2013 Amad Khilji. All rights reserved.
//

#import "UserModel.h"
#import "RestaurantModel.h"

@implementation UserModel

@synthesize loginID, tokenID, message, userID, firstName, lastName, emailAddress, gender, dateOfBirth, city, state, zipCode;
@synthesize authenticationList, promotionList, parkedOrderList, restaurantList;
@synthesize gratuity_rate;
@synthesize isSuccessful, isPasscodeActive, shouldNotifyMePromotions;

-(id)init {
    self = [super init];
    if (self) {
        loginID = [NSString string];
        tokenID = [NSString string];
        message = [NSString string];
        userID = [NSString string];
        firstName = [NSString string];
        lastName = [NSString string];
        emailAddress = [NSString string];
        gender = [NSString string];
        dateOfBirth = [NSString string];
        city = [NSString string];
        state = [NSString string];
        zipCode = [NSString string];
        isSuccessful = YES;
        authenticationList = [NSMutableArray array];
        promotionList = [NSMutableArray array];
        parkedOrderList = [NSMutableArray array];
        restaurantList = [NSMutableArray array];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([defaults floatForKey:GRATUITY_RATE]) {
            gratuity_rate = [defaults floatForKey:GRATUITY_RATE];
        }
        else {
            gratuity_rate = DEFAULT_GRATUITY;
            [defaults setFloat:gratuity_rate forKey:GRATUITY_RATE];
        }
        if ([defaults boolForKey:PASSCODE]) {
            isPasscodeActive = [defaults boolForKey:PASSCODE];
        }
        else {
            isPasscodeActive = NO;
            [defaults setBool:isPasscodeActive forKey:PASSCODE];
        }
        if ([defaults boolForKey:NOTIFY_ME]) {
            shouldNotifyMePromotions = [defaults boolForKey:NOTIFY_ME];
        }
        else {
            shouldNotifyMePromotions = NO;
            [defaults setBool:shouldNotifyMePromotions forKey:NOTIFY_ME];
        }
        [defaults synchronize];
    }
    
    return self;
}

-(void)loadData:(NSDictionary*)data {
    
    if (data) {
        if ([data objectForKey:@"Id"] && (NSNull*)[data objectForKey:@"Id"] != [NSNull null]) {
            userID = [data objectForKey:@"Id"];
        }
        if ([data objectForKey:@"FirstName"] && (NSNull*)[data objectForKey:@"FirstName"] != [NSNull null]) {
            firstName = [data objectForKey:@"FirstName"];
        }
        if ([data objectForKey:@"LastName"] && (NSNull*)[data objectForKey:@"LastName"] != [NSNull null]) {
            lastName = [data objectForKey:@"LastName"];
        }
        if ([data objectForKey:@"EmailAddress"] && (NSNull*)[data objectForKey:@"EmailAddress"] != [NSNull null]) {
            emailAddress = [data objectForKey:@"EmailAddress"];
        }
        if ([data objectForKey:@"Gender"] && (NSNull*)[data objectForKey:@"Gender"] != [NSNull null]) {
            gender = [data objectForKey:@"Gender"];
        }
        if ([data objectForKey:@"DateofBirth"] && (NSNull*)[data objectForKey:@"DateofBirth"] != [NSNull null]) {
            dateOfBirth = [data objectForKey:@"DateofBirth"];
        }
        if ([data objectForKey:@"City"] && (NSNull*)[data objectForKey:@"City"] != [NSNull null]) {
            city = [data objectForKey:@"City"];
        }
        if ([data objectForKey:@"State"] && (NSNull*)[data objectForKey:@"State"] != [NSNull null]) {
            state = [data objectForKey:@"State"];
        }
        if ([data objectForKey:@"ZipCode"] && (NSNull*)[data objectForKey:@"ZipCode"] != [NSNull null]) {
            zipCode = [data objectForKey:@"ZipCode"];
        }
    }
}

-(void)loadSettingsFromList:(NSArray*)settingsList {
    
    if (settingsList) {
        for (int i=0; i<[settingsList count]; i++) {
            NSDictionary *obj = [settingsList objectAtIndex:i];
            if (obj && [obj isKindOfClass:[NSDictionary class]] && [obj objectForKey:@"Type"]) {
                if ([[obj objectForKey:@"Type"] integerValue] == 100) {
                    gratuity_rate = [[obj objectForKey:@"Value"] floatValue];
                }
                else if ([[obj objectForKey:@"Type"] integerValue] == 200) {
                    shouldNotifyMePromotions = [[obj objectForKey:@"Value"] boolValue];
                }
                else if ([[obj objectForKey:@"Type"] integerValue] == 300) {
                    isPasscodeActive = [[obj objectForKey:@"Value"] boolValue];
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    if (isPasscodeActive && [defaults objectForKey:PASSCODE_VALUE] && [[defaults objectForKey:PASSCODE_VALUE] length] == 4) {
                        isPasscodeActive = YES;
                    }
                    else {
                        isPasscodeActive = NO;
                    }
                }
            }
        }
        [self saveUser];
    }
}

-(void)addParkedOrder:(NSDictionary*)order {
    
    [parkedOrderList addObject:[NSMutableDictionary dictionaryWithDictionary:order]];
}

-(void)updateParkedOrder:(NSDictionary*)order {
    
    BOOL isFound = NO;
    for (int i=0; i<[parkedOrderList count]; i++) {
        NSDictionary *parkedOrder = [parkedOrderList objectAtIndex:i];
        if ([[parkedOrder objectForKey:@"Id"] isEqualToString:[order objectForKey:@"Id"]]) {
            [parkedOrderList replaceObjectAtIndex:i withObject:[NSMutableDictionary dictionaryWithDictionary:order]];
            isFound = YES;
            break;
        }
    }
    if (!isFound) {
        [self addParkedOrder:order];
    }
}

-(void)closeParkedOrderWithID:(NSString*)order_id {
    
    for (int i=0; i<[parkedOrderList count]; i++) {
        NSDictionary *parkedOrder = [parkedOrderList objectAtIndex:i];
        if ([[parkedOrder objectForKey:@"Id"] isEqualToString:order_id]) {
            NSMutableDictionary *closedOrder = [NSMutableDictionary dictionaryWithDictionary:parkedOrder];
            [closedOrder setObject:[NSNumber numberWithInt:ParkedOrderStatusClosed] forKey:@"Status"];
            [parkedOrderList replaceObjectAtIndex:i withObject:closedOrder];
            break;
        }
    }
}

-(void)deleteParkedOrderWithID:(NSString*)order_id {
    
    for (int i=0; i<[parkedOrderList count]; i++) {
        NSDictionary *parkedOrder = [parkedOrderList objectAtIndex:i];
        if ([[parkedOrder objectForKey:@"Id"] isEqualToString:order_id]) {
            [parkedOrderList removeObjectAtIndex:i];
            break;
        }
    }
}

-(void)addPromotion:(NSDictionary*)promotion {
    
    if (promotion && [promotion isKindOfClass:[NSDictionary class]]) {
        for (int i=0; i<[promotionList count]; i++) {
            NSDictionary *promotionObj = [promotionList objectAtIndex:i];
            if ([[promotionObj objectForKey:@"Id"] isEqualToString:[promotion objectForKey:@"Id"]]) {
                [promotionList removeObjectAtIndex:i];
                break;
            }
        }
        [promotionList insertObject:promotion atIndex:0];
        [self sortPromotionsList];
    }
}

-(void)updatePromotion:(NSDictionary *)promotion {
    
    if (promotion && [promotion isKindOfClass:[NSDictionary class]]) {
        BOOL isAlreadyAdded = NO;
        for (int i=0; i<[promotionList count]; i++) {
            NSDictionary *promotionObj = [promotionList objectAtIndex:i];
            if ([[promotionObj objectForKey:@"Id"] isEqualToString:[promotion objectForKey:@"Id"]]) {
                [promotionList replaceObjectAtIndex:i withObject:promotion];
                isAlreadyAdded = YES;
                break;
            }
        }
        if (!isAlreadyAdded) {
            [promotionList insertObject:promotion atIndex:0];
        }
        [self sortPromotionsList];
    }
}

-(void)deletePromotionWithID:(NSString*)promotion_id {
    
    if (promotion_id && (NSNull*)promotion_id != [NSNull null] && [promotion_id isKindOfClass:[NSString class]]) {
        for (int i=0; i<[promotionList count]; i++) {
            NSDictionary *promotionObj = [promotionList objectAtIndex:i];
            if ([[promotionObj objectForKey:@"Id"] isEqualToString:promotion_id]) {
                [promotionList removeObjectAtIndex:i];
                break;
            }
        }
    }
}

-(NSMutableDictionary*)getParkedOrderWithID:(NSString*)order_id {
    
    NSMutableDictionary *parkedOrder = [NSMutableDictionary dictionary];
    for (int i=0; i<[parkedOrderList count]; i++) {
        NSDictionary *order = [parkedOrderList objectAtIndex:i];
        if ([[order objectForKey:@"Id"] isEqualToString:order_id]) {
            [parkedOrder addEntriesFromDictionary:order];
            break;
        }
    }
    return parkedOrder;
}

-(void)updateUserAuthentication:(NSDictionary*)oAuth {
    
    if (oAuth && [oAuth isKindOfClass:[NSDictionary class]]) {
        
        BOOL hasFound = NO;
        for (int i=0; i<[authenticationList count] && !hasFound; i++) {
            NSDictionary *obj = [authenticationList objectAtIndex:i];
            if ([obj objectForKey:@"Id"] && [oAuth objectForKey:@"Id"] && [[obj objectForKey:@"Id"] isEqualToString:[oAuth objectForKey:@"Id"]]) {
                hasFound = YES;
                [authenticationList replaceObjectAtIndex:i withObject:oAuth];
//                if (i > 0) {
//                    [authenticationList exchangeObjectAtIndex:i withObjectAtIndex:0];
//                }
            }
            else if ([obj objectForKey:@"CardType"] && (NSNull*)[obj objectForKey:@"CardType"] != [NSNull null]) {
                hasFound = YES;
                if ([[obj objectForKey:@"CardType"] isEqualToString:[oAuth objectForKey:@"CardType"]]) {
                    [authenticationList replaceObjectAtIndex:i withObject:oAuth];
                }
            }
        }
        if (!hasFound) {
            [authenticationList addObject:oAuth];
        }
    }
}

-(void)sortRestaurantsList {
    
    if ([restaurantList count] > 0) {
        [restaurantList sortUsingComparator:^NSComparisonResult(id obj1, id obj2){
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

-(void)sortPromotionsList {
    
    if ([promotionList count] > 0) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MM/dd/yyyy"];
        [promotionList sortUsingComparator:^NSComparisonResult(id obj1, id obj2){
            NSDictionary *promotion1 = obj1;
            NSDictionary *promotion2 = obj2;
            NSDate *date1 = [formatter dateFromString:[promotion1 objectForKey:@"EndDate"]];
            NSDate *date2 = [formatter dateFromString:[promotion2 objectForKey:@"EndDate"]];
            if ([date1 timeIntervalSince1970] > [date2 timeIntervalSince1970]) {
                return NSOrderedAscending;
            }
            else if ([date1 timeIntervalSince1970] < [date2 timeIntervalSince1970]) {
                return NSOrderedDescending;
            }
            else {
                return NSOrderedSame;
            }
        }];
    }
}

-(NSString*)getBrainTreeCardType {

    NSString *cardType = @"";
    for (int i=0; i<[authenticationList count]; i++) {
        NSDictionary *paymentMethod = [authenticationList objectAtIndex:i];
        if (paymentMethod && [paymentMethod objectForKey:@"Provider"] && (NSNull*)[paymentMethod objectForKey:@"Provider"] != [NSNull null]) {
            if ([[paymentMethod objectForKey:@"Provider"] isEqualToString:BRAINTREE_PAYMENT] && [paymentMethod objectForKey:@"CardType"] && (NSNull*)[paymentMethod objectForKey:@"CardType"] != [NSNull null]) {
                cardType = [NSString stringWithFormat:@"%@", [paymentMethod objectForKey:@"CardType"]];
                break;
            }
        }
    }
    return cardType;
}

-(NSString*)getBrainTreeMaskedNumber {
    
    NSString *maskedNumber = @"";
    for (int i=0; i<[authenticationList count]; i++) {
        NSDictionary *paymentMethod = [authenticationList objectAtIndex:i];
        if (paymentMethod && [paymentMethod objectForKey:@"Provider"] && (NSNull*)[paymentMethod objectForKey:@"Provider"] != [NSNull null]) {
            if ([[paymentMethod objectForKey:@"Provider"] isEqualToString:BRAINTREE_PAYMENT] && [paymentMethod objectForKey:@"OAuthToken"] && (NSNull*)[paymentMethod objectForKey:@"OAuthToken"] != [NSNull null]) {
                maskedNumber = [NSString stringWithFormat:@"%@", [paymentMethod objectForKey:@"OAuthToken"]];
                break;
            }
        }
    }
    return maskedNumber;
}

-(void)saveUser {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setFloat:gratuity_rate forKey:GRATUITY_RATE];
    [defaults setBool:isPasscodeActive forKey:PASSCODE];
    [defaults setBool:shouldNotifyMePromotions forKey:NOTIFY_ME];
    if (!isPasscodeActive) {
        [defaults removeObjectForKey:PASSCODE_VALUE];
    }
    [defaults synchronize];
}

-(void)deleteUser {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setFloat:18.0 forKey:GRATUITY_RATE];
    [defaults setBool:NO forKey:PASSCODE];
    [defaults setBool:NO forKey:NOTIFY_ME];
    [defaults removeObjectForKey:PASSCODE_VALUE];
    [defaults removeObjectForKey:EMAIL];
    [defaults removeObjectForKey:PASSWORD];
    [defaults synchronize];
}

@end
