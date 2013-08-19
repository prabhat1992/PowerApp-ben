//
//  LineGraphView.m
//  PowerApp
//
//  Created by Cory Hymel on 6/15/13.
//  Copyright (c) 2013 Prime Notion Technologies, Inc. All rights reserved.
//

#import "LineGraphView.h"
#import <QuartzCore/QuartzCore.h>

#define kDotDiameter    5.0f
#define kLineWidth      3.0f
#define kDataGroup      30
#define kLineColor      [UIColor colorWithRed:0.655f green:0.855f blue:0.655f alpha:1.000f]
#define kExtraLineColor [UIColor colorWithRed:0.835f green:0.400f blue:0.396f alpha:0.700f]

@interface LineGraphView () {
    NSMutableArray *graphLayers; //Array of CAShapeLayers that have been drawn on screen
    NSMutableArray *dataArrays; //Array of NSArrays of data
    NSMutableArray *colors;
    
    BOOL drawDots; //If you want dots to be drawn at each point in the line graph

    float minValue, maxValue; //The current max and min value of data graphed
}

@end

@implementation LineGraphView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    maxValue = 0.0f;
    minValue = 0.0f;
    dataArrays = [NSMutableArray new];
    graphLayers = [NSMutableArray new];
    
    colors = [NSMutableArray new];
    [colors addObject:kLineColor];
    [colors addObject:kExtraLineColor];
}

#pragma mark -
#pragma mark - Public methods

/* Graph an array of data
 @param NSArray of NSNumber items of data points to graph
 */
- (void)addLine:(NSArray*)data animated:(BOOL)animated{
    [self addLine:data cleanData:YES animated:animated];
}

/* Remove a layer at a given index from the screen. This will also delete the associated data array so if you need it back you will have to reload the data on your own. 
 @param The index of the layer to remove
*/
- (void)removeLayerAtIndex:(int)index {
    if (index < 0 || index > graphLayers.count)
        return;
    
    CAShapeLayer *layerToRemove = [graphLayers objectAtIndex:index];
    [layerToRemove removeFromSuperlayer]; layerToRemove = nil;
    
    [graphLayers removeObjectAtIndex:index];
    
    NSArray *dataToRemove = [dataArrays objectAtIndex:index];
    
    bool needsRedraw = NO;
    if ([[dataToRemove valueForKeyPath:@"@min.self"] floatValue] == minValue) {
        needsRedraw = YES;
    }
    
    if ([[dataToRemove valueForKeyPath:@"@max.self"] floatValue] == maxValue) {
        needsRedraw = YES;
    }
    
    [dataArrays removeObjectAtIndex:index];
    
    if (needsRedraw) {
        [self reloadLines];
        return;
    }
}

#pragma mark -
#pragma mark - Private methods

/* If the max or min values change when adding or removing a layer, we need to reload all the data to adjust accordingly
*/
- (void)reloadLines {
    
    NSArray *data = [NSArray arrayWithArray:dataArrays];
    
    [graphLayers enumerateObjectsUsingBlock:^(CAShapeLayer *layer, NSUInteger idx, BOOL *stop) {
        [layer removeFromSuperlayer]; layer = nil;
    }];
    
    [graphLayers removeAllObjects];
    [dataArrays removeAllObjects];
    
    [data enumerateObjectsUsingBlock:^(NSArray *array, NSUInteger idx, BOOL *stop) {
        [self addLine:array cleanData:NO animated:YES];
    }];
}

/* Adds the line to the graph. We are also able to control if the data needs to be "cleaned" or not. If it's coming from a public method call then it has to be "cleaned", otherwise we don't have to. 
*/
- (void)addLine:(NSArray*)data cleanData:(BOOL)dirtyData animated:(BOOL)animated {

    drawDots = NO;
    
    NSAssert([[data objectAtIndex:0] isKindOfClass:[NSNumber class]], @"This method only accepts arrays of NSNumber objects.");
    
    CAShapeLayer *newLineLayer = [self createLine:data cleanData:dirtyData animated:animated];
    
    if (!newLineLayer)
        return;
    

    [self.layer addSublayer:newLineLayer];
    [graphLayers addObject:newLineLayer];
}

- (CAShapeLayer*)createLine:(NSArray*)data cleanData:(BOOL)dirtyData animated:(BOOL)animated{
    
    drawDots = NO;
    
    NSAssert([[data objectAtIndex:0] isKindOfClass:[NSNumber class]], @"This method only accepts arrays of NSNumber objects.");
    
    int stopIndex = data.count;
    
    NSArray *cleanData;
    
    if (dirtyData)
        cleanData = [self cleanData:data];
    else
        cleanData = [NSArray arrayWithArray:data];
    
    bool needsRedraw = NO;
    if ([[cleanData valueForKeyPath:@"@min.self"] floatValue] < minValue) {
        minValue = [[cleanData valueForKeyPath:@"@min.self"] floatValue];
        needsRedraw = YES;
    }
    
    if ([[cleanData valueForKeyPath:@"@max.self"] floatValue] > maxValue) {
        maxValue = [[cleanData valueForKeyPath:@"@max.self"] floatValue];
        needsRedraw = YES;
    }
    
    [dataArrays addObject:cleanData];
    
    if (needsRedraw) {
        [self reloadLines];
        return nil;
    }
    
    UIColor *color;
    if (graphLayers.count)
        color = [colors objectAtIndex:(graphLayers.count - 1)];
    else
        color = [colors objectAtIndex:0];
    
    CAShapeLayer *newLineLayer = [self lineShapeLayerWithColor:color];
    newLineLayer.path = [self pathFromData:cleanData stopIndex:[NSNumber numberWithInt:stopIndex]].CGPath;
    //[self.layer addSublayer:newLineLayer];
    
    [graphLayers addObject:newLineLayer];
    
    //Add the animation to the shape layer. This will make it animate its drawing and it HAS to be done after the shape layer is added to the view's layer.
    if (animated)
        [self addStrokeEndAnimationToLayer:newLineLayer duration:2];
    
    return newLineLayer;
}


/* Clean the data
*/
- (NSArray*)cleanData:(NSArray*)data {
    
    NSMutableArray *returnData = [NSMutableArray arrayWithArray:data];
    
    //Run through and make sure it is out of 1400 (since that's how many minutes are in the day)
    if (data.count < 1400){
        for (int i = returnData.count; i < 1400; i++ ) {
            [returnData addObject:[NSNumber numberWithInt:0]];
        }
    }
    else if (data.count > 1400) {
        NSRange r;
        r.location = 1401;
        r.length = [returnData count]-1401;
        [returnData removeObjectsInRange:r];
    }
    
    NSMutableArray *adjData = [NSMutableArray new];
    
    __block float runningAmount = 0.0f;
    
    //We run through and find averages because graphing all 1400 is to much and looks like crap. 
    [returnData enumerateObjectsUsingBlock:^(NSNumber *value, NSUInteger idx, BOOL *stop) {
        
        runningAmount += [value floatValue];
        
        if (idx % kDataGroup == 0 && idx > 0) {
            [adjData addObject:[NSNumber numberWithFloat:runningAmount]];
            runningAmount = 0.0f;
        }
    }];
    
    
    NSLog(@"adjData count = %d", adjData.count);
    
    return adjData;
}

#pragma mark -
#pragma mark - Drawing helpers 

/* Adds a stroke animation to a given CAShapeLayer, a little overkill to abstract this out but whatever. 
*/
- (void)addStrokeEndAnimationToLayer:(CAShapeLayer*)shapeLayer duration:(NSTimeInterval)duration {
    [shapeLayer addAnimation:[self strokeEndAnimationWithDuration:duration] forKey:@"strokeEnd"];
}

/* Creates a basic CAShapelayer for the lines. It accepts a color for the line as well. 
*/
- (CAShapeLayer*)lineShapeLayerWithColor:(UIColor*)color {
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.strokeColor = [color CGColor];
    shapeLayer.fillColor = nil;
    shapeLayer.lineWidth = kLineWidth;
    shapeLayer.lineJoin = kCALineJoinRound;
    return shapeLayer;
}

/* Creates a basic stroke beginning to end animation
*/
- (CABasicAnimation*)strokeEndAnimationWithDuration:(NSTimeInterval)duration {
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = 2.0;
    pathAnimation.fromValue = @(0.0f);
    pathAnimation.toValue = @(1.0f);
    return pathAnimation;
}

/* The guts of this class. This method takes in the formatted data array and creates a UIBezierPath to be drawn on screen. 
*/
- (UIBezierPath*)pathFromData:(NSArray*)data stopIndex:(NSNumber*)stopIndex {
    
    int viewHeight = CGRectGetHeight(self.bounds);
    int viewWidth = CGRectGetWidth(self.bounds);

    
    float minOffset = ((((minValue * 100) / maxValue) * viewHeight) / 100);
    
    viewHeight = viewHeight - abs(minOffset);
    
    NSLog(@"minOffset = %f", minOffset);
    
    
    //Create the bezier path that will hold all the points of data
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];

    //Draw the user subscales scores
    [data enumerateObjectsUsingBlock:^(NSNumber *userValue, NSUInteger idx, BOOL *stop) {
        
        
        if (idx <= [stopIndex floatValue]) {
            
            //Find the x and y location
            //float yLocation = viewHeight - (viewHeight * [userValue floatValue]);
            
            float yLocation = viewHeight - (((([userValue floatValue] * 100) / maxValue) * viewHeight) / 100) ;
            
            float xLocation = (idx *  (viewWidth / (data.count - 1))) - (kDotDiameter / 2);
            
            //If its the first point we need to make sure and move to that point not add to it
            if (idx == 0)
                [bezierPath moveToPoint: CGPointMake(xLocation, yLocation)];
            else
                [bezierPath addLineToPoint: CGPointMake(xLocation, yLocation)];
            
            //If we want dots at each data point on the graph
            if (drawDots) {
                UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake((idx *  (viewWidth / data.count)), (yLocation - (kDotDiameter / 2)), kDotDiameter, kDotDiameter)];
                [[UIColor greenColor] setFill];
                [ovalPath fill];
                
                CAShapeLayer *ovalLayer = [CAShapeLayer layer];
                ovalLayer.path = ovalPath.CGPath;
                ovalLayer.fillColor = nil;
                
                if ([userValue floatValue] < 0)
                    ovalLayer.strokeColor = [[UIColor greenColor] CGColor];
                else if ([userValue floatValue] == 0)
                    ovalLayer.strokeColor = [[UIColor blueColor] CGColor];
                else if ([userValue floatValue] > 0)
                    ovalLayer.strokeColor = [[UIColor redColor] CGColor];
                
                [self.layer addSublayer:ovalLayer];
            }
        }
        else {
            *stop = YES;
        }
    }];
    
    return bezierPath;
}



/* Add multiple lines to the graph at one time
 @param NSArray of NSArrays which are arrays of NSNumbers to of data points to be graphed.
 
 - (void)addLines:(NSArray*)lines animated:(BOOL)animated {
 
 NSMutableArray *newLines = [NSMutableArray new];
 
 [lines enumerateObjectsUsingBlock:^(NSArray *data, NSUInteger idx, BOOL *stop) {
 CAShapeLayer *newLayer = [self createLine:data cleanData:YES animated:NO];
 [newLines addObject:newLayer];
 }];
 
 [newLines enumerateObjectsUsingBlock:^(CAShapeLayer *layer, NSUInteger idx, BOOL *stop) {
 
 [self.layer addSublayer:layer];
 [self addStrokeEndAnimationToLayer:layer duration:2.0f];
 }];
 
 }
 */

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
