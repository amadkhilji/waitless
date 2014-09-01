//
//  RestaurantModel.m
//  WaitlessPO
//
//  Created by Amad Khilji on 01/11/2013.
//  Copyright (c) 2013 Amad Khilji. All rights reserved.
//

#import "RestaurantModel.h"

@interface RestaurantModel ()

-(void)downlaodIconInBackground;

@end

@implementation RestaurantModel

@synthesize restaurantID, restaurantName, alternatePhone, primaryPhone, faxNumber, description, businessHours, assetUrl, assetId, zipCode, stateCode, addressLine1, addressLine2, city;
@synthesize isConvenienceFee, isPayNow;
@synthesize distance, gratuityRate, taxRate;
@synthesize iconImage;
@synthesize restaurantCategoryList, foodCategoryList, paymentList;

-(id)init {
    self = [super init];
    if (self) {
        restaurantID = [NSString string];
        restaurantName = [NSString string];
        alternatePhone = [NSString string];
        primaryPhone = [NSString string];
        faxNumber = [NSString string];
        description = [NSString string];
        businessHours = [NSString string];
        assetId = [NSString string];
        assetUrl = [NSString string];
        zipCode = [NSString string];
        stateCode = [NSString string];
        addressLine1 = [NSString string];
        addressLine2 = [NSString string];
        city = [NSString string];
        distance = 0.0;
        gratuityRate = 0.0;
        taxRate = 0.0;
        isConvenienceFee = NO;
        isPayNow = NO;
        restaurantCategoryList = [NSMutableArray array];
        foodCategoryList = [NSMutableArray array];
        paymentList = [NSMutableArray array];
    }
    
    return self;
}

-(void)loadData:(NSDictionary*)data {
    
    if (data) {
        if ([data objectForKey:@"AddressCity"] && (NSNull*)[data objectForKey:@"AddressCity"] != [NSNull null]) {
            city = [data objectForKey:@"AddressCity"];
        }
        if ([data objectForKey:@"AddressLine1"] && (NSNull*)[data objectForKey:@"AddressLine1"] != [NSNull null]) {
            addressLine1 = [data objectForKey:@"AddressLine1"];
        }
        if ([data objectForKey:@"AddressLine2"] && (NSNull*)[data objectForKey:@"AddressLine2"] != [NSNull null]) {
            addressLine2 = [data objectForKey:@"AddressLine2"];
        }
        if ([data objectForKey:@"AddressStateCode"] && (NSNull*)[data objectForKey:@"AddressStateCode"] != [NSNull null]) {
            stateCode = [data objectForKey:@"AddressStateCode"];
        }
        if ([data objectForKey:@"AddressZipCode"] && (NSNull*)[data objectForKey:@"AddressZipCode"] != [NSNull null]) {
            zipCode = [data objectForKey:@"AddressZipCode"];
        }
        if ([data objectForKey:@"AssetId"] && (NSNull*)[data objectForKey:@"AssetId"] != [NSNull null]) {
            assetId = [data objectForKey:@"AssetId"];
        }
        if ([data objectForKey:@"AssetUrl"] && (NSNull*)[data objectForKey:@"AssetUrl"] != [NSNull null]) {
            assetUrl = [data objectForKey:@"AssetUrl"];
        }
        if ([data objectForKey:@"BusinessHours"] && (NSNull*)[data objectForKey:@"BusinessHours"] != [NSNull null]) {
            businessHours = [data objectForKey:@"BusinessHours"];
        }
        if ([data objectForKey:@"Description"] && (NSNull*)[data objectForKey:@"Description"] != [NSNull null]) {
            description = [data objectForKey:@"Description"];
        }
        if ([data objectForKey:@"FaxNumber"] && (NSNull*)[data objectForKey:@"FaxNumber"] != [NSNull null]) {
            faxNumber = [data objectForKey:@"FaxNumber"];
        }
        if ([data objectForKey:@"Id"] && (NSNull*)[data objectForKey:@"Id"] != [NSNull null]) {
            restaurantID = [data objectForKey:@"Id"];
        }
        if ([data objectForKey:@"Name"] && (NSNull*)[data objectForKey:@"Name"] != [NSNull null]) {
            restaurantName = [data objectForKey:@"Name"];
        }
        if ([data objectForKey:@"PaymentList"] && [[data objectForKey:@"PaymentList"] objectForKey:@"List"] && [[[data objectForKey:@"PaymentList"] objectForKey:@"List"] isKindOfClass:[NSArray class]]) {
            [paymentList addObjectsFromArray:[[data objectForKey:@"PaymentList"] objectForKey:@"List"]];
        }
        if ([data objectForKey:@"PhoneAlternate"] && (NSNull*)[data objectForKey:@"PhoneAlternate"] != [NSNull null]) {
            alternatePhone = [data objectForKey:@"PhoneAlternate"];
        }
        if ([data objectForKey:@"PhonePrimary"] && (NSNull*)[data objectForKey:@"PhonePrimary"] != [NSNull null]) {
            primaryPhone = [data objectForKey:@"PhonePrimary"];
        }
        if ([data objectForKey:@"FoodCategoryList"] && [[data objectForKey:@"FoodCategoryList"] objectForKey:@"List"] && [[[data objectForKey:@"FoodCategoryList"] objectForKey:@"List"] isKindOfClass:[NSArray class]]) {
            [foodCategoryList addObjectsFromArray:[[data objectForKey:@"FoodCategoryList"] objectForKey:@"List"]];
        }
        if ([data objectForKey:@"RestaurantCategoryList"] && [[data objectForKey:@"RestaurantCategoryList"] objectForKey:@"List"] && [[[data objectForKey:@"RestaurantCategoryList"] objectForKey:@"List"] isKindOfClass:[NSArray class]]) {
            [restaurantCategoryList addObjectsFromArray:[[data objectForKey:@"RestaurantCategoryList"] objectForKey:@"List"]];
        }
        if ([data objectForKey:@"Distance"]) {
            distance = [[data objectForKey:@"Distance"] floatValue];
        }
        if ([data objectForKey:@"GratuityRate"]) {
            gratuityRate = [[data objectForKey:@"GratuityRate"] floatValue];
        }
        if ([data objectForKey:@"TaxRate"]) {
            taxRate = [[data objectForKey:@"TaxRate"] floatValue];
        }
        if ([data objectForKey:@"PayNow"]) {
            isPayNow = [[data objectForKey:@"PayNow"] boolValue];
        }
        if ([data objectForKey:@"ConvenienceFee"]) {
            isConvenienceFee = [[data objectForKey:@"ConvenienceFee"] boolValue];
        }
//        [self performSelectorInBackground:@selector(downlaodIconInBackground) withObject:nil];
    }
}

-(void)downlaodIconInBackground {
    
    @autoreleasepool {
        
        NSString *urlString = [NSString stringWithFormat:@"%@%@", ASSET_URL, assetUrl];
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
        iconImage = [UIImage imageWithData:data];
    }
}

@end
