//
//  AppDelegate.m
//  AL-Masdar
//
//  Created by Osama Rabie on 6/23/15.
//  Copyright (c) 2015 Osama Rabie. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "AFHTTPRequestOperationManager.h"
#import <MMAdSDK/MMAdSDK.h>

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

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
    
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
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
    
    [[MMSDK sharedInstance] initializeWithSettings:nil withUserSettings:nil];
    
    
    NSDictionary* userInfo = [launchOptions valueForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if(userInfo)
    {
        NSString* ID = [userInfo objectForKey:@"u"];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData * data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",@"http://almasdarapp.com/almasdar/getAllDetails.php?id=",ID]]];
            UIImage* image = nil;
            NSError* error;
             NSDictionary* news = [[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error] objectAtIndex:0];            if(!error)
            {
                if(![[news objectForKey:@"mediaURL"] isEqualToString:@""])
                {
                    NSData* imageData = [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:[news objectForKey:@"mediaURL"]]];
                    image = [[UIImage alloc]initWithData:imageData];
                }else
                {
                    image = [UIImage imageNamed:@"no-image-img.png"];
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                if(!error)
                {
                    
                    NSString *sharedMsg=[news objectForKey:@"body"];
                    NSArray* sharedObjects;
                    
                    if([[news objectForKey:@"mediaURL"]isEqualToString:@""])
                    {
                        sharedObjects=[NSArray arrayWithObjects:sharedMsg, nil];
                        [[NSUserDefaults standardUserDefaults] setObject:sharedMsg forKey:@"textToShare"];
                        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"imgToShare"];
                        
                    }
                    else
                    {
                        [[NSUserDefaults standardUserDefaults] setObject:sharedMsg forKey:@"textToShare"];
                        [[NSUserDefaults standardUserDefaults] setObject:[news objectForKey:@"mediaURL"] forKey:@"imgToShare"];
                    }
                    
                    [[NSUserDefaults standardUserDefaults] setObject:UIImagePNGRepresentation(image) forKey:@"currentImgData"];
                    
                    [[NSUserDefaults standardUserDefaults] setObject:sharedObjects forKey:@"objectsToShare"];
                    [[NSUserDefaults standardUserDefaults] setObject:[self getShareLinkForId:[news objectForKey:@"id"]] forKey:@"theSavedNewsId"];
                    [[NSUserDefaults standardUserDefaults] setObject:[news objectForKey:@"id"] forKey:@"commentsId"];
                    [[NSUserDefaults standardUserDefaults] setObject:[news objectForKey:@"newsURL"] forKey:@"newsLinkToOpen"];
                    [[NSUserDefaults standardUserDefaults] setObject:[news objectForKey:@"photos"] forKey:@"newsAllPhotos"];
                    [[NSUserDefaults standardUserDefaults] setObject:[news objectForKey:@"videos"] forKey:@"newsAllVideos"];
                    [[NSUserDefaults standardUserDefaults] setObject:[news objectForKey:@"body"] forKey:@"savedNewsTitle"];
                    [[NSUserDefaults standardUserDefaults] setObject:[news objectForKey:@"fullBody"] forKey:@"savedNewsBody"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [[NSUserDefaults standardUserDefaults]setObject:[news objectForKey:@"newsURL"] forKey:@"newsUrlNotif"];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"OpenDetailsNotification" object:self];

                }
            });
        });
    }
    
    return YES;
}

-(NSString*)getShareLinkForId:(NSString*)theId
{
    return [@"http://almasdarapp.com/almasdar/Sharing/index.html?id=" stringByAppendingString:theId];
}


-(NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        return UIInterfaceOrientationMaskAll;
    }
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isLandscapeOn"])return UIInterfaceOrientationMaskAllButUpsideDown;
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
    // Return YES for supported orientations
    //    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)application:(UIApplication *)application handleWatchKitExtensionRequest:(NSDictionary *)userInfo reply:(void (^)(NSDictionary *))reply
{
    __block UIBackgroundTaskIdentifier bogusWorkaroundTask;
    bogusWorkaroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:bogusWorkaroundTask];
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] endBackgroundTask:bogusWorkaroundTask];
    });
    // --------------------
    __block UIBackgroundTaskIdentifier realBackgroundTask;
    realBackgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        dataSource = [[NSMutableArray alloc] init];
        
        upperCurrentID = [userInfo objectForKey:@"upperCurrentID"];
        lowerCurrentID = [userInfo objectForKey:@"lowerCurrentID"];
        
        isLoadingDone = NO;
        
        NSMutableArray *sources = [[NSMutableArray alloc]init];
        
        NSArray* subs = [[NSUserDefaults standardUserDefaults] objectForKey:@"subscriptions"];
        
        for(NSDictionary* dict in subs)
        {
            [sources addObject:[dict objectForKey:@"twitterID"]];
        }
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        NSDictionary* params;
        
        NSString *urlStr;
        
        if ([[userInfo objectForKey:@"request"] isEqualToString:@"getNewsData"])
        {
            if ([upperCurrentID integerValue] == 0)
            {
                params = @{@"lowerID":lowerCurrentID,@"sources":[sources componentsJoinedByString:@","]};
                urlStr = @"http://almasdarapp.com/almasdar/getNewerNewsWatch.php";
            }
            else
            {
                params = @{@"lowerID":upperCurrentID,@"sources":[sources componentsJoinedByString:@","]};
                urlStr = @"http://almasdarapp.com/almasdar/getOlderNewsWatch.php";
            }
        }
        else if ([[userInfo objectForKey:@"request"] isEqualToString:@"getFavData"])
        {
            NSMutableArray* favs = [[NSMutableArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"favs"] copyItems:YES];
            NSArray *aSortedArray = [favs sortedArrayUsingComparator:^(NSDictionary *obj1,NSDictionary *obj2) {
                NSString *num1 =[obj1 objectForKey:@"createdAt"];
                NSString *num2 =[obj2 objectForKey:@"createdAt"];
                return (NSComparisonResult) [num2 compare:num1 options:(NSNumericSearch)];
            }];
            
            dataSource = [[NSMutableArray alloc]initWithArray:aSortedArray copyItems:YES];
            
            reply ([NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:dataSource,lowerCurrentID, nil] forKeys:[NSArray arrayWithObjects:@"theReply",@"upperId", nil]]);
            return;
        }
        else if ([[userInfo objectForKey:@"request"] isEqualToString:@"getBreakingData"])
        {
            if ([upperCurrentID integerValue] == 0)
            {
                params = @{@"lowerID":lowerCurrentID,@"sources":[sources componentsJoinedByString:@","]};
                urlStr = @"http://almasdarapp.com/almasdar/getBreakingNewsNewerWatch.php";
            }
            else
            {
                params = @{@"lowerID":upperCurrentID,@"sources":[sources componentsJoinedByString:@","]};
                urlStr = @"http://almasdarapp.com/almasdar/getBreakingNewsWatch.php";
            }
        }
        
        [manager POST:urlStr parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            dataSource = [[NSMutableArray alloc]initWithArray:[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil]];
            
            if([dataSource count]>0)
            {
                lowerCurrentID = [[dataSource lastObject] objectForKey:@"id"];
            }
            
            NSMutableArray *filterArr = [[NSMutableArray alloc] init];
            NSMutableArray *checkArr = [[NSMutableArray alloc] init];
            
            NSDictionary* news;
            
            for (int i = 0; i < dataSource.count; i++)
            {
                news = [dataSource objectAtIndex:i];
                if (![checkArr containsObject:[news objectForKey:@"body"]])
                {
                    [checkArr addObject:[news objectForKey:@"body"]];
                    [filterArr addObject:[dataSource objectAtIndex:i]];
                }
            }
            
            dataSource = [[NSMutableArray alloc] initWithArray:filterArr];
            
            reply ([NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:dataSource,lowerCurrentID, nil] forKeys:[NSArray arrayWithObjects:@"theReply",@"upperId", nil]]);
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            reply (nil);
        }];
        [[UIApplication sharedApplication] endBackgroundTask:realBackgroundTask];
    }];
    // Kick off a network request, heavy processing work, etc.
    // Return any data you need to, obviously.
    dataSource = [[NSMutableArray alloc] init];
    
    upperCurrentID = [userInfo objectForKey:@"upperCurrentID"];
    lowerCurrentID = [userInfo objectForKey:@"lowerCurrentID"];
    
    isLoadingDone = NO;
    
    NSMutableArray *sources = [[NSMutableArray alloc]init];
    
    NSArray* subs = [[NSUserDefaults standardUserDefaults] objectForKey:@"subscriptions"];
    
    for(NSDictionary* dict in subs)
    {
        [sources addObject:[dict objectForKey:@"twitterID"]];
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSDictionary* params;
    
    NSString *urlStr;
    
    if ([[userInfo objectForKey:@"request"] isEqualToString:@"getNewsData"])
    {
        if ([upperCurrentID integerValue] == 0)
        {
            params = @{@"lowerID":lowerCurrentID,@"sources":[sources componentsJoinedByString:@","]};
            urlStr = @"http://almasdarapp.com/almasdar/getNewerNewsWatch.php";
        }
        else
        {
            params = @{@"lowerID":upperCurrentID,@"sources":[sources componentsJoinedByString:@","]};
            urlStr = @"http://almasdarapp.com/almasdar/getOlderNewsWatch.php";
        }
    }
    else if ([[userInfo objectForKey:@"request"] isEqualToString:@"getFavData"])
    {
        NSMutableArray* favs = [[NSMutableArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"favs"] copyItems:YES];
        NSArray *aSortedArray = [favs sortedArrayUsingComparator:^(NSDictionary *obj1,NSDictionary *obj2) {
            NSString *num1 =[obj1 objectForKey:@"createdAt"];
            NSString *num2 =[obj2 objectForKey:@"createdAt"];
            return (NSComparisonResult) [num2 compare:num1 options:(NSNumericSearch)];
        }];
        
        dataSource = [[NSMutableArray alloc]initWithArray:aSortedArray copyItems:YES];
        
        reply ([NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:dataSource,lowerCurrentID, nil] forKeys:[NSArray arrayWithObjects:@"theReply",@"upperId", nil]]);
        return;
    }
    else if ([[userInfo objectForKey:@"request"] isEqualToString:@"getBreakingData"])
    {
        if ([upperCurrentID integerValue] == 0)
        {
            params = @{@"lowerID":lowerCurrentID,@"sources":[sources componentsJoinedByString:@","]};
            urlStr = @"http://almasdarapp.com/almasdar/getBreakingNewsNewerWatch.php";
        }
        else
        {
            params = @{@"lowerID":upperCurrentID,@"sources":[sources componentsJoinedByString:@","]};
            urlStr = @"http://almasdarapp.com/almasdar/getBreakingNewsWatch.php";
        }
    }
    
    [manager POST:urlStr parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        dataSource = [[NSMutableArray alloc]initWithArray:[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil]];
        
        if([dataSource count]>0)
        {
            lowerCurrentID = [[dataSource lastObject] objectForKey:@"id"];
        }
        
        NSMutableArray *filterArr = [[NSMutableArray alloc] init];
        NSMutableArray *checkArr = [[NSMutableArray alloc] init];
        
        NSDictionary* news;
        
        for (int i = 0; i < dataSource.count; i++)
        {
            news = [dataSource objectAtIndex:i];
            if (![checkArr containsObject:[news objectForKey:@"body"]])
            {
                [checkArr addObject:[news objectForKey:@"body"]];
                [filterArr addObject:[dataSource objectAtIndex:i]];
            }
        }
        
        dataSource = [[NSMutableArray alloc] initWithArray:filterArr];
        
        reply ([NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:dataSource,lowerCurrentID, nil] forKeys:[NSArray arrayWithObjects:@"theReply",@"upperId", nil]]);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        reply (nil);
    }];
    
    [[UIApplication sharedApplication] endBackgroundTask:realBackgroundTask];
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
    if ( application.applicationState == UIApplicationStateInactive || application.applicationState == UIApplicationStateBackground  )
    {
        if(userInfo)
        {
            NSString* ID = [userInfo objectForKey:@"u"];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSData * data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",@"http://almasdarapp.com/almasdar/getAllDetails.php?id=",ID]]];
                UIImage* image = nil;
                NSError* error;
                NSLog(@"%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                NSDictionary* news = [[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error] objectAtIndex:0];
                if(!error)
                {
                    if(![[news objectForKey:@"mediaURL"] isEqualToString:@""])
                    {
                        NSData* imageData = [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:[news objectForKey:@"mediaURL"]]];
                        image = [[UIImage alloc]initWithData:imageData];
                    }else
                    {
                        image = [UIImage imageNamed:@"no-image-img.png"];
                    }
                }
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    if(!error)
                    {
                        
                        NSString *sharedMsg=[news objectForKey:@"body"];
                        NSArray* sharedObjects;
                        
                        if([[news objectForKey:@"mediaURL"]isEqualToString:@""])
                        {
                            sharedObjects=[NSArray arrayWithObjects:sharedMsg, nil];
                            [[NSUserDefaults standardUserDefaults] setObject:sharedMsg forKey:@"textToShare"];
                            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"imgToShare"];
                            
                        }
                        else
                        {
                            [[NSUserDefaults standardUserDefaults] setObject:sharedMsg forKey:@"textToShare"];
                            [[NSUserDefaults standardUserDefaults] setObject:[news objectForKey:@"mediaURL"] forKey:@"imgToShare"];
                        }
                        
                        [[NSUserDefaults standardUserDefaults] setObject:UIImagePNGRepresentation(image) forKey:@"currentImgData"];
                        
                        [[NSUserDefaults standardUserDefaults] setObject:sharedObjects forKey:@"objectsToShare"];
                        [[NSUserDefaults standardUserDefaults] setObject:[self getShareLinkForId:[news objectForKey:@"id"]] forKey:@"theSavedNewsId"];
                        [[NSUserDefaults standardUserDefaults] setObject:[news objectForKey:@"id"] forKey:@"commentsId"];
                        [[NSUserDefaults standardUserDefaults] setObject:[news objectForKey:@"newsURL"] forKey:@"newsLinkToOpen"];
                        [[NSUserDefaults standardUserDefaults] setObject:[news objectForKey:@"photos"] forKey:@"newsAllPhotos"];
                        [[NSUserDefaults standardUserDefaults] setObject:[news objectForKey:@"videos"] forKey:@"newsAllVideos"];
                        [[NSUserDefaults standardUserDefaults] setObject:[news objectForKey:@"body"] forKey:@"savedNewsTitle"];
                        [[NSUserDefaults standardUserDefaults] setObject:[news objectForKey:@"fullBody"] forKey:@"savedNewsBody"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        [[NSUserDefaults standardUserDefaults]setObject:[news objectForKey:@"newsURL"] forKey:@"newsUrlNotif"];
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"OpenDetailsNotification" object:self];
                        
                    }
                });
            });
        }
    }
}

@end
