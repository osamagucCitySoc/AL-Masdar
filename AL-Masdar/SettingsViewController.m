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
    
    [_BreakingNewsSwitch setOn:[[NSUserDefaults standardUserDefaults] boolForKey:@"isUrgentPush"]];
    [_soundSwitch setOn:[[NSUserDefaults standardUserDefaults] boolForKey:@"isSoundEffects"]];
}

- (IBAction)breakingNewsOnOff:(id)sender {
    if (_BreakingNewsSwitch.isOn)
    {
        [self subscribeForUrgentPush];
    }
    else
    {
        [self unSubscribeForUrgentPush];
    }
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
        
        NSArray* subs = [[NSUserDefaults standardUserDefaults] objectForKey:@"subscriptions"];
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
    
    [self setTheColor];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0 || section == 1)
    {
        return 2;
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
    [lbl setFont:[UIFont systemFontOfSize:14]];
    [lbl setTextColor:[UIColor colorWithRed:157.0/255 green:157.0/255 blue:160.0/255 alpha:1.0]];
    
    return lbl;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0)
    {
        [self openColorView];
    }
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
    label.font = [UIFont boldSystemFontOfSize:20.0f];
    
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
