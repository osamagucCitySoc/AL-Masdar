//
//  NewsTableViewCell.m
//
//  Created by Housein Jouhar on 31/05/15.
//  Copyright (c) 2015 SADAH Software Solutions. All rights reserved.
//

#import "NewsTableViewCell.h"

@implementation NewsTableViewCell

- (void )layoutSubviews {
    [super layoutSubviews];
    
    self.selectedBackgroundView.frame = CGRectMake(5, 0, self.frame.size.width -10, self.frame.size.height);
}

@end
