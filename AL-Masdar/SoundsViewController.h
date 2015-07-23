//
//  SoundsViewController.h
//
//  Created by Housein Jouhar on 7/3/15.
//  Copyright (c) 2015 SADAH Software Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface SoundsViewController : UITableViewController <AVAudioPlayerDelegate>

@property (strong, nonatomic) IBOutlet AVAudioPlayer *player;
@end
