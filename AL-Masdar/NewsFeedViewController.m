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
#import "NewsDetailsViewController.h"

@interface NewsFeedViewController ()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate>

@end

@implementation NewsFeedViewController
{
    __weak IBOutlet NSLayoutConstraint *verticalLayout;
    PQFBarsInCircle* loader;
    __weak IBOutlet UITableView *tableView;
    
    NSMutableArray* dataSource;
    NSString* lowerCurrentID;
    NSString* upperCurrentID;
    BOOL loadingData;
    NSMutableArray* sources;
    
    __weak IBOutlet UIView *searchView;
    __weak IBOutlet UIButton *retryButton;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier]isEqualToString:@"detailsSeg"])
    {
        NewsDetailsViewController* dst = (NewsDetailsViewController*)[segue destinationViewController];
        [dst setUrl:[[dataSource objectAtIndex:tableView.indexPathForSelectedRow.row] objectForKey:@"newsURL"]];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    loader = [PQFBarsInCircle createLoaderOnView:self.view];
    loader.loaderColor = [UIColor blackColor];
    tableView.alpha = 0;
    lowerCurrentID = @"-1";
    upperCurrentID = @"-1";
    loadingData = NO;
    dataSource = [[NSMutableArray alloc]init];
    
   // [tableView setTranslatesAutoresizingMaskIntoConstraints:YES];
    
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
    
    
    [searchView setAlpha:0.0];
}
-(void)viewDidAppear:(BOOL)animated
{
    [verticalLayout setConstant:-86];
    
    [self.view setNeedsDisplay];
    [self.view setNeedsLayout];
    [tableView setNeedsLayout];
    [tableView setNeedsDisplay];

    
    if([self connected])
    {
        [tableView setAlpha:0.0];
        [retryButton setAlpha:0.0];
        [self getData];
    }else
    {
        loadingData = NO;
        [tableView setAlpha:0.0];
        [retryButton setAlpha:1.0];
    }
}

-(void)getData
{
    if(!loadingData)
    {
        loadingData = YES;
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        
        
        if([dataSource count] == 0)
        {
            [loader showLoader];
            
            NSDictionary* params = @{@"lowerID":upperCurrentID,@"sources":[sources componentsJoinedByString:@","]};
            
            [manager POST:@"http://moh2013.com/arabDevs/almasdar/getNewerNews.php" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                [loader removeLoader];[tableView setAlpha:1.0];
                
                dataSource = [[NSMutableArray alloc]initWithArray:[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil]];
                
                if([dataSource count]>0)
                {
                    upperCurrentID = [[dataSource objectAtIndex:0] objectForKey:@"tweetID"];
                    lowerCurrentID = [[dataSource lastObject] objectForKey:@"tweetID"];
                }
                
                [tableView reloadData];
                [tableView setNeedsDisplay];
                loadingData = NO;
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [loader removeLoader];[tableView setAlpha:1.0];
                loadingData = NO;
                NSLog(@"Error: %@", error);}];
        }else
        {
            [loader showLoader];
            
            NSDictionary* params = @{@"lowerID":upperCurrentID,@"sources":[sources componentsJoinedByString:@","]};
            
            [manager POST:@"http://moh2013.com/arabDevs/almasdar/getNewerNews.php" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                [loader removeLoader];[tableView setAlpha:1.0];
                
                
                NSMutableArray* newNews = [[NSMutableArray alloc]initWithArray:[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil]];
                if([newNews count]>0)
                {
                    //[newNews addObjectsFromArray:dataSource];
                    //dataSource = [[NSMutableArray alloc]initWithArray:newNews copyItems:YES];
                    upperCurrentID = [[newNews objectAtIndex:0] objectForKey:@"tweetID"];
                    CGPoint offset = tableView.contentOffset;
                    for(int i = (int)newNews.count-1 ; i >= 0 ; i--)
                    {
                        
                        
                        [dataSource insertObject:[newNews objectAtIndex:i] atIndex:0];
                        [tableView beginUpdates];
                        [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                        if([[[newNews objectAtIndex:i] objectForKey:@"mediaURL"] isEqualToString:@""])
                        {
                            offset.y += 116;
                        }else
                        {
                            offset.y += 475;
                        }
                        [tableView endUpdates];
                    }
                    [tableView setContentOffset:offset animated:NO];
                    
                    NSDictionary *options = @{
                                              kCRToastTextKey : [NSString stringWithFormat:@"%lu %@",(unsigned long)newNews.count,@"خبر جديد"],
                                              kCRToastTextAlignmentKey : @(NSTextAlignmentCenter),
                                              kCRToastBackgroundColorKey : [UIColor redColor],
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
                
                [loader showLoader];
                
                if([[tableView.indexPathsForVisibleRows lastObject] row] > dataSource.count-5)
                {
                    NSDictionary* params = @{@"lowerID":lowerCurrentID,@"sources":[sources componentsJoinedByString:@","]};
                    
                    [manager POST:@"http://moh2013.com/arabDevs/almasdar/getOlderNews.php" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                        [loader removeLoader];[tableView setAlpha:1.0];
                        
                        
                        NSMutableArray* newNews = [[NSMutableArray alloc]initWithArray:[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil]];
                        
                        if([newNews count]>0)
                        {
                            lowerCurrentID = [[newNews lastObject] objectForKey:@"tweetID"];
                            
                            for(NSDictionary* dict in newNews)
                            {
                                [dataSource addObject:dict];
                                [tableView beginUpdates];
                                [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:(dataSource.count-1) inSection:0]]withRowAnimation:UITableViewRowAnimationRight];
                                [tableView endUpdates];
                            }
                        }
                        loadingData = NO;
                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        [loader removeLoader];[tableView setAlpha:1.0];
                        loadingData = NO;
                        NSLog(@"Error: %@", error);}];
                }else
                {
                    loadingData = NO;
                    [loader removeLoader];[tableView setAlpha:1.0];
                }
                
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [loader removeLoader];[tableView setAlpha:1.0];
                loadingData = NO;
                NSLog(@"Error: %@", error);}];
            
        }
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
- (IBAction)cancelSearchClicked:(id)sender {
    CGRect frame = tableView.frame;
    frame.origin.y -= 100;
    [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^(void) {
                         searchView.alpha = 0.0f;
                         [tableView setFrame:frame];
                     }
                     completion:^(BOOL finished){}];
}

- (IBAction)sourceChooserClicked:(id)sender {
    [[self navigationController] popViewControllerAnimated:YES];
}

- (IBAction)optionsClicked:(id)sender {
    UIActionSheet* sheet = [[UIActionSheet alloc]initWithTitle:@"خيارات الخبر" delegate:self cancelButtonTitle:@"إلغاء" destructiveButtonTitle:@"تحديث" otherButtonTitles:@"البحث",@"يحدث في مدينتي",@"المفضلة",nil];
    sheet.tag = 3;
    [sheet showInView:self.view];
}

- (BOOL)connected
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return networkStatus != NotReachable;
}



#pragma mark - Table delegate
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
    
    returnedSecondString = [self replacePattern:@"https://" withReplacement:@"" forString:returnedSecondString usingCharacterSet:characterSet];
    
    
    NSMutableArray* splitting = [[NSMutableArray alloc]initWithArray:[returnedSecondString componentsSeparatedByString:@" "]];
    int currentLength = 0;
    for(int i = 0 ; i < splitting.count ; i++)
    {
        currentLength+= [[splitting objectAtIndex:i] length];
        if(currentLength>=50)
        {
            [splitting replaceObjectAtIndex:i withObject:[[splitting objectAtIndex:i]stringByAppendingString:@"\n"]];
            break;
        }
    }
    
    returnedSecondString = [splitting componentsJoinedByString:@" "];
    [(UILabel*)[cell viewWithTag:4] setText:returnedSecondString];
    
    if([[news objectForKey:@"mediaType"]isEqualToString:@""])
    {
        [(UIImageView*)[cell viewWithTag:5] setAlpha:0.0];
    }else
    {
        [(UIImageView*)[cell viewWithTag:5] setAlpha:1.0];
        [(UIImageView*)[cell viewWithTag:5] hnk_setImageFromURL:[NSURL URLWithString:[news objectForKey:@"mediaURL"]] placeholder:[UIImage imageNamed:@"Wait-icon-2.png"]];
    }
    
    if(indexPath.row > dataSource.count-5)
    {
        [self getData];
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary* news = [dataSource objectAtIndex:indexPath.row];
    if([[news objectForKey:@"mediaType"]isEqualToString:@""])
    {
        return 116;
    }else
    {
        return 475;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary* news = [dataSource objectAtIndex:indexPath.row];
    if([[news objectForKey:@"newsURL"]isEqualToString:@""])
    {
        UIActionSheet* sheet = [[UIActionSheet alloc]initWithTitle:@"خيارات الخبر" delegate:self cancelButtonTitle:@"إلغاء" destructiveButtonTitle:nil otherButtonTitles:@"مشاركة",@"تفضيل",nil];
        sheet.tag = 1;
        [sheet showInView:self.view];
    }else
    {
        UIActionSheet* sheet = [[UIActionSheet alloc]initWithTitle:@"خيارات الخبر" delegate:self cancelButtonTitle:@"إلغاء" destructiveButtonTitle:@"التفاصيل من المصدر" otherButtonTitles:@"مشاركة",@"تفضيل",nil];
        sheet.tag = 2;
        [sheet showInView:self.view];
    }
}

#pragma mark MISC methods

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

#pragma mark action sheet delegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSDictionary* news = [dataSource objectAtIndex:tableView.indexPathForSelectedRow.row];
    
    if(actionSheet.tag == 1)
    {
        
        if(buttonIndex == 0)
        {
            NSString *sharedMsg=[news objectForKey:@"body"];
            NSArray* sharedObjects;
            
            if([[news objectForKey:@"mediaURL"]isEqualToString:@""])
            {
                sharedObjects=[NSArray arrayWithObjects:sharedMsg, nil];
            }else
            {
                UITableViewCell* cell = [tableView cellForRowAtIndexPath:tableView.indexPathForSelectedRow];
                UIImageView* imageView = (UIImageView*)[cell viewWithTag:5];
                UIImage* sharedImg=imageView.image;
                sharedObjects=[NSArray arrayWithObjects:sharedMsg, sharedImg, nil];
            }
            
            UIActivityViewController *activityViewController = [[UIActivityViewController alloc]
                                                                initWithActivityItems:sharedObjects applicationActivities:nil];
            activityViewController.popoverPresentationController.sourceView = self.view;
            [self presentViewController:activityViewController animated:YES completion:nil];
        }else if(buttonIndex == 1)
        {
            
        }
    }else if(actionSheet.tag == 2)
    {
        if(buttonIndex == 0)
        {
            [self performSegueWithIdentifier:@"detailsSeg" sender:self];
        }else if(buttonIndex == 1)
        {
            NSString *sharedMsg=[news objectForKey:@"body"];
            NSArray* sharedObjects;
            
            if([[news objectForKey:@"mediaURL"]isEqualToString:@""])
            {
                sharedObjects=[NSArray arrayWithObjects:sharedMsg, nil];
            }else
            {
                UITableViewCell* cell = [tableView cellForRowAtIndexPath:tableView.indexPathForSelectedRow];
                UIImageView* imageView = (UIImageView*)[cell viewWithTag:5];
                UIImage* sharedImg=imageView.image;
                sharedObjects=[NSArray arrayWithObjects:sharedMsg, sharedImg, nil];
            }
            
            UIActivityViewController *activityViewController = [[UIActivityViewController alloc]
                                                                initWithActivityItems:sharedObjects applicationActivities:nil];
            activityViewController.popoverPresentationController.sourceView = self.view;
            [self presentViewController:activityViewController animated:YES completion:nil];            
        }else if(buttonIndex == 2)
        {
            
        }
    }else if(actionSheet.tag == 3)
    {
        if(buttonIndex == 0)
        {
            [self getData];
        }else if(buttonIndex == 1)
        {
            CGRect frame = tableView.frame;
            frame.origin.y += 100;
            [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                             animations:^(void) {
                                 searchView.alpha = 1.0f;
                                 [tableView setFrame:frame];
                             }
                             completion:^(BOOL finished){}];
        }
    }
}



@end
