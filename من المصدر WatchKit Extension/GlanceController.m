//
//  GlanceController.m
//  من المصدر WatchKit Extension
//
//  Created by Hussein Jouhar on 8/3/15.
//  Copyright (c) 2015 Osama Rabie. All rights reserved.
//

#import "GlanceController.h"


@interface GlanceController()

@end


@implementation GlanceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    // Configure interface objects here.
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    
    NSDictionary *requst = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"getBreakingData",@"0",@"-1", nil] forKeys:[NSArray arrayWithObjects:@"request",@"upperCurrentID",@"lowerCurrentID", nil]];
    
    [WKInterfaceController openParentApplication:requst
                                           reply:^( NSDictionary *replyInfo, NSError *error ) {
                                               
                                               NSMutableArray *dataSource = [[NSMutableArray alloc]init];
                                               
                                               dataSource = [replyInfo objectForKey:@"theReply"];
                                               
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
                                               
                                               NSDictionary *myNews;
                                               
                                               dataSource = [[NSMutableArray alloc] initWithArray:filterArr];
                                               
                                               myNews = [dataSource objectAtIndex:0];
                                               
                                               [_breakingLabel setText:[myNews objectForKey:@"body"]];
                                               [_breakingName setText:[myNews objectForKey:@"name"]];
                                           }];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

@end



