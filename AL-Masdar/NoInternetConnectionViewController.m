//
//  NoInternetConnectionViewController.m
//  AL-Masdar
//
//  Created by Osama Rabie on 6/23/15.
//  Copyright (c) 2015 Osama Rabie. All rights reserved.
//

#import "NoInternetConnectionViewController.h"
#import "Reachability.h"

@interface NoInternetConnectionViewController ()

@end

@implementation NoInternetConnectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [NSTimer scheduledTimerWithTimeInterval: 2.0
                                     target: self
                                   selector:@selector(ckeckTheNet:)
                                   userInfo: nil repeats:YES];
    
    [self netStartAnimation];
}

-(void)netStartAnimation
{
    [UIView animateWithDuration:1.0
                          delay:0
                        options:UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse
                     animations:^{
                         [_netImg setAlpha:0.2];
                     }completion:^(BOOL finished){
                         [_netImg setAlpha:1.0];
                         [self netStartAnimation];
                     }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(void)ckeckTheNet:(NSTimer *)timer {
    if([self connected])
    {
        [_netImg setHidden:YES];
        [_netReadyImg setHidden:NO];
        [_netReadyImg setAlpha:0.0];
        [_netLabel setText:@"تم الإتصال بنجاح"];
        [UIView animateWithDuration:0.1 delay:0.0 options:0
                         animations:^{
                             [_netReadyImg setAlpha:1.0];
                         }
                         completion:^(BOOL finished) {
                             [UIView animateWithDuration:0.1 delay:0.0 options:0
                                              animations:^{
                                                  [_netReadyImg setAlpha:0.0];
                                              }
                                              completion:^(BOOL finished) {
                                                  [UIView animateWithDuration:0.1 delay:0.0 options:0
                                                                   animations:^{
                                                                       [_netReadyImg setAlpha:1.0];
                                                                   }
                                                                   completion:^(BOOL finished) {
                                                                       [self performSelector:@selector(closeMe) withObject:nil afterDelay:1.0];
                                                                   }];
                                                  [UIView commitAnimations];
                                              }];
                             [UIView commitAnimations];
                         }];
        [UIView commitAnimations];
    }
}

-(void)closeMe
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)connected
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return networkStatus != NotReachable;
}

@end
