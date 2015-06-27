//
//  NewsFeedViewController.m
//  AL-Masdar
//
//  Created by Osama Rabie on 6/25/15.
//  Copyright (c) 2015 Osama Rabie. All rights reserved.
//

#import "NewsFeedViewController.h"
#import <Haneke/Haneke.h>
#import "Reachability.h"
#import "AFHTTPRequestOperationManager.h"
#import "CRToastManager.h"
#import "CRToast.h"
#import "NewsDetailsViewController.h"
#import <Parse/Parse.h>

@interface NewsFeedViewController ()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,UITextFieldDelegate>

@end

@implementation NewsFeedViewController
{
    __weak IBOutlet NSLayoutConstraint *verticalLayout;
    __weak IBOutlet UIActivityIndicatorView *loader;
    __weak IBOutlet UITableView *tableView;
    
    NSMutableArray* dataSource;
    NSString* lowerCurrentID;
    NSString* upperCurrentID;
    BOOL loadingData;
    
    BOOL moreSearch;
    NSMutableArray* sources;
    int searchLimit;
    __weak IBOutlet UIView *searchView;
    __weak IBOutlet UIButton *retryButton;
    __weak IBOutlet UITextField *searchTextField;
    __weak IBOutlet UISegmentedControl *searchSegment;
    
    BOOL showingFav;
    NSMutableArray* favTempStoring;
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
    [loader setAlpha:0.0];
    tableView.alpha = 0;
    searchLimit = 0;
    moreSearch = YES;
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
        [tableView setAlpha:1];
        [retryButton setAlpha:0.0];
        [self getData];
    }else
    {
        loadingData = NO;
        [tableView setAlpha:1];
        [retryButton setAlpha:1.0];
    }
}

-(void)getData
{
    if(!showingFav && !loadingData)
    {
        loadingData = YES;
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        
        
        if([dataSource count] == 0)
        {
            [loader setAlpha:1.0];
            
            NSDictionary* params = @{@"lowerID":upperCurrentID,@"sources":[sources componentsJoinedByString:@","]};
            
            [manager POST:@"http://moh2013.com/arabDevs/almasdar/getNewerNews.php" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                [loader setAlpha:0.0];
                
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
                [loader setAlpha:0.0];
                loadingData = NO;
                NSLog(@"Error: %@", error);}];
        }else
        {
            [loader setAlpha:1.0];
            
            NSDictionary* params = @{@"lowerID":upperCurrentID,@"sources":[sources componentsJoinedByString:@","]};
            
            [manager POST:@"http://moh2013.com/arabDevs/almasdar/getNewerNews.php" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                [loader setAlpha:0.0];
                
                
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
                            offset.y += 427;
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
                
                [loader setAlpha:1.0];
                
                if([[tableView.indexPathsForVisibleRows lastObject] row] > dataSource.count-5)
                {
                    NSDictionary* params = @{@"lowerID":lowerCurrentID,@"sources":[sources componentsJoinedByString:@","]};
                    
                    [manager POST:@"http://moh2013.com/arabDevs/almasdar/getOlderNews.php" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                        [loader setAlpha:0.0];
                        
                        
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
                        [loader setAlpha:0.0];
                        loadingData = NO;
                        NSLog(@"Error: %@", error);}];
                }else
                {
                    loadingData = NO;
                    [loader setAlpha:0.0];
                }
                
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [loader setAlpha:0.0];
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
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [searchTextField resignFirstResponder];
    [self searchClicked:nil];
    return YES;
}
- (IBAction)searchSegmentChanged:(id)sender {
    [self searchClicked:nil];
}
- (IBAction)searchClicked:(id)sender {
    if(![self connected])
    {
        NSDictionary *options = @{
                                  kCRToastTextKey : @"يجب أن تكون متصلاً بالإنترنت",
                                  kCRToastTextAlignmentKey : @(NSTextAlignmentCenter),
                                  kCRToastBackgroundColorKey : [UIColor redColor],
                                  kCRToastAnimationInTypeKey : @(CRToastAnimationTypeLinear),
                                  kCRToastAnimationOutTypeKey : @(CRToastAnimationTypeLinear),
                                  kCRToastAnimationInDirectionKey : @(CRToastAnimationDirectionTop),
                                  kCRToastAnimationOutDirectionKey : @(CRToastAnimationDirectionBottom),
                                  kCRToastAnimationInTimeIntervalKey: @(3)
                                  };
        [CRToastManager showNotificationWithOptions:options
                                    completionBlock:^{
                                        NSLog(@"Completed");
                                    }];
        
    }else
    {
        if(searchTextField.text.length < 3)
        {
            NSDictionary *options = @{
                                      kCRToastTextKey : @"يجب إدخال كلمة واحدة من ٣ أحرف على الأقل",
                                      kCRToastTextAlignmentKey : @(NSTextAlignmentCenter),
                                      kCRToastBackgroundColorKey : [UIColor redColor],
                                      kCRToastAnimationInTypeKey : @(CRToastAnimationTypeLinear),
                                      kCRToastAnimationOutTypeKey : @(CRToastAnimationTypeLinear),
                                      kCRToastAnimationInDirectionKey : @(CRToastAnimationDirectionTop),
                                      kCRToastAnimationOutDirectionKey : @(CRToastAnimationDirectionBottom),
                                      kCRToastAnimationInTimeIntervalKey: @(3)
                                      };
            [CRToastManager showNotificationWithOptions:options
                                        completionBlock:^{
                                            NSLog(@"Completed");
                                        }];
        }else
        {
            lowerCurrentID = @"-1";
            upperCurrentID = @"-1";
            
            dataSource = [[NSMutableArray alloc] init];
            [tableView reloadData];
            [tableView setNeedsDisplay];
            searchLimit = 0;
            moreSearch = YES;
            [tableView setAlpha:1];
            [loader setAlpha:1.0];
            
            [self getSearchData];
        }
    }
    
}

-(void)getSearchData
{
    [searchTextField resignFirstResponder];
    NSString* keywords = [[searchTextField.text stringByReplacingOccurrencesOfString:@" ،" withString:@"،"] stringByReplacingOccurrencesOfString:@"، " withString:@"،"];
    NSDictionary* params;
    
    if(searchSegment.selectedSegmentIndex == 0)
    {
        params = @{@"limit":[NSString stringWithFormat:@"%i",searchLimit],@"keyword":keywords};
    }else
    {
        params = @{@"limit":[NSString stringWithFormat:@"%i",searchLimit],@"sources":[sources componentsJoinedByString:@","],@"keyword":keywords};
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager POST:@"http://moh2013.com/arabDevs/almasdar/getSearchNews.php" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [tableView setAlpha:1.0];
        [loader setAlpha:0.0];
        NSMutableArray* dataSourcee = [[NSMutableArray alloc]initWithArray:[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil]];
        
        [dataSource addObjectsFromArray:dataSourcee];
        if(dataSourcee.count > 0)
        {
            searchLimit += dataSourcee.count;
            moreSearch = YES;
        }else
        {
            moreSearch = NO;
        }
        [tableView reloadData];
        [tableView setNeedsDisplay];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [tableView setAlpha:1.0];
        [loader setAlpha:0.0];
        NSLog(@"Error: %@", error);}];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[self view]endEditing:YES];
    [searchTextField resignFirstResponder];
}
- (IBAction)retryClicked:(id)sender {
    if([self connected])
    {
        [tableView setAlpha:1.0];
        [retryButton setAlpha:0.0];
        [self getData];
    }else
    {
        [tableView setAlpha:1.0];
        [retryButton setAlpha:1.0];
    }
}
- (IBAction)cancelSearchClicked:(id)sender
{
    [verticalLayout setConstant:-86];
    [searchTextField resignFirstResponder];
    lowerCurrentID = @"-1";
    upperCurrentID = @"-1";
    searchLimit = 0;
    moreSearch = YES;
    loadingData = NO;
    dataSource = [[NSMutableArray alloc] init];
    [tableView reloadData];
    [tableView setNeedsDisplay];
    [self getData];
    
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
    UIActionSheet* sheet;
    if(showingFav)
    {
        sheet = [[UIActionSheet alloc]initWithTitle:@"خيارات الخبر" delegate:self cancelButtonTitle:@"إلغاء" destructiveButtonTitle:@"الأخبار" otherButtonTitles:nil];
    }else
    {
        sheet = [[UIActionSheet alloc]initWithTitle:@"خيارات الخبر" delegate:self cancelButtonTitle:@"إلغاء" destructiveButtonTitle:@"تحديث" otherButtonTitles:@"البحث",@"كلمات التنبيه",@"المفضلة",nil];
    }
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
    
    
    
    
    NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@" !?,()]#"];
    
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
    
    if(!showingFav && indexPath.row > dataSource.count-5)
    {
        if(searchView.alpha>0)
        {
            [self getSearchData];
        }else
        {
            [self getData];
        }
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
        return 427;
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

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(showingFav)
    {
        return YES;
    }else
    {
        return NO;
    }
}

-(void)tableView:(UITableView *)tableVieww commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [dataSource removeObjectAtIndex:indexPath.row];
        NSArray* newFavs = [[NSArray alloc]initWithArray:dataSource copyItems:YES];

        [[NSUserDefaults standardUserDefaults]setObject:newFavs forKey:@"favs"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
        [tableVieww beginUpdates];
        [tableVieww deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [tableVieww endUpdates];
        
        if(dataSource.count == 0)
        {
            showingFav = NO;
            dataSource = [[NSMutableArray alloc]initWithArray:favTempStoring copyItems:YES];
            [tableView reloadData];
            [tableView setNeedsDisplay];
        }
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
            NSMutableArray* favs = [[NSMutableArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"favs"] copyItems:YES];
            [favs addObject:[dataSource objectAtIndex:tableView.indexPathForSelectedRow.row]];
            NSArray* newFavs = [[NSArray alloc]initWithArray:favs copyItems:YES];
            [[NSUserDefaults standardUserDefaults]setObject:newFavs forKey:@"favs"];
            [[NSUserDefaults standardUserDefaults]synchronize];
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
            NSMutableArray* favs = [[NSMutableArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"favs"] copyItems:YES];
            [favs addObject:[dataSource objectAtIndex:tableView.indexPathForSelectedRow.row]];
            NSArray* newFavs = [[NSArray alloc]initWithArray:favs copyItems:YES];
            [[NSUserDefaults standardUserDefaults]setObject:newFavs forKey:@"favs"];
            [[NSUserDefaults standardUserDefaults]synchronize];
        }
    }else if(actionSheet.tag == 3)
    {
        if(buttonIndex == 0)
        {
            if(showingFav)
            {
                showingFav = NO;
                dataSource = [[NSMutableArray alloc]initWithArray:favTempStoring copyItems:YES];
                [tableView reloadData];
                [tableView setNeedsDisplay];
            }else
            {
                [self getData];
            }
        }else if(buttonIndex == 1)
        {
            verticalLayout.constant = 0;
            CGRect frame = tableView.frame;
            frame.origin.y += 100;
            [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                             animations:^(void) {
                                 searchView.alpha = 1.0f;
                                 [tableView setFrame:frame];
                             }
                             completion:^(BOOL finished){}];
        }else if(buttonIndex == 2)
        {
            [self performSegueWithIdentifier:@"notifSeg" sender:self];
        }else if(buttonIndex == 3)
        {
            NSMutableArray* favs = [[NSMutableArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"favs"] copyItems:YES];
            NSArray *aSortedArray = [favs sortedArrayUsingComparator:^(NSDictionary *obj1,NSDictionary *obj2) {
                NSString *num1 =[obj1 objectForKey:@"createdAt"];
                NSString *num2 =[obj2 objectForKey:@"createdAt"];
                return (NSComparisonResult) [num2 compare:num1 options:(NSNumericSearch)];
            }];

            if(favs.count == 0)
            {
                NSDictionary *options = @{
                                          kCRToastTextKey : @"لم تقم بتفضيل أي خبر من قبل",
                                          kCRToastTextAlignmentKey : @(NSTextAlignmentCenter),
                                          kCRToastBackgroundColorKey : [UIColor redColor],
                                          kCRToastAnimationInTypeKey : @(CRToastAnimationTypeLinear),
                                          kCRToastAnimationOutTypeKey : @(CRToastAnimationTypeLinear),
                                          kCRToastAnimationInDirectionKey : @(CRToastAnimationDirectionTop),
                                          kCRToastAnimationOutDirectionKey : @(CRToastAnimationDirectionBottom),
                                          kCRToastAnimationInTimeIntervalKey: @(3)
                                          };
                [CRToastManager showNotificationWithOptions:options
                                            completionBlock:^{
                                                NSLog(@"Completed");
                                            }];
                
            }else
            {
                showingFav = YES;
                if(searchView.alpha>0)
                {
                    [verticalLayout setConstant:-86];
                    [searchTextField resignFirstResponder];
                    lowerCurrentID = @"-1";
                    upperCurrentID = @"-1";
                    searchLimit = 0;
                    moreSearch = YES;
                    loadingData = NO;
                    
                    CGRect frame = tableView.frame;
                    frame.origin.y -= 100;
                    [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                                     animations:^(void) {
                                         searchView.alpha = 0.0f;
                                         [tableView setFrame:frame];
                                     }
                                     completion:^(BOOL finished){
                                         favTempStoring = [[NSMutableArray alloc]initWithArray:dataSource copyItems:YES];
                                         dataSource = [[NSMutableArray alloc]initWithArray:aSortedArray copyItems:YES];
                                         [tableView reloadData];
                                         [tableView setNeedsDisplay];
                                     }];
                    
                }else
                {
                    favTempStoring = [[NSMutableArray alloc]initWithArray:dataSource copyItems:YES];
                    dataSource = [[NSMutableArray alloc]initWithArray:aSortedArray copyItems:YES];
                    [tableView reloadData];
                    [tableView setNeedsDisplay];
                }
            }
        }
    }
}



@end
