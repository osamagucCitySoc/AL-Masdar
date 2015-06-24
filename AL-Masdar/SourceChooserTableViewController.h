//
//  SourceChooserTableViewController.h
//  AL-Masdar
//
//  Created by Osama Rabie on 6/24/15.
//  Copyright (c) 2015 Osama Rabie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SourceChooserTableViewController : UITableViewController

@property(nonatomic,strong) NSMutableArray* dataSourcee;
@property(nonatomic,strong) NSString* section;
@property(nonatomic,strong) NSString* country;

@end
