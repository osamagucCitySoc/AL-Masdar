//
//  NewsDetailsViewController.m
//  AL-Masdar
//
//  Created by Osama Rabie on 6/25/15.
//  Copyright (c) 2015 Osama Rabie. All rights reserved.
//

#import "NewsDetailsViewController.h"

@interface NewsDetailsViewController ()<UIWebViewDelegate>

@end

@implementation NewsDetailsViewController
{
    __weak IBOutlet UIWebView *webView;
    __weak IBOutlet UIView *loadingView;
}
@synthesize url;
- (void)viewDidLoad {
    [super viewDidLoad];

    [self openURL];
    
}

-(void)openURL
{
    [loadingView setAlpha:0.0];
    
    [webView setDelegate:self];
    
    self.url = [self.url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    /*    if(![self.url hasPrefix:@"https"])
     {
     self.url = [@"http://mobilizer.instapaper.com/m?url=" stringByAppendingString:self.url];
     }*/
    
    self.url = [@"http://mobilizer.instapaper.com/m?u=" stringByAppendingString:self.url];
    
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.url] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:100]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveLocalNotification:)
                                                 name:@"OpenUrl"
                                               object:nil];
}

- (void) receiveLocalNotification:(NSNotification *) notification
{
    if([notification.name isEqualToString:@"OpenUrl"])
    {
        NSDictionary *userInfo = notification.userInfo;
        NSString* urll = [userInfo objectForKey:@"url"];
        self.url = urll;
        [self openURL];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"" object:nil];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [loadingView setAlpha:1.0];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [loadingView setAlpha:0.0];
}


- (IBAction)closButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
