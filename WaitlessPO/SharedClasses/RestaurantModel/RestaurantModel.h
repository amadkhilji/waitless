//
//  RestaurantModel.h
//  WaitlessPO
//
//  Created by Amad Khilji on 01/11/2013.
//  Copyright (c) 2013 Amad Khilji. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RestaurantModel : NSObject

@property (nonatomic, readonly) NSString *restaurantID, *restaurantName, *alternatePhone, *primaryPhone, *faxNumber, *description, *businessHours, *assetUrl, *assetId, *zipCode, *stateCode, *addressLine1, *addressLine2, *city;
@property (nonatomic, readonly) BOOL     isConvenienceFee, isPayNow;
@property (nonatomic, readonly) CGFloat  distance, gratuityRate, taxRate;
@property (nonatomic, readonly) UIImage  *iconImage;
@property (nonatomic, readonly) NSMutableArray *restaurantCategoryList, *foodCategoryList, *paymentList;

-(void)loadData:(NSDictionary*)data;

@end
