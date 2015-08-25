//
//  SelectViewController.h
//
//  Created by Housein Jouhar on 7/3/15.
//  Copyright (c) 2015 SADAH Software Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface SelectViewController : UITableViewController
{
    NSMutableArray *sourcesArray;
    NSMutableArray *idArray;
    NSMutableArray *selectedArray;
    NSMutableArray *dictArray;
    NSInteger selectedCount;
}

@property (strong, nonatomic) IBOutlet UIBarButtonItem *selectAllButton;

@end
