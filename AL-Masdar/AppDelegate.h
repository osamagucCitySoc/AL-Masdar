//
//  AppDelegate.h
//  AL-Masdar
//
//  Created by Osama Rabie on 6/23/15.
//  Copyright (c) 2015 Osama Rabie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    NSMutableArray *dataSource;
    NSString *upperCurrentID,*lowerCurrentID;
    BOOL isLoadingDone;
}

@property (strong, nonatomic) UIWindow *window;


@end

