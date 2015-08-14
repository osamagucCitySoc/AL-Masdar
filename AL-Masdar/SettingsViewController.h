//
//  SettingsViewController.h
//
//  Created by Housein Jouhar on 7/3/15.
//  Copyright (c) 2015 SADAH Software Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CRToastManager.h"
#import "CRToast.h"
#import <Parse/Parse.h>
#import "Reachability.h"
#import <MessageUI/MFMailComposeViewController.h>
#import <sys/utsname.h>

@interface SettingsViewController : UITableViewController <MFMailComposeViewControllerDelegate>
{
    NSInteger rowToSave;
    BOOL isCellRemoved,isDidDone;
}

@property (strong, nonatomic) IBOutlet UITableViewCell *cell1;
@property (strong, nonatomic) IBOutlet UITableViewCell *cell2;
@property (strong, nonatomic) IBOutlet UITableViewCell *cell3;
@property (strong, nonatomic) IBOutlet UITableViewCell *cell4;
@property (strong, nonatomic) IBOutlet UITableViewCell *cell5;
@property (strong, nonatomic) IBOutlet UITableViewCell *cell6;
@property (strong, nonatomic) IBOutlet UIView *selectColorView;
@property (strong, nonatomic) IBOutlet UIButton *darkBackButton;
@property (strong, nonatomic) IBOutlet UIPickerView *pickerView;
@property (strong, nonatomic) IBOutlet UISwitch *BreakingNewsSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *soundSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *nightSwitch;

@end
