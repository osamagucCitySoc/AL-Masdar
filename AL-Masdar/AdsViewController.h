//
//  AdsViewController.h
//
//  Created by Hussein Jouhar on 05/31/15.
//  Copyright (c) 2015 SADAH Software Solutions, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "UIImageView+WebCache.h"

@interface AdsViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIImageView *adImage;
@property (strong, nonatomic) IBOutlet UILabel *adTitle;
@property (strong, nonatomic) IBOutlet UILabel *adMsg;
@property (strong, nonatomic) IBOutlet UIButton *adButton;


@end
