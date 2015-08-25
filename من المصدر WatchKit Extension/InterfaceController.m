//
//  InterfaceController.m
//  من المصدر WatchKit Extension
//
//  Created by Hussein Jouhar on 8/3/15.
//  Copyright (c) 2015 Osama Rabie. All rights reserved.
//

#import "InterfaceController.h"


@interface InterfaceController()

@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    [_newsImg setImage:[UIImage imageNamed:@"timeline-watch-icon"]];
    [_favImg setImage:[UIImage imageNamed:@"favorites-watch-icon"]];
    [_breakingImg setImage:[UIImage imageNamed:@"breaking-watch-icon"]];
    // Configure interface objects here.
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (IBAction)openNews {
    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"currentReqNum"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self openTable];
}

- (IBAction)openFav {
    [[NSUserDefaults standardUserDefaults] setInteger:2 forKey:@"currentReqNum"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self openTable];
}

- (IBAction)openBreaking {
    [[NSUserDefaults standardUserDefaults] setInteger:3 forKey:@"currentReqNum"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self openTable];
}

-(void)openTable
{
    [self pushControllerWithName:@"theTableSeg" context:nil];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

@end



