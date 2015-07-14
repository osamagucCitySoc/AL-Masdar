//
//  SADAHMsg.h
//  SADAHMsg
//
//  Created by Housein Jouhar on 31/05/15.
//  Copyright (c) 2015 SADAH Software Solutions. All rights reserved.
//

#import "SADAHMsg.h"

//typedef void(^ActionBlock)(BOOL);

@implementation SADAHMsg

ActionBlock _actionBlock;

+(void)showMsgWithTitle:(NSString*)theTitle andMsg:(NSString*)theMsg inView:(UIView*)theView withCase:(NSInteger)theCase withBlock:(ActionBlock)completion
{
    UIView *backView = [[UIView alloc] initWithFrame:theView.frame];
    
    [backView setAlpha:0.0];
    [theView addSubview:backView];
    
    UIView *contanerView = [[UIView alloc] initWithFrame:CGRectMake(0, backView.frame.size.height-84, backView.frame.size.width, 84)];
    
    [contanerView setTag:2342];
    
    [contanerView setBackgroundColor:[UIColor colorWithRed:20.0/255.0 green:20.0/255.0 blue:20.0/255.0 alpha:1.0]];
    
    [backView addSubview:contanerView];
    
    UIImageView *rateImg = [[UIImageView alloc] initWithFrame:CGRectMake(contanerView.frame.size.width-48, 0, 48, 84)];
    
    if (theCase == 1)
    {
        [rateImg setImage:[UIImage imageNamed:@"tips-icon.png"]];
        backView.backgroundColor = [UIColor colorWithRed:41.0/255 green:136.0/255 blue:160.0/255 alpha:0.3];
    }
    else if (theCase == 2)
    {
        [rateImg setImage:[UIImage imageNamed:@"error-icon.png"]];
        backView.backgroundColor = [UIColor colorWithRed:159.0/255 green:30.0/255 blue:37.0/255 alpha:0.3];
    }
    
    [contanerView addSubview:rateImg];
    
    float labelWidth = contanerView.frame.size.width-98;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(contanerView.frame.size.width -(labelWidth+53), 3, labelWidth, 31)];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [titleLabel setTextAlignment:NSTextAlignmentRight];
    [titleLabel setTextColor:[UIColor whiteColor]];
    
    [titleLabel setText:theTitle];
    
    [contanerView addSubview:titleLabel];
    
    UILabel *msgLabel = [[UILabel alloc] initWithFrame:CGRectMake(contanerView.frame.size.width -(labelWidth+53), contanerView.frame.size.height-50, labelWidth, 45)];
    [msgLabel setFont:[UIFont systemFontOfSize:16]];
    [msgLabel setTextAlignment:NSTextAlignmentRight];
    [msgLabel setNumberOfLines:2];
    [msgLabel setTextColor:[UIColor whiteColor]];
    
    [msgLabel setText:theMsg];
    
    [contanerView addSubview:msgLabel];
    
    _actionBlock = completion;
    
    UIButton *fullCloseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [fullCloseButton setTag:3333];
    [fullCloseButton setBackgroundColor:[UIColor clearColor]];
    [fullCloseButton addTarget:self action:@selector(closeMsgView:) forControlEvents:UIControlEventTouchUpInside];
    [fullCloseButton setTitle:@"" forState:UIControlStateNormal];
    fullCloseButton.frame = CGRectMake(0, 0, backView.frame.size.width, backView.frame.size.height-contanerView.frame.size.height);
    [backView addSubview:fullCloseButton];
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton setTag:3334];
    [closeButton setBackgroundColor:[UIColor clearColor]];
    [closeButton addTarget:self action:@selector(closeMsgView:) forControlEvents:UIControlEventTouchUpInside];
    [closeButton setTitle:@"" forState:UIControlStateNormal];
    [closeButton setImage:[UIImage imageNamed:@"close-img.png"] forState:UIControlStateNormal];
    [closeButton setFrame:CGRectMake(0, 0, 48, 84)];
    [contanerView addSubview:closeButton];
    
    [contanerView setFrame:CGRectMake(contanerView.frame.origin.x, contanerView.frame.origin.y + contanerView.frame.size.height, contanerView.frame.size.width, contanerView.frame.size.height)];
    
    [UIView animateWithDuration:0.2 delay:0.0 options:0
                     animations:^{
                         [backView setAlpha:1.0];
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.2 delay:0.0 options:0
                                          animations:^{
                                              [contanerView setFrame:CGRectMake(contanerView.frame.origin.x, contanerView.frame.origin.y-contanerView.frame.size.height, contanerView.frame.size.width, contanerView.frame.size.height)];
                                          }
                                          completion:^(BOOL finished) {
                                              
                                          }];
                         
                         [UIView commitAnimations];
                     }];
    
    [UIView commitAnimations];
}

+(void)showMsgWithTitle:(NSString*)theTitle andMsg:(NSString*)theMsg inView:(UIView*)theView withCase:(NSInteger)theCase
{
    UIView *backView = [[UIView alloc] initWithFrame:theView.frame];
    
    [backView setAlpha:0.0];
    
    [theView addSubview:backView];
    
    UIView *contanerView = [[UIView alloc] initWithFrame:CGRectMake(0, backView.frame.size.height-84, backView.frame.size.width, 84)];
    
    [contanerView setTag:2342];
    
    [contanerView setBackgroundColor:[UIColor colorWithRed:20.0/255.0 green:20.0/255.0 blue:20.0/255.0 alpha:1.0]];
    
    [backView addSubview:contanerView];
    
    UIImageView *rateImg = [[UIImageView alloc] initWithFrame:CGRectMake(contanerView.frame.size.width-48, 0, 48, 84)];
    
    if (theCase == 1)
    {
        [rateImg setImage:[UIImage imageNamed:@"tips-icon.png"]];
        backView.backgroundColor = [UIColor colorWithRed:41.0/255 green:136.0/255 blue:160.0/255 alpha:0.3];
    }
    else if (theCase == 2)
    {
        [rateImg setImage:[UIImage imageNamed:@"error-icon.png"]];
        backView.backgroundColor = [UIColor colorWithRed:159.0/255 green:30.0/255 blue:37.0/255 alpha:0.3];
    }
    
    [contanerView addSubview:rateImg];
    
    float labelWidth = contanerView.frame.size.width-98;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(contanerView.frame.size.width -(labelWidth+53), 3, labelWidth, 31)];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [titleLabel setTextAlignment:NSTextAlignmentRight];
    [titleLabel setTextColor:[UIColor whiteColor]];
    
    [titleLabel setText:theTitle];
    
    [contanerView addSubview:titleLabel];
    
    UILabel *msgLabel = [[UILabel alloc] initWithFrame:CGRectMake(contanerView.frame.size.width -(labelWidth+53), contanerView.frame.size.height-50, labelWidth, 45)];
    [msgLabel setFont:[UIFont systemFontOfSize:16]];
    [msgLabel setTextAlignment:NSTextAlignmentRight];
    [msgLabel setNumberOfLines:2];
    [msgLabel setTextColor:[UIColor whiteColor]];
    
    [msgLabel setText:theMsg];
    
    [contanerView addSubview:msgLabel];
    
    UIButton *fullCloseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [fullCloseButton setTag:333];
    [fullCloseButton setBackgroundColor:[UIColor clearColor]];
    [fullCloseButton addTarget:self action:@selector(closeMsgView:) forControlEvents:UIControlEventTouchUpInside];
    [fullCloseButton setTitle:@"" forState:UIControlStateNormal];
    fullCloseButton.frame = CGRectMake(0, 0, backView.frame.size.width, backView.frame.size.height-contanerView.frame.size.height);
    [backView addSubview:fullCloseButton];
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton setBackgroundColor:[UIColor clearColor]];
    [closeButton addTarget:self action:@selector(closeMsgView:) forControlEvents:UIControlEventTouchUpInside];
    [closeButton setTitle:@"" forState:UIControlStateNormal];
    [closeButton setImage:[UIImage imageNamed:@"close-img.png"] forState:UIControlStateNormal];
    [closeButton setFrame:CGRectMake(0, 0, 48, 84)];
    [contanerView addSubview:closeButton];
    
    [contanerView setFrame:CGRectMake(contanerView.frame.origin.x, contanerView.frame.origin.y + contanerView.frame.size.height, contanerView.frame.size.width, contanerView.frame.size.height)];
    
    [UIView animateWithDuration:0.2 delay:0.0 options:0
                     animations:^{
                         [backView setAlpha:1.0];
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.2 delay:0.0 options:0
                                          animations:^{
                                              [contanerView setFrame:CGRectMake(contanerView.frame.origin.x, contanerView.frame.origin.y-contanerView.frame.size.height, contanerView.frame.size.width, contanerView.frame.size.height)];
                                          }
                                          completion:^(BOOL finished) {
                                              
                                          }];
                         
                         [UIView commitAnimations];
                     }];
    
    [UIView commitAnimations];
}

+(void)showDoneMsgWithTitle:(NSString*)theTitle andMsg:(NSString*)theMsg inView:(UIView*)theView
{
    UIView *backView = [[UIView alloc] initWithFrame:theView.frame];
    
    [backView setAlpha:0.0];
    
    [theView addSubview:backView];
    
    UIView *contanerView = [[UIView alloc] initWithFrame:CGRectMake(0, backView.frame.size.height-84, backView.frame.size.width, 84)];
    
    [contanerView setTag:2342];
    
    [contanerView setBackgroundColor:[UIColor colorWithRed:20.0/255.0 green:20.0/255.0 blue:20.0/255.0 alpha:1.0]];
    
    [backView addSubview:contanerView];
    
    UIImageView *rateImg = [[UIImageView alloc] initWithFrame:CGRectMake(contanerView.frame.size.width-48, 0, 48, 84)];
    
    [rateImg setImage:[UIImage imageNamed:@"done-icon.png"]];
    backView.backgroundColor = [UIColor colorWithRed:48.0/255 green:176.0/255 blue:96.0/255 alpha:0.3];
    
    [contanerView addSubview:rateImg];
    
    float labelWidth = contanerView.frame.size.width-98;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(contanerView.frame.size.width -(labelWidth+53), 3, labelWidth, 31)];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [titleLabel setTextAlignment:NSTextAlignmentRight];
    [titleLabel setTextColor:[UIColor whiteColor]];
    
    [titleLabel setText:theTitle];
    
    [contanerView addSubview:titleLabel];
    
    UILabel *msgLabel = [[UILabel alloc] initWithFrame:CGRectMake(contanerView.frame.size.width -(labelWidth+53), contanerView.frame.size.height-50, labelWidth, 45)];
    [msgLabel setFont:[UIFont systemFontOfSize:16]];
    [msgLabel setTextAlignment:NSTextAlignmentRight];
    [msgLabel setNumberOfLines:2];
    [msgLabel setTextColor:[UIColor whiteColor]];
    
    [msgLabel setText:theMsg];
    
    [contanerView addSubview:msgLabel];
    
    UIButton *fullCloseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [fullCloseButton setTag:333];
    [fullCloseButton setBackgroundColor:[UIColor clearColor]];
    [fullCloseButton addTarget:self action:@selector(closeMsgView:) forControlEvents:UIControlEventTouchUpInside];
    [fullCloseButton setTitle:@"" forState:UIControlStateNormal];
    fullCloseButton.frame = CGRectMake(0, 0, backView.frame.size.width, backView.frame.size.height-contanerView.frame.size.height);
    [backView addSubview:fullCloseButton];
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton setBackgroundColor:[UIColor clearColor]];
    [closeButton addTarget:self action:@selector(closeMsgView:) forControlEvents:UIControlEventTouchUpInside];
    [closeButton setTitle:@"" forState:UIControlStateNormal];
    [closeButton setImage:[UIImage imageNamed:@"close-img.png"] forState:UIControlStateNormal];
    [closeButton setFrame:CGRectMake(0, 0, 48, 84)];
    [contanerView addSubview:closeButton];
    
    [contanerView setFrame:CGRectMake(contanerView.frame.origin.x, contanerView.frame.origin.y + contanerView.frame.size.height, contanerView.frame.size.width, contanerView.frame.size.height)];
    
    [UIView animateWithDuration:0.2 delay:0.0 options:0
                     animations:^{
                         [backView setAlpha:1.0];
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.2 delay:0.0 options:0
                                          animations:^{
                                              [contanerView setFrame:CGRectMake(contanerView.frame.origin.x, contanerView.frame.origin.y-contanerView.frame.size.height, contanerView.frame.size.width, contanerView.frame.size.height)];
                                          }
                                          completion:^(BOOL finished) {
                                              
                                              [NSTimer scheduledTimerWithTimeInterval: 2.0
                                                                               target: self
                                                                             selector:@selector(closeDoneView:)
                                                                             userInfo: nil repeats:NO];
                                          }];
                         
                         [UIView commitAnimations];
                     }];
    
    [UIView commitAnimations];
}

+(void)closeDoneView:(NSTimer *)timer
{
    UIView *viewToClose = [[[UIApplication sharedApplication] keyWindow] viewWithTag:2342];
    [UIView animateWithDuration:0.2 delay:0.0 options:0
                     animations:^{
                         [[viewToClose superview] setBackgroundColor:[UIColor clearColor]];
                         [viewToClose setFrame:CGRectMake(viewToClose.frame.origin.x, viewToClose.frame.origin.y + viewToClose.frame.size.height, viewToClose.frame.size.width, viewToClose.frame.size.height)];
                         
                     }
                     completion:^(BOOL finished) {
                         [[viewToClose superview] removeFromSuperview];
                     }];
    
    [UIView commitAnimations];
}

+(void)showRateViewIn:(UIView*)theView
{
    UIView *backView = [[UIView alloc] initWithFrame:theView.frame];
    
    backView.backgroundColor = [UIColor colorWithRed:198.0/255 green:170.0/255 blue:18.0/255 alpha:0.3];
    
    [backView setAlpha:0.0];
    
    [theView addSubview:backView];
    
    UIView *contanerView = [[UIView alloc] initWithFrame:CGRectMake(0, backView.frame.size.height-84, backView.frame.size.width, 84)];
    
    [contanerView setBackgroundColor:[UIColor colorWithRed:20.0/255.0 green:20.0/255.0 blue:20.0/255.0 alpha:1.0]];
    
    [backView addSubview:contanerView];
    
    UIImageView *rateImg = [[UIImageView alloc] initWithFrame:CGRectMake(contanerView.frame.size.width-48, 0, 48, 84)];
    
    [rateImg setImage:[UIImage imageNamed:@"rate-icon.png"]];
    
    [contanerView addSubview:rateImg];
    
    UIButton *rateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rateButton setBackgroundColor:[UIColor clearColor]];
    [rateButton addTarget:self action:@selector(rateNow:) forControlEvents:UIControlEventTouchUpInside];
    [rateButton setTitle:@"" forState:UIControlStateNormal];
    rateButton.frame = CGRectMake(0, 0, contanerView.frame.size.width, contanerView.frame.size.height);
    [contanerView addSubview:rateButton];
    
    float labelWidth = contanerView.frame.size.width-95;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(contanerView.frame.size.width -(labelWidth+53), 3, labelWidth, 31)];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [titleLabel setTextAlignment:NSTextAlignmentRight];
    [titleLabel setTextColor:[UIColor whiteColor]];
    
    [titleLabel setText:@"تقييم التطبيق"];
    
    [contanerView addSubview:titleLabel];
    
    UILabel *msgLabel = [[UILabel alloc] initWithFrame:CGRectMake(contanerView.frame.size.width -(labelWidth+53), contanerView.frame.size.height-50, labelWidth, 45)];
    [msgLabel setFont:[UIFont systemFontOfSize:16]];
    [msgLabel setTextAlignment:NSTextAlignmentRight];
    [msgLabel setNumberOfLines:2];
    [msgLabel setTextColor:[UIColor whiteColor]];
    
    [msgLabel setText:@"لو أعجبك التطبيق هل باللإمكان تقييمه في متجر البرامج لأن ذلك يساعدنا كثيراً."];
    
    [contanerView addSubview:msgLabel];
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton setBackgroundColor:[UIColor clearColor]];
    [closeButton addTarget:self action:@selector(closeMsgView:) forControlEvents:UIControlEventTouchUpInside];
    [closeButton setTitle:@"" forState:UIControlStateNormal];
    [closeButton setImage:[UIImage imageNamed:@"close-img.png"] forState:UIControlStateNormal];
    [closeButton setFrame:CGRectMake(0, 0, 48, 84)];
    [contanerView addSubview:closeButton];
    
    [contanerView setFrame:CGRectMake(contanerView.frame.origin.x, contanerView.frame.origin.y + contanerView.frame.size.height, contanerView.frame.size.width, contanerView.frame.size.height)];
    
    [UIView animateWithDuration:0.2 delay:0.0 options:0
                     animations:^{
                         [backView setAlpha:1.0];
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.2 delay:0.0 options:0
                                          animations:^{
                                              [contanerView setFrame:CGRectMake(contanerView.frame.origin.x, contanerView.frame.origin.y-contanerView.frame.size.height, contanerView.frame.size.width, contanerView.frame.size.height)];
                                          }
                                          completion:^(BOOL finished) {
                                              
                                          }];
                         
                         [UIView commitAnimations];
                     }];
    
    [UIView commitAnimations];
}

+(void)rateNow:(id)sender
{
    [UIView animateWithDuration:0.2 delay:0.0 options:0
                     animations:^{
                         [[[sender superview] superview] setBackgroundColor:[UIColor clearColor]];
                         [[sender superview] setFrame:CGRectMake([sender superview].frame.origin.x, [sender superview].frame.origin.y + [sender superview].frame.size.height, [sender superview].frame.size.width, [sender superview].frame.size.height)];
                         
                     }
                     completion:^(BOOL finished) {
                         [[[sender superview] superview] removeFromSuperview];
                         [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=1015326285&onlyLatestVersion=false&type=Purple+Software"]];
                     }];
    
    [UIView commitAnimations];
}

+(void)closeMsgView:(id)sender
{
    if ([sender tag] == 3333)
    {
        [UIView animateWithDuration:0.2 delay:0.0 options:0
                         animations:^{
                             [[sender superview] setBackgroundColor:[UIColor clearColor]];
                             [[[sender superview] viewWithTag:2342] setFrame:CGRectMake([[sender superview] viewWithTag:2342].frame.origin.x, [[sender superview] viewWithTag:2342].frame.origin.y + [[sender superview] viewWithTag:2342].frame.size.height, [[sender superview] viewWithTag:2342].frame.size.width, [[sender superview] viewWithTag:2342].frame.size.height)];
                             
                         }
                         completion:^(BOOL finished) {
                             [[sender superview] removeFromSuperview];
                             _actionBlock(YES);
                         }];
        
        [UIView commitAnimations];
    }
    else if ([sender tag] == 3334)
    {
        [UIView animateWithDuration:0.2 delay:0.0 options:0
                         animations:^{
                             [[[sender superview] superview] setBackgroundColor:[UIColor clearColor]];
                             [[sender superview] setFrame:CGRectMake([sender superview].frame.origin.x, [sender superview].frame.origin.y + [sender superview].frame.size.height, [sender superview].frame.size.width, [sender superview].frame.size.height)];
                             
                         }
                         completion:^(BOOL finished) {
                             [[[sender superview] superview] removeFromSuperview];
                             _actionBlock(YES);
                         }];
        
        [UIView commitAnimations];
    }
    else if ([sender tag] == 333)
    {
        [UIView animateWithDuration:0.2 delay:0.0 options:0
                         animations:^{
                             [[sender superview] setBackgroundColor:[UIColor clearColor]];
                             [[[sender superview] viewWithTag:2342] setFrame:CGRectMake([[sender superview] viewWithTag:2342].frame.origin.x, [[sender superview] viewWithTag:2342].frame.origin.y + [[sender superview] viewWithTag:2342].frame.size.height, [[sender superview] viewWithTag:2342].frame.size.width, [[sender superview] viewWithTag:2342].frame.size.height)];
                             
                         }
                         completion:^(BOOL finished) {
                             [[sender superview] removeFromSuperview];
                         }];
        
        [UIView commitAnimations];
    }
    else
    {
        [UIView animateWithDuration:0.2 delay:0.0 options:0
                         animations:^{
                             [[[sender superview] superview] setBackgroundColor:[UIColor clearColor]];
                             [[sender superview] setFrame:CGRectMake([sender superview].frame.origin.x, [sender superview].frame.origin.y + [sender superview].frame.size.height, [sender superview].frame.size.width, [sender superview].frame.size.height)];
                             
                         }
                         completion:^(BOOL finished) {
                             [[[sender superview] superview] removeFromSuperview];
                         }];
        
        [UIView commitAnimations];
    }
}

@end
