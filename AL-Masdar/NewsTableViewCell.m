//
//  NewsTableViewCell.m
//  MicroTransfer
//
//  Created by jacksonpan on 13-1-15.
//  Copyright (c) 2013年 weichuan. All rights reserved.
//

#import "NewsTableViewCell.h"

@implementation NewsTableViewCell

- (void )layoutSubviews {
    [super layoutSubviews];
    
    self.selectedBackgroundView.frame = CGRectMake(5, 7, self.frame.size.width -10, self.frame.size.height -11);
}

@end
