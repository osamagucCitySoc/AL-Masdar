//
//  SettingsViewController.m
//
//  Created by Housein Jouhar on 7/3/15.
//  Copyright (c) 2015 SADAH Software Solutions. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _cell1.selectedBackgroundView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"settings-selected-back.png"]];
    _cell2.selectedBackgroundView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"settings-selected-back.png"]];
    _cell3.selectedBackgroundView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"settings-selected-back.png"]];
    _cell4.selectedBackgroundView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"settings-selected-back.png"]];
    _cell5.selectedBackgroundView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"settings-selected-back.png"]];
    _cell6.selectedBackgroundView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"settings-selected-back.png"]];
    
    [_BreakingNewsSwitch setOn:[[NSUserDefaults standardUserDefaults] boolForKey:@"isUrgentPush"]];
    [_soundSwitch setOn:[[NSUserDefaults standardUserDefaults] boolForKey:@"isSoundEffects"]];
    [_nightSwitch setOn:[[NSUserDefaults standardUserDefaults] boolForKey:@"isAutoNight"]];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!isDidDone)
    {
        isDidDone = YES;
        
        isCellRemoved = ![[NSUserDefaults standardUserDefaults] boolForKey:@"isUrgentPush"];
        
        if (isCellRemoved)
        {
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:1]]  withRowAnimation:UITableViewRowAnimationNone];
        }
    }
}

- (IBAction)breakingNewsOnOff:(id)sender {
    if (_BreakingNewsSwitch.isOn)
    {
        isCellRemoved = NO;
        [self subscribeForUrgentPush];
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:1]] withRowAnimation:UITableViewRowAnimationMiddle];
    }
    else
    {
        [self unSubscribeForUrgentPush];
        isCellRemoved = YES;
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:1]]  withRowAnimation:UITableViewRowAnimationMiddle];
    }
}

- (IBAction)autoNightChanged:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:_nightSwitch.isOn forKey:@"isAutoNight"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)showStatusBarMsg:(NSString*)theMsg isRed:(BOOL)isRed
{
    UIColor *selectedColor;
    
    if (isRed)
    {
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
        selectedColor = [UIColor colorWithRed:140.0/255.0 green:117.0/255.0 blue:26.0/255.0 alpha:1.0];
    }
    
    NSDictionary *options = @{
                              kCRToastTextKey : theMsg,
                              kCRToastTextAlignmentKey : @(NSTextAlignmentCenter),
                              kCRToastBackgroundColorKey : selectedColor,
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

- (void)subscribeForUrgentPush
{
    if(![self connected])
    {
        [self showStatusBarMsg:@"يجب أن تكون متصلاً بالإنترنت" isRed:YES];
        [_BreakingNewsSwitch setOn:NO animated:YES];
        
    }else
    {
        NSMutableArray* sources = [[NSMutableArray alloc]init];
        
        NSArray *subs;
        
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"breakingSubscriptions"] && [[[NSUserDefaults standardUserDefaults] objectForKey:@"breakingSubscriptions"] count] > 0)
        {
            subs = [[NSUserDefaults standardUserDefaults] objectForKey:@"breakingSubscriptions"];
        }
        else
        {
            subs = [[NSUserDefaults standardUserDefaults] objectForKey:@"subscriptions"];
            [[NSUserDefaults standardUserDefaults] setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"subscriptions"] forKey:@"breakingSubscriptions"];
        }
        
        for(NSDictionary* dict in subs)
        {
            [sources addObject:[NSString stringWithFormat:@"c%@",[dict objectForKey:@"twitterID"]]];
        }
        
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        [currentInstallation addUniqueObjectsFromArray:sources forKey:@"urgentPush"];
        [currentInstallation saveInBackground];
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isUrgentPush"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)unSubscribeForUrgentPush {
    if(![self connected])
    {
        [self showStatusBarMsg:@"يجب أن تكون متصلاً بالإنترنت" isRed:YES];
        [_BreakingNewsSwitch setOn:YES animated:YES];
        
    }else
    {
        NSMutableArray* sources = [[NSMutableArray alloc]init];
        
        NSArray* subs = [[NSUserDefaults standardUserDefaults] objectForKey:@"subscriptions"];
        for(NSDictionary* dict in subs)
        {
            [sources addObject:[NSString stringWithFormat:@"c%@",[dict objectForKey:@"twitterID"]]];
        }
        
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        [currentInstallation removeObjectsInArray:sources forKey:@"urgentPush"];
        [currentInstallation saveInBackground];
        
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isUrgentPush"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (BOOL)connected
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return networkStatus != NotReachable;
}

-(void)setTheColor
{
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"currentColor"] == 1)
    {
        [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
        [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
        [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:50.0/255.0 green:50.0/255.0 blue:50.0/255.0 alpha:1.0]];
    }
    else if ([[NSUserDefaults standardUserDefaults] integerForKey:@"currentColor"] == 2)
    {
        [self.navigationController.navigationBar setBarStyle:UIBarStyleDefault];
        [self.navigationController.navigationBar setTintColor:[UIColor colorWithRed:37.0/255.0 green:37.0/255.0 blue:37.0/255.0 alpha:1.0]];
        [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:241.0/255.0 green:241.0/255.0 blue:241.0/255.0 alpha:1.0]];
    }
    else if ([[NSUserDefaults standardUserDefaults] integerForKey:@"currentColor"] == 3)
    {
        [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
        [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
        [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:33.0/255.0 green:125.0/255.0 blue:140.0/255.0 alpha:1.0]];
    }
    else if ([[NSUserDefaults standardUserDefaults] integerForKey:@"currentColor"] == 4)
    {
        [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
        [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
        [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:118.0/255.0 green:0.0/255.0 blue:161.0/255.0 alpha:1.0]];
    }
    else if ([[NSUserDefaults standardUserDefaults] integerForKey:@"currentColor"] == 5)
    {
        [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
        [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
        [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:26.0/255.0 green:140.0/255.0 blue:55.0/255.0 alpha:1.0]];
    }
    else if ([[NSUserDefaults standardUserDefaults] integerForKey:@"currentColor"] == 6)
    {
        [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
        [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
        [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:185.0/255.0 green:21.0/255.0 blue:57.0/255.0 alpha:1.0]];
    }
    else
    {
        [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
        [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
        [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:50.0/255.0 green:50.0/255.0 blue:50.0/255.0 alpha:1.0]];
    }
}

- (IBAction)saveSelectedColor:(id)sender {
    [self closeTheColorView];
}

- (IBAction)closeColorView:(id)sender {
    [[NSUserDefaults standardUserDefaults] setInteger:rowToSave+1 forKey:@"currentColor"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self setTheColor];
    [self closeTheColorView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
    
    if ([_BreakingNewsSwitch isOn] && ![[NSUserDefaults standardUserDefaults] boolForKey:@"isUrgentPush"])
    {
        isCellRemoved = YES;
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:1]]  withRowAnimation:UITableViewRowAnimationMiddle];
        [self unSubscribeForUrgentPush];
    }
    
    [_BreakingNewsSwitch setOn:[[NSUserDefaults standardUserDefaults] boolForKey:@"isUrgentPush"] animated:animated];
    
    [UIView animateWithDuration:0.1 delay:0.0 options:0
                     animations:^{
                         if ([[NSUserDefaults standardUserDefaults] integerForKey:@"currentColor"] == 1)
                         {
                             [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
                             [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
                             [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:50.0/255.0 green:50.0/255.0 blue:50.0/255.0 alpha:1.0]];
                         }
                         else if ([[NSUserDefaults standardUserDefaults] integerForKey:@"currentColor"] == 2)
                         {
                             [self.navigationController.navigationBar setBarStyle:UIBarStyleDefault];
                             [self.navigationController.navigationBar setTintColor:[UIColor colorWithRed:37.0/255.0 green:37.0/255.0 blue:37.0/255.0 alpha:1.0]];
                             [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:241.0/255.0 green:241.0/255.0 blue:241.0/255.0 alpha:1.0]];
                         }
                         else if ([[NSUserDefaults standardUserDefaults] integerForKey:@"currentColor"] == 3)
                         {
                             [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
                             [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
                             [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:33.0/255.0 green:125.0/255.0 blue:140.0/255.0 alpha:1.0]];
                         }
                         else if ([[NSUserDefaults standardUserDefaults] integerForKey:@"currentColor"] == 4)
                         {
                             [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
                             [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
                             [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:118.0/255.0 green:0.0/255.0 blue:161.0/255.0 alpha:1.0]];
                         }
                         else if ([[NSUserDefaults standardUserDefaults] integerForKey:@"currentColor"] == 5)
                         {
                             [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
                             [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
                             [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:26.0/255.0 green:140.0/255.0 blue:55.0/255.0 alpha:1.0]];
                         }
                         else if ([[NSUserDefaults standardUserDefaults] integerForKey:@"currentColor"] == 6)
                         {
                             [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
                             [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
                             [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:185.0/255.0 green:21.0/255.0 blue:57.0/255.0 alpha:1.0]];
                         }
                         else
                         {
                             [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
                             [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
                             [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:50.0/255.0 green:50.0/255.0 blue:50.0/255.0 alpha:1.0]];
                         }
                     }
                     completion:^(BOOL finished) {
                         //
                     }];
    [UIView commitAnimations];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 1)
    {
        if (isCellRemoved)
        {
            return 2;
        }
    }
    return 3;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger) section
{
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 40)];
    lbl.textAlignment = NSTextAlignmentRight;
    
    if (section == 0)
    {
        lbl.text = @"  عام";
    }
    else if (section == 1)
    {
        lbl.text = @"  التنبيهات";
    }
    else if (section == 2)
    {
        lbl.text = @"  المزيد";
    }
    
    [lbl setBackgroundColor:[UIColor clearColor]];
    [lbl setFont:[UIFont fontWithName:@"DroidArabicKufi" size:12.0]];
    [lbl setTextColor:[UIColor colorWithRed:157.0/255 green:157.0/255 blue:160.0/255 alpha:1.0]];
    
    return lbl;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0)
    {
        [self openColorView];
    }
    else if (indexPath.section == 2 && indexPath.row == 0)
    {
        [self contactUs];
    }
    else if (indexPath.section == 2 && indexPath.row == 1)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"youtubeLink"]]];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

-(void)contactUs
{
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
        
        picker.mailComposeDelegate = self;
        
        [picker setToRecipients:[NSArray arrayWithObject:@"men.almasdar@gmail.com"]];
        
        [picker setMessageBody:[@"\n\n\n\n\n\n\n\n" stringByAppendingFormat:@"المعلومات التالية تساعدنا في تحديد المشاكل بشكل أدق:\n----------\nIOS: %@\nDevice: %@\nApp Version: %.1f",[[UIDevice currentDevice] systemVersion],[self theDeviceType],[[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] floatValue]] isHTML:NO];
        
        [self presentViewController:picker animated:YES completion:nil];
        
    }
    else
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://sadah-sw.com/contacts.html"]];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSString *) theDeviceType
{
    NSString *platform;
    struct utsname systemInfo;
    uname(&systemInfo);
    platform = [NSString stringWithCString:systemInfo.machine
                                  encoding:NSUTF8StringEncoding];
    
    if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"])    return @"Verizon iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([platform isEqualToString:@"iPhone5,1"])    return @"iPhone 5 (GSM)";
    if ([platform isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone5,3"])    return @"iPhone 5c (GSM)";
    if ([platform isEqualToString:@"iPhone5,4"])    return @"iPhone 5c (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone6,1"])    return @"iPhone 5s (GSM)";
    if ([platform isEqualToString:@"iPhone6,2"])    return @"iPhone 5s (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([platform isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([platform isEqualToString:@"iPod5,1"])      return @"iPod Touch 5G";
    if ([platform isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([platform isEqualToString:@"iPad2,4"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    if ([platform isEqualToString:@"iPad2,6"])      return @"iPad Mini (GSM)";
    if ([platform isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([platform isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad3,3"])      return @"iPad 3 (GSM)";
    if ([platform isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([platform isEqualToString:@"iPad3,5"])      return @"iPad 4 (GSM)";
    if ([platform isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad4,1"])      return @"iPad Air (WiFi)";
    if ([platform isEqualToString:@"iPad4,2"])      return @"iPad Air (Cellular)";
    if ([platform isEqualToString:@"iPad4,3"])      return @"iPad Air";
    if ([platform isEqualToString:@"iPad4,4"])      return @"iPad Mini 2G (WiFi)";
    if ([platform isEqualToString:@"iPad4,5"])      return @"iPad Mini 2G (Cellular)";
    if ([platform isEqualToString:@"iPad4,6"])      return @"iPad Mini 2G";
    if ([platform isEqualToString:@"iPad4,7"])      return @"iPad Mini 3 (WiFi)";
    if ([platform isEqualToString:@"iPad4,8"])      return @"iPad Mini 3 (Cellular)";
    if ([platform isEqualToString:@"iPad4,9"])      return @"iPad Mini 3 (China)";
    if ([platform isEqualToString:@"iPad5,3"])      return @"iPad Air 2 (WiFi)";
    if ([platform isEqualToString:@"iPad5,4"])      return @"iPad Air 2 (Cellular)";
    if ([platform isEqualToString:@"AppleTV2,1"])   return @"Apple TV 2G";
    if ([platform isEqualToString:@"AppleTV3,1"])   return @"Apple TV 3";
    if ([platform isEqualToString:@"AppleTV3,2"])   return @"Apple TV 3 (2013)";
    if ([platform isEqualToString:@"i386"])         return @"Simulator";
    if ([platform isEqualToString:@"x86_64"])       return @"Simulator";
    return platform;
}

- (IBAction)soundChanged:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:_soundSwitch.isOn forKey:@"isSoundEffects"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)openColorView
{
    [_darkBackButton setAlpha:0.0];
    [[self.navigationController view] addSubview:_selectColorView];
    [_pickerView setTintColor:[UIColor blackColor]];
    [_pickerView reloadAllComponents];
    rowToSave = [self savedRow];
    [_pickerView selectRow:rowToSave inComponent:0 animated:NO];
    _selectColorView.frame = CGRectMake(self.navigationController.view.frame.origin.x, self.navigationController.view.frame.size.height, self.navigationController.view.frame.size.width, self.navigationController.view.frame.size.height);
    [UIView animateWithDuration:0.3 delay:0.0 options:0
                     animations:^{
                         _selectColorView.frame = self.navigationController.view.frame;
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.3 delay:0.0 options:0
                                          animations:^{
                                              [_darkBackButton setAlpha:0.3];
                                          }
                                          completion:^(BOOL finished) {
                                              
                                          }];
                         [UIView commitAnimations];
                     }];
    [UIView commitAnimations];
}

-(void)closeTheColorView
{
    [_darkBackButton setAlpha:0.0];
    [UIView animateWithDuration:0.3 delay:0.0 options:0
                     animations:^{
                         _selectColorView.frame = CGRectMake(self.navigationController.view.frame.origin.x, self.navigationController.view.frame.size.height, self.navigationController.view.frame.size.width, self.navigationController.view.frame.size.height);
                     }
                     completion:^(BOOL finished) {
                         [_selectColorView removeFromSuperview];
                         [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
                     }];
    [UIView commitAnimations];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)picker
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)picker numberOfRowsInComponent:(NSInteger)component
{
    return 6;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    CGRect rowFrame = CGRectMake(00.0f, 0.0f, [pickerView viewForRow:row forComponent:component].frame.size.width, [pickerView viewForRow:row forComponent:component].frame.size.height);
    UILabel *label = [[UILabel alloc] initWithFrame:rowFrame];
    label.font = [UIFont fontWithName:@"DroidArabicKufi-Bold" size:18.0];
    
    if (row == 0)
    {
        label.text = @"الأسود";
        label.textColor = [UIColor colorWithRed:50.0/255 green:50.0/255 blue:50.0/255 alpha:1.0];
    }
    else if (row == 1)
    {
        label.text = @"الأبيض";
        label.textColor = [UIColor colorWithRed:190.0/255 green:190.0/255 blue:190.0/255 alpha:1.0];
    }
    else if (row == 2)
    {
        label.text = @"الأزرق";
        label.textColor = [UIColor colorWithRed:33.0/255 green:125.0/255 blue:140.0/255 alpha:1.0];
    }
    else if (row == 3)
    {
        label.text = @"الأرجواني";
        label.textColor = [UIColor colorWithRed:118.0/255 green:0.0/255 blue:161.0/255 alpha:1.0];
    }
    else if (row == 4)
    {
        label.text = @"الأخضر";
        label.textColor = [UIColor colorWithRed:26.0/255 green:140.0/255 blue:55.0/255 alpha:1.0];
    }
    else if (row == 5)
    {
        label.text = @"الأحمر";
        label.textColor = [UIColor colorWithRed:185.0/255 green:21.0/255 blue:57.0/255 alpha:1.0];
    }
    
    label.textAlignment = NSTextAlignmentCenter;
    
    return label;
}


- (void)pickerView:(UIPickerView *)picker didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [[NSUserDefaults standardUserDefaults] setInteger:row+1 forKey:@"currentColor"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self setTheColor];
}

-(NSInteger)savedRow
{
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"currentColor"] > 0 && [[NSUserDefaults standardUserDefaults] integerForKey:@"currentColor"] < 7)return [[NSUserDefaults standardUserDefaults] integerForKey:@"currentColor"]-1;
    return 0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
