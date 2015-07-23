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
    
    [self setRights];
    
    [self performSelector:@selector(startTheAnimation) withObject:nil afterDelay:0.3];
}

-(void)startTheAnimation
{
    [_label1 setFrame:CGRectMake(_label1.frame.origin.x, self.view.frame.size.height+50, _label1.frame.size.width, _label1.frame.size.height)];
    [_label2 setFrame:CGRectMake(_label2.frame.origin.x, self.view.frame.size.height+50, _label2.frame.size.width, _label2.frame.size.height)];
    [_rightsLabel setFrame:CGRectMake(_rightsLabel.frame.origin.x, self.view.frame.size.height+50, _rightsLabel.frame.size.width, _rightsLabel.frame.size.height)];
    [_label1 setHidden:NO];
    [_label2 setHidden:NO];
    [_rightsLabel setHidden:NO];
    [_rightsLabel setAlpha:0.0];
    [_label1 setFrame:CGRectMake(_label1.frame.origin.x, _label1.frame.origin.y-4, _label1.frame.size.width, _label1.frame.size.height)];
    [_label2 setFrame:CGRectMake(_label2.frame.origin.x, _label2.frame.origin.y-4, _label2.frame.size.width, _label2.frame.size.height)];
    _label1.transform=CGAffineTransformMakeRotation(M_PI / -4);
    _label2.transform=CGAffineTransformMakeRotation(M_PI / -4);
    [UIView animateWithDuration:0.3 delay:0.0 options:0
                     animations:^{
                         _label1.transform=CGAffineTransformMakeRotation(0);
                         [_splashImageView setFrame:CGRectMake(_splashImageView.frame.origin.x, _splashImageView.frame.origin.y-50, _splashImageView.frame.size.width, _splashImageView.frame.size.height)];
                         [_label1 setFrame:CGRectMake(_label1.frame.origin.x, _splashImageView.frame.origin.y+110, _label1.frame.size.width, _label1.frame.size.height)];
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.3 delay:0.1 options:0
                                          animations:^{
                                              _label2.transform=CGAffineTransformMakeRotation(0);
                                              [_label2 setFrame:CGRectMake(_label2.frame.origin.x, _label1.frame.origin.y+_label2.frame.size.height, _label2.frame.size.width, _label2.frame.size.height)];
                                          }
                                          completion:^(BOOL finished) {
                                              [UIView animateWithDuration:0.3 delay:0.0 options:0
                                                               animations:^{
                                                                   [_rightsLabel setAlpha:0.5];
                                                                   [_rightsLabel setFrame:CGRectMake(_rightsLabel.frame.origin.x, self.view.frame.size.height-_rightsLabel.frame.size.height, _rightsLabel.frame.size.width, _rightsLabel.frame.size.height)];
                                                               }
                                                               completion:^(BOOL finished) {
                                                                   [UIView animateWithDuration:0.3 delay:1.0 options:0
                                                                                    animations:^{
                                                                                        [_splashImageView setFrame:CGRectMake(_splashImageView.frame.origin.x, _splashImageView.frame.origin.y+self.view.frame.size.height, _splashImageView.frame.size.width, _splashImageView.frame.size.height)];
                                                                                        
                                                                                        [_label1 setFrame:CGRectMake(_label1.frame.origin.x, _label1.frame.origin.y+self.view.frame.size.height, _label1.frame.size.width, _label1.frame.size.height)];
                                                                                        
                                                                                        [_label2 setFrame:CGRectMake(_label2.frame.origin.x, _label2.frame.origin.y+self.view.frame.size.height, _label2.frame.size.width, _label2.frame.size.height)];
                                                                                        
                                                                                        [_rightsLabel setFrame:CGRectMake(_rightsLabel.frame.origin.x, _rightsLabel.frame.origin.y+self.view.frame.size.height, _rightsLabel.frame.size.width, _rightsLabel.frame.size.height)];
                                                                                    }
                                                                                    completion:^(BOOL finished) {
                                                                                        [self performSegueWithIdentifier:@"firstSeg" sender:self];
                                                                                    }];
                                                                   [UIView commitAnimations];
                                                               }];
                                              [UIView commitAnimations];
                                          }];
                         [UIView commitAnimations];
                     }];
    [UIView commitAnimations];
}

-(void)setRights
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"YYYY"];
    
    _rightsLabel.text = [@"" stringByAppendingFormat:@"Copyright (c) %@ SADAH Software Solutions, LLC. All rights reserved.",[dateFormatter stringFromDate:[NSDate date]]];
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
