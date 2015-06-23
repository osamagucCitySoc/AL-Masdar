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
#import <CoreLocation/CoreLocation.h>

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@interface ViewController ()<CLLocationManagerDelegate,UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) PQFBouncingBalls *bouncingBalls;
@end

@implementation ViewController
{
    NSMutableArray* dataSource;
    CLLocationManager* locationManager;
    CLLocation* currentLocation;
    BOOL locationDone;
    BOOL sourcesDone;
    CLLocation* myLocation;
    NSString* userCountry;
    __weak IBOutlet UITableView *tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    dataSource = [[NSMutableArray alloc]init];
    
    [tableView setDelegate:self];
    [tableView setNeedsDisplay];
    
    locationDone = NO;
    sourcesDone = NO;
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone; //whenever we move
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if(IS_OS_8_OR_LATER) {
        [locationManager requestWhenInUseAuthorization];
    }
    
    [locationManager startUpdatingLocation];
    
    userCountry = @"";
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
        self.bouncingBalls = [PQFBouncingBalls createLoaderOnView:tableView];
        self.bouncingBalls.jumpAmount = 50;
        self.bouncingBalls.zoomAmount = 20;
        self.bouncingBalls.separation = 20;
        self.bouncingBalls.loaderColor = [UIColor blackColor];
        [self.bouncingBalls showLoader];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        
        [manager POST:@"http://moh2013.com/arabDevs/almasdar/getSources.php" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            dataSource = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
            sourcesDone = YES;
            if(locationDone && sourcesDone)
            {
                if(myLocation)
                {
                    ReverseGeocodeCountry *reverseGeocode = [[ReverseGeocodeCountry alloc] init];
                    userCountry = [reverseGeocode getCountry:[myLocation coordinate].latitude :[myLocation coordinate].longitude];
                    userCountry = [userCountry lowercaseString];
                    BOOL found = NO;
                    for(NSDictionary* dict in dataSource)
                    {
                        if([[dict objectForKey:@"countryEN"] isEqualToString:userCountry])
                        {
                            found = YES;
                            userCountry = [dict objectForKey:@"countryAR"];
                            break;
                        }
                    }
                    if(!found)
                    {
                        userCountry = @"";
                    }
                    [self.bouncingBalls removeLoader];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [tableView reloadData];
                        [tableView setNeedsDisplay];
                    });
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [tableView reloadData];
                [tableView setNeedsDisplay];
            });
        }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            sourcesDone = YES;
            if(locationDone && sourcesDone)
            {
                [self.bouncingBalls removeLoader];
            }
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


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if([userCountry isEqualToString:@""])
    {
        return 1;
    }else
    {
        return 2;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if([userCountry isEqualToString:@""])
    {
        return 2;
    }else
    {
        if(section == 0)
        {
            return 1;
        }else
        {
            return 2;
        }
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableVieww cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellID = @"sourcesCell";
    UITableViewCell *cell = [tableVieww dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    
    if([userCountry isEqualToString:@""])
    {
        if(indexPath.row == 0)
        {
            [[cell textLabel]setText:@"المصادر العربية"];
        }else
        {
            [[cell textLabel]setText:@"المصادر العالمية"];
        }
    }else
    {
        if(indexPath.section == 0 && indexPath.row == 0)
        {
            [[cell textLabel]setText:userCountry];
        }
        else if(indexPath.section == 1 && indexPath.row == 0)
        {
            [[cell textLabel]setText:@"المصادر العربية"];
        }else if(indexPath.section == 1 && indexPath.row == 1)
        {
            [[cell textLabel]setText:@"المصادر العالمية"];
        }
    }
    
    
    return cell;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if([userCountry isEqualToString:@""])
    {
        if(section == 0)
        {
            return @"المصادر المتاحة";
        }
    }else
    {
        if(section == 0)
        {
            return @"مصادر بالقرب منك";
        }else
        {
            return @"المصادر الأخرى";
        }
    }
    
    return @"";
}


#pragma mark location delegate
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    NSLog(@"%@",[locations lastObject]);
    locationDone = YES;
    myLocation = [locations lastObject];
    ReverseGeocodeCountry *reverseGeocode = [[ReverseGeocodeCountry alloc] init];
    userCountry = [reverseGeocode getCountry:[[locations lastObject] coordinate].latitude :[[locations lastObject] coordinate].longitude];
    userCountry = [userCountry lowercaseString];
    BOOL found = NO;
    if(locationDone && sourcesDone)
    {
        for(NSDictionary* dict in dataSource)
        {
            if([[dict objectForKey:@"countryEN"] isEqualToString:userCountry])
            {
                found = YES;
                userCountry = [dict objectForKey:@"countryAR"];
                break;
            }
        }
        if(!found)
        {
            userCountry = @"";
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [tableView reloadData];
            [tableView setNeedsDisplay];
        });
        [self.bouncingBalls removeLoader];
    }
    
    [locationManager stopUpdatingLocation];
}


- (void)locationManager:(CLLocationManager*)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined: {
            NSLog(@"User still thinking..");
            locationDone = NO;
        } break;
        case kCLAuthorizationStatusDenied: {
            locationDone = YES;
            NSLog(@"User hates you");
        } break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:{
        } break;
        default:
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    locationDone = YES;
}


@end
