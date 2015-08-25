//
//  WatchViewController.h
//
//  Created by Housein Jouhar on 7/10/15.
//  Copyright (c) 2015 SADAH Software Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface WatchViewController : UIViewController <UIWebViewDelegate>
{
    BOOL loadedDone;
}

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *actView;
@property (strong, nonatomic) IBOutlet UINavigationBar *watchNavBar;
@property (strong, nonatomic) IBOutlet UILabel *watchTopLabel;
@property (strong, nonatomic) IBOutlet UIWebView *videoWebView;
@end
