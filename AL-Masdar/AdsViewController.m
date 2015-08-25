//
//  MedalViewController.m
//  Subha - السبحة
//
//  Created by Hussein Jouhar on 05/30/15.
//  Copyright (c) 2015 SADAH Software Solutions, LLC. All rights reserved.
//

#import "AdsViewController.h"

@interface AdsViewController ()

@end

@implementation AdsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)closeAds:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSDictionary *jsonResponse = [[NSUserDefaults standardUserDefaults] objectForKey:@"adsJsonData"];
    
    [_adImage setContentMode:UIViewContentModeScaleAspectFit];
    
    [_adImage sd_setImageWithURL:[NSURL URLWithString:[jsonResponse objectForKey:@"adsIcon"]]
                                          placeholderImage:[UIImage imageNamed:@"update-wait-img.png"]];
    
    _adTitle.text = [jsonResponse objectForKey:@"adsTitle"];
    _adMsg.text = [jsonResponse objectForKey:@"adsMsg"];
    
    if ([[jsonResponse objectForKey:@"adsButtonTitle"] length] == 0)
    {
        [_adButton setTitle:@"إغلاق" forState:UIControlStateNormal];
    }
    else
    {
        [_adButton setTitle:[jsonResponse objectForKey:@"adsButtonTitle"] forState:UIControlStateNormal];
    }
}

- (IBAction)openAdLink:(id)sender {
    NSDictionary *jsonResponse = [[NSUserDefaults standardUserDefaults] objectForKey:@"adsJsonData"];
    
    if ([[jsonResponse objectForKey:@"adsButtonTitle"] length] == 0)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[jsonResponse objectForKey:@"buttonUrl"]]];
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
