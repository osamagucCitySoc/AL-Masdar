//
//  InfoFeedViewController.h
//  AL-Masdar
//
//  Created by Osama Rabie on 6/25/15.
//  Copyright (c) 2015 Osama Rabie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SADAHMsg.h"
#import "SADAHBlurView.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface customCell : UITableViewCell
@end

@interface InfoFeedViewController : UIViewController <UIGestureRecognizerDelegate,MFMailComposeViewControllerDelegate>
{
    UIRefreshControl *refreshControl;
    BOOL tableIsReady,isRemoveAct,isOptions,isFullScreen,isScrollButton,isOnNews,isRectResume,isFromNight,isNoResume,isShowStatus,isSearching,isSearchMsg,isTap,isFirstDrag,isAfterSearch,isSearchYet,isFromRefresh,isOnBreakingNews,isReloaded,isFromSwipe,isFromBreaking,isInfoDone;
    UITapGestureRecognizer *tap,*dbTap;
    CGRect prevFrame;
    UIImage *imgToSave;
    NSInteger indVal,countToEnd,theSavedCount;
    UIBackgroundTaskIdentifier bgTask;
    CGRect resumeRect,favRect,newsRect,breakingRect;
    float imageZoomScale;
    CGPoint scrollSavedPoint;
    UITableViewCell *cellToClose;
}

@property (strong, nonatomic) IBOutlet UIView *viewToClose;
@property (strong, nonatomic) IBOutlet UIImageView *imageToClose;
@property (strong, nonatomic) IBOutlet UIImageView *anmImg;
@property (strong, nonatomic) IBOutlet UIButton *darkBackButton;
@property (strong, nonatomic) IBOutlet UINavigationBar *optionsNavBar;
@property (strong, nonatomic) IBOutlet UIScrollView *imageScrollView;
@property (strong, nonatomic) IBOutlet UINavigationItem *topTitle;
@property (strong, nonatomic) IBOutlet UIView *newsMainView;
@property (strong, nonatomic) IBOutlet UINavigationBar *searchNavBar;
@property (strong, nonatomic) IBOutlet UIView *shareView;
@property (strong, nonatomic) IBOutlet UILabel *shareLabel1;
@property (strong, nonatomic) IBOutlet UILabel *shareLabel2;
@property (strong, nonatomic) IBOutlet UILabel *shareLabel3;
@property (strong, nonatomic) IBOutlet UILabel *shareLabel4;
@property (strong, nonatomic) IBOutlet UIButton *shareCancelButton;

@end
