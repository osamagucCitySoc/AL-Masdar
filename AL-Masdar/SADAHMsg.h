//
//  SADAHMsg.h
//  SADAHMsg
//
//  Created by Housein Jouhar on 31/05/15.
//  Copyright (c) 2015 SADAH Software Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface SADAHMsg : NSObject

typedef void(^ActionBlock)(BOOL);

+(void)showMsgWithTitle:(NSString*)theTitle andMsg:(NSString*)theMsg inView:(UIView*)theView withCase:(NSInteger)theCase withBlock:(ActionBlock)completion;
+(void)showMsgWithTitle:(NSString*)theTitle andMsg:(NSString*)theMsg inView:(UIView*)theView withCase:(NSInteger)theCase;
+(void)showRateViewIn:(UIView*)theView;
+(void)showDoneMsgWithTitle:(NSString*)theTitle andMsg:(NSString*)theMsg inView:(UIView*)theView;

@end
