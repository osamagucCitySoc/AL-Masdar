//
//  NewsDetailsViewController.h
//  AL-Masdar
//
//  Created by Osama Rabie on 6/25/15.
//  Copyright (c) 2015 Osama Rabie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SADAHSwitch.h"
#import "AFHTTPRequestOperationManager.h"
#import "CRToastManager.h"
#import "CRToast.h"
#import <AVFoundation/AVFoundation.h>
#import "SADAHMsg.h"
#import <Haneke/Haneke.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "SADAHBlurView.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>

@interface NewsDetailsViewController : UIViewController <UIWebViewDelegate,AVSpeechSynthesizerDelegate,UIGestureRecognizerDelegate,UIScrollViewDelegate,UIActionSheetDelegate,MFMailComposeViewControllerDelegate,AVAudioPlayerDelegate>
{
    BOOL isFristLoad,isVideo,isAnimation,isFirstOneDone,isWebOnly,isFromZoom,isVideoDone,isImageDone,isImage,isFirstDrag,isTap,isFullScreen,isShowStatus;
    UIImage *firstImg,*imgToSave;
    CGRect oldVideoRect,prevFrame;
    UITapGestureRecognizer *tap,*dbTap;
    CGPoint scrollSavedPoint;
    NSInteger numberOfImages;
}

@property (strong, nonatomic) IBOutlet AVAudioPlayer *player;
@property (readwrite, nonatomic, copy) NSString *utteranceString;
@property (readwrite, nonatomic, strong) AVSpeechSynthesizer *speechSynthesizer;
@property(nonatomic,strong)UIImage* image;
@property(nonatomic,strong)NSString* url;
@property(nonatomic,strong)NSString* defUrl;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *actView;
@property (strong, nonatomic) IBOutlet SADAHSwitch *theSwitch;
@property (strong, nonatomic) IBOutlet UILabel *actBackLabel;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UINavigationBar *topBar;
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (strong, nonatomic) IBOutlet UIToolbar *toolBar;
@property (strong, nonatomic) IBOutlet UILabel *topLabel;
@property (strong, nonatomic) IBOutlet UIScrollView *imagesScroll;
@property (strong, nonatomic) IBOutlet UIScrollView *videosScroll;
@property (strong, nonatomic) IBOutlet UITextView *titleTextView;
@property (strong, nonatomic) IBOutlet UILabel *closeLabel;
@property (strong, nonatomic) IBOutlet UIProgressView *closeProgressView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *zoomNextButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *previousButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *listenButton;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;
@property (strong, nonatomic) IBOutlet UIView *shareView;
@property (strong, nonatomic) IBOutlet UILabel *shareLabel1;
@property (strong, nonatomic) IBOutlet UILabel *shareLabel2;
@property (strong, nonatomic) IBOutlet UILabel *shareLabel3;
@property (strong, nonatomic) IBOutlet UILabel *shareLabel4;
@property (strong, nonatomic) IBOutlet UIButton *shareCancelButton;

@end
