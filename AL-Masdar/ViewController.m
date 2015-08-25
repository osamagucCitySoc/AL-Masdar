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
    NSMutableArray* arabicSources;
    NSMutableArray* otherSources;
    NSMutableArray* iconsArray;
    NSMutableArray* searchArray;
    NSArray *ctArr;
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
        
        NSInteger theSection = tableView.indexPathForSelectedRow.section;
        NSInteger theRow = tableView.indexPathForSelectedRow.row;
        NSString *finalStr = @"";
        
        if([[[NSUserDefaults standardUserDefaults] objectForKey:@"subscriptions"]count] != 0)
        {
            if(![userCountry isEqualToString:@""])
            {
                if (theSection == 0)
                {
                    finalStr = @"onlyMySources";
                }
                else if (theSection == 1)
                {
                    finalStr = [sectionsAvailble objectAtIndex:[sectionsAvailble indexOfObject:userCountry]];
                }
                else if (theSection == 2)
                {
                    finalStr = [sectionsAvailble objectAtIndex:[sectionsAvailble indexOfObject:[arabicSources objectAtIndex:theRow]]];
                }
                else if (theSection == 3)
                {
                    finalStr = [sectionsAvailble objectAtIndex:[sectionsAvailble indexOfObject:@"مصادر عالمية"]];
                }
                else
                {
                    finalStr = [sectionsAvailble objectAtIndex:[sectionsAvailble indexOfObject:[otherSources objectAtIndex:theRow]]];
                }
            }
            else
            {
                if (theSection == 0)
                {
                    finalStr = @"onlyMySources";
                }
                else if (theSection == 1)
                {
                    finalStr = [sectionsAvailble objectAtIndex:[sectionsAvailble indexOfObject:[arabicSources objectAtIndex:theRow]]];
                }
                else if (theSection == 2)
                {
                    finalStr = [sectionsAvailble objectAtIndex:[sectionsAvailble indexOfObject:@"مصادر عالمية"]];
                }
                else
                {
                    finalStr = [sectionsAvailble objectAtIndex:[sectionsAvailble indexOfObject:[otherSources objectAtIndex:theRow]]];
                }
            }
        }
        else
        {
            if(![userCountry isEqualToString:@""])
            {
                if (theSection == 0)
                {
                    finalStr = [sectionsAvailble objectAtIndex:[sectionsAvailble indexOfObject:userCountry]];
                }
                else if (theSection == 1)
                {
                    finalStr = [sectionsAvailble objectAtIndex:[sectionsAvailble indexOfObject:[arabicSources objectAtIndex:theRow]]];
                }
                else if (theSection == 2)
                {
                    finalStr = [sectionsAvailble objectAtIndex:[sectionsAvailble indexOfObject:@"مصادر عالمية"]];
                }
                else
                {
                    finalStr = [sectionsAvailble objectAtIndex:[sectionsAvailble indexOfObject:[otherSources objectAtIndex:theRow]]];
                }
            }
            else
            {
                if (theSection == 0)
                {
                    finalStr = [sectionsAvailble objectAtIndex:[sectionsAvailble indexOfObject:[arabicSources objectAtIndex:theRow]]];
                }
                else if (theSection == 1)
                {
                    finalStr = [sectionsAvailble objectAtIndex:[sectionsAvailble indexOfObject:@"مصادر عالمية"]];
                }
                else
                {
                    finalStr = [sectionsAvailble objectAtIndex:[sectionsAvailble indexOfObject:[otherSources objectAtIndex:theRow]]];
                }
            }
        }
        
        [dst setSection:finalStr];
        [dst setCountry:@""];
    }
}

-(BOOL)isCity:(NSString*)theBody
{
    NSArray *countriesArr = [NSArray arrayWithObjects:@"السعودية",@"مصر",@"لبنان",@"الكويت",@"سوريا",@"الإمارات",@"قطر",@"البحرين",@"الأردن",@"فلسطين",@"تونس",@"عمان",@"اليمن",@"المغرب",@"الجزائر",@"السودان",@"العراق",@"الصومال",@"موريتانيا", nil];
    
    for (int i = 0; i < countriesArr.count; i++)
    {
        if ([theBody rangeOfString:[countriesArr objectAtIndex:i]].location != NSNotFound)
        {
            return YES;
        }
    }
    
    return NO;
}

-(void)getYoutubeLink
{
    NSURL *storeURL = [NSURL URLWithString:@"https://dl.dropboxusercontent.com/u/59230746/Al-Masdar/youtube-link.txt"];
    
    NSMutableURLRequest *storeRequest = [NSMutableURLRequest requestWithURL:storeURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:storeRequest queue:queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               if (!connectionError) {
                                   NSError *error;
                                   
                                   NSString *firstdataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                   
                                   if (error)
                                   {
                                       NSLog(@"Error: %@",error.description);
                                   }
                                   else
                                   {
                                       [[NSUserDefaults standardUserDefaults] setObject:firstdataStr forKey:@"youtubeLink"];
                                       [[NSUserDefaults standardUserDefaults] synchronize];
                                       
                                       NSLog(@"linkSaved:\n%@",firstdataStr);
                                   }
                               }
                           }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"isFirstLoad"])
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isFirstLoad"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isSoundEffects"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isReadability"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isAutoNight"];
        [[NSUserDefaults standardUserDefaults] setInteger:2 forKey:@"currentColor"];
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"selectedSound"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [_searchTextField addTarget:self
                  action:@selector(textFieldDidChange:)
        forControlEvents:UIControlEventEditingChanged];
    
    [self getYoutubeLink];
    
    [[UINavigationBar appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont fontWithName:@"DroidArabicKufi" size:17.0], NSFontAttributeName,nil]];
    
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"DroidArabicKufi" size:15.0], NSFontAttributeName, nil] forState:UIControlStateNormal];
    
    [[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"DroidArabicKufi" size:15.0], NSFontAttributeName, nil] forState:UIControlStateNormal];
    
    [self showTheStatusBar];
    
    dataSource = [[NSMutableArray alloc]init];
    sectionsAvailble = [[NSMutableArray alloc]init];
    
    arabicSources = [[NSMutableArray alloc]init];
    otherSources = [[NSMutableArray alloc]init];
    
    iconsArray = [[NSMutableArray alloc]init];
    
    [tableView setDelegate:self];
    [tableView setNeedsDisplay];
    
    locationDone = YES;
    sourcesDone = NO;
    
    userCountry = @"";
    
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"subscriptions"]count] != 0)
    {
        UIViewController *aYourViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"theNewsSeg"];
        [self.navigationController pushViewController:aYourViewController animated:NO];
    }
}

- (IBAction)startSearch:(id)sender {
    [self showSearchView];
}

- (IBAction)cancelSearch:(id)sender {
    [self hideSearchView];
}

-(void)showSearchView
{
    currentSubNum = [[[NSUserDefaults standardUserDefaults] objectForKey:@"subscriptions"] count];
    
    searchArray = [[NSMutableArray alloc] initWithArray:dataSource];
    
    _searchTextField.text = @"";
    
    isSearching = YES;
    [tableView reloadData];
    [self.navigationController.view addSubview:_searchView];
    [_searchView setAlpha:0.0];
    [_searchView setFrame:CGRectMake(0, 20, self.navigationController.view.frame.size.width, _searchView.frame.size.height)];
    
    [UIView animateWithDuration:0.2 delay:0.0 options:0
                     animations:^{
                         [_searchView setAlpha:1.0];
                     }
                     completion:^(BOOL finished) {
                         [_searchTextField becomeFirstResponder];
                     }];
    [UIView commitAnimations];
}

-(void)textFieldDidChange:(UITextField *)theTextField{
    if ([_searchTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length != 0)
    {
        [self filterSearchArray];
    }
}

-(void)filterSearchArray
{
    searchArray = [[NSMutableArray alloc] initWithArray:dataSource];
    
    NSMutableArray *filterArr = [[NSMutableArray alloc] init];
    
    NSDictionary* dict;
    
    for (int i = 0; i < searchArray.count; i++)
    {
        dict = [searchArray objectAtIndex:i];
        
        if ([[[dict objectForKey:@"name"] lowercaseString] rangeOfString:[_searchTextField.text lowercaseString]].location != NSNotFound)
        {
            [filterArr addObject:[searchArray objectAtIndex:i]];
        }
    }
    
    searchArray = [[NSMutableArray alloc] initWithArray:filterArr];
    
    [tableView reloadData];
}

-(void)hideSearchView
{
    _searchTextField.text = @"";
    isSearching = NO;
    [tableView reloadData];
    [self checkLoading];
    [searchArray removeAllObjects];
    [_searchTextField resignFirstResponder];
    [UIView animateWithDuration:0.2 delay:0.0 options:0
                     animations:^{
                         [_searchView setAlpha:0.0];
                     }
                     completion:^(BOOL finished) {
                         [_searchView removeFromSuperview];
                     }];
    [UIView commitAnimations];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self checkLoading];
    
    [self setTheColor];
    
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:animated];
}

-(void)checkLoading
{
    if (currentSubNum == 0 && [[[NSUserDefaults standardUserDefaults] objectForKey:@"subscriptions"] count] != 0)
    {
        isAllLoaded = NO;
    }
    else if (currentSubNum > 0 && [[[NSUserDefaults standardUserDefaults] objectForKey:@"subscriptions"] count] == 0)
    {
        isAllLoaded = NO;
    }
    
    if (!isAllLoaded)
    {
        [self addActivityView];
        
        [self performSelector:@selector(doTheReload) withObject:nil afterDelay:0.1];
        
        isAllLoaded = YES;
    }
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    currentSubNum = [[[NSUserDefaults standardUserDefaults] objectForKey:@"subscriptions"] count];
}

-(void)setTheColor
{
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
        [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:0.0/255.0 green:106.0/255.0 blue:161.0/255.0 alpha:1.0]];
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
    
    UIImage *img = [UIImage animatedImageWithImages:[NSArray arrayWithObjects:[UIImage imageNamed:@"wait-table-img-1.png"], [UIImage imageNamed:@"wait-table-img-2.png"],[UIImage imageNamed:@"wait-table-img-3.png"],nil] duration:0.6];
    [loadingImg setImage:img];
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
    dataSource = [[NSMutableArray alloc] init];
    sectionsAvailble = [[NSMutableArray alloc] init];
    iconsArray = [[NSMutableArray alloc] init];
    arabicSources = [[NSMutableArray alloc] init];
    otherSources = [[NSMutableArray alloc] init];
    
    if(![self connected])
    {
        [self performSegueWithIdentifier:@"NoConnectionSeg" sender:self];
    }else
    {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        
        [manager POST:@"http://almasdarapp.com/almasdar/getSources.php" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
            
            for (int i = 0; i < sectionsAvailble.count; i++)
            {
                if ([self isCity:[sectionsAvailble objectAtIndex:i]])
                {
                    [arabicSources addObject:[sectionsAvailble objectAtIndex:i]];
                }
                else if (![[sectionsAvailble objectAtIndex:i] isEqualToString:@"مصادر عالمية"])
                {
                    [otherSources addObject:[sectionsAvailble objectAtIndex:i]];
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
    if (isSearching)return 1;
    
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"subscriptions"]count] != 0)
    {
        if([userCountry isEqualToString:@""])
        {
            return 4;
        }else
        {
            return 5;
        }
    }
    else
    {
        if([userCountry isEqualToString:@""])
        {
            return 3;
        }else
        {
            return 4;
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (isSearching)return searchArray.count;
    
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"subscriptions"]count] != 0)
    {
        if(![userCountry isEqualToString:@""])
        {
            if (section == 0)
            {
                return 1;
            }
            else if (section == 1)
            {
                return 1;
            }
            else if (section == 2)
            {
                return arabicSources.count;
            }
            else if (section == 3)
            {
                return 1;
            }
            else
            {
                return otherSources.count;
            }
        }
        else
        {
            if (section == 0)
            {
                return 1;
            }
            else if (section == 1)
            {
                return arabicSources.count;
            }
            else if (section == 2)
            {
                return 1;
            }
            else
            {
                return otherSources.count;
            }
        }
    }
    else
    {
        if(![userCountry isEqualToString:@""])
        {
            if (section == 0)
            {
                return 1;
            }
            else if (section == 1)
            {
                return arabicSources.count;
            }
            else if (section == 2)
            {
                return 1;
            }
            else
            {
                return otherSources.count;
            }
        }
        else
        {
            if (section == 0)
            {
                return arabicSources.count;
            }
            else if (section == 1)
            {
                return 1;
            }
            else
            {
                return otherSources.count;
            }
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isSearching)return 79.0;
    return 65.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableVieww cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellID;
    
    if (isSearching)
    {
        cellID = @"sourceCell";
    }
    else
    {
        cellID = @"sourcesCell";
    }
    
    UITableViewCell *cell = [tableVieww dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"settings-selected-back.png"]];
    
    if (isSearching)
    {
        NSDictionary* dict = [searchArray objectAtIndex:indexPath.row];
        
        [(UILabel*)[cell viewWithTag:1] setText:[dict objectForKey:@"name"]];
        
        if ([[dict objectForKey:@"descc"] length] == 0)
        {
            [(UILabel*)[cell viewWithTag:4] setText:@"--"];
        }
        else
        {
            [(UILabel*)[cell viewWithTag:4] setText:[dict objectForKey:@"descc"]];
        }
        
        [[[cell viewWithTag:2] layer] setCornerRadius:22];
        [cell viewWithTag:2].layer.shouldRasterize = YES;
        
        [(UIImageView*)[cell viewWithTag:2] hnk_setImageFromURL:[NSURL URLWithString:[dict objectForKey:@"icon"]] placeholder:nil];
        
        if([[[NSUserDefaults standardUserDefaults] objectForKey:@"subscriptions"] containsObject:dict])
        {
            [(UIImageView*)[cell viewWithTag:3] setImage:[UIImage imageNamed:@"check-on.png"]];
        }
        else
        {
            [(UIImageView*)[cell viewWithTag:3] setImage:[UIImage imageNamed:@"check-off.png"]];
        }
    }
    else
    {
        if([[[NSUserDefaults standardUserDefaults] objectForKey:@"subscriptions"]count] != 0)
        {
            if (![userCountry isEqualToString:@""])
            {
                if (iconsArray.count == sectionsAvailble.count && sectionsAvailble.count > 0)
                {
                    if (indexPath.section == 0)
                    {
                        [(UILabel*)[cell viewWithTag:1] setText:@"مصادرك المختارة"];
                        [(UIImageView*)[cell viewWithTag:2] setImage:[UIImage imageNamed:@"current-icon.png"]];
                    }
                    else if (indexPath.section == 1)
                    {
                        [(UILabel*)[cell viewWithTag:1] setText:userCountry];
                        [(UIImageView*)[cell viewWithTag:2] sd_setImageWithURL:[NSURL URLWithString:[[iconsArray objectAtIndex:[sectionsAvailble indexOfObject:userCountry]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:[UIImage imageNamed:@"loading-img.png"]];
                        if ([arabicSources containsObject:userCountry])
                        {
                            [arabicSources removeObject:userCountry];
                            [tableVieww reloadData];
                            NSLog(@"Removed!!!!!!!!!!!!!!");
                        }
                    }
                    else if (indexPath.section == 2)
                    {
                        [(UILabel*)[cell viewWithTag:1] setText:[arabicSources objectAtIndex:indexPath.row]];
                        [(UIImageView*)[cell viewWithTag:2] sd_setImageWithURL:[NSURL URLWithString:[[iconsArray objectAtIndex:[sectionsAvailble indexOfObject:[arabicSources objectAtIndex:indexPath.row]]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:[UIImage imageNamed:@"loading-img.png"]];
                    }
                    else if (indexPath.section == 3)
                    {
                        [(UILabel*)[cell viewWithTag:1] setText:@"مصادر عالمية"];
                        [(UIImageView*)[cell viewWithTag:2] sd_setImageWithURL:[NSURL URLWithString:[[iconsArray objectAtIndex:[sectionsAvailble indexOfObject:@"مصادر عالمية"]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:[UIImage imageNamed:@"loading-img.png"]];
                    }
                    else
                    {
                        [(UILabel*)[cell viewWithTag:1] setText:[otherSources objectAtIndex:indexPath.row]];
                        [(UIImageView*)[cell viewWithTag:2] sd_setImageWithURL:[NSURL URLWithString:[[iconsArray objectAtIndex:[sectionsAvailble indexOfObject:[otherSources objectAtIndex:indexPath.row]]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:[UIImage imageNamed:@"loading-img.png"]];
                    }
                }
            }
            else
            {
                if (iconsArray.count == sectionsAvailble.count && sectionsAvailble.count > 0)
                {
                    if (indexPath.section == 0)
                    {
                        [(UILabel*)[cell viewWithTag:1] setText:@"مصادرك المختارة"];
                        [(UIImageView*)[cell viewWithTag:2] setImage:[UIImage imageNamed:@"current-icon.png"]];
                    }
                    else if (indexPath.section == 1)
                    {
                        [(UILabel*)[cell viewWithTag:1] setText:[arabicSources objectAtIndex:indexPath.row]];
                        [(UIImageView*)[cell viewWithTag:2] sd_setImageWithURL:[NSURL URLWithString:[[iconsArray objectAtIndex:[sectionsAvailble indexOfObject:[arabicSources objectAtIndex:indexPath.row]]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:[UIImage imageNamed:@"loading-img.png"]];
                    }
                    else if (indexPath.section == 2)
                    {
                        [(UILabel*)[cell viewWithTag:1] setText:@"مصادر عالمية"];
                        [(UIImageView*)[cell viewWithTag:2] sd_setImageWithURL:[NSURL URLWithString:[[iconsArray objectAtIndex:[sectionsAvailble indexOfObject:@"مصادر عالمية"]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:[UIImage imageNamed:@"loading-img.png"]];
                    }
                    else
                    {
                        [(UILabel*)[cell viewWithTag:1] setText:[otherSources objectAtIndex:indexPath.row]];
                        [(UIImageView*)[cell viewWithTag:2] sd_setImageWithURL:[NSURL URLWithString:[[iconsArray objectAtIndex:[sectionsAvailble indexOfObject:[otherSources objectAtIndex:indexPath.row]]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:[UIImage imageNamed:@"loading-img.png"]];
                    }
                }
            }
        }
        else
        {
            if (![userCountry isEqualToString:@""])
            {
                if (iconsArray.count == sectionsAvailble.count && sectionsAvailble.count > 0)
                {
                    if (indexPath.section == 0)
                    {
                        [(UILabel*)[cell viewWithTag:1] setText:userCountry];
                        [(UIImageView*)[cell viewWithTag:2] sd_setImageWithURL:[NSURL URLWithString:[[iconsArray objectAtIndex:[sectionsAvailble indexOfObject:userCountry]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:[UIImage imageNamed:@"loading-img.png"]];
                        if ([arabicSources containsObject:userCountry])
                        {
                            [arabicSources removeObject:userCountry];
                            [tableVieww reloadData];
                        }
                    }
                    else if (indexPath.section == 1)
                    {
                        [(UILabel*)[cell viewWithTag:1] setText:[arabicSources objectAtIndex:indexPath.row]];
                        [(UIImageView*)[cell viewWithTag:2] sd_setImageWithURL:[NSURL URLWithString:[[iconsArray objectAtIndex:[sectionsAvailble indexOfObject:[arabicSources objectAtIndex:indexPath.row]]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:[UIImage imageNamed:@"loading-img.png"]];
                    }
                    else if (indexPath.section == 2)
                    {
                        [(UILabel*)[cell viewWithTag:1] setText:@"مصادر عالمية"];
                        [(UIImageView*)[cell viewWithTag:2] sd_setImageWithURL:[NSURL URLWithString:[[iconsArray objectAtIndex:[sectionsAvailble indexOfObject:@"مصادر عالمية"]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:[UIImage imageNamed:@"loading-img.png"]];
                    }
                    else
                    {
                        [(UILabel*)[cell viewWithTag:1] setText:[otherSources objectAtIndex:indexPath.row]];
                        [(UIImageView*)[cell viewWithTag:2] sd_setImageWithURL:[NSURL URLWithString:[[iconsArray objectAtIndex:[sectionsAvailble indexOfObject:[otherSources objectAtIndex:indexPath.row]]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:[UIImage imageNamed:@"loading-img.png"]];
                    }
                }
            }
            else
            {
                if (iconsArray.count == sectionsAvailble.count && sectionsAvailble.count > 0)
                {
                    if (indexPath.section == 0)
                    {
                        [(UILabel*)[cell viewWithTag:1] setText:[arabicSources objectAtIndex:indexPath.row]];
                        [(UIImageView*)[cell viewWithTag:2] sd_setImageWithURL:[NSURL URLWithString:[[iconsArray objectAtIndex:[sectionsAvailble indexOfObject:[arabicSources objectAtIndex:indexPath.row]]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:[UIImage imageNamed:@"loading-img.png"]];
                    }
                    else if (indexPath.section == 1)
                    {
                        [(UILabel*)[cell viewWithTag:1] setText:@"مصادر عالمية"];
                        [(UIImageView*)[cell viewWithTag:2] sd_setImageWithURL:[NSURL URLWithString:[[iconsArray objectAtIndex:[sectionsAvailble indexOfObject:@"مصادر عالمية"]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:[UIImage imageNamed:@"loading-img.png"]];
                    }
                    else
                    {
                        [(UILabel*)[cell viewWithTag:1] setText:[otherSources objectAtIndex:indexPath.row]];
                        [(UIImageView*)[cell viewWithTag:2] sd_setImageWithURL:[NSURL URLWithString:[[iconsArray objectAtIndex:[sectionsAvailble indexOfObject:[otherSources objectAtIndex:indexPath.row]]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:[UIImage imageNamed:@"loading-img.png"]];
                    }
                }
            }
        }
        
        [[[cell viewWithTag:2] layer] setCornerRadius:22];
        [cell viewWithTag:2].layer.shouldRasterize = YES;
    }
    
    return cell;
}

-(UIView *)tableView:(UITableView *)tableView2 viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView2.frame.size.width, 30)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView2.frame.size.width, 30)];
    [label setFont:[UIFont fontWithName:@"DroidArabicKufi" size:14.0]];
    [label setTextAlignment:NSTextAlignmentRight];
    [label setTextColor:[UIColor colorWithRed:50.0/255.0 green:50.0/255.0 blue:50.0/255.0 alpha:1.0]];
    
    if (isSearching)
    {
        if (searchArray.count > 0)
        {
            [label setText:[@"" stringByAppendingFormat:@"  النتائج: (%lu)",(unsigned long)searchArray.count]];
        }
        else
        {
            [label setText:@"  لايوجد نتائج"];
        }
    }
    else
    {
        if([[[NSUserDefaults standardUserDefaults] objectForKey:@"subscriptions"]count] != 0)
        {
            if(![userCountry isEqualToString:@""])
            {
                if (section == 0)
                {
                    [label setText:@"  المصادر الحالية"];
                }
                else if (section == 1)
                {
                    [label setText:@"  مصادر بالقرب منك"];
                }
                else if (section == 2)
                {
                    [label setText:@"  مصادر عربية"];
                }
                else if (section == 3)
                {
                    [label setText:@"  مصادر عالمية"];
                }
                else
                {
                    [label setText:@"  مصادر أخرى"];
                }
            }
            else
            {
                if (section == 0)
                {
                    [label setText:@"  المصادر الحالية"];
                }
                else if (section == 1)
                {
                    [label setText:@"  مصادر عربية"];
                }
                else if (section == 2)
                {
                    [label setText:@"  مصادر عالمية"];
                }
                else
                {
                    [label setText:@"  مصادر أخرى"];
                }
            }
        }
        else
        {
            if(![userCountry isEqualToString:@""])
            {
                if (section == 0)
                {
                    [label setText:@"  مصادر بالقرب منك"];
                }
                else if (section == 1)
                {
                    [label setText:@"  مصادر عربية"];
                }
                else if (section == 2)
                {
                    [label setText:@"  مصادر عالمية"];
                }
                else
                {
                    [label setText:@"  مصادر أخرى"];
                }
            }
            else
            {
                if (section == 0)
                {
                    [label setText:@"  مصادر عربية"];
                }
                else if (section == 1)
                {
                    [label setText:@"  مصادر عالمية"];
                }
                else
                {
                    [label setText:@"  مصادر أخرى"];
                }
            }
        }
    }
    
    [view addSubview:label];
    [view setBackgroundColor:[UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:0.9]];
    return view;
}

-(void)tableView:(UITableView *)tableView2 didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isSearching)
    {
        if(![self connected])
        {
            [self performSegueWithIdentifier:@"NoConnectionSeg" sender:self];
            
        }else
        {
            NSDictionary* dict = [searchArray objectAtIndex:indexPath.row];
            
            UITableViewCell *cell = [tableView2 cellForRowAtIndexPath:indexPath];
            
            if([[[NSUserDefaults standardUserDefaults] objectForKey:@"subscriptions"] containsObject:dict])
            {
                [UIView animateWithDuration:0.2 delay:0.0 options:0
                                 animations:^{
                                     [[cell viewWithTag:3] setTransform:CGAffineTransformMakeScale(0.7, 0.7)];
                                     [(UIImageView*)[cell viewWithTag:3] setImage:[UIImage imageNamed:@"check-off.png"]];
                                 }
                                 completion:^(BOOL finished) {
                                     [UIView animateWithDuration:0.1 delay:0.0 options:0
                                                      animations:^{
                                                          [[cell viewWithTag:3] setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
                                                      }
                                                      completion:^(BOOL finished) {
                                                      }];
                                     [UIView commitAnimations];
                                 }];
                [UIView commitAnimations];
                
                
                
                NSMutableArray* mutArray = [[NSMutableArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"subscriptions"] copyItems:YES];
                [mutArray removeObject:dict];
                
                [[NSUserDefaults standardUserDefaults]setObject:mutArray forKey:@"subscriptions"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                NSArray *subscribedChannels = [currentInstallation objectForKey:@"customChannels"];
                NSMutableArray* toBeRemoved = [[NSMutableArray alloc]init];
                for(NSString* channel in subscribedChannels)
                {
                    if([channel hasPrefix:[dict objectForKey:@"twitterID"]])
                    {
                        [toBeRemoved addObject:channel];
                    }
                }
                
                if([[NSUserDefaults standardUserDefaults] boolForKey:@"isUrgentPush"])
                {
                    [currentInstallation removeObject:[NSString stringWithFormat:@"c%@",[dict objectForKey:@"twitterID"]] forKey:@"urgentPush"];
                    [currentInstallation saveInBackground];
                }
                
                if(toBeRemoved.count>0)
                {
                    [currentInstallation removeObjectsInArray:toBeRemoved forKey:@"customChannels"];
                    [currentInstallation saveInBackground];
                }
                
            }else
            {
                [UIView animateWithDuration:0.2 delay:0.0 options:0
                                 animations:^{
                                     [[cell viewWithTag:3] setTransform:CGAffineTransformMakeScale(1.3, 1.3)];
                                     [(UIImageView*)[cell viewWithTag:3] setImage:[UIImage imageNamed:@"check-on.png"]];
                                 }
                                 completion:^(BOOL finished) {
                                     [UIView animateWithDuration:0.1 delay:0.0 options:0
                                                      animations:^{
                                                          [[cell viewWithTag:3] setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
                                                      }
                                                      completion:^(BOOL finished) {
                                                      }];
                                     [UIView commitAnimations];
                                 }];
                [UIView commitAnimations];
                
                NSMutableArray* mutArray = [[NSMutableArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"subscriptions"] copyItems:YES];
                [mutArray addObject:dict];
                
                [[NSUserDefaults standardUserDefaults]setObject:mutArray forKey:@"subscriptions"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                NSArray* words = [[NSUserDefaults standardUserDefaults] objectForKey:@"notifWords"];
                NSMutableArray* toBeAdded = [[NSMutableArray alloc]init];
                
                for(NSString* word in words)
                {
                    [toBeAdded addObject:[NSString stringWithFormat:@"%@-%@",[dict objectForKey:@"twitterID"],word]];
                }
                
                if([[NSUserDefaults standardUserDefaults] boolForKey:@"isUrgentPush"])
                {
                    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                    [currentInstallation addUniqueObject:[NSString stringWithFormat:@"c%@",[dict objectForKey:@"twitterID"]] forKey:@"urgentPush"];
                    [currentInstallation saveInBackground];
                }
                
                if(toBeAdded.count>0)
                {
                    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                    [currentInstallation addUniqueObjectsFromArray:toBeAdded forKey:@"customChannels"];
                    [currentInstallation saveInBackground];
                    
                }
                
            }
        }
    }
    else
    {
        if([[[NSUserDefaults standardUserDefaults] objectForKey:@"subscriptions"]count] != 0)
        {
            if (indexPath.section == 0)
            {
                [self performSegueWithIdentifier:@"sourcesSeg1" sender:self];
            }
            else if(![userCountry isEqualToString:@""] && indexPath.section == 1)
            {
                [self performSegueWithIdentifier:@"sourcesSeg2" sender:self];
            }else
            {
                [self performSegueWithIdentifier:@"sourcesSeg1" sender:self];
            }
        }
        else
        {
            if(![userCountry isEqualToString:@""] && indexPath.section == 0)
            {
                [self performSegueWithIdentifier:@"sourcesSeg2" sender:self];
            }else
            {
                [self performSegueWithIdentifier:@"sourcesSeg1" sender:self];
            }
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
