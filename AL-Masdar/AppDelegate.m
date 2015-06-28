//
//  AppDelegate.m
//  AL-Masdar
//
//  Created by Osama Rabie on 6/23/15.
//  Copyright (c) 2015 Osama Rabie. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    
    
    
    
    if(![[NSUserDefaults standardUserDefaults] objectForKey:@"subscriptions"])
    {
        [[NSUserDefaults standardUserDefaults]setObject:[[NSArray alloc] init] forKey:@"subscriptions"];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
    
    
    if(![[NSUserDefaults standardUserDefaults] objectForKey:@"notifWords"])
    {
        [[NSUserDefaults standardUserDefaults]setObject:[[NSArray alloc] init] forKey:@"notifWords"];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
    
    // Initialize Parse.
    [Parse setApplicationId:@"poGzr9XppoOpAAXsPsmlHThMuREuy041CI8pUObx"
                  clientKey:@"j26t2K3012Cn6jhwV1SJSooE6TcqmKwsztKZdk5b"];
    
    
    
    
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    if([currSysVer hasPrefix:@"8"])
    {
        
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                        UIUserNotificationTypeBadge |
                                                        UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                                 categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    }else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }
    
    
    NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (userInfo == NULL)
    {
        NSLog(@"didFinishLaunchingWithOptions user startup userinfo: %@", userInfo);
    }
    else
    {
        NSLog(@"didFinishLaunchingWithOptions notification startup userinfo: %@", userInfo);
        //NSDictionary *userrInfo = [NSDictionary dictionaryWithObject:[userInfo objectForKey:@"u"] forKey:@"url"];
        //[[NSNotificationCenter defaultCenter] postNotificationName: @"OpenUrl" object:nil userInfo:userrInfo];
        if([userInfo objectForKey:@"u"])
        {
            [[NSUserDefaults standardUserDefaults]setObject:[userInfo objectForKey:@"u"]  forKey:@"url"];
            [[NSUserDefaults standardUserDefaults]synchronize];
        }
    }
    

    
    return YES;
}



- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];

}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
    if ([UIApplication sharedApplication].applicationState==UIApplicationStateActive) {
        NSLog(@"Notification recieved by running app");
    }
    else{
        NSDictionary* aps = [userInfo objectForKey:@"aps"];
        if([userInfo objectForKey:@"u"])
        {
            NSLog(@"%@",[aps objectForKey:@"u"]);
            NSDictionary *userrInfo = [NSDictionary dictionaryWithObject:[userInfo objectForKey:@"u"] forKey:@"url"];
            [[NSNotificationCenter defaultCenter] postNotificationName: @"OpenUrl" object:nil userInfo:userrInfo];
        }
    }
}

@end
