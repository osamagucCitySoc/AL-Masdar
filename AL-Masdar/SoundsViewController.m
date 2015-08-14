//
//  SoundsViewController.m
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
    return 9;
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
    if (indexPath.row != 8)
    {
        [self playSound:[@"" stringByAppendingFormat:@"%ld",indexPath.row+1]];
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if([[NSUserDefaults standardUserDefaults] integerForKey:@"selectedSound"] != indexPath.row)
    {
        UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[[NSUserDefaults standardUserDefaults] integerForKey:@"selectedSound"] inSection:0]];
        [(UIImageView*)[selectedCell viewWithTag:2] setImage:[UIImage imageNamed:@"check-off.png"]];
        
        [[NSFileManager defaultManager] removeItemAtPath:[documentsDir stringByAppendingPathComponent:@"x.caf"] error:nil];
        
        NSString* path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[[@"" stringByAppendingFormat:@"%ld",indexPath.row+1] stringByAppendingString:@".caf"]];
        
        [[NSFileManager defaultManager] copyItemAtPath:path toPath:[documentsDir stringByAppendingPathComponent:@"x.caf"] error:nil];
    }
    
    [(UIImageView*)[cell viewWithTag:2] setImage:[UIImage imageNamed:@"check-on.png"]];
    
    if([[NSUserDefaults standardUserDefaults] integerForKey:@"selectedSound"] != indexPath.row)
    {
        [UIView animateWithDuration:0.2 delay:0.0 options:0
                         animations:^{
                             [[cell viewWithTag:2] setTransform:CGAffineTransformMakeScale(1.3, 1.3)];
                         }
                         completion:^(BOOL finished) {
                             [UIView animateWithDuration:0.2 delay:0.0 options:0
                                              animations:^{
                                                  [[cell viewWithTag:2] setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
                                              }
                                              completion:^(BOOL finished) {
                                                  [tableView deselectRowAtIndexPath:indexPath animated:YES];
                                              }];
                             [UIView commitAnimations];
                         }];
        [UIView commitAnimations];
    }
    else
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    
    [[NSUserDefaults standardUserDefaults] setInteger:indexPath.row forKey:@"selectedSound"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
