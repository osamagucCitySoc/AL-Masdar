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
    
    NSMutableArray* myDataSource = [[NSMutableArray alloc]init];
    sectionedSource = [[NSMutableArray alloc]init];
    
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

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)sectionn
{
    NSDictionary* dict = [sectionedSource objectAtIndex:sectionn];
    return [[[dict objectForKey:[[dict allKeys] lastObject]] lastObject] objectForKey:@"subSection"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* cellID = @"sourceCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    
    if(!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    
    NSDictionary* dict = [sectionedSource objectAtIndex:indexPath.section];
    NSDictionary* dict2 = [[dict objectForKey:[[dict allKeys] lastObject]] objectAtIndex:indexPath.row];

    
    [[cell textLabel]setText:[dict2 objectForKey:@"name"]];
    
    
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"subscriptions"] containsObject:dict2])
    {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
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
    NSDictionary* dict = [sectionedSource objectAtIndex:indexPath.section];
    NSDictionary* dict2 = [[dict objectForKey:[[dict allKeys] lastObject]] objectAtIndex:indexPath.row];


    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"subscriptions"] containsObject:dict2])
    {
        [[self.tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryNone];
      
        NSMutableArray* mutArray = [[NSMutableArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"subscriptions"] copyItems:YES];
        [mutArray removeObject:dict2];
        
        [[NSUserDefaults standardUserDefaults]setObject:mutArray forKey:@"subscriptions"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        NSArray *subscribedChannels = currentInstallation.channels;
        NSMutableArray* toBeRemoved = [[NSMutableArray alloc]init];
        for(NSString* channel in subscribedChannels)
        {
            if([channel hasPrefix:[dict2 objectForKey:@"twitterID"]])
            {
                [toBeRemoved addObject:channel];
            }
        }

        if(toBeRemoved.count>0)
        {
            [currentInstallation removeObjectsInArray:toBeRemoved forKey:@"customChannels"];
            [currentInstallation saveInBackground];
        }
        
    }else
    {
        [[self.tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
        
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
