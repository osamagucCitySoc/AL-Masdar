//
//  SettingsViewController.m
//
//  Created by Housein Jouhar on 7/3/15.
//  Copyright (c) 2015 SADAH Software Solutions. All rights reserved.
//

#import "SoundsViewController.h"

@interface SoundsViewController ()

@end

@implementation SoundsViewController

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
}

-(void)playSound:(NSString*)theSound
{
    NSString* path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[theSound stringByAppendingString:@".caf"]];
    
    NSError* error;
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:&error];
    self.player.delegate = self;
    [self.player play];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    if (flag) {
        NSLog(@"audioPlayerDidFinishPlaying successfully");
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* cellID = @"soundCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    
    if(!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    if (indexPath.row == 0)
    {
        [(UILabel*)[cell viewWithTag:1] setText:@"الصوت الأول"];
    }
    else if (indexPath.row == 1)
    {
        [(UILabel*)[cell viewWithTag:1] setText:@"الصوت الثاني"];
    }
    else if (indexPath.row == 2)
    {
        [(UILabel*)[cell viewWithTag:1] setText:@"الصوت الثالث"];
    }
    else if (indexPath.row == 3)
    {
        [(UILabel*)[cell viewWithTag:1] setText:@"الصوت الرابع"];
    }
    else if (indexPath.row == 4)
    {
        [(UILabel*)[cell viewWithTag:1] setText:@"الصوت الخامس"];
    }
    else if (indexPath.row == 5)
    {
        [(UILabel*)[cell viewWithTag:1] setText:@"الصوت السادس"];
    }
    else if (indexPath.row == 6)
    {
        [(UILabel*)[cell viewWithTag:1] setText:@"الصوت السابع"];
    }
    else if (indexPath.row == 7)
    {
        [(UILabel*)[cell viewWithTag:1] setText:@"الصوت الثامن"];
    }
    else if (indexPath.row == 8)
    {
        [(UILabel*)[cell viewWithTag:1] setText:@"الصوت الافتراضي"];
    }
    else if (indexPath.row == 9)
    {
        [(UILabel*)[cell viewWithTag:1] setText:@"بدون صوت"];
    }
    
    if([[NSUserDefaults standardUserDefaults] integerForKey:@"selectedSound"] == indexPath.row)
    {
        [(UIImageView*)[cell viewWithTag:2] setImage:[UIImage imageNamed:@"check-on.png"]];
    }
    else
    {
        [(UIImageView*)[cell viewWithTag:2] setImage:[UIImage imageNamed:@"check-off.png"]];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 8)
    {
        AudioServicesPlaySystemSound(1315);
    }
    else if (indexPath.row != 9)
    {
        [self playSound:[@"" stringByAppendingFormat:@"%ld",indexPath.row+1]];
    }
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if([[NSUserDefaults standardUserDefaults] integerForKey:@"selectedSound"] != indexPath.row)
    {
        UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[[NSUserDefaults standardUserDefaults] integerForKey:@"selectedSound"] inSection:0]];
        [(UIImageView*)[selectedCell viewWithTag:2] setImage:[UIImage imageNamed:@"check-off.png"]];
    }
    
    [(UIImageView*)[cell viewWithTag:2] setImage:[UIImage imageNamed:@"check-on.png"]];
    
    [[NSUserDefaults standardUserDefaults] setInteger:indexPath.row forKey:@"selectedSound"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
