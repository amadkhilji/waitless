//
//  HTTPRequest.m
//  WaitlessPO
//
//  Created by Amad Khilji on 29/10/2013.
//  Copyright (c) 2013 Amad Khilji. All rights reserved.
//

#import "HTTPRequest.h"
#import "JSONKit.h"
#import "OAuthConsumer.h"

@interface HTTPRequest ()

@property (atomic, weak) id<HTTPRequestDelegate> delegate;

-(void)requestGetWithMethod:(NSString*)methodName Params:(NSDictionary*)params andDelegate:(id<HTTPRequestDelegate>)requestDelegate;
-(void)requestPostWithMethod:(NSString*)methodName Params:(NSDictionary*)params andDelegate:(id<HTTPRequestDelegate>)requestDelegate;
-(void)getYelpRestaurantsWithCoordinates:(CLLocationCoordinate2D)coordinates andDelegate:(id<HTTPRequestDelegate>)requestDelegate;

@end

@implementation HTTPRequest

@synthesize requestType;

-(id)init {
    
    if (self = [super init]) {
        
        urlData = [[NSMutableData alloc] init];
        requestType = HTTPRequestTypeWaitless;
    }
    
    return self;
}

#pragma mark
#pragma mark Static Methods

+(void)requestGetWithMethod:(NSString*)methodName Params:(NSDictionary*)params andDelegate:(id<HTTPRequestDelegate>)requestDelegate {
    
    HTTPRequest *request = [[HTTPRequest alloc] init];
    [request requestGetWithMethod:methodName Params:params andDelegate:requestDelegate];
}

+(void)requestPostWithMethod:(NSString*)methodName Params:(NSDictionary*)params andDelegate:(id<HTTPRequestDelegate>)requestDelegate {
    
    HTTPRequest *request = [[HTTPRequest alloc] init];
    [request requestPostWithMethod:methodName Params:params andDelegate:requestDelegate];
}

+(void)requestGetWithMethod:(NSString*)methodName Params:(NSDictionary*)params andDelegate:(id<HTTPRequestDelegate>)requestDelegate andRequestType:(HTTPRequestType)requestType_ {
    
    HTTPRequest *request = [[HTTPRequest alloc] init];
    request.requestType = requestType_;
    [request requestGetWithMethod:methodName Params:params andDelegate:requestDelegate];
}

+(void)requestPostWithMethod:(NSString*)methodName Params:(NSDictionary*)params andDelegate:(id<HTTPRequestDelegate>)requestDelegate andRequestType:(HTTPRequestType)requestType_ {
    
    HTTPRequest *request = [[HTTPRequest alloc] init];
    request.requestType = requestType_;
    [request requestPostWithMethod:methodName Params:params andDelegate:requestDelegate];
}

+(void)getYelpRestaurantsWithCoordinates:(CLLocationCoordinate2D)coordinates andDelegate:(id<HTTPRequestDelegate>)requestDelegate {
    
    HTTPRequest *request = [[HTTPRequest alloc] init];
    [request getYelpRestaurantsWithCoordinates:coordinates andDelegate:requestDelegate];
}

#pragma mark
#pragma mark Private Methods

-(void)requestGetWithMethod:(NSString*)methodName Params:(NSDictionary*)params andDelegate:(id<HTTPRequestDelegate>)requestDelegate {
    
    self.delegate = requestDelegate;
    [urlData setLength:0];
    
    NSMutableString *method = [NSMutableString stringWithString:@""];
    if (methodName) {
        [method appendString:methodName];
    }
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (params) {
        [parameters addEntriesFromDictionary:params];
    }
    if ([[parameters allValues] count] > 0) {
        [method appendString:@"?"];
        for (int i=0; i<[[parameters allValues] count]; i++) {
            if (i>0) {
                [method appendString:@"&"];
            }
            [method appendFormat:@"%@=%@", [[parameters allKeys] objectAtIndex:i], [[parameters allValues] objectAtIndex:i]];
        }
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@", SERVER_URL, [method stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    request.timeoutInterval = TIMEOUT_INTERVAL;
    
    NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [urlConnection start];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
}

-(void)requestPostWithMethod:(NSString*)methodName Params:(NSDictionary*)params andDelegate:(id<HTTPRequestDelegate>)requestDelegate {
    
    self.delegate = requestDelegate;
    [urlData setLength:0];
    
    NSMutableString *method = [NSMutableString stringWithString:@""];
    if (methodName) {
        [method appendString:methodName];
    }
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (params) {
        [parameters addEntriesFromDictionary:params];
    }
    NSData *postData = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:nil];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    NSString *urlString = [NSString stringWithFormat:@"%@%@", SERVER_URL, [method stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/raw" forHTTPHeaderField:@"Content-Type"];
    request.timeoutInterval = TIMEOUT_INTERVAL;
    
    NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [urlConnection start];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

-(void)getYelpRestaurantsWithCoordinates:(CLLocationCoordinate2D)coordinates andDelegate:(id<HTTPRequestDelegate>)requestDelegate {
    
    self.delegate = requestDelegate;
    requestType = HTTPRequestTypeYelp;
    [urlData setLength:0];
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.yelp.com/v2/search?term=restaurants&ll=%f,%f", coordinates.latitude, coordinates.longitude]];
    OAConsumer *consumer = [[OAConsumer alloc] initWithKey:YELP_CONSUMER_KEY secret:YELP_CONSUMER_SECRET];
    OAToken *token = [[OAToken alloc] initWithKey:YELP_TOKEN_KEY secret:YELP_TOKEN_SECRET];
    
    id<OASignatureProviding, NSObject> provider = [[OAHMAC_SHA1SignatureProvider alloc] init];
    NSString *realm = nil;
    
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:URL
                                                                   consumer:consumer
                                                                      token:token
                                                                      realm:realm
                                                          signatureProvider:provider];
    [request prepare];
    
    NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [urlConnection start];
    
}

#pragma mark NSURLConnectionDelegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
    if (httpResponse.statusCode == 200) {// http OK status code
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(didStartRequest:)]) {
            [self.delegate didStartRequest:self];
        }
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    [urlData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    NSString *responseString = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
    id responseData = [responseString objectFromJSONString];
    
    if (requestType == HTTPRequestTypeYelp) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didFinishRequest:withYelpData:)]) {
            [self.delegate didFinishRequest:self withYelpData:responseData];
        }
    }
    else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didFinishRequest:withData:)]) {
            [self.delegate didFinishRequest:self withData:responseData];
        }
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didFailRequest:withError:)]) {
        [self.delegate didFailRequest:self withError:[error localizedDescription]];
    }
}

@end
