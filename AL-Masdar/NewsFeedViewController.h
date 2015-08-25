//
//  NewsFeedViewController.h
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
#import <AVFoundation/AVFoundation.h>
#import <GoogleMobileAds/GoogleMobileAds.h>
#import <MMAdSDK/MMAdSDK.h>

@interface customCell : UITableViewCell
@end

@interface NewsFeedViewController : UIViewController <UIGestureRecognizerDelegate,MFMailComposeViewControllerDelegate,AVAudioPlayerDelegate,GADInterstitialDelegate,MMInlineDelegate>
{
    UIRefreshControl *refreshControl;
    BOOL tableIsReady,isRemoveAct,isOptions,isFullScreen,isScrollButton,isOnNews,isRectResume,isFromNight,isNoResume,isShowStatus,isSearching,isSearchMsg,isTap,isFirstDrag,isAfterSearch,isSearchYet,isFromRefresh,isOnBreakingNews,isReloaded,isFromSwipe,isFromBreaking,isCheckBrDone,isLoadComplated,isSettingsBack,isManualNight,isStartSearch;
    UITapGestureRecognizer *tap,*dbTap;
    CGRect prevFrame;
    UIImage *imgToSave;
    NSInteger indVal,countToEnd,theSavedCount,currentPickerRow;
    UIBackgroundTaskIdentifier bgTask;
    CGRect resumeRect,favRect,newsRect,breakingRect;
    float imageZoomScale;
    CGPoint scrollSavedPoint;
    UITableViewCell *cellToClose;
    MMInlineAd *bannerAd;
}

@property (strong, nonatomic) IBOutlet UIScrollView *optionsScrollView;
@property (strong, nonatomic) IBOutlet AVAudioPlayer *player;
@property (strong, nonatomic) IBOutlet UIView *viewToClose;
@property (strong, nonatomic) IBOutlet UIImageView *imageToClose;
@property (strong, nonatomic) IBOutlet UIImageView *anmImg;
@property (strong, nonatomic) IBOutlet UIImageView *newsImg1;
@property (strong, nonatomic) IBOutlet UIImageView *newsImg2;
@property (strong, nonatomic) IBOutlet UIImageView *newsImg3;
@property (strong, nonatomic) IBOutlet UIImageView *newsImg4;
@property (strong, nonatomic) IBOutlet UIView *optionsView;
@property (strong, nonatomic) IBOutlet UIButton *darkBackButton;
@property (strong, nonatomic) IBOutlet UINavigationBar *optionsNavBar;
@property (strong, nonatomic) IBOutlet UIImageView *firstMoreImg;
@property (strong, nonatomic) IBOutlet UIImageView *secMoreImg;
@property (strong, nonatomic) IBOutlet UIButton *timeLineButton;
@property (strong, nonatomic) IBOutlet UIButton *favButton;
@property (strong, nonatomic) IBOutlet UIButton *notifyButton;
@property (strong, nonatomic) IBOutlet UIButton *nightButton;
@property (strong, nonatomic) IBOutlet UIButton *settingsButton;
@property (strong, nonatomic) IBOutlet UIScrollView *imageScrollView;
@property (strong, nonatomic) IBOutlet UINavigationItem *topTitle;
@property (strong, nonatomic) IBOutlet UIImageView *nightImg;
@property (strong, nonatomic) IBOutlet UIView *newsMainView;
@property (strong, nonatomic) IBOutlet UINavigationBar *searchNavBar;
@property (strong, nonatomic) IBOutlet UIImageView *noResultsImg;
@property (strong, nonatomic) IBOutlet UILabel *noResultsLabel;
@property (strong, nonatomic) IBOutlet UIButton *breakingButton;
@property (strong, nonatomic) IBOutlet UIView *shareView;
@property (strong, nonatomic) IBOutlet UILabel *shareLabel1;
@property (strong, nonatomic) IBOutlet UILabel *shareLabel2;
@property (strong, nonatomic) IBOutlet UILabel *shareLabel3;
@property (strong, nonatomic) IBOutlet UILabel *shareLabel4;
@property (strong, nonatomic) IBOutlet UIButton *shareCancelButton;
@property (strong, nonatomic) IBOutlet UIToolbar *searchToolBar;
@property (strong, nonatomic) IBOutlet UIButton *filterButton;
@property (strong, nonatomic) IBOutlet UIView *selectSourceView;
@property (strong, nonatomic) IBOutlet UIButton *darkFilterBack;
@property (strong, nonatomic) IBOutlet UIPickerView *filterPickerView;
@property (strong, nonatomic) IBOutlet UIButton *footballButton;
@property (strong, nonatomic) IBOutlet UILabel *backBlockLabel;
@property (strong, nonatomic) IBOutlet UIView *rateView;
@property (strong, nonatomic) IBOutlet UIImageView *rateImage;
@property (strong, nonatomic) IBOutlet UILabel *rateLabel;
@property (strong, nonatomic) IBOutlet UIButton *rateButton;
@property (strong, nonatomic) IBOutlet UIButton *noRateButton;
@property (strong, nonatomic) IBOutlet UILabel *finalRateLabel;

@end
