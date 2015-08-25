//
//  WatchViewController.m
//
//  Created by Housein Jouhar on 7/10/15.
//  Copyright (c) 2015 SADAH Software Solutions. All rights reserved.
//

#import "WatchViewController.h"

@interface WatchViewController ()

@end

@implementation WatchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoStarted:) name:UIWindowDidBecomeVisibleNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoFinished:) name:UIWindowDidBecomeHiddenNotification object:nil];
    
    NSURLRequest* req = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",@"http://almasdarapp.com/almasdar/goalsVideos/",[[NSUserDefaults standardUserDefaults] objectForKey:@"currentHtmlCode"]]] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:100];
    
    [[_videoWebView scrollView] setScrollEnabled:NO];
    
    [_videoWebView loadRequest:req];
    
    [_videoWebView setHidden:YES];
    
    [_actView startAnimating];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isNightOn"])
    {
        [_watchNavBar setBarTintColor:[UIColor colorWithRed:70.0/255.0 green:70.0/255.0 blue:70.0/255.0 alpha:1.0]];
        [_watchNavBar setTintColor:[UIColor whiteColor]];
        [_watchNavBar setBarStyle:UIBarStyleBlack];
        [_watchTopLabel setBackgroundColor:[UIColor colorWithRed:70.0/255.0 green:70.0/255.0 blue:70.0/255.0 alpha:1.0]];
    }
    else
    {
        [_watchNavBar setBarTintColor:[UIColor colorWithRed:241.0/255.0 green:241.0/255.0 blue:241.0/255.0 alpha:1.0]];
        [_watchNavBar setBarStyle:UIBarStyleDefault];
        [_watchNavBar setTintColor:[UIColor blackColor]];
        [_watchTopLabel setBackgroundColor:[UIColor colorWithRed:241.0/255.0 green:241.0/255.0 blue:241.0/255.0 alpha:1.0]];
    }
}

-(void)videoStarted:(NSNotification *)notification{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isLandscapeOn"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isSoundEffects"])
    {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
}

-(void)videoFinished:(NSNotification *)notification{
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isLandscapeOn"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isSoundEffects"])
    {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
    }
    
    [self setToPortrait];
}

-(void)setToPortrait
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)return;
    
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
}

- (IBAction)closeWatchView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isNightOn"]) return UIStatusBarStyleLightContent;
    return UIStatusBarStyleDefault;
}

- (void) webViewDidFinishLoad:(UIWebView *)webView
{
    if (webView.tag == 909)
    {
        [_actView stopAnimating];
        [webView setHidden:NO];
        return;
    }
    
    NSString *hTMLString = [webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
    
    if ([hTMLString rangeOfString:@"<iframe"].location != NSNotFound && !loadedDone)
    {
        loadedDone = YES;
        
        NSString *embedHTML = @"<iframe width=\"$$$\" height=\"&&&\" src=\"###\" frameborder=\"0\" allowfullscreen></iframe>";
        
        embedHTML = [embedHTML stringByReplacingOccurrencesOfString:@"$$$" withString:[@"" stringByAppendingFormat:@"%d",(int)webView.frame.size.width]];
        embedHTML = [embedHTML stringByReplacingOccurrencesOfString:@"&&&" withString:[@"" stringByAppendingFormat:@"%d",(int)webView.frame.size.height]];
        
        embedHTML = [embedHTML stringByReplacingOccurrencesOfString:@"###" withString:[self findUrls:hTMLString]];
        
        [webView setTag:909];
        [webView loadHTMLString:embedHTML baseURL:nil];
    }
}

-(NSString*)findUrls:(NSString *)string
{
    NSError *error = NULL;
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink
                                                               error:&error];
    
    
    if (error)return @"";
    
    NSRange r = NSMakeRange(0, [string length]);
    
    if (r.length == 0)return @"";
    
    NSArray *matches = [detector matchesInString:string
                                         options:0
                                           range:NSMakeRange(0, [string length])];
    
    
    for (NSTextCheckingResult *match in matches) {
        if ([match resultType] == NSTextCheckingTypeLink) {
            if (![[NSString stringWithFormat:@"%@",[match URL]] hasPrefix:@"mailto:"])
            {
                return [NSString stringWithFormat:@"%@",[match URL]];
            }
        }
    }
    
    return @"";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
