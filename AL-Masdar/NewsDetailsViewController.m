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

    [loadingView setAlpha:0.0];

    [webView setDelegate:self];
    
    self.url = [@"http://www.readability.com/m?url=" stringByAppendingString:self.url];
    
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.url] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:100]];
    
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
