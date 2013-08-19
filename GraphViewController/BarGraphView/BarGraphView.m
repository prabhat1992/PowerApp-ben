//
//  BarGraphView.m
//  PowerApp
//
//  Created by Cory Hymel on 6/15/13.
//  Copyright (c) 2013 Prime Notion Technologies, Inc. All rights reserved.
//

#import "BarGraphView.h"
#import "AttributedLabel.h"
#import <QuartzCore/QuartzCore.h>

#define kBounceOffset 10.0f
#define kBarColor [UIColor colorWithRed:0.710f green:0.890f blue:0.937f alpha:1.000f]
#define RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

#define kDays [NSArray arrayWithObjects:@"m", @"t", @"w", @"t", @"f", @"s", @"s", nil]

@interface BarGraphView () {
    NSMutableArray *barLabels, *barTitles;
    int currentIndex;
    BOOL animating;
}

@end

@implementation BarGraphView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)addBars:(NSArray*)bars {
    
    float maxValue = [[bars valueForKeyPath:@"@max.self"] floatValue];
    
    float barSpacing = 0.0f;;
    
    if (bars.count == 7)
        barSpacing = 3.0f;
    else if (bars.count == 12)
        barSpacing = 4.0f;
    else
        barSpacing = 2.0f;
    
    float viewWidth = CGRectGetWidth(self.bounds);
    
    float viewHeight = CGRectGetHeight(self.bounds);
    
    float xOffset = (viewWidth / (bars.count));
    
    float barWidth = ((viewWidth / (bars.count)) - barSpacing);
    
    barLabels = [NSMutableArray new];
    
    
    [bars enumerateObjectsUsingBlock:^(NSNumber *value, NSUInteger idx, BOOL *stop) {
        
        float yLocation = viewHeight - (((([value floatValue] * 100) / maxValue) * viewHeight) / 100);
        
        float xLocation = (idx * xOffset) + (barSpacing / 2);
        
        float height = (viewHeight - yLocation);
        
        if (value.floatValue == 0.0f)
            height = 0.5f;
        
        AttributedLabel *barLabel = [AttributedLabel new];
        barLabel.frame = CGRectMake(xLocation, viewHeight, barWidth, 0);
        barLabel.beginFrame = barLabel.frame;
        barLabel.endFrame = CGRectMake(xLocation, yLocation, barWidth, height);
        barLabel.bounceFrame = CGRectMake(xLocation, yLocation - kBounceOffset, barWidth, height + kBounceOffset);
        
        UIColor *baseColor = RGBA(20, 134, 255, 1.0);
    
        if (bars.count != 12) {
            CGFloat hue, saturation, brightness, alpha;
            
            BOOL ok = [baseColor getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha ] ;
            if ( !ok ) {} // handle error
            
            float adjBrightness = brightness - (0.05 * (idx % 7));
            
            UIColor *newColor = [UIColor colorWithHue:hue saturation:saturation brightness:adjBrightness alpha:alpha];
            barLabel.backgroundColor = newColor;
        }
        else
            barLabel.backgroundColor = baseColor;
        
        [self addSubview:barLabel];
        
        
        UILabel *label = [[UILabel alloc] init];
        label.backgroundColor = [UIColor clearColor];
        
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentRight;
        
        if (bars.count == 7) {
            
            label.text = [kDays objectAtIndex:idx];
            
            label.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:40];
            
            if (value.floatValue != 0 || height <= kBounceOffset) {
                label.frame = CGRectMake(1, 1, barWidth - 2, barWidth - 2);
                [barLabel addSubview:label];
            }
            
            else {
                label.textColor = [UIColor lightGrayColor];
                label.textAlignment = NSTextAlignmentCenter;
                label.clipsToBounds = NO;
                barLabel.clipsToBounds = NO;
                label.frame = CGRectMake(xLocation, viewHeight - barWidth, barWidth - 2, barWidth - 2);
                [self addSubview:label];
            }
        }
        
        else if (bars.count == 12) {
            
            label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
            
            label.text = [NSString stringWithFormat:@"%d", (idx + 1)];
            label.frame = CGRectMake(1, 1, barWidth - 2, barWidth - 2);
            [barLabel addSubview:label];
        }
        
        else {
            
            label.font = [UIFont fontWithName:@"HelveticaNeue" size:10];
            
            if ((idx == 0) || (idx == (bars.count / 2))  || (idx == (bars.count - 1))) {
                label.text = [NSString stringWithFormat:@"%d", (idx + 1)];
                label.frame = CGRectMake(1, 1, barWidth - 2, barWidth - 2);
                [barLabel addSubview:label];
            }
        }
        
        
        [barTitles addObject:label];
        
        [barLabels addObject:barLabel];
        
    }];
}

- (void)titleForIndex:(int)idx {
    
    
    
    
    
}

- (void)animateLables {
    
    if (animating)
        return;
    
    currentIndex = 0.0f;
    
    float interval = 0.0f;
    
    if (barLabels.count == 7)
        interval = 0.2;
    else if (barLabels.count > 12)
        interval = 0.05;
    else
        interval = 0.1;
    
    
    NSTimer *timer = [NSTimer timerWithTimeInterval:interval target:self selector:@selector(animateLabel:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
}

- (void)animateLabel:(NSTimer*)timer {
    
    AttributedLabel *label = [barLabels objectAtIndex:currentIndex];
    currentIndex++;
    
    //AttributedLabel *titleLabel = [barTitles objectAtIndex:currentIndex];
    
    [UIView animateWithDuration:0.3f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
        label.frame = label.bounceFrame;
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.2 delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
            label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y + kBounceOffset, label.frame.size.width, label.frame.size.height);
        } completion:^(BOOL finished) {
            label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y, label.frame.size.width, label.frame.size.height - kBounceOffset);
        }];
    }];
    
    if ((currentIndex + 1) > barLabels.count) {
        [timer invalidate];
        animating = NO;
    }
}


/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
