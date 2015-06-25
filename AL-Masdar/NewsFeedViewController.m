//
//  NewsFeedViewController.m
//  AL-Masdar
//
//  Created by Osama Rabie on 6/25/15.
//  Copyright (c) 2015 Osama Rabie. All rights reserved.
//

#import "NewsFeedViewController.h"
#import <Haneke/Haneke.h>
#import <PQFCustomLoaders/PQFCustomLoaders.h>
#import "Reachability.h"
#import "AFHTTPRequestOperationManager.h"
#import "CRToastManager.h"
#import "CRToast.h"


@interface NewsFeedViewController ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation NewsFeedViewController
{
    PQFBarsInCircle* loader;
    __weak IBOutlet UITableView *tableView;
    
    NSMutableArray* dataSource;
    NSString* lowerCurrentID;
    NSString* upperCurrentID;
    
    NSMutableArray* sources;
    
    __weak IBOutlet UIButton *retryButton;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    loader = [PQFBarsInCircle createLoaderOnView:tableView];
    loader.loaderColor = [UIColor blackColor];
    
    lowerCurrentID = @"-1";
    upperCurrentID = @"-1";
    dataSource = [[NSMutableArray alloc]init];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [retryButton setAlpha:0];
    
    sources = [[NSMutableArray alloc]init];
    
    NSArray* subs = [[NSUserDefaults standardUserDefaults] objectForKey:@"subscriptions"];
    for(NSDictionary* dict in subs)
    {
        [sources addObject:[dict objectForKey:@"twitterID"]];
    }
    
}
-(void)viewDidAppear:(BOOL)animated
{
    if([self connected])
    {
        [tableView setAlpha:1.0];
        [retryButton setAlpha:0.0];
        [self getData];
    }else
    {
        [tableView setAlpha:0.0];
        [retryButton setAlpha:1.0];
    }
}

-(void)getData
{
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    
    
    if([dataSource count] == 0)
    {
        [loader showLoader];
        
        NSDictionary* params = @{@"lowerID":upperCurrentID,@"sources":[sources componentsJoinedByString:@","]};
        
        [manager POST:@"http://moh2013.com/arabDevs/almasdar/getNewerNews.php" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [loader removeLoader];
            
            dataSource = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
            
            if([dataSource count]>0)
            {
                upperCurrentID = [[dataSource objectAtIndex:0] objectForKey:@"tweetID"];
                lowerCurrentID = [[dataSource lastObject] objectForKey:@"tweetID"];
            }
            
            [tableView reloadData];
            [tableView setNeedsDisplay];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [loader removeLoader];
            NSLog(@"Error: %@", error);}];
    }else
    {
        [loader showLoader];
        
        NSDictionary* params = @{@"lowerID":upperCurrentID,@"sources":[sources componentsJoinedByString:@","]};
        
        [manager POST:@"http://moh2013.com/arabDevs/almasdar/getNewerNews.php" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [loader removeLoader];
            
            
            NSMutableArray* newNews = [[NSMutableArray alloc]initWithArray:[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil]];
            if([newNews count]>0)
            {
                [newNews addObjectsFromArray:dataSource];
                dataSource = [[NSMutableArray alloc]initWithArray:newNews copyItems:YES];
                upperCurrentID = [[dataSource objectAtIndex:0] objectForKey:@"tweetID"];
                
                NSMutableArray* indicesArray = [[NSMutableArray alloc]init];
                for(int i = 0 ; i < newNews.count ; i++)
                {
                    [indicesArray addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                }
                [tableView beginUpdates];
                [tableView insertRowsAtIndexPaths:indicesArray withRowAnimation:UITableViewRowAnimationRight];
                [tableView endUpdates];
                
                NSDictionary *options = @{
                                          kCRToastTextKey : [NSString stringWithFormat:@"%lu %@",(unsigned long)newNews.count,@"خبر جديد"],
                                          kCRToastTextAlignmentKey : @(NSTextAlignmentCenter),
                                          kCRToastBackgroundColorKey : [UIColor yellowColor],
                                          kCRToastAnimationInTypeKey : @(CRToastAnimationTypeLinear),
                                          kCRToastAnimationOutTypeKey : @(CRToastAnimationTypeLinear),
                                          kCRToastAnimationInDirectionKey : @(CRToastAnimationDirectionTop),
                                          kCRToastAnimationOutDirectionKey : @(CRToastAnimationDirectionBottom)
                                          };
                [CRToastManager showNotificationWithOptions:options
                                            completionBlock:^{
                                                NSLog(@"Completed");
                                            }];
            }
            
            [loader removeLoader];
            [loader showLoader];
            
            if([[tableView.indexPathsForVisibleRows lastObject] row] > dataSource.count-5)
            {
                NSDictionary* params = @{@"lowerID":lowerCurrentID,@"sources":[sources componentsJoinedByString:@","]};
                
                [manager POST:@"http://moh2013.com/arabDevs/almasdar/getNewerNews.php" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    [loader removeLoader];
                    
                    
                    NSMutableArray* newNews = [[NSMutableArray alloc]initWithArray:[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil]];
                    
                    if([newNews count]>0)
                    {
                        int lastEndIndexPath = (int)dataSource.count;
                        [dataSource addObjectsFromArray:newNews];
                        lowerCurrentID = [[dataSource lastObject] objectForKey:@"tweetID"];
                        
                        NSMutableArray* indicesArray = [[NSMutableArray alloc]init];
                        for(int i = lastEndIndexPath ; i < newNews.count ; i++)
                        {
                            [indicesArray addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                        }
                        [tableView beginUpdates];
                        [tableView insertRowsAtIndexPaths:indicesArray withRowAnimation:UITableViewRowAnimationRight];
                        [tableView endUpdates];
                        
                    }
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    [loader removeLoader];
                    NSLog(@"Error: %@", error);}];
            }
            
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [loader removeLoader];
            NSLog(@"Error: %@", error);}];
        
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
- (IBAction)retryClicked:(id)sender {
    if([self connected])
    {
        [tableView setAlpha:1.0];
        [retryButton setAlpha:0.0];
        [self getData];
    }else
    {
        [tableView setAlpha:0.0];
        [retryButton setAlpha:1.0];
    }
}

- (IBAction)sourceChooserClicked:(id)sender {
}


- (BOOL)connected
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return networkStatus != NotReachable;
}



#pragma mark table delegate
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return dataSource.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableVieww cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* cellID = @"newsFeedCell";
    UITableViewCell *cell = [tableVieww dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    
    if(!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    
    NSDictionary* news = [dataSource objectAtIndex:indexPath.row];
    
    [(UIImageView*)[cell viewWithTag:1] hnk_setImageFromURL:[NSURL URLWithString:[news objectForKey:@"icon"]] placeholder:[UIImage imageNamed:@"Wait-icon.png"]];
    [(UILabel*)[cell viewWithTag:2] setText:[news objectForKey:@"name"]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    NSDate* date = [dateFormatter dateFromString:dateString];
    
    long currentStamp = [date timeIntervalSince1970];
    long newsStamp = [[news objectForKey:@"createdAt"] longLongValue];
    long diff = currentStamp-newsStamp;
    
    if(diff < 60)
    {
        [(UILabel*)[cell viewWithTag:3] setText:@"الآن"];
    }else if (diff < 3600)
    {
        [(UILabel*)[cell viewWithTag:3] setText:[NSString stringWithFormat:@"منذ %i دقيقة",(int)(diff/60)]];
    }else if (diff < 86400)
    {
        [(UILabel*)[cell viewWithTag:3] setText:[NSString stringWithFormat:@"منذ %i ساعة",(int)(diff/3600)]];
    }else if (diff < 604800)
    {
        [(UILabel*)[cell viewWithTag:3] setText:[NSString stringWithFormat:@"منذ %i يوم",(int)(diff/86400)]];
    }else
    {
        [(UILabel*)[cell viewWithTag:3] setText:[NSString stringWithFormat:@"منذ %i إسبوع",(int)(diff/604800)]];
    }
    
    NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@" !?,()]"];
    
    NSString *returnedSecondString = [self replacePattern:@"http://" withReplacement:@"" forString:[news objectForKey:@"body"] usingCharacterSet:characterSet];
    
    [(UILabel*)[cell viewWithTag:4] setText:returnedSecondString];
    
    if([[news objectForKey:@"mediaType"]isEqualToString:@""])
    {
        [(UIImageView*)[cell viewWithTag:5] setAlpha:0.0];
    }else
    {
        [(UIImageView*)[cell viewWithTag:5] setAlpha:1.0];
        [(UIImageView*)[cell viewWithTag:5] hnk_setImageFromURL:[NSURL URLWithString:[news objectForKey:@"mediaURL"]] placeholder:[UIImage imageNamed:@"Wait-icon-2.png"]];
    }
    
    return cell;
}


#pragma make MISC methods

- (NSTimeInterval) timeStamp {
    NSDate* referenceDate = [NSDate dateWithTimeIntervalSince1970: 0];
    return [referenceDate timeIntervalSince1970];
}


- (NSString*)replacePattern:(NSString*)pattern withReplacement:(NSString*)replacement forString:(NSString*)string usingCharacterSet:(NSCharacterSet*)characterSetOrNil
{
    // Check if a NSCharacterSet has been provided, otherwise use our "default" one
    if (!characterSetOrNil)
        characterSetOrNil = [NSCharacterSet characterSetWithCharactersInString:@" !?,()]"];
    
    // Create a mutable copy of the string supplied, setup all the default variables we'll need to use
    NSMutableString *mutableString = [[NSMutableString alloc] initWithString:string];
    NSString *beforePatternString = nil;
    NSRange outputrange = NSMakeRange(0, 0);
    
    // Check if the string contains the "pattern" you're looking for, otherwise simply return it.
    NSRange containsPattern = [mutableString rangeOfString:pattern];
    while (containsPattern.location != NSNotFound)
        // Found the pattern, let's run with the changes
    {
        // Firstly, we grab the full string range
        NSRange stringrange = NSMakeRange(0, [mutableString length]);
        NSScanner *scanner = [[NSScanner alloc] initWithString:mutableString];
        
        // Now we use NSScanner to scan UP TO the pattern provided
        [scanner scanUpToString:pattern intoString:&beforePatternString];
        
        // Check for nil here otherwise you will crash - you will get nil if the pattern is at the very beginning of the string
        // outputrange represents the range of the string right BEFORE your pattern
        // We need this to know where to start searching for our characterset (i.e. end of output range = beginning of our pattern)
        if (beforePatternString != nil)
            outputrange = [mutableString rangeOfString:beforePatternString];
        
        // Search for any of the character sets supplied to know where to stop.
        // i.e. for a URL you'd be looking at non-URL friendly characters, including spaces (this may need a bit more research for an exhaustive list)
        NSRange characterAfterPatternRange = [mutableString rangeOfCharacterFromSet:characterSetOrNil options:NSLiteralSearch range:NSMakeRange(outputrange.length, stringrange.length-outputrange.length)];
        
        // Check if the link is not at the very end of the string, in which case there will be no characters AFTER it so set the NSRage location to the end of the string (== it's length)
        if (characterAfterPatternRange.location == NSNotFound)
            characterAfterPatternRange.location = [mutableString length];
        
        // Assign the pattern's start position and length, and then replace it with the pattern
        NSInteger patternStartPosition = outputrange.length;
        NSInteger patternLength = characterAfterPatternRange.location - outputrange.length;
        [mutableString replaceCharactersInRange:NSMakeRange(patternStartPosition, patternLength) withString:replacement];
        
        // Reset containsPattern for new mutablestring and let the loop continue
        containsPattern = [mutableString rangeOfString:pattern];
    }
    return mutableString;
}



@end
