//
//  SoccerViewController.m
//
//  Created by Housein Jouhar on 8/1/15.
//  Copyright (c) 2015 SADAH Software Solutions. All rights reserved.
//

#import "SoccerViewController.h"

@interface SoccerViewController ()

@end

@implementation SoccerViewController

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
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isNightOn"])
    {
        blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    }
    else
    {
        blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSData* data = [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:@"http://almasdarapp.com/almasdar/getGoals.php"]];
        
        dataSource = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        
        [self.tableView reloadData];
    });
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isNightOn"])
    {
        [[self.navigationController navigationBar] setBarTintColor:[UIColor colorWithRed:70.0/255.0 green:70.0/255.0 blue:70.0/255.0 alpha:1.0]];
        [[self.navigationController navigationBar] setTintColor:[UIColor whiteColor]];
        [[self.navigationController navigationBar] setBarStyle:UIBarStyleBlack];
        [self.tableView setBackgroundColor:[UIColor colorWithRed:50.0/255.0 green:50.0/255.0 blue:50.0/255.0 alpha:1.0]];
    }
    else
    {
        [self setTheColor];
        [self.tableView setBackgroundColor:[UIColor colorWithRed:241.0/255.0 green:241.0/255.0 blue:241.0/255.0 alpha:1.0]];
    }
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* cellID = @"soccerCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    
    if(!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    [(UILabel*)[cell viewWithTag:1]setText:[[dataSource objectAtIndex:indexPath.row] objectForKey:@"title"]];
    
    [[cell viewWithTag:10] removeFromSuperview];
    
    UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    
    [visualEffectView setAlpha:0.7];
    
    [visualEffectView setTag:10];
    
    visualEffectView.frame = cell.contentView.bounds;
    
    [cell.contentView insertSubview:visualEffectView aboveSubview:[cell viewWithTag:2]];
    
    [(UIImageView*)[cell viewWithTag:2] sd_setImageWithURL:[NSURL URLWithString:[[dataSource objectAtIndex:indexPath.row] objectForKey:@"image"]]
                                          placeholderImage:nil];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* htmlCode = [[dataSource objectAtIndex:indexPath.row] objectForKey:@"iframe"];
    
    [[NSUserDefaults standardUserDefaults] setObject:htmlCode forKey:@"currentHtmlCode"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self performSegueWithIdentifier:@"watchSeg" sender:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
