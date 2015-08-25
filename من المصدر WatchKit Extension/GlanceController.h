//
//  GlanceController.h
//  من المصدر WatchKit Extension
//
//  Created by Hussein Jouhar on 8/3/15.
//  Copyright (c) 2015 Osama Rabie. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface GlanceController : WKInterfaceController


@property (strong, nonatomic) IBOutlet WKInterfaceLabel *breakingLabel;
@property (strong, nonatomic) IBOutlet WKInterfaceLabel *breakingName;

@end
