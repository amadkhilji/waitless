//
//  AppDelegate.m
//  WaitlessPO
//
//  Created by Amad Khilji on 28/10/2013.
//  Copyright (c) 2013 Amad Khilji. All rights reserved.
//

#import "AppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>
#import "UIBarButtonItem+FlatUI.h"
#import "UserModel.h"
#import "SVProgressHUD.h"
#import "JSONKit.h"

@interface AppDelegate ()

-(void)handleFulfilledParkedOrderNotification;

@end

// Please use the client ID created for you by Google.
static NSString * const kClientID = @"36169379961.apps.googleusercontent.com";//@"343032801200.apps.googleusercontent.com";

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Set app's client ID for |GPPSignIn| and |GPPShare|.
    [GPPSignIn sharedInstance].clientID = kClientID;
    
    // Read Google+ deep-link data.
    [GPPDeepLink setDelegate:self];
    [GPPDeepLink readDeepLinkAfterInstall];
    
    [[AppInfo sharedInfo] loadUserSession];
    
    if (launchOptions) {
        NSDictionary *remoteNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (remoteNotification) {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:remoteNotification forKey:PUSH_NOTIFICATION];
            [defaults synchronize];
        }
    }
    
    // Override point for customization after application launch.
//    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    UINavigationController *navigationController = [storyboard instantiateInitialViewController];

    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = navigationController;
    
    [self.window makeKeyAndVisible];
    
    
            
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    [[AppInfo sharedInfo] saveUserSession];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

    [[AppInfo sharedInfo] saveUserSession];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[AppInfo sharedInfo] loadUserSession];
    if ([[AppInfo sharedInfo] isLogin] && application.applicationIconBadgeNumber > 0) {
        [self handleFulfilledParkedOrderNotification];
    }
    else if ([[AppInfo sharedInfo] shouldShowPaymentSignUp]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SHOW_PAYMENT_ALERT_NOTIFICATION object:@"show_payment_alert"];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [FBAppEvents activateApp];
    [FBAppCall handleDidBecomeActive];
    [[AppInfo sharedInfo] loadUserSession];
    if ([[AppInfo sharedInfo] isLogin] && application.applicationIconBadgeNumber > 0) {
        [self handleFulfilledParkedOrderNotification];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    [[FBSession activeSession] close];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    [SVProgressHUD dismiss];
    if ([FBAppCall handleOpenURL:url sourceApplication:sourceApplication]) {
        return YES;
    }
    return [GPPURLHandler handleURL:url
                  sourceApplication:sourceApplication
                         annotation:annotation];
}

#pragma mark
#pragma mark PushNotification call backs

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    //register to receive notifications
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    // We have received a new device token. This method is usually called right
	// away after you've registered for push notifications, but there are no
	// guarantees. It could take up to a few seconds and you should take this
	// into consideration when you design your app. In our case, the user could
	// send a "join" request to the server before we have received the device
	// token. In that case, we silently send an "update" request to the server
	// API once we receive the token.
    
	NSString* newToken = [deviceToken description];
	newToken = [newToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
	newToken = [newToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:newToken forKey:DEVICE_TOKEN];
    [defaults synchronize];
    
    if ([[AppInfo sharedInfo] isLogin]) {
        [[AppInfo sharedInfo] requestForDeviceRegistration];
    }
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults objectForKey:DEVICE_TOKEN] || [[[UIDevice currentDevice] model] isEqualToString:@"iPhone Simulator"]) {
        UIDevice *device = [UIDevice currentDevice];
        NSString *deviceId = [NSString stringWithFormat:@"%@ %@ %@ %@", device.name, device.model, device.systemName, device.systemVersion];
        [defaults setObject:[NSString stringWithFormat:@"%@%f", deviceId, [[NSDate date] timeIntervalSince1970]] forKey:DEVICE_TOKEN];
        [defaults synchronize];
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    // This method is invoked when the app is running and a push notification
	// is received. If the app was suspended in the background, it is woken up
	// and this method is invoked as well. We add the new message to the data
	// model and add it to the ChatViewController's table view.
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:userInfo forKey:PUSH_NOTIFICATION];
    [defaults synchronize];
    NSString *response = [[userInfo objectForKey:@"message"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *notification = [response objectFromJSONString];
    if (application.applicationState == UIApplicationStateActive) {
        if ([[AppInfo sharedInfo] isLogin]) {
            if (notification && [notification isKindOfClass:[NSDictionary class]] && [notification objectForKey:@"UpdateType"]) {
                int updateType = [[notification objectForKey:@"UpdateType"] intValue];
                if ([notification objectForKey:@"UserId"] && [[notification objectForKey:@"UserId"] isEqualToString:[AppInfo sharedInfo].user.userID] && (updateType == ParkedOrderStatusFulfilled || updateType == ParkedOrderStatusClosed)) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:PARKED_ORDER_UPDATE_NOTIFICATION object:Nil];
                }
                else if (updateType == PromotionTypeAdd) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:PROMOTION_ADD_NOTIFICATION object:Nil];
                }
                else if (updateType == PromotionTypeDelete) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:PROMOTION_DELETE_NOTIFICATION object:Nil];
                }
                else if (updateType == PromotionTypeUpdate) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:PROMOTION_UPDATE_NOTIFICATION object:Nil];
                }
            }
        }
    }
    else {
        if ([userInfo objectForKey:@"aps"] && [[userInfo objectForKey:@"aps"] objectForKey:@"badge"]) {
//            application.applicationIconBadgeNumber = [[[userInfo objectForKey:@"aps"] objectForKey:@"badge"] integerValue];
        }
    }
}

#pragma mark - GPPDeepLinkDelegate

- (void)didReceiveDeepLink:(GPPDeepLink *)deepLink {
    // An example to handle the deep link data.
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Deep-link Data"
                          message:[deepLink deepLinkID]
                          delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark
#pragma mark UIAlertViewDelegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PARKED_ORDER_UPDATE_NOTIFICATION object:Nil];
}

-(void)handleFulfilledParkedOrderNotification {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *userInfo = [defaults objectForKey:PUSH_NOTIFICATION];
    NSString *response = [[userInfo objectForKey:@"message"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *notification = [response objectFromJSONString];
    if (notification && [notification isKindOfClass:[NSDictionary class]] && [notification objectForKey:@"UpdateType"]) {
        int updateType = [[notification objectForKey:@"UpdateType"] intValue];
        if ([notification objectForKey:@"UserId"] && [[notification objectForKey:@"UserId"] isEqualToString:[AppInfo sharedInfo].user.userID] && (updateType == ParkedOrderStatusFulfilled || updateType == ParkedOrderStatusClosed)) {
            if (updateType == ParkedOrderStatusFulfilled) {
                [SVProgressHUD showWithStatus:@"Updating parked order..." maskType:SVProgressHUDMaskTypeGradient];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:PARKED_ORDER_UPDATE_NOTIFICATION object:Nil];
        }
        else if (updateType == PromotionTypeAdd) {
            [[NSNotificationCenter defaultCenter] postNotificationName:PROMOTION_ADD_NOTIFICATION object:Nil];
        }
        else if (updateType == PromotionTypeDelete) {
            [[NSNotificationCenter defaultCenter] postNotificationName:PROMOTION_DELETE_NOTIFICATION object:Nil];
        }
        else if (updateType == PromotionTypeUpdate) {
            [[NSNotificationCenter defaultCenter] postNotificationName:PROMOTION_UPDATE_NOTIFICATION object:Nil];
        }
    }
}

@end
