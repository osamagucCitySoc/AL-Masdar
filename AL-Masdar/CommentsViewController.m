//
//  CommentsViewController.m
//
//  Created by Housein Jouhar on 8/10/15.
//  Copyright (c) 2015 SADAH Software Solutions. All rights reserved.
//

#import "CommentsViewController.h"

@interface CommentsViewController ()

@end

@implementation CommentsViewController
{
    NSString* copStr;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _commentText.tintColor = [UIColor colorWithRed:70.0/255.0 green:70.0/255.0 blue:70.0/255.0 alpha:1.0];
    _userNameText.tintColor = [UIColor colorWithRed:70.0/255.0 green:70.0/255.0 blue:70.0/255.0 alpha:1.0];
    _emailText.tintColor = [UIColor colorWithRed:70.0/255.0 green:70.0/255.0 blue:70.0/255.0 alpha:1.0];
    
    [_commentText setBackgroundColor:[UIColor colorWithRed:241.0/255.0 green:241.0/255.0 blue:241.0/255.0 alpha:1.0]];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isNightOn"])
    {
        [self.tableView setSeparatorColor:[UIColor colorWithRed:20.0/255.0 green:20.0/255.0 blue:20.0/255.0 alpha:1.0]];
        
        [self.tableView setBackgroundColor:[UIColor colorWithRed:70.0/255.0 green:70.0/255.0 blue:70.0/255.0 alpha:1.0]];
        
        [_mainView setBackgroundColor:[UIColor colorWithRed:50.0/255.0 green:50.0/255.0 blue:50.0/255.0 alpha:1.0]];
        [_commentView setBackgroundColor:[UIColor colorWithRed:50.0/255.0 green:50.0/255.0 blue:50.0/255.0 alpha:1.0]];
        
        _userNameText.textColor = [UIColor colorWithRed:50.0/255.0 green:50.0/255.0 blue:50.0/255.0 alpha:1.0];
        _emailText.textColor = [UIColor colorWithRed:50.0/255.0 green:50.0/255.0 blue:50.0/255.0 alpha:1.0];
        
        [_commentText setKeyboardAppearance:UIKeyboardAppearanceDark];
        [_userNameText setKeyboardAppearance:UIKeyboardAppearanceDark];
        [_emailText setKeyboardAppearance:UIKeyboardAppearanceDark];
        
        [_userNameText setBackgroundColor:[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0]];
        [_emailText setBackgroundColor:[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0]];
        
        [_noCommentsImg setTintColor:[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0]];
        
        _noCommentsImg.image = [[UIImage imageNamed:@"no-comments-img.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        
        [_sendToolBar setBackgroundColor:[UIColor blackColor]];
        [_sendToolBar setBarTintColor:[UIColor blackColor]];
        [_sendToolBar setTintColor:[UIColor whiteColor]];
        
        [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:70.0/255.0 green:70.0/255.0 blue:70.0/255.0 alpha:1.0]];
        [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
        [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    }
    else
    {
        [self.tableView setSeparatorColor:[UIColor colorWithRed:210.0/255.0 green:210.0/255.0 blue:210.0/255.0 alpha:1.0]];
        
        [self.tableView setBackgroundColor:[UIColor colorWithRed:241.0/255.0 green:241.0/255.0 blue:241.0/255.0 alpha:1.0]];
        
        [_mainView setBackgroundColor:[UIColor colorWithRed:241.0/255.0 green:241.0/255.0 blue:241.0/255.0 alpha:1.0]];
        [_commentView setBackgroundColor:[UIColor colorWithRed:241.0/255.0 green:241.0/255.0 blue:241.0/255.0 alpha:1.0]];
        
        _userNameText.textColor = [UIColor colorWithRed:37.0/255.0 green:37.0/255.0 blue:37.0/255.0 alpha:1.0];
        _emailText.textColor = [UIColor colorWithRed:37.0/255.0 green:37.0/255.0 blue:37.0/255.0 alpha:1.0];
        
        [_commentText setKeyboardAppearance:UIKeyboardAppearanceLight];
        [_userNameText setKeyboardAppearance:UIKeyboardAppearanceLight];
        [_emailText setKeyboardAppearance:UIKeyboardAppearanceLight];
        
        [_userNameText setBackgroundColor:[UIColor whiteColor]];
        [_emailText setBackgroundColor:[UIColor whiteColor]];
        
        [_sendToolBar setBackgroundColor:[UIColor colorWithRed:241.0/255.0 green:241.0/255.0 blue:241.0/255.0 alpha:1.0]];
        [_sendToolBar setBarTintColor:[UIColor colorWithRed:241.0/255.0 green:241.0/255.0 blue:241.0/255.0 alpha:1.0]];
        [_sendToolBar setTintColor:[UIColor colorWithRed:85.0/255.0 green:85.0/255.0 blue:85.0/255.0 alpha:1.0]];
        
        [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:241.0/255.0 green:241.0/255.0 blue:241.0/255.0 alpha:1.0]];
        [self.navigationController.navigationBar setBarStyle:UIBarStyleDefault];
        [self.navigationController.navigationBar setTintColor:[UIColor blackColor]];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.backgroundView = [UIView new];
    self.tableView.backgroundView.backgroundColor = [UIColor clearColor];
    
    dataSource = [[NSMutableArray alloc] init];
    
    [self addActivityView];
    
    [self loadComments];
}

-(void)loadComments
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSLog(@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"commentsId"]);
    
    NSDictionary *params = @{@"id":[[NSUserDefaults standardUserDefaults] objectForKey:@"commentsId"]};
    
    [manager POST:@"http://almasdarapp.com/almasdar/getComments.php" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        dataSource = [[NSMutableArray alloc]initWithArray:[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil]];
        
        [self removeActivityView];
        
        if (dataSource.count == 0)
        {
            [_noCommentsImg setHidden:NO];
            [_addCommentButton setHidden:NO];
            [self.tableView setHidden:YES];
        }
        else
        {
            [_topNavLabel setTitle:[@"التعليقات " stringByAppendingFormat:@"(%lu)",(unsigned long)dataSource.count]];
            
            [_noCommentsImg setHidden:YES];
            [_addCommentButton setHidden:YES];
            [self.tableView setHidden:NO];
            
            [self.tableView reloadData];
            
            if (!isTableOn)
            {
                isTableOn = YES;
                [self.tableView setFrame:CGRectMake(self.tableView.frame.origin.x, self.navigationController.view.frame.size.height, self.tableView.frame.size.width, self.tableView.frame.size.height)];
                
                [UIView animateWithDuration:0.2 delay:0.0 options:0
                                 animations:^{
                                     [self.tableView setFrame:CGRectMake(self.tableView.frame.origin.x, 0, self.tableView.frame.size.width, self.tableView.frame.size.height)];
                                 }
                                 completion:^(BOOL finished) {
                                     //
                                 }];
                [UIView commitAnimations];
            }
        }
        
        NSLog(@"%@",dataSource);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"GET COMMENTS ERROR: %@",error.debugDescription);
    }];
}

-(void)postComment:(NSString*)theComment withUserName:(NSString*)userName andEmail:(NSString*)theEmail
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSDictionary* params = @{@"id":[[NSUserDefaults standardUserDefaults] objectForKey:@"commentsId"],@"comment":theComment,@"username":userName,@"email":theEmail};
    
    [manager POST:@"http://almasdarapp.com/almasdar/submitComment.php" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self showStatusBarMsg:@"تم إضافة التعليق بنجاح" isRed:NO];
        
        [self loadComments];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"POST ERROR: %@",error.debugDescription);
        [self showStatusBarMsg:@"لم تتم اضافة التعليق" isRed:YES];
        
        [self loadComments];
    }];
}

-(void)changeAddButton:(BOOL)isPost isHideIt:(BOOL)isHide
{
    if (isHide)
    {
        _topRightButton = [[UIBarButtonItem alloc]initWithTitle:@" " style:UIBarButtonItemStylePlain target:self action:@selector(addComment:)];
        [_topRightButton setEnabled:NO];
        self.navigationItem.rightBarButtonItem = _topRightButton;
        return;
    }
    else
    {
        [_topRightButton setEnabled:YES];
    }
    
    if (isPost)
    {
        _topRightButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"send-icon.png"] style:UIBarButtonItemStylePlain target:self action:(@selector(postTheComment:))];
        self.navigationItem.rightBarButtonItem = _topRightButton;
    }
    else
    {
        _topRightButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(addComment:)];
        self.navigationItem.rightBarButtonItem = _topRightButton;
    }
}

-(void)addActivityView
{
    UIImage *img = [UIImage animatedImageWithImages:[NSArray arrayWithObjects:[UIImage imageNamed:[[self waitImgName] stringByAppendingString:@"wait-img-1.png"]], [UIImage imageNamed:[[self waitImgName] stringByAppendingString:@"wait-img-2.png"]],[UIImage imageNamed:[[self waitImgName] stringByAppendingString:@"wait-img-3.png"]],nil] duration:0.6];
    [_anmImg setHidden:NO];
    [_anmImg setImage:img];
    [_anmImg startAnimating];
}

-(void)removeActivityView
{
    [_anmImg stopAnimating];
    [_anmImg setHidden:YES];
}

-(NSString*)waitImgName
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isNightOn"])
    {
        return @"night-";
    }
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"currentColor"] == 3)
    {
        return @"blue-";
    }
    else if ([[NSUserDefaults standardUserDefaults] integerForKey:@"currentColor"] == 4)
    {
        return @"purple-";
    }
    else if ([[NSUserDefaults standardUserDefaults] integerForKey:@"currentColor"] == 5)
    {
        return @"green-";
    }
    else if ([[NSUserDefaults standardUserDefaults] integerForKey:@"currentColor"] == 6)
    {
        return @"red-";
    }
    
    return @"black-";
}

- (IBAction)addComment:(id)sender {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"infoSaved"])
    {
        [self showCommentView];
    }
    else
    {
        [self showLogInView];
    }
}

- (IBAction)postTheComment:(id)sender {
    if ([[_commentText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0)
    {
        [self showStatusBarMsg:@"أضف تعليقك على الخبر أولا" isRed:YES];
        return;
    }
    
    [self closeCommentView];
    
    [self.tableView setHidden:YES];
    [self addActivityView];
    
    [self postComment:_commentText.text withUserName:[[NSUserDefaults standardUserDefaults] objectForKey:@"currentUserName"] andEmail:[[NSUserDefaults standardUserDefaults] objectForKey:@"currentUserEmail"]];
    
    _commentText.text = @"";
}

- (IBAction)editMyInfo:(id)sender {
    [self showLogInView];
}

- (IBAction)saveUserInfo:(id)sender {
    if ([[_userNameText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0)
    {
        [self showStatusBarMsg:@"يجب إدخال اسم المستخدم" isRed:YES];
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:_userNameText.text forKey:@"currentUserName"];
    [[NSUserDefaults standardUserDefaults] setObject:_emailText.text forKey:@"currentUserEmail"];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"infoSaved"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self showCommentView];
}

-(void)showLogInView
{
    [self changeAddButton:NO isHideIt:YES];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"infoSaved"])
    {
        [_topNavLabel setTitle:@"تعديل البيانات"];
        _userNameText.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"currentUserName"];
        _emailText.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"currentUserEmail"];
    }
    else
    {
        [_topNavLabel setTitle:@"إضافة البيانات"];
    }
    
    if (isViewOn)
    {
        [UIView animateWithDuration:0.2 delay:0.0 options:0
                         animations:^{
                             [_darkBackButton setAlpha:0.0];
                             [_commentView setFrame:CGRectMake(_commentView.frame.origin.x, -135, _commentView.frame.size.width, 135)];
                         }
                         completion:^(BOOL finished) {
                             [_commentView setHidden:NO];
                             [_starLabel setHidden:NO];
                             [_userNameText setHidden:NO];
                             [_emailText setHidden:NO];
                             [_saveButton setHidden:NO];
                             [_commentText setHidden:YES];
                             [UIView animateWithDuration:0.2 delay:0.0 options:0
                                              animations:^{
                                                  [_darkBackButton setAlpha:0.8];
                                                  [_commentView setFrame:CGRectMake(_commentView.frame.origin.x, 0, _commentView.frame.size.width, 135)];
                                              }
                                              completion:^(BOOL finished) {
                                                  [_userNameText becomeFirstResponder];
                                              }];
                             [UIView commitAnimations];
                         }];
        [UIView commitAnimations];
        
        return;
    }
    
    [_darkBackButton setHidden:NO];
    [_darkBackButton setAlpha:0.0];
    [_commentView setHidden:NO];
    [_commentView setFrame:CGRectMake(_commentView.frame.origin.x, -135, _commentView.frame.size.width, 135)];
    [_starLabel setHidden:NO];
    [_userNameText setHidden:NO];
    [_emailText setHidden:NO];
    [_saveButton setHidden:NO];
    [_commentText setHidden:YES];
    
    [UIView animateWithDuration:0.2 delay:0.0 options:0
                     animations:^{
                         [_darkBackButton setAlpha:0.8];
                         [_commentView setFrame:CGRectMake(_commentView.frame.origin.x, 0, _commentView.frame.size.width, 135)];
                     }
                     completion:^(BOOL finished) {
                         [_userNameText becomeFirstResponder];
                     }];
    [UIView commitAnimations];
    
    isViewOn = YES;
}

-(void)showCommentView
{
    [_topNavLabel setTitle:@"إضافة تعليق"];
    
    [self changeAddButton:YES isHideIt:NO];
    
    if (isViewOn)
    {
        [UIView animateWithDuration:0.2 delay:0.0 options:0
                         animations:^{
                             [_darkBackButton setAlpha:0.0];
                             [_commentView setFrame:CGRectMake(_commentView.frame.origin.x, -200, _commentView.frame.size.width, 200)];
                             _commentText.inputAccessoryView = _sendToolBar;
                         }
                         completion:^(BOOL finished) {
                             [_commentView setHidden:NO];
                             [_starLabel setHidden:YES];
                             [_userNameText setHidden:YES];
                             [_emailText setHidden:YES];
                             [_saveButton setHidden:YES];
                             [_commentText setHidden:NO];
                             [UIView animateWithDuration:0.2 delay:0.0 options:0
                                              animations:^{
                                                  [_darkBackButton setAlpha:0.8];
                                                  [_commentView setFrame:CGRectMake(_commentView.frame.origin.x, 0, _commentView.frame.size.width, 200)];
                                              }
                                              completion:^(BOOL finished) {
                                                  [_commentText becomeFirstResponder];
                                              }];
                             [UIView commitAnimations];
                         }];
        [UIView commitAnimations];
        
        return;
    }
    
    [_darkBackButton setHidden:NO];
    [_darkBackButton setAlpha:0.0];
    [_commentView setHidden:NO];
    [_commentView setFrame:CGRectMake(_commentView.frame.origin.x, -200, _commentView.frame.size.width, 200)];
    [_starLabel setHidden:YES];
    [_userNameText setHidden:YES];
    [_emailText setHidden:YES];
    [_saveButton setHidden:YES];
    [_commentText setHidden:NO];
    
    [UIView animateWithDuration:0.2 delay:0.0 options:0
                     animations:^{
                         [_darkBackButton setAlpha:0.8];
                         [_commentView setFrame:CGRectMake(_commentView.frame.origin.x, 0, _commentView.frame.size.width, 200)];
                         _commentText.inputAccessoryView = _sendToolBar;
                     }
                     completion:^(BOOL finished) {
                         [_commentText becomeFirstResponder];
                     }];
    [UIView commitAnimations];
    
    isViewOn = YES;
}

-(void)closeCommentView
{
    [_topNavLabel setTitle:[@"التعليقات " stringByAppendingFormat:@"(%lu)",(unsigned long)dataSource.count]];
    
    [self changeAddButton:NO isHideIt:NO];
    
    isViewOn = NO;
    
    [_commentText resignFirstResponder];
    [_userNameText resignFirstResponder];
    [_emailText resignFirstResponder];
    
    [UIView animateWithDuration:0.2 delay:0.0 options:0
                     animations:^{
                         [_darkBackButton setAlpha:0.0];
                         [_commentView setFrame:CGRectMake(_commentView.frame.origin.x, -_commentView.frame.size.height, _commentView.frame.size.width, _commentView.frame.size.height)];
                     }
                     completion:^(BOOL finished) {
                         [_darkBackButton setHidden:YES];
                     }];
    [UIView commitAnimations];
}

- (IBAction)closeComments:(id)sender {
    if (isViewOn)
    {
        [self closeCommentView];
        return;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *commentsDict = [dataSource objectAtIndex:indexPath.row];
    
    return [self heightForText:[commentsDict objectForKey:@"comment"]];
}

-(CGFloat)heightForText:(NSString *)text
{
    UITextView * textView = [[UITextView alloc] initWithFrame: CGRectMake(0, 0, self.tableView.frame.size.width-16, 2000)];
    textView.text = text;
    textView.font = [UIFont fontWithName:@"DroidArabicKufi" size:14.0];
    [textView sizeToFit];
    return textView.frame.size.height+50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellID = @"commentCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    if(!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isNightOn"])
    {
        cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"settings-selected-back.png"]];
        
        [cell setBackgroundColor:[UIColor colorWithRed:70.0/255.0 green:70.0/255.0 blue:70.0/255.0 alpha:1.0]];
        
        [(UILabel*)[cell viewWithTag:1] setHighlightedTextColor:[UIColor whiteColor]];
        [(UILabel*)[cell viewWithTag:2] setHighlightedTextColor:[UIColor whiteColor]];
        
        [(UILabel*)[cell viewWithTag:2] setTextColor:[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0]];
    }
    else
    {
        cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"news-selected-back.png"]];
        
        [cell setBackgroundColor:[UIColor colorWithRed:241.0/255.0 green:241.0/255.0 blue:241.0/255.0 alpha:1.0]];
        
        [(UILabel*)[cell viewWithTag:1] setHighlightedTextColor:[UIColor blackColor]];
        [(UILabel*)[cell viewWithTag:2] setHighlightedTextColor:[UIColor blackColor]];
        
        [(UILabel*)[cell viewWithTag:2] setTextColor:[UIColor colorWithRed:37.0/255.0 green:37.0/255.0 blue:37.0/255.0 alpha:1.0]];
    }
    
    
    NSDictionary *commentsDict = [dataSource objectAtIndex:indexPath.row];
    
    [(UILabel*)[cell viewWithTag:2] setNumberOfLines:100];
    
    [(UILabel*)[cell viewWithTag:1] setText:[commentsDict objectForKey:@"username"]];
    
    [(UILabel*)[cell viewWithTag:2] setText:[commentsDict objectForKey:@"comment"]];
    
    [(UILabel*)[cell viewWithTag:2] setFrame:CGRectMake([cell viewWithTag:2].frame.origin.x, [cell viewWithTag:2].frame.origin.y, [cell viewWithTag:2].frame.size.width, [(UILabel*)[cell viewWithTag:2] sizeThatFits:CGSizeMake([cell viewWithTag:2].frame.size.width, CGFLOAT_MAX)].height)];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [dataSource count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *commentsDict = [dataSource objectAtIndex:indexPath.row];
    copStr = [commentsDict objectForKey:@"comment"];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"خيارات" delegate:self cancelButtonTitle:@"إلغاء" destructiveButtonTitle:nil otherButtonTitles:@"نسخ التعليق",nil];
    [actionSheet setTag:11];
    [actionSheet showInView:self.navigationController.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex  {
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    switch (buttonIndex) {
        case 0:
        {
            if (actionSheet.tag == 11)
            {
                [[UIPasteboard generalPasteboard] setString:copStr];
            }
        }
    }
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end