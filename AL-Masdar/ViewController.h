//
//  ViewController.h
//  AL-Masdar
//
//  Created by Osama Rabie on 6/23/15.
//  Copyright (c) 2015 Osama Rabie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SADAHBlurView.h"
#import "SADAHMsg.h"
#import "UIImageView+WebCache.h"
#import <Parse/Parse.h>

@interface ViewController : UIViewController
{
    BOOL isAllLoaded,isShowStatus,isSearching;
    NSInteger currentSubNum;
}

@property (strong, nonatomic) IBOutlet UIView *searchView;
@property (strong, nonatomic) IBOutlet UITextField *searchTextField;

@end

