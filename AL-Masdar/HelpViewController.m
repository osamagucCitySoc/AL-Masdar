//
//  HelpViewController.m
//
//  Created by Housein Jouhar on 7/10/15.
//  Copyright (c) 2015 SADAH Software Solutions. All rights reserved.
//

#import "HelpViewController.h"

@interface HelpViewController ()

@end

@implementation HelpViewController

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
    
    [self performSelector:@selector(startCellFav) withObject:nil afterDelay:0.6];
}

-(void)startCellFav
{
    _helpImg3.image = [UIImage imageNamed:@"help-cell-sample.png"];
    
    [_blackLabel2 setHidden:YES];
    [_shareImg setHidden:YES];
    
    [UIView animateWithDuration:0.1 delay:0.0 options:0
                     animations:^{
                         [_helpImg1 setAlpha:1.0];
                         [[self.view viewWithTag:2] setAlpha:1.0];
                         
                         [(UILabel*)[self.view viewWithTag:2] setTextColor:[UIColor colorWithRed:248.0/255.0 green:156.0/255.0 blue:37.0/255.0 alpha:1.0]];
                     }
                     completion:^(BOOL finished) {
                         [_blackLabel1 setHidden:NO];
                         [_favImg setHidden:NO];
                     }];
    [UIView commitAnimations];
    
    [UIView animateWithDuration:0.3 delay:0.0 options:0
                     animations:^{
                         [_helpImg1 setFrame:CGRectMake(_helpImg1.frame.origin.x+110, _helpImg1.frame.origin.y, _helpImg1.frame.size.width, _helpImg1.frame.size.height)];
                     }
                     completion:^(BOOL finished) {
                         [_favImg setImage:[UIImage imageNamed:@"fav-on.png"]];
                         [UIView animateWithDuration:0.3 delay:0.3 options:0
                                          animations:^{
                                              [_helpImg1 setFrame:CGRectMake(_helpImg1.frame.origin.x-110, _helpImg1.frame.origin.y, _helpImg1.frame.size.width, _helpImg1.frame.size.height)];
                                          }
                                          completion:^(BOOL finished) {
                                              [_favImg setImage:[UIImage imageNamed:@"fav-off.png"]];
                                              [self performSelector:@selector(startCellShare) withObject:nil afterDelay:1.0];
                                          }];
                         [UIView commitAnimations];
                     }];
    [UIView commitAnimations];
}

-(void)startCellShare
{
    [_blackLabel1 setHidden:YES];
    [_favImg setHidden:YES];
    
    [UIView animateWithDuration:0.1 delay:0.0 options:0
                     animations:^{
                         [_helpImg2 setAlpha:1.0];
                         [[self.view viewWithTag:4] setAlpha:1.0];
                         
                         [(UILabel*)[self.view viewWithTag:4] setTextColor:[UIColor colorWithRed:248.0/255.0 green:156.0/255.0 blue:37.0/255.0 alpha:1.0]];
                     }
                     completion:^(BOOL finished) {
                         [_blackLabel2 setHidden:NO];
                         [_shareImg setHidden:NO];
                     }];
    [UIView commitAnimations];
    
    [UIView animateWithDuration:0.3 delay:0.0 options:0
                     animations:^{
                         [_helpImg2 setFrame:CGRectMake(_helpImg2.frame.origin.x-110, _helpImg2.frame.origin.y, _helpImg2.frame.size.width, _helpImg2.frame.size.height)];
                     }
                     completion:^(BOOL finished) {
                         [_shareImg setImage:[UIImage imageNamed:@"share-on.png"]];
                         [UIView animateWithDuration:0.3 delay:0.3 options:0
                                          animations:^{
                                              [_helpImg2 setFrame:CGRectMake(_helpImg2.frame.origin.x+110, _helpImg2.frame.origin.y, _helpImg2.frame.size.width, _helpImg2.frame.size.height)];
                                          }
                                          completion:^(BOOL finished) {
                                              [_shareImg setImage:[UIImage imageNamed:@"share-off.png"]];
                                              [self performSelector:@selector(startCellZoom) withObject:nil afterDelay:1.0];
                                          }];
                         [UIView commitAnimations];
                     }];
    [UIView commitAnimations];
}

-(void)startCellZoom
{
    [_blackLabel1 setHidden:YES];
    [_favImg setHidden:YES];
    
    [_blackLabel2 setHidden:YES];
    [_shareImg setHidden:YES];
    
    [UIView animateWithDuration:0.1 delay:0.0 options:0
                     animations:^{
                         [_helpImg3 setAlpha:1.0];
                         [[self.view viewWithTag:6] setAlpha:1.0];
                         
                         [(UILabel*)[self.view viewWithTag:6] setTextColor:[UIColor colorWithRed:248.0/255.0 green:156.0/255.0 blue:37.0/255.0 alpha:1.0]];
                     }
                     completion:^(BOOL finished) {
                         [self performSelector:@selector(zoomAnm1) withObject:nil afterDelay:0.3];
                     }];
    [UIView commitAnimations];
}

-(void)zoomAnm1
{
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionTransitionCrossDissolve
                     animations:^{
                         _helpImg3.image = [UIImage imageNamed:@"help-cell-highlighted.png"];
                     }
                     completion:^(BOOL finished) {
                         [self performSelector:@selector(zoomAnm2) withObject:nil afterDelay:1.0];
                     }];
    [UIView commitAnimations];
}

-(void)zoomAnm2
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationTransition:(UIViewAnimationTransitionFlipFromRight)
                           forView:_helpImg3 cache:YES];
    [UIView commitAnimations];
    
    _helpImg3.image = [UIImage imageNamed:@"help-cell-image.png"];
    
    [self performSelector:@selector(endAll) withObject:nil afterDelay:1.5];
}

-(void)endAll
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationTransition:(UIViewAnimationTransitionFlipFromLeft)
                           forView:_helpImg3 cache:YES];
    [UIView commitAnimations];
    
    [UIView animateWithDuration:1.0 delay:0.0 options:0
                     animations:^{
                         [_blackLabel1 setHidden:NO];
                         [_favImg setHidden:NO];
                         
                         [_blackLabel2 setHidden:NO];
                         [_shareImg setHidden:NO];
                         
                         [_helpImg1 setFrame:CGRectMake(_helpImg1.frame.origin.x+110, _helpImg1.frame.origin.y, _helpImg1.frame.size.width, _helpImg1.frame.size.height)];
                         [_helpImg2 setFrame:CGRectMake(_helpImg2.frame.origin.x-110, _helpImg2.frame.origin.y, _helpImg2.frame.size.width, _helpImg2.frame.size.height)];
                     }
                     completion:^(BOOL finished) {
                         [_favImg setImage:[UIImage imageNamed:@"fav-on.png"]];
                         [_shareImg setImage:[UIImage imageNamed:@"share-on.png"]];
                     }];
    [UIView commitAnimations];
    
    _helpImg3.image = [UIImage imageNamed:@"help-cell-sample.png"];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleDefault;
}

- (IBAction)closeHelpView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
