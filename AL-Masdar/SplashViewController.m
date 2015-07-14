//
//  SplashViewController.m
//
//  Created by Housein Jouhar on 7/10/15.
//  Copyright (c) 2015 SADAH Software Solutions. All rights reserved.
//

#import "SplashViewController.h"

@interface SplashViewController ()

@end

@implementation SplashViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self performSelector:@selector(startTheAnimation) withObject:nil afterDelay:0.1];
}

-(void)startTheAnimation
{
    [UIView animateWithDuration:0.2 delay:0.0 options:0
                     animations:^{
                         [_splashImageView setFrame:CGRectMake(_splashImageView.frame.origin.x, _splashImageView.frame.origin.y-50, _splashImageView.frame.size.width, _splashImageView.frame.size.height)];
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.2 delay:0.1 options:0
                                          animations:^{
                                              [_splashImageView setFrame:CGRectMake(_splashImageView.frame.origin.x, _splashImageView.frame.origin.y+self.view.frame.size.height, _splashImageView.frame.size.width, _splashImageView.frame.size.height)];
                                          }
                                          completion:^(BOOL finished) {
                                              //[self performSelector:@selector(openFirstView) withObject:nil afterDelay:0.3];
                                              [self performSegueWithIdentifier:@"firstSeg" sender:self];
                                          }];
                         [UIView commitAnimations];
                     }];
    [UIView commitAnimations];
}

-(void)openFirstView
{
    [self performSegueWithIdentifier:@"firstSeg" sender:self];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
