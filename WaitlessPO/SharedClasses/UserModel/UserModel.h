//
//  UserModel.h
//  WaitlessPO
//
//  Created by Amad Khilji on 01/11/2013.
//  Copyright (c) 2013 Amad Khilji. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserModel : NSObject

@property (nonatomic, readonly) NSString *userID, *firstName, *lastName, *emailAddress, *gender, *dateOfBirth, *city, *state, *zipCode;
@property (nonatomic, retain) NSString *loginID, *tokenID, *message;
@property (atomic, retain) NSMutableArray *authenticationList, *promotionList, *parkedOrderList, *restaurantList;

@property (nonatomic, assign) float gratuity_rate;
@property (nonatomic, assign) BOOL isSuccessful, isPasscodeActive, shouldNotifyMePromotions;

-(void)loadData:(NSDictionary*)data;
-(void)loadSettingsFromList:(NSArray*)settingsList;
-(void)addParkedOrder:(NSDictionary*)order;
-(void)updateParkedOrder:(NSDictionary*)order;
-(void)closeParkedOrderWithID:(NSString*)order_id;
-(void)deleteParkedOrderWithID:(NSString*)order_id;
-(void)addPromotion:(NSDictionary*)promotion;
-(void)updatePromotion:(NSDictionary*)promotion;
-(void)deletePromotionWithID:(NSString*)promotion_id;
-(NSMutableDictionary*)getParkedOrderWithID:(NSString*)order_id;
-(void)updateUserAuthentication:(NSDictionary*)oAuth;
-(void)sortRestaurantsList;
-(void)sortPromotionsList;
-(void)saveUser;
-(void)deleteUser;
-(NSString*)getBrainTreeCardType;
-(NSString*)getBrainTreeMaskedNumber;

@end
