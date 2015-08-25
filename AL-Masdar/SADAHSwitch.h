//
//  SADAHSwich.h
//  SADAHSwich
//
//  Created by Housein Jouhar on 6/25/13.
//  Copyright (c) 2013 SADAH Software Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SADAHSwitch : UIControl {
    CGPoint tapPt;
    int     xPos;
@private
    BOOL    _on,touchMoved,isDrawDone;
}

@property (nonatomic, assign) BOOL on;

@end
