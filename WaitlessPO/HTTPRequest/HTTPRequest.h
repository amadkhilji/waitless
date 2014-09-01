//
//  HTTPRequest.h
//  WaitlessPO
//
//  Created by Amad Khilji on 29/10/2013.
//  Copyright (c) 2013 Amad Khilji. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef enum {
    
    HTTPRequestTypeWaitless,
    HTTPRequestTypeYelp,
    HTTPRequestTypeDeviceRegistration,
    HTTPRequestTypeFacebookFindUser,
    HTTPRequestTypeFacebookSignUp,
    HTTPRequestTypeFacebookConnect,
    HTTPRequestTypeGooglePlusFindUser,
    HTTPRequestTypeGooglePlusSignUp,
    HTTPRequestTypeGooglePlusConnect,
    HTTPRequestTypeSettingsSendFeed,
    HTTPRequestTypeSettingsUpdateGratuity,
    HTTPRequestTypeSettingsUpdateNotifyMe,
    HTTPRequestTypeSettingsUpdatePasscode,
    HTTPRequestTypeGetDwollaAccountBalance,
    HTTPRequestTypeSendDwollaMoney,
    HTTPRequestTypeGetAddPromotion,
    HTTPRequestTypeGetUpdatePromotion,
    HTTPRequestTypeGetParkedOrder,
    HTTPRequestTypeUpdateParkedOrder,
    HTTPRequestTypeParkedOrder,
    HTTPRequestTypeBrainTreePayment
    
} HTTPRequestType;

@class HTTPRequest;

@protocol HTTPRequestDelegate <NSObject>

@optional

-(void)didStartRequest:(HTTPRequest*)httpRequest;
-(void)didFinishRequest:(HTTPRequest*)httpRequest withData:(id)data;
-(void)didFinishRequest:(HTTPRequest*)httpRequest withYelpData:(id)data;
-(void)didFailRequest:(HTTPRequest*)httpRequest withError:(NSString*)errorMessage;

@end

@interface HTTPRequest : NSObject <NSURLConnectionDelegate> {
    
    NSMutableData       *urlData;
    
    HTTPRequestType     requestType;
}

@property (atomic, assign) HTTPRequestType requestType;

+(void)requestGetWithMethod:(NSString*)methodName Params:(NSDictionary*)params andDelegate:(id<HTTPRequestDelegate>)requestDelegate;
+(void)requestPostWithMethod:(NSString*)methodName Params:(NSDictionary*)params andDelegate:(id<HTTPRequestDelegate>)requestDelegate;
+(void)requestGetWithMethod:(NSString*)methodName Params:(NSDictionary*)params andDelegate:(id<HTTPRequestDelegate>)requestDelegate andRequestType:(HTTPRequestType)requestType_;
+(void)requestPostWithMethod:(NSString*)methodName Params:(NSDictionary*)params andDelegate:(id<HTTPRequestDelegate>)requestDelegate andRequestType:(HTTPRequestType)requestType_;
+(void)getYelpRestaurantsWithCoordinates:(CLLocationCoordinate2D)coordinates andDelegate:(id<HTTPRequestDelegate>)requestDelegate;

@end
