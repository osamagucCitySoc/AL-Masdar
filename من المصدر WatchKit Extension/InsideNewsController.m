//
//  InsideNewsController.m
//  من المصدر WatchKit Extension
//
//  Created by Hussein Jouhar on 8/3/15.
//  Copyright (c) 2015 Osama Rabie. All rights reserved.
//

#import "InsideNewsController.h"


@interface InsideNewsController()

@end


@implementation InsideNewsController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    // Configure interface objects here.
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    
    [_newsLabel setText:[[NSUserDefaults standardUserDefaults] objectForKey:@"currentFullBody"]];
    
    if ([[[[NSUserDefaults standardUserDefaults] objectForKey:@"currentFullBody"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0)
    {
        [_newsLabel setHidden:YES];
        [_noNewsLabel setHidden:NO];
    }
    else
    {
        [_newsLabel setHidden:NO];
        [_noNewsLabel setHidden:YES];
    }
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

@end



