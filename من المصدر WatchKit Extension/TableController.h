//
//  WatchViewController.m
//
//  Created by Housein Jouhar on 07/6/15.
//  Copyright (c) 2015 SADAH Software Solutions. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>
#import "MyRowController.h"

@interface TableController : WKInterfaceController
{
    BOOL loadingData;
    NSMutableArray *newsTitleArr,*newsBodyArr,*fullBodyArr;
    NSInteger currentCaseNum,lastRow;
    NSString *upperId;
}

@property (strong, nonatomic) IBOutlet WKInterfaceTable *tableView;
@property (strong, nonatomic) IBOutlet WKInterfaceLabel *noNewsLabel;
@property (strong, nonatomic) IBOutlet WKInterfaceImage *noNewsImg;
@property (strong, nonatomic) IBOutlet WKInterfaceButton *loadMoreButton;
@property (strong, nonatomic) IBOutlet WKInterfaceImage *waitImg;

@end
