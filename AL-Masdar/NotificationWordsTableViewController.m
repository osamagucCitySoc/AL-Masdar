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
    
    sources = [[NSMutableArray alloc]init];
    
    NSArray* subs = [[NSUserDefaults standardUserDefaults] objectForKey:@"subscriptions"];
    for(NSDictionary* dict in subs)
    {
        [sources addObject:[dict objectForKey:@"twitterID"]];
    }
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [newWordTextField resignFirstResponder];
}
- (IBAction)addButtonClicked:(id)sender {
    [newWordTextField resignFirstResponder];
    if(newWordTextField.text.length < 3)
    {
        NSDictionary *options = @{
                                  kCRToastTextKey : @"يجب إدخال كلمة واحدة من ٣ أحرف على الأقل",
                                  kCRToastTextAlignmentKey : @(NSTextAlignmentCenter),
                                  kCRToastBackgroundColorKey : [UIColor redColor],
                                  kCRToastAnimationInTypeKey : @(CRToastAnimationTypeLinear),
                                  kCRToastAnimationOutTypeKey : @(CRToastAnimationTypeLinear),
                                  kCRToastAnimationInDirectionKey : @(CRToastAnimationDirectionTop),
                                  kCRToastAnimationOutDirectionKey : @(CRToastAnimationDirectionBottom),
                                  kCRToastAnimationInTimeIntervalKey: @(3)
                                  };
        [CRToastManager showNotificationWithOptions:options
                                    completionBlock:^{
                                        NSLog(@"Completed");
                                    }];
    }else
    {
        if(![self connected])
        {
            NSDictionary *options = @{
                                      kCRToastTextKey : @"يجب أن تكون متصلاً بالإنترنت",
                                      kCRToastTextAlignmentKey : @(NSTextAlignmentCenter),
                                      kCRToastBackgroundColorKey : [UIColor redColor],
                                      kCRToastAnimationInTypeKey : @(CRToastAnimationTypeLinear),
                                      kCRToastAnimationOutTypeKey : @(CRToastAnimationTypeLinear),
                                      kCRToastAnimationInDirectionKey : @(CRToastAnimationDirectionTop),
                                      kCRToastAnimationOutDirectionKey : @(CRToastAnimationDirectionBottom),
                                      kCRToastAnimationInTimeIntervalKey: @(3)
                                      };
            [CRToastManager showNotificationWithOptions:options
                                        completionBlock:^{
                                            NSLog(@"Completed");
                                        }];
            
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
            
            [self.tableView reloadData];
            [self.tableView setNeedsDisplay];
            
            
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


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellID = @"notifCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    if(!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    [[cell textLabel] setText:[[[NSUserDefaults standardUserDefaults] objectForKey:@"notifWords"] objectAtIndex:indexPath.row]];
    
    return cell;
}



- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        if(![self connected])
        {
            NSDictionary *options = @{
                                      kCRToastTextKey : @"يجب أن تكون متصلاً بالإنترنت",
                                      kCRToastTextAlignmentKey : @(NSTextAlignmentCenter),
                                      kCRToastBackgroundColorKey : [UIColor redColor],
                                      kCRToastAnimationInTypeKey : @(CRToastAnimationTypeLinear),
                                      kCRToastAnimationOutTypeKey : @(CRToastAnimationTypeLinear),
                                      kCRToastAnimationInDirectionKey : @(CRToastAnimationDirectionTop),
                                      kCRToastAnimationOutDirectionKey : @(CRToastAnimationDirectionBottom),
                                      kCRToastAnimationInTimeIntervalKey: @(3)
                                      };
            [CRToastManager showNotificationWithOptions:options
                                        completionBlock:^{
                                            NSLog(@"Completed");
                                        }];
            
        }else
        {
            NSString*word =[[[NSUserDefaults standardUserDefaults] objectForKey:@"notifWords"] objectAtIndex:indexPath.row];
            
            NSMutableArray* mutArray = [[NSMutableArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"notifWords"] copyItems:YES];
            [mutArray removeObjectAtIndex:indexPath.row];
            
            [[NSUserDefaults standardUserDefaults]setObject:mutArray forKey:@"notifWords"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            
            
            PFInstallation *currentInstallation = [PFInstallation currentInstallation];
            NSArray *subscribedChannels = currentInstallation.channels;
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
