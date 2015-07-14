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
#import "CountryChooserTableViewController.h"
#import "SourceChooserTableViewController.h"
#import "CRToastManager.h"
#import "CRToast.h"


#import <PQFCustomLoaders/PQFCustomLoaders.h>
//#import <CoreLocation/CoreLocation.h>

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
//@property (nonatomic, strong) PQFBouncingBalls *bouncingBalls;
@end

@implementation ViewController
{
    NSMutableArray* dataSource;
    NSMutableArray* sectionsAvailble;
    NSMutableArray* iconsArray;
    BOOL locationDone;
    BOOL sourcesDone;
    NSString* userCountry;
    __weak IBOutlet UITableView *tableView;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier]isEqualToString:@"countrySeg"])
    {
        CountryChooserTableViewController* dst = (CountryChooserTableViewController*)[segue destinationViewController];
        [dst setDataSource:dataSource];
    }else if([[segue identifier]isEqualToString:@"sourcesSeg2"])
    {
        SourceChooserTableViewController* dst = (SourceChooserTableViewController*)[segue destinationViewController];
        [dst setDataSourcee:dataSource];
        [dst setSection:@""];
        [dst setCountry:userCountry];
    }else if([[segue identifier]isEqualToString:@"sourcesSeg1"])
    {
        SourceChooserTableViewController* dst = (SourceChooserTableViewController*)[segue destinationViewController];
        [dst setDataSourcee:dataSource];
        [dst setSection:[sectionsAvailble objectAtIndex:tableView.indexPathForSelectedRow.row]];
        [dst setCountry:@""];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"isFirstLoad"])
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isFirstLoad"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isSoundEffects"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isReadability"];
        [[NSUserDefaults standardUserDefaults] setInteger:2 forKey:@"currentColor"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [self showTheStatusBar];
    
    dataSource = [[NSMutableArray alloc]init];
    sectionsAvailble = [[NSMutableArray alloc]init];
    iconsArray = [[NSMutableArray alloc]init];
    
    [tableView setDelegate:self];
    [tableView setNeedsDisplay];
    
    locationDone = YES;
    sourcesDone = NO;
    
    userCountry = @"";
    
    if(![[[NSUserDefaults standardUserDefaults] objectForKey:@"subscriptions"]count] == 0)
    {
        //[self performSegueWithIdentifier:@"newsSeg" sender:self];
        UIViewController *aYourViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"theNewsSeg"];
        [self.navigationController pushViewController:aYourViewController animated:NO];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!isAllLoaded)
    {
        [self addActivityView];
        
        [self performSelector:@selector(doTheReload) withObject:nil afterDelay:0.1];
        
        isAllLoaded = YES;
    }
    
    [self setTheColor];
    
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:animated];
}

-(void)setTheColor
{
//    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
//    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
//    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:20.0/255.0 green:20.0/255.0 blue:20.0/255.0 alpha:1.0]];
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"currentColor"] == 1)
    {
        [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
        [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
        [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:50.0/255.0 green:50.0/255.0 blue:50.0/255.0 alpha:1.0]];
    }
    else if ([[NSUserDefaults standardUserDefaults] integerForKey:@"currentColor"] == 2)
    {
        [self.navigationController.navigationBar setBarStyle:UIBarStyleDefault];
        [self.navigationController.navigationBar setTintColor:[UIColor colorWithRed:37.0/255.0 green:37.0/255.0 blue:37.0/255.0 alpha:1.0]];
        [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:241.0/255.0 green:241.0/255.0 blue:241.0/255.0 alpha:1.0]];
    }
    else if ([[NSUserDefaults standardUserDefaults] integerForKey:@"currentColor"] == 3)
    {
        [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
        [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
        [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:33.0/255.0 green:125.0/255.0 blue:140.0/255.0 alpha:1.0]];
    }
    else if ([[NSUserDefaults standardUserDefaults] integerForKey:@"currentColor"] == 4)
    {
        [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
        [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
        [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:118.0/255.0 green:0.0/255.0 blue:161.0/255.0 alpha:1.0]];
    }
    else if ([[NSUserDefaults standardUserDefaults] integerForKey:@"currentColor"] == 5)
    {
        [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
        [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
        [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:26.0/255.0 green:140.0/255.0 blue:55.0/255.0 alpha:1.0]];
    }
    else if ([[NSUserDefaults standardUserDefaults] integerForKey:@"currentColor"] == 6)
    {
        [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
        [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
        [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:185.0/255.0 green:21.0/255.0 blue:57.0/255.0 alpha:1.0]];
    }
    else
    {
        [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
        [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
        [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:50.0/255.0 green:50.0/255.0 blue:50.0/255.0 alpha:1.0]];
    }
}

-(void)addActivityView
{
    [self hideTheStatusBar];
    for (UIView *view in [[self navigationController]view].subviews)
    {
        if (view.tag == 383)
        {
            [view removeFromSuperview];
            break;
        }
    }
    
    UIView *backView = [[UIView alloc] initWithFrame:self.navigationController.view.frame];
    
    backView.backgroundColor = [UIColor blackColor];
    
    [backView setAlpha:0.0];
    
    [backView setTag:383];
    
    [[self.navigationController view] addSubview:backView];
    
    UIImageView *loadingImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 73, 20)];
    
    loadingImg.center = backView.center;
    
    [backView addSubview:loadingImg];
    
    loadingImg.animationImages = [NSArray arrayWithObjects:[UIImage imageNamed:@"wait-table-img-1.png"], [UIImage imageNamed:@"wait-table-img-2.png"],[UIImage imageNamed:@"wait-table-img-3.png"],nil];
    [loadingImg setAnimationRepeatCount:9999];
    loadingImg.animationDuration = 0.6;
    [loadingImg startAnimating];
    
    [UIView animateWithDuration:0.2 delay:0.0 options:0
                     animations:^{
                         [backView setAlpha:1.0];
                     }
                     completion:^(BOOL finished) {
                         
                     }];
    
    [UIView commitAnimations];
}

-(void)removeActivityView
{
    [self showTheStatusBar];
    [UIView animateWithDuration:0.2 delay:0.0 options:0
                     animations:^{
                         [[[[self navigationController] view] viewWithTag:383] setAlpha:0.0];
                     }
                     completion:^(BOOL finished) {
                         [[[[self navigationController] view] viewWithTag:383] removeFromSuperview];
                         [tableView setHidden:NO];
                     }];
    
    [UIView commitAnimations];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void)showTheStatusBar
{
    isShowStatus = YES;
    [self setNeedsStatusBarAppearanceUpdate];
}

-(void)hideTheStatusBar
{
    isShowStatus = NO;
    [self setNeedsStatusBarAppearanceUpdate];
}

- (BOOL)prefersStatusBarHidden {
    return !isShowStatus;
}

-(void)doTheReload
{
    if(![self connected])
    {
        [self performSegueWithIdentifier:@"NoConnectionSeg" sender:self];
    }else
    {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        
        [manager POST:@"http://moh2013.com/arabDevs/almasdar/getSources.php" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            dataSource = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
            
            for(NSDictionary* dict in dataSource)
            {
                if(![sectionsAvailble containsObject:[dict objectForKey:@"section"]])
                {
                    [sectionsAvailble addObject:[dict objectForKey:@"section"]];
                }
                
                if(![iconsArray containsObject:[dict objectForKey:@"sourceImage"]])
                {
                    [iconsArray addObject:[dict objectForKey:@"sourceImage"]];
                }
            }
            
            sourcesDone = YES;
            if(locationDone && sourcesDone)
            {
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
                userCountry = [self getUserCountry];
                //[self.bouncingBalls removeLoader];
                [self removeActivityView];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [tableView reloadData];
                    [tableView setNeedsDisplay];
                });
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [tableView reloadData];
                [tableView setNeedsDisplay];
            });
        }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            sourcesDone = YES;
            if(locationDone && sourcesDone)
            {
                //[self.bouncingBalls removeLoader];
                [self removeActivityView];
            }
            NSLog(@"Error: %@", error);
        }];
    }
}

-(NSString*)getUserCountry
{
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://ip-api.com/json"]];
    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest: request
                                                 returningResponse: &response
                                                             error: &error];
    NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:nil];
    
    NSString *country = [[dict objectForKey:@"country"] lowercaseString];
    
    if([country rangeOfString:@"kuwait" options:NSCaseInsensitiveSearch].location != NSNotFound)
    {
        return @"الكويت";
    }else  if([country rangeOfString:@"egypt" options:NSCaseInsensitiveSearch].location != NSNotFound)
    {
        return @"مصر";
    }else  if([country rangeOfString:@"saudi" options:NSCaseInsensitiveSearch].location != NSNotFound || [country rangeOfString:@"ksa" options:NSCaseInsensitiveSearch].location != NSNotFound)
    {
        return @"السعودية";
    }else  if([country rangeOfString:@"emirates" options:NSCaseInsensitiveSearch].location != NSNotFound || [country rangeOfString:@"u.a.e" options:NSCaseInsensitiveSearch].location != NSNotFound || [country rangeOfString:@"uae" options:NSCaseInsensitiveSearch].location != NSNotFound)
    {
        return @"الإمارات";
    }else  if([country rangeOfString:@"lebanon" options:NSCaseInsensitiveSearch].location != NSNotFound)
    {
        return @"لبنان";
    }else  if([country rangeOfString:@"qatar" options:NSCaseInsensitiveSearch].location != NSNotFound)
    {
        return @"قطر";
    }else  if([country rangeOfString:@"syria" options:NSCaseInsensitiveSearch].location != NSNotFound)
    {
        return @"سوريا";
    }else  if([country rangeOfString:@"bahrain" options:NSCaseInsensitiveSearch].location != NSNotFound)
    {
        return @"البحرين";
    }else  if([country rangeOfString:@"jordan" options:NSCaseInsensitiveSearch].location != NSNotFound)
    {
        return @"الأردن";
    }else  if([country rangeOfString:@"palestine" options:NSCaseInsensitiveSearch].location != NSNotFound)
    {
        return @"فلسطين";
    }else  if([country rangeOfString:@"tunisia" options:NSCaseInsensitiveSearch].location != NSNotFound)
    {
        return @"تونس";
    }else  if([country rangeOfString:@"oman" options:NSCaseInsensitiveSearch].location != NSNotFound)
    {
        return @"عمان";
    }else  if([country rangeOfString:@"yemen" options:NSCaseInsensitiveSearch].location != NSNotFound)
    {
        return @"اليمن";
    }else  if([country rangeOfString:@"morocco" options:NSCaseInsensitiveSearch].location != NSNotFound)
    {
        return @"المغرب";
    }else  if([country rangeOfString:@"libya" options:NSCaseInsensitiveSearch].location != NSNotFound)
    {
        return @"ليبيا";
    }else  if([country rangeOfString:@"algeria" options:NSCaseInsensitiveSearch].location != NSNotFound)
    {
        return @"الجزائر";
    }else  if([country rangeOfString:@"sudan" options:NSCaseInsensitiveSearch].location != NSNotFound)
    {
        return @"السودان";
    }else  if([country rangeOfString:@"iraq" options:NSCaseInsensitiveSearch].location != NSNotFound)
    {
        return @"العراق";
    }
    
    return @"";
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
        return sectionsAvailble.count;
    }else
    {
        if(section == 0)
        {
            return 1;
        }else
        {
            return sectionsAvailble.count;
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
    
    cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"settings-selected-back.png"]];
    
    if([userCountry isEqualToString:@""])
    {
        [(UILabel*)[cell viewWithTag:1] setText:[sectionsAvailble objectAtIndex:indexPath.row]];
    }else
    {
        if(indexPath.section == 0 && indexPath.row == 0)
        {
            [(UILabel*)[cell viewWithTag:1] setText:userCountry];
        }
        else if(indexPath.section == 1)
        {
            [(UILabel*)[cell viewWithTag:1] setText:[sectionsAvailble objectAtIndex:indexPath.row]];
        }
    }
    
    if(![userCountry isEqualToString:@""] && indexPath.row == 0 && indexPath.section == 0)
    {
        if (iconsArray.count > indexPath.row)
        {
            [[[cell viewWithTag:2] layer] setCornerRadius:22];
            [cell viewWithTag:2].layer.shouldRasterize = YES;
            
            
            if (iconsArray.count > [sectionsAvailble indexOfObject:userCountry])
            {
                [(UIImageView*)[cell viewWithTag:2] hnk_setImageFromURL:[NSURL URLWithString:[[iconsArray objectAtIndex:[sectionsAvailble indexOfObject:userCountry]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholder:[UIImage imageNamed:@"loading-img.png"]];
            }
            else
            {
                [(UIImageView*)[cell viewWithTag:2] hnk_setImageFromURL:[NSURL URLWithString:[[iconsArray objectAtIndex:indexPath.row] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholder:[UIImage imageNamed:@"loading-img.png"]];
            }
        }
    }
    else
    {
        if (iconsArray.count > indexPath.row)
        {
            [[[cell viewWithTag:2] layer] setCornerRadius:22];
            [cell viewWithTag:2].layer.shouldRasterize = YES;
            
            [(UIImageView*)[cell viewWithTag:2] hnk_setImageFromURL:[NSURL URLWithString:[[iconsArray objectAtIndex:indexPath.row] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholder:[UIImage imageNamed:@"loading-img.png"]];
        }
    }
    
//    if (indexPath.row == 0)
//    {
//        [(UIImageView*)[cell viewWithTag:2] setImage:[UIImage imageNamed:@"arab-icon.png"]];
//    }
//    else if (indexPath.row == 1)
//    {
//        [(UIImageView*)[cell viewWithTag:2] setImage:[UIImage imageNamed:@"world-icon.png"]];
//    }
//    else if (indexPath.row == 2)
//    {
//        [(UIImageView*)[cell viewWithTag:2] setImage:[UIImage imageNamed:@"tech-icon.png"]];
//    }
//    else
//    {
//        [(UIImageView*)[cell viewWithTag:2] setImage:[UIImage imageNamed:@"sport-icon.png"]];
//    }
    
    return cell;
}

-(UIView *)tableView:(UITableView *)tableView2 viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView2.frame.size.width, 30)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView2.frame.size.width, 30)];
    [label setFont:[UIFont systemFontOfSize:16]];
    [label setTextAlignment:NSTextAlignmentRight];
    [label setTextColor:[UIColor colorWithRed:50.0/255.0 green:50.0/255.0 blue:50.0/255.0 alpha:1.0]];
    
    if([userCountry isEqualToString:@""])
    {
        if(section == 0)
        {
            [label setText:@"  المصادر المتاحة"];
        }
    }else
    {
        if(section == 0)
        {
            [label setText:@"  مصادر بالقرب منك"];
        }else
        {
            [label setText:@"  المصادر الأخرى"];
        }
    }
    
    [view addSubview:label];
    [view setBackgroundColor:[UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:0.9]];
    return view;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(![userCountry isEqualToString:@""] && indexPath.section == 0)
    {
        [self performSegueWithIdentifier:@"sourcesSeg2" sender:self];
    }else
    {
        if([[sectionsAvailble objectAtIndex:indexPath.row] isEqualToString:@"صحف عربية"])
        {
            [self performSegueWithIdentifier:@"countrySeg" sender:self];
        }else
        {
            [self performSegueWithIdentifier:@"sourcesSeg1" sender:self];
        }
    }
}


#pragma mark location delegate

- (IBAction)doneClicked:(id)sender {
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"subscriptions"]count] == 0)
    {
        NSDictionary *options = @{
                                  kCRToastTextKey : @"يجب تحديد مصدر واحد على الأقل",
                                  kCRToastTextAlignmentKey : @(NSTextAlignmentCenter),
                                  kCRToastBackgroundColorKey : [UIColor colorWithRed:209.0/255.0 green:65.0/255.0 blue:65.0/255.0 alpha:1.0],
                                  kCRToastAnimationInTypeKey : @(CRToastAnimationTypeLinear),
                                  kCRToastAnimationOutTypeKey : @(CRToastAnimationTypeLinear),
                                  kCRToastAnimationInDirectionKey : @(CRToastAnimationDirectionTop),
                                  kCRToastAnimationOutDirectionKey : @(CRToastAnimationDirectionBottom)
                                  };
        [CRToastManager showNotificationWithOptions:options
                                    completionBlock:^{
                                        NSLog(@"Completed");
                                    }];

    }else
    {
        [self performSegueWithIdentifier:@"newsSeg" sender:self];
    }
}

@end
