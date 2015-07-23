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
#import "UIImageView+WebCache.h"

@interface NewsFeedViewController ()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,UITextFieldDelegate>

@end

@implementation NewsFeedViewController
{
    __weak IBOutlet UIActivityIndicatorView *loader;
    __weak IBOutlet UITableView *tableView;
    
    NSMutableArray* dataSource;
    NSMutableArray* breakingArray;
    NSString* lowerCurrentID;
    NSString* upperCurrentID;
    NSString* createdAt;
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

//-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    if([[segue identifier]isEqualToString:@"detailsSeg"])
//    {
//        NewsDetailsViewController* dst = (NewsDetailsViewController*)[segue destinationViewController];
//        [dst setUrl:[[dataSource objectAtIndex:tableView.indexPathForSelectedRow.row] objectForKey:@"newsURL"]];
//        if([(UIImageView*)[[tableView cellForRowAtIndexPath:tableView.indexPathForSelectedRow] viewWithTag:5] alpha] == 0)
//        {
//            [dst setImage:[UIImage imageNamed:@"Wait-icon.png"]];
//        }else if([(UIImageView*)[[tableView cellForRowAtIndexPath:tableView.indexPathForSelectedRow] viewWithTag:5] alpha] == 1)
//        {
//            [dst setImage:[(UIImageView*)[[tableView cellForRowAtIndexPath:tableView.indexPathForSelectedRow] viewWithTag:5] image]];
//        }
//    }else if([[segue identifier]isEqualToString:@"urlLocalNotifSeg"])
//    {
//        NewsDetailsViewController* dst = (NewsDetailsViewController*)[segue destinationViewController];
//        [dst setUrl:localURLToOpen];
//    }
//}

-(void) brightnessDidChange:(NSNotification*)notification
{
    NSLog(@"Brightness did change: %f",[UIScreen mainScreen].brightness);
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier]isEqualToString:@"detailsSeg"])
    {
        NewsDetailsViewController* dst = (NewsDetailsViewController*)[segue destinationViewController];
        [dst setUrl:[[dataSource objectAtIndex:tableView.indexPathForSelectedRow.row] objectForKey:@"newsURL"]];
    }
}

-(void)checkBrightness:(NSTimer *)timer {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"isAutoNight"])return;
    if ([UIScreen mainScreen].brightness < 0.5)
    {
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"isNightOn"])
        {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isNightOn"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self performSelector:@selector(enableNightMode) withObject:nil afterDelay:0.3];
        }
    }
    else
    {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isNightOn"])
        {
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isNightOn"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self performSelector:@selector(disableNightMode) withObject:nil afterDelay:0.3];
        }
    }
}

-(void)checkBrightnessProcess
{
    UIApplication *app = [UIApplication sharedApplication];
    
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        [app endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    
    [NSTimer scheduledTimerWithTimeInterval: 2.0
                                     target: self
                                   selector:@selector(checkBrightness:)
                                   userInfo: nil repeats:YES];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getBreakingNewsWords];
    theSavedCount = 0;
    countToEnd = 0;
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    [loader setAlpha:0.0];
    [tableView setHidden:YES];
    [self addActivityView];
    tableView.alpha = 0;
    searchLimit = 0;
    moreSearch = YES;
    lowerCurrentID = @"-1";
    upperCurrentID = @"-1";
    createdAt = @"-1";
    loadingData = NO;
    dataSource = [[NSMutableArray alloc]init];
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(brightnessDidChange:) name:UIScreenBrightnessDidChangeNotification object:nil];
    
    if (!isCheckBrDone)
    {
        isCheckBrDone = YES;
        [self checkBrightnessProcess];
    }
    
    [self showTheStatusBar];
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isReloadNeeded"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageFullScreen:)];
    tap.delegate = self;
    
    [_imageScrollView addGestureRecognizer:tap];
    
    dbTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    [dbTap setNumberOfTapsRequired:2];
    dbTap.delegate = self;
    
    [_imageScrollView addGestureRecognizer:dbTap];
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 0.5;
    lpgr.delegate = self;
    [tableView addGestureRecognizer:lpgr];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    [_timeLineButton setBackgroundImage:[UIImage imageNamed:@"news-selected-back.png"] forState:UIControlStateHighlighted];
    [_favButton setBackgroundImage:[UIImage imageNamed:@"news-selected-back.png"] forState:UIControlStateHighlighted];
    [_breakingButton setBackgroundImage:[UIImage imageNamed:@"news-selected-back.png"] forState:UIControlStateHighlighted];
    [_notifyButton setBackgroundImage:[UIImage imageNamed:@"news-selected-back.png"] forState:UIControlStateHighlighted];
    [_nightButton setBackgroundImage:[UIImage imageNamed:@"news-selected-back.png"] forState:UIControlStateHighlighted];
    [_settingsButton setBackgroundImage:[UIImage imageNamed:@"news-selected-back.png"] forState:UIControlStateHighlighted];
    
    _timeLineButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    _favButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    _breakingButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    _notifyButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    _nightButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    _settingsButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    
    [_timeLineButton setTitle:@"         الأخبار" forState:UIControlStateNormal];
    [_favButton setTitle:@"         المفضلة" forState:UIControlStateNormal];
    [_breakingButton setTitle:@"         الأخبار العاجلة والهامة" forState:UIControlStateNormal];
    [_notifyButton setTitle:@"         التنبيه بكلمات وجمل معينة" forState:UIControlStateNormal];
    [_nightButton setTitle:@"         وضع القراءة الليلي" forState:UIControlStateNormal];
    [_settingsButton setTitle:@"         الإعدادات" forState:UIControlStateNormal];
    
    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(handleSwipeRight:)];
    recognizer.delegate = self;
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [tableView addGestureRecognizer:recognizer];
    
    UISwipeGestureRecognizer *recognizer2 = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(handleSwipeLeft:)];
    recognizer2.delegate = self;
    [recognizer2 setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [tableView addGestureRecognizer:recognizer2];
        
    // [tableView setTranslatesAutoresizingMaskIntoConstraints:YES];
    
    isOnNews = YES;
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isSoundEffects"])
    {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
    }
    
    [self playSound:@"Empty"];
}

-(void)getBreakingNewsWords
{
    NSURL *theURL = [NSURL URLWithString:@"http://almasdarapp.com/almasdar/getBreakingNewsWords.php"];
    
    NSMutableURLRequest *storeRequest = [NSMutableURLRequest requestWithURL:theURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:storeRequest queue:queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               if (!connectionError) {
                                   NSError *error;
                                   
                                   NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSNonLossyASCIIStringEncoding];//NSASCIIStringEncoding NSUTF8StringEncoding
                                   
                                   if (!dataStr || error || [dataStr isEqualToString:@""])
                                   {
                                       NSLog(@"Error");
                                   }
                                   else
                                   {
                                       [[NSUserDefaults standardUserDefaults] setObject:dataStr forKey:@"breakingWords"];
                                       [[NSUserDefaults standardUserDefaults] synchronize];
                                   }
                               }
                           }];
}

-(void)playSound:(NSString*)theSound
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"isSoundEffects"])return;
    
    NSString* path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[theSound stringByAppendingString:@".caf"]];
    
    NSError* error;
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:&error];
    self.player.delegate = self;
    [self.player play];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    if (flag) {
        NSLog(@"audioPlayerDidFinishPlaying successfully");
    }
}

-(BOOL)isBreakingNews:(NSString*)body
{
    NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@" !?,()]#.:|\""];
    NSString *adjustedBody = [self replacePattern:@"http://" withReplacement:@"" forString:body usingCharacterSet:characterSet];
    
    adjustedBody = [adjustedBody stringByReplacingOccurrencesOfString:@"-" withString:@" "];
    adjustedBody = [adjustedBody stringByReplacingOccurrencesOfString:@"_" withString:@" "];
    adjustedBody = [adjustedBody stringByReplacingOccurrencesOfString:@"#" withString:@" "];
    adjustedBody = [adjustedBody stringByReplacingOccurrencesOfString:@":" withString:@" "];
    adjustedBody = [adjustedBody stringByReplacingOccurrencesOfString:@"|" withString:@" "];
    adjustedBody = [adjustedBody stringByReplacingOccurrencesOfString:@"." withString:@" "];
    adjustedBody = [adjustedBody stringByReplacingOccurrencesOfString:@"،" withString:@" "];
    
    adjustedBody = [adjustedBody stringByReplacingOccurrencesOfString:@"[ ]+"
                                                           withString:@" "
                                                              options:NSRegularExpressionSearch
                                                                range:NSMakeRange(0, adjustedBody.length)];
    
    adjustedBody = [adjustedBody stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSError *err = nil;
    NSArray *array = [NSJSONSerialization JSONObjectWithData:[[[NSUserDefaults standardUserDefaults] objectForKey:@"breakingWords"] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
    NSDictionary *dictionary;
    NSMutableArray *breakingNewsWordsArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < array.count; i++)
    {
        dictionary = [array objectAtIndex:i];
        [breakingNewsWordsArray addObject:[dictionary objectForKey:@"word"]];
    }
    NSArray* bodyArray = [adjustedBody componentsSeparatedByString:@" "];
    NSMutableArray* adjustedBodyArray = [[NSMutableArray alloc]init];
    
    for(NSString* string in bodyArray)
    {
        NSString* trimmedString = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if(trimmedString.length>2)
        {
            [adjustedBodyArray addObject:trimmedString];
        }
    }
    
    for(int i = 0 ; i < adjustedBodyArray.count ; i++)
    {
        for(int len = 1 ; (i+len) <= adjustedBodyArray.count ; len++)
        {
            NSArray* sliceArray = [adjustedBodyArray subarrayWithRange:NSMakeRange(i, len)];
            NSString* sliceString = [sliceArray componentsJoinedByString:@" "];
            sliceString = [sliceString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if([breakingNewsWordsArray containsObject:sliceString])
            {
                return YES;
            }
        }
    }
    
    [breakingNewsWordsArray removeAllObjects];
    
    return NO;
}

-(void)showNoInternet
{
    isReloaded = NO;
    [self performSegueWithIdentifier:@"noInternetSeg" sender:self];
}

-(void)showTheTable
{
    if (tableIsReady)
    {
        [tableView setHidden:NO];
        if (dataSource.count == 0)
        {
            [self showNoResults];
        }
        return;
    }
    
    tableIsReady = YES;
    [tableView setFrame:CGRectMake(tableView.frame.origin.x, tableView.frame.origin.y+tableView.frame.size.height, tableView.frame.size.width, tableView.frame.size.height)];
    [tableView setHidden:NO];
    [UIView animateWithDuration:0.3 delay:0.0 options:0
                     animations:^{
                         [tableView setFrame:CGRectMake(tableView.frame.origin.x, tableView.frame.origin.y-tableView.frame.size.height, tableView.frame.size.width, tableView.frame.size.height)];
                     }
                     completion:^(BOOL finished) {
                     }];
    [UIView commitAnimations];
}

-(void)startSearching
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isNightOn"])
    {
        _searchToolBar.tintColor = [UIColor lightGrayColor];
        _searchToolBar.barTintColor = [UIColor colorWithRed:70.0/255.0 green:70.0/255.0 blue:70.0/255.0 alpha:1.0];
        _searchToolBar.backgroundColor = [UIColor colorWithRed:70.0/255.0 green:70.0/255.0 blue:70.0/255.0 alpha:1.0];
        searchTextField.tintColor = [UIColor colorWithRed:70.0/255.0 green:70.0/255.0 blue:70.0/255.0 alpha:1.0];
    }
    else
    {
        _searchToolBar.tintColor = [UIColor darkGrayColor];
        _searchToolBar.barTintColor = [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0];
        _searchToolBar.backgroundColor = [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0];
        searchTextField.tintColor = [UIColor colorWithRed:70.0/255.0 green:70.0/255.0 blue:70.0/255.0 alpha:1.0];
    }
    
    searchTextField.inputAccessoryView = _searchToolBar;
    theSavedCount = 0;
    
    if (!isSearching)
    {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isNightOn"])
        {
            [searchTextField setKeyboardAppearance:UIKeyboardAppearanceDark];
        }
        else
        {
            [searchTextField setKeyboardAppearance:UIKeyboardAppearanceLight];
        }
        
        newsRect = [tableView bounds];
        
        [searchTextField setText:@""];
        isSearching = YES;
        [searchView setHidden:NO];
        CGRect frame = tableView.frame;
        frame.origin.y += 85;
        frame.size.height -= 85;
        [[self.navigationController view] addSubview:searchView];
        [searchView setFrame:CGRectMake(0, 20, [self.navigationController view].frame.size.width, 44)];
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^(void) {
                             searchView.alpha = 1.0f;
                             [tableView setFrame:frame];
                             [searchView setFrame:CGRectMake(0, 20, [self.navigationController view].frame.size.width, 128)];
                         }
                         completion:^(BOOL finished){
                             if (![[NSUserDefaults standardUserDefaults] boolForKey:@"isSearchHelp"])
                             {
                                 [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isSearchHelp"];
                                 [[NSUserDefaults standardUserDefaults] synchronize];
                                 [SADAHMsg showMsgWithTitle:@"البحث بأكثر من موضوع" andMsg:@"للبحث بأكثر من موضوع ضع فاصلة (،) بعد كل كلمة أو جملة، مثال: (آيفون، أبل، الوطن العربي)." inView:[self.navigationController view] withCase:1 withBlock:^(BOOL finished) {
                                     if(finished){
                                         [searchTextField becomeFirstResponder];
                                     }
                                 }];
                             }
                             else
                             {
                                 [searchTextField becomeFirstResponder];
                             }
                         }
         ];
    }
    else
    {
        [self cancelSearching];
    }
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (!(gestureRecognizer.state == UIGestureRecognizerStateBegan))
    {
        return;
    }
    
    NSIndexPath *indexPath = [tableView indexPathForRowAtPoint:[gestureRecognizer locationInView:tableView]];
    
    if (indexPath == nil)
    {
        return;
    }
    
    indVal = indexPath.row;
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if ([cell viewWithTag:5].alpha > 0)
    {
        UIImageView *fullImg = [[UIImageView alloc] initWithImage:[(UIImageView*)[cell viewWithTag:5] image]];
        
        [fullImg setContentMode:UIViewContentModeScaleAspectFit];
        
        [_imageScrollView addSubview:fullImg];
        
        isFullScreen = NO;
        
        CGRect rectOfCellInSuperview = [cell convertRect:[[cell viewWithTag:5] frame] toView:[self.navigationController view]];
        
        [[cell viewWithTag:5] setHidden:YES];
        
        [_imageScrollView setFrame:rectOfCellInSuperview];
        
        [[self.navigationController view] addSubview:_imageScrollView];
        
        [self imageFullScreen:nil];
    }
    else
    {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

-(void)handleDoubleTap:(UITapGestureRecognizer *)recognizer
{
    isTap = YES;
    UIScrollView *theScrollView = (UIScrollView*)[[[self navigationController] view] viewWithTag:191];
    
    if (theScrollView.zoomScale > 1.0)
    {
        [theScrollView setZoomScale:1.0 animated:YES];
    }
    else
    {
        CGPoint translation = [recognizer locationInView:[[[self navigationController] view] viewWithTag:191]];
        [theScrollView zoomToRect:CGRectMake(translation.x, translation.y, 2.0, 0.0) animated:YES];
    }
}

-(void)imageFullScreen:(UITapGestureRecognizer *)recognizeasdasrs
{
    if (!isFullScreen) {
        [UIView animateWithDuration:0.2 delay:0 options:0 animations:^{
            for (UIImageView *imgView in _imageScrollView.subviews)
            {
                isFirstDrag = YES;
                isTap = NO;
                [imgView setTag:893];
                imgView.frame = _imageScrollView.frame;
                prevFrame = imgView.frame;
                imgView.clipsToBounds = YES;
                UIScrollView *backgroundView = [[UIScrollView alloc] initWithFrame:imgView.frame];
                [backgroundView addGestureRecognizer:tap];
                [backgroundView addGestureRecognizer:dbTap];
                [_imageScrollView addSubview:backgroundView];
                [backgroundView setBackgroundColor:[UIColor blackColor]];
                [backgroundView addSubview:imgView];
                [backgroundView setTag:191];
                [[[self navigationController] view]addSubview:backgroundView];
                [backgroundView setFrame:[[self navigationController] view].frame];
                [imgView setFrame:[[self navigationController] view].frame];
                backgroundView.showsHorizontalScrollIndicator = NO;
                backgroundView.showsVerticalScrollIndicator = NO;
                
                UIPanGestureRecognizer *pngst = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
                pngst.delegate = self;
                [backgroundView addGestureRecognizer:pngst];
                
                UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                                      initWithTarget:self action:@selector(imageLongPress:)];
                lpgr.minimumPressDuration = 0.5;
                lpgr.delegate = self;
                [backgroundView addGestureRecognizer:lpgr];
                
                backgroundView.minimumZoomScale = 1.0;
                backgroundView.maximumZoomScale = 3.0;
                backgroundView.delegate = self;
                
                imgToSave = imgView.image;
                
                break;
            }
            
        }completion:^(BOOL finished){
            isFullScreen = YES;
            [self hideTheStatusBar];
        }];
        return;
    }
    else{
        [self performSelector:@selector(closeFullView) withObject:nil afterDelay:0.5];
        return;
    }
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

-(void)refreshStatusBar
{
    [self setNeedsStatusBarAppearanceUpdate];
}

-(void)closeFullView
{
    if (isTap)
    {
        isTap = NO;
        return;
    }
    
    if ([(UIScrollView*)[[[self navigationController] view] viewWithTag:191] zoomScale] >= 2.0)
    {
        [(UIScrollView*)[[[self navigationController] view] viewWithTag:191] setZoomScale:1.0 animated:YES];
        return;
    }
    
    [self showTheStatusBar];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indVal inSection:0]];
    [(UIImageView*)[[[self navigationController] view] viewWithTag:893] setContentMode:UIViewContentModeCenter];
    [[(UIImageView*)[[[self navigationController] view] viewWithTag:893] layer] setCornerRadius:5];
    [[[[self navigationController] view] viewWithTag:191] setBackgroundColor:[UIColor clearColor]];
    [[[self navigationController] view] addSubview:[[[self navigationController] view] viewWithTag:893]];
    [UIView animateWithDuration:0.2 delay:0 options:0 animations:^{
        CGRect rectOfCellInSuperview = [cell convertRect:[[cell viewWithTag:5] frame] toView:[self.navigationController view]];
        [[[[self navigationController] view] viewWithTag:191] setFrame:rectOfCellInSuperview];
        [[[[self navigationController] view] viewWithTag:893] setFrame:rectOfCellInSuperview];
        [_imageScrollView setFrame:[[cell viewWithTag:5] frame]];
    }completion:^(BOOL finished){
        isFullScreen = NO;
        [_imageScrollView removeFromSuperview];
        [[[[self navigationController] view] viewWithTag:191] removeFromSuperview];
        [[[[self navigationController] view] viewWithTag:893] removeFromSuperview];
        [[cell viewWithTag:5] setHidden:NO];
        [[tableView viewWithTag:5] setHidden:NO];
        for (UIView *view in [tableView subviews])
        {
            if (view.tag == 5)
            {
                [view setHidden:NO];
            }
        }
    }];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
       shouldReceiveTouch:(UITouch *)touch
{
    if ([[@"" stringByAppendingFormat:@"%@",[gestureRecognizer class]] rangeOfString:@"UIPanGestureRecognizer"].location != NSNotFound)
    {
        if ([(UIScrollView*)[[[self navigationController] view] viewWithTag:191] zoomScale] > 1.0)
        {
            return NO;
        }
    }

    return YES;
}

-(float)diffToAlpha:(CGFloat)theNum
{
    theNum = theNum /2;
    if (theNum/10 > 10)
    {
        return 0.4;
    }
    
    if (1.1-(theNum/100.0) < 0.4)
    {
        return 0.4;
    }
    
    return 1.1-(theNum/100.0);
}

- (IBAction)handlePan:(UIPanGestureRecognizer *)recognizer {
    if (isFirstDrag)
    {
        isFirstDrag = NO;
        scrollSavedPoint = [[[self navigationController] view] viewWithTag:191].center;
    }
    
    CGPoint translation = [recognizer translationInView:[[[self navigationController] view] viewWithTag:191]];
    
    [[[self navigationController] view] viewWithTag:893].center = CGPointMake([[[self navigationController] view] viewWithTag:893].center.x + translation.x,
                                         [[[self navigationController] view] viewWithTag:893].center.y + translation.y);
    
    CGFloat theXPoint;
    CGFloat theYPoint;
    
    if (scrollSavedPoint.x > [[[self navigationController] view] viewWithTag:893].center.x)
    {
        theXPoint = scrollSavedPoint.x - [[[self navigationController] view] viewWithTag:893].center.x;
    }
    else
    {
        theXPoint = [[[self navigationController] view] viewWithTag:893].center.x - scrollSavedPoint.x;
    }
    
    if (scrollSavedPoint.y > [[[self navigationController] view] viewWithTag:893].center.y)
    {
        theYPoint = scrollSavedPoint.y - [[[self navigationController] view] viewWithTag:893].center.y;
    }
    else
    {
        theYPoint = [[[self navigationController] view] viewWithTag:893].center.y - scrollSavedPoint.y;
    }
    
    [[[[self navigationController] view] viewWithTag:191] setBackgroundColor:[UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:[self diffToAlpha:theXPoint+theYPoint]]];
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        NSLog(@"End");
        if (theXPoint >= 100 || theYPoint >= 100)
        {
            [self closeFullView];
        }
        else
        {
            [UIView animateWithDuration:0.2 delay:0.0 options:0
                             animations:^{
                                 [[[self navigationController] view] viewWithTag:893].center = scrollSavedPoint;
                                 [[[[self navigationController] view] viewWithTag:191] setBackgroundColor:[UIColor blackColor]];
                             }
                             completion:^(BOOL finished) {
                             }];
            [UIView commitAnimations];
        }
    }
    
    
    [recognizer setTranslation:CGPointMake(0, 0) inView:[[[self navigationController] view] viewWithTag:893]];
    
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return [[[self navigationController] view] viewWithTag:893];
}

-(void)imageLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (!(gestureRecognizer.state == UIGestureRecognizerStateBegan))
    {
        return;
    }
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"إلغاء" destructiveButtonTitle:nil otherButtonTitles:@"حفظ الصورة",nil];
    [actionSheet setTag:14];
    [actionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    [actionSheet showInView:self.navigationController.view];
}

- (void)handleSwipeRight:(UISwipeGestureRecognizer *)gestureRecognizer
{
    CGPoint location = [gestureRecognizer locationInView:tableView];
    
    NSIndexPath *indexPath = [tableView indexPathForRowAtPoint:location];
    
    if(indexPath)
    {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        indVal = indexPath.row;
        
        BOOL isAddIt = NO;
        
        CGRect rectOfCellInSuperview = [cell convertRect:[[cell viewWithTag:8] frame] toView:tableView];
        
        UIView *favView = [[UIView alloc] initWithFrame:CGRectMake(-100, rectOfCellInSuperview.origin.y, 100, rectOfCellInSuperview.size.height)];
        
        [favView setBackgroundColor:[UIColor colorWithRed:20.0/255.0 green:20.0/255.0 blue:20.0/255.0 alpha:1.0]];
        
        UIImageView *favImg;
        
        [favView setTag:645];
        [favImg setTag:646];
        
        [favImg setContentMode:UIViewContentModeCenter];
        
        if (showingFav)
        {
            favImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"trash-off.png"]];
        }
        else
        {
            NSMutableArray* favs = [[NSMutableArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"favs"] copyItems:YES];
            
            if ([favs containsObject:[dataSource objectAtIndex:indexPath.row]])
            {
                favImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fav-on.png"]];
                [favs removeObject:[dataSource objectAtIndex:indexPath.row]];
            }
            else
            {
                favImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fav-off.png"]];
                [favs addObject:[dataSource objectAtIndex:indexPath.row]];
                isAddIt = YES;
            }
            
            NSArray* newFavs = [[NSArray alloc]initWithArray:favs copyItems:YES];
            [[NSUserDefaults standardUserDefaults]setObject:newFavs forKey:@"favs"];
            [[NSUserDefaults standardUserDefaults]synchronize];
        }
        
        [favImg setFrame:CGRectMake(-100, rectOfCellInSuperview.origin.y, 100, 110)];
        
        [tableView addSubview:favView];
        [tableView addSubview:favImg];
        
        favImg.center = favView.center;
        
        [UIView animateWithDuration:0.2 delay:0.0 options:0
                         animations:^{
                             [cell setFrame:CGRectMake(100, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height)];
                             [favView setFrame:CGRectMake(0, rectOfCellInSuperview.origin.y, 100, rectOfCellInSuperview.size.height)];
                             [favImg setFrame:CGRectMake(0, favImg.frame.origin.y, 100, 110)];
                         }
                         completion:^(BOOL finished) {
                             if (showingFav)
                             {
                                 [favImg setTag:646];
                                 favImg.image = [UIImage imageNamed:@"trash-on.png"];
                                 [self askToRemoveFav];
                             }
                             else
                             {
                                 [UIView animateWithDuration:0.2 delay:0.4 options:0
                                                  animations:^{
                                                      if (isAddIt)
                                                      {
                                                          favImg.image = [UIImage imageNamed:@"fav-on.png"];
                                                          [self playSound:@"in-sound"];
                                                      }
                                                      else
                                                      {
                                                          favImg.image = [UIImage imageNamed:@"fav-off.png"];
                                                          [self playSound:@"out-sound"];
                                                      }
                                                      [cell setFrame:CGRectMake(0, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height)];
                                                      [favView setFrame:CGRectMake(-100, rectOfCellInSuperview.origin.y, 100, rectOfCellInSuperview.size.height)];
                                                      [favImg setFrame:CGRectMake(-100, favImg.frame.origin.y, 100, 110)];
                                                      
                                                  }
                                                  completion:^(BOOL finished) {
                                                      [favView removeFromSuperview];
                                                      [favImg removeFromSuperview];
                                                      isFromSwipe = YES;
                                                      [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                                                  }];
                                 [UIView commitAnimations];
                             }
                         }];
        [UIView commitAnimations];
    }
}

-(void)askToRemoveFav
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"هل تريد حذف الخبر من المفضلة؟" delegate:self cancelButtonTitle:@"إلغاء" destructiveButtonTitle:@"حذف الخبر" otherButtonTitles:nil];
    [actionSheet setTag:15];
    [actionSheet showInView:self.view];
}

-(void)deleteTheFav
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indVal inSection:0]];
    CGRect rectOfCellInSuperview = [cell convertRect:[[cell viewWithTag:8] frame] toView:tableView];
    [UIView animateWithDuration:0.1 delay:0.0 options:0
                     animations:^{
                         [cell setFrame:CGRectMake(0, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height)];
                         [[tableView viewWithTag:646] setFrame:CGRectMake(-100, [tableView viewWithTag:646].frame.origin.y, 100, 110)];
                         [[tableView viewWithTag:645] setFrame:CGRectMake(-100, rectOfCellInSuperview.origin.y, 100, [tableView viewWithTag:645].frame.size.height)];
                     }
                     completion:^(BOOL finished) {
                         [[tableView viewWithTag:646] removeFromSuperview];
                         [[tableView viewWithTag:645] removeFromSuperview];
                         
                         NSMutableArray* favs = [[NSMutableArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"favs"] copyItems:YES];
                         
                         [favs removeObject:[dataSource objectAtIndex:indVal]];
                         
                         NSArray* newFavs = [[NSArray alloc]initWithArray:favs copyItems:YES];
                         [[NSUserDefaults standardUserDefaults]setObject:newFavs forKey:@"favs"];
                         [[NSUserDefaults standardUserDefaults]synchronize];
                         
                         [dataSource removeObjectAtIndex:indVal];
                         
                         [(UILabel*)[tableView viewWithTag:837] setText:[@"عدد الأخبار في المفضلة " stringByAppendingFormat:@"(%ld)",(long)dataSource.count]];
                         
                         [tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indVal inSection:0]] withRowAnimation:UITableViewRowAnimationMiddle];
                         
                         if (dataSource.count == 0)
                         {
                             [self openTimeline:nil];
                         }
                     }];
    [UIView commitAnimations];
}

-(void)closeFavSwipe
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indVal inSection:0]];
    CGRect rectOfCellInSuperview = [cell convertRect:[[cell viewWithTag:8] frame] toView:tableView];
    [UIView animateWithDuration:0.1 delay:0.0 options:0
                     animations:^{
                         [cell setFrame:CGRectMake(0, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height)];
                         [[tableView viewWithTag:646] setFrame:CGRectMake(-100, [tableView viewWithTag:646].frame.origin.y, 100, 110)];
                         [[tableView viewWithTag:645] setFrame:CGRectMake(-100, rectOfCellInSuperview.origin.y, 100, [tableView viewWithTag:645].frame.size.height)];
                     }
                     completion:^(BOOL finished) {
                         [[tableView viewWithTag:646] removeFromSuperview];
                         [[tableView viewWithTag:645] removeFromSuperview];
                     }];
    [UIView commitAnimations];
}

- (void)handleSwipeLeft:(UISwipeGestureRecognizer *)gestureRecognizer
{
    CGPoint location = [gestureRecognizer locationInView:tableView];
    
    NSIndexPath *indexPath = [tableView indexPathForRowAtPoint:location];
    
    if(indexPath)
    {
        indVal = indexPath.row;
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        if ([cell viewWithTag:5].alpha == 0 || [cell viewWithTag:5].isHidden)
        {
            imgToSave = nil;
        }
        else
        {
            imgToSave = [(UIImageView*)[cell viewWithTag:5] image];
        }
        
        CGRect rectOfCellInSuperview = [cell convertRect:[[cell viewWithTag:8] frame] toView:tableView];
        
        UIView *favView = [[UIView alloc] initWithFrame:CGRectMake(cell.frame.size.width, rectOfCellInSuperview.origin.y, 100, rectOfCellInSuperview.size.height)];
        
        [favView setBackgroundColor:[UIColor colorWithRed:20.0/255.0 green:20.0/255.0 blue:20.0/255.0 alpha:1.0]];
        
        UIImageView *favImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"share-off.png"]];
        
        [favImg setContentMode:UIViewContentModeCenter];
        
        [favImg setFrame:CGRectMake(cell.frame.size.width, rectOfCellInSuperview.origin.y, 100, 110)];
        
        [tableView addSubview:favView];
        [tableView addSubview:favImg];
        
        favImg.center = favView.center;
        
        [UIView animateWithDuration:0.2 delay:0.0 options:0
                         animations:^{
                             [cell setFrame:CGRectMake(-100, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height)];
                             [favView setFrame:CGRectMake(cell.frame.size.width-100, rectOfCellInSuperview.origin.y, 100, rectOfCellInSuperview.size.height)];
                             [favImg setFrame:CGRectMake(cell.frame.size.width-100, favImg.frame.origin.y, 100, 110)];
                         }
                         completion:^(BOOL finished) {
                             [UIView animateWithDuration:0.2 delay:0.4 options:0
                                              animations:^{
                                                  favImg.image = [UIImage imageNamed:@"share-on.png"];
                                              }
                                              completion:^(BOOL finished) {
                                                  cellToClose = cell;
                                                  _viewToClose = favView;
                                                  _imageToClose = favImg;
                                                  [self showSmartShare];
                                              }];
                         }];
        [UIView commitAnimations];
    }
}

-(void)showSmartShare
{
    SADAHBlurView *blurView = [[SADAHBlurView alloc] initWithFrame:self.navigationController.view.frame];
    
    UIView *backView = [[UIView alloc] initWithFrame:self.navigationController.view.frame];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isNightOn"])
    {
        backView.backgroundColor = [UIColor colorWithRed:20.0/255 green:20.0/255 blue:20.0/255 alpha:0.8];
    }
    else
    {
        backView.backgroundColor = [UIColor colorWithRed:221.0/255 green:221.0/255 blue:221.0/255 alpha:0.8];
    }
    
    [backView setTag:732];
    
    [blurView setTag:733];
    
    blurView.backgroundColor = [UIColor blackColor];
    
    blurView.blurRadius = 10;
    
    blurView.alpha = 1.0;
    
    [[self.navigationController view] addSubview:blurView];
    
    [[self.navigationController view] addSubview:backView];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isNightOn"])
    {
        _shareView.backgroundColor = [UIColor colorWithRed:50.0/255.0 green:50.0/255.0 blue:50.0/255.0 alpha:1.0];
        _shareLabel1.textColor = [UIColor lightGrayColor];
        _shareLabel2.textColor = [UIColor lightGrayColor];
        _shareLabel3.textColor = [UIColor lightGrayColor];
        _shareLabel4.textColor = [UIColor lightGrayColor];
        _shareCancelButton.backgroundColor = [UIColor colorWithRed:56.0/255.0 green:56.0/255.0 blue:56.0/255.0 alpha:1.0];
        [_shareCancelButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [_shareCancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [_shareCancelButton setBackgroundImage:[UIImage imageNamed:@"settings-selected-back.png"] forState:UIControlStateHighlighted];
    }
    else
    {
        _shareView.backgroundColor = [UIColor colorWithRed:241.0/255.0 green:241.0/255.0 blue:241.0/255.0 alpha:1.0];
        _shareLabel1.textColor = [UIColor colorWithRed:70.0/255.0 green:70.0/255.0 blue:70.0/255.0 alpha:1.0];
        _shareLabel2.textColor = [UIColor colorWithRed:70.0/255.0 green:70.0/255.0 blue:70.0/255.0 alpha:1.0];
        _shareLabel3.textColor = [UIColor colorWithRed:70.0/255.0 green:70.0/255.0 blue:70.0/255.0 alpha:1.0];
        _shareLabel4.textColor = [UIColor colorWithRed:70.0/255.0 green:70.0/255.0 blue:70.0/255.0 alpha:1.0];
        _shareCancelButton.backgroundColor = [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0];
        [_shareCancelButton setTitleColor:[UIColor colorWithRed:70.0/255.0 green:70.0/255.0 blue:70.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        [_shareCancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
        [_shareCancelButton setBackgroundImage:[UIImage imageNamed:@"news-selected-back.png"] forState:UIControlStateHighlighted];
    }
    
    [_shareView.layer setCornerRadius:5];
    
    [[self.navigationController view] addSubview:_shareView];
    _shareView.center = [self.navigationController view].center;
    _shareView.transform = CGAffineTransformMakeScale(-1, 0);
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^(void) {
                         _shareView.transform = CGAffineTransformMakeScale(1, 1);
                         [self playSound:@"swipe"];
                     }
                     completion:nil];
}

-(void)closeSmartShare:(BOOL)isCloseAll
{
    CGRect rectOfCellInSuperview = [cellToClose convertRect:[[cellToClose viewWithTag:8] frame] toView:tableView];
    [UIView animateWithDuration:0.3 delay:0.0 options:0
                     animations:^{
                         [[[self.navigationController view] viewWithTag:732] setAlpha:0.0];
                         [[[self.navigationController view] viewWithTag:733] setAlpha:0.0];
                         [_shareView setFrame:CGRectMake(_shareView.frame.origin.x, _shareView.frame.origin.y+500, _shareView.frame.size.width, _shareView.frame.size.height)];
                         if (isCloseAll)
                         {
                             [cellToClose setFrame:CGRectMake(0, cellToClose.frame.origin.y, cellToClose.frame.size.width, cellToClose.frame.size.height)];
                             [_viewToClose setFrame:CGRectMake(cellToClose.frame.size.width, rectOfCellInSuperview.origin.y, 100, rectOfCellInSuperview.size.height)];
                             [_imageToClose setFrame:CGRectMake(cellToClose.frame.size.width, _imageToClose.frame.origin.y, 100, 100)];
                         }
                     }
                     completion:^(BOOL finished) {
                         [_shareView removeFromSuperview];
                         [[[self.navigationController view] viewWithTag:732] removeFromSuperview];
                         [[[self.navigationController view] viewWithTag:733] removeFromSuperview];
                         if (isCloseAll)
                         {
                             [_viewToClose removeFromSuperview];
                             [_imageToClose removeFromSuperview];
                         }
                     }];
    [UIView commitAnimations];
}

- (IBAction)closeShareView:(id)sender {
    [self closeSmartShare:YES];
}

- (IBAction)topShareAction:(id)sender {
    if ([sender tag] == 1)
    {
        [self shareOnInstagram];
    }
    else if ([sender tag] == 2)
    {
        [self shareOnTwitter];
    }
    else if ([sender tag] == 3)
    {
        [self shareOnFacebook];
    }
    else if ([sender tag] == 4)
    {
        [self shareViaMail];
    }
}

- (IBAction)bottomShareAction:(id)sender {
    if ([sender tag] == 1)
    {
        [self openLinkInSafari];
    }
    else if ([sender tag] == 2)
    {
        [self copNews];
    }
    else if ([sender tag] == 3)
    {
        if (imgToSave == nil)
        {
            [self showStatusBarMsg:@"لا يوجد صورة في هذا الخبر" isRed:YES];
        }
        else
        {
            [self saveTheImg];
            [self closeSmartShare:YES];
        }
    }
    else if ([sender tag] == 4)
    {
        [self openShareMore];
    }
}

-(void)openLinkInSafari
{
    NSDictionary* news = [dataSource objectAtIndex:indVal];
    if([[news objectForKey:@"newsURL"]isEqualToString:@""])
    {
        [self showStatusBarMsg:@"لايوجد رابط لهذا الخبر حتى يتم فتحه" isRed:YES];
    }
    else
    {
        [self performSelector:@selector(openLink:) withObject:[news objectForKey:@"newsURL"] afterDelay:0.3];
        [self closeSmartShare:YES];
    }
}

-(void)openLink:(NSString*)theLink
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[theLink stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
}

-(void)copNews
{
    NSDictionary* news = [dataSource objectAtIndex:indVal];
    [[UIPasteboard generalPasteboard] setString:[[news objectForKey:@"body"] stringByAppendingFormat:@"%@",@"\n\n#تطبيق_من_المصدر"]];
    [self showStatusBarMsg:@"تم نسخ الخبر بنجاح" isRed:NO];
    [self closeSmartShare:YES];
}

-(void)openShareMore
{
    [self shareNewsForCell:cellToClose andIndex:indVal andView:_viewToClose andImg:_imageToClose];
    [self closeSmartShare:NO];
}

-(void)shareOnInstagram
{
    NSDictionary* news = [dataSource objectAtIndex:indVal];
    
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://app"];
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL])
    {
        NSString *caption = [[news objectForKey:@"body"] stringByAppendingFormat:@"%@",@"\n\n#تطبيق_من_المصدر"];
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library writeImageDataToSavedPhotosAlbum:UIImagePNGRepresentation(imgToSave) metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
            NSString *escapedCaption  = [self urlencodedString:caption];
            NSURL *instagramURL = [NSURL URLWithString:[NSString stringWithFormat:[@"instagram://library?AssetPath=%@&InstagramCaption=%@" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],assetURL.absoluteString,escapedCaption]];
            if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
                [[UIApplication sharedApplication] openURL:instagramURL];
            }
        }];
    }
    else
    {
        [SADAHMsg showMsgWithTitle:@"لا يمكن المشاركة" andMsg:@"تأكد أن تطبيق انستغرام موجود على جهازك ثم حاول مرة ثانية." inView:[self.navigationController view] withCase:2];
    }
}

-(void)shareOnTwitter
{
    if(![SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        [SADAHMsg showMsgWithTitle:@"لا يمكن المشاركة" andMsg:@"تأكد من وجود حساب تويتر واحد على الأقل مفعل في جهازك وذلك من إعدادات الجهاز." inView:[self.navigationController view] withCase:2];
        return;
    }
    NSDictionary* news = [dataSource objectAtIndex:indVal];
    SLComposeViewController *tweetComposerSheet;
    tweetComposerSheet = [[SLComposeViewController alloc] init]; //initiate the Social Controller
    tweetComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter]; //Tell him with what social plattform to use it, e.g. facebook or twitter
    [tweetComposerSheet setInitialText:[NSString stringWithFormat:@"%@\n\n%@",[news objectForKey:@"body"],@"#تطبيق_من_المصدر"]];
    [tweetComposerSheet addImage:imgToSave];
    if(![[news objectForKey:@"newsURL"]isEqualToString:@""])
    {
        [tweetComposerSheet addURL:[NSURL URLWithString:[[news objectForKey:@"newsURL"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    }
    [tweetComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
        [self closeSmartShare:YES];
        switch (result) {
            case SLComposeViewControllerResultCancelled:
                break;
            case SLComposeViewControllerResultDone:
                [SADAHMsg showDoneMsgWithTitle:@"تمت المشاركة" andMsg:@"تمت مشاركة الخبر بنجاح عبر حسابك في تويتر." inView:[self.navigationController view]];
                break;
            default:
                break;
        }
    }];
    [self presentViewController:tweetComposerSheet animated:YES completion:nil];
}

-(void)shareOnFacebook
{
    if(![SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        [SADAHMsg showMsgWithTitle:@"لا يمكن المشاركة" andMsg:@"تأكد من وجود حساب فيس بوك مفعل في جهازك وذلك من إعدادات الجهاز." inView:[self.navigationController view] withCase:2];
        return;
    }
    NSDictionary* news = [dataSource objectAtIndex:indVal];
    SLComposeViewController *faceComposerSheet;
    faceComposerSheet = [[SLComposeViewController alloc] init]; //initiate the Social Controller
    faceComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook]; //Tell him with what social plattform to use it, e.g. facebook or twitter
    [faceComposerSheet setInitialText:[NSString stringWithFormat:@"%@\n\n%@",[news objectForKey:@"body"],@"#تطبيق_من_المصدر"]]; //the message you want to post
    [faceComposerSheet addImage:imgToSave];
    if(![[news objectForKey:@"newsURL"]isEqualToString:@""])
    {
        [faceComposerSheet addURL:[NSURL URLWithString:[[news objectForKey:@"newsURL"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    }
    [self presentViewController:faceComposerSheet animated:YES completion:nil];
    
    [faceComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
        [self closeSmartShare:YES];
        switch (result) {
            case SLComposeViewControllerResultCancelled:
                break;
            case SLComposeViewControllerResultDone:
                [SADAHMsg showDoneMsgWithTitle:@"تمت المشاركة" andMsg:@"تمت مشاركة الخبر بنجاح عبر حسابك في فيس بوك." inView:[self.navigationController view]];
                break;
            default:
                break;
        }
    }];
}

-(void)shareViaMail
{
    if ([MFMailComposeViewController canSendMail])
    {
        NSDictionary* news = [dataSource objectAtIndex:indVal];
        
        MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
        
        picker.mailComposeDelegate = self;
        
        NSData *imageData = UIImageJPEGRepresentation(imgToSave, 0.5);
        [picker addAttachmentData:imageData mimeType:@"image/jpeg" fileName:[NSString stringWithFormat:@"1.jpg"]];
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0)
        {
            [[picker navigationBar] setTintColor:[UIColor colorWithRed:170.0/255 green:64.0/255 blue:65.0/255 alpha:1]];
        }
        
        [picker setMessageBody:[@"" stringByAppendingFormat:@"%@\n\n%@",[news objectForKey:@"body"],@"#تطبيق_من_المصدر"] isHTML:NO];
        
        [self presentViewController:picker animated:YES completion:nil];
    }
    else
    {
        [SADAHMsg showMsgWithTitle:@"لا يمكن المشاركة" andMsg:@"تأكد من وجود حساب بريد الكتروني مفعل في جهازك وذلك من إعدادات الجهاز." inView:[self.navigationController view] withCase:2];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self closeSmartShare:YES];
}

-(NSString*)urlencodedString:(NSString*)theStr
{
    return [theStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

-(void)shareNewsForCell:(UITableViewCell*)cell andIndex:(NSInteger)theInd andView:(UIView*)theView andImg:(UIImageView*)theImgView
{
    NSDictionary* news = [dataSource objectAtIndex:theInd];
    
    CGRect rectOfCellInSuperview = [cell convertRect:[[cell viewWithTag:8] frame] toView:tableView];
    
    NSString *sharedMsg = [@"" stringByAppendingFormat:@"%@\n\n%@",[news objectForKey:@"body"],@"#تطبيق_من_المصدر"];
    NSArray* sharedObjects;
    
    if([[news objectForKey:@"mediaURL"]isEqualToString:@""])
    {
        sharedObjects=[NSArray arrayWithObjects:sharedMsg, nil];
    }else
    {
        UIImageView* imageView = (UIImageView*)[cell viewWithTag:5];
        UIImage* sharedImg=imageView.image;
        sharedObjects=[NSArray arrayWithObjects:sharedMsg, sharedImg, nil];
    }
    
    self.navigationItem.rightBarButtonItems = nil;
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc]
                                                        initWithActivityItems:sharedObjects applicationActivities:nil];
    activityViewController.popoverPresentationController.sourceView = self.navigationController.view;
    
    activityViewController.completionHandler = ^(NSString *activityType, BOOL completed) {
        [UIView animateWithDuration:0.1 delay:0.0 options:0
                         animations:^{
                             [cell setFrame:CGRectMake(0, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height)];
                             [theView setFrame:CGRectMake(cell.frame.size.width, rectOfCellInSuperview.origin.y, 100, rectOfCellInSuperview.size.height)];
                             [theImgView setFrame:CGRectMake(cell.frame.size.width, theImgView.frame.origin.y, 100, 100)];
                         }
                         completion:^(BOOL finished) {
                             [self refreshNavigationItems];
                             [theView removeFromSuperview];
                             [theImgView removeFromSuperview];
                         }];
        [UIView commitAnimations];
    };
    
    [self presentViewController:activityViewController animated:YES completion:nil];
}

-(void)addActivityView
{
    [_anmImg setHidden:NO];
    _anmImg.animationImages = [NSArray arrayWithObjects:[UIImage imageNamed:[[self waitImgName] stringByAppendingString:@"wait-img-1.png"]], [UIImage imageNamed:[[self waitImgName] stringByAppendingString:@"wait-img-2.png"]],[UIImage imageNamed:[[self waitImgName] stringByAppendingString:@"wait-img-3.png"]],nil];
    [_anmImg setAnimationRepeatCount:9999];
    _anmImg.animationDuration = 0.6;
    [_anmImg startAnimating];

    [self performSelector:@selector(addTheNewsImg1) withObject:nil afterDelay:0.2];
    [self performSelector:@selector(addTheNewsImg2) withObject:nil afterDelay:0.6];
    [self performSelector:@selector(addTheNewsImg3) withObject:nil afterDelay:1.0];
}

-(NSString*)waitImgName
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isNightOn"])
    {
        return @"night-";
    }
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"currentColor"] == 3)
    {
        return @"blue-";
    }
    else if ([[NSUserDefaults standardUserDefaults] integerForKey:@"currentColor"] == 4)
    {
        return @"purple-";
    }
    else if ([[NSUserDefaults standardUserDefaults] integerForKey:@"currentColor"] == 5)
    {
        return @"green-";
    }
    else if ([[NSUserDefaults standardUserDefaults] integerForKey:@"currentColor"] == 6)
    {
        return @"red-";
    }
    
    return @"black-";
}

-(void)addTheNewsImg1
{
    [UIView animateWithDuration:0.2 delay:0.0 options:0
                     animations:^{
                         _newsImg2.center = _newsImg1.center;
                     }
                     completion:^(BOOL finished) {
                         //
                     }];
    [UIView commitAnimations];
}

-(void)addTheNewsImg2
{
    [UIView animateWithDuration:0.2 delay:0.0 options:0
                     animations:^{
                         _newsImg3.center = _newsImg1.center;
                     }
                     completion:^(BOOL finished) {
                         //
                     }];
    [UIView commitAnimations];
}

-(void)addTheNewsImg3
{
    [UIView animateWithDuration:0.2 delay:0.0 options:0
                     animations:^{
                         _newsImg4.center = _newsImg1.center;
                     }
                     completion:^(BOOL finished) {
                         if (isRemoveAct)
                         {
                             [self removeActivityView];
                         }
                         else
                         {
                             isRemoveAct = YES;
                         }
                         if(![self connected])
                         {
                             [self showNoInternet];
                         }
                     }];
    [UIView commitAnimations];
}

-(void)removeActivityView
{
    if (!isRemoveAct)
    {
        isRemoveAct = YES;
        return;
    }
    isRemoveAct = NO;
    [_anmImg stopAnimating];
    [_anmImg setHidden:YES];
    
    [_newsImg1 setHidden:YES];
    [_newsImg2 setHidden:YES];
    [_newsImg3 setHidden:YES];
    [_newsImg4 setHidden:YES];
    
    if(![self connected])
    {
        [self showNoInternet];
    }
    
    [self showTheTable];
    
    if (!isLoadComplated)
    {
        isLoadComplated = YES;
        self.navigationItem.rightBarButtonItems = nil;
        [self refreshNavigationItems];
    }
}

- (void)refreshTable
{
    NSLog(@"refreshTable");
    if(showingFav)
    {
        [refreshControl endRefreshing];
    }
    else if (isSearching)
    {
        isFromRefresh = YES;
        [self getSearchData];
    }
    else if (isOnBreakingNews)
    {
        [self getDataForBreakingNews:1];
    }
    else
    {
        [self getData];
    }
}

-(void)applicationWillEnterForeground:(UIApplication *)application
{
    isOnNews = YES;
    if (!isSearching && !showingFav && !isOnBreakingNews)
    {
        [self getData];
    }
}

-(void)applicationDidEnterBackground:(UIApplication *)application
{
    isOnNews = NO;
}

-(void)addRefreshView
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isNightOn"])
    {
        [refreshControl removeFromSuperview];
        refreshControl = nil;
        refreshControl = [[UIRefreshControl alloc]init];
        refreshControl.backgroundColor = [UIColor clearColor];
        refreshControl.tintColor = [UIColor lightGrayColor];
        [tableView addSubview:refreshControl];
        [refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    }
    else
    {
        [refreshControl removeFromSuperview];
        refreshControl = nil;
        refreshControl = [[UIRefreshControl alloc]init];
        refreshControl.backgroundColor = [UIColor clearColor];
        refreshControl.tintColor = [UIColor colorWithRed:85.0/255.0 green:85.0/255.0 blue:85.0/255.0 alpha:1.0];
        [tableView addSubview:refreshControl];
        [refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    }
}

-(void)setTheColor
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isNightOn"])
    {
        [_optionsNavBar setTintColor:[UIColor whiteColor]];
        [_optionsNavBar setBarTintColor:[UIColor colorWithRed:70.0/255.0 green:70.0/255.0 blue:70.0/255.0 alpha:1.0]];
        [_optionsNavBar setBarStyle:UIBarStyleBlack];
        
        [_searchNavBar setTintColor:[UIColor whiteColor]];
        [_searchNavBar setBarTintColor:[UIColor colorWithRed:70.0/255.0 green:70.0/255.0 blue:70.0/255.0 alpha:1.0]];
        [_searchNavBar setBarStyle:UIBarStyleBlack];
        
        [searchView setBackgroundColor:[UIColor colorWithRed:70.0/255.0 green:70.0/255.0 blue:70.0/255.0 alpha:1.0]];
        
        [searchTextField setBackgroundColor:[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0]];
        
        [searchSegment setTintColor:[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0]];
        
        [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
        [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
        [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:70.0/255.0 green:70.0/255.0 blue:70.0/255.0 alpha:1.0]];
        
        [_newsMainView setBackgroundColor:[UIColor colorWithRed:20.0/255.0 green:20.0/255.0 blue:20.0/255.0 alpha:1.0]];
        
        [self addRefreshView];
        
        if (isFromNight)
        {
            isFromNight = NO;
        }
        else
        {
            if (isLoadComplated)
            {
                self.navigationItem.rightBarButtonItems = nil;
                [self refreshNavigationItems];
            }
        }
        
        return;
    }
    
    [self addRefreshView];
    
    [_newsMainView setBackgroundColor:[UIColor colorWithRed:221.0/255.0 green:221.0/255.0 blue:221.0/255.0 alpha:1.0]];
    
    [searchView setBackgroundColor:[UIColor colorWithRed:241.0/255.0 green:241.0/255.0 blue:241.0/255.0 alpha:1.0]];
    
    [searchTextField setBackgroundColor:[UIColor whiteColor]];
    
    [searchSegment setTintColor:[UIColor colorWithRed:37.0/255.0 green:37.0/255.0 blue:37.0/255.0 alpha:1.0]];
    
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"currentColor"] == 1)
    {
        [_optionsNavBar setTintColor:[UIColor whiteColor]];
        [_optionsNavBar setBarTintColor:[UIColor colorWithRed:50.0/255.0 green:50.0/255.0 blue:50.0/255.0 alpha:1.0]];
        [_optionsNavBar setBarStyle:UIBarStyleBlack];
        
        [_searchNavBar setTintColor:[UIColor whiteColor]];
        [_searchNavBar setBarTintColor:[UIColor colorWithRed:50.0/255.0 green:50.0/255.0 blue:50.0/255.0 alpha:1.0]];
        [_searchNavBar setBarStyle:UIBarStyleBlack];
        
        [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
        [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
        [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:50.0/255.0 green:50.0/255.0 blue:50.0/255.0 alpha:1.0]];
    }
    else if ([[NSUserDefaults standardUserDefaults] integerForKey:@"currentColor"] == 2)
    {
        [_optionsNavBar setTintColor:[UIColor colorWithRed:37.0/255.0 green:37.0/255.0 blue:37.0/255.0 alpha:1.0]];
        [_optionsNavBar setBarTintColor:[UIColor colorWithRed:241.0/255.0 green:241.0/255.0 blue:241.0/255.0 alpha:1.0]];
        [_optionsNavBar setBarStyle:UIBarStyleDefault];
        
        [_searchNavBar setTintColor:[UIColor colorWithRed:37.0/255.0 green:37.0/255.0 blue:37.0/255.0 alpha:1.0]];
        [_searchNavBar setBarTintColor:[UIColor colorWithRed:241.0/255.0 green:241.0/255.0 blue:241.0/255.0 alpha:1.0]];
        [_searchNavBar setBarStyle:UIBarStyleDefault];
        
        [self.navigationController.navigationBar setBarStyle:UIBarStyleDefault];
        [self.navigationController.navigationBar setTintColor:[UIColor colorWithRed:37.0/255.0 green:37.0/255.0 blue:37.0/255.0 alpha:1.0]];
        [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:241.0/255.0 green:241.0/255.0 blue:241.0/255.0 alpha:1.0]];
    }
    else if ([[NSUserDefaults standardUserDefaults] integerForKey:@"currentColor"] == 3)
    {
        [_optionsNavBar setTintColor:[UIColor whiteColor]];
        [_optionsNavBar setBarTintColor:[UIColor colorWithRed:33.0/255.0 green:125.0/255.0 blue:140.0/255.0 alpha:1.0]];
        [_optionsNavBar setBarStyle:UIBarStyleBlack];
        
        [_searchNavBar setTintColor:[UIColor whiteColor]];
        [_searchNavBar setBarTintColor:[UIColor colorWithRed:33.0/255.0 green:125.0/255.0 blue:140.0/255.0 alpha:1.0]];
        [_searchNavBar setBarStyle:UIBarStyleBlack];
        
        [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
        [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
        [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:33.0/255.0 green:125.0/255.0 blue:140.0/255.0 alpha:1.0]];
    }
    else if ([[NSUserDefaults standardUserDefaults] integerForKey:@"currentColor"] == 4)
    {
        [_optionsNavBar setTintColor:[UIColor whiteColor]];
        [_optionsNavBar setBarTintColor:[UIColor colorWithRed:118.0/255.0 green:0.0/255.0 blue:161.0/255.0 alpha:1.0]];
        [_optionsNavBar setBarStyle:UIBarStyleBlack];
        
        [_searchNavBar setTintColor:[UIColor whiteColor]];
        [_searchNavBar setBarTintColor:[UIColor colorWithRed:118.0/255.0 green:0.0/255.0 blue:161.0/255.0 alpha:1.0]];
        [_searchNavBar setBarStyle:UIBarStyleBlack];
        
        [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
        [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
        [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:118.0/255.0 green:0.0/255.0 blue:161.0/255.0 alpha:1.0]];
    }
    else if ([[NSUserDefaults standardUserDefaults] integerForKey:@"currentColor"] == 5)
    {
        [_optionsNavBar setTintColor:[UIColor whiteColor]];
        [_optionsNavBar setBarTintColor:[UIColor colorWithRed:26.0/255.0 green:140.0/255.0 blue:55.0/255.0 alpha:1.0]];
        [_optionsNavBar setBarStyle:UIBarStyleBlack];
        
        [_searchNavBar setTintColor:[UIColor whiteColor]];
        [_searchNavBar setBarTintColor:[UIColor colorWithRed:26.0/255.0 green:140.0/255.0 blue:55.0/255.0 alpha:1.0]];
        [_searchNavBar setBarStyle:UIBarStyleBlack];
        
        [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
        [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
        [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:26.0/255.0 green:140.0/255.0 blue:55.0/255.0 alpha:1.0]];
    }
    else if ([[NSUserDefaults standardUserDefaults] integerForKey:@"currentColor"] == 6)
    {
        [_optionsNavBar setTintColor:[UIColor whiteColor]];
        [_optionsNavBar setBarTintColor:[UIColor colorWithRed:185.0/255.0 green:21.0/255.0 blue:57.0/255.0 alpha:1.0]];
        [_optionsNavBar setBarStyle:UIBarStyleBlack];
        
        [_searchNavBar setTintColor:[UIColor whiteColor]];
        [_searchNavBar setBarTintColor:[UIColor colorWithRed:185.0/255.0 green:21.0/255.0 blue:57.0/255.0 alpha:1.0]];
        [_searchNavBar setBarStyle:UIBarStyleBlack];
        
        [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
        [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
        [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:185.0/255.0 green:21.0/255.0 blue:57.0/255.0 alpha:1.0]];
    }
    else
    {
        [_optionsNavBar setTintColor:[UIColor whiteColor]];
        [_optionsNavBar setBarTintColor:[UIColor colorWithRed:50.0/255.0 green:50.0/255.0 blue:50.0/255.0 alpha:1.0]];
        [_optionsNavBar setBarStyle:UIBarStyleBlack];
        
        [_searchNavBar setTintColor:[UIColor whiteColor]];
        [_searchNavBar setBarTintColor:[UIColor colorWithRed:50.0/255.0 green:50.0/255.0 blue:50.0/255.0 alpha:1.0]];
        [_searchNavBar setBarStyle:UIBarStyleBlack];
        
        [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
        [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
        [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:50.0/255.0 green:50.0/255.0 blue:50.0/255.0 alpha:1.0]];
    }
    
    if (isFromNight)
    {
        isFromNight = NO;
    }
    else
    {
        if (isLoadComplated)
        {
            self.navigationItem.rightBarButtonItems = nil;
            [self refreshNavigationItems];
        }
    }
}

-(void)startBackAnimation
{
    NSArray *visibleCellsArray = [NSArray arrayWithArray:[tableView indexPathsForVisibleRows]];
    
    UITableViewCell *anmCell;
    
    for (int i = 0; i < visibleCellsArray.count; i++)
    {
        anmCell = [tableView cellForRowAtIndexPath:[visibleCellsArray objectAtIndex:i]];
        
        [anmCell setFrame:CGRectMake(anmCell.frame.origin.x-anmCell.frame.size.width, anmCell.frame.origin.y, anmCell.frame.size.width, anmCell.frame.size.height)];
    }
    
    anmInt = 0;
    
    [self reloadCells:visibleCellsArray.count];
}

-(void)reloadCells:(NSInteger)totalCells
{
    UITableViewCell *anmCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:anmInt inSection:0]];
    
    [UIView animateWithDuration:0.3 delay:0.0 options:0
                     animations:^{
                         anmInt++;
                         [anmCell setFrame:CGRectMake(anmCell.frame.origin.x+anmCell.frame.size.width, anmCell.frame.origin.y, anmCell.frame.size.width, anmCell.frame.size.height)];
                     }
                     completion:^(BOOL finished) {
                         if (anmInt < totalCells)
                         {
                             [self reloadCells:totalCells];
                         }
                     }];
    [UIView commitAnimations];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    isOnNews = NO;
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (isSearching)
    {
        [searchView setHidden:YES];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (isSearching)
    {
        [searchView setHidden:NO];
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isLandscapeOn"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self setTheColor];
    
    isOnNews = YES;
    
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:animated];
    
    [retryButton setAlpha:0];
    
    sources = [[NSMutableArray alloc]init];
    
    NSArray* subs = [[NSUserDefaults standardUserDefaults] objectForKey:@"subscriptions"];
    for(NSDictionary* dict in subs)
    {
        [sources addObject:[dict objectForKey:@"twitterID"]];
    }
    
    if (isSettingsBack)
    {
        isSettingsBack = NO;
        [self startBackAnimation];
    }
}
-(void)viewDidAppear:(BOOL)animated
{
    if (isReloaded)
    {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isReloadNeeded"])
        {
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isReloadNeeded"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [tableView reloadData];
        }
        return;
    }
    isReloaded = YES;
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
    if(!showingFav && !loadingData && !isOnBreakingNews)
    {
        loadingData = YES;
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        
        
        if([dataSource count] == 0)
        {
            [loader setAlpha:1.0];
            
            NSDictionary* params = @{@"lowerID":upperCurrentID,@"sources":[sources componentsJoinedByString:@","]};
            
            [manager POST:@"http://almasdarapp.com/almasdar/getNewerNews.php" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                [loader setAlpha:0.0];
                [self removeActivityView];
                [refreshControl endRefreshing];
                
                dataSource = [[NSMutableArray alloc]initWithArray:[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil]];
                
                if([dataSource count]>0)
                {
                    upperCurrentID = [[dataSource objectAtIndex:0] objectForKey:@"id"];
                    lowerCurrentID = [[dataSource lastObject] objectForKey:@"id"];
                }
                
                [(UILabel*)[tableView viewWithTag:837] setText:[@"عدد الأخبار المتبقية " stringByAppendingFormat:@"(%ld)",(long)[self getTheCount]]];
                
                breakingArray = [[NSMutableArray alloc] init];
                NSDictionary* news;
                for (int i = 0; i < dataSource.count; i++)
                {
                    news = [dataSource objectAtIndex:i];
                    if ([self isBreakingNews:[news objectForKey:@"body"]])
                    {
                        [breakingArray addObject:@"1"];
                    }
                    else
                    {
                        [breakingArray addObject:@"0"];
                    }
                }
                
                NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:dataSource];
                dataSource = [[NSMutableArray alloc] initWithArray:[orderedSet array]];
                
                [tableView reloadData];
                [tableView setNeedsDisplay];
                
                
                loadingData = NO;
                
                if (isAfterSearch)
                {
                    isAfterSearch = NO;
                    [self performSelector:@selector(scrollTableToNewsRect) withObject:nil afterDelay:0.5];
                }
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [loader setAlpha:0.0];
                [self removeActivityView];
                [refreshControl endRefreshing];
                loadingData = NO;
                [SADAHMsg showMsgWithTitle:@"خطأ في الإتصال" andMsg:@"هناك خطأ في الإتصال بسيرفر التطبيق، برجاء حاول مجدداً بعد قليل وشكراً لك." inView:[self.navigationController view] withCase:2];
                NSLog(@"Error: %@", error);}];
        }else
        {
            [loader setAlpha:1.0];
            
            NSDictionary* params = @{@"lowerID":upperCurrentID,@"sources":[sources componentsJoinedByString:@","]};
            
            [manager POST:@"http://almasdarapp.com/almasdar/getNewerNews.php" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                [loader setAlpha:0.0];
                [self removeActivityView];
                [refreshControl endRefreshing];
                
                NSMutableArray* newNews = [[NSMutableArray alloc]initWithArray:[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil]];
                if([newNews count]>0)
                {
                    //[newNews addObjectsFromArray:dataSource];
                    //dataSource = [[NSMutableArray alloc]initWithArray:newNews copyItems:YES];
                    upperCurrentID = [[newNews objectAtIndex:0] objectForKey:@"id"];
                    CGPoint offset = tableView.contentOffset;
                    for(int i = (int)newNews.count-1 ; i >= 0 ; i--)
                    {
                        
                        
                        [dataSource insertObject:[newNews objectAtIndex:i] atIndex:0];
//                        [tableView beginUpdates];
//                        [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                        if([[[newNews objectAtIndex:i] objectForKey:@"mediaURL"] isEqualToString:@""])
                        {
                            offset.y += 150.0;
                        }else
                        {
                            offset.y += 358.0;
                        }
//                        [tableView endUpdates];
                    }
                    
                    breakingArray = [[NSMutableArray alloc] init];
                    NSDictionary* news;
                    for (int i = 0; i < dataSource.count; i++)
                    {
                        news = [dataSource objectAtIndex:i];
                        if ([self isBreakingNews:[news objectForKey:@"body"]])
                        {
                            [breakingArray addObject:@"1"];
                        }
                        else
                        {
                            [breakingArray addObject:@"0"];
                        }
                    }
                    
                    NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:dataSource];
                    dataSource = [[NSMutableArray alloc] initWithArray:[orderedSet array]];
                    
                    [tableView reloadData];
                    
                    [(UILabel*)[tableView viewWithTag:837] setText:[@"عدد الأخبار المتبقية " stringByAppendingFormat:@"(%ld)",(long)[self getTheCount]]];
                    [tableView setContentOffset:offset animated:NO];
                    if (!isSearching)[self performSelector:@selector(addScrollTopButton:) withObject:[@"" stringByAppendingFormat:@"%lu",(unsigned long)newNews.count] afterDelay:0.2];
                }
                
                if (isAfterSearch)
                {
                    isAfterSearch = NO;
                    [self performSelector:@selector(scrollTableToNewsRect) withObject:nil afterDelay:0.5];
                }
                
                [loader setAlpha:1.0];
                
                if([[tableView.indexPathsForVisibleRows lastObject] row] > dataSource.count-5)
                {
                    NSDictionary* params = @{@"lowerID":lowerCurrentID,@"sources":[sources componentsJoinedByString:@","]};
                    
                    [manager POST:@"http://almasdarapp.com/almasdar/getOlderNews.php" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                        [loader setAlpha:0.0];
                        [self removeActivityView];
                        [refreshControl endRefreshing];
                        
                        NSMutableArray* newNews = [[NSMutableArray alloc]initWithArray:[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil]];
                        
                        if([newNews count]>0)
                        {
                            lowerCurrentID = [[newNews lastObject] objectForKey:@"id"];
                            for(NSDictionary* dict in newNews)
                            {
                                [dataSource addObject:dict];
                                if ([self isBreakingNews:[dict objectForKey:@"body"]])
                                {
                                    [breakingArray addObject:@"1"];
                                }
                                else
                                {
                                    [breakingArray addObject:@"0"];
                                }
//                                [tableView beginUpdates];
//                                [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:(dataSource.count-1) inSection:0]]withRowAnimation:UITableViewRowAnimationRight];
//                                [tableView endUpdates];
                            }
                        }
                        
                        [tableView reloadData];
                        
                        if (isAfterSearch)
                        {
                            isAfterSearch = NO;
                            [self performSelector:@selector(scrollTableToNewsRect) withObject:nil afterDelay:0.5];
                        }
                        
                        loadingData = NO;
                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        [loader setAlpha:0.0];
                        [self removeActivityView];
                        [refreshControl endRefreshing];
                        loadingData = NO;
                        [SADAHMsg showMsgWithTitle:@"خطأ في الإتصال" andMsg:@"هناك خطأ في الإتصال بسيرفر التطبيق، برجاء حاول مجدداً بعد قليل وشكراً لك." inView:[self.navigationController view] withCase:2];
                        NSLog(@"Error: %@", error);}];
                }else
                {
                    loadingData = NO;
                    [loader setAlpha:0.0];
                    [self removeActivityView];
                    [refreshControl endRefreshing];
                }
                
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [loader setAlpha:0.0];
                [self removeActivityView];
                [refreshControl endRefreshing];
                loadingData = NO;
                [SADAHMsg showMsgWithTitle:@"خطأ في الإتصال" andMsg:@"هناك خطأ في الإتصال بسيرفر التطبيق، برجاء حاول مجدداً بعد قليل وشكراً لك." inView:[self.navigationController view] withCase:2];
                NSLog(@"Error: %@", error);}];

        }
    }
}

-(void)scrollTableToNewsRect
{
    [tableView scrollRectToVisible:newsRect animated:YES];
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
    if([searchTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length >= 3)
    {
        [self searchClicked:nil];
    }
}
- (IBAction)searchClicked:(id)sender {
    if(![self connected])
    {
        [self showStatusBarMsg:@"يجب أن تكون متصلاً بالإنترنت" isRed:YES];
        
    }else
    {
        if([searchTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length < 3)
        {
            isSearchMsg = YES;
            [self showStatusBarMsg:@"يجب إدخال كلمة واحدة من ٣ أحرف على الأقل" isRed:YES];
        }else
        {
            lowerCurrentID = @"-1";
            upperCurrentID = @"-1";
            
            isSearchYet = YES;
            dataSource = [[NSMutableArray alloc] init];
            [self addActivityView];
            [tableView setHidden:YES];
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

- (IBAction)addComma:(id)sender {
    [searchTextField setText:[searchTextField.text stringByAppendingString:@"، "]];
}

-(void)getSearchData
{
    [self hideNoResults];
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
    
    [manager POST:@"http://almasdarapp.com/almasdar/getSearchNews.php" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [tableView setAlpha:1.0];
        [loader setAlpha:0.0];
        [refreshControl endRefreshing];
        NSMutableArray* dataSourcee = [[NSMutableArray alloc]initWithArray:[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil]];
        
        [dataSource addObjectsFromArray:dataSourcee];
        
        NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:dataSource];
        dataSource = [[NSMutableArray alloc] initWithArray:[orderedSet array]];
        
        if(dataSourcee.count > 0)
        {
            searchLimit += dataSourcee.count;
            moreSearch = YES;
        }else
        {
            moreSearch = NO;
        }
        if (isFromRefresh)
        {
            isFromRefresh = NO;
            [tableView reloadData];
        }
        else
        {
            [tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationMiddle];
        }
        [tableView setNeedsDisplay];
        [tableView setHidden:NO];
        [self removeActivityView];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [tableView setAlpha:1.0];
        [loader setAlpha:0.0];
        [refreshControl endRefreshing];
        [self removeActivityView];
        [SADAHMsg showMsgWithTitle:@"خطأ في الإتصال" andMsg:@"هناك خطأ في الإتصال بسيرفر التطبيق، برجاء حاول مجدداً بعد قليل وشكراً لك." inView:[self.navigationController view] withCase:2];
        NSLog(@"Error: %@", error);}];
}

-(void)showNoResults
{
    if (!isSearching)return;
    
    [_noResultsImg setHidden:NO];
    [_noResultsLabel setHidden:NO];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isNightOn"])
    {
        [_noResultsImg setTintColor:[UIColor colorWithRed:70.0/255.0 green:70.0/255.0 blue:70.0/255.0 alpha:1.0]];
        [_noResultsLabel setTextColor:[UIColor colorWithRed:70.0/255.0 green:70.0/255.0 blue:70.0/255.0 alpha:1.0]];
    }
    else
    {
        [_noResultsImg setTintColor:[UIColor lightGrayColor]];
        [_noResultsLabel setTextColor:[UIColor lightGrayColor]];
    }
    
    _noResultsImg.image = [_noResultsImg.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

-(void)hideNoResults
{
    [_noResultsImg setHidden:YES];
    [_noResultsLabel setHidden:YES];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[self view]endEditing:YES];
    [searchTextField resignFirstResponder];
}

- (IBAction)cancelSearchClicked:(id)sender
{
    [self cancelSearching];
}

-(void)cancelSearching
{
    theSavedCount = 0;
    [self hideNoResults];
    isSearching = NO;
    [searchTextField resignFirstResponder];
    
    searchLimit = 0;
    moreSearch = YES;
    loadingData = NO;
    
    if (isSearchYet)
    {
        lowerCurrentID = @"-1";
        upperCurrentID = @"-1";
        isSearchYet = NO;
        dataSource = [[NSMutableArray alloc] init];
        [tableView reloadData];
        [tableView setNeedsDisplay];
        [tableView setHidden:YES];
        isAfterSearch = YES;
        [self addActivityView];
        [self getData];
    }
    
    CGRect frame = tableView.frame;
    frame.origin.y -= 85;
    frame.size.height += 85;
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^(void) {
                         [searchView setFrame:CGRectMake(0, 20, searchView.frame.size.width, 44)];
                         [tableView setFrame:frame];
                     }
                     completion:^(BOOL finished){
                         [searchView removeFromSuperview];
                     }
     ];
}

- (IBAction)sourceChooserClicked:(id)sender {
    [[self navigationController] popViewControllerAnimated:YES];
}

- (IBAction)openTimeline:(id)sender {
    if (!showingFav && !isOnBreakingNews)
    {
        [self hideOptionsTable];
        return;
    }
    
    [_topTitle setTitle:@"الأخبار"];
    
    if (isOnBreakingNews)
    {
        breakingRect = [tableView bounds];
    }
    else
    {
        favRect = [tableView bounds];
    }
    
    isOnBreakingNews = NO;
    showingFav = NO;
    self.navigationItem.rightBarButtonItems = nil;
    [self refreshNavigationItems];
    dataSource = [[NSMutableArray alloc]initWithArray:favTempStoring copyItems:YES];
    [self performSelector:@selector(reloadTheTable) withObject:nil afterDelay:0.3];
    
    [self hideOptionsTable];
}

- (IBAction)openFav:(id)sender {
    if (showingFav)
    {
        [self hideOptionsTable];
        return;
    }
    NSMutableArray* favs = [[NSMutableArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"favs"] copyItems:YES];
    NSArray *aSortedArray = [favs sortedArrayUsingComparator:^(NSDictionary *obj1,NSDictionary *obj2) {
        NSString *num1 =[obj1 objectForKey:@"createdAt"];
        NSString *num2 =[obj2 objectForKey:@"createdAt"];
        return (NSComparisonResult) [num2 compare:num1 options:(NSNumericSearch)];
    }];
    
    if(favs.count == 0)
    {
        [self showStatusBarMsg:@"لايوجد أخبار في المفضلة" isRed:YES];
        [SADAHMsg showMsgWithTitle:@"لايوجد أخبار في المفضلة" andMsg:@"للإضافة خبر للمفضلة قم بسحب الخبر لجهة اليمين وستتم إضافته مباشرة إلى المفضلة." inView:[self.navigationController view] withCase:2];
        
    }else
    {
        [_topTitle setTitle:@"المفضلة"];
        if (isOnBreakingNews)
        {
            isOnBreakingNews = NO;
            breakingRect = [tableView bounds];
        }
        else
        {
            newsRect = [tableView bounds];
            favTempStoring = [[NSMutableArray alloc]initWithArray:dataSource copyItems:YES];
        }
        
        showingFav = YES;
        self.navigationItem.rightBarButtonItems = nil;
        [self refreshNavigationItems];
        
        dataSource = [[NSMutableArray alloc]initWithArray:aSortedArray copyItems:YES];
        [self performSelector:@selector(reloadTheTable) withObject:nil afterDelay:0.3];
        
        [self hideOptionsTable];
    }
}

- (IBAction)openBreakingNews:(id)sender {
    if (isOnBreakingNews)
    {
        [self hideOptionsTable];
        return;
    }
    if (!showingFav)
    {
        favTempStoring = [[NSMutableArray alloc]initWithArray:dataSource copyItems:YES];
    }
    
    [_topTitle setTitle:@"الأخبار العاجلة"];
    isOnBreakingNews = YES;
    self.navigationItem.rightBarButtonItems = nil;
    [self refreshNavigationItems];
    showingFav = NO;
    createdAt = @"-1";
    [self getDataForBreakingNews:0];
    
    [self hideOptionsTable];
}

-(void)getDataForBreakingNews:(NSInteger)theCase
{
    if (theCase == 1)
    {
        createdAt = [[dataSource firstObject] objectForKey:@"id"];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        NSDictionary* params = @{@"createdAt":createdAt,@"sources":[sources componentsJoinedByString:@","]};
        
        [manager POST:@"http://almasdarapp.com/almasdar/getBreakingNewsNewer.php" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSMutableArray* newNews = [[NSMutableArray alloc]initWithArray:[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil]];
            
            if([newNews count]>0)
            {
                //[newNews addObjectsFromArray:dataSource];
                //dataSource = [[NSMutableArray alloc]initWithArray:newNews copyItems:YES];
                createdAt = [[newNews objectAtIndex:0] objectForKey:@"id"];
                CGPoint offset = tableView.contentOffset;
                for(int i = (int)newNews.count-1 ; i >= 0 ; i--)
                {
                    
                    
                    [dataSource insertObject:[newNews objectAtIndex:i] atIndex:0];
                    //                        [tableView beginUpdates];
                    //                        [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                    if([[[newNews objectAtIndex:i] objectForKey:@"mediaURL"] isEqualToString:@""])
                    {
                        offset.y += 150.0;
                    }else
                    {
                        offset.y += 358.0;
                    }
                    //                        [tableView endUpdates];
                }
                
                NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:dataSource];
                dataSource = [[NSMutableArray alloc] initWithArray:[orderedSet array]];
                
                [tableView reloadData];
                
                [(UILabel*)[tableView viewWithTag:837] setText:[@"عدد الأخبار المتبقية " stringByAppendingFormat:@"(%ld)",(long)[self getTheCount]]];
                [tableView setContentOffset:offset animated:NO];
                if (!isSearching)[self performSelector:@selector(addScrollTopButton:) withObject:[@"" stringByAppendingFormat:@"%lu",(unsigned long)newNews.count] afterDelay:0.2];
            }
            [refreshControl endRefreshing];
            
        }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
            [refreshControl endRefreshing];
            [SADAHMsg showMsgWithTitle:@"خطأ في الإتصال" andMsg:@"هناك خطأ في الإتصال بسيرفر التطبيق، برجاء حاول مجدداً بعد قليل وشكراً لك." inView:[self.navigationController view] withCase:2];
        }];
        
    }
    else if (theCase == 2)
    {
        createdAt = [[dataSource lastObject] objectForKey:@"id"];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        NSDictionary* params = @{@"createdAt":createdAt,@"sources":[sources componentsJoinedByString:@","]};
        
        [manager POST:@"http://almasdarapp.com/almasdar/getBreakingNews.php" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSMutableArray* newNews = [[NSMutableArray alloc]initWithArray:[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil]];
            
            if([newNews count]>0)
            {
                createdAt = [[newNews lastObject] objectForKey:@"id"];
                for(NSDictionary* dict in newNews)
                {
                    [dataSource addObject:dict];
                }
            }
            
            NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:dataSource];
            dataSource = [[NSMutableArray alloc] initWithArray:[orderedSet array]];
            
            [tableView reloadData];
            
        }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
            [refreshControl endRefreshing];
            [SADAHMsg showMsgWithTitle:@"خطأ في الإتصال" andMsg:@"هناك خطأ في الإتصال بسيرفر التطبيق، برجاء حاول مجدداً بعد قليل وشكراً لك." inView:[self.navigationController view] withCase:2];
        }];
    }
    else
    {
        [tableView setHidden:YES];
        [self addActivityView];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        NSDictionary* params = @{@"createdAt":createdAt,@"sources":[sources componentsJoinedByString:@","]};
        
        [manager POST:@"http://almasdarapp.com/almasdar/getBreakingNews.php" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            //dataSource = [[NSMutableArray alloc] init];
            //dataSource = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
            dataSource = [[NSMutableArray alloc]initWithArray:[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil]];
            NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:dataSource];
            dataSource = [[NSMutableArray alloc] initWithArray:[orderedSet array]];
            createdAt = [[dataSource lastObject] objectForKey:@"id"];
            
            [self performSelector:@selector(reloadTheTable) withObject:nil afterDelay:0.2];
            [self removeActivityView];
            
        }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
            [self removeActivityView];
            [SADAHMsg showMsgWithTitle:@"خطأ في الإتصال" andMsg:@"هناك خطأ في الإتصال بسيرفر التطبيق، برجاء حاول مجدداً بعد قليل وشكراً لك." inView:[self.navigationController view] withCase:2 withBlock:^(BOOL finished) {
                if(finished){
                    if (isOnBreakingNews)
                    {
                        [_topTitle setTitle:@"الأخبار"];
                        
                        if (isOnBreakingNews)
                        {
                            breakingRect = [tableView bounds];
                        }
                        else
                        {
                            favRect = [tableView bounds];
                        }
                        
                        isOnBreakingNews = NO;
                        showingFav = NO;
                        self.navigationItem.rightBarButtonItems = nil;
                        [self refreshNavigationItems];
                        dataSource = [[NSMutableArray alloc]initWithArray:favTempStoring copyItems:YES];
                        [self performSelector:@selector(reloadTheTable) withObject:nil afterDelay:0.3];
                    }
                }
            }];
        }];
    }
}

-(void)reloadTheTable
{
    [tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationMiddle];
    [tableView setNeedsDisplay];
    [self performSelector:@selector(reloadNow) withObject:nil afterDelay:1.0];
}

-(void)reloadNow
{
    [tableView reloadData];
    if (showingFav)
    {
        if (favRect.origin.y != 0)
        {
            [tableView scrollRectToVisible:favRect animated:YES];
        }
        else
        {
            [tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
        }
    }
    else if (isOnBreakingNews)
    {
        if (breakingRect.origin.y != 0)
        {
            [tableView scrollRectToVisible:breakingRect animated:YES];
        }
        else
        {
            [tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
        }
    }
    else
    {
        if (newsRect.origin.y != 0)
        {
            [tableView scrollRectToVisible:newsRect animated:YES];
        }
        else
        {
            [tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
        }
    }
}

- (IBAction)openNotifications:(id)sender {
    [_optionsNavBar removeFromSuperview];
    [[_optionsNavBar viewWithTag:3338] removeFromSuperview];
    [[_optionsNavBar viewWithTag:3339] removeFromSuperview];
    [self hideOptionsTable];
    [self performSelector:@selector(openNotificationsView) withObject:nil afterDelay:0.3];
}

- (IBAction)nightMood:(id)sender {
    [self hideOptionsTable];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isNightOn"])
    {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isNightOn"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self performSelector:@selector(disableNightMode) withObject:nil afterDelay:0.3];
    }
    else
    {
        [self performSelector:@selector(enableNightMode) withObject:nil afterDelay:0.3];
    }
}

- (IBAction)openSettings:(id)sender {
    [self hideOptionsTable];
    [self performSelector:@selector(openSettingsView) withObject:nil afterDelay:0.3];
    isSettingsBack = YES;
}

-(void)enableNightMode
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isNightOn"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    refreshControl.tintColor = [UIColor lightGrayColor];
    
    isFromNight = YES;
    self.navigationItem.rightBarButtonItems = nil;
    [UIView animateWithDuration:0.2 delay:0.0 options:0
                     animations:^{
                         [self setTheColor];
                         [tableView reloadData];
                     }
                     completion:^(BOOL finished) {
                         [self refreshNavigationItems];
                     }];
    [UIView commitAnimations];
}

-(void)disableNightMode
{
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isNightOn"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    refreshControl.tintColor = [UIColor colorWithRed:85.0/255.0 green:85.0/255.0 blue:85.0/255.0 alpha:1.0];
    
    isFromNight = YES;
    self.navigationItem.rightBarButtonItems = nil;
    [UIView animateWithDuration:0.2 delay:0.0 options:0
                     animations:^{
                         [self setTheColor];
                         [tableView reloadData];
                     }
                     completion:^(BOOL finished) {
                         [self refreshNavigationItems];
                     }];
    [UIView commitAnimations];
}

-(void)openSettingsView
{
    [self performSegueWithIdentifier:@"settingsSeg" sender:self];
}

-(void)openNotificationsView
{
    [self performSegueWithIdentifier:@"notifSeg" sender:self];
}

- (IBAction)closeOptionsView:(id)sender {
    [self hideOptionsTable];
}

- (IBAction)optionsClicked:(id)sender {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isNightOn"])
    {
        [_nightButton setTitle:@"         وضع القراءة العادي" forState:UIControlStateNormal];
        [_nightImg setImage:[UIImage imageNamed:@"sun-icon.png"]];
    }
    else
    {
        [_nightButton setTitle:@"         وضع القراءة الليلي" forState:UIControlStateNormal];
        [_nightImg setImage:[UIImage imageNamed:@"moon-icon.png"]];
    }
    if (isOptions)
    {
        [self hideOptionsTable];
    }
    else
    {
        [self showOptionsTable];
    }
}

-(void)setCurrentBackColor
{
    if (showingFav)
    {
        [_favButton setBackgroundColor:[UIColor colorWithRed:231.0/255.0 green:222.0/255.0 blue:199.0/255.0 alpha:1.0]];
        [_timeLineButton setBackgroundColor:[UIColor clearColor]];
        [_breakingButton setBackgroundColor:[UIColor clearColor]];
    }
    else if (isOnBreakingNews)
    {
        [_breakingButton setBackgroundColor:[UIColor colorWithRed:231.0/255.0 green:222.0/255.0 blue:199.0/255.0 alpha:1.0]];
        [_timeLineButton setBackgroundColor:[UIColor clearColor]];
        [_favButton setBackgroundColor:[UIColor clearColor]];
    }
    else
    {
        [_timeLineButton setBackgroundColor:[UIColor colorWithRed:231.0/255.0 green:222.0/255.0 blue:199.0/255.0 alpha:1.0]];
        [_favButton setBackgroundColor:[UIColor clearColor]];
        [_breakingButton setBackgroundColor:[UIColor clearColor]];
    }
}

-(void)showOptionsTable
{
    isOptions = YES;
    [self setCurrentBackColor];
    [[self.navigationController view] addSubview:_optionsNavBar];
    UIImageView *firstImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 5)];
    UIImageView *secImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 5)];
    
    [firstImg setTag:3338];
    [secImg setTag:3339];
    
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"currentColor"] == 2 && ![[NSUserDefaults standardUserDefaults] boolForKey:@"isNightOn"])
    {
        [firstImg setTintColor:[UIColor colorWithRed:37.0/255.0 green:37.0/255.0 blue:37.0/255.0 alpha:1.0]];
        [secImg setTintColor:[UIColor colorWithRed:37.0/255.0 green:37.0/255.0 blue:37.0/255.0 alpha:1.0]];
        
        firstImg.image = [[UIImage imageNamed:@"more-line.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        secImg.image = [[UIImage imageNamed:@"more-line.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    else
    {
        [firstImg setTintColor:[UIColor whiteColor]];
        [secImg setTintColor:[UIColor whiteColor]];
        
        [firstImg setImage:[UIImage imageNamed:@"more-line.png"]];
        [secImg setImage:[UIImage imageNamed:@"more-line.png"]];
    }
    
    [_optionsNavBar addSubview:firstImg];
    [_optionsNavBar addSubview:secImg];
    
    firstImg.center = _firstMoreImg.center;
    secImg.center = _secMoreImg.center;
    
    [firstImg setFrame:CGRectMake(firstImg.frame.origin.x, firstImg.frame.origin.y+40, 30, 5)];
    [secImg setFrame:CGRectMake(secImg.frame.origin.x, secImg.frame.origin.y+40, 30, 5)];
    
    [self rotateImg:firstImg isLeft:NO];
    [self rotateImg:secImg isLeft:YES];
    
    [_optionsNavBar setFrame:CGRectMake(0, 20, [self.navigationController view].frame.size.width, _optionsNavBar.frame.size.height)];
    [_optionsView setHidden:NO];
    [_darkBackButton setHidden:NO];
    [tableView setAlpha:1.0];
    [_darkBackButton setAlpha:0.0];
    [_optionsView setFrame:CGRectMake(_optionsView.frame.origin.x, -325, _optionsView.frame.size.width, 325)];
    [UIView animateWithDuration:0.2 delay:0.0 options:0
                     animations:^{
                         [tableView setAlpha:0.4];
                         [_darkBackButton setAlpha:0.8];
                         [_optionsView setFrame:CGRectMake(0, 0, _optionsView.frame.size.width, _optionsView.frame.size.height)];
                     }
                     completion:^(BOOL finished) {
                     }];
    [UIView commitAnimations];
}

-(void)hideOptionsTable
{
    isOptions = NO;
    [self rotateImgBack:(UIImageView*)[_optionsNavBar viewWithTag:3338] isLeft:NO];
    [self rotateImgBack:(UIImageView*)[_optionsNavBar viewWithTag:3339] isLeft:YES];
    [tableView setAlpha:1.0];
    [_darkBackButton setAlpha:0.0];
    [UIView animateWithDuration:0.2 delay:0.0 options:0
                     animations:^{
                         [_optionsView setFrame:CGRectMake(_optionsView.frame.origin.x, -_optionsView.frame.size.height, _optionsView.frame.size.width, _optionsView.frame.size.height)];
                     }
                     completion:^(BOOL finished) {
                         [_optionsView setHidden:YES];
                         [_darkBackButton setHidden:YES];
                         [_optionsNavBar removeFromSuperview];
                         [[_optionsNavBar viewWithTag:3338] removeFromSuperview];
                         [[_optionsNavBar viewWithTag:3339] removeFromSuperview];
                     }];
    [UIView commitAnimations];
}

-(void)rotateImg:(UIImageView*)theImgView isLeft:(BOOL)leftRotate
{
    [UIImageView beginAnimations:nil context:NULL];
    if (leftRotate)
    {
        [theImgView setFrame:CGRectMake(theImgView.frame.origin.x, theImgView.frame.origin.y-4, 30, 5)];
        theImgView.transform=CGAffineTransformMakeRotation(M_PI / -4);
    }
    else
    {
        [theImgView setFrame:CGRectMake(theImgView.frame.origin.x, theImgView.frame.origin.y+4, 30, 5)];
        theImgView.transform=CGAffineTransformMakeRotation(M_PI / 4);
    }
    [UIImageView setAnimationDelay:0.5];
    [UIImageView commitAnimations];
}

-(void)rotateImgBack:(UIImageView*)theImgView isLeft:(BOOL)leftRotate
{
    [UIImageView beginAnimations:nil context:NULL];
    if (leftRotate)
    {
        theImgView.transform=CGAffineTransformMakeRotation(0);
        [theImgView setFrame:CGRectMake(theImgView.frame.origin.x, theImgView.frame.origin.y+4, 30, 5)];
    }
    else
    {
        theImgView.transform=CGAffineTransformMakeRotation(0);
        [theImgView setFrame:CGRectMake(theImgView.frame.origin.x, theImgView.frame.origin.y-4, 30, 5)];
    }
    [UIImageView setAnimationDelay:0.5];
    [UIImageView commitAnimations];
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

-(void)addScrollTopButton:(NSString*)newsCountStr
{
    if (isSearching)return;
    NSInteger newsCount = [newsCountStr integerValue];
    indVal = newsCount-1;
    
    countToEnd = newsCount;
    
    isNoResume = NO;
    
    isScrollButton = YES;
    
    resumeRect = [tableView bounds];
    
    UIView *headerView = [tableView viewWithTag:884];
    
    UIButton *scrollButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [scrollButton setBackgroundColor:[UIColor clearColor]];
    [scrollButton addTarget:self action:@selector(scrollToTopNow) forControlEvents:UIControlEventTouchUpInside];
    [scrollButton setTag:885];
    [scrollButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [scrollButton setTitleColor:[UIColor colorWithRed:71.0/255.0 green:69.0/255.0 blue:9.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    
    if (newsCount == 1)
    {
        [scrollButton setTitle:@"يوجد خبر جديد" forState:UIControlStateNormal];
    }
    else if (newsCount == 2)
    {
        [scrollButton setTitle:@"يوجد خبرين جديدين" forState:UIControlStateNormal];
    }
    else if (newsCount <= 10)
    {
        [scrollButton setTitle:[@"" stringByAppendingFormat:@"يوجد %ld أخبار جديدة",(long)newsCount] forState:UIControlStateNormal];
    }
    else
    {
        [scrollButton setTitle:[@"" stringByAppendingFormat:@"يوجد %ld خبر جديد",(long)newsCount] forState:UIControlStateNormal];
    }
    
    [scrollButton setImage:[UIImage imageNamed:@"top-arrow.png"] forState:UIControlStateNormal];
    scrollButton.frame = CGRectMake(0, 0, headerView.frame.size.width, headerView.frame.size.height);
    [headerView addSubview:scrollButton];
    
    [scrollButton setAlpha:0.0];
    
    [UIView animateWithDuration:0.3 delay:0.0 options:0
                     animations:^{
                         [headerView setBackgroundColor:[UIColor colorWithRed:230.0/255.0 green:223.0/255.0 blue:37.0/255.0 alpha:1.0]];
                         [[tableView viewWithTag:838] setAlpha:0.0];
                         [[tableView viewWithTag:839] setAlpha:0.0];
                         [[tableView viewWithTag:840] setAlpha:0.0];
                         [scrollButton setAlpha:1.0];
                     }
                     completion:^(BOOL finished) {
                         NSIndexPath *checkPath;
                         BOOL isFound = NO;
                         for (int i = 0; i < [[tableView indexPathsForVisibleRows] count]; i++)
                         {
                             checkPath = [[tableView indexPathsForVisibleRows] objectAtIndex:i];
                             if (checkPath.row == indVal-1)
                             {
                                 isFound = YES;
                                 break;
                             }
                         }
                         
                         if (isFound)
                         {
                             isRectResume = NO;
                             isNoResume = YES;
                             [self performSelector:@selector(setHeaderBack) withObject:nil afterDelay:3.0];
                         }
                         else
                         {
                             [self performSelector:@selector(setHeaderBack) withObject:nil afterDelay:10.0];
                         }
                     }];
    [UIView commitAnimations];
}

-(void)addBackToRect
{
    if (isNoResume)
    {
        isNoResume = NO;
        return;
    }
    
    if (isSearching)return;
    
    UIView *headerView = [tableView viewWithTag:884];
    
    UIButton *scrollButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [scrollButton setBackgroundColor:[UIColor clearColor]];
    [scrollButton addTarget:self action:@selector(scrollBack) forControlEvents:UIControlEventTouchUpInside];
    [scrollButton setTag:885];
    [scrollButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [scrollButton setTitleColor:[UIColor colorWithRed:241.0/255.0 green:241.0/255.0 blue:241.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    
    [scrollButton setTitle:@"الرجوع للخبر الذي وصلت إليه بالقراءة" forState:UIControlStateNormal];
    
    [scrollButton setImage:[UIImage imageNamed:@"bottom-arrow.png"] forState:UIControlStateNormal];
    scrollButton.frame = CGRectMake(0, 0, headerView.frame.size.width, headerView.frame.size.height);
    [headerView addSubview:scrollButton];
    
    [scrollButton setAlpha:0.0];
    
    [UIView animateWithDuration:0.3 delay:0.0 options:0
                     animations:^{
                         [headerView setBackgroundColor:[UIColor colorWithRed:26.0/255.0 green:160.0/255.0 blue:204.0/255.0 alpha:1.0]];
                         [[tableView viewWithTag:838] setAlpha:0.0];
                         [[tableView viewWithTag:839] setAlpha:0.0];
                         [[tableView viewWithTag:840] setAlpha:0.0];
                         [scrollButton setAlpha:1.0];
                     }
                     completion:^(BOOL finished) {
                         [self performSelector:@selector(setRectBack) withObject:nil afterDelay:10.0];
                     }];
    [UIView commitAnimations];
}

-(void)scrollToTopNow
{
    isRectResume = YES;
    [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:indVal inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    [self setHeaderBack];
}

-(void)scrollBack
{
    [tableView scrollRectToVisible:resumeRect animated:YES];
    [self setRectBack];
}

-(void)setRectBack
{
    [UIView animateWithDuration:0.3 delay:0.0 options:0
                     animations:^{
                         if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isNightOn"])
                         {
                             [[tableView viewWithTag:884] setBackgroundColor:[UIColor colorWithRed:85.0/255.0 green:85.0/255.0 blue:85.0/255.0 alpha:0.9]];
                         }
                         else
                         {
                             [[tableView viewWithTag:884] setBackgroundColor:[UIColor colorWithRed:235.0/255.0 green:235.0/255.0 blue:235.0/255.0 alpha:0.9]];
                         }
                         [[tableView viewWithTag:838] setAlpha:1.0];
                         [[tableView viewWithTag:885] setAlpha:0.0];
                         
                         if (countToEnd < 1)
                         {
                             [[tableView viewWithTag:839] setAlpha:0.0];
                             [[tableView viewWithTag:840] setAlpha:0.0];
                         }
                         else
                         {
                             [[tableView viewWithTag:839] setAlpha:1.0];
                             [[tableView viewWithTag:840] setAlpha:1.0];
                             [(UILabel*)[tableView viewWithTag:839] setText:[@"       " stringByAppendingFormat:@"%ld",(long)countToEnd]];
                         }
                     }
                     completion:^(BOOL finished) {
                         [[tableView viewWithTag:885] removeFromSuperview];
                     }];
    [UIView commitAnimations];
}

-(void)setHeaderBack
{
    if (!isScrollButton)return;
    
    isScrollButton = NO;
    [UIView animateWithDuration:0.3 delay:0.0 options:0
                     animations:^{
                         if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isNightOn"])
                         {
                             [[tableView viewWithTag:884] setBackgroundColor:[UIColor colorWithRed:85.0/255.0 green:85.0/255.0 blue:85.0/255.0 alpha:0.9]];
                         }
                         else
                         {
                             [[tableView viewWithTag:884] setBackgroundColor:[UIColor colorWithRed:235.0/255.0 green:235.0/255.0 blue:235.0/255.0 alpha:0.9]];
                         }
                         [[tableView viewWithTag:838] setAlpha:1.0];
                         if (countToEnd < 1)
                         {
                             [[tableView viewWithTag:839] setAlpha:0.0];
                             [[tableView viewWithTag:840] setAlpha:0.0];
                         }
                         else
                         {
                             [[tableView viewWithTag:839] setAlpha:1.0];
                             [[tableView viewWithTag:840] setAlpha:1.0];
                             [(UILabel*)[tableView viewWithTag:839] setText:[@"       " stringByAppendingFormat:@"%ld",(long)countToEnd]];
                         }
                         [[tableView viewWithTag:885] setAlpha:0.0];
                     }
                     completion:^(BOOL finished) {
                         [[tableView viewWithTag:885] removeFromSuperview];
                     }];
    [UIView commitAnimations];
}

-(void)scrollToNews
{
    if (countToEnd > 0)
    {
        [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:countToEnd-1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

-(UIView *)tableView:(UITableView *)tableView2 viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView2.frame.size.width, 30)];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView2.frame.size.width, 30)];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [label setTag:838];
    [label setFont:[UIFont systemFontOfSize:16]];
    [label setTextAlignment:NSTextAlignmentCenter];
    
    UILabel *countLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView2.frame.size.width, 30)];
    [countLabel setTag:839];
    [countLabel setFont:[UIFont systemFontOfSize:16]];
    [countLabel setTextAlignment:NSTextAlignmentLeft];
    
    [countLabel setText:[@"       " stringByAppendingFormat:@"%ld",(long)countToEnd]];
    
    UIImageView *topLeftImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"top-left-arrow.png"]];
    [topLeftImg setFrame:CGRectMake(0, 0, 15, 16)];
    [topLeftImg setCenter:view.center];
    [topLeftImg setFrame:CGRectMake(10, topLeftImg.frame.origin.y, 15, 16)];
    [topLeftImg setTag:840];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [button addTarget:self
               action:@selector(scrollToNews)
     forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"" forState:UIControlStateNormal];
    button.frame = view.frame;
    [view addSubview:button];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isNightOn"])
    {
        [label setTextColor:[UIColor lightGrayColor]];
        [countLabel setTextColor:[UIColor lightGrayColor]];
    }
    else
    {
        [label setTextColor:[UIColor colorWithRed:85.0/255.0 green:85.0/255.0 blue:85.0/255.0 alpha:0.9]];
        [countLabel setTextColor:[UIColor colorWithRed:100.0/255.0 green:100.0/255.0 blue:100.0/255.0 alpha:0.9]];
    }
    
    if (showingFav)
    {
        [label setText:@"الأخبار المفضلة"];
    }
    else
    {
        [label setText:@"أخبار اليوم"];
    }
    
    [view addSubview:label];
    [view addSubview:countLabel];
    [view addSubview:topLeftImg];
    
    if (countToEnd < 1)
    {
        [countLabel setAlpha:0.0];
        [topLeftImg setAlpha:0.0];
        NSLog(@"countToEnd hidden in header");
    }
    else
    {
        [countLabel setAlpha:1.0];
        [topLeftImg setAlpha:1.0];
        [countLabel setHidden:NO];
        [topLeftImg setHidden:NO];
    }
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isNightOn"])
    {
        [view setBackgroundColor:[UIColor colorWithRed:85.0/255.0 green:85.0/255.0 blue:85.0/255.0 alpha:0.9]];
    }
    else
    {
        [view setBackgroundColor:[UIColor colorWithRed:235.0/255.0 green:235.0/255.0 blue:235.0/255.0 alpha:0.9]];
    }
    [view setTag:884];
    
    if (dataSource.count == 0)
    {
        [view setHidden:YES];
    }
    
    return view;
}

-(UIView*)tableView:(UITableView *)tableView2 viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView2.frame.size.width, 30)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView2.frame.size.width, 30)];
    [label setTag:837];
    [label setFont:[UIFont systemFontOfSize:16]];
    [label setTextAlignment:NSTextAlignmentCenter];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isNightOn"])
     {
         [label setTextColor:[UIColor lightGrayColor]];
     }
     else
     {
         [label setTextColor:[UIColor colorWithRed:85.0/255.0 green:85.0/255.0 blue:85.0/255.0 alpha:0.9]];
     }
    
    [label setText:[@"عدد الأخبار المتبقية " stringByAppendingFormat:@"(%ld)",(long)[self getTheCount]]];
    
    [view addSubview:label];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isNightOn"])
    {
        [view setBackgroundColor:[UIColor colorWithRed:85.0/255.0 green:85.0/255.0 blue:85.0/255.0 alpha:0.9]];
    }
    else
    {
        [view setBackgroundColor:[UIColor colorWithRed:235.0/255.0 green:235.0/255.0 blue:235.0/255.0 alpha:0.9]];
    }
    
    if (dataSource.count == 0)
    {
        [view setHidden:YES];
    }
    
    return view;
}

-(NSInteger)getTheCount
{
    NSInteger biggestInt = 0;
    NSIndexPath *biggestRow;
    
    for (int i = 0; i < [tableView indexPathsForVisibleRows].count; i++)
    {
        biggestRow = [[tableView indexPathsForVisibleRows] objectAtIndex:i];
        if (biggestInt < biggestRow.row) biggestInt = biggestRow.row;
    }
    
    return dataSource.count - biggestRow.row;
}

-(NSString*)getDayStr:(long)createdAtVal andCompare:(long)compareVal andToday:(NSDate*)todayDate
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:( NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit ) fromDate:todayDate];
    
    [components setHour:-[components hour]];
    [components setMinute:-[components minute]];
    [components setSecond:-[components second]];
    
    [components setHour:-24];
    [components setMinute:0];
    [components setSecond:0];
    
    NSDate *yesterday = [cal dateByAddingComponents:components toDate: todayDate options:0];
    
    long previousTimeInterval = [yesterday timeIntervalSince1970];
    
    if((createdAtVal - previousTimeInterval) < compareVal)
    {
        return @"أخبار أمس";
    }
    else
    {
        return @"أخبار اليوم";
    }
}

- (void)tableView:(UITableView *)tableView2 willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (showingFav)
    {
        [[cell viewWithTag:9] setHidden:YES];
        [[cell viewWithTag:10] setHidden:YES];
    }
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isNightOn"])
    {
        [cell viewWithTag:8].layer.borderColor = [UIColor colorWithRed:70.0/255.0 green:70.0/255.0 blue:70.0/255.0 alpha:1.0].CGColor;
    }
    else
    {
        [cell viewWithTag:8].layer.borderColor = [UIColor colorWithRed:85.0/255.0 green:85.0/255.0 blue:85.0/255.0 alpha:0.4].CGColor;
    }
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isNightOn"])
    {
        if (!showingFav)
        {
            NSMutableArray* favs = [[NSMutableArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"favs"] copyItems:YES];
            
            if ([favs containsObject:[dataSource objectAtIndex:indexPath.row]])
            {
                [cell viewWithTag:8].layer.borderColor = [UIColor colorWithRed:91.0/255.0 green:81.0/255.0 blue:47.0/255.0 alpha:0.4].CGColor;
                [[cell viewWithTag:8] setBackgroundColor:[UIColor colorWithRed:81.0/255.0 green:72.0/255.0 blue:43.0/255.0 alpha:0.5]];
                
                [[cell viewWithTag:9] setHidden:NO];
                [[cell viewWithTag:10] setHidden:NO];
                
                [[cell viewWithTag:9] setAlpha:1.0];
                [[cell viewWithTag:10] setAlpha:1.0];
                
                if (isFromSwipe)
                {
                    isFromSwipe = NO;
                    BOOL isOnBreak = NO;
                    CGRect oldBreakRect;
                    NSDictionary* news = [dataSource objectAtIndex:indexPath.row];
                    if (!isOnBreakingNews && !isSearching)
                    {
                        if (showingFav)
                        {
                            if ([self isBreakingNews:[news objectForKey:@"body"]])
                            {
                                isOnBreak = YES;
                                if([[news objectForKey:@"mediaType"]isEqualToString:@""] && [[self imageUrlForRow:indexPath.row] length] == 0)
                                {
                                    oldBreakRect = [cell viewWithTag:12].frame;
                                    [[cell viewWithTag:12] setHidden:NO];
                                    [[cell viewWithTag:11] setHidden:YES];
                                }
                                else
                                {
                                    oldBreakRect = [cell viewWithTag:11].frame;
                                    [[cell viewWithTag:12] setHidden:YES];
                                    [[cell viewWithTag:11] setHidden:NO];
                                }
                            }
                        }
                        else
                        {
                            if ([[breakingArray objectAtIndex:indexPath.row] integerValue] == 1)
                            {
                                isOnBreak = YES;
                                if([[news objectForKey:@"mediaType"]isEqualToString:@""] && [[self imageUrlForRow:indexPath.row] length] == 0)
                                {
                                    oldBreakRect = [cell viewWithTag:12].frame;
                                    [[cell viewWithTag:12] setHidden:NO];
                                    [[cell viewWithTag:11] setHidden:YES];
                                }
                                else
                                {
                                    oldBreakRect = [cell viewWithTag:11].frame;
                                    [[cell viewWithTag:12] setHidden:YES];
                                    [[cell viewWithTag:11] setHidden:NO];
                                }
                            }
                        }
                    }
                    
                    [cell viewWithTag:9].transform=CGAffineTransformMakeRotation(M_PI / -4);
                    [UIView animateWithDuration:0.5 delay:0.0 options:0
                                     animations:^{
                                         [cell viewWithTag:9].transform=CGAffineTransformMakeRotation(M_PI / 2);
                                         if (isOnBreak)
                                         {
                                             if([[news objectForKey:@"mediaType"]isEqualToString:@""] && [[self imageUrlForRow:indexPath.row] length] == 0)
                                             {
                                                 [[cell viewWithTag:12] setFrame:CGRectMake([cell viewWithTag:12].frame.origin.x+100, [cell viewWithTag:12].frame.origin.y, [cell viewWithTag:12].frame.size.width, [cell viewWithTag:12].frame.size.height)];
                                             }
                                             else
                                             {
                                                 [[cell viewWithTag:11] setFrame:CGRectMake([cell viewWithTag:11].frame.origin.x+100, [cell viewWithTag:11].frame.origin.y, [cell viewWithTag:11].frame.size.width, [cell viewWithTag:11].frame.size.height)];
                                             }
                                         }
                                     }
                                     completion:^(BOOL finished) {
                                         [UIView animateWithDuration:0.5 delay:0.0 options:0
                                                          animations:^{
                                                              [cell viewWithTag:9].transform=CGAffineTransformMakeRotation(0);
                                                          }
                                                          completion:^(BOOL finished) {
                                                              [[cell viewWithTag:11] setHidden:YES];
                                                              [[cell viewWithTag:12] setHidden:YES];
                                                              if (isOnBreak)
                                                              {
                                                                  if([[news objectForKey:@"mediaType"]isEqualToString:@""] && [[self imageUrlForRow:indexPath.row] length] == 0)
                                                                  {
                                                                      [[cell viewWithTag:12] setFrame:oldBreakRect];
                                                                  }
                                                                  else
                                                                  {
                                                                      [[cell viewWithTag:11] setFrame:oldBreakRect];
                                                                  }
                                                              }
                                                          }];
                                         [UIView commitAnimations];
                                     }];
                    [UIView commitAnimations];
                }
            }
            else
            {
                NSDictionary* news = [dataSource objectAtIndex:indexPath.row];
                if (!isOnBreakingNews && !isSearching)
                {
                    if (showingFav)
                    {
                        if ([self isBreakingNews:[news objectForKey:@"body"]])
                        {
                            if([[news objectForKey:@"mediaType"]isEqualToString:@""] && [[self imageUrlForRow:indexPath.row] length] == 0)
                            {
                                [[cell viewWithTag:12] setHidden:NO];
                                [[cell viewWithTag:11] setHidden:YES];
                            }
                            else
                            {
                                [[cell viewWithTag:12] setHidden:YES];
                                [[cell viewWithTag:11] setHidden:NO];
                            }
                            [[cell viewWithTag:8] setBackgroundColor:[UIColor colorWithRed:81.0/255.0 green:43.0/255.0 blue:43.0/255.0 alpha:1.0]];
                            [cell viewWithTag:8].layer.borderColor = [UIColor colorWithRed:48.0/255.0 green:26.0/255.0 blue:26.0/255.0 alpha:1.0].CGColor;
                        }
                        else
                        {
                            [[cell viewWithTag:11] setHidden:YES];
                            [[cell viewWithTag:12] setHidden:YES];
                            [[cell viewWithTag:8] setBackgroundColor:[UIColor colorWithRed:50.0/255.0 green:50.0/255.0 blue:50.0/255.0 alpha:1.0]];
                        }
                    }
                    else
                    {
                        if ([[breakingArray objectAtIndex:indexPath.row] integerValue] == 1)
                        {
                            if([[news objectForKey:@"mediaType"]isEqualToString:@""] && [[self imageUrlForRow:indexPath.row] length] == 0)
                            {
                                [[cell viewWithTag:12] setHidden:NO];
                                [[cell viewWithTag:11] setHidden:YES];
                            }
                            else
                            {
                                [[cell viewWithTag:12] setHidden:YES];
                                [[cell viewWithTag:11] setHidden:NO];
                            }
                            [[cell viewWithTag:8] setBackgroundColor:[UIColor colorWithRed:81.0/255.0 green:43.0/255.0 blue:43.0/255.0 alpha:1.0]];
                            [cell viewWithTag:8].layer.borderColor = [UIColor colorWithRed:48.0/255.0 green:26.0/255.0 blue:26.0/255.0 alpha:1.0].CGColor;
                        }
                        else
                        {
                            [[cell viewWithTag:11] setHidden:YES];
                            [[cell viewWithTag:12] setHidden:YES];
                            [[cell viewWithTag:8] setBackgroundColor:[UIColor colorWithRed:50.0/255.0 green:50.0/255.0 blue:50.0/255.0 alpha:1.0]];
                        }
                    }
                    
                }
                else
                {
                    [[cell viewWithTag:11] setHidden:YES];
                    [[cell viewWithTag:12] setHidden:YES];
                    [[cell viewWithTag:8] setBackgroundColor:[UIColor colorWithRed:50.0/255.0 green:50.0/255.0 blue:50.0/255.0 alpha:1.0]];
                }
                
                
                if (isFromSwipe)
                {
                    isFromSwipe = NO;
                    [[cell viewWithTag:9] setHidden:NO];
                    [[cell viewWithTag:10] setHidden:NO];
                    [[cell viewWithTag:9] setAlpha:1.0];
                    [[cell viewWithTag:10] setAlpha:1.0];
                    
                    if (!isOnBreakingNews && !isSearching)
                    {
                        if([[news objectForKey:@"mediaType"]isEqualToString:@""] && [[self imageUrlForRow:indexPath.row] length] == 0)
                        {
                            [[cell viewWithTag:12] setFrame:CGRectMake([cell viewWithTag:12].frame.origin.x+100, [cell viewWithTag:12].frame.origin.y, [cell viewWithTag:12].frame.size.width, [cell viewWithTag:12].frame.size.height)];
                        }
                        else
                        {
                            [[cell viewWithTag:11] setFrame:CGRectMake([cell viewWithTag:11].frame.origin.x+100, [cell viewWithTag:11].frame.origin.y, [cell viewWithTag:11].frame.size.width, [cell viewWithTag:11].frame.size.height)];
                        }
                    }
                    
                    
                    [UIView animateWithDuration:0.2 delay:0.0 options:0
                                     animations:^{
                                         [[cell viewWithTag:9] setAlpha:0.0];
                                         [[cell viewWithTag:10] setAlpha:0.0];
                                         if (!isOnBreakingNews && !isSearching)
                                         {
                                             if([[news objectForKey:@"mediaType"]isEqualToString:@""] && [[self imageUrlForRow:indexPath.row] length] == 0)
                                             {
                                                 [[cell viewWithTag:12] setFrame:CGRectMake([cell viewWithTag:12].frame.origin.x-100, [cell viewWithTag:12].frame.origin.y, [cell viewWithTag:12].frame.size.width, [cell viewWithTag:12].frame.size.height)];
                                             }
                                             else
                                             {
                                                 [[cell viewWithTag:11] setFrame:CGRectMake([cell viewWithTag:11].frame.origin.x-100, [cell viewWithTag:11].frame.origin.y, [cell viewWithTag:11].frame.size.width, [cell viewWithTag:11].frame.size.height)];
                                             }
                                         }
                                         
                                     }
                                     completion:^(BOOL finished) {
                                         [[cell viewWithTag:9] setAlpha:1.0];
                                         [[cell viewWithTag:10] setAlpha:1.0];
                                         [[cell viewWithTag:9] setHidden:YES];
                                         [[cell viewWithTag:10] setHidden:YES];
                                     }];
                    [UIView commitAnimations];
                }
                else
                {
                    [[cell viewWithTag:9] setHidden:YES];
                    [[cell viewWithTag:10] setHidden:YES];
                }
            }
        }
        else
        {
            NSDictionary* news = [dataSource objectAtIndex:indexPath.row];
            if (!isOnBreakingNews && !isSearching)
            {
                if (showingFav)
                {
                    if ([self isBreakingNews:[news objectForKey:@"body"]])
                    {
                        if([[news objectForKey:@"mediaType"]isEqualToString:@""] && [[self imageUrlForRow:indexPath.row] length] == 0)
                        {
                            [[cell viewWithTag:12] setHidden:NO];
                            [[cell viewWithTag:11] setHidden:YES];
                        }
                        else
                        {
                            [[cell viewWithTag:12] setHidden:YES];
                            [[cell viewWithTag:11] setHidden:NO];
                        }
                        [[cell viewWithTag:8] setBackgroundColor:[UIColor colorWithRed:81.0/255.0 green:43.0/255.0 blue:43.0/255.0 alpha:1.0]];
                        [cell viewWithTag:8].layer.borderColor = [UIColor colorWithRed:48.0/255.0 green:26.0/255.0 blue:26.0/255.0 alpha:1.0].CGColor;
                    }
                    else
                    {
                        [[cell viewWithTag:12] setHidden:YES];
                        [[cell viewWithTag:11] setHidden:YES];
                        [[cell viewWithTag:8] setBackgroundColor:[UIColor colorWithRed:50.0/255.0 green:50.0/255.0 blue:50.0/255.0 alpha:1.0]];
                    }
                }
                else
                {
                    if ([[breakingArray objectAtIndex:indexPath.row] integerValue] == 1)
                    {
                        if([[news objectForKey:@"mediaType"]isEqualToString:@""] && [[self imageUrlForRow:indexPath.row] length] == 0)
                        {
                            [[cell viewWithTag:12] setHidden:NO];
                            [[cell viewWithTag:11] setHidden:YES];
                        }
                        else
                        {
                            [[cell viewWithTag:12] setHidden:YES];
                            [[cell viewWithTag:11] setHidden:NO];
                        }
                        [[cell viewWithTag:8] setBackgroundColor:[UIColor colorWithRed:81.0/255.0 green:43.0/255.0 blue:43.0/255.0 alpha:1.0]];
                        [cell viewWithTag:8].layer.borderColor = [UIColor colorWithRed:48.0/255.0 green:26.0/255.0 blue:26.0/255.0 alpha:1.0].CGColor;
                    }
                    else
                    {
                        [[cell viewWithTag:12] setHidden:YES];
                        [[cell viewWithTag:11] setHidden:YES];
                        [[cell viewWithTag:8] setBackgroundColor:[UIColor colorWithRed:50.0/255.0 green:50.0/255.0 blue:50.0/255.0 alpha:1.0]];
                    }
                }
                
            }
            else
            {
                [[cell viewWithTag:12] setHidden:YES];
                [[cell viewWithTag:11] setHidden:YES];
                [[cell viewWithTag:8] setBackgroundColor:[UIColor colorWithRed:50.0/255.0 green:50.0/255.0 blue:50.0/255.0 alpha:1.0]];
            }
        }
    }
    else
    {
        if (!showingFav)
        {
            NSMutableArray* favs = [[NSMutableArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"favs"] copyItems:YES];
            
            if ([favs containsObject:[dataSource objectAtIndex:indexPath.row]])
            {
                [[cell viewWithTag:8] setBackgroundColor:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:225.0/255.0 alpha:1.0]];
                
                [[cell viewWithTag:9] setHidden:NO];
                [[cell viewWithTag:10] setHidden:NO];
                
                [[cell viewWithTag:9] setAlpha:1.0];
                [[cell viewWithTag:10] setAlpha:1.0];
                
                if (isFromSwipe)
                {
                    isFromSwipe = NO;
                    BOOL isOnBreak = NO;
                    CGRect oldBreakRect;
                    NSDictionary* news = [dataSource objectAtIndex:indexPath.row];
                    if (!isOnBreakingNews && !isSearching)
                    {
                        if (showingFav)
                        {
                            if ([self isBreakingNews:[news objectForKey:@"body"]])
                            {
                                isOnBreak = YES;
                                if([[news objectForKey:@"mediaType"]isEqualToString:@""] && [[self imageUrlForRow:indexPath.row] length] == 0)
                                {
                                    oldBreakRect = [cell viewWithTag:12].frame;
                                    [[cell viewWithTag:12] setHidden:NO];
                                    [[cell viewWithTag:11] setHidden:YES];
                                }
                                else
                                {
                                    oldBreakRect = [cell viewWithTag:11].frame;
                                    [[cell viewWithTag:12] setHidden:YES];
                                    [[cell viewWithTag:11] setHidden:NO];
                                }
                            }
                        }
                        else
                        {
                            if ([[breakingArray objectAtIndex:indexPath.row] integerValue] == 1)
                            {
                                isOnBreak = YES;
                                if([[news objectForKey:@"mediaType"]isEqualToString:@""] && [[self imageUrlForRow:indexPath.row] length] == 0)
                                {
                                    oldBreakRect = [cell viewWithTag:12].frame;
                                    [[cell viewWithTag:12] setHidden:NO];
                                    [[cell viewWithTag:11] setHidden:YES];
                                }
                                else
                                {
                                    oldBreakRect = [cell viewWithTag:11].frame;
                                    [[cell viewWithTag:12] setHidden:YES];
                                    [[cell viewWithTag:11] setHidden:NO];
                                }
                            }
                        }
                        
                    }
                    
                    [cell viewWithTag:9].transform=CGAffineTransformMakeRotation(M_PI / -4);
                    [UIView animateWithDuration:0.5 delay:0.0 options:0
                                     animations:^{
                                         [cell viewWithTag:9].transform=CGAffineTransformMakeRotation(M_PI / 2);
                                         if (isOnBreak)
                                         {
                                             if([[news objectForKey:@"mediaType"]isEqualToString:@""] && [[self imageUrlForRow:indexPath.row] length] == 0)
                                             {
                                                 [[cell viewWithTag:12] setFrame:CGRectMake([cell viewWithTag:12].frame.origin.x+100, [cell viewWithTag:12].frame.origin.y, [cell viewWithTag:12].frame.size.width, [cell viewWithTag:12].frame.size.height)];
                                             }
                                             else
                                             {
                                                 [[cell viewWithTag:11] setFrame:CGRectMake([cell viewWithTag:11].frame.origin.x+100, [cell viewWithTag:11].frame.origin.y, [cell viewWithTag:11].frame.size.width, [cell viewWithTag:11].frame.size.height)];
                                             }
                                         }
                                     }
                                     completion:^(BOOL finished) {
                                         [UIView animateWithDuration:0.5 delay:0.0 options:0
                                                          animations:^{
                                                              [cell viewWithTag:9].transform=CGAffineTransformMakeRotation(0);
                                                          }
                                                          completion:^(BOOL finished) {
                                                              [[cell viewWithTag:11] setHidden:YES];
                                                              [[cell viewWithTag:12] setHidden:YES];
                                                              if (isOnBreak)
                                                              {
                                                                  if([[news objectForKey:@"mediaType"]isEqualToString:@""] && [[self imageUrlForRow:indexPath.row] length] == 0)
                                                                  {
                                                                      [[cell viewWithTag:12] setFrame:oldBreakRect];
                                                                  }
                                                                  else
                                                                  {
                                                                      [[cell viewWithTag:11] setFrame:oldBreakRect];
                                                                  }
                                                              }
                                                          }];
                                         [UIView commitAnimations];
                                     }];
                    [UIView commitAnimations];
                }
            }
            else
            {
                NSDictionary* news = [dataSource objectAtIndex:indexPath.row];
                if (!isOnBreakingNews && !isSearching)
                {
                    if (showingFav)
                    {
                        if ([self isBreakingNews:[news objectForKey:@"body"]])
                        {
                            if([[news objectForKey:@"mediaType"]isEqualToString:@""] && [[self imageUrlForRow:indexPath.row] length] == 0)
                            {
                                [[cell viewWithTag:12] setHidden:NO];
                                [[cell viewWithTag:11] setHidden:YES];
                            }
                            else
                            {
                                [[cell viewWithTag:12] setHidden:YES];
                                [[cell viewWithTag:11] setHidden:NO];
                            }
                            [[cell viewWithTag:8] setBackgroundColor:[UIColor colorWithRed:255.0/255.0 green:225.0/255.0 blue:225.0/255.0 alpha:1.0]];
                        }
                        else
                        {
                            [[cell viewWithTag:12] setHidden:YES];
                            [[cell viewWithTag:11] setHidden:YES];
                            [[cell viewWithTag:8] setBackgroundColor:[UIColor colorWithRed:241.0/255.0 green:241.0/255.0 blue:241.0/255.0 alpha:1.0]];
                        }
                    }
                    else
                    {
                        if ([[breakingArray objectAtIndex:indexPath.row] integerValue] == 1)
                        {
                            if([[news objectForKey:@"mediaType"]isEqualToString:@""] && [[self imageUrlForRow:indexPath.row] length] == 0)
                            {
                                [[cell viewWithTag:12] setHidden:NO];
                                [[cell viewWithTag:11] setHidden:YES];
                            }
                            else
                            {
                                [[cell viewWithTag:12] setHidden:YES];
                                [[cell viewWithTag:11] setHidden:NO];
                            }
                            [[cell viewWithTag:8] setBackgroundColor:[UIColor colorWithRed:255.0/255.0 green:225.0/255.0 blue:225.0/255.0 alpha:1.0]];
                        }
                        else
                        {
                            [[cell viewWithTag:12] setHidden:YES];
                            [[cell viewWithTag:11] setHidden:YES];
                            [[cell viewWithTag:8] setBackgroundColor:[UIColor colorWithRed:241.0/255.0 green:241.0/255.0 blue:241.0/255.0 alpha:1.0]];
                        }
                    }
                    
                }
                else
                {
                    [[cell viewWithTag:12] setHidden:YES];
                    [[cell viewWithTag:11] setHidden:YES];
                    [[cell viewWithTag:8] setBackgroundColor:[UIColor colorWithRed:241.0/255.0 green:241.0/255.0 blue:241.0/255.0 alpha:1.0]];
                }
                
                if (isFromSwipe)
                {
                    isFromSwipe = NO;
                    [[cell viewWithTag:9] setHidden:NO];
                    [[cell viewWithTag:10] setHidden:NO];
                    [[cell viewWithTag:9] setAlpha:1.0];
                    [[cell viewWithTag:10] setAlpha:1.0];
                    
                    if (!isOnBreakingNews && !isSearching)
                    {
                        if([[news objectForKey:@"mediaType"]isEqualToString:@""] && [[self imageUrlForRow:indexPath.row] length] == 0)
                        {
                            [[cell viewWithTag:12] setFrame:CGRectMake([cell viewWithTag:12].frame.origin.x+100, [cell viewWithTag:12].frame.origin.y, [cell viewWithTag:12].frame.size.width, [cell viewWithTag:12].frame.size.height)];
                        }
                        else
                        {
                            [[cell viewWithTag:11] setFrame:CGRectMake([cell viewWithTag:11].frame.origin.x+100, [cell viewWithTag:11].frame.origin.y, [cell viewWithTag:11].frame.size.width, [cell viewWithTag:11].frame.size.height)];
                        }
                    }
                    
                    [UIView animateWithDuration:0.2 delay:0.0 options:0
                                     animations:^{
                                         [[cell viewWithTag:9] setAlpha:0.0];
                                         [[cell viewWithTag:10] setAlpha:0.0];
                                         if (!isOnBreakingNews && !isSearching)
                                         {
                                             if([[news objectForKey:@"mediaType"]isEqualToString:@""] && [[self imageUrlForRow:indexPath.row] length] == 0)
                                             {
                                                 [[cell viewWithTag:12] setFrame:CGRectMake([cell viewWithTag:12].frame.origin.x-100, [cell viewWithTag:12].frame.origin.y, [cell viewWithTag:12].frame.size.width, [cell viewWithTag:12].frame.size.height)];
                                             }
                                             else
                                             {
                                                 [[cell viewWithTag:11] setFrame:CGRectMake([cell viewWithTag:11].frame.origin.x-100, [cell viewWithTag:11].frame.origin.y, [cell viewWithTag:11].frame.size.width, [cell viewWithTag:11].frame.size.height)];
                                             }
                                         }
                                         
                                     }
                                     completion:^(BOOL finished) {
                                         [[cell viewWithTag:9] setAlpha:1.0];
                                         [[cell viewWithTag:10] setAlpha:1.0];
                                         [[cell viewWithTag:9] setHidden:YES];
                                         [[cell viewWithTag:10] setHidden:YES];
                                     }];
                    [UIView commitAnimations];
                }
                else
                {
                    [[cell viewWithTag:9] setHidden:YES];
                    [[cell viewWithTag:10] setHidden:YES];
                }
            }
        }
        else
        {
            NSDictionary* news = [dataSource objectAtIndex:indexPath.row];
            if (!isOnBreakingNews && !isSearching)
            {
                if (showingFav)
                {
                    if ([self isBreakingNews:[news objectForKey:@"body"]])
                    {
                        if([[news objectForKey:@"mediaType"]isEqualToString:@""] && [[self imageUrlForRow:indexPath.row] length] == 0)
                        {
                            [[cell viewWithTag:12] setHidden:NO];
                            [[cell viewWithTag:11] setHidden:YES];
                        }
                        else
                        {
                            [[cell viewWithTag:12] setHidden:YES];
                            [[cell viewWithTag:11] setHidden:NO];
                        }
                        [[cell viewWithTag:8] setBackgroundColor:[UIColor colorWithRed:255.0/255.0 green:225.0/255.0 blue:225.0/255.0 alpha:1.0]];
                    }
                    else
                    {
                        [[cell viewWithTag:12] setHidden:YES];
                        [[cell viewWithTag:11] setHidden:YES];
                        [[cell viewWithTag:8] setBackgroundColor:[UIColor colorWithRed:241.0/255.0 green:241.0/255.0 blue:241.0/255.0 alpha:1.0]];
                    }
                }
                else
                {
                    if ([[breakingArray objectAtIndex:indexPath.row] integerValue] == 1)
                    {
                        if([[news objectForKey:@"mediaType"]isEqualToString:@""] && [[self imageUrlForRow:indexPath.row] length] == 0)
                        {
                            [[cell viewWithTag:12] setHidden:NO];
                            [[cell viewWithTag:11] setHidden:YES];
                        }
                        else
                        {
                            [[cell viewWithTag:12] setHidden:YES];
                            [[cell viewWithTag:11] setHidden:NO];
                        }
                        [[cell viewWithTag:8] setBackgroundColor:[UIColor colorWithRed:255.0/255.0 green:225.0/255.0 blue:225.0/255.0 alpha:1.0]];
                    }
                    else
                    {
                        [[cell viewWithTag:12] setHidden:YES];
                        [[cell viewWithTag:11] setHidden:YES];
                        [[cell viewWithTag:8] setBackgroundColor:[UIColor colorWithRed:241.0/255.0 green:241.0/255.0 blue:241.0/255.0 alpha:1.0]];
                    }
                }
                
            }
            else
            {
                [[cell viewWithTag:12] setHidden:YES];
                [[cell viewWithTag:11] setHidden:YES];
                [[cell viewWithTag:8] setBackgroundColor:[UIColor colorWithRed:241.0/255.0 green:241.0/255.0 blue:241.0/255.0 alpha:1.0]];
            }
        }
    }
    
    if (!showingFav)
    {
        if (isScrollButton)
        {
            if (indexPath.row <= indVal)
            {
                if (indexPath.row > 0)
                {
                    isRectResume = YES;
                }
                
                [self performSelector:@selector(setHeaderBack) withObject:nil afterDelay:0.2];
            }
        }
        
        if (isRectResume && indexPath.row == 0)
        {
            isRectResume = NO;
            [self performSelector:@selector(setHeaderBack) withObject:nil afterDelay:0.2];
            [self performSelector:@selector(addBackToRect) withObject:nil afterDelay:5.0];
        }
        else if (indexPath.row == 0 && isScrollButton)
        {
            [self performSelector:@selector(setHeaderBack) withObject:nil afterDelay:0.2];
        }
    }
    
    [cell viewWithTag:8].layer.borderWidth = 1;
    [cell viewWithTag:8].layer.masksToBounds = NO;
    [cell viewWithTag:8].layer.shouldRasterize = YES;
    
    if (indexPath.row < countToEnd)
    {
        countToEnd = indexPath.row+1;
    }
    
    if (countToEnd < 0)countToEnd = 0;
    
    if (countToEnd == 0)
    {
        countToEnd = 0;
        [UIView animateWithDuration:0.2 delay:0.0 options:0
                         animations:^{
                             [[tableView viewWithTag:839] setAlpha:0.0];
                             [[tableView viewWithTag:840] setAlpha:0.0];
                             NSLog(@"countToEnd hidden in cell");
                         }
                         completion:^(BOOL finished) {
                             //
                         }];
        [UIView commitAnimations];
    }
    else
    {
        [(UILabel*)[tableView viewWithTag:839] setText:[@"       " stringByAppendingFormat:@"%ld",(long)countToEnd]];
    }
}

- (IBAction)infoClicked:(id)sender event:(id)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchPos = [touch locationInView:tableView];
    NSIndexPath *indexPath = [tableView indexPathForRowAtPoint:touchPos];
    
    if (indexPath == nil)
    {
        return;
    }
    
    if (isSearching)
    {
        [searchView setHidden:YES];
    }
    
    NSDictionary* news = [dataSource objectAtIndex:indexPath.row];
    
    [[NSUserDefaults standardUserDefaults] setObject:[news objectForKey:@"userID"] forKey:@"subscriptionsObject"];
    [[NSUserDefaults standardUserDefaults] setObject:[news objectForKey:@"name"] forKey:@"theInfoTitle"];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isReloadNeeded"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [self performSegueWithIdentifier:@"infoSeg" sender:self];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y <= 20 && [tableView viewWithTag:839].alpha > 0)
    {
        countToEnd = 0;
        [UIView animateWithDuration:0.2 delay:0.0 options:0
                         animations:^{
                             [[tableView viewWithTag:839] setAlpha:0.0];
                             [[tableView viewWithTag:840] setAlpha:0.0];
                         }
                         completion:^(BOOL finished) {
                             //
                         }];
        [UIView commitAnimations];
    }
}

-(NSString*)imageUrlForRow:(NSInteger)theRow
{
    NSDictionary* news = [dataSource objectAtIndex:theRow];
    
    NSArray *urls = [[news objectForKey:@"photos"] componentsSeparatedByString:@","];
    
    if (urls.count > 0)
    {
        if ([[urls objectAtIndex:0] length] > 5)
        {
            return [[urls objectAtIndex:0] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
        else
        {
            if (urls.count > 1)
            {
                if ([[urls objectAtIndex:1] length] > 5)
                {
                    return [[urls objectAtIndex:1] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                }
            }
        }
    }
    
    return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableVieww cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* cellID = @"newsFeedCell";
    UITableViewCell *cell = [tableVieww dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    
    if(!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isNightOn"])
    {
        [(UILabel*)[cell viewWithTag:2] setTextColor:[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0]];
        [(UILabel*)[cell viewWithTag:4] setTextColor:[UIColor lightGrayColor]];
        
        [(UILabel*)[cell viewWithTag:2] setHighlightedTextColor:[UIColor whiteColor]];
        [(UILabel*)[cell viewWithTag:3] setHighlightedTextColor:[UIColor whiteColor]];
        [(UILabel*)[cell viewWithTag:4] setHighlightedTextColor:[UIColor whiteColor]];
        
        cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"settings-selected-back.png"]];
        
        [[[cell viewWithTag:5] layer] setBorderColor:[UIColor colorWithRed:20.0/255.0 green:20.0/255.0 blue:20.0/255.0 alpha:1.0].CGColor];
        [(UIImageView*)[cell viewWithTag:5] setBackgroundColor:[UIColor colorWithRed:20.0/255.0 green:20.0/255.0 blue:20.0/255.0 alpha:1.0]];
        
        [(UIImageView*)[cell viewWithTag:10] setTintColor:[UIColor colorWithRed:20.0/255.0 green:20.0/255.0 blue:20.0/255.0 alpha:1.0]];
        [(UIImageView*)[cell viewWithTag:10] setImage:[[UIImage imageNamed:@"top-left-back.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    }
    else
    {
        [(UILabel*)[cell viewWithTag:2] setTextColor:[UIColor colorWithRed:30.0/255.0 green:30.0/255.0 blue:30.0/255.0 alpha:1.0]];
        [(UILabel*)[cell viewWithTag:4] setTextColor:[UIColor colorWithRed:37.0/255.0 green:37.0/255.0 blue:37.0/255.0 alpha:1.0]];
        
        [(UILabel*)[cell viewWithTag:2] setHighlightedTextColor:[UIColor blackColor]];
        [(UILabel*)[cell viewWithTag:3] setHighlightedTextColor:[UIColor colorWithRed:77.0/255.0 green:165.0/255.0 blue:224.0/255.0 alpha:1.0]];
        [(UILabel*)[cell viewWithTag:4] setHighlightedTextColor:[UIColor blackColor]];
        
        cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"news-selected-back.png"]];
        
        [[[cell viewWithTag:5] layer] setBorderColor:[UIColor colorWithRed:50.0/255.0 green:50.0/255.0 blue:50.0/255.0 alpha:0.5].CGColor];
        [(UIImageView*)[cell viewWithTag:5] setBackgroundColor:[UIColor colorWithRed:221.0/255.0 green:221.0/255.0 blue:221.0/255.0 alpha:1.0]];
        
        [(UIImageView*)[cell viewWithTag:10] setTintColor:[UIColor colorWithRed:85.0/255.0 green:85.0/255.0 blue:85.0/255.0 alpha:1.0]];
        [(UIImageView*)[cell viewWithTag:10] setImage:[[UIImage imageNamed:@"top-left-back.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    }
    
    if (showingFav)
    {
        [(UILabel*)[tableView viewWithTag:837] setText:[@"عدد الأخبار في المفضلة " stringByAppendingFormat:@"(%ld)",(long)dataSource.count]];
    }
    else
    {
        [(UILabel*)[tableView viewWithTag:837] setText:[@"عدد الأخبار المتبقية " stringByAppendingFormat:@"(%ld)",(long)[self getTheCount]]];
    }
    
    NSDictionary* news = [dataSource objectAtIndex:indexPath.row];
    
    //[(UIImageView*)[cell viewWithTag:1] hnk_setImageFromURL:[NSURL URLWithString:[[news objectForKey:@"icon"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholder:nil];
    
    [(UIImageView*)[cell viewWithTag:1] sd_setImageWithURL:[NSURL URLWithString:[news objectForKey:@"icon"]]
                      placeholderImage:nil];
    
    
    [(UILabel*)[cell viewWithTag:2] setText:[news objectForKey:@"name"]];
    
    [[[cell viewWithTag:1] layer] setCornerRadius:5];
    [[[cell viewWithTag:5] layer] setCornerRadius:5];
    [[[cell viewWithTag:5] layer] setBorderWidth:1];
    
    [cell viewWithTag:5].layer.shouldRasterize = YES;
    [cell viewWithTag:1].layer.shouldRasterize = YES;
    
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
        if (!showingFav)
        {
            [(UILabel*)[tableView viewWithTag:838] setText:@"أخبار اليوم"];
        }
    }else if (diff < 3600)
    {
        if ((int)(diff/60) == 1)
        {
            [(UILabel*)[cell viewWithTag:3] setText:@"منذ دقيقة"];
        }
        else if ((int)(diff/60) == 2)
        {
            [(UILabel*)[cell viewWithTag:3] setText:@"منذ دقيقتين"];
        }
        else if ((int)(diff/60) <= 10)
        {
            [(UILabel*)[cell viewWithTag:3] setText:[NSString stringWithFormat:@"منذ %i دقائق",(int)(diff/60)]];
        }
        else
        {
            [(UILabel*)[cell viewWithTag:3] setText:[NSString stringWithFormat:@"منذ %i دقيقة",(int)(diff/60)]];
        }
        
        if (!showingFav)
        {
            [(UILabel*)[tableView viewWithTag:838] setText:@"أخبار اليوم"];
        }
    }else if (diff < 86400)
    {
        if ((int)(diff/3600) == 1)
        {
            [(UILabel*)[cell viewWithTag:3] setText:@"منذ ساعة"];
        }
        else if ((int)(diff/3600) == 2)
        {
            [(UILabel*)[cell viewWithTag:3] setText:@"منذ ساعتين"];
        }
        else if ((int)(diff/3600) <= 10)
        {
            [(UILabel*)[cell viewWithTag:3] setText:[NSString stringWithFormat:@"منذ %i ساعات",(int)(diff/3600)]];
        }
        else
        {
            [(UILabel*)[cell viewWithTag:3] setText:[NSString stringWithFormat:@"منذ %i ساعة",(int)(diff/3600)]];
        }
        if (!showingFav)
        {
            [(UILabel*)[tableView viewWithTag:838] setText:[self getDayStr:newsStamp andCompare:diff andToday:date]];
        }
    }else if (diff < 604800)
    {
        if ((int)(diff/86400) == 1)
        {
            [(UILabel*)[cell viewWithTag:3] setText:@"منذ يوم"];
        }
        else if ((int)(diff/86400) == 2)
        {
            [(UILabel*)[cell viewWithTag:3] setText:@"منذ يومين"];
        }
        else if ((int)(diff/86400) <= 10)
        {
            [(UILabel*)[cell viewWithTag:3] setText:[NSString stringWithFormat:@"منذ %i أيام",(int)(diff/86400)]];
        }
        else
        {
            [(UILabel*)[cell viewWithTag:3] setText:[NSString stringWithFormat:@"منذ %i يوم",(int)(diff/86400)]];
        }
        
        if (!showingFav)
        {
            if ((int)(diff/86400) == 1)
            {
                [(UILabel*)[tableView viewWithTag:838] setText:@"أخبار أمس"];
            }
            else
            {
                [(UILabel*)[tableView viewWithTag:838] setText:@"أخبار الأسبوع"];
            }
        }
    }else if (diff < 2592000)
    {
        if ((int)(diff/604800) == 1)
        {
            [(UILabel*)[cell viewWithTag:3] setText:@"منذ إسبوع"];
        }
        else if ((int)(diff/604800) == 2)
        {
            [(UILabel*)[cell viewWithTag:3] setText:@"منذ إسبوعين"];
        }
        else if ((int)(diff/604800) <= 10)
        {
            [(UILabel*)[cell viewWithTag:3] setText:[NSString stringWithFormat:@"منذ %i أسابيع",(int)(diff/604800)]];
        }
        else
        {
            [(UILabel*)[cell viewWithTag:3] setText:[NSString stringWithFormat:@"منذ %i إسبوع",(int)(diff/604800)]];
        }
        
        if (!showingFav)
        {
            if ((int)(diff/604800) == 1)
            {
                [(UILabel*)[tableView viewWithTag:838] setText:@"أخبار الأسبوع"];
            }
            else
            {
                [(UILabel*)[tableView viewWithTag:838] setText:@"أخبار سابقة"];
            }
        }
    }
    else
    {
        if ((int)(diff/2592000) == 1)
        {
            [(UILabel*)[cell viewWithTag:3] setText:@"منذ شهر"];
        }
        else if ((int)(diff/2592000) == 2)
        {
            [(UILabel*)[cell viewWithTag:3] setText:@"منذ شهرين"];
        }
        else if ((int)(diff/2592000) <= 10)
        {
            [(UILabel*)[cell viewWithTag:3] setText:[NSString stringWithFormat:@"منذ %i أشهر",(int)(diff/2592000)]];
        }
        else
        {
            [(UILabel*)[cell viewWithTag:3] setText:[NSString stringWithFormat:@"منذ %i شهر",(int)(diff/2592000)]];
        }
        
        if (!showingFav)
        {
            [(UILabel*)[tableView viewWithTag:838] setText:@"أخبار سابقة"];
        }
    }
    
    [(UILabel*)[cell viewWithTag:4] setText:[self getFilteredStringFrom:[news objectForKey:@"body"]]];
    
    [(UIImageView*)[cell viewWithTag:5] setImage:nil];
    
    if ([cell viewWithTag:999])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[cell viewWithTag:999] removeFromSuperview];
        });
    }
    
    if([[news objectForKey:@"mediaType"]isEqualToString:@""])
    {
        NSString *imgUrl = [self imageUrlForRow:indexPath.row];
        if ([imgUrl length] > 0)
        {
            [(UIImageView*)[cell viewWithTag:5] setAlpha:1.0];
            
            UIImageView *anmImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 83, 83)];
            
            [anmImage setTag:999];
            
            anmImage.clipsToBounds = YES;
            
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isNightOn"])
            {
                [anmImage setTintColor:[UIColor lightGrayColor]];
                
                anmImage.image = [[UIImage imageNamed:@"image-loading-img.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            }
            else
            {
                [anmImage setTintColor:[UIColor colorWithRed:130.0/255.0 green:130.0/255.0 blue:130.0/255.0 alpha:1.0]];
                
                anmImage.image = [[UIImage imageNamed:@"image-loading-img.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            }
            
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
            animation.fromValue = [NSNumber numberWithFloat:1.0f];
            animation.toValue = [NSNumber numberWithFloat: 999];
            animation.duration = 170.5f;
            [anmImage.layer addAnimation:animation forKey:@"MyAnimation"];
            
            anmImage.center = [cell viewWithTag:5].center;
            
            [cell addSubview:anmImage];
            
            [(UIImageView*)[cell viewWithTag:5] hnk_setImageFromURL:[NSURL URLWithString:[imgUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholder:[UIImage imageNamed:@"loading-img.png"] success:^(UIImage *image) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [(UIImageView*)[cell viewWithTag:5] setImage:image];
                    [anmImage stopAnimating];
                    [anmImage removeFromSuperview];
                    [[cell viewWithTag:999] removeFromSuperview];
                });
            } failure:^(NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [anmImage stopAnimating];
                    [anmImage removeFromSuperview];
                    [[cell viewWithTag:999] removeFromSuperview];
                    [(UIImageView*)[cell viewWithTag:5] setImage:[UIImage imageNamed:@"no-image-img.png"]];
                });
            }];
        }
        else
        {
            [(UIImageView*)[cell viewWithTag:5] setAlpha:0.0];
        }
    }else
    {
        [(UIImageView*)[cell viewWithTag:5] setAlpha:1.0];
        
        UIImageView *anmImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 83, 83)];
        
        [anmImage setTag:999];
        
        anmImage.clipsToBounds = YES;
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isNightOn"])
        {
            [anmImage setTintColor:[UIColor lightGrayColor]];
            
            anmImage.image = [[UIImage imageNamed:@"image-loading-img.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }
        else
        {
            [anmImage setTintColor:[UIColor colorWithRed:130.0/255.0 green:130.0/255.0 blue:130.0/255.0 alpha:1.0]];
            
            anmImage.image = [[UIImage imageNamed:@"image-loading-img.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        animation.fromValue = [NSNumber numberWithFloat:1.0f];
        animation.toValue = [NSNumber numberWithFloat: 999];
        animation.duration = 170.5f;
        [anmImage.layer addAnimation:animation forKey:@"MyAnimation"];
        
        anmImage.center = [cell viewWithTag:5].center;
        
        [cell addSubview:anmImage];
        
        [(UIImageView*)[cell viewWithTag:5] hnk_setImageFromURL:[NSURL URLWithString:[[news objectForKey:@"mediaURL"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholder:[UIImage imageNamed:@"loading-img.png"] success:^(UIImage *image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [(UIImageView*)[cell viewWithTag:5] setImage:image];
                [anmImage stopAnimating];
                [anmImage removeFromSuperview];
                [[cell viewWithTag:999] removeFromSuperview];
            });
        } failure:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [anmImage stopAnimating];
                [anmImage removeFromSuperview];
                [[cell viewWithTag:999] removeFromSuperview];
                [(UIImageView*)[cell viewWithTag:5] setImage:[UIImage imageNamed:@"no-image-img.png"]];
            });
        }];
    }
    
    if(!showingFav && indexPath.row > dataSource.count-5 && dataSource.count > theSavedCount)
    {
        theSavedCount = dataSource.count;
        if(isSearching)
        {
            isFromRefresh = YES;
            [self getSearchData];
        }
        else if (isOnBreakingNews)
        {
            [(UILabel*)[tableView viewWithTag:837] setText:@"جاري تحميل المزيد من الأخبار.."];
            [self getDataForBreakingNews:2];
        }
        else
        {
            [(UILabel*)[tableView viewWithTag:837] setText:@"جاري تحميل المزيد من الأخبار.."];
            [self getData];
        }
    }
    
    return cell;
}

-(NSString*)getFilteredStringFrom:(NSString*)theString
{
    NSDataDetector *linkDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
    
    NSArray *matches = [linkDetector matchesInString:theString options:0 range:NSMakeRange(0, [theString length])];
    
    for (NSTextCheckingResult *match in matches)
    {
        if ([match resultType] == NSTextCheckingTypeLink)
        {
            theString = [theString stringByReplacingOccurrencesOfString:[[match URL] absoluteString] withString:@""];
        }
    }
    
    theString = [theString stringByReplacingOccurrencesOfString:@"RT" withString:@""];
    theString = [theString stringByReplacingOccurrencesOfString:@"#retweet" withString:@""];
    theString = [theString stringByReplacingOccurrencesOfString:@"#Retweet" withString:@""];
    theString = [theString stringByReplacingOccurrencesOfString:@"#ريتويت" withString:@""];
    
    NSMutableArray* splitting = [[NSMutableArray alloc]initWithArray:[theString componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    
    for (NSString *string in splitting)
    {
        if ([string hasPrefix:@"@"])
        {
            theString = [theString stringByReplacingOccurrencesOfString:string withString:@""];
        }
    }
    
    return theString;
}

-(void)showStatusBarMsg:(NSString*)theMsg isRed:(BOOL)isRed
{
    UIColor *selectedColor,*theTextColor;
    
    if (isRed)
    {
        theTextColor = [UIColor whiteColor];
        if ([[NSUserDefaults standardUserDefaults] integerForKey:@"currentColor"] == 6)
        {
            selectedColor = [UIColor colorWithRed:20.0/255.0 green:20.0/255.0 blue:20.0/255.0 alpha:1.0];
        }
        else
        {
            selectedColor = [UIColor colorWithRed:209.0/255.0 green:65.0/255.0 blue:65.0/255.0 alpha:1.0];
        }
    }
    else
    {
        theTextColor = [UIColor colorWithRed:71.0/255.0 green:69.0/255.0 blue:9.0/255.0 alpha:1.0];
        selectedColor = [UIColor colorWithRed:230.0/255.0 green:223.0/255.0 blue:37.0/255.0 alpha:1.0];
    }
    
    NSDictionary *options = @{
                              kCRToastTextKey : theMsg,
                              kCRToastTextColorKey : theTextColor,
                              kCRToastBackgroundColorKey : selectedColor,
                              kCRToastTextAlignmentKey : @(NSTextAlignmentCenter),
                              kCRToastAnimationInTypeKey : @(CRToastAnimationTypeLinear),
                              kCRToastAnimationOutTypeKey : @(CRToastAnimationTypeLinear),
                              kCRToastAnimationInDirectionKey : @(CRToastAnimationDirectionTop),
                              kCRToastAnimationOutDirectionKey : @(CRToastAnimationDirectionBottom)
                              };
    [CRToastManager showNotificationWithOptions:options
                                completionBlock:^{
                                    NSLog(@"Completed");
                                    if (isSearchMsg)
                                    {
                                        isSearchMsg = NO;
                                        [searchTextField becomeFirstResponder];
                                    }
                                }];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary* news = [dataSource objectAtIndex:indexPath.row];
    
    if([[news objectForKey:@"mediaType"]isEqualToString:@""] && [[self imageUrlForRow:indexPath.row] length] == 0)
    {
        return 150.0;
    }
    
    return 358.0;
}

-(void)tableView:(UITableView *)tableView2 didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary* news = [dataSource objectAtIndex:indexPath.row];
    
    if([[news objectForKey:@"newsURL"]isEqualToString:@""])
    {
        [self showStatusBarMsg:@"لايوجد تفاصيل لهذا الخبر" isRed:YES];
        
        [tableView2 deselectRowAtIndexPath:indexPath animated:NO];
    }
    else
    {
        if (isSearching && !isSearchYet)
        {
            [self cancelSearching];
        }
        
        NSDictionary* news = [dataSource objectAtIndex:indexPath.row];
        
        NSString *sharedMsg=[news objectForKey:@"body"];
        NSArray* sharedObjects;
        
        if([[news objectForKey:@"mediaURL"]isEqualToString:@""])
        {
            sharedObjects=[NSArray arrayWithObjects:sharedMsg, nil];
            [[NSUserDefaults standardUserDefaults] setObject:sharedMsg forKey:@"textToShare"];
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"imgToShare"];
            
        }
        else
        {
            [[NSUserDefaults standardUserDefaults] setObject:sharedMsg forKey:@"textToShare"];
            [[NSUserDefaults standardUserDefaults] setObject:[news objectForKey:@"mediaURL"] forKey:@"imgToShare"];
        }
        
        UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
        
        if ([[cell viewWithTag:5] alpha] > 0 && ![[cell viewWithTag:5] isHidden])
        {
            [[NSUserDefaults standardUserDefaults] setObject:UIImagePNGRepresentation([(UIImageView*)[cell viewWithTag:5] image]) forKey:@"currentImgData"];
        }
        else
        {
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"currentImgData"];
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:sharedObjects forKey:@"objectsToShare"];
        [[NSUserDefaults standardUserDefaults] setObject:[news objectForKey:@"newsURL"] forKey:@"newsLinkToOpen"];
        [[NSUserDefaults standardUserDefaults] setObject:[news objectForKey:@"photos"] forKey:@"newsAllPhotos"];
        [[NSUserDefaults standardUserDefaults] setObject:[news objectForKey:@"videos"] forKey:@"newsAllVideos"];
        [[NSUserDefaults standardUserDefaults] setObject:[news objectForKey:@"body"] forKey:@"savedNewsTitle"];
        [[NSUserDefaults standardUserDefaults] setObject:[news objectForKey:@"fullBody"] forKey:@"savedNewsBody"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self performSegueWithIdentifier:@"detailsSeg" sender:self];
    }
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
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
    return [mutableString copy];
}

-(void)refreshNavigationItems
{
    if (!showingFav && !isOnBreakingNews)
    {
        UIBarButtonItem *searchButton = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:@selector(startSearching)];
        [searchButton setImage:[UIImage imageNamed:@"search-icon.png"]];
        
        UIBarButtonItem *moreButton = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:@selector(optionsClicked:)];
        [moreButton setImage:[UIImage imageNamed:@"more-icon.png"]];
        UIBarButtonItem *space = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
        space.width = 10;
        
        NSArray *buttons = @[moreButton, space, searchButton];
        
        self.navigationItem.rightBarButtonItems = buttons;
    }
    else
    {
        UIBarButtonItem *moreButton = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:@selector(optionsClicked:)];
        [moreButton setImage:[UIImage imageNamed:@"more-icon.png"]];
        
        self.navigationItem.rightBarButtonItem = moreButton;
    }
}

- (void)savingImage:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error)
    {
        [SADAHMsg showMsgWithTitle:@"لايمكن حفظ الصورة" andMsg:@"تأكد من السماح للتطبيق بالوصول إلى ألبوم الصور من إعدادات جهازك حتى يتمكن من حفظ الصورة." inView:[self.navigationController view] withCase:2];
    }
    else
    {
        [self showStatusBarMsg:@"تم حفظ الصورة بنجاح" isRed:NO];
    };
}

-(void)saveTheImg
{
    UIImageWriteToSavedPhotosAlbum(imgToSave, self, @selector(savingImage:didFinishSavingWithError:contextInfo:), nil);
}

#pragma mark action sheet delegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSDictionary* news = [dataSource objectAtIndex:tableView.indexPathForSelectedRow.row];
    
    if (actionSheet.tag == 15)
    {
        if(buttonIndex == 0)
        {
            [self deleteTheFav];
        }
        else
        {
            [self closeFavSwipe];
        }
    }
    else if (actionSheet.tag == 14)
    {
        if(buttonIndex == 0)
        {
            [self performSelector:@selector(saveTheImg) withObject:nil afterDelay:0.5];
        }
    }
    else if(actionSheet.tag == 1)
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
        }else if(buttonIndex == 1)
        {
        }else if(buttonIndex == 2)
        {
            [self performSegueWithIdentifier:@"notifSeg" sender:self];
        }else if(buttonIndex == 3)
        {
            
        }
    }
}



@end
