//
//  SplashViewController.h
//
//  Created by Housein Jouhar on 7/10/15.
//  Copyright (c) 2015 SADAH Software Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface SplashViewController : UIViewController
{
    BOOL isDoneAnm;
}

@property (strong, nonatomic) IBOutlet UIImageView *splashImageView;
@property (strong, nonatomic) IBOutlet UILabel *label1;
@property (strong, nonatomic) IBOutlet UILabel *label2;
@property (strong, nonatomic) IBOutlet UILabel *rightsLabel;
@property (strong, nonatomic) IBOutlet UILabel *leftLabel;
@property (strong, nonatomic) IBOutlet UILabel *rightLabel;
@property (strong, nonatomic) IBOutlet UIView *mainView;

@end
