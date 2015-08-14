//
//  WatchViewController.m
//
//  Created by Housein Jouhar on 07/6/15.
//  Copyright (c) 2015 SADAH Software Solutions. All rights reserved.
//
////

#import "TableController.h"

@interface TableController()

@end

@implementation TableController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
}

- (void)willActivate {
    [super willActivate];
    
    if (newsTitleArr.count == 0)
    {
        [_waitImg setHidden:NO];
        
        UIImage * img1 = [UIImage imageNamed:@"wait-watch-1"];
        UIImage * img2 = [UIImage imageNamed:@"wait-watch-2"];
        UIImage * img3 = [UIImage imageNamed:@"wait-watch-3"];
        
        UIImage * img = [UIImage animatedImageWithImages:@[img1, img2, img3] duration:0.6];
        
        [_waitImg setImage:img];
        [_waitImg startAnimating];
    }
    
    currentCaseNum = [[NSUserDefaults standardUserDefaults] integerForKey:@"currentReqNum"];
    
    if (currentCaseNum == 1)
    {
        [self getNewsData];
    }
    else if (currentCaseNum == 2)
    {
        [self getFavData];
    }
    else if (currentCaseNum == 3)
    {
        [self getBreakingData];
    }
}

- (IBAction)loadMoreNews {
    [_loadMoreButton setTitle:@"جاري التحميل.."];
    if (currentCaseNum == 1)
    {
        [self getNewsData];
    }
    else if (currentCaseNum == 3)
    {
        [self getBreakingData];
    }
}

-(void)getNewsData
{
    NSDictionary *requst;
    
    if (upperId)
    {
        requst = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"getNewsData",upperId,@"-1", nil] forKeys:[NSArray arrayWithObjects:@"request",@"upperCurrentID",@"lowerCurrentID", nil]];
    }
    else
    {
        requst = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"getNewsData",@"0",@"-1", nil] forKeys:[NSArray arrayWithObjects:@"request",@"upperCurrentID",@"lowerCurrentID", nil]];
    }
    
    [WKInterfaceController openParentApplication:requst
                                           reply:^( NSDictionary *replyInfo, NSError *error ) {
                                               if (newsTitleArr.count == 0)
                                               {
                                                   newsTitleArr = [[NSMutableArray alloc] init];
                                                   newsBodyArr = [[NSMutableArray alloc] init];
                                                   fullBodyArr = [[NSMutableArray alloc] init];
                                               }
                                               
                                               NSMutableArray *dataSource = [[NSMutableArray alloc]init];
                                               
                                               dataSource = [replyInfo objectForKey:@"theReply"];
                                               upperId = [replyInfo objectForKey:@"upperId"];
                                               
                                               NSMutableArray *filterArr = [[NSMutableArray alloc] init];
                                               NSMutableArray *checkArr = [[NSMutableArray alloc] init];
                                               
                                               NSDictionary* news;
                                               
                                               for (int i = 0; i < dataSource.count; i++)
                                               {
                                                   news = [dataSource objectAtIndex:i];
                                                   
                                                   if (![checkArr containsObject:[news objectForKey:@"body"]])
                                                   {
                                                       [checkArr addObject:[news objectForKey:@"body"]];
                                                       [filterArr addObject:[dataSource objectAtIndex:i]];
                                                   }
                                               }
                                               
                                               NSDictionary *myNews;
                                               
                                               dataSource = [[NSMutableArray alloc] initWithArray:filterArr];
                                               
                                               lastRow = 0;
                                               
                                               for (int i = 0; i < dataSource.count; i++)
                                               {
                                                   myNews = [dataSource objectAtIndex:i];
                                                   
                                                   if (![newsBodyArr containsObject:[myNews objectForKey:@"body"]])
                                                   {
                                                       [newsTitleArr addObject:[myNews objectForKey:@"name"]];
                                                       [newsBodyArr addObject:[myNews objectForKey:@"body"]];
                                                       [fullBodyArr addObject:[myNews objectForKey:@"fullBody"]];
                                                       lastRow++;
                                                   }
                                               }
                                               
                                               [self loadAllData];
                                           }];
}

-(void)getFavData
{
    NSDictionary *requst;
    
    if (upperId)
    {
        requst = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"getFavData",upperId,@"-1", nil] forKeys:[NSArray arrayWithObjects:@"request",@"upperCurrentID",@"lowerCurrentID", nil]];
    }
    else
    {
        requst = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"getFavData",@"0",@"-1", nil] forKeys:[NSArray arrayWithObjects:@"request",@"upperCurrentID",@"lowerCurrentID", nil]];
    }
    
    [WKInterfaceController openParentApplication:requst
                                           reply:^( NSDictionary *replyInfo, NSError *error ) {
                                               if (newsTitleArr.count == 0)
                                               {
                                                   newsTitleArr = [[NSMutableArray alloc] init];
                                                   newsBodyArr = [[NSMutableArray alloc] init];
                                                   fullBodyArr = [[NSMutableArray alloc] init];
                                               }
                                               
                                               NSMutableArray *dataSource = [[NSMutableArray alloc]init];
                                               
                                               dataSource = [replyInfo objectForKey:@"theReply"];
                                               upperId = [replyInfo objectForKey:@"upperId"];
                                               
                                               NSMutableArray *filterArr = [[NSMutableArray alloc] init];
                                               NSMutableArray *checkArr = [[NSMutableArray alloc] init];
                                               
                                               NSDictionary* news;
                                               
                                               for (int i = 0; i < dataSource.count; i++)
                                               {
                                                   news = [dataSource objectAtIndex:i];
                                                   
                                                   if (![checkArr containsObject:[news objectForKey:@"body"]])
                                                   {
                                                       [checkArr addObject:[news objectForKey:@"body"]];
                                                       [filterArr addObject:[dataSource objectAtIndex:i]];
                                                   }
                                               }
                                               
                                               NSDictionary *myNews;
                                               
                                               dataSource = [[NSMutableArray alloc] initWithArray:filterArr];
                                               
                                               lastRow = 0;
                                               
                                               for (int i = 0; i < dataSource.count; i++)
                                               {
                                                   myNews = [dataSource objectAtIndex:i];
                                                   
                                                   if (![newsBodyArr containsObject:[myNews objectForKey:@"body"]])
                                                   {
                                                       [newsTitleArr addObject:[myNews objectForKey:@"name"]];
                                                       [newsBodyArr addObject:[myNews objectForKey:@"body"]];
                                                       [fullBodyArr addObject:[myNews objectForKey:@"fullBody"]];
                                                       lastRow++;
                                                   }
                                               }
                                               
                                               [self loadAllData];
                                           }];
}

-(void)getBreakingData
{
    NSDictionary *requst;
    
    if (upperId)
    {
        requst = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"getBreakingData",upperId,@"-1", nil] forKeys:[NSArray arrayWithObjects:@"request",@"upperCurrentID",@"lowerCurrentID", nil]];
    }
    else
    {
        requst = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"getBreakingData",@"0",@"-1", nil] forKeys:[NSArray arrayWithObjects:@"request",@"upperCurrentID",@"lowerCurrentID", nil]];
    }
    
    [WKInterfaceController openParentApplication:requst
                                           reply:^( NSDictionary *replyInfo, NSError *error ) {
                                               if (newsTitleArr.count == 0)
                                               {
                                                   newsTitleArr = [[NSMutableArray alloc] init];
                                                   newsBodyArr = [[NSMutableArray alloc] init];
                                                   fullBodyArr = [[NSMutableArray alloc] init];
                                               }
                                               
                                               NSMutableArray *dataSource = [[NSMutableArray alloc]init];
                                               
                                               dataSource = [replyInfo objectForKey:@"theReply"];
                                               upperId = [replyInfo objectForKey:@"upperId"];
                                               
                                               NSMutableArray *filterArr = [[NSMutableArray alloc] init];
                                               NSMutableArray *checkArr = [[NSMutableArray alloc] init];
                                               
                                               NSDictionary* news;
                                               
                                               for (int i = 0; i < dataSource.count; i++)
                                               {
                                                   news = [dataSource objectAtIndex:i];
                                                   
                                                   if (![checkArr containsObject:[news objectForKey:@"body"]])
                                                   {
                                                       [checkArr addObject:[news objectForKey:@"body"]];
                                                       [filterArr addObject:[dataSource objectAtIndex:i]];
                                                   }
                                               }
                                               
                                               NSDictionary *myNews;
                                               
                                               dataSource = [[NSMutableArray alloc] initWithArray:filterArr];
                                               
                                               lastRow = 0;
                                               
                                               for (int i = 0; i < dataSource.count; i++)
                                               {
                                                   myNews = [dataSource objectAtIndex:i];
                                                   
                                                   if (![newsBodyArr containsObject:[myNews objectForKey:@"body"]])
                                                   {
                                                       [newsTitleArr addObject:[myNews objectForKey:@"name"]];
                                                       [newsBodyArr addObject:[myNews objectForKey:@"body"]];
                                                       [fullBodyArr addObject:[myNews objectForKey:@"fullBody"]];
                                                       lastRow++;
                                                   }
                                               }
                                               
                                               [self loadAllData];
                                           }];
}

-(void)loadAllData
{
    lastRow = lastRow+self.tableView.numberOfRows;
    
    if (self.tableView.numberOfRows > 0)
    {
        NSMutableIndexSet *mutableIndexSet = [[NSMutableIndexSet alloc] init];
        
        for (int i = 0; i < lastRow; i++)
        {
            if (i > self.tableView.numberOfRows)
            {
                [mutableIndexSet addIndex:i-1];
            }
        }
        
        [self.tableView insertRowsAtIndexes:mutableIndexSet withRowType:@"myRow"];
        
        for (int i = 0; i < lastRow; i++)
        {
            MyRowController *theRow = (MyRowController *)[self.tableView rowControllerAtIndex:i];
            
            [theRow.titleLabel setText:[newsTitleArr objectAtIndex:i]];
            [theRow.bodyLabel setText:[newsBodyArr objectAtIndex:i]];
        }
    }
    else
    {
        [self.tableView setNumberOfRows:newsTitleArr.count withRowType:@"myRow"];
        
        for (int i = 0; i < self.tableView.numberOfRows; i++)
        {
            MyRowController *theRow = (MyRowController *)[self.tableView rowControllerAtIndex:i];
            
            [theRow.titleLabel setText:[newsTitleArr objectAtIndex:i]];
            [theRow.bodyLabel setText:[newsBodyArr objectAtIndex:i]];
        }
    }
    
    if (currentCaseNum == 1)
    {
        [_noNewsLabel setText:@"لايوجد أخبار"];
        [_noNewsImg setImage:[UIImage imageNamed:@"timeline-watch-icon"]];
    }
    else if (currentCaseNum == 2)
    {
        [_noNewsLabel setText:@"لايوجد أخبار"];
        [_noNewsImg setImage:[UIImage imageNamed:@"favorites-watch-icon"]];
    }
    else if (currentCaseNum == 3)
    {
        [_noNewsLabel setText:@"لايوجد أخبار عاجلة"];
        [_noNewsImg setImage:[UIImage imageNamed:@"breaking-watch-icon"]];
    }
    
    [_loadMoreButton setTitle:@"تحميل المزيد"];
    
    if (newsTitleArr.count == 0)
    {
        [_noNewsLabel setHidden:NO];
        [_noNewsImg setHidden:NO];
        [_loadMoreButton setHidden:YES];
    }
    else
    {
        [_noNewsLabel setHidden:YES];
        [_noNewsImg setHidden:YES];
        if (currentCaseNum != 2)
        {
            [_loadMoreButton setHidden:NO];
        }
    }
    
    [_waitImg stopAnimating];
    [_waitImg setHidden:YES];
    
    [self.tableView setHidden:NO];
}

- (void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex
{
    [[NSUserDefaults standardUserDefaults] setObject:[fullBodyArr objectAtIndex:rowIndex] forKey:@"currentFullBody"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self pushControllerWithName:@"infoNewsSeg" context:nil];
}

- (void)didDeactivate {
    [super didDeactivate];
}

@end



