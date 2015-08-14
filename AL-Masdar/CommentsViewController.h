//
//  CommentsViewController.h
//
//  Created by Housein Jouhar on 8/10/15.
//  Copyright (c) 2015 SADAH Software Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFHTTPRequestOperationManager.h"
#import "CRToastManager.h"
#import "CRToast.h"

@interface CommentsViewController : UIViewController <UIActionSheetDelegate>
{
    NSMutableArray *dataSource;
    BOOL isViewOn,isTableOn;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITextField *userNameText;
@property (strong, nonatomic) IBOutlet UITextField *emailText;
@property (strong, nonatomic) IBOutlet UITextView *commentText;
@property (strong, nonatomic) IBOutlet UIButton *saveButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *topRightButton;
@property (strong, nonatomic) IBOutlet UINavigationItem *topNavLabel;
@property (strong, nonatomic) IBOutlet UIView *commentView;
@property (strong, nonatomic) IBOutlet UIButton *darkBackButton;
@property (strong, nonatomic) IBOutlet UIImageView *noCommentsImg;
@property (strong, nonatomic) IBOutlet UIImageView *anmImg;
@property (strong, nonatomic) IBOutlet UIButton *addCommentButton;
@property (strong, nonatomic) IBOutlet UILabel *starLabel;
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (strong, nonatomic) IBOutlet UIToolbar *sendToolBar;

@end