//
//  NotificationWordsTableViewController.m
//  AL-Masdar
//
//  Created by Osama Rabie on 6/27/15.
//  Copyright (c) 2015 Osama Rabie. All rights reserved.
//

#import "NotificationWordsTableViewController.h"
#import <Parse/Parse.h>
#import "CRToastManager.h"
#import "CRToast.h"
#import "Reachability.h"

@interface NotificationWordsTableViewController ()

@end

@implementation NotificationWordsTableViewController
{
    
    __weak IBOutlet UITextField *newWordTextField;
    NSMutableArray* sources;
    __weak IBOutlet UIView *upperView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[self tableView] setEditing:YES];
    
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 44, 0);
    
    sources = [[NSMutableArray alloc]init];
    
    [[self.navigationController view] addSubview:upperView];
    [upperView setFrame:[[self.navigationController view] frame]];
    
    NSArray* subs = [[NSUserDefaults standardUserDefaults] objectForKey:@"subscriptions"];
    for(NSDictionary* dict in subs)
    {
        [sources addObject:[dict objectForKey:@"twitterID"]];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    //[newWordTextField becomeFirstResponder];
    
    
    [self.tableView setFrame:CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.tableView.frame.size.height)];
}

- (void)keyboardWillShow:(NSNotification *)notif
{
    CGRect keyboardSize = [[[notif userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    [upperView setFrame:CGRectMake(keyboardSize.origin.x, keyboardSize.origin.y-44, keyboardSize.size.width, keyboardSize.size.height)];
    
    [NSTimer scheduledTimerWithTimeInterval: 0.5
                                     target: self
                                   selector:@selector(showUpperView:)
                                   userInfo: nil repeats:NO];
}

- (void)keyboardWillHide:(NSNotification *)notif
{
    CGRect keyboardSize = [[[notif userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    [upperView setFrame:CGRectMake(keyboardSize.origin.x, keyboardSize.origin.y-44, keyboardSize.size.width, keyboardSize.size.height)];
}

-(void)showUpperView:(NSTimer *)timer {
    [upperView setHidden:NO];
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

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setTheColor];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"help2Done"])
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"help2Done"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [SADAHMsg showMsgWithTitle:@"التنبيه بكلمة أو جملة" andMsg:@"سيتم إرسال إشعار لك بكل الأخبار التي تحتوي الكلمة أو الجملة التي تحفظها هنا." inView:[self.navigationController view] withCase:1 withBlock:^(BOOL finished) {
            if(finished){
                [newWordTextField becomeFirstResponder];
            }
        }];
    }
    else
    {
        [newWordTextField becomeFirstResponder];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [newWordTextField resignFirstResponder];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [upperView removeFromSuperview];
    
 /*   CGRect frame = upperView.frame;
    frame.size.height = 44;
    [upperView setFrame:frame];
    [upperView setNeedsDisplay];
    
    
    CGRect frame2 = self.tableView.frame;
    frame2.origin.y = frame.origin.y+48;
    [self.tableView setFrame:frame2];
    [self.tableView setNeedsDisplay];*/
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (IBAction)addButtonClicked:(id)sender {
    if([newWordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length < 3)
    {
        [self showStatusBarMsg:@"يجب إدخال كلمة واحدة من ٣ أحرف على الأقل" isRed:YES];
    }else
    {
        if(![self connected])
        {
            [self showStatusBarMsg:@"يجب أن تكون متصلاً بالإنترنت" isRed:YES];
            
        }else
        {
            NSMutableArray* toBeAdded = [[NSMutableArray alloc]init];
            for(NSString* source in sources)
            {
                [toBeAdded addObject:[NSString stringWithFormat:@"%@-%@",source,newWordTextField.text]];
            }
            
            if(toBeAdded.count>0)
            {
                PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                [currentInstallation addUniqueObjectsFromArray:toBeAdded forKey:@"customChannels"];
                [currentInstallation saveInBackground];
                
            }
            
            NSMutableArray* mutArray = [[NSMutableArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"notifWords"] copyItems:YES];
            [mutArray addObject:newWordTextField.text];
            
            [[NSUserDefaults standardUserDefaults]setObject:mutArray forKey:@"notifWords"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:mutArray.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationMiddle];
            [self.tableView setNeedsDisplay];
            
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[[[NSUserDefaults standardUserDefaults] objectForKey:@"notifWords"] count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            
            [newWordTextField setText:@""];
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"notifWords"] count];
}

-(UIView *)tableView:(UITableView *)tableView2 viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView2.frame.size.width, 30)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView2.frame.size.width, 30)];
    [label setFont:[UIFont fontWithName:@"DroidArabicKufi" size:14.0]];
    [label setTextAlignment:NSTextAlignmentRight];
    [label setTextColor:[UIColor colorWithRed:85.0/255.0 green:85.0/255.0 blue:85.0/255.0 alpha:0.9]];
    
    [label setText:@"  سيتم تنبيهك بهذه الكلمات | الجمل"];
    
    [view addSubview:label];
    [view setBackgroundColor:[UIColor colorWithRed:230.0/255 green:230.0/255 blue:230.0/255 alpha:0.9]];
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellID = @"notifCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    if(!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    [[cell textLabel] setFont:[UIFont fontWithName:@"DroidArabicKufi" size:15.0]];
    
    [[cell textLabel] setText:[[[NSUserDefaults standardUserDefaults] objectForKey:@"notifWords"] objectAtIndex:indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        if(![self connected])
        {
            [self showStatusBarMsg:@"يجب أن تكون متصلاً بالإنترنت" isRed:YES];
            
        }else
        {
            NSString*word =[[[NSUserDefaults standardUserDefaults] objectForKey:@"notifWords"] objectAtIndex:indexPath.row];
            
            NSMutableArray* mutArray = [[NSMutableArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"notifWords"] copyItems:YES];
            [mutArray removeObjectAtIndex:indexPath.row];
            
            [[NSUserDefaults standardUserDefaults]setObject:mutArray forKey:@"notifWords"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
            
            
            PFInstallation *currentInstallation = [PFInstallation currentInstallation];
            NSArray *subscribedChannels = [currentInstallation objectForKey:@"customChannels"];
            NSMutableArray* toBeRemoved = [[NSMutableArray alloc]init];
            for(NSString* channel in subscribedChannels)
            {
                NSArray* dist = [channel componentsSeparatedByString:@"-"];
                
                if([[dist objectAtIndex:1] isEqualToString:word])
                {
                    [toBeRemoved addObject:channel];
                }
            }
            
            if(toBeRemoved.count>0)
            {
                [currentInstallation removeObjectsInArray:toBeRemoved forKey:@"customChannels"];
                [currentInstallation saveInBackground];
            }
        }
    }
}

- (BOOL)connected
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return networkStatus != NotReachable;
}

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
