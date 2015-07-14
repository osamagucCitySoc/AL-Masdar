//
//  SADAHSwich.m
//  SADAHSwich
//
//  Created by Housein Jouhar on 6/25/13.
//  Copyright (c) 2013 SADAH Software Solutions. All rights reserved.
//

#import "SADAHSwitch.h"
#import <QuartzCore/QuartzCore.h>

#define SLIDER_X_ON  -2
#define SLIDER_X_OFF  -43
#define SLIDER_TAG  430

@implementation SADAHSwitch

@synthesize on = _on;

- (id)initWithFrame:(CGRect)frame
{
    CGRect cframe = CGRectMake(frame.origin.x, frame.origin.y, 70.0f, 29.0f);
    self = [super initWithFrame:cframe];
    if (self) {
        // Initialization code
        self.clipsToBounds = YES;
        CGRect cframe = CGRectMake(self.frame.origin.x, self.frame.origin.y, 70.0f, 29.0f);
        self.layer.cornerRadius = 4;
        self.frame = cframe;
        [self setNeedsDisplay];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self=[super initWithCoder: aDecoder];
    if(self) {
        self.clipsToBounds = YES;
        CGRect cframe = CGRectMake(self.frame.origin.x, self.frame.origin.y, 70.0f, 29.0f);
        self.layer.cornerRadius = 15;
        self.frame = cframe;
        [self setNeedsDisplay];
	}
	return self;
}

- (void)drawRect:(CGRect)rect {
    if (isDrawDone)return;
    isDrawDone = YES;
    [super drawRect:rect];
    UIImageView *slider = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"readability-swich-img.png"]];
    [slider setContentMode:UIViewContentModeScaleAspectFit];
    CGRect sliderFrame = slider.frame;
    if (_on) {
        sliderFrame.origin.x = SLIDER_X_ON;
    } else {
        sliderFrame.origin.x = SLIDER_X_OFF;
    }
    sliderFrame.origin.y = 0;
    slider.tag = SLIDER_TAG;
    slider.frame = sliderFrame;
    [self addSubview:slider];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    tapPt = [[touches anyObject] locationInView: self];
    xPos = tapPt.x + SLIDER_X_OFF;
    
    UIImageView *slider = (UIImageView *)[self viewWithTag:SLIDER_TAG];
    CGRect sliderFrame = slider.frame;
    if (xPos > SLIDER_X_ON) {
        xPos = SLIDER_X_ON;
    }
    if (xPos < SLIDER_X_OFF) {
        xPos = SLIDER_X_OFF;
    }
    sliderFrame.origin.x = xPos;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint tappedPt = [[touches anyObject] locationInView: self];
    xPos = tappedPt.x + SLIDER_X_OFF - 20;
    
    UIImageView *slider = (UIImageView *)[self viewWithTag:SLIDER_TAG];
    CGRect sliderFrame = slider.frame;
    if (xPos > SLIDER_X_ON) {
        xPos = SLIDER_X_ON;
    }
    if (xPos < SLIDER_X_OFF) {
        xPos = SLIDER_X_OFF;
    }
    sliderFrame.origin.x = xPos;
    
    slider.frame = sliderFrame;
    
    touchMoved = YES;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	UIImageView *slider = (UIImageView *)[self viewWithTag:SLIDER_TAG];
    CGRect sliderFrame = slider.frame;
    BOOL value;
    if (sliderFrame.origin.x < (SLIDER_X_OFF / 2)) {
        sliderFrame.origin.x = SLIDER_X_OFF;
        value = NO;
    } else {
        sliderFrame.origin.x = SLIDER_X_ON;
        value = YES;
    }
    if (touchMoved)
    {
        if (xPos < (SLIDER_X_OFF / 2)) {
            sliderFrame.origin.x = SLIDER_X_OFF;
            value = NO;
        } else {
            sliderFrame.origin.x = SLIDER_X_ON;
            value = YES;
        }
    }
    else
    {
        if (value)
        {
            sliderFrame.origin.x = SLIDER_X_OFF;
            value = NO;
        }
        else
        {
            sliderFrame.origin.x = SLIDER_X_ON;
            value = YES;
        }
    }
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    slider.frame = sliderFrame;
    [UIView commitAnimations];
    
    if (value != _on) {
        _on = value;
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
    touchMoved = NO;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	UIImageView *slider = (UIImageView *)[self viewWithTag:SLIDER_TAG];
    CGRect sliderFrame = slider.frame;
    BOOL value;
    if (sliderFrame.origin.x < (SLIDER_X_OFF / 2)) {
        sliderFrame.origin.x = SLIDER_X_OFF;
        value = NO;
    } else {
        sliderFrame.origin.x = SLIDER_X_ON;
        value = YES;
    }
    if (xPos < (SLIDER_X_OFF / 2)) {
        sliderFrame.origin.x = SLIDER_X_OFF;
        value = NO;
    } else {
        sliderFrame.origin.x = SLIDER_X_ON;
        value = YES;
    }
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    slider.frame = sliderFrame;
    [UIView commitAnimations];
    
    if (value != _on) {
        _on = value;
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
    
    touchMoved = NO;
}

- (void)setOn:(BOOL)on
{
    UIImageView *slider = (UIImageView *)[self viewWithTag:SLIDER_TAG];
    CGRect sliderFrame = slider.frame;
    _on = on;
    if (_on) {
        sliderFrame.origin.x = SLIDER_X_ON;
    } else {
        sliderFrame.origin.x = SLIDER_X_OFF;
    }
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    slider.frame = sliderFrame;
    [UIView commitAnimations];
}

@end