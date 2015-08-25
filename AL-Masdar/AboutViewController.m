//
//  AboutViewController.m
//
//  Created by Housein Jouhar on 2/18/14.
//  Copyright (c) 2014 SADAH Software Solutions. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [UIView animateWithDuration:0.2 delay:0.0 options:0
                     animations:^{
                         [[self.navigationController navigationBar] setBarTintColor:[UIColor blackColor]];
                         [[self.navigationController navigationBar] setTintColor:[UIColor whiteColor]];
                         [[self.navigationController navigationBar] setBarStyle:UIBarStyleBlack];
                     }
                     completion:^(BOOL finished) {
                         //
                     }];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [UIView animateWithDuration:0.2 delay:0.0 options:0
                     animations:^{
                         [_moreButton setAlpha:0.3];
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.2 delay:0.0 options:0
                                          animations:^{
                                              [_moreButton setAlpha:1.0];
                                          }
                                          completion:^(BOOL finished) {
                                              [UIView animateWithDuration:0.2 delay:0.0 options:0
                                                               animations:^{
                                                                   [_moreButton setAlpha:0.3];
                                                               }
                                                               completion:^(BOOL finished) {
                                                                   [UIView animateWithDuration:0.2 delay:0.0 options:0
                                                                                    animations:^{
                                                                                        [_moreButton setAlpha:1.0];
                                                                                    }
                                                                                    completion:^(BOOL finished) {
                                                                                        //
                                                                                    }];
                                                               }];
                                          }];
                     }];
    [UIView commitAnimations];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _verLabel.text = [@"الإصدار: " stringByAppendingFormat:@"%.1f",[[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] floatValue]];
    
    [self setRights];
}

-(void)setRights
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"YYYY"];
    
    _rightsLabel.text = [@"" stringByAppendingFormat:@"Copyright (c) %@ SADAH Software Solutions, LLC. All rights reserved.",[dateFormatter stringFromDate:[NSDate date]]];
}

- (IBAction)openMore:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/tw/artist/sadah-software-solutions-llc/id460047429"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
