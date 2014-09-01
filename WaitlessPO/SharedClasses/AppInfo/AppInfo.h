//
//  AppInfo.h
//  WaitlessPO
//
//  Created by Amad Khilji on 01/11/2013.
//  Copyright (c) 2013 Amad Khilji. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    
    SessionTypeNone,
    SessionTypeWaitless,
    SessionTypeFacebook,
    SessionTypeGooglePlus
    
} SessionType;

typedef enum {
    
    ParkedOrderStatusNew = 1,
    ParkedOrderStatusOpened = 2,        //display this
    ParkedOrderStatusPending = 3,
    ParkedOrderStatusFulfilled = 4,     //display this
    ParkedOrderStatusClosed = 5,        //display this
    ParkedOrderStatusRefunded = 6,
    ParkedOrderStatusDeleted = 7,
    ParkedOrderStatusVoided = 8
    
} ParkedOrderStatus;

typedef enum {
    
    PromotionTypeAdd = 500,
    PromotionTypeDelete = 501,
    PromotionTypeUpdate = 502
    
} PromotionType;

typedef enum {
    
    PaymentTypeDwolla,
    PaymentTypePaypal,
    PaymentTypeVisa,
    PaymentTypeMasterCard,
    PaymentTypeAmericanExpress,
    PaymentTypeDiscover,
    PaymentTypeNone
    
} PaymentType;

typedef enum {
    
    AccountRenewTypeDwolla,
    AccountRenewTypeBraintree
    
} AccountRenewType;

typedef enum {
    
    ButtonTypeReviewOrder = 1,
    ButtonTypeDeleteOrder = 2,
    ButtonTypeDeleteItem = 3,
    ButtonTypeFavorite = 4,
    ButtonTypeAddItems = 5,
    ButtonTypeEditOrder = 6,
    ButtonTypeUpdateOrder = 7,
    ButtonTypePayNow = 8,
    ButtonTypeDirections = 9,
    ButtonTypeShare = 10
    
} ButtonType;

@protocol PaymentDelegate <NSObject>

-(void)paymentSuccessful;
-(void)paymentFailed;

@end

@class UserModel;
@class RestaurantModel;

@interface AppInfo : NSObject

@property (nonatomic, readonly) UserModel *user;
@property (atomic, readonly)    NSMutableArray *restaurantsList, *yelpRestaurantsList;
@property (atomic, retain) NSDictionary *fbUserData;
@property (atomic, assign) SessionType sessionType;
@property (atomic, assign) BOOL isPaymentMethodVisible;

+(AppInfo*)sharedInfo;
+(BOOL)isValidEmail:(NSString*)emailString;
+(BOOL)isValidPassword:(NSString*)passwordString;
+(NSInteger)age:(NSDate *)dateOfBirth;
+(NSDate*)getDateFromDateIntervalString:(NSString*)dateString;
+(NSString*)getAppName;
+(NSString*)getButtonTitleOfType:(ButtonType)type;

-(void)setUserModel:(UserModel*)_user;
-(void)setRestaurantList:(NSArray*)list;
-(void)setYelpRestaurantList:(NSArray*)list;
-(NSString*)getRestaurantNameFromID:(NSString*)rest_id;
-(RestaurantModel*)getRestaurantModelFromID:(NSString*)rest_id;
-(NSArray*)getPromotionListWithRestaurantID:(NSString*)rest_id;

-(BOOL)isLogin;
-(void)loadUserSession;
-(void)saveUserSession;
-(void)logoutUser;
-(void)requestForDeviceRegistration;
-(BOOL)shouldShowPaymentSignUp;
-(BOOL)isPaymentMethodAvailable;
-(void)setSocialPost:(BOOL)isPosted;
-(BOOL)hasPostedToSocial;

@end
