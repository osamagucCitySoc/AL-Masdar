//
//  ViewController.m
//  AL-Masdar
//
//  Created by Osama Rabie on 6/23/15.
//  Copyright (c) 2015 Osama Rabie. All rights reserved.
//

#import "ViewController.h"
#import "ReverseGeocodeCountry.h"
#import "Reachability.h"
#import <PQFCustomLoaders/PQFCustomLoaders.h>

@interface ViewController ()
@property (nonatomic, strong) PQFBouncingBalls *bouncingBalls;
@end

@implementation ViewController
{
    NSMutableArray* dataSource;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(![self connected])
    {
        [self performSegueWithIdentifier:@"NoConnectionSeg" sender:self];
    }else
    {
        self.bouncingBalls = [PQFBouncingBalls createModalLoader];
        self.bouncingBalls.jumpAmount = 50;
        self.bouncingBalls.zoomAmount = 20;
        self.bouncingBalls.separation = 20;
        [self.bouncingBalls showLoader];
    }
}


- (BOOL)connected
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return networkStatus != NotReachable;
}

@end
