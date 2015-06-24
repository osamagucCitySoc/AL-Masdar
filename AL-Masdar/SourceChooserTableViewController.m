//
//  SourceChooserTableViewController.m
//  AL-Masdar
//
//  Created by Osama Rabie on 6/24/15.
//  Copyright (c) 2015 Osama Rabie. All rights reserved.
//

#import "SourceChooserTableViewController.h"

@interface SourceChooserTableViewController ()

@end


@implementation SourceChooserTableViewController
{
    NSMutableArray* myDataSource;
}

@synthesize country,dataSourcee,section;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    myDataSource = [[NSMutableArray alloc]init];
    
    
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
        NSString *num1 =[obj1 objectForKey:@"name"];
        NSString *num2 =[obj2 objectForKey:@"name"];
        return (NSComparisonResult) [num1 compare:num2 options:(NSNumericSearch)];
    }];
    
    myDataSource = [[NSMutableArray alloc]initWithArray:aSortedArray copyItems:YES];
    
    [self.tableView reloadData];
    [self.tableView setNeedsDisplay];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return myDataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* cellID = @"sourceCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    
    if(!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    [[cell textLabel]setText:[[myDataSource objectAtIndex:indexPath.row] objectForKey:@"name"]];
    
    return cell;
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

@end
