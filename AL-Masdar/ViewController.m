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
#import "AFHTTPRequestOperationManager.h"
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
        self.bouncingBalls = [PQFBouncingBalls createLoaderOnView:self.view];
        self.bouncingBalls.jumpAmount = 50;
        self.bouncingBalls.zoomAmount = 20;
        self.bouncingBalls.separation = 20;
        self.bouncingBalls.loaderColor = [UIColor blackColor];
        [self.bouncingBalls showLoader];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];

        
        [manager POST:@"http://moh2013.com/arabDevs/almasdar/getSources.php" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            dataSource = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
            [self.bouncingBalls removeLoader];
        }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self.bouncingBalls removeLoader];
            NSLog(@"Error: %@", error);
        }];
    }
}


- (BOOL)connected
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return networkStatus != NotReachable;
}

@end
