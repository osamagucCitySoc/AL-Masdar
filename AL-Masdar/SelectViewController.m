//
//  SelectViewController.m
//
//  Created by Housein Jouhar on 7/3/15.
//  Copyright (c) 2015 SADAH Software Solutions. All rights reserved.
//

#import "SelectViewController.h"

@interface SelectViewController ()

@end

@implementation SelectViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    sourcesArray = [[NSMutableArray alloc] init];
    idArray = [[NSMutableArray alloc] init];
    selectedArray = [[NSMutableArray alloc] init];
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"breakingSubscriptions"] || [[[NSUserDefaults standardUserDefaults] objectForKey:@"breakingSubscriptions"] count] == 0)
    {
        [[NSUserDefaults standardUserDefaults] setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"subscriptions"] forKey:@"breakingSubscriptions"];
    }
    
    dictArray = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"subscriptions"]];
    NSMutableArray *currentSubs = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"breakingSubscriptions"]];
    NSDictionary *news;
    
    selectedCount = dictArray.count;
    
    for (int i = 0; i < dictArray.count; i++)
    {
        news = [dictArray objectAtIndex:i];
        
        [sourcesArray addObject:[news objectForKey:@"name"]];
        [idArray addObject:[news objectForKey:@"twitterID"]];
        
        if ([currentSubs containsObject:news])
        {
            [selectedArray addObject:[news objectForKey:@"twitterID"]];
        }
        else
        {
            [selectedArray addObject:@"NO"];
            selectedCount--;
        }
    }
    
    if (selectedCount < idArray.count)
    {
        [_selectAllButton setTitle:@"تحديد الكل"];
    }
    else
    {
        [_selectAllButton setTitle:@"إلغاء الكل"];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self saveAllSources];
}

- (IBAction)selectAllSources:(id)sender {
    if (selectedCount < idArray.count)
    {
        NSLog(@"Select All");
        [_selectAllButton setTitle:@"إلغاء الكل"];
        selectedCount = idArray.count;
        
        for (int i = 0; i < selectedArray.count; i++)
        {
            [selectedArray replaceObjectAtIndex:i withObject:[idArray objectAtIndex:i]];
        }
        
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        [currentInstallation addUniqueObjectsFromArray:idArray forKey:@"urgentPush"];
        [currentInstallation saveInBackground];
        
        [[NSUserDefaults standardUserDefaults] setObject:dictArray forKey:@"breakingSubscriptions"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
    {
        NSLog(@"Deselect All");
        [_selectAllButton setTitle:@"تحديد الكل"];
        selectedCount = 0;
        
        for (int i = 0; i < selectedArray.count; i++)
        {
            [selectedArray replaceObjectAtIndex:i withObject:@"NO"];
        }
        
        NSMutableArray *currentSubs = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"breakingSubscriptions"]];
        NSMutableArray *soucresArr = [[NSMutableArray alloc] init];
        
        for(NSDictionary* dict in currentSubs)
        {
            [soucresArr addObject:[NSString stringWithFormat:@"c%@",[dict objectForKey:@"twitterID"]]];
        }
        
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        [currentInstallation removeObjectsInArray:idArray forKey:@"urgentPush"];
        [currentInstallation removeObjectsInArray:soucresArr forKey:@"urgentPush"];
        [currentInstallation saveInBackground];
        
        [[NSUserDefaults standardUserDefaults] setObject:[[NSMutableArray alloc] init] forKey:@"breakingSubscriptions"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [[self tableView] reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return sourcesArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* cellID = @"sourcesCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    
    if(!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    [(UILabel*)[cell viewWithTag:1] setText:[sourcesArray objectAtIndex:indexPath.row]];
    
    if([[selectedArray objectAtIndex:indexPath.row] isEqualToString:@"NO"])
    {
        [(UIImageView*)[cell viewWithTag:2] setImage:[UIImage imageNamed:@"check-off.png"]];
    }
    else
    {
        [(UIImageView*)[cell viewWithTag:2] setImage:[UIImage imageNamed:@"check-on.png"]];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isUrgentPush"])
    {
        NSMutableArray *currentSubs = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"breakingSubscriptions"]];
        NSMutableArray *soucresArr = [[NSMutableArray alloc] init];
        
        for(NSDictionary* dict in currentSubs)
        {
            [soucresArr addObject:[NSString stringWithFormat:@"c%@",[dict objectForKey:@"twitterID"]]];
        }
        
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        [currentInstallation removeObjectsInArray:soucresArr forKey:@"urgentPush"];
        [currentInstallation removeObjectsInArray:idArray forKey:@"urgentPush"];
        [currentInstallation saveInBackground];
    }
    
    if([[selectedArray objectAtIndex:indexPath.row] isEqualToString:@"NO"])
    {
        selectedCount++;
        [selectedArray replaceObjectAtIndex:indexPath.row withObject:[idArray objectAtIndex:indexPath.row]];
        [(UIImageView*)[cell viewWithTag:2] setImage:[UIImage imageNamed:@"check-on.png"]];
        [UIView animateWithDuration:0.2 delay:0.0 options:0
                         animations:^{
                             [[cell viewWithTag:2] setTransform:CGAffineTransformMakeScale(1.3, 1.3)];
                         }
                         completion:^(BOOL finished) {
                             [UIView animateWithDuration:0.1 delay:0.0 options:0
                                              animations:^{
                                                  [[cell viewWithTag:2] setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
                                              }
                                              completion:^(BOOL finished) {
                                                  [self setNewSource:[idArray objectAtIndex:indexPath.row] andIsAdd:YES];
                                                  [tableView deselectRowAtIndexPath:indexPath animated:YES];
                                              }];
                             [UIView commitAnimations];
                         }];
        [UIView commitAnimations];
    }
    else
    {
        selectedCount--;
        [selectedArray replaceObjectAtIndex:indexPath.row withObject:@"NO"];
        [UIView animateWithDuration:0.2 delay:0.0 options:0
                         animations:^{
                             [[cell viewWithTag:2] setTransform:CGAffineTransformMakeScale(0.7, 0.7)];
                             [(UIImageView*)[cell viewWithTag:2] setImage:[UIImage imageNamed:@"check-off.png"]];
                         }
                         completion:^(BOOL finished) {
                             [UIView animateWithDuration:0.1 delay:0.0 options:0
                                              animations:^{
                                                  [[cell viewWithTag:2] setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
                                              }
                                              completion:^(BOOL finished) {
                                                  [self setNewSource:[idArray objectAtIndex:indexPath.row] andIsAdd:NO];
                                                  [tableView deselectRowAtIndexPath:indexPath animated:YES];
                                              }];
                             [UIView commitAnimations];
                         }];
        [UIView commitAnimations];
    }
    
    if (selectedCount < idArray.count)
    {
        [_selectAllButton setTitle:@"تحديد الكل"];
    }
    else
    {
        [_selectAllButton setTitle:@"إلغاء الكل"];
    }
}

-(void)setNewSource:(NSString*)theId andIsAdd:(BOOL)isAdd
{
    NSMutableArray *currentSubs = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"breakingSubscriptions"]];
    
    for (int i = 0; i < dictArray.count; i++)
    {
        if ([[@"" stringByAppendingFormat:@"%@",[dictArray objectAtIndex:i]] rangeOfString:theId].location != NSNotFound)
        {
            if (isAdd)
            {
                [currentSubs addObject:[dictArray objectAtIndex:i]];
            }
            else
            {
                [currentSubs removeObject:[dictArray objectAtIndex:i]];
            }
            break;
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:currentSubs forKey:@"breakingSubscriptions"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)saveAllSources
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isUrgentPush"])
    {
        NSMutableArray *currentSubs = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"breakingSubscriptions"]];
        
        NSMutableArray* sources = [[NSMutableArray alloc]init];
        
        for (NSDictionary* dict in currentSubs)
        {
            [sources addObject:[NSString stringWithFormat:@"c%@",[dict objectForKey:@"twitterID"]]];
        }
        
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        
        [currentInstallation setObject:[[NSArray alloc] init] forKey:@"urgentPush"];
        [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded && !error) {
                [currentInstallation addUniqueObjectsFromArray:sources forKey:@"urgentPush"];
                [currentInstallation saveInBackground];
                
                if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"breakingSubscriptions"] count] == 0)
                {
                    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isUrgentPush"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"خطأ في الإتصال" message:@"لم تتم إضافة المصادر للتنبيه، حاول مجدداً لاحقاً." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"موافق", nil];
                [alert show];
            }
            
        }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
