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
    __weak IBOutlet UITextView *textView;
    __weak IBOutlet UIImageView *imageView;
    NSMutableArray* images;
    NSMutableArray* videos;
    NSString* imageURL;
    NSString* videosURL;
    BOOL youtube;
    __weak IBOutlet UIWebView *webView;
}

static NSString * BCP47LanguageCodeFromISO681LanguageCode(NSString *ISO681LanguageCode) {
    if ([ISO681LanguageCode isEqualToString:@"ar"]) {
        return @"ar-SA";
    } else if ([ISO681LanguageCode hasPrefix:@"cs"]) {
        return @"cs-CZ";
    } else if ([ISO681LanguageCode hasPrefix:@"da"]) {
        return @"da-DK";
    } else if ([ISO681LanguageCode hasPrefix:@"de"]) {
        return @"de-DE";
    } else if ([ISO681LanguageCode hasPrefix:@"el"]) {
        return @"el-GR";
    } else if ([ISO681LanguageCode hasPrefix:@"en"]) {
        return @"en-US"; // en-AU, en-GB, en-IE, en-ZA
    } else if ([ISO681LanguageCode hasPrefix:@"es"]) {
        return @"es-ES"; // es-MX
    } else if ([ISO681LanguageCode hasPrefix:@"fi"]) {
        return @"fi-FI";
    } else if ([ISO681LanguageCode hasPrefix:@"fr"]) {
        return @"fr-FR"; // fr-CA
    } else if ([ISO681LanguageCode hasPrefix:@"hi"]) {
        return @"hi-IN";
    } else if ([ISO681LanguageCode hasPrefix:@"hu"]) {
        return @"hu-HU";
    } else if ([ISO681LanguageCode hasPrefix:@"id"]) {
        return @"id-ID";
    } else if ([ISO681LanguageCode hasPrefix:@"it"]) {
        return @"it-IT";
    } else if ([ISO681LanguageCode hasPrefix:@"ja"]) {
        return @"ja-JP";
    } else if ([ISO681LanguageCode hasPrefix:@"ko"]) {
        return @"ko-KR";
    } else if ([ISO681LanguageCode hasPrefix:@"nl"]) {
        return @"nl-NL"; // nl-BE
    } else if ([ISO681LanguageCode hasPrefix:@"no"]) {
        return @"no-NO";
    } else if ([ISO681LanguageCode hasPrefix:@"pl"]) {
        return @"pl-PL";
    } else if ([ISO681LanguageCode hasPrefix:@"pt"]) {
        return @"pt-BR"; // pt-PT
    } else if ([ISO681LanguageCode hasPrefix:@"ro"]) {
        return @"ro-RO";
    } else if ([ISO681LanguageCode hasPrefix:@"ru"]) {
        return @"ru-RU";
    } else if ([ISO681LanguageCode hasPrefix:@"sk"]) {
        return @"sk-SK";
    } else if ([ISO681LanguageCode hasPrefix:@"sv"]) {
        return @"sv-SE";
    } else if ([ISO681LanguageCode hasPrefix:@"th"]) {
        return @"th-TH";
    } else if ([ISO681LanguageCode hasPrefix:@"tr"]) {
        return @"tr-TR";
    } else if ([ISO681LanguageCode hasPrefix:@"zh"]) {
        return @"zh-CN"; // zh-HK, zh-TW
    } else {
        return nil;
    }
}

static NSString * BCP47LanguageCodeForString(NSString *string) {
    NSString *ISO681LanguageCode = (__bridge NSString *)CFStringTokenizerCopyBestStringLanguage((__bridge CFStringRef)string, CFRangeMake(0, [string length]));
    return BCP47LanguageCodeFromISO681LanguageCode(ISO681LanguageCode);
}

@synthesize url,defUrl;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isReadability"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self playSound:@"Empty"];
    
    isShowStatus = YES;
    
    if (self.speechSynthesizer == nil)
    {
        self.speechSynthesizer = [[AVSpeechSynthesizer alloc] init];
        self.speechSynthesizer.delegate = self;
    }
    
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageFullScreen:)];
    tap.delegate = self;
    
    [_imagesScroll addGestureRecognizer:tap];
    
    dbTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    [dbTap setNumberOfTapsRequired:2];
    dbTap.delegate = self;
    
    [_imagesScroll addGestureRecognizer:dbTap];
    
    [_scrollView setHidden:YES];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isReadability"])
    {
        [webView setHidden:YES];
    }
    else
    {
        [webView setHidden:NO];
    }
    
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"theFontSize"] == 0)
    {
        [[NSUserDefaults standardUserDefaults] setInteger:22 forKey:@"theFontSize"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [_titleTextView setFont:[UIFont fontWithName:@"DroidArabicKufi-Bold" size:[[NSUserDefaults standardUserDefaults] integerForKey:@"theFontSize"]]];
    [textView setFont:[UIFont fontWithName:@"DroidArabicKufi" size:[[NSUserDefaults standardUserDefaults] integerForKey:@"theFontSize"]]];
    
    [_theSwitch setOn:[[NSUserDefaults standardUserDefaults] boolForKey:@"isReadability"]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoStarted:) name:UIWindowDidBecomeVisibleNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoFinished:) name:UIWindowDidBecomeHiddenNotification object:nil];
    
    [webView setDelegate:self];
    
    self.defUrl = [self.url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [self performSelector:@selector(reloadWebPage) withObject:nil afterDelay:0.1];
}

-(void)addCommentsBadge
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSDictionary *params = @{@"id":[[NSUserDefaults standardUserDefaults] objectForKey:@"commentsId"]};
    
    [manager POST:@"http://almasdarapp.com/almasdar/getComments.php" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSMutableArray *dataArr = [[NSMutableArray alloc]initWithArray:[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil]];
        
        if (dataArr.count > 0)
        {
            [[self.view viewWithTag:283] removeFromSuperview];
            
            UILabel *badgeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
            
            [badgeLabel setTag:283];
            
            [badgeLabel setFont:[UIFont fontWithName:@"DroidArabicKufi" size:13]];
            
            [badgeLabel setTextAlignment:NSTextAlignmentCenter];
            
            badgeLabel.text = [@"" stringByAppendingFormat:@"%lu",(unsigned long)dataArr.count];
            
            [badgeLabel sizeToFit];
            
            [badgeLabel setTextColor:[UIColor whiteColor]];
            
            [badgeLabel setBackgroundColor:[UIColor colorWithRed:204.0/255.0 green:69.0/255.0 blue:54.0/255.0 alpha:1.0]];
            
            [self.view addSubview:badgeLabel];
            
            badgeLabel.center = _toolBar.center;
            
            [badgeLabel setClipsToBounds:YES];
            
            [badgeLabel.layer setCornerRadius:badgeLabel.frame.size.height/2];
            
            if (badgeLabel.frame.size.width < badgeLabel.frame.size.height)
            {
                [badgeLabel setFrame:CGRectMake(badgeLabel.frame.origin.x+62, badgeLabel.frame.origin.y-22, badgeLabel.frame.size.height, badgeLabel.frame.size.height)];
            }
            else
            {
                [badgeLabel setFrame:CGRectMake(badgeLabel.frame.origin.x+62, badgeLabel.frame.origin.y-22, badgeLabel.frame.size.width+10, badgeLabel.frame.size.height)];
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    }];
}

-(void)showSmartShare
{
    SADAHBlurView *blurView = [[SADAHBlurView alloc] initWithFrame:self.view.frame];
    
    UIView *backView = [[UIView alloc] initWithFrame:self.view.frame];
    
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
    
    [[self view] addSubview:blurView];
    
    [[self view] addSubview:backView];
    
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
    
    [[self view] addSubview:_shareView];
    _shareView.center = [self view].center;
    _shareView.transform = CGAffineTransformMakeScale(-1, 0);
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^(void) {
                         _shareView.transform = CGAffineTransformMakeScale(1, 1);
                         [self playSound:@"swipe"];
                     }
                     completion:nil];
    
    for (UIImageView *imgView in _imagesScroll.subviews)
    {
        if (imgView.tag == 80 + _pageControl.currentPage)
        {
            imgToSave = imgView.image;
            break;
        }
    }
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

-(void)closeSmartShare:(BOOL)isCloseAll
{
    [UIView animateWithDuration:0.3 delay:0.0 options:0
                     animations:^{
                         [[[self view] viewWithTag:732] setAlpha:0.0];
                         [[[self view] viewWithTag:733] setAlpha:0.0];
                         [_shareView setFrame:CGRectMake(_shareView.frame.origin.x, _shareView.frame.origin.y+500, _shareView.frame.size.width, _shareView.frame.size.height)];
                     }
                     completion:^(BOOL finished) {
                         [_shareView removeFromSuperview];
                         [[[self view] viewWithTag:732] removeFromSuperview];
                         [[[self view] viewWithTag:733] removeFromSuperview];
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
    [self performSelector:@selector(openLink:) withObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"theSavedNewsId"] afterDelay:0.3];
    [self closeSmartShare:YES];
}

-(void)openLink:(NSString*)theLink
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[theLink stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
}

-(void)copNews
{
    [[UIPasteboard generalPasteboard] setString:[[[NSUserDefaults standardUserDefaults] objectForKey:@"savedNewsBody"] stringByAppendingFormat:@"%@",@"\n\n#تطبيق_من_المصدر"]];
    [self showStatusBarMsg:@"تم نسخ الخبر بنجاح" isRed:NO];
    [self closeSmartShare:YES];
}

-(void)openShareMore
{
    [self closeSmartShare:NO];
    
    NSArray *sharedObjects;
    
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"imgToShare"]isEqualToString:@""])
    {
        sharedObjects = [NSArray arrayWithObjects:[[NSUserDefaults standardUserDefaults] objectForKey:@"savedNewsTitle"], nil];
    }
    else
    {
        UIImage* sharedImg=imgToSave;
        sharedObjects = [NSArray arrayWithObjects:[[NSUserDefaults standardUserDefaults] objectForKey:@"savedNewsTitle"],sharedImg, nil];
    }
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc]
                                                        initWithActivityItems:sharedObjects applicationActivities:nil];
    activityViewController.popoverPresentationController.sourceView = self.view;
    
    [self presentViewController:activityViewController animated:YES completion:nil];
}

-(void)shareOnInstagram
{
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://app"];
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL])
    {
        NSString *caption = [[[NSUserDefaults standardUserDefaults] objectForKey:@"savedNewsTitle"] stringByAppendingFormat:@"%@",@"\n\n#تطبيق_من_المصدر"];
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
        [SADAHMsg showMsgWithTitle:@"لا يمكن المشاركة" andMsg:@"تأكد أن تطبيق انستغرام موجود على جهازك ثم حاول مرة ثانية." inView:[self view] withCase:2];
    }
}

-(void)shareOnTwitter
{
    if(![SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        [SADAHMsg showMsgWithTitle:@"لا يمكن المشاركة" andMsg:@"تأكد من وجود حساب تويتر واحد على الأقل مفعل في جهازك وذلك من إعدادات الجهاز." inView:[self view] withCase:2];
        return;
    }//[self getShareLinkForId:[news objectForKey:@"id"]]
    
    SLComposeViewController *tweetComposerSheet;
    tweetComposerSheet = [[SLComposeViewController alloc] init]; //initiate the Social Controller
    tweetComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter]; //Tell him with what social plattform to use it, e.g. facebook or twitter
    [tweetComposerSheet setInitialText:[NSString stringWithFormat:@"%@\n\n%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"savedNewsTitle"],@"#تطبيق_من_المصدر"]];
    [tweetComposerSheet addImage:imgToSave];
    [tweetComposerSheet addURL:[NSURL URLWithString:[[[NSUserDefaults standardUserDefaults] objectForKey:@"theSavedNewsId"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    [tweetComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
        [self closeSmartShare:YES];
        switch (result) {
            case SLComposeViewControllerResultCancelled:
                break;
            case SLComposeViewControllerResultDone:
                [SADAHMsg showDoneMsgWithTitle:@"تمت المشاركة" andMsg:@"تمت مشاركة الخبر بنجاح عبر حسابك في تويتر." inView:[self view]];
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
        [SADAHMsg showMsgWithTitle:@"لا يمكن المشاركة" andMsg:@"تأكد من وجود حساب فيس بوك مفعل في جهازك وذلك من إعدادات الجهاز." inView:[self view] withCase:2];
        return;
    }
    SLComposeViewController *faceComposerSheet;
    faceComposerSheet = [[SLComposeViewController alloc] init]; //initiate the Social Controller
    faceComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook]; //Tell him with what social plattform to use it, e.g. facebook or twitter
    [faceComposerSheet setInitialText:[NSString stringWithFormat:@"%@\n\n%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"savedNewsTitle"],@"#تطبيق_من_المصدر"]]; //the message you want to post
    [faceComposerSheet addImage:imgToSave];
    [faceComposerSheet addURL:[NSURL URLWithString:[[[NSUserDefaults standardUserDefaults] objectForKey:@"theSavedNewsId"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    [self presentViewController:faceComposerSheet animated:YES completion:nil];
    
    [faceComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
        [self closeSmartShare:YES];
        switch (result) {
            case SLComposeViewControllerResultCancelled:
                break;
            case SLComposeViewControllerResultDone:
                [SADAHMsg showDoneMsgWithTitle:@"تمت المشاركة" andMsg:@"تمت مشاركة الخبر بنجاح عبر حسابك في فيس بوك." inView:[self view]];
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
        MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
        
        picker.mailComposeDelegate = self;
        
        NSData *imageData = UIImageJPEGRepresentation(imgToSave, 0.5);
        [picker addAttachmentData:imageData mimeType:@"image/jpeg" fileName:[NSString stringWithFormat:@"1.jpg"]];
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0)
        {
            [[picker navigationBar] setTintColor:[UIColor colorWithRed:170.0/255 green:64.0/255 blue:65.0/255 alpha:1]];
        }
        
        [picker setMessageBody:[@"" stringByAppendingFormat:@"%@\n\n%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"savedNewsBody"],@"#تطبيق_من_المصدر"] isHTML:NO];
        
        [self presentViewController:picker animated:YES completion:nil];
    }
    else
    {
        [SADAHMsg showMsgWithTitle:@"لا يمكن المشاركة" andMsg:@"تأكد من وجود حساب بريد الكتروني مفعل في جهازك وذلك من إعدادات الجهاز." inView:[self view] withCase:2];
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


-(void)handleDoubleTap:(UITapGestureRecognizer *)recognizer
{
    isTap = YES;
    UIScrollView *theScrollView = (UIScrollView*)[[self view] viewWithTag:191];
    
    if (theScrollView.zoomScale > 1.0)
    {
        [theScrollView setZoomScale:1.0 animated:YES];
    }
    else
    {
        CGPoint translation = [recognizer locationInView:[[self view] viewWithTag:191]];
        [theScrollView zoomToRect:CGRectMake(translation.x, translation.y, 2.0, 0.0) animated:YES];
    }
}

-(void)imageFullScreen:(UITapGestureRecognizer *)recognizeasdasrs
{
    if (isNoImg)return;
    
    if (!isFullScreen) {
        
        if (isEmptyImg)return;
        for (UIImageView *imgView in _imagesScroll.subviews)
        {
//            NSLog(@"Tag: %ld",(long)imgView.tag);
//            NSLog(@"Page: %ld",(long)_pageControl.currentPage);
//            NSLog(@"All: %ld",(80 + _pageControl.currentPage));
            if (imgView.tag == (80 + _pageControl.currentPage))
            {
                //[imgView setContentMode:UIViewContentModeScaleAspectFit];
                prevFrame = imgView.frame;
                isFirstDrag = YES;
                isTap = NO;
                [imgView setTag:893];
                imgView.clipsToBounds = YES;
                UIScrollView *backgroundView = [[UIScrollView alloc] initWithFrame:imgView.frame];
                [backgroundView addGestureRecognizer:tap];
                [backgroundView addGestureRecognizer:dbTap];
                [backgroundView setBackgroundColor:[UIColor blackColor]];
                [backgroundView addSubview:imgView];
                [backgroundView setTag:191];
                [[self view]addSubview:backgroundView];
                backgroundView.center = _imagesScroll.center;
                imgView.center = backgroundView.center;
                
                [UIView animateWithDuration:0.2 delay:0 options:0 animations:^{
                    
                    [backgroundView setFrame:[self view].frame];
                    [imgView setFrame:backgroundView.frame];
                }completion:^(BOOL finished){
                    isFullScreen = YES;
                    [self hideTheStatusBar];
                }];
                
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
                
                backgroundView.showsHorizontalScrollIndicator = NO;
                backgroundView.showsVerticalScrollIndicator = NO;
                
                imgToSave = imgView.image;
                
                break;
            }
            else if ([_pageControl isHidden])
            {
                //[imgView setContentMode:UIViewContentModeScaleAspectFit];
                prevFrame = imgView.frame;
                isFirstDrag = YES;
                isTap = NO;
                [imgView setTag:893];
                imgView.clipsToBounds = YES;
                UIScrollView *backgroundView = [[UIScrollView alloc] initWithFrame:imgView.frame];
                [backgroundView addGestureRecognizer:tap];
                [backgroundView addGestureRecognizer:dbTap];
                [backgroundView setBackgroundColor:[UIColor blackColor]];
                [backgroundView addSubview:imgView];
                [backgroundView setTag:191];
                [[self view]addSubview:backgroundView];
                backgroundView.center = _imagesScroll.center;
                imgView.center = backgroundView.center;
                
                [UIView animateWithDuration:0.2 delay:0 options:0 animations:^{
                    
                    [backgroundView setFrame:[self view].frame];
                    [imgView setFrame:backgroundView.frame];
                }completion:^(BOOL finished){
                    isFullScreen = YES;
                    [self hideTheStatusBar];
                }];
                
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
                
                backgroundView.showsHorizontalScrollIndicator = NO;
                backgroundView.showsVerticalScrollIndicator = NO;
                
                imgToSave = imgView.image;
                
                break;
            }
        }
        
        return;
    }
    else{
        [self performSelector:@selector(closeFullView) withObject:nil afterDelay:0.5];
        return;
    }
}

-(void)closeFullView
{
    if (isTap)
    {
        isTap = NO;
        return;
    }
    
    if ([(UIScrollView*)[[self view] viewWithTag:191] zoomScale] >= 2.0)
    {
        [(UIScrollView*)[[self view] viewWithTag:191] setZoomScale:1.0 animated:YES];
        return;
    }
    
    [self showTheStatusBar];
    [[[self view] viewWithTag:893] setFrame:CGRectMake([[self view] viewWithTag:893].frame.origin.x, [[self view] viewWithTag:893].frame.origin.y, prevFrame.size.width, prevFrame.size.height)];
    //[(UIImageView*)[[self view] viewWithTag:893] setContentMode:UIViewContentModeScaleAspectFill];
    [[[self view] viewWithTag:191] setBackgroundColor:[UIColor clearColor]];
    [[self view] addSubview:[[self view] viewWithTag:893]];
    [[[self view] viewWithTag:191] removeFromSuperview];
    [UIView animateWithDuration:0.2 delay:0 options:0 animations:^{
        [[[self view] viewWithTag:893] setCenter:CGPointMake(_imagesScroll.center.x, _imagesScroll.center.y+63)];
    }completion:^(BOOL finished){
        isFullScreen = NO;
        [_imagesScroll addSubview:[[self view] viewWithTag:893]];
        [[[self view] viewWithTag:893] setFrame:prevFrame];
        [[[self view] viewWithTag:893] setTag:80+_pageControl.currentPage];
        [_imagesScroll addGestureRecognizer:tap];
    }];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
       shouldReceiveTouch:(UITouch *)touch
{
    if ([[@"" stringByAppendingFormat:@"%@",[gestureRecognizer class]] rangeOfString:@"UIPanGestureRecognizer"].location != NSNotFound)
    {
        if ([(UIScrollView*)[[self view] viewWithTag:191] zoomScale] > 1.0)
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
        scrollSavedPoint = [[self view] viewWithTag:191].center;
    }
    
    CGPoint translation = [recognizer translationInView:[[self view] viewWithTag:191]];
    
    [[self view] viewWithTag:893].center = CGPointMake([[self view] viewWithTag:893].center.x + translation.x,
                                                                              [[self view] viewWithTag:893].center.y + translation.y);
    
    CGFloat theXPoint;
    CGFloat theYPoint;
    
    if (scrollSavedPoint.x > [[self view] viewWithTag:893].center.x)
    {
        theXPoint = scrollSavedPoint.x - [[self view] viewWithTag:893].center.x;
    }
    else
    {
        theXPoint = [[self view] viewWithTag:893].center.x - scrollSavedPoint.x;
    }
    
    if (scrollSavedPoint.y > [[self view] viewWithTag:893].center.y)
    {
        theYPoint = scrollSavedPoint.y - [[self view] viewWithTag:893].center.y;
    }
    else
    {
        theYPoint = [[self view] viewWithTag:893].center.y - scrollSavedPoint.y;
    }
    
    [[[self view] viewWithTag:191] setBackgroundColor:[UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:[self diffToAlpha:theXPoint+theYPoint]]];
    
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
                                 [[self view] viewWithTag:893].center = scrollSavedPoint;
                                 [[[self view] viewWithTag:191] setBackgroundColor:[UIColor blackColor]];
                             }
                             completion:^(BOOL finished) {
                             }];
            [UIView commitAnimations];
        }
    }
    
    
    [recognizer setTranslation:CGPointMake(0, 0) inView:[[self view] viewWithTag:893]];
    
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return [[self view] viewWithTag:893];
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
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex  {
    switch (buttonIndex) {
        case 0:
        {
            if (actionSheet.tag == 14)
            {
                [self performSelector:@selector(saveTheImg) withObject:nil afterDelay:0.5];
            }
        }
    }
}

- (void)savingImage:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error)
    {
        [SADAHMsg showMsgWithTitle:@"لايمكن حفظ الصورة" andMsg:@"تأكد من السماح للتطبيق بالوصول إلى ألبوم الصور من إعدادات جهازك حتى يتمكن من حفظ الصورة." inView:[self view] withCase:2];
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

- (IBAction)startTheSpeech:(id)sender {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"isReadability"] || isWebOnly)return;
    
    if ([self.speechSynthesizer isPaused])
    {
        [self.speechSynthesizer continueSpeaking];
        [_listenButton setImage:[UIImage imageNamed:@"pause-icon.png"]];
    }
    else if ([self.speechSynthesizer isSpeaking])
    {
        [self.speechSynthesizer pauseSpeakingAtBoundary:AVSpeechBoundaryImmediate];
        [_listenButton setImage:[UIImage imageNamed:@"play-icon.png"]];
    }
    else
    {
        [self startSpeech];
        [_listenButton setImage:[UIImage imageNamed:@"pause-icon.png"]];
    }
}

-(void)stopTheSpeech
{
    if ([self.speechSynthesizer isSpeaking])
    {
        [self.speechSynthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
        [_listenButton setImage:nil];
        [_listenButton setTitle:@""];
        [_listenButton setEnabled:NO];
    }
}

- (IBAction)goToNext:(id)sender {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isReadability"] && !isWebOnly)
    {
        NSInteger theFontSize = [[NSUserDefaults standardUserDefaults] integerForKey:@"theFontSize"]+1;
        
        if (theFontSize >= 100)
        {
            return;
        }
        
        [_titleTextView setFont:[UIFont fontWithName:@"DroidArabicKufi-Bold" size:theFontSize]];
        [textView setFont:[UIFont fontWithName:@"DroidArabicKufi" size:theFontSize]];
        [UIView animateWithDuration:0.1 delay:0.0 options:0
                         animations:^{
                             _titleTextView.transform = CGAffineTransformMakeScale(1.1, 1.1);
                             textView.transform = CGAffineTransformMakeScale(1.1, 1.1);
                         }
                         completion:^(BOOL finished) {
                             [UIView animateWithDuration:0.1 delay:0.0 options:0
                                              animations:^{
                                                  _titleTextView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                                                  textView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                                              }
                                              completion:^(BOOL finished) {
                                                  [self stopTheLoading];
                                              }];
                             [UIView commitAnimations];
                         }];
        [UIView commitAnimations];
        
        [[NSUserDefaults standardUserDefaults] setInteger:theFontSize forKey:@"theFontSize"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
    {
        [webView goForward];
    }
}

- (IBAction)goToPrevious:(id)sender {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isReadability"] && !isWebOnly)
    {
        NSInteger theFontSize = [[NSUserDefaults standardUserDefaults] integerForKey:@"theFontSize"]-1;
        
        if (theFontSize <= 7)
        {
            return;
        }
        [_titleTextView setFont:[UIFont fontWithName:@"DroidArabicKufi-Bold" size:theFontSize]];
        [textView setFont:[UIFont fontWithName:@"DroidArabicKufi" size:theFontSize]];
        [UIView animateWithDuration:0.1 delay:0.0 options:0
                         animations:^{
                             _titleTextView.transform = CGAffineTransformMakeScale(0.9, 0.9);
                             textView.transform = CGAffineTransformMakeScale(0.9, 0.9);
                         }
                         completion:^(BOOL finished) {
                             [UIView animateWithDuration:0.1 delay:0.0 options:0
                                              animations:^{
                                                  _titleTextView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                                                  textView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                                              }
                                              completion:^(BOOL finished) {
                                                  [self stopTheLoading];
                                              }];
                             [UIView commitAnimations];
                         }];
        [UIView commitAnimations];
        
        [[NSUserDefaults standardUserDefaults] setInteger:theFontSize forKey:@"theFontSize"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
    {
        [webView goBack];
    }
}

-(void)videoStarted:(NSNotification *)notification{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isLandscapeOn"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isSoundEffects"])
    {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
    
    oldVideoRect = _videosScroll.frame;
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
    [self performSelector:@selector(setVideoFrameBack) withObject:nil afterDelay:0.5];
}

-(void)setVideoFrameBack
{
    [_videosScroll setFrame:oldVideoRect];
}

-(void)reloadWebPage
{
    [_actBackLabel setHidden:NO];
    [self startLoading];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isReadability"] && !isWebOnly)
    {
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"savedNewsBody"] isEqualToString:@""])
        {
            isWebOnly = YES;
            [self stopTheSpeech];
            [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.defUrl] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:60]];
            [_scrollView setHidden:YES];
            
            [webView setHidden:NO];
            
            [_theSwitch setOn:NO];
            
            [_listenButton setImage:nil];
            [_listenButton setTitle:@""];
            [_listenButton setEnabled:NO];
            
            [_commentsButton setImage:nil];
            [_commentsButton setTitle:@""];
            [_commentsButton setEnabled:NO];
            
            [[self.view viewWithTag:283] removeFromSuperview];
            
            [_zoomNextButton setImage:[UIImage imageNamed:@"right-arrow.png"]];
            [_previousButton setImage:[UIImage imageNamed:@"left-arrow.png"]];
            
            [_zoomNextButton setEnabled:NO];
            [_previousButton setEnabled:NO];
        }
        else
        {
            if (isUrlDone)
            {
                [_actView stopAnimating];
                [_actBackLabel setHidden:YES];
                [webView setHidden:YES];
                [_scrollView setHidden:NO];
            }
            else
            {
                images = [[NSMutableArray alloc] init];
                if(self.image)
                {
                    [images addObject:self.image];
                }
                videos = [[NSMutableArray alloc] init];
                
                [webView setHidden:YES];
                
                [_zoomNextButton setImage:[UIImage imageNamed:@"zoom-in-icon.png"]];
                [_previousButton setImage:[UIImage imageNamed:@"zoom-out-icon.png"]];
                
                [_zoomNextButton setEnabled:YES];
                [_previousButton setEnabled:YES];
                
                [_listenButton setEnabled:YES];
                [_listenButton setImage:[UIImage imageNamed:@"listen-icon.png"]];
                
                [_commentsButton setEnabled:YES];
                [_commentsButton setImage:[UIImage imageNamed:@"comment-icon.png"]];
                
                [self addCommentsBadge];
                
                [self openURL];
            }
        }
    }
    else
    {
        [self stopTheSpeech];
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.defUrl] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:60]];
        [_scrollView setHidden:YES];
        
        [webView setHidden:NO];
        
        [_listenButton setImage:nil];
        [_listenButton setTitle:@""];
        [_listenButton setEnabled:NO];
        
        [_commentsButton setImage:nil];
        [_commentsButton setTitle:@""];
        [_commentsButton setEnabled:NO];
        
        [[self.view viewWithTag:283] removeFromSuperview];
        
        [_zoomNextButton setImage:[UIImage imageNamed:@"right-arrow.png"]];
        [_previousButton setImage:[UIImage imageNamed:@"left-arrow.png"]];
        
        [_zoomNextButton setEnabled:NO];
        [_previousButton setEnabled:NO];
    }
}

//-(void)reloadForWeb
//{
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self stopTheSpeech];
//        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.defUrl] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:60]];
//        [_scrollView setHidden:YES];
//        
//        [_zoomNextButton setImage:[UIImage imageNamed:@"right-arrow.png"]];
//        [_previousButton setImage:[UIImage imageNamed:@"left-arrow.png"]];
//        
//        [_zoomNextButton setEnabled:NO];
//        [_previousButton setEnabled:NO];
//    });
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
                                }];
}

-(void)addLoadingImg
{
//    anmImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 83, 83)];
//    
//    anmImage.clipsToBounds = YES;
//    
//    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isNightOn"])
//    {
//        [anmImage setTintColor:[UIColor lightGrayColor]];
//        
//        anmImage.image = [[UIImage imageNamed:@"image-loading-img.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//    }
//    else
//    {
//        [anmImage setTintColor:[UIColor colorWithRed:130.0/255.0 green:130.0/255.0 blue:130.0/255.0 alpha:1.0]];
//        
//        anmImage.image = [[UIImage imageNamed:@"image-loading-img.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//    }
//    
//    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
//    animation.fromValue = [NSNumber numberWithFloat:1.0f];
//    animation.toValue = [NSNumber numberWithFloat: 999];
//    animation.duration = 170.5f;
//    [anmImage.layer addAnimation:animation forKey:@"MyAnimation"];
//    
//    anmImage.center = _imagesScroll.center;
//    [anmImage setFrame:CGRectMake(anmImage.frame.origin.x, anmImage.frame.origin.y+70, 83, 83)];
//    [self.view addSubview:anmImage];
}

-(void)stopLoadingImage
{
//    [anmImage stopAnimating];
//    [anmImage removeFromSuperview];
}

-(void)openURL
{
    isUrlDone = YES;
    youtube = NO;
    
    [self addCurrentImg];
    
    NSString *newsBody = [[NSUserDefaults standardUserDefaults] objectForKey:@"savedNewsBody"];
    
    newsBody = [newsBody stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    newsBody = [newsBody stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    
    NSArray *lines = [newsBody componentsSeparatedByString:@"\n"];
    
    for (NSString *str in lines)
    {
        if (str.length < 40)
        {
            newsBody = [newsBody stringByReplacingOccurrencesOfString:str withString:@""];
        }
        else if ([str hasSuffix:@"."])
        {
            newsBody = [newsBody stringByReplacingOccurrencesOfString:str withString:[str stringByAppendingString:@"\n"]];
        }
    }
    
    if (newsBody.length < 5)
    {
        isWebOnly = YES;
        [self reloadWebPage];
        return;
    }
    
    [_titleTextView setText:[[NSUserDefaults standardUserDefaults] objectForKey:@"savedNewsTitle"]];
    [textView setText:newsBody];
    isTextDone = YES;
    [self addLoadingImg];
    [self stopTheLoading];
    
//    [webView setDelegate:self];
//    
//    [self startLoading];
//    
//    if (!isFristLoad)
//    {
//        isFristLoad = YES;
//        self.url = [self.url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//        videosURL = self.url;
//    }
//    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        NSLog(@"%@",[NSString stringWithFormat:@"%@%@",@"http://expandurl.appspot.com/expand?url=",[self.url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]);
//        NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",@"http://expandurl.appspot.com/expand?url=",self.url]]];
//        
//        NSString* bibloUrl = [NSString stringWithFormat:@"http://boilerpipe-web.appspot.com/extract?url=%@&extractor=ArticleExtractor&output=json&extractImages=",[[[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil] objectForKey:@"end_url"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//        //NEW PART END
//        
//        
//        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//        
//        
//        
//        [manager GET:bibloUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//            
//            
//            NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
//            if([dict objectForKey:@"error"])
//            {
//                AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//                manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//                
//                NSString* ourParserUrl = [@"http://almasdarapp.com/almasdar/getOsamaReadabilityParser.php?url=" stringByAppendingString:self.url];
//                
//                [manager GET:ourParserUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//                    
//                    
//                    NSString* content = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//                    
//                    NSArray* components = [content componentsSeparatedByString:@"####"];
//                    if (components.count > 0)
//                    {
//                        if (components.count > 1)
//                        {
//                            content = [components objectAtIndex:1];
//                        }
//                        
//                        self.title = [components objectAtIndex:0];
//                    }
//                    
//                    
//                    NSMutableArray* arr = [[NSMutableArray alloc]initWithArray:[content componentsSeparatedByString:@"\n"]];
//                    NSString* string = @"";
//                    for(NSString* line in arr)
//                    {
//                        if(line.length > 40)
//                        {
//                            string = [string stringByAppendingFormat:@"%@\n",line];
//                        }
//                    }
//                    
//                    [_titleTextView setText:self.title];
//                    [textView setText:string];
//                    [imageView setImage:self.image];
//                    if ([textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0)
//                    {
//                        [_listenButton setImage:[UIImage imageNamed:@"listen-icon.png"]];
//                    }
//                    
//                    
//                    if(string.length < 140)
//                    {
//                        NSLog(@"%@",@"We should open a web view:)");
//                        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isReadability"])
//                        {
//                            isWebOnly = YES;
//                            [_theSwitch setOn:NO];
//                            [self reloadForWeb];
//                        }
//                    }
//                    
//                    [self stopTheLoading];
//                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                    [self stopTheLoading];
//                }
//                 ];
//            }else
//            {
//                self.title = [[dict objectForKey:@"response"] objectForKey:@"title"];
//                NSString* content = [[dict objectForKey:@"response"] objectForKey:@"content"];
//                [_titleTextView setText:self.title];
//                [textView setText:content];
//                [imageView setImage:self.image];
//                [self stopTheLoading];
//                if ([textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0)
//                {
//                    [_listenButton setImage:[UIImage imageNamed:@"listen-icon.png"]];
//                }
//                
//            }
//        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            [self stopTheLoading];
//        }
//         ];
//        //NEW PART START
//    });
//    //NEW PART END
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        [self getImages];
//        [self getVideos];
//    });
}

-(void)openURLold
{
    youtube = NO;
    
//    [webView setDelegate:self];
//    
//    [self startLoading];
//    
//    if (!isFristLoad)
//    {
//        isFristLoad = YES;
//        self.url = [self.url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//        videosURL = self.url;
//        imageURL = [@"http://embed.ly/docs/explore/extract?url=" stringByAppendingString:self.url];
//    }
//    
//    NSString* bibloUrl = [NSString stringWithFormat:@"http://boilerpipe-web.appspot.com/extract?url=%@&extractor=ArticleExtractor&output=json&extractImages=",self.url];
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//    
//    
//    
//    [manager GET:bibloUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        
//        
//        NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
//        if([dict objectForKey:@"error"])
//        {
//            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//            manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//            
//            NSString* ourParserUrl = [@"http://almasdarapp.com/almasdar/getOsamaReadabilityParser.php?url=" stringByAppendingString:self.url];
//            
//            [manager GET:ourParserUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//                
//                
//                NSString* content = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//                
//                NSArray* components = [content componentsSeparatedByString:@"####"];
//                content = [components objectAtIndex:1];
//                self.title = [components objectAtIndex:0];
//                
//                NSMutableArray* arr = [[NSMutableArray alloc]initWithArray:[content componentsSeparatedByString:@"\n"]];
//                NSString* string = @"";
//                for(NSString* line in arr)
//                {
//                    if(line.length > 40)
//                    {
//                        string = [string stringByAppendingFormat:@"%@\n",line];
//                    }
//                }
//                
//                [_titleTextView setText:self.title];
//                [textView setText:string];
//                [imageView setImage:self.image];
//                [self stopTheLoading];
//                
//                if(string.length < 140)
//                {
//                    NSLog(@"%@",@"We should open a web view:)");
//                    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isReadability"])
//                    {
//                        isWebOnly = YES;
//                        [_theSwitch setOn:NO];
//                        [self reloadForWeb];
//                    }
//                }
//                
//            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            }
//             ];
//        }else
//        {
//            self.title = [[dict objectForKey:@"response"] objectForKey:@"title"];
//            NSString* content = [[dict objectForKey:@"response"] objectForKey:@"content"];
//            [_titleTextView setText:self.title];
//            [textView setText:content];
//            [imageView setImage:self.image];
//            [self stopTheLoading];
//            
//        }
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//    }
//     ];
}

-(void)getImages
{
    NSArray *urls = [[[NSUserDefaults standardUserDefaults] objectForKey:@"newsAllPhotos"] componentsSeparatedByString:@","];
    
    images = [[NSMutableArray alloc]init];
    
    for (NSString *str in urls)
    {
        if (str.length > 5)
        {
            [images addObject:str];
        }
    }
    
    if (images.count > 0)
    {
        [_loadingLabel setHidden:NO];
        [self addImages];
    }
    else if (self.image == nil)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            isEmptyImg = YES;
            
            numberOfImages = 0;
            
            workingFrame = _imagesScroll.frame;
            workingFrame.origin.x = 0;
            workingFrame.origin.y = 0;
            
            UIImageView *theImage = [[UIImageView alloc] initWithFrame:workingFrame];
            
            [theImage setContentMode:UIViewContentModeScaleAspectFit];
            
            theImage.clipsToBounds = YES;
            
            theImage.tag = 80 + numberOfImages;
            
            theImage.image = [UIImage imageNamed:@"no-image-img.png"];
            
            isNoImg = YES;
            
            [_imagesScroll addSubview:theImage];
            
            workingFrame.origin.x = workingFrame.origin.x + workingFrame.size.width;
            
            isFrameChanged = YES;
            
            numberOfImages++;
        });
    }
}

-(void)getVideos
{
    NSArray *urls = [[[NSUserDefaults standardUserDefaults] objectForKey:@"newsAllVideos"] componentsSeparatedByString:@"SPLITONTHIS"];
    
    videos = [[NSMutableArray alloc]init];
    
    for (NSString *str in urls)
    {
        if (str.length > 5)
        {
            
            if([str rangeOfString:@"class=\"embedly-embed\""].location != NSNotFound)
            {
                NSString* vidID = [[[[str componentsSeparatedByString:@"v%3D"] objectAtIndex:1] componentsSeparatedByString:@"%"] objectAtIndex:0];
                
                NSString* iFrame = [NSString stringWithFormat:@"<iframe width=\"%d\" height=\"%d\" src=\"http://www.youtube.com/embed/%@\" allowfullscreen></iframe>",(int)_videosScroll.frame.size.width,(int)_videosScroll.frame.size.height,vidID];
                [videos addObject:iFrame];
            }else
            {
                //NSLog(@"%@",str);
                NSString* width = [[[[str componentsSeparatedByString:@"width=\""] objectAtIndex:1] componentsSeparatedByString:@"\""] objectAtIndex:0];
                NSString* height = [[[[str componentsSeparatedByString:@"height=\""] objectAtIndex:1] componentsSeparatedByString:@"\""] objectAtIndex:0];
                NSString *finalStr = str;
                
                finalStr = [finalStr stringByReplacingOccurrencesOfString:width withString:[@"" stringByAppendingFormat:@"%d",(int)_videosScroll.frame.size.width]];
                finalStr = [finalStr stringByReplacingOccurrencesOfString:height withString:[@"" stringByAppendingFormat:@"%d",(int)_videosScroll.frame.size.height]];
                
                NSLog(@"%@",str);
                NSLog(@"%@",finalStr);
                [videos addObject:finalStr];
            }
        }
    }
    
    if (videos.count == 0)return;
    
    [self addVideos];
}

-(void)getImages2
{
    images = [[NSMutableArray alloc]init];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (self.image != nil)
        {
            [images addObject:self.image];
        }
        
        NSLog(@"%@",[NSString stringWithFormat:@"%@%@",@"http://expandurl.appspot.com/expand?url=",[self.url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]);
        
        NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",@"http://expandurl.appspot.com/expand?url=",[self.url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]];
        
        NSString* parseURL = [NSString stringWithFormat:@"%@%@",@"http://www.google.com/gwt/x?u=",[[[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil] objectForKey:@"end_url"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        
        [manager GET:parseURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            
            NSString* content = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            content = [content stringByReplacingOccurrencesOfString:@"\"" withString:@"'"];
            
            NSRange r;
            while ((r = [content rangeOfString:@"<a(.*?)</a>" options:NSRegularExpressionSearch]).location != NSNotFound)
            {
                content = [content stringByReplacingCharactersInRange:r withString:@""];
            }
            while ((r = [content rangeOfString:@"<img(.*?)/>" options:NSRegularExpressionSearch]).location != NSNotFound)
            {
                @try {
                    NSString* img = [content substringWithRange:r];
                    NSString* source = [[[[[[img componentsSeparatedByString:@"src='"] objectAtIndex:1] componentsSeparatedByString:@"'"] objectAtIndex:0] componentsSeparatedByString:@"http"] objectAtIndex:1];
                    NSString* splitWith = @"";
                    NSString* width = @"";
                    NSString* height = @"";
                    
                    if([source rangeOfString:@".jpg"].location != NSNotFound)
                    {
                        splitWith = @".jpg";
                    }else if([source rangeOfString:@".jpeg"].location != NSNotFound)
                    {
                        splitWith = @".jpeg";
                    } if([source rangeOfString:@".png"].location != NSNotFound)
                    {
                        splitWith = @".png";
                    }
                    
                    if(![splitWith isEqualToString:@""])
                    {
                        NSString* image = [[source componentsSeparatedByString:splitWith] objectAtIndex:0];
                        image = [NSString stringWithFormat:@"http%@%@",image,splitWith];
                        image = [image stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                        
                        if([img rangeOfString:@"width" options:NSCaseInsensitiveSearch].location != NSNotFound && [img rangeOfString:@"height" options:NSCaseInsensitiveSearch].location)
                        {
                            width = [[[[img componentsSeparatedByString:@"width='"] objectAtIndex:1] componentsSeparatedByString:@"'"] objectAtIndex:0];
                            height = [[[[img componentsSeparatedByString:@"height='"] objectAtIndex:1] componentsSeparatedByString:@"'"] objectAtIndex:0];
                            if([width floatValue] * [height floatValue] >= 20000)
                            {
                                NSData* data = [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:image] options:NSDataReadingMappedIfSafe error:nil];
                                UIImage* img2 = [UIImage imageWithData:data];
                                
                                if (![self image:self.image isEqualTo:img2] && ![images containsObject:img2] && ![self imageWithSize:self.image isEqualTo:img2])
                                {
                                    BOOL isImg = NO;
                                    for (int i = 0; i < images.count; i++)
                                    {
                                        if ([self image:[images objectAtIndex:i] isEqualTo:img2] || [self imageWithSize:[images objectAtIndex:i] isEqualTo:img2])
                                        {
                                            isImg = YES;
                                            break;
                                        }
                                    }
                                    if (!isImg)
                                    {
                                        [images addObject:img2];
                                    }
                                }
                            }
                        }
                    }
                } @catch (NSException *exception) {}
                @finally {
                    content = [content stringByReplacingCharactersInRange:r withString:@""];
                }
                
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if(images.count == 0)
                {
                    if(self.image)
                    {
                        [images addObject:self.image];
                    }
                }
                
                [self addImages];
            });
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(images.count == 0)
                {
                    if(self.image)
                    {
                        [images addObject:self.image];
                    }
                    [self addImages];
                }
            });
        }
         ];
    });
}

- (BOOL)image:(UIImage *)image1 isEqualTo:(UIImage *)image2
{
    return [UIImagePNGRepresentation(image1) isEqual:UIImagePNGRepresentation(image2)];
}

- (BOOL)imageWithSize:(UIImage *)image1 isEqualTo:(UIImage *)image2
{
    return ([UIImagePNGRepresentation(image1) length] == [UIImagePNGRepresentation(image2) length]);
}

-(void)getImagesold
{
    images = [[NSMutableArray alloc]init];
    if(self.image)
    {
        [images addObject:self.image];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSURL *urll = [NSURL URLWithString:[imageURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSString *webData= [NSString stringWithContentsOfURL:urll encoding:NSUTF8StringEncoding error:nil];
        NSError *error = NULL;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(<img\\s[\\s\\S]*?src\\s*?=\\s*?['\"](.*?)['\"][\\s\\S]*?>)+?"
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:&error];
        NSArray* matches = [regex matchesInString:webData options:0 range:NSMakeRange(0, [webData length])];
        for(NSTextCheckingResult* result in matches)
        {
            NSString *img = [webData substringWithRange:[result rangeAtIndex:2]];
            
            if([img hasPrefix:@"http"] && ![img hasSuffix:@"ico"])
            {
                NSData* data = [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:[img stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] options:NSDataReadingMappedIfSafe error:nil];
                UIImage* img2 = [UIImage imageWithData:data];
                if(img2.size.width >= 200 && img2.size.height >= 200)
                {
                    NSLog(@"%f %f %@",img2.size.width,img2.size.height,img);
                    [images addObject:img2];
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self addImages];
        });
    });
    
}

-(void)getVideos2
{
    videos = [[NSMutableArray alloc]init];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError* err;
        
        NSURL *urll = [NSURL URLWithString:[videosURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSString *webData = [NSString stringWithContentsOfURL:urll encoding:NSASCIIStringEncoding error:&err];
        if(err)
        {
            webData = [NSString stringWithContentsOfURL:urll encoding:NSUTF8StringEncoding error:&err];
            NSLog(@"%@",[err debugDescription]);
        }
        if(webData && [webData rangeOfString:@"<div id=\"watch7-container\" class=\"\">"].location != NSNotFound)
        {
            NSString* version = @"";
            version = [[[[webData componentsSeparatedByString:@"<link rel=\"alternate\" href=\"android-app://com.google.android.youtube/http/www.youtube.com/watch?v="] objectAtIndex:1]componentsSeparatedByString:@"\""]objectAtIndex:0];
            NSString* embeddedCode = [NSString stringWithFormat:@"https://www.youtube.com/embed/%@",version];
            youtube = YES;
            isVideo = YES;
            NSLog(@"isVideo");
            [videos addObject:embeddedCode];
        }else
        {
            webData = [webData stringByReplacingOccurrencesOfString:@"< iframe" withString:@"<iframe"];
            
            
            NSArray* iframes = [webData componentsSeparatedByString:@"<iframe"];
            for(int i = 1 ; i < iframes.count ; i++)
            {
                @try {
                    NSString* maybeIframe = [[[iframes objectAtIndex:i]componentsSeparatedByString:@"</iframe>"] objectAtIndex:0];
                    NSString* src = [[[[maybeIframe componentsSeparatedByString:@"src=\""] objectAtIndex:1] componentsSeparatedByString:@"\""] objectAtIndex:0];
                    NSString* adjustedSrc = @"";
                    for(int i = 0 ; i < src.length ; i++)
                    {
                        NSString* substring = [src substringFromIndex:i];
                        if([substring hasPrefix:@"http"] || [substring hasPrefix:@"www"])
                        {
                            adjustedSrc = substring;
                            break;
                        }
                    }
                    if([adjustedSrc hasPrefix:@"www"])
                    {
                        adjustedSrc = [@"http://" stringByAppendingString:adjustedSrc];
                    }
                    NSString* width = [[[[maybeIframe componentsSeparatedByString:@"width=\""] objectAtIndex:1] componentsSeparatedByString:@"\""] objectAtIndex:0];
                    NSString* height = [[[[maybeIframe componentsSeparatedByString:@"height=\""] objectAtIndex:1] componentsSeparatedByString:@"\""] objectAtIndex:0];
                    
                    if([maybeIframe rangeOfString:@"full" options:NSCaseInsensitiveSearch].location != NSNotFound && adjustedSrc.length > 0)
                    {
                        [videos addObject:adjustedSrc];
                        isVideo = YES;
                        NSLog(@"isVideo");
                    }else if([width doubleValue]>300 && [height doubleValue]>300 && adjustedSrc.length>0)
                    {
                        [videos addObject:adjustedSrc];
                        isVideo = YES;
                        NSLog(@"isVideo");
                    }
                }
                @catch (NSException *exception) {
                    continue;
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(youtube)
            {
                [textView setText:self.title];
            }
            [self addVideos];
            [self stopTheLoading];
        });
        
    });
    
}

-(void)startLoading
{
    [_actBackLabel setHidden:NO];
    [_actView startAnimating];
    [_scrollView setHidden:YES];
}

-(void)stopTheLoading
{
    [_actView stopAnimating];
    [_actBackLabel setHidden:YES];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isReadability"] && !isWebOnly)
    {
        [_titleTextView setFrame:CGRectMake(_titleTextView.frame.origin.x, _titleTextView.frame.origin.y, _titleTextView.frame.size.width, 0)];
        CGFloat fixedWidth = _titleTextView.frame.size.width;
        CGSize newSize = [_titleTextView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
        CGRect newFrame = _titleTextView.frame;
        newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
        _titleTextView.frame = newFrame;
        
        [textView setFrame:_titleTextView.frame];
        
        [textView setFrame:CGRectMake(textView.frame.origin.x, textView.frame.origin.y, textView.frame.size.width, 0)];
        fixedWidth = textView.frame.size.width;
        newSize = [textView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
        newFrame = textView.frame;
        newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
        textView.frame = newFrame;
        
        [textView setFrame:CGRectMake(textView.frame.origin.x, textView.frame.origin.y+_titleTextView.frame.size.height, textView.frame.size.width, textView.frame.size.height)];
        
        [_videosScroll setFrame:CGRectMake(_videosScroll.frame.origin.x, textView.frame.origin.y, _videosScroll.frame.size.width, _videosScroll.frame.size.height)];
        
        [_videosScroll setFrame:CGRectMake(_videosScroll.frame.origin.x, _videosScroll.frame.origin.y+textView.frame.size.height, _videosScroll.frame.size.width, _imagesScroll.frame.size.height)];
        
        CGFloat scrollViewHeight = 0.0f;
        for (UIView* view in _scrollView.subviews)
        {
            if ([[@"" stringByAppendingFormat:@"%@",view.class] isEqualToString:@"UITextView"] || [[@"" stringByAppendingFormat:@"%@",view.class] isEqualToString:@"UIScrollView"])
            {
                if (view.tag != 5)
                {
                    if (view.tag == 6)
                    {
                        if (isVideo)
                        {
                            [view setHidden:NO];
                            scrollViewHeight += view.frame.size.height;
                        }
                        else
                        {
                            [view setHidden:YES];
                        }
                    }
                    else
                    {
                        scrollViewHeight += view.frame.size.height;
                    }
                }
            }
        }
        
        if (scrollViewHeight < _scrollView.frame.size.height)scrollViewHeight = _scrollView.frame.size.height;
        
        scrollViewHeight += 80;
        
        [_scrollView setContentSize:(CGSizeMake(_scrollView.frame.size.width, scrollViewHeight))];
        [_scrollView setHidden:NO];
        
        _closeLabel.center = _scrollView.center;
        [_closeLabel setFrame:CGRectMake(_closeLabel.frame.origin.x, _scrollView.contentSize.height, _closeLabel.frame.size.width, _closeLabel.frame.size.height)];
        
        _closeProgressView.center = _closeLabel.center;
        [_closeProgressView setFrame:CGRectMake(_closeProgressView.frame.origin.x, _closeProgressView.frame.origin.y+24, _closeProgressView.frame.size.width, _closeProgressView.frame.size.height)];
        
        if (isTextDone)
        {
            isTextDone = NO;
            [self performSelector:@selector(getImages) withObject:nil afterDelay:0.1];
            [self performSelector:@selector(getVideos) withObject:nil afterDelay:0.2];
        }
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (isFullScreen)return;
    if (scrollView == _imagesScroll)
    {
        CGFloat pageWidth = _imagesScroll.frame.size.width;
        int page = floor((_imagesScroll.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        if (page + 1 > numberOfImages)
        {
            return;
        }
        _pageControl.currentPage = page;
    }
    else
    {
        if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height)
        {
            float scrollVal = scrollView.contentSize.height - (scrollView.contentOffset.y + scrollView.frame.size.height);
            [self setProgressTo:-scrollVal];
        }
        
        if (!isVideoDone)
        {
            if (isVideo)
            {
                if ([self checkIfVisible:_videosScroll])
                {
                    isVideoDone = YES;
                    [self performSelector:@selector(scrollToVideos) withObject:nil afterDelay:1.0];
                }
            }
        }
    }
}

-(void)scrollToImages
{
    CGRect frame = _imagesScroll.frame;
    frame.origin.x = frame.size.width * (numberOfImages-1);
    frame.origin.y = 0;
    [_imagesScroll scrollRectToVisible:frame animated:YES];
    [self performSelector:@selector(scrollImagesBack) withObject:nil afterDelay:1.0];
}

-(void)scrollToVideos
{
    CGRect frame = _videosScroll.frame;
    frame.origin.x = frame.size.width * (videos.count-1);
    frame.origin.y = 0;
    [_videosScroll scrollRectToVisible:frame animated:YES];
    [self performSelector:@selector(scrollVideosBack) withObject:nil afterDelay:1.0];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (_closeProgressView.progress == 1.0)
    {
        [self stopTheSpeech];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)setProgressTo:(float)theVal
{
    theVal = theVal*1.5;
    
    [_closeProgressView setProgress:theVal/100];
    [_closeProgressView setAlpha:theVal/100];
    [_closeLabel setAlpha:theVal/100];
    if (_closeProgressView.progress == 1.0)
    {
        if (!isFirstOneDone)
        {
            isAnimation = YES;
            isFirstOneDone = YES;
            [UIView animateWithDuration:0.2 delay:0.0 options:0
                             animations:^{
                                 [_closeLabel setText:@"اترك لإغلاق الخبر"];
                                 _closeLabel.transform = CGAffineTransformMakeScale(1.1, 1.1);
                                 _closeProgressView.transform = CGAffineTransformMakeScale(1.1, 1.1);
                             }
                             completion:^(BOOL finished) {
                                 [UIView animateWithDuration:0.2 delay:0.0 options:0
                                                  animations:^{
                                                      _closeLabel.transform = CGAffineTransformMakeScale(1.0, 1.0);
                                                      _closeProgressView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                                                  }
                                                  completion:^(BOOL finished) {
                                                      //
                                                  }];
                                 [UIView commitAnimations];
                             }];
            [UIView commitAnimations];
        }
    }
    else
    {
        if (isAnimation)
        {
            isAnimation = NO;
            isFirstOneDone = NO;
            [_closeLabel setText:@"تابع السحب لإغلاق الخبر"];
        }
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isReadability"] && !isWebOnly)return;
    [self startLoading];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView2
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isReadability"] && !isWebOnly)return;
    [self stopTheLoading];
    
    if ([webView canGoBack])
    {
        [_previousButton setEnabled:YES];
    }
    else
    {
        [_previousButton setEnabled:NO];
    }
    
    if ([webView canGoForward])
    {
        [_zoomNextButton setEnabled:YES];
    }
    else
    {
        [_zoomNextButton setEnabled:NO];
    }
}

- (IBAction)shareClicked:(id)sender {
    [self showSmartShare];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isNightOn"])
    {
        [_mainView setBackgroundColor:[UIColor colorWithRed:50.0/255.0 green:50.0/255.0 blue:50.0/255.0 alpha:1.0]];
        textView.textColor = [UIColor lightGrayColor];
        _titleTextView.textColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0];
        [_topBar setBarTintColor:[UIColor colorWithRed:70.0/255.0 green:70.0/255.0 blue:70.0/255.0 alpha:1.0]];
        [_topBar setTintColor:[UIColor whiteColor]];
        [_topBar setBarStyle:UIBarStyleBlack];
        [_actBackLabel setBackgroundColor:[UIColor colorWithRed:70.0/255.0 green:70.0/255.0 blue:70.0/255.0 alpha:1.0]];
        [_topLabel setBackgroundColor:[UIColor colorWithRed:70.0/255.0 green:70.0/255.0 blue:70.0/255.0 alpha:1.0]];
        [_actView setColor:[UIColor whiteColor]];
        [_toolBar setBackgroundColor:[UIColor colorWithRed:70.0/255.0 green:70.0/255.0 blue:70.0/255.0 alpha:1.0]];
        [_toolBar setBarTintColor:[UIColor colorWithRed:70.0/255.0 green:70.0/255.0 blue:70.0/255.0 alpha:1.0]];
        [_toolBar setTintColor:[UIColor colorWithRed:241.0/255.0 green:241.0/255.0 blue:241.0/255.0 alpha:1.0]];
        [_imagesScroll.layer setBorderColor:[UIColor colorWithRed:20.0/255.0 green:20.0/255.0 blue:20.0/255.0 alpha:1.0].CGColor];
        [_imagesScroll setBackgroundColor:[UIColor colorWithRed:20.0/255.0 green:20.0/255.0 blue:20.0/255.0 alpha:1.0]];
        [_videosScroll.layer setBorderColor:[UIColor colorWithRed:20.0/255.0 green:20.0/255.0 blue:20.0/255.0 alpha:1.0].CGColor];
        [_videosScroll setBackgroundColor:[UIColor colorWithRed:20.0/255.0 green:20.0/255.0 blue:20.0/255.0 alpha:1.0]];
        [_pageControl setCurrentPageIndicatorTintColor:[UIColor lightGrayColor]];
        [_pageControl setPageIndicatorTintColor:[UIColor colorWithRed:70.0/255.0 green:70.0/255.0 blue:70.0/255.0 alpha:1.0]];
        [_loadingLabel setTextColor:textView.textColor];
    }
    else
    {
        [_mainView setBackgroundColor:[UIColor colorWithRed:241.0/255.0 green:241.0/255.0 blue:241.0/255.0 alpha:1.0]];
        textView.textColor = [UIColor colorWithRed:37.0/255.0 green:37.0/255.0 blue:37.0/255.0 alpha:1.0];
        _titleTextView.textColor = [UIColor colorWithRed:20.0/255.0 green:20.0/255.0 blue:20.0/255.0 alpha:1.0];
        [_topBar setBarTintColor:[UIColor colorWithRed:241.0/255.0 green:241.0/255.0 blue:241.0/255.0 alpha:1.0]];
        [_topBar setBarStyle:UIBarStyleDefault];
        [_topBar setTintColor:[UIColor blackColor]];
        [_actBackLabel setBackgroundColor:[UIColor colorWithRed:241.0/255.0 green:241.0/255.0 blue:241.0/255.0 alpha:1.0]];
        [_topLabel setBackgroundColor:[UIColor colorWithRed:241.0/255.0 green:241.0/255.0 blue:241.0/255.0 alpha:1.0]];
        [_actView setColor:[UIColor blackColor]];
        [_toolBar setBackgroundColor:[UIColor colorWithRed:241.0/255.0 green:241.0/255.0 blue:241.0/255.0 alpha:1.0]];
        [_toolBar setBarTintColor:[UIColor colorWithRed:241.0/255.0 green:241.0/255.0 blue:241.0/255.0 alpha:1.0]];
        [_toolBar setTintColor:[UIColor colorWithRed:85.0/255.0 green:85.0/255.0 blue:85.0/255.0 alpha:1.0]];
        [_imagesScroll.layer setBorderColor:[UIColor colorWithRed:50.0/255.0 green:50.0/255.0 blue:50.0/255.0 alpha:0.5].CGColor];
        [_imagesScroll setBackgroundColor:[UIColor colorWithRed:221.0/255.0 green:221.0/255.0 blue:221.0/255.0 alpha:1.0]];
        [_videosScroll.layer setBorderColor:[UIColor colorWithRed:50.0/255.0 green:50.0/255.0 blue:50.0/255.0 alpha:0.5].CGColor];
        [_videosScroll setBackgroundColor:[UIColor colorWithRed:221.0/255.0 green:221.0/255.0 blue:221.0/255.0 alpha:1.0]];
        [_pageControl setCurrentPageIndicatorTintColor:[UIColor colorWithRed:20.0/255.0 green:20.0/255.0 blue:20.0/255.0 alpha:1.0]];
        [_pageControl setPageIndicatorTintColor:[UIColor colorWithRed:120.0/255.0 green:120.0/255.0 blue:120.0/255.0 alpha:1.0]];
        [_loadingLabel setTextColor:textView.textColor];
    }
    
    [_closeLabel setTextColor:_titleTextView.textColor];
    
    [_imagesScroll.layer setBorderWidth:1];
    [_videosScroll.layer setBorderWidth:1];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveLocalNotification:)
                                                 name:@"OpenUrl"
                                               object:nil];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isNightOn"]) return UIStatusBarStyleLightContent;
    return UIStatusBarStyleDefault;
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

- (IBAction)showComments:(id)sender {
    [self performSegueWithIdentifier:@"commentsSeg" sender:self];
}

- (IBAction)readChanged:(id)sender {
    if (isWebOnly)
    {
        [self showStatusBarMsg:@"هذا الخبر لايدعم وضعية القراءة" isRed:YES];
        [_theSwitch setOn:NO];
        return;
    }
    [[NSUserDefaults standardUserDefaults] setBool:_theSwitch.on forKey:@"isReadability"];
    [webView setHidden:_theSwitch.on];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self reloadWebPage];
}

- (IBAction)closButtonClicked:(id)sender {
    [self stopTheSpeech];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)loadImageFromUrl:(NSString*)urlString withLoadingImg:(UIImage*)theLoadingImage andErrorImg:(UIImage*)theErrorImage forImageView:(UIImageView*)newImgView
{
    //Add your image and set a loading image so the user know that you are loading an image:
    newImgView.image = theLoadingImage;
    
    //Request image data from the URL:
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (imgData)
            {
                //Load the data into an UIImage:
                UIImage *image = [UIImage imageWithData:imgData];
                
                //Check if your image loaded successfully:
                if (image)
                {
                    newImgView.image = image;
                }
                else
                {
                    //Failed to load the data into an UIImage:
                    newImgView.image = theErrorImage;
                }
            }
            else
            {
                //Failed to get the image data:
                newImgView.image = theErrorImage;
            }
        });
    });
}

- (UIColor *)colorAtPixel:(CGPoint)point inImage:(UIImage *)image {
    
    if (!CGRectContainsPoint(CGRectMake(0.0f, 0.0f, image.size.width, image.size.height), point)) {
        return nil;
    }
    
    // Create a 1x1 pixel byte array and bitmap context to draw the pixel into.
    NSInteger pointX = trunc(point.x);
    NSInteger pointY = trunc(point.y);
    CGImageRef cgImage = image.CGImage;
    NSUInteger width = image.size.width;
    NSUInteger height = image.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    int bytesPerPixel = 4;
    int bytesPerRow = bytesPerPixel * 1;
    NSUInteger bitsPerComponent = 8;
    unsigned char pixelData[4] = { 0, 0, 0, 0 };
    CGContextRef context = CGBitmapContextCreate(pixelData, 1, 1, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    
    // Draw the pixel we are interested in onto the bitmap context
    CGContextTranslateCTM(context, -pointX, pointY-(CGFloat)height);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, (CGFloat)width, (CGFloat)height), cgImage);
    CGContextRelease(context);
    
    // Convert color values [0..255] to floats [0.0..1.0]
    CGFloat red   = (CGFloat)pixelData[0] / 255.0f;
    CGFloat green = (CGFloat)pixelData[1] / 255.0f;
    CGFloat blue  = (CGFloat)pixelData[2] / 255.0f;
    CGFloat alpha = (CGFloat)pixelData[3] / 255.0f;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

-(NSInteger)color:(UIColor *)color1 matchesColor:(UIColor *)color2
{
    CGFloat red1, red2, green1, green2, blue1, blue2, alpha1, alpha2;
    [color1 getRed:&red1 green:&green1 blue:&blue1 alpha:&alpha1];
    [color2 getRed:&red2 green:&green2 blue:&blue2 alpha:&alpha2];
    
    NSInteger theIntNum = 0;
    
    if (red1 == red1)
    {
        theIntNum = theIntNum + 25;
    }
    
    if (green1 == green2)
    {
        theIntNum = theIntNum + 25;
    }
    
    if (blue1 == blue2)
    {
        theIntNum = theIntNum + 25;
    }
    
    if (alpha1 == alpha2)
    {
        theIntNum = theIntNum + 25;
    }
    
    return theIntNum;
}

- (NSArray*)getRGBAsFromImage:(UIImage*)image atX:(int)x andY:(int)y count:(int)count
{
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:count];
    
    // First get the image into your data buffer
    CGImageRef imageRef = [image CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    
    // Now your rawData contains the image data in the RGBA8888 pixel format.
    NSUInteger byteIndex = (bytesPerRow * y) + x * bytesPerPixel;
    for (int i = 0 ; i < count ; ++i)
    {
        CGFloat red   = (rawData[byteIndex]     * 1.0) / 255.0;
        CGFloat green = (rawData[byteIndex + 1] * 1.0) / 255.0;
        CGFloat blue  = (rawData[byteIndex + 2] * 1.0) / 255.0;
        CGFloat alpha = (rawData[byteIndex + 3] * 1.0) / 255.0;
        byteIndex += bytesPerPixel;
        
        UIColor *acolor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
        [result addObject:acolor];
    }
    
    free(rawData);
    
    return result;
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

-(void)addCurrentImg
{
    UIImage *currentImg = [UIImage imageWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"currentImgData"]];
    
    if(currentImg != nil)
    {
        self.image = currentImg;
    }
    
    if (self.image != nil)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            numberOfImages = 0;
            
            workingFrame = _imagesScroll.frame;
            workingFrame.origin.x = 0;
            workingFrame.origin.y = 0;
            
            UIImageView *theImage = [[UIImageView alloc] initWithFrame:workingFrame];
            
            [theImage setContentMode:UIViewContentModeScaleAspectFit];
            
            theImage.clipsToBounds = YES;
            
            theImage.tag = 80 + numberOfImages;
            
            theImage.image = self.image;
            
            [_imagesScroll addSubview:theImage];
            
            workingFrame.origin.x = workingFrame.origin.x + workingFrame.size.width;
            
            isFrameChanged = YES;
            
            numberOfImages++;
        });
    }
}

-(void)addImages
{
    if (!isFrameChanged)
    {
        for (UIView *view in [_imagesScroll subviews]) {
            [view removeFromSuperview];
        }
        
        numberOfImages = 0;
        
        workingFrame = _imagesScroll.frame;
        workingFrame.origin.x = 0;
        workingFrame.origin.y = 0;
    }
    
    CGRect frame = _imagesScroll.frame;
    frame.origin.x = frame.size.width * 0;
    frame.origin.y = 0;
    [_imagesScroll scrollRectToVisible:frame animated:NO];
    
    NSLog(@"Images: %lu",(unsigned long)images.count);
    
        for (int i = 0; i < images.count; i++)
        {
            
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[images objectAtIndex:i]]];
            
            [NSURLConnection sendAsynchronousRequest:request
                                               queue:[NSOperationQueue mainQueue]
                                   completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                       if ( !error )
                                       {
                                           UIImage *theImg = [[UIImage alloc] initWithData:data];
                                           UIImageView *theImage = [[UIImageView alloc] initWithFrame:workingFrame];
                                           [theImage setContentMode:UIViewContentModeScaleAspectFit];
                                           
                                           theImage.clipsToBounds = YES;
                                           
                                           theImage.tag = 80 + numberOfImages;
                                           
                                           if (theImg != nil)
                                           {
                                               if (theImg.size.width > 250)
                                               {
                                                   if (self.image != nil)
                                                   {
                                                       UIImage *img1 = [self imageWithImage:self.image scaledToSize:CGSizeMake(100, 100)];
                                                       UIImage *img2 = [self imageWithImage:theImg scaledToSize:CGSizeMake(100, 100)];
                                                       
                                                       if ([self color:[self colorAtPixel:CGPointMake(50, 50) inImage:img1] matchesColor:[self colorAtPixel:CGPointMake(50, 50) inImage:img2]] <= 50 && [self color:[self colorAtPixel:CGPointMake(25, 25) inImage:img1] matchesColor:[self colorAtPixel:CGPointMake(25, 25) inImage:img2]] <= 50 && [self color:[self colorAtPixel:CGPointMake(75, 75) inImage:img1] matchesColor:[self colorAtPixel:CGPointMake(75, 75) inImage:img2]] <= 50)
                                                       {
                                                           theImage.image = theImg;
                                                           dispatch_async(dispatch_get_main_queue(), ^{
                                                               [_imagesScroll addSubview:theImage];
                                                           });
                                                           
                                                           workingFrame.origin.x = workingFrame.origin.x + workingFrame.size.width;
                                                           
                                                           numberOfImages++;
                                                           
                                                           NSLog(@"Images Added!");
                                                       }
                                                       else
                                                       {
                                                           NSLog(@"Duplicated Image");
                                                       }
                                                   }
                                                   else
                                                   {
                                                       self.image = theImg;
                                                       
                                                       theImage.image = theImg;
                                                       
                                                       dispatch_async(dispatch_get_main_queue(), ^{
                                                           [_imagesScroll addSubview:theImage];
                                                       });
                                                       
                                                       workingFrame.origin.x = workingFrame.origin.x + workingFrame.size.width;
                                                       
                                                       numberOfImages++;
                                                       
                                                       NSLog(@"Images Added!");
                                                   }
                                               }
                                               else
                                               {
                                                   NSLog(@"Small Image:\nWidth: %f",theImg.size.width);
                                               }
                                           }
                                           else
                                           {
                                               NSLog(@"Image == nil");
                                           }
                                           
                                           if (i == images.count-1)
                                           {
                                               dispatch_async(dispatch_get_main_queue(), ^{
                                               [_imagesScroll setPagingEnabled:YES];
                                               [_imagesScroll setContentSize:CGSizeMake(workingFrame.origin.x, workingFrame.size.height)];
                                               });
                                               isImage = YES;
                                               if (numberOfImages == 0)
                                               {
                                                   [_loadingLabel setHidden:YES];
                                                   
                                                   UIImageView *theImage = [[UIImageView alloc] initWithFrame:workingFrame];
                                                   
                                                   [theImage setContentMode:UIViewContentModeCenter];
                                                   
                                                   theImage.clipsToBounds = YES;
                                                   
                                                   isNoImg = YES;
                                                   
                                                   if ([[NSUserDefaults standardUserDefaults] integerForKey:@"currentColor"] == 2 && ![[NSUserDefaults standardUserDefaults] boolForKey:@"isNightOn"])
                                                   {
                                                       [theImage setTintColor:[UIColor lightGrayColor]];
                                                       
                                                       theImage.image = [[UIImage imageNamed:@"no-image-img.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                                                   }
                                                   else
                                                   {
                                                       [theImage setTintColor:[UIColor colorWithRed:50.0/255.0 green:50.0/255.0 blue:50.0/255.0 alpha:1.0]];
                                                       
                                                       [theImage setImage:[UIImage imageNamed:@"no-image-img.png"]];
                                                   }
                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                       [self stopLoadingImage];
                                                   
                                                       [_imagesScroll addSubview:theImage];
                                                   });
                                               }
                                               else
                                               {
                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                       [self stopLoadingImage];
                                                       [_loadingLabel setHidden:YES];
                                                       [_pageControl setHidden:NO];
                                                       [_pageControl setNumberOfPages:numberOfImages];
                                                       [_pageControl setCurrentPage:0];
                                                       [self scrollToImages];
                                                   });
                                               }
                                               
                                               NSLog(@"Done!");
                                           }
                                           
                                       } else{
                                           [_loadingLabel setHidden:YES];
                                           
                                           UIImageView *theImage = [[UIImageView alloc] initWithFrame:workingFrame];
                                           
                                           [theImage setContentMode:UIViewContentModeCenter];
                                           
                                           theImage.clipsToBounds = YES;
                                           
                                           isNoImg = YES;
                                           
                                           if ([[NSUserDefaults standardUserDefaults] integerForKey:@"currentColor"] == 2 && ![[NSUserDefaults standardUserDefaults] boolForKey:@"isNightOn"])
                                           {
                                               [theImage setTintColor:[UIColor lightGrayColor]];
                                               
                                               theImage.image = [[UIImage imageNamed:@"no-image-img.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                                           }
                                           else
                                           {
                                               [theImage setTintColor:[UIColor colorWithRed:50.0/255.0 green:50.0/255.0 blue:50.0/255.0 alpha:1.0]];
                                               
                                               [theImage setImage:[UIImage imageNamed:@"no-image-img.png"]];
                                           }
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               [self stopLoadingImage];
                                               
                                               [_imagesScroll addSubview:theImage];
                                           });
                                       }
                                   }];
            
        }
    
    
    if (images.count == 0)
    {
        [_imagesScroll setPagingEnabled:YES];
        [_imagesScroll setContentSize:CGSizeMake(workingFrame.origin.x, workingFrame.size.height)];
        isImage = YES;
        UIImageView *theImage = [[UIImageView alloc] initWithFrame:workingFrame];
        
        [theImage setContentMode:UIViewContentModeCenter];
        
        theImage.clipsToBounds = YES;
        
        [self stopLoadingImage];
        
        [_imagesScroll addSubview:theImage];
    }
}

-(void)addNewPhotoAtIndex:(NSInteger)i
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImageView *theImage = [[UIImageView alloc] initWithFrame:workingFrame];
        
        [theImage setContentMode:UIViewContentModeScaleAspectFit];
        
        theImage.clipsToBounds = YES;
        
        theImage.tag = 80 + numberOfImages;
        
        NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[images objectAtIndex:i]]];
        
        if (imgData)
        {
            UIImage *theImg = [UIImage imageWithData:imgData];
            
            if (theImg != nil)
            {
                if (theImg.size.width > 250 && theImg.size.height > 200)
                {
                    if (self.image != nil)
                    {
                        UIImage *img1 = [self imageWithImage:self.image scaledToSize:CGSizeMake(100, 100)];
                        UIImage *img2 = [self imageWithImage:theImg scaledToSize:CGSizeMake(100, 100)];
                        
                        if ([self color:[self colorAtPixel:CGPointMake(50, 50) inImage:img1] matchesColor:[self colorAtPixel:CGPointMake(50, 50) inImage:img2]] <= 50 && [self color:[self colorAtPixel:CGPointMake(25, 25) inImage:img1] matchesColor:[self colorAtPixel:CGPointMake(25, 25) inImage:img2]] <= 50 && [self color:[self colorAtPixel:CGPointMake(75, 75) inImage:img1] matchesColor:[self colorAtPixel:CGPointMake(75, 75) inImage:img2]] <= 50)
                        {
                            theImage.image = theImg;
                            
                            [_imagesScroll addSubview:theImage];
                            
                            workingFrame.origin.x = workingFrame.origin.x + workingFrame.size.width;
                            
                            numberOfImages++;
                            
                            NSLog(@"Images Added!");
                        }
                        else
                        {
                            NSLog(@"Duplicated Image");
                        }
                    }
                    else
                    {
                        self.image = theImg;
                        
                        theImage.image = theImg;
                        
                        [_imagesScroll addSubview:theImage];
                        
                        workingFrame.origin.x = workingFrame.origin.x + workingFrame.size.width;
                        
                        numberOfImages++;
                        
                        NSLog(@"Images Added!");
                    }
                }
                else
                {
                    NSLog(@"Small Image");
                }
            }
            else
            {
                NSLog(@"Image == nil");
            }
        }
        
        if (i == images.count-1)
        {
            [_imagesScroll setPagingEnabled:YES];
            [_imagesScroll setContentSize:CGSizeMake(workingFrame.origin.x, workingFrame.size.height)];
            isImage = YES;
            [_loadingLabel setHidden:YES];
            [_pageControl setHidden:NO];
            [_pageControl setNumberOfPages:numberOfImages];
            [_pageControl setCurrentPage:0];
            [self scrollToImages];
            NSLog(@"Done!");
        }
    });
}

-(void)addNewImgAtIndex:(NSString*)thei
{
    NSInteger i = [thei integerValue];
    __block UIImageView *theImage;
    
    theImage = [[UIImageView alloc] initWithFrame:workingFrame];
    
    [theImage setContentMode:UIViewContentModeScaleAspectFill];
    
    theImage.clipsToBounds = YES;
    
    [theImage hnk_setImageFromURL:[NSURL URLWithString:[[images objectAtIndex:i] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholder:[UIImage imageNamed:@"loading-img.png"] success:^(UIImage *theImg) {
        
        NSLog(@"%ld of %lu",i+1,(unsigned long)images.count);
        
        if (theImg != nil)
        {
            if (theImg.size.width > 250 && theImg.size.height > 200)
            {
                if (self.image != nil)
                {
                    UIImage *img1 = [self imageWithImage:self.image scaledToSize:CGSizeMake(100, 100)];
                    UIImage *img2 = [self imageWithImage:theImg scaledToSize:CGSizeMake(100, 100)];
                    
                    if ([self color:[self colorAtPixel:CGPointMake(50, 50) inImage:img1] matchesColor:[self colorAtPixel:CGPointMake(50, 50) inImage:img2]] <= 50 && [self color:[self colorAtPixel:CGPointMake(25, 25) inImage:img1] matchesColor:[self colorAtPixel:CGPointMake(25, 25) inImage:img2]] <= 50 && [self color:[self colorAtPixel:CGPointMake(75, 75) inImage:img1] matchesColor:[self colorAtPixel:CGPointMake(75, 75) inImage:img2]] <= 50)
                    {
                        theImage = [[UIImageView alloc] initWithFrame:workingFrame];
                        
                        theImage.image = theImg;
                        
                        theImage.clipsToBounds = YES;
                        
                        theImage.tag = 80 + i;
                        
                        [theImage setContentMode:UIViewContentModeScaleAspectFill];
                        
                        [_imagesScroll addSubview:theImage];
                        
                        workingFrame.origin.x = workingFrame.origin.x + workingFrame.size.width;
                        
                        numberOfImages++;
                        
                        NSLog(@"Images Added!");
                    }
                    else
                    {
                        NSLog(@"Duplicated Image");
                    }
                }
                else
                {
                    theImage = [[UIImageView alloc] initWithFrame:workingFrame];
                    
                    theImage.image = theImg;
                    
                    self.image = theImg;
                    
                    theImage.clipsToBounds = YES;
                    
                    theImage.tag = 80 + i;
                    
                    [theImage setContentMode:UIViewContentModeScaleAspectFill];
                    
                    [_imagesScroll addSubview:theImage];
                    
                    workingFrame.origin.x = workingFrame.origin.x + workingFrame.size.width;
                    
                    numberOfImages++;
                    
                    NSLog(@"Images Added!");
                }
            }
            else
            {
                NSLog(@"Small Image");
            }
        }
        else
        {
            NSLog(@"Image == nil");
        }
        
        if (i == images.count-1)
        {
            [_imagesScroll setPagingEnabled:YES];
            [_imagesScroll setContentSize:CGSizeMake(workingFrame.origin.x, workingFrame.size.height)];
            isImage = YES;
            [_loadingLabel setHidden:YES];
            [_pageControl setHidden:NO];
            [_pageControl setNumberOfPages:numberOfImages];
            [_pageControl setCurrentPage:0];
            [self scrollToImages];
        }
    } failure:^(NSError *error) {
        [_loadingLabel setHidden:YES];
        [_pageControl setHidden:NO];
        [_pageControl setNumberOfPages:numberOfImages];
        [_pageControl setCurrentPage:0];
    }];

}

- (IBAction)pageChanged:(id)sender {
    CGRect frame = _imagesScroll.frame;
    frame.origin.x = frame.size.width * _pageControl.currentPage;
    frame.origin.y = 0;
    [_imagesScroll scrollRectToVisible:frame animated:YES];
}

-(void)addVideos
{
    dispatch_async(dispatch_get_main_queue(), ^{
        for (UIView *view in [_videosScroll subviews]) {
            [view removeFromSuperview];
        }
        
        workingFrame = _videosScroll.frame;
        workingFrame.origin.x = 0;
        workingFrame.origin.y = 0;
        
        CGRect frame = _videosScroll.frame;
        frame.origin.x = frame.size.width * 0;
        frame.origin.y = 0;
        [_videosScroll scrollRectToVisible:frame animated:NO];
        
        for (int i = 0; i < videos.count;i++) {
//            NSURLRequest* req = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:[[videos objectAtIndex:i] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:100];
            UIWebView *theWebView = [[UIWebView alloc]init];
            [theWebView loadHTMLString:[videos objectAtIndex:i] baseURL:nil];
  //          [theWebView loadRequest:req];
            //theWebView.scalesPageToFit=YES;
           // theWebView.scrollView.scrollEnabled = NO;
            theWebView.frame = workingFrame;
            [_videosScroll addSubview:theWebView];
            
            workingFrame.origin.x = workingFrame.origin.x + workingFrame.size.width;
        }
        
        [_videosScroll setPagingEnabled:YES];
        [_videosScroll setContentSize:CGSizeMake(workingFrame.origin.x, workingFrame.size.height)];
        
        isVideo = YES;
        
        [self stopTheLoading];
    });
}

-(void)scrollImagesBack
{
    CGRect frame = _imagesScroll.frame;
    frame.origin.x = frame.size.width * 0;
    frame.origin.y = 0;
    [_imagesScroll scrollRectToVisible:frame animated:YES];
}

-(void)scrollVideosBack
{
    CGRect frame = _videosScroll.frame;
    frame.origin.x = frame.size.width * 0;
    frame.origin.y = 0;
    [_videosScroll scrollRectToVisible:frame animated:YES];
}

-(BOOL)checkIfVisible:(UIScrollView*)theScrollView
{
    if (CGRectIntersectsRect(_scrollView.bounds, theScrollView.frame))return YES;
    return NO;
}

#pragma mark - AVSpeechSynthesizerDelegate

-(void)startSpeech
{
    self.utteranceString = textView.text;
    
    AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:textView.text];
    
    utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:BCP47LanguageCodeForString(utterance.speechString)];
    //    utterance.pitchMultiplier = 0.5f;
    //utterance.rate = AVSpeechUtteranceDefaultSpeechRate;
//    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"speedOfSpeech"] == 0)
//    {
//        [utterance setRate:0.2f];
//    }
//    else if ([[NSUserDefaults standardUserDefaults] integerForKey:@"speedOfSpeech"] == 2)
//    {
//        [utterance setRate:0.4f];
//    }
    
    [utterance setRate:0.2f];
    
    utterance.preUtteranceDelay = 0.2f;
    utterance.postUtteranceDelay = 0.2f;
    
    [self.speechSynthesizer speakUtterance:utterance];
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer willSpeakRangeOfSpeechString:(NSRange)characterRange utterance:(AVSpeechUtterance *)utterance
{
//    self.utteranceString = textView.text;
//    
//    NSMutableAttributedString *mutableAttributedString;
//    
//    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isNightOn"])
//    {
//        mutableAttributedString = [[NSMutableAttributedString alloc] initWithString:self.utteranceString attributes:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[UIFont fontWithName:@"DroidArabicKufi" size:[[NSUserDefaults standardUserDefaults] integerForKey:@"theFontSize"]],[UIColor lightGrayColor], nil] forKeys:[NSArray arrayWithObjects:NSFontAttributeName,NSForegroundColorAttributeName, nil]]];
//        [mutableAttributedString addAttribute:NSBackgroundColorAttributeName value:[UIColor colorWithRed:121.0/255.0 green:100.0/255.0 blue:56.0/255.0 alpha:1.0] range:characterRange];
//    }
//    else
//    {
//        mutableAttributedString = [[NSMutableAttributedString alloc] initWithString:self.utteranceString attributes:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[UIFont fontWithName:@"DroidArabicKufi" size:[[NSUserDefaults standardUserDefaults] integerForKey:@"theFontSize"]],[UIColor colorWithRed:37.0/255.0 green:37.0/255.0 blue:37.0/255.0 alpha:1.0], nil] forKeys:[NSArray arrayWithObjects:NSFontAttributeName,NSForegroundColorAttributeName, nil]]];
//        [mutableAttributedString addAttribute:NSBackgroundColorAttributeName value:[UIColor colorWithRed:254.0/255.0 green:255.0/255.0 blue:0.0/255.0 alpha:1.0] range:characterRange];
//    }
//    
//    [textView setAttributedText:mutableAttributedString];
//    
//    textView.textAlignment = NSTextAlignmentRight;
//    
//    [_scrollView scrollRectToVisible:[self theRectOfText:characterRange] animated:YES];
}

-(CGRect)theRectOfText:(NSRange)theRange
{
    if(theRange.location<textView.text.length)
    {
        NSString * firstHalfString = [textView.text substringToIndex:theRange.location];
        
        CGSize s = [firstHalfString sizeWithAttributes:@{NSFontAttributeName:textView.font}];
        
        CGSize adjustedSize2 = CGSizeMake(ceilf(s.width), ceilf(s.height));
        
        float finalSize = adjustedSize2.height+_imagesScroll.frame.size.height;
        finalSize = finalSize+_titleTextView.frame.size.height;
        
        if (finalSize >= (_scrollView.contentSize.height/4))
        {
            finalSize = finalSize +100;
        }
        
        if (finalSize >= (_scrollView.contentSize.height/3))
        {
            finalSize = finalSize +100;
        }
        
        if (finalSize >= (_scrollView.contentSize.height/2))
        {
            finalSize = finalSize +100;
        }
        
        //Here is the frame of your word in text view.
        NSLog(@"ycoordinate = %f",finalSize);
        
        return CGRectMake(_scrollView.bounds.origin.x, finalSize, adjustedSize2.width, _scrollView.bounds.size.height);
        
    }
    else
    {
        return CGRectMake(_scrollView.contentOffset.x, _scrollView.contentOffset.y, _scrollView.frame.size.width, _scrollView.frame.size.height);
    }
}

//- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer
//  didStartSpeechUtterance:(AVSpeechUtterance *)utterance
//{
//    NSLog(@"%@ %@", [self class], NSStringFromSelector(_cmd));
//    self.utteranceString = textView.text;
//    textView.attributedText = [[NSAttributedString alloc] initWithString:self.utteranceString];
//    
//    textView.font = [UIFont fontWithName:@"DroidArabicKufi" size:[[NSUserDefaults standardUserDefaults] integerForKey:@"theFontSize"]];
//    textView.textAlignment = NSTextAlignmentRight;
//}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer
 didFinishSpeechUtterance:(AVSpeechUtterance *)utterance
{
    self.utteranceString = textView.text;
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isNightOn"])
    {
        textView.attributedText = [[NSAttributedString alloc] initWithString:self.utteranceString attributes:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[UIFont fontWithName:@"DroidArabicKufi" size:[[NSUserDefaults standardUserDefaults] integerForKey:@"theFontSize"]],[UIColor lightGrayColor], nil] forKeys:[NSArray arrayWithObjects:NSFontAttributeName,NSForegroundColorAttributeName, nil]]];
    }
    else
    {
        textView.attributedText = [[NSAttributedString alloc] initWithString:self.utteranceString attributes:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[UIFont fontWithName:@"DroidArabicKufi" size:[[NSUserDefaults standardUserDefaults] integerForKey:@"theFontSize"]],[UIColor colorWithRed:37.0/255.0 green:37.0/255.0 blue:37.0/255.0 alpha:1.0], nil] forKeys:[NSArray arrayWithObjects:NSFontAttributeName,NSForegroundColorAttributeName, nil]]];
    }
    
    textView.textAlignment = NSTextAlignmentRight;
    [_listenButton setImage:[UIImage imageNamed:@"listen-icon.png"]];
}

@end
