//
//  SourceChooserTableViewController.m
//  AL-Masdar
//
//  Created by Osama Rabie on 6/24/15.
//  Copyright (c) 2015 Osama Rabie. All rights reserved.
//

#import "SourceChooserTableViewController.h"
#import <Parse/Parse.h>
#import "Reachability.h"
#import "CRToastManager.h"
#import "CRToast.h"

@interface SourceChooserTableViewController ()

@end


@implementation SourceChooserTableViewController
{
    NSMutableArray* sectionedSource;
}

@synthesize country,dataSourcee,section;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTheColor];
    
    NSMutableArray* myDataSource = [[NSMutableArray alloc]init];
    sectionedSource = [[NSMutableArray alloc]init];
    
    if ([section isEqualToString:@"onlyMySources"])
    {
        [self setTitle:@"مصادرك المختارة"];
        
        NSMutableArray *mySourcee = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"subscriptions"]];
        NSMutableArray *filteredArr = [[NSMutableArray alloc] init];
        
        for(NSDictionary* dict in dataSourcee)
        {
            for (NSDictionary* dict2 in mySourcee)
            {
                if ([[dict objectForKey:@"twitterID"] isEqualToString:[dict2 objectForKey:@"twitterID"]])
                {
                    [filteredArr addObject:dict];
                }
            }
        }
        
        for(NSDictionary* dict in filteredArr)
        {
            [myDataSource addObject:dict];
        }
    }
    else
    {
        if(![country isEqualToString:@""])
        {
            [self setTitle:country];
        }else
        {
            [self setTitle:section];
        }
        
        for(NSDictionary* dict in dataSourcee)
        {
            if([[dict objectForKey:@"section"]isEqualToString:section])
            {
                [myDataSource addObject:dict];
            }else if([[dict objectForKey:@"countryAR"]isEqualToString:country])
            {
                [myDataSource addObject:dict];
            }
        }
    }
    
    NSArray *aSortedArray = [myDataSource sortedArrayUsingComparator:^(NSDictionary *obj1,NSDictionary *obj2) {
        NSString *num1 =[obj1 objectForKey:@"subSection"];
        NSString *num2 =[obj2 objectForKey:@"subSection"];
        return (NSComparisonResult) [num1 compare:num2 options:(NSNumericSearch)];
    }];
    
    myDataSource = [[NSMutableArray alloc]initWithArray:aSortedArray copyItems:YES];
    
    while(YES)
    {
        if(myDataSource.count == 0)
        {
            break;
        }
        NSMutableArray* groupArray = [[NSMutableArray alloc]init];
        
        NSDictionary* sampleDict = [myDataSource objectAtIndex:0];
        
        if(![groupArray containsObject:sampleDict])
        {
            [groupArray addObject:sampleDict];
        }
        [myDataSource removeObjectAtIndex:0];
        for(int k = 0 ; k <myDataSource.count ; k++)
        {
            NSDictionary* dict = [myDataSource objectAtIndex:k];
            if([[dict objectForKey:@"subSection"]isEqualToString:[sampleDict objectForKey:@"subSection"]])
            {
                if(![groupArray containsObject:dict])
                {
                    [groupArray addObject:dict];
                }
                k--;
                [myDataSource removeObject:dict];
            }else
            {
                
                NSArray *aSortedArray = [groupArray sortedArrayUsingComparator:^(NSDictionary *obj1,NSDictionary *obj2) {
                    NSString *num1 =[obj1 objectForKey:@"name"];
                    NSString *num2 =[obj2 objectForKey:@"name"];
                    return (NSComparisonResult) [num1 compare:num2 options:(NSNumericSearch)];
                }];
                
                groupArray = [[NSMutableArray alloc]initWithArray:aSortedArray copyItems:YES];

                
                NSDictionary* groupDict = [[NSDictionary alloc]initWithObjects:@[groupArray] forKeys:@[[sampleDict objectForKey:@"subSection"]]];
                [sectionedSource addObject:groupDict];
                
                groupArray = [[NSMutableArray alloc]init];
                
                break;
            }
        }
        
       // [myDataSource removeObjectsInArray:groupArray];
        
        if([groupArray count]>0)
        {
            NSArray *aSortedArray = [groupArray sortedArrayUsingComparator:^(NSDictionary *obj1,NSDictionary *obj2) {
                NSString *num1 =[obj1 objectForKey:@"name"];
                NSString *num2 =[obj2 objectForKey:@"name"];
                return (NSComparisonResult) [num1 compare:num2 options:(NSNumericSearch)];
            }];
            
            groupArray = [[NSMutableArray alloc]initWithArray:aSortedArray copyItems:YES];
            
            
            NSDictionary* groupDict = [[NSDictionary alloc]initWithObjects:@[groupArray] forKeys:@[[sampleDict objectForKey:@"subSection"]]];
            [sectionedSource addObject:groupDict];
            
            groupArray = [[NSMutableArray alloc]init];

        }
    }
    
   
    
    [self.tableView reloadData];
    [self.tableView setNeedsDisplay];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return sectionedSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionn {

    NSDictionary* dict = [sectionedSource objectAtIndex:sectionn];
    return [[dict objectForKey:[[dict allKeys] lastObject]] count];
}

-(UIView *)tableView:(UITableView *)tableView2 viewForHeaderInSection:(NSInteger)section2
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView2.frame.size.width, 30)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView2.frame.size.width, 30)];
    [label setFont:[UIFont fontWithName:@"DroidArabicKufi" size:14.0]];
    [label setTextAlignment:NSTextAlignmentRight];
    [label setTextColor:[UIColor colorWithRed:50.0/255.0 green:50.0/255.0 blue:50.0/255.0 alpha:1.0]];
    
    NSDictionary* dict = [sectionedSource objectAtIndex:section2];
    
    [label setText:[@"  " stringByAppendingFormat:@"%@",[[[dict objectForKey:[[dict allKeys] lastObject]] lastObject] objectForKey:@"subSection"]]];
    
    [view addSubview:label];
    [view setBackgroundColor:[UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:0.9]];
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* cellID = @"sourceCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    
    if(!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"settings-selected-back.png"]];
    
    NSDictionary* dict = [sectionedSource objectAtIndex:indexPath.section];
    NSDictionary* dict2 = [[dict objectForKey:[[dict allKeys] lastObject]] objectAtIndex:indexPath.row];
    
    [(UILabel*)[cell viewWithTag:1] setText:[dict2 objectForKey:@"name"]];
    
    if ([[dict2 objectForKey:@"descc"] length] == 0)
    {
        [(UILabel*)[cell viewWithTag:4] setText:@"--"];
    }
    else
    {
        [(UILabel*)[cell viewWithTag:4] setText:[dict2 objectForKey:@"descc"]];
    }
    
    [[[cell viewWithTag:2] layer] setCornerRadius:22];
    [cell viewWithTag:2].layer.shouldRasterize = YES;
    
    [(UIImageView*)[cell viewWithTag:2] hnk_setImageFromURL:[NSURL URLWithString:[dict2 objectForKey:@"icon"]] placeholder:nil];
    
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"subscriptions"] containsObject:dict2])
    {
        [(UIImageView*)[cell viewWithTag:3] setImage:[UIImage imageNamed:@"check-on.png"]];
    }
    else
    {
        [(UIImageView*)[cell viewWithTag:3] setImage:[UIImage imageNamed:@"check-off.png"]];
    }
    
    return cell;
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(![self connected])
    {
        [self showStatusBarMsg:@"يجب أن تكون متصلاً بالإنترنت" isRed:YES];
        
    }else
    {
        NSDictionary* dict = [sectionedSource objectAtIndex:indexPath.section];
        NSDictionary* dict2 = [[dict objectForKey:[[dict allKeys] lastObject]] objectAtIndex:indexPath.row];
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        if([[[NSUserDefaults standardUserDefaults] objectForKey:@"subscriptions"] containsObject:dict2])
        {
            [UIView animateWithDuration:0.2 delay:0.0 options:0
                             animations:^{
                                 [[cell viewWithTag:3] setTransform:CGAffineTransformMakeScale(0.7, 0.7)];
                                 [(UIImageView*)[cell viewWithTag:3] setImage:[UIImage imageNamed:@"check-off.png"]];
                             }
                             completion:^(BOOL finished) {
                                 [UIView animateWithDuration:0.1 delay:0.0 options:0
                                                  animations:^{
                                                      [[cell viewWithTag:3] setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
                                                  }
                                                  completion:^(BOOL finished) {
                                                  }];
                                 [UIView commitAnimations];
                             }];
            [UIView commitAnimations];
            
            
            
            NSMutableArray* mutArray = [[NSMutableArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"subscriptions"] copyItems:YES];
            [mutArray removeObject:dict2];
            
            [[NSUserDefaults standardUserDefaults]setObject:mutArray forKey:@"subscriptions"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            PFInstallation *currentInstallation = [PFInstallation currentInstallation];
            NSArray *subscribedChannels = [currentInstallation objectForKey:@"customChannels"];
            NSMutableArray* toBeRemoved = [[NSMutableArray alloc]init];
            for(NSString* channel in subscribedChannels)
            {
                if([channel hasPrefix:[dict2 objectForKey:@"twitterID"]])
                {
                    [toBeRemoved addObject:channel];
                }
            }
            
            if([[NSUserDefaults standardUserDefaults] boolForKey:@"isUrgentPush"])
            {
                [currentInstallation removeObject:[NSString stringWithFormat:@"c%@",[dict2 objectForKey:@"twitterID"]] forKey:@"urgentPush"];
                [currentInstallation saveInBackground];
            }
            
            if(toBeRemoved.count>0)
            {
                [currentInstallation removeObjectsInArray:toBeRemoved forKey:@"customChannels"];
                [currentInstallation saveInBackground];
            }
            
        }else
        {
            [UIView animateWithDuration:0.2 delay:0.0 options:0
                             animations:^{
                                 [[cell viewWithTag:3] setTransform:CGAffineTransformMakeScale(1.3, 1.3)];
                                 [(UIImageView*)[cell viewWithTag:3] setImage:[UIImage imageNamed:@"check-on.png"]];
                             }
                             completion:^(BOOL finished) {
                                 [UIView animateWithDuration:0.1 delay:0.0 options:0
                                                  animations:^{
                                                      [[cell viewWithTag:3] setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
                                                  }
                                                  completion:^(BOOL finished) {
                                                  }];
                                 [UIView commitAnimations];
                             }];
            [UIView commitAnimations];
            
            NSMutableArray* mutArray = [[NSMutableArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"subscriptions"] copyItems:YES];
            [mutArray addObject:dict2];
            
            [[NSUserDefaults standardUserDefaults]setObject:mutArray forKey:@"subscriptions"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            NSArray* words = [[NSUserDefaults standardUserDefaults] objectForKey:@"notifWords"];
            NSMutableArray* toBeAdded = [[NSMutableArray alloc]init];
            
            for(NSString* word in words)
            {
                [toBeAdded addObject:[NSString stringWithFormat:@"%@-%@",[dict2 objectForKey:@"twitterID"],word]];
            }
            
            if([[NSUserDefaults standardUserDefaults] boolForKey:@"isUrgentPush"])
            {
                PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                [currentInstallation addUniqueObject:[NSString stringWithFormat:@"c%@",[dict2 objectForKey:@"twitterID"]] forKey:@"urgentPush"];
                [currentInstallation saveInBackground];
            }
            
            if(toBeAdded.count>0)
            {
                PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                [currentInstallation addUniqueObjectsFromArray:toBeAdded forKey:@"customChannels"];
                [currentInstallation saveInBackground];
                
            }
            
        }
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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

- (BOOL)connected
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return networkStatus != NotReachable;
}

@end
