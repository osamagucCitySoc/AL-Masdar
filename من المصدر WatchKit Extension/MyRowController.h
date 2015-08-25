//
//  WatchViewController.m
//
//  Created by Housein Jouhar on 07/6/15.
//  Copyright (c) 2015 SADAH Software Solutions. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface MyRowController : NSObject

@property (strong, nonatomic) IBOutlet WKInterfaceLabel *titleLabel;
@property (strong, nonatomic) IBOutlet WKInterfaceLabel *bodyLabel;
@property (strong, nonatomic) IBOutlet WKInterfaceImage *newsImg;

@end
